-- 0030_group_functions_writes_admin.sql
-- Purpose: Batch 4 (Groups) — admin-only moderation RPCs (approve/reject/invite/assign/revoke)
-- plus user-level block/unblock (used for "block user in group", per docs/features/05-groups.md
-- §5 — blocks are user-level, not group-scoped, per that doc's §8 open question #9).
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5. Sensitive/moderation actions
-- (approve/reject/admin changes) are audited per this task's explicit instruction.

begin;

-- ---------------------------------------------------------------------------------------------
-- approve_join_request — admin-only. Target must have a pending request. Audited.
-- ---------------------------------------------------------------------------------------------
create or replace function public.approve_join_request(p_group_id uuid, p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'approve_join_request: no authenticated user';
  end if;

  if not public.is_group_admin(p_group_id, v_uid) then
    raise exception 'approve_join_request: caller is not an admin of this group';
  end if;

  if not exists (
    select 1 from public.group_user_status
    where group_id = p_group_id and user_id = p_user_id and coalesce(is_requested, false)
  ) then
    raise exception 'approve_join_request: no pending request for this user';
  end if;

  update public.group_user_status
  set is_approved = true, is_member = true, is_requested = false, approved_by = v_uid, joined_at = now()
  where group_id = p_group_id and user_id = p_user_id;

  insert into public.group_members (group_id, user_id, is_requested, is_approved, approved_by, joined_at, requested_date)
  values (p_group_id, p_user_id, true, true, v_uid, now(), now())
  on conflict (group_id, user_id) do update
    set is_approved = true, approved_by = v_uid, joined_at = now();

  update public.group_members_invite
  set is_member = true, accepted_at = now()
  where group_id = p_group_id and invited_user = p_user_id;

  insert into public.audit_log (actor_id, action, target_table, target_id, details)
  values (v_uid, 'approve_join_request', 'group_members', p_group_id, jsonb_build_object('target_user_id', p_user_id));
end;
$$;

comment on function public.approve_join_request(uuid, uuid) is
  'SECURITY DEFINER: admin-only approval of a pending private-group join request. Audited.';

revoke all on function public.approve_join_request(uuid, uuid) from public;
grant execute on function public.approve_join_request(uuid, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- reject_join_request — admin-only. Deletes the pending request (resets to not_member). Audited.
-- ---------------------------------------------------------------------------------------------
create or replace function public.reject_join_request(p_group_id uuid, p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'reject_join_request: no authenticated user';
  end if;

  if not public.is_group_admin(p_group_id, v_uid) then
    raise exception 'reject_join_request: caller is not an admin of this group';
  end if;

  if not exists (
    select 1 from public.group_user_status
    where group_id = p_group_id and user_id = p_user_id and coalesce(is_requested, false)
  ) then
    raise exception 'reject_join_request: no pending request for this user';
  end if;

  delete from public.group_user_status where group_id = p_group_id and user_id = p_user_id;

  insert into public.audit_log (actor_id, action, target_table, target_id, details)
  values (v_uid, 'reject_join_request', 'group_user_status', p_group_id, jsonb_build_object('target_user_id', p_user_id));
end;
$$;

comment on function public.reject_join_request(uuid, uuid) is
  'SECURITY DEFINER: admin-only rejection of a pending private-group join request. Audited.';

revoke all on function public.reject_join_request(uuid, uuid) from public;
grant execute on function public.reject_join_request(uuid, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- invite_users_to_group (InviteFriends) — bulk invite. Caller must be an approved member (any
-- member may invite, per docs/features/05-groups.md §5 — not admin-restricted). Per-target branch
-- matches the feature doc exactly: an already-'requested' user gets converted straight to
-- 'invited' (is_requested cleared); everyone else gets a fresh/refreshed invite. Skips targets who
-- are already members, already invited, self, or blocked (either direction). Not audited (everyday
-- social action, matches invite/follow precedent).
-- ---------------------------------------------------------------------------------------------
create or replace function public.invite_users_to_group(p_group_id uuid, p_user_ids uuid[])
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid    uuid := auth.uid();
  v_target       uuid;
  v_gus          public.group_user_status;
  v_had_status   boolean;
begin
  if v_uid is null then
    raise exception 'invite_users_to_group: no authenticated user';
  end if;

  if not public.is_group_approved_member(p_group_id, v_uid) then
    raise exception 'invite_users_to_group: caller is not a member of this group';
  end if;

  foreach v_target in array p_user_ids loop
    continue when v_target = v_uid;
    continue when public.is_blocked_pair(v_uid, v_target);
    continue when public.is_group_approved_member(p_group_id, v_target);

    select * into v_gus from public.group_user_status where group_id = p_group_id and user_id = v_target;
    -- Capture FOUND immediately — it gets overwritten by every subsequent SQL statement below.
    v_had_status := found;

    if v_had_status and coalesce(v_gus.is_invited, false) then
      continue; -- already has a pending invite
    end if;

    insert into public.group_members_invite (invited_by, group_id, invited_user, is_member)
    values (v_uid, p_group_id, v_target, false)
    on conflict (group_id, invited_user) do update
      set invited_by = v_uid, is_member = false, accepted_at = null;

    if v_had_status and coalesce(v_gus.is_requested, false) then
      update public.group_user_status
      set is_invited = true, invited_by = v_uid, invited_date = now(), is_requested = false
      where group_id = p_group_id and user_id = v_target;
    else
      insert into public.group_user_status (
        group_id, user_id, is_requested, is_invited, is_approved, is_member, invited_by, invited_date
      )
      values (p_group_id, v_target, false, true, false, false, v_uid, now())
      on conflict (group_id, user_id) do update
        set is_invited = true, invited_by = v_uid, invited_date = now(), is_requested = false;
    end if;
  end loop;
end;
$$;

comment on function public.invite_users_to_group(uuid, uuid[]) is
  'SECURITY DEFINER: bulk-invites p_user_ids to p_group_id. Caller must be an approved member. Skips self/blocked/already-member/already-invited targets.';

revoke all on function public.invite_users_to_group(uuid, uuid[]) from public;
grant execute on function public.invite_users_to_group(uuid, uuid[]) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- assign_group_admin — admin-only. Target must already be an approved member. Idempotent
-- (ON CONFLICT DO NOTHING). Audited.
-- ---------------------------------------------------------------------------------------------
create or replace function public.assign_group_admin(p_group_id uuid, p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'assign_group_admin: no authenticated user';
  end if;

  if not public.is_group_admin(p_group_id, v_uid) then
    raise exception 'assign_group_admin: caller is not an admin of this group';
  end if;

  if not public.is_group_approved_member(p_group_id, p_user_id) then
    raise exception 'assign_group_admin: target user is not an approved member of this group';
  end if;

  insert into public.group_admin (group_id, user_id, e_group_role)
  values (p_group_id, p_user_id, 'admin')
  on conflict (group_id, user_id) do nothing;

  insert into public.audit_log (actor_id, action, target_table, target_id, details)
  values (v_uid, 'assign_group_admin', 'group_admin', p_group_id, jsonb_build_object('target_user_id', p_user_id));
end;
$$;

comment on function public.assign_group_admin(uuid, uuid) is
  'SECURITY DEFINER: admin-only. Grants group_admin to an existing approved member. Audited.';

revoke all on function public.assign_group_admin(uuid, uuid) from public;
grant execute on function public.assign_group_admin(uuid, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- delete_group_admin (DeleteAdminCall) — covers BOTH frontend flows: comp_resign_admin (caller
-- resigns own admin role, p_user_id = self) and comp_revoke_admin (an admin removes another
-- admin's role, p_user_id = target). Blocks removing the group's last admin either way. Audited.
-- ---------------------------------------------------------------------------------------------
create or replace function public.delete_group_admin(p_group_id uuid, p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'delete_group_admin: no authenticated user';
  end if;

  if v_uid <> p_user_id and not public.is_group_admin(p_group_id, v_uid) then
    raise exception 'delete_group_admin: caller may only resign their own admin role or, if an admin themself, revoke another''s';
  end if;

  if not public.is_group_admin(p_group_id, p_user_id) then
    raise exception 'delete_group_admin: target user is not an admin of this group';
  end if;

  if public.group_admin_count(p_group_id) <= 1 then
    raise exception 'delete_group_admin: cannot remove the last admin of this group';
  end if;

  delete from public.group_admin where group_id = p_group_id and user_id = p_user_id;

  insert into public.audit_log (actor_id, action, target_table, target_id, details)
  values (v_uid, 'delete_group_admin', 'group_admin', p_group_id, jsonb_build_object('target_user_id', p_user_id));
end;
$$;

comment on function public.delete_group_admin(uuid, uuid) is
  'SECURITY DEFINER: self-resign or admin-revoke of a group_admin row. Blocks removing the last admin. Audited.';

revoke all on function public.delete_group_admin(uuid, uuid) from public;
grant execute on function public.delete_group_admin(uuid, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- block_user / unblock_user — user-level (NOT group-scoped; the `blocks` table has no group_id,
-- per docs/features/05-groups.md §8 open question #9). Front-loads the Moderation batch's
-- recommended signature (docs/database/09-rpc-inventory.md §13) since group screens need it now
-- (comp_report_block insert / comp_unblock_user delete). `blocks` already has owner-scoped
-- INSERT/DELETE/SELECT RLS from 0016_post_rls.sql (self-block prevented) — these RPCs are an
-- ADDITIONAL validated entrypoint (defense-in-depth), they do not replace or narrow that RLS.
-- -- TODO(confirm): when the future Moderation batch lands, reconcile with these functions rather
-- than redefining block_user/unblock_user a second time.
-- ---------------------------------------------------------------------------------------------
create or replace function public.block_user(p_blocked_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'block_user: no authenticated user';
  end if;
  if p_blocked_id is null or p_blocked_id = v_uid then
    raise exception 'block_user: cannot block yourself';
  end if;

  insert into public.blocks (blocker_id, blocked_id)
  values (v_uid, p_blocked_id)
  on conflict (blocker_id, blocked_id) do nothing;
end;
$$;

comment on function public.block_user(uuid) is
  'SECURITY DEFINER: auth.uid() blocks p_blocked_id (user-level, not group-scoped). Self-block guarded.';

revoke all on function public.block_user(uuid) from public;
grant execute on function public.block_user(uuid) to authenticated;

create or replace function public.unblock_user(p_blocked_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'unblock_user: no authenticated user';
  end if;

  delete from public.blocks where blocker_id = v_uid and blocked_id = p_blocked_id;
end;
$$;

comment on function public.unblock_user(uuid) is
  'SECURITY DEFINER: auth.uid() unblocks p_blocked_id (user-level, not group-scoped).';

revoke all on function public.unblock_user(uuid) from public;
grant execute on function public.unblock_user(uuid) to authenticated;

commit;

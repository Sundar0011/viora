-- 0029_group_functions_writes_membership.sql
-- Purpose: Batch 4 (Groups) — group CRUD + the join/request/invite-accept/leave state machine.
-- Per docs/decisions.md (2026-07-19, "User-facing writes") and this task's explicit instruction:
-- ALL privileged group actions go through validated SECURITY DEFINER RPCs, never direct client
-- DML — a user must not be able to self-approve a private-group join, self-assign admin, etc.
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5: validates auth.uid() inside, pins
-- search_path = public, pg_temp, REVOKEs EXECUTE from PUBLIC, GRANTs only to authenticated.
-- Sensitive ones (delete_group) are audited; everyday membership toggles (join/request/leave) are
-- NOT audited, matching the add_like()/user_follow() precedent (normal social actions, not
-- admin/moderation actions).

begin;

-- ---------------------------------------------------------------------------------------------
-- create_group — creator becomes the initial admin + first approved member. Forces
-- created_by = auth.uid(); ignores any client-sent total_members/isdeleted/status.
-- Required args first, then optional (p_community_id last — vestigial compat, per the arg-order
-- fix documented in docs/decisions.md 2026-07-19 Batch 2).
-- ---------------------------------------------------------------------------------------------
create or replace function public.create_group(
  p_name               text,
  p_e_group_type       public.e_group_type,
  p_e_discoverability  text,
  p_location           text,
  p_description        text default null,
  p_profile_picture    text default null,
  p_community_id       int8 default null -- compat arg only, unused
)
returns public."group"
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid   uuid := auth.uid();
  v_group public."group";
begin
  if v_uid is null then
    raise exception 'create_group: no authenticated user';
  end if;
  if p_name is null or btrim(p_name) = '' then
    raise exception 'create_group: name is required';
  end if;

  insert into public."group" (
    created_by, name, description, e_group_type, e_discoverability, location,
    profile_picture, updated_at, total_members, isdeleted, status
  )
  values (
    v_uid, p_name, p_description, p_e_group_type, p_e_discoverability, p_location,
    coalesce(p_profile_picture, 'squadd/default_group_image/default_group_image.png'),
    now(), 1, false, 'active'
  )
  returning * into v_group;

  insert into public.group_admin (group_id, user_id, e_group_role)
  values (v_group.id, v_uid, 'admin');

  insert into public.group_members (group_id, user_id, is_requested, is_approved, approved_by, joined_at, requested_date)
  values (v_group.id, v_uid, false, true, v_uid, now(), now());

  insert into public.group_user_status (
    group_id, user_id, is_requested, is_invited, is_approved, is_member, approved_by, joined_at
  )
  values (v_group.id, v_uid, false, false, true, true, v_uid, now());

  return v_group;
end;
$$;

comment on function public.create_group(text, public.e_group_type, text, text, text, text, int8) is
  'SECURITY DEFINER: creates a group; creator becomes initial admin + approved member. p_community_id unused (compat).';

revoke all on function public.create_group(text, public.e_group_type, text, text, text, text, int8) from public;
grant execute on function public.create_group(text, public.e_group_type, text, text, text, text, int8) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- edit_group — admin-only (creator is always an admin, see create_group). Only provided
-- (non-null) fields are updated. -- TODO(confirm): docs/features/05-groups.md §8 notes the
-- FRONTEND currently resets profile_picture to the default URL on every save unless a new file is
-- picked; that behavior lives client-side (whatever it sends as p_profile_picture), this RPC just
-- applies whatever the caller sends.
-- ---------------------------------------------------------------------------------------------
create or replace function public.edit_group(
  p_group_id          uuid,
  p_name              text default null,
  p_description       text default null,
  p_location          text default null,
  p_profile_picture   text default null
)
returns public."group"
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid   uuid := auth.uid();
  v_group public."group";
begin
  if v_uid is null then
    raise exception 'edit_group: no authenticated user';
  end if;

  if not exists (select 1 from public."group" where id = p_group_id and isdeleted = false) then
    raise exception 'edit_group: group not found';
  end if;

  if not public.is_group_admin(p_group_id, v_uid) then
    raise exception 'edit_group: caller is not an admin of this group';
  end if;

  update public."group" set
    name = coalesce(p_name, name),
    description = coalesce(p_description, description),
    location = coalesce(p_location, location),
    profile_picture = coalesce(p_profile_picture, profile_picture),
    updated_at = now()
  where id = p_group_id
  returning * into v_group;

  return v_group;
end;
$$;

comment on function public.edit_group(uuid, text, text, text, text) is
  'SECURITY DEFINER: admin-only group edit (name/description/location/profile_picture).';

revoke all on function public.edit_group(uuid, text, text, text, text) from public;
grant execute on function public.edit_group(uuid, text, text, text, text) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- delete_group — soft delete only (isdeleted=true, status='removed'). Admin-only. Audited (per
-- this task's explicit instruction: delete_group is one of the sensitive actions to audit).
-- ---------------------------------------------------------------------------------------------
create or replace function public.delete_group(p_group_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'delete_group: no authenticated user';
  end if;

  if not exists (select 1 from public."group" where id = p_group_id and isdeleted = false) then
    raise exception 'delete_group: group not found';
  end if;

  if not public.is_group_admin(p_group_id, v_uid) then
    raise exception 'delete_group: caller is not an admin of this group';
  end if;

  update public."group"
  set isdeleted = true, status = 'removed'
  where id = p_group_id;

  insert into public.audit_log (actor_id, action, target_table, target_id, details)
  values (v_uid, 'delete_group', 'group', p_group_id, jsonb_build_object());
end;
$$;

comment on function public.delete_group(uuid) is
  'SECURITY DEFINER: admin-only soft-delete of a group (isdeleted=true, status=removed). Audited.';

revoke all on function public.delete_group(uuid) from public;
grant execute on function public.delete_group(uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- request_or_join_group — the join/request entrypoint (task-specified single combined RPC,
-- supersedes the earlier design-doc split of join_open_group/request_join_group). Open group ->
-- instant approved membership. Private group -> pending request (group_user_status only, no
-- group_members row yet), per docs/features/05-groups.md §5. Idempotent: repeat calls on an
-- already-member/already-requested group return the current state instead of erroring; a caller
-- with a pending INVITE is told to call accept_invite() instead (different, more specific flow).
-- ---------------------------------------------------------------------------------------------
create or replace function public.request_or_join_group(p_group_id uuid)
returns text
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid         uuid := auth.uid();
  v_group_type  public.e_group_type;
  v_gus         public.group_user_status;
begin
  if v_uid is null then
    raise exception 'request_or_join_group: no authenticated user';
  end if;

  select e_group_type into v_group_type from public."group" where id = p_group_id and isdeleted = false and status = 'active';
  if v_group_type is null then
    raise exception 'request_or_join_group: group not found';
  end if;

  if public.is_group_approved_member(p_group_id, v_uid) then
    return 'member';
  end if;

  select * into v_gus from public.group_user_status where group_id = p_group_id and user_id = v_uid;

  if found and coalesce(v_gus.is_invited, false) then
    raise exception 'request_or_join_group: user already invited to this group; call accept_invite() instead';
  end if;

  if found and coalesce(v_gus.is_requested, false) then
    return 'requested';
  end if;

  if v_group_type = 'open' then
    insert into public.group_members (group_id, user_id, is_requested, is_approved, approved_by, joined_at, requested_date)
    values (p_group_id, v_uid, false, true, v_uid, now(), now())
    on conflict (group_id, user_id) do update
      set is_approved = true, approved_by = v_uid, joined_at = now();

    insert into public.group_user_status (
      group_id, user_id, is_requested, is_invited, is_approved, is_member, approved_by, joined_at
    )
    values (p_group_id, v_uid, false, false, true, true, v_uid, now())
    on conflict (group_id, user_id) do update
      set is_member = true, is_approved = true, is_requested = false, approved_by = v_uid, joined_at = now();

    return 'member';
  else
    insert into public.group_user_status (group_id, user_id, is_requested, is_invited, is_member, requested_date)
    values (p_group_id, v_uid, true, false, false, now())
    on conflict (group_id, user_id) do update
      set is_requested = true, requested_date = now();

    return 'requested';
  end if;
end;
$$;

comment on function public.request_or_join_group(uuid) is
  'SECURITY DEFINER: open group -> instant approved join; private group -> pending request. Idempotent. Returns the resulting user_status.';

revoke all on function public.request_or_join_group(uuid) from public;
grant execute on function public.request_or_join_group(uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- accept_invite — caller accepts their own pending invite. Open group -> instant approved join.
-- Private group -> converts the invite into a pending request (still needs admin approval), per
-- docs/features/05-groups.md §5 ("Private group invite" — TODO(confirm), see §8 open question #7).
-- ---------------------------------------------------------------------------------------------
create or replace function public.accept_invite(p_group_id uuid)
returns text
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid        uuid := auth.uid();
  v_group_type public.e_group_type;
  v_gus        public.group_user_status;
begin
  if v_uid is null then
    raise exception 'accept_invite: no authenticated user';
  end if;

  select e_group_type into v_group_type from public."group" where id = p_group_id and isdeleted = false;
  if v_group_type is null then
    raise exception 'accept_invite: group not found';
  end if;

  select * into v_gus from public.group_user_status where group_id = p_group_id and user_id = v_uid;
  if not found or not coalesce(v_gus.is_invited, false) then
    raise exception 'accept_invite: no pending invite for this group';
  end if;

  if v_group_type = 'open' then
    insert into public.group_members (group_id, user_id, is_requested, is_approved, approved_by, joined_at, requested_date)
    values (p_group_id, v_uid, false, true, v_gus.invited_by, now(), now())
    on conflict (group_id, user_id) do update
      set is_approved = true, approved_by = v_gus.invited_by, joined_at = now();

    update public.group_user_status
    set is_member = true, is_approved = true, approved_by = v_gus.invited_by, joined_at = now()
    where group_id = p_group_id and user_id = v_uid;

    update public.group_members_invite
    set is_member = true, accepted_at = now()
    where group_id = p_group_id and invited_user = v_uid;

    return 'member';
  else
    update public.group_user_status
    set is_requested = true, requested_date = now()
    where group_id = p_group_id and user_id = v_uid;

    return 'requested';
  end if;
end;
$$;

comment on function public.accept_invite(uuid) is
  'SECURITY DEFINER: caller accepts their own pending invite. Open -> instant join. Private -> converts to a pending request. TODO(confirm) two-step design.';

revoke all on function public.accept_invite(uuid) from public;
grant execute on function public.accept_invite(uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- decline_invite — caller declines their own pending invite; resets to "not_member" by deleting
-- the group_user_status row. The historical group_members_invite row is left as-is (is_member
-- stays false) for audit/history.
-- ---------------------------------------------------------------------------------------------
create or replace function public.decline_invite(p_group_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'decline_invite: no authenticated user';
  end if;

  if not exists (
    select 1 from public.group_user_status
    where group_id = p_group_id and user_id = v_uid and coalesce(is_invited, false)
  ) then
    raise exception 'decline_invite: no pending invite for this group';
  end if;

  delete from public.group_user_status where group_id = p_group_id and user_id = v_uid;
end;
$$;

comment on function public.decline_invite(uuid) is
  'SECURITY DEFINER: caller declines their own pending invite; resets group_user_status to not_member.';

revoke all on function public.decline_invite(uuid) from public;
grant execute on function public.decline_invite(uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- leave_group — self only. Deletes group_members/group_admin/group_user_status rows for the
-- caller. SAFETY ADDITION (not explicit in the feature doc, smaller implementation choice per
-- CLAUDE.md §7 — recorded in docs/decisions.md): blocks the caller from leaving if they are the
-- group's ONLY admin, mirroring the delete_group_admin() last-admin guard, so a group can never be
-- left with zero admins. -- TODO(confirm) with product whether this stricter behavior (vs. the
-- frontend's unconditional delete) is desired.
-- ---------------------------------------------------------------------------------------------
create or replace function public.leave_group(p_group_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'leave_group: no authenticated user';
  end if;

  if not public.is_group_approved_member(p_group_id, v_uid) then
    raise exception 'leave_group: not a member of this group';
  end if;

  if public.is_group_admin(p_group_id, v_uid) and public.group_admin_count(p_group_id) <= 1 then
    raise exception 'leave_group: cannot leave — you are the only admin; assign another admin first';
  end if;

  delete from public.group_members where group_id = p_group_id and user_id = v_uid;
  delete from public.group_admin where group_id = p_group_id and user_id = v_uid;
  delete from public.group_user_status where group_id = p_group_id and user_id = v_uid;
end;
$$;

comment on function public.leave_group(uuid) is
  'SECURITY DEFINER: self-only. Removes the caller''s membership/admin/status rows. Blocks leaving as the sole admin (see comment).';

revoke all on function public.leave_group(uuid) from public;
grant execute on function public.leave_group(uuid) to authenticated;

commit;

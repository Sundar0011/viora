-- 0028_group_functions_reads2.sql
-- Purpose: Batch 4 (Groups) — member/invite/admin list read RPCs + check_group_member. Continues
-- 0027, split for the 400-line cap. Covers: get_group_members_with_admin_status,
-- get_available_users_to_invite, get_invited_users_for_group,
-- get_user_following_groups_with_status (DEFERRED from Batch 3 — built here now that "group"
-- exists), check_group_member.
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5. Every list read is two-way
-- block-filtered (is_blocked_pair) and backend-paginated with DEFAULT args (CLAUDE.md/decisions.md
-- "Pagination & filtering" — TODO(frontend) to wire real pagination).
--
-- Parameter ordering: every function below puts REQUIRED args first, then optional/DEFAULTed args
-- last (Postgres requires this) — the vestigial `p_community_id` compat arg is always placed
-- immediately before the pagination defaults, matching the Batch 2/3 fix for the two arg-order
-- bugs noted in docs/decisions.md (2026-07-19, Batch 2).

begin;

-- ---------------------------------------------------------------------------------------------
-- get_group_members_with_admin_status (GroupMembersCall) — approved members of a group + admin
-- flag. Visibility (RECOMMENDED, see docs/rls-policies-draft.md "Batch 4"): open groups ->
-- any authenticated user; private groups -> caller must be an approved member or admin.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_group_members_with_admin_status(
  p_group_id          uuid,
  p_search_text       text default null,
  p_limit             int4 default 50,
  p_after_created_at  timestamptz default null,
  p_after_id          uuid default null
)
returns table (
  user_id           uuid,
  name              text,
  profile_picture   text,
  city              text,
  is_admin          boolean,
  joined_at         timestamptz
)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid          uuid := auth.uid();
  v_group_type   public.e_group_type;
begin
  if v_uid is null then
    raise exception 'get_group_members_with_admin_status: no authenticated user';
  end if;

  select e_group_type into v_group_type from public."group" where id = p_group_id and isdeleted = false;
  if v_group_type is null then
    raise exception 'get_group_members_with_admin_status: group not found';
  end if;

  if v_group_type = 'private'
     and not public.is_group_approved_member(p_group_id, v_uid)
     and not public.is_group_admin(p_group_id, v_uid) then
    raise exception 'get_group_members_with_admin_status: not authorized to view members of this private group';
  end if;

  return query
  select
    gm.user_id, prof.name, prof.profile_picture, prof.city,
    (public.is_group_admin(p_group_id, gm.user_id)) as is_admin,
    gm.joined_at
  from public.group_members gm
  join public.public_user_profile prof on prof.id = gm.user_id
  where gm.group_id = p_group_id
    and coalesce(gm.is_approved, false)
    and not public.is_blocked_pair(v_uid, gm.user_id)
    and (p_search_text is null or p_search_text = '' or prof.name ilike '%' || p_search_text || '%')
    and (
      p_after_created_at is null
      or (gm.created_at, gm.id) < (p_after_created_at, p_after_id)
    )
  order by gm.created_at desc, gm.id desc
  limit least(greatest(p_limit, 1), 200);
end;
$$;

comment on function public.get_group_members_with_admin_status(uuid, text, int4, timestamptz, uuid) is
  'Approved members of p_group_id + admin flag. Open groups: any authenticated. Private groups: members/admins only.';

revoke all on function public.get_group_members_with_admin_status(uuid, text, int4, timestamptz, uuid) from public;
grant execute on function public.get_group_members_with_admin_status(uuid, text, int4, timestamptz, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- get_available_users_to_invite (InviteFriendsCall) — users who have NO existing
-- group_user_status row (never requested/invited/joined) for p_group_id. Caller must be an
-- approved member (any member may invite, per docs/features/05-groups.md §5). p_community_id kept
-- as a compat arg only (unused).
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_available_users_to_invite(
  p_group_id          uuid,
  p_search_text       text default null,
  p_community_id      int8 default null, -- compat arg only, unused
  p_limit             int4 default 50,
  p_after_created_at  timestamptz default null,
  p_after_id          uuid default null
)
returns table (
  user_id           uuid,
  name              text,
  profile_picture   text,
  city              text,
  user_status       text
)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'get_available_users_to_invite: no authenticated user';
  end if;

  if not public.is_group_approved_member(p_group_id, v_uid) then
    raise exception 'get_available_users_to_invite: caller is not a member of this group';
  end if;

  return query
  select prof.id, prof.name, prof.profile_picture, prof.city, 'not_member'::text as user_status
  from public.public_user_profile prof
  join public."user" u on u.id = prof.id and coalesce(u.is_deleted, false) = false
  where prof.id <> v_uid
    and not public.is_blocked_pair(v_uid, prof.id)
    and not exists (
      select 1 from public.group_user_status gus
      where gus.group_id = p_group_id and gus.user_id = prof.id
        and (coalesce(gus.is_member, false) or coalesce(gus.is_invited, false) or coalesce(gus.is_requested, false))
    )
    and (p_search_text is null or p_search_text = '' or prof.name ilike '%' || p_search_text || '%')
    and (
      p_after_created_at is null
      or (prof.created_at, prof.id) < (p_after_created_at, p_after_id)
    )
  order by prof.created_at desc, prof.id desc
  limit least(greatest(p_limit, 1), 200);
end;
$$;

comment on function public.get_available_users_to_invite(uuid, text, int8, int4, timestamptz, uuid) is
  'Users with no existing group_user_status row for p_group_id (invitable). Caller must be an approved member. p_community_id unused (compat).';

revoke all on function public.get_available_users_to_invite(uuid, text, int8, int4, timestamptz, uuid) from public;
grant execute on function public.get_available_users_to_invite(uuid, text, int8, int4, timestamptz, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- get_invited_users_for_group (GetInvitedUsersForGroupCall) — admin-only: users with a pending or
-- historical invite for p_group_id. p_community_id kept as a compat arg only (unused).
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_invited_users_for_group(
  p_group_id          uuid,
  p_search_text       text default null,
  p_community_id      int8 default null, -- compat arg only, unused
  p_limit             int4 default 50,
  p_after_created_at  timestamptz default null,
  p_after_id          uuid default null
)
returns table (
  user_id          uuid,
  name             text,
  profile_picture  text,
  city             text,
  invited_by       uuid,
  is_member        boolean,
  created_at       timestamptz
)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'get_invited_users_for_group: no authenticated user';
  end if;

  if not public.is_group_admin(p_group_id, v_uid) then
    raise exception 'get_invited_users_for_group: caller is not an admin of this group';
  end if;

  return query
  select
    inv.invited_user, prof.name, prof.profile_picture, prof.city, inv.invited_by, inv.is_member, inv.created_at
  from public.group_members_invite inv
  join public.public_user_profile prof on prof.id = inv.invited_user
  where inv.group_id = p_group_id
    and not public.is_blocked_pair(v_uid, inv.invited_user)
    and (p_search_text is null or p_search_text = '' or prof.name ilike '%' || p_search_text || '%')
    and (
      p_after_created_at is null
      or (inv.created_at, inv.id) < (p_after_created_at, p_after_id)
    )
  order by inv.created_at desc, inv.id desc
  limit least(greatest(p_limit, 1), 200);
end;
$$;

comment on function public.get_invited_users_for_group(uuid, text, int8, int4, timestamptz, uuid) is
  'Admin-only: users with a pending/historical invite for p_group_id. p_community_id unused (compat).';

revoke all on function public.get_invited_users_for_group(uuid, text, int8, int4, timestamptz, uuid) from public;
grant execute on function public.get_invited_users_for_group(uuid, text, int8, int4, timestamptz, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- get_user_following_groups_with_status (GetOtherUserFollowingGroupsrCall) — DEFERRED from Batch 3
-- (0019_follows_functions_reads.sql explicitly skipped this pending "group"). Groups where
-- target_user_id is an approved member, plus the CALLER's own derived user_status per group (so
-- the viewing screen can offer Join/Request even while browsing someone else's group list).
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_user_following_groups_with_status(
  target_user_id      uuid,
  p_limit             int4 default 50,
  p_after_created_at  timestamptz default null,
  p_after_id          uuid default null
)
returns table (
  group_id           uuid,
  name               text,
  description        text,
  profile_picture    text,
  e_group_type       public.e_group_type,
  total_members      int8,
  caller_user_status text
)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'get_user_following_groups_with_status: no authenticated user';
  end if;

  if public.is_blocked_pair(v_uid, target_user_id) then
    return; -- empty set, two-way block
  end if;

  return query
  select
    g.id, g.name, g.description, g.profile_picture, g.e_group_type, g.total_members,
    case
      when coalesce(gus.is_member, false) then 'member'
      when coalesce(gus.is_invited, false) then 'invite'
      when coalesce(gus.is_requested, false) then 'requested'
      when g.e_group_type = 'open' then 'join'
      else 'request'
    end as caller_user_status
  from public.group_members gm
  join public."group" g on g.id = gm.group_id and g.isdeleted = false and g.status = 'active'
  left join public.group_user_status gus on gus.group_id = g.id and gus.user_id = v_uid
  where gm.user_id = target_user_id
    and coalesce(gm.is_approved, false)
    and (
      p_after_created_at is null
      or (g.created_at, g.id) < (p_after_created_at, p_after_id)
    )
  order by g.created_at desc, g.id desc
  limit least(greatest(p_limit, 1), 100);
end;
$$;

comment on function public.get_user_following_groups_with_status(uuid, int4, timestamptz, uuid) is
  'Groups target_user_id is an approved member of, plus caller''s own derived user_status per group. Block-filtered.';

revoke all on function public.get_user_following_groups_with_status(uuid, int4, timestamptz, uuid) from public;
grant execute on function public.get_user_following_groups_with_status(uuid, int4, timestamptz, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- check_group_member (CheckGroupMemberShareCall) — is auth.uid() an approved member of the group
-- that p_postid belongs to (share-into-group flow). p_userid accepted for frontend compat but
-- IGNORED/forced to auth.uid() (never trust caller-supplied user id), per the Batch 3 precedent.
-- ---------------------------------------------------------------------------------------------
create or replace function public.check_group_member(
  p_postid  uuid,
  p_userid  uuid default null -- IGNORED; forced to auth.uid() below
)
returns boolean
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid      uuid := auth.uid();
  v_group_id uuid;
begin
  if v_uid is null then
    raise exception 'check_group_member: no authenticated user';
  end if;

  select group_id into v_group_id from public.post where id = p_postid;
  if v_group_id is null then
    return false;
  end if;

  return public.is_group_approved_member(v_group_id, v_uid);
end;
$$;

comment on function public.check_group_member(uuid, uuid) is
  'True if auth.uid() is an approved member of the group that p_postid belongs to. p_userid ignored (forced to auth.uid()).';

revoke all on function public.check_group_member(uuid, uuid) from public;
grant execute on function public.check_group_member(uuid, uuid) to authenticated;

commit;

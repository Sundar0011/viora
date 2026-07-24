-- 0027_group_functions_reads1.sql
-- Purpose: Batch 4 (Groups) — group list + group detail read RPCs. Split from a single
-- "0027_group_functions_reads.sql" to respect CLAUDE.md §5's 400-line cap (same precedent as
-- Batch 2/3's read-file splits — see backend-dev playbook).
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5: validates auth.uid() inside, pins
-- search_path = public, pg_temp, REVOKEs EXECUTE from PUBLIC, GRANTs only to authenticated.
-- Every list read is two-way block-filtered (is_blocked_pair, 0009) and backend-paginated per
-- docs/decisions.md (2026-07-19, "Pagination & filtering") — DEFAULT args so the locked frontend's
-- existing no-pagination calls keep working (-- TODO(frontend) to wire real pagination).

begin;

-- ---------------------------------------------------------------------------------------------
-- get_groups_with_user_status (GetGroupsWithUserStatusCall) — all discoverable (non-deleted,
-- active) groups + the caller's derived user_status. Feeds all_groups / nearest_groups / groups
-- landing screens (same RPC — no separate "nearby" filter exists server-side today, see `nearest`
-- note below).
--
-- user_status derivation (reconstructed from docs/features/05-groups.md §5's observed button
-- states, no group_user_status row = fresh state):
--   is_member          -> 'member'
--   is_invited         -> 'invite'
--   is_requested       -> 'requested'
--   no row, open group -> 'join'
--   no row, private    -> 'request'
--
-- `nearest`: the `"group"` table has NO geography column (`location` is a free-text radio value,
-- not lat/lon) — there is no data to compute real distance from. Returned as a constant `false`.
-- -- TODO(confirm): what "nearest" is actually meant to represent for nearest_groups, and whether
-- group needs a geography column added in a follow-up migration once product clarifies.
--
-- Block filter: applied against the group's creator (closest analogue to a "people" filter for a
-- group list, per this task's instruction to block-filter every group people/member/invite list).
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_groups_with_user_status(
  p_search_text       text default null,
  p_limit             int4 default 50,
  p_after_created_at  timestamptz default null,
  p_after_id          uuid default null
)
returns table (
  group_id            uuid,
  name                text,
  description         text,
  profile_picture     text,
  e_group_type        public.e_group_type,
  e_discoverability   text,
  location            text,
  total_members       int8,
  created_by          uuid,
  created_at          timestamptz,
  user_status         text,
  invited_by_user_id  uuid,
  nearest             boolean
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
    raise exception 'get_groups_with_user_status: no authenticated user';
  end if;

  return query
  select
    g.id, g.name, g.description, g.profile_picture, g.e_group_type, g.e_discoverability,
    g.location, g.total_members, g.created_by, g.created_at,
    case
      when coalesce(gus.is_member, false) then 'member'
      when coalesce(gus.is_invited, false) then 'invite'
      when coalesce(gus.is_requested, false) then 'requested'
      when g.e_group_type = 'open' then 'join'
      else 'request'
    end as user_status,
    gus.invited_by as invited_by_user_id,
    false as nearest -- TODO(confirm), see header
  from public."group" g
  left join public.group_user_status gus on gus.group_id = g.id and gus.user_id = v_uid
  where g.isdeleted = false
    and g.status = 'active'
    and not public.is_blocked_pair(v_uid, g.created_by)
    and (p_search_text is null or p_search_text = '' or g.name ilike '%' || p_search_text || '%')
    and (
      p_after_created_at is null
      or (g.created_at, g.id) < (p_after_created_at, p_after_id)
    )
  order by g.created_at desc, g.id desc
  limit least(greatest(p_limit, 1), 100);
end;
$$;

comment on function public.get_groups_with_user_status(text, int4, timestamptz, uuid) is
  'All discoverable groups + caller''s derived user_status (join/request/requested/invite/member). Block-filtered on creator, paginated.';

revoke all on function public.get_groups_with_user_status(text, int4, timestamptz, uuid) from public;
grant execute on function public.get_groups_with_user_status(text, int4, timestamptz, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- get_specific_group_with_user_status (SpecificGroupCall) — single group + caller's status, plus
-- caller's admin flag and (admin-only) pending-request count for the group_details/about_group
-- management surface.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_specific_group_with_user_status(p_group_id uuid)
returns table (
  group_id                 uuid,
  name                     text,
  description              text,
  profile_picture          text,
  e_group_type             public.e_group_type,
  e_discoverability        text,
  location                 text,
  total_members            int8,
  created_by               uuid,
  created_at               timestamptz,
  user_status              text,
  invited_by_user_id       uuid,
  nearest                  boolean,
  is_caller_admin          boolean,
  pending_requests_count   int4
)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid      uuid := auth.uid();
  v_is_admin boolean;
begin
  if v_uid is null then
    raise exception 'get_specific_group_with_user_status: no authenticated user';
  end if;

  v_is_admin := public.is_group_admin(p_group_id, v_uid);

  return query
  select
    g.id, g.name, g.description, g.profile_picture, g.e_group_type, g.e_discoverability,
    g.location, g.total_members, g.created_by, g.created_at,
    case
      when coalesce(gus.is_member, false) then 'member'
      when coalesce(gus.is_invited, false) then 'invite'
      when coalesce(gus.is_requested, false) then 'requested'
      when g.e_group_type = 'open' then 'join'
      else 'request'
    end as user_status,
    gus.invited_by as invited_by_user_id,
    false as nearest, -- TODO(confirm), see 0027 header
    v_is_admin as is_caller_admin,
    case when v_is_admin then (
      select count(*)::int4 from public.group_user_status s
      where s.group_id = p_group_id and coalesce(s.is_requested, false) and not coalesce(s.is_approved, false)
    ) else 0 end as pending_requests_count
  from public."group" g
  left join public.group_user_status gus on gus.group_id = g.id and gus.user_id = v_uid
  where g.id = p_group_id
    and g.isdeleted = false
    and not public.is_blocked_pair(v_uid, g.created_by);
end;
$$;

comment on function public.get_specific_group_with_user_status(uuid) is
  'Single group + caller status, admin flag, and (admin-only) pending-request count.';

revoke all on function public.get_specific_group_with_user_status(uuid) from public;
grant execute on function public.get_specific_group_with_user_status(uuid) to authenticated;

commit;

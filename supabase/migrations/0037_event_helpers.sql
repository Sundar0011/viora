-- 0037_event_helpers.sql
-- Purpose: Batch 5 (Events) internal helper predicates, used by every write/read RPC in this
-- batch. Mirrors the is_group_admin()/is_group_approved_member() pattern from
-- 0026_group_helpers.sql: explicit-2-arg internal helpers are revoked from ALL client roles
-- (called only by other SECURITY DEFINER functions, as owner); self-scoped `_self` wrappers (used
-- by RLS policies) are added later in 0047_event_marketplace_rls.sql.
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5: pins search_path = public, pg_temp.

begin;

-- ---------------------------------------------------------------------------------------------
-- is_event_owner — true if p_user_id is the admin_user (creator) of p_event_id.
-- ---------------------------------------------------------------------------------------------
create or replace function public.is_event_owner(p_event_id uuid, p_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1 from public.event_page ep
    where ep.id = p_event_id and ep.admin_user = p_user_id
  );
$$;

comment on function public.is_event_owner(uuid, uuid) is
  'True if p_user_id is the admin_user (creator) of p_event_id. Internal helper — called only by other SECURITY DEFINER event functions.';

revoke all on function public.is_event_owner(uuid, uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------------------------------
-- can_view_event_attending_row — true if p_viewer_id may see a given event_attending row: the
-- attendee themself, the inviter, or the event's owner. Matches docs/database/04-tables-events-
-- marketplace.md's event_attending RLS intent.
-- ---------------------------------------------------------------------------------------------
create or replace function public.can_view_event_attending_row(p_row_id uuid, p_viewer_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1 from public.event_attending ea
    where ea.id = p_row_id
      and (
        ea.attending_id = p_viewer_id
        or ea.invited_by = p_viewer_id
        or public.is_event_owner(ea.event_id, p_viewer_id)
      )
  );
$$;

comment on function public.can_view_event_attending_row(uuid, uuid) is
  'True if p_viewer_id is the attendee, the inviter, or the event owner for event_attending row p_row_id. Internal helper.';

revoke all on function public.can_view_event_attending_row(uuid, uuid) from public, anon, authenticated;

commit;

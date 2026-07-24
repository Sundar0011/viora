-- 0040_event_functions_reads.sql
-- Purpose: Batch 5 (Events) — read RPCs for all_events/latest/ending/my_events/event_details.
-- These are ALL NEW RPCs: docs/features/06-events.md §4 shows the frontend currently performing
-- these as DIRECT client SELECT queries (EventPageTable().queryRows/querySingleRow), not RPC
-- calls — no name is reserved in docs/database/09-rpc-inventory.md for any of them. Per
-- docs/decisions.md (2026-07-19, "Pagination & filtering" decision #11 — "approved scope
-- expansion: the over-fetching frontend screens WILL be updated to call the paginated/backend-
-- filtered RPCs"), these are built as backend-paginated RPCs. -- TODO(frontend): wire the
-- latest_event/ending_event/all_events/my_event/event_details screens to call these instead of
-- raw table queries.
--
-- "Upcoming" lifecycle filter (docs/features/06-events.md §5 "Event lifecycle / list
-- computation"): is_deleted = false AND end_date_time > now(). Applied to every list below.
--
-- Ordering is kept LITERALLY as documented (created_at ASCENDING for latest/all, oldest-first) —
-- this looks backwards for a screen named "Latest", but it is what the reviewed frontend query
-- does; CLAUDE.md §2 says match the frontend, don't "fix" it silently.
-- -- TODO(confirm): is `created_at asc` really intended for "Latest events", or is this a
-- frontend bug that should be `desc` once confirmed with product?
--
-- get_my_created_events DELIBERATELY filters by admin_user = caller (unlike the literal frontend
-- query, which docs/features/06-events.md §8.4 flags as missing this filter and returning ALL
-- upcoming events). Scoping "my created events" to the caller is the only sane/secure reading of
-- a screen literally named "My events" — recorded as a smaller implementation decision (CLAUDE.md
-- §7), not a silent guess. -- TODO(confirm) with product whether the unscoped frontend behavior
-- was intentional.
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5: validates auth.uid() inside, pins
-- search_path = public, pg_temp, REVOKEs EXECUTE from PUBLIC, GRANTs only to authenticated.

begin;

-- ---------------------------------------------------------------------------------------------
-- get_all_events — all upcoming events, created_at ascending, keyset-paginated.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_all_events(
  p_limit             int4 default 20,
  p_after_created_at  timestamptz default null,
  p_after_id          uuid default null
)
returns setof public.event_page
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'get_all_events: no authenticated user';
  end if;

  return query
  select ep.*
  from public.event_page ep
  where ep.is_deleted = false
    and ep.end_date_time > now()
    and (
      p_after_created_at is null
      or (ep.created_at, ep.id) > (p_after_created_at, p_after_id)
    )
  order by ep.created_at asc, ep.id asc
  limit least(greatest(p_limit, 1), 100);
end;
$$;

comment on function public.get_all_events(int4, timestamptz, uuid) is
  'All upcoming events (is_deleted=false, end_date_time>now), created_at ascending, keyset-paginated. TODO(confirm) ascending vs descending.';

revoke all on function public.get_all_events(int4, timestamptz, uuid) from public;
grant execute on function public.get_all_events(int4, timestamptz, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- get_latest_events — same filter/order as get_all_events (docs/features/06-events.md §5: "Latest
-- and All ... ordered by created_at ascending"; the only documented difference is a community_id
-- filter on "latest", which is vestigial/no-op per docs/decisions.md). Kept as a distinct RPC name
-- since the "latest_event" and "all_events" screens are separate frontend screens.
-- p_communityid kept as a compat arg only (unused).
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_latest_events(
  p_communityid       int8 default null, -- compat arg only, unused
  p_limit             int4 default 20,
  p_after_created_at  timestamptz default null,
  p_after_id          uuid default null
)
returns setof public.event_page
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'get_latest_events: no authenticated user';
  end if;

  return query
  select ep.*
  from public.event_page ep
  where ep.is_deleted = false
    and ep.end_date_time > now()
    and (
      p_after_created_at is null
      or (ep.created_at, ep.id) > (p_after_created_at, p_after_id)
    )
  order by ep.created_at asc, ep.id asc
  limit least(greatest(p_limit, 1), 100);
end;
$$;

comment on function public.get_latest_events(int8, int4, timestamptz, uuid) is
  'Upcoming events, created_at ascending, keyset-paginated. p_communityid unused (compat). TODO(confirm) ascending vs descending.';

revoke all on function public.get_latest_events(int8, int4, timestamptz, uuid) from public;
grant execute on function public.get_latest_events(int8, int4, timestamptz, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- get_ending_events — upcoming events ordered by end_date_time ascending (soonest end first).
-- No community_id filter, matching docs/features/06-events.md §5 ("Ending-soon list has no
-- community_id filter while latest does").
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_ending_events(
  p_limit                 int4 default 20,
  p_after_end_date_time   timestamptz default null,
  p_after_id              uuid default null
)
returns setof public.event_page
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'get_ending_events: no authenticated user';
  end if;

  return query
  select ep.*
  from public.event_page ep
  where ep.is_deleted = false
    and ep.end_date_time > now()
    and (
      p_after_end_date_time is null
      or (ep.end_date_time, ep.id) > (p_after_end_date_time, p_after_id)
    )
  order by ep.end_date_time asc, ep.id asc
  limit least(greatest(p_limit, 1), 100);
end;
$$;

comment on function public.get_ending_events(int4, timestamptz, uuid) is
  'Upcoming events ordered by end_date_time ascending (soonest end first), keyset-paginated.';

revoke all on function public.get_ending_events(int4, timestamptz, uuid) from public;
grant execute on function public.get_ending_events(int4, timestamptz, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- get_my_created_events — events the CALLER created (admin_user = auth.uid()), upcoming only,
-- created_at ascending. See file header for the admin_user-filter deviation from the literal
-- (unfiltered) frontend query.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_my_created_events(
  p_limit             int4 default 20,
  p_after_created_at  timestamptz default null,
  p_after_id          uuid default null
)
returns setof public.event_page
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'get_my_created_events: no authenticated user';
  end if;

  return query
  select ep.*
  from public.event_page ep
  where ep.admin_user = v_uid
    and ep.is_deleted = false
    and ep.end_date_time > now()
    and (
      p_after_created_at is null
      or (ep.created_at, ep.id) > (p_after_created_at, p_after_id)
    )
  order by ep.created_at asc, ep.id asc
  limit least(greatest(p_limit, 1), 100);
end;
$$;

comment on function public.get_my_created_events(int4, timestamptz, uuid) is
  'Upcoming events created by the caller, created_at ascending, keyset-paginated. TODO(confirm) vs unfiltered frontend query, see file header.';

revoke all on function public.get_my_created_events(int4, timestamptz, uuid) from public;
grant execute on function public.get_my_created_events(int4, timestamptz, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- get_my_invited_events — events the caller was INVITED to and hasn't yet responded/attended
-- (attending_id=caller, is_invited=true, is_attending=false, end_date_time>now,
-- is_group_deleted=false), ordered by end_date_time ascending. Flattened event fields for the
-- "my_event" invited-tab list. Block-filtered against the inviter (task's block-filter scope:
-- "event attendees/inviters").
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_my_invited_events(
  p_limit                 int4 default 20,
  p_after_end_date_time   timestamptz default null,
  p_after_id              uuid default null
)
returns table (
  event_attending_id  uuid,
  event_id            uuid,
  name                text,
  cover_image         text,
  start_date_time     timestamptz,
  end_date_time       timestamptz,
  "Address"           text,
  invited_by          uuid
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
    raise exception 'get_my_invited_events: no authenticated user';
  end if;

  return query
  select ea.id, ep.id, ep.name, ep.cover_image, ep.start_date_time, ep.end_date_time, ep."Address", ea.invited_by
  from public.event_attending ea
  join public.event_page ep on ep.id = ea.event_id
  where ea.attending_id = v_uid
    and ea.is_invited = true
    and coalesce(ea.is_attending, false) = false
    and coalesce(ea.is_group_deleted, false) = false
    and ea.end_date_time > now()
    and ep.is_deleted = false
    and (ea.invited_by is null or not public.is_blocked_pair(v_uid, ea.invited_by))
    and (
      p_after_end_date_time is null
      or (ea.end_date_time, ea.id) > (p_after_end_date_time, p_after_id)
    )
  order by ea.end_date_time asc, ea.id asc
  limit least(greatest(p_limit, 1), 100);
end;
$$;

comment on function public.get_my_invited_events(int4, timestamptz, uuid) is
  'Events the caller was invited to, not yet attending, upcoming; block-filtered against the inviter, keyset-paginated.';

revoke all on function public.get_my_invited_events(int4, timestamptz, uuid) from public;
grant execute on function public.get_my_invited_events(int4, timestamptz, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- get_event_attendees — attendees of an event (is_attending=true), block-filtered, paginated. Used
-- by the "view attendees" list and to filter invite candidates.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_event_attendees(
  p_event_id          uuid,
  p_limit             int4 default 50,
  p_after_created_at  timestamptz default null,
  p_after_id          uuid default null
)
returns table (user_id uuid, name text, profile_picture text, city text, created_at timestamptz)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'get_event_attendees: no authenticated user';
  end if;

  return query
  select prof.id, prof.name, prof.profile_picture, prof.city, ea.created_at
  from public.event_attending ea
  join public.public_user_profile prof on prof.id = ea.attending_id
  where ea.event_id = p_event_id
    and ea.is_attending = true
    and coalesce(ea.is_group_deleted, false) = false
    and not public.is_blocked_pair(v_uid, ea.attending_id)
    and (
      p_after_created_at is null
      or (ea.created_at, ea.id) > (p_after_created_at, p_after_id)
    )
  order by ea.created_at asc, ea.id asc
  limit least(greatest(p_limit, 1), 200);
end;
$$;

comment on function public.get_event_attendees(uuid, int4, timestamptz, uuid) is
  'Attendees (is_attending=true) of p_event_id, block-filtered, keyset-paginated.';

revoke all on function public.get_event_attendees(uuid, int4, timestamptz, uuid) from public;
grant execute on function public.get_event_attendees(uuid, int4, timestamptz, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- get_event_details — single event detail JSON: the event row, the caller's own RSVP state, and
-- the "more events" footer list (upcoming, excludes this event, created_at order, limit 4 — per
-- docs/features/06-events.md §5). Visible regardless of block state (events aren't user-scoped
-- content the way posts are) — TODO(confirm) whether a blocked owner's event should be hidden.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_event_details(p_event_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid    uuid := auth.uid();
  v_result jsonb;
begin
  if v_uid is null then
    raise exception 'get_event_details: no authenticated user';
  end if;

  select jsonb_build_object(
    'event', to_jsonb(ep),
    'is_attending', coalesce((
      select ea.is_attending from public.event_attending ea
      where ea.event_id = ep.id and ea.attending_id = v_uid
    ), false),
    'more_events', (
      select coalesce(jsonb_agg(to_jsonb(m) order by m.created_at asc), '[]'::jsonb)
      from (
        select * from public.event_page
        where is_deleted = false and end_date_time > now() and id <> ep.id
        order by created_at asc
        limit 4
      ) m
    )
  )
  into v_result
  from public.event_page ep
  where ep.id = p_event_id and ep.is_deleted = false;

  return v_result;
end;
$$;

comment on function public.get_event_details(uuid) is
  'Single event detail JSON: event row + caller''s RSVP state + more_events (limit 4).';

revoke all on function public.get_event_details(uuid) from public;
grant execute on function public.get_event_details(uuid) to authenticated;

commit;

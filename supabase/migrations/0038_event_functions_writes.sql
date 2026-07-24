-- 0038_event_functions_writes.sql
-- Purpose: Batch 5 (Events) write RPCs. Per docs/decisions.md (2026-07-19, "User-facing writes")
-- and docs/features/06-events.md §8.8: the frontend currently performs direct client DML on
-- event_page/event_attending — moved behind validated SECURITY DEFINER RPCs here (all writes
-- RPC-only, no client INSERT/UPDATE/DELETE policy on either table — matches the post/follows/
-- group precedent). update_event_location/invite_user_to_event keep their EXACT frontend-observed
-- names + argument names (docs/database/09-rpc-inventory.md §6, cross-checked against the literal
-- JSON bodies in lib/backend/api_requests/api_calls.dart UpdateEventLocationCall/
-- InviteUserToEventCall). create_event/edit_event/delete_event/rsvp_event are NEW RPCs (§7 of the
-- feature doc's "Recommended new RPCs") — TODO(frontend) to wire create_event/edit_event/
-- rsvp_event/delete_event into the create/edit/RSVP/delete screens in place of direct DML.
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5: validates auth.uid() inside, pins
-- search_path = public, pg_temp, REVOKEs EXECUTE from PUBLIC, GRANTs only to authenticated.
-- Only delete_event is audited (destructive/moderation-adjacent action), matching the
-- delete_group()/delete_post() precedent — everyday actions (create/edit/RSVP/invite) are not.

begin;

-- ---------------------------------------------------------------------------------------------
-- create_event — creator becomes admin_user and auto-attends (is_attending=true) in the same
-- transaction. end_date_time defaults to start_date_time when not chosen (docs/features/
-- 06-events.md §5 "Create event" step 3). location is built from p_latitude/p_longitude when both
-- are provided (cover_image is inserted '' and set later via edit_event/update cover, after the
-- client uploads to the `event` storage bucket using the returned id as the folder name).
-- Required args first, defaulted args last (the arg-order bug fix from Batch 2, re-applied here).
-- ---------------------------------------------------------------------------------------------
create or replace function public.create_event(
  p_name             text,
  p_event_type       public.event_type,
  p_description      text,
  p_start_date_time  timestamptz,
  p_end_date_time    timestamptz default null,
  p_video_call_link  text default null,
  p_address          text default null,
  p_latitude         float8 default null,
  p_longitude        float8 default null,
  p_communityid      int8 default null -- compat arg only, unused
)
returns public.event_page
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid   uuid := auth.uid();
  v_event public.event_page;
begin
  if v_uid is null then
    raise exception 'create_event: no authenticated user';
  end if;
  if p_name is null or btrim(p_name) = '' then
    raise exception 'create_event: name is required';
  end if;

  insert into public.event_page (
    admin_user, name, event_type, cover_image, video_call_link,
    start_date_time, end_date_time, description, is_deleted, attendee_count,
    "Address", latitude, logitude, event_status,
    location
  )
  values (
    v_uid, p_name, p_event_type, '', p_video_call_link,
    p_start_date_time, coalesce(p_end_date_time, p_start_date_time), p_description, false, 0,
    p_address, p_latitude, p_longitude, 'active',
    case when p_latitude is not null and p_longitude is not null
      then extensions.ST_SetSRID(extensions.ST_MakePoint(p_longitude, p_latitude), 4326)::extensions.geography
      else null
    end
  )
  returning * into v_event;

  -- Creator auto-attends. Does NOT rely on the caller to also invoke update_event_attendee_count
  -- (see docs/features/06-events.md §8.2) — the trigger in 0041_event_triggers.sql keeps
  -- attendee_count authoritative on every event_attending change.
  insert into public.event_attending (event_id, attending_id, is_invited, is_attending, end_date_time)
  values (v_event.id, v_uid, false, true, v_event.end_date_time);

  select * into v_event from public.event_page where id = v_event.id;
  return v_event;
end;
$$;

comment on function public.create_event(text, public.event_type, text, timestamptz, timestamptz, text, text, float8, float8, int8) is
  'SECURITY DEFINER: creates an event; creator becomes admin_user and auto-attends. p_communityid unused (compat).';

revoke all on function public.create_event(text, public.event_type, text, timestamptz, timestamptz, text, text, float8, float8, int8) from public;
grant execute on function public.create_event(text, public.event_type, text, timestamptz, timestamptz, text, text, float8, float8, int8) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- edit_event — owner-only. Only provided (non-null) fields are updated. Re-derives `location`
-- from p_latitude/p_longitude when BOTH are provided (matches create_event's geo-build logic);
-- otherwise leaves the existing location untouched.
-- ---------------------------------------------------------------------------------------------
create or replace function public.edit_event(
  p_event_id         uuid,
  p_name             text default null,
  p_event_type       public.event_type default null,
  p_description      text default null,
  p_start_date_time  timestamptz default null,
  p_end_date_time    timestamptz default null,
  p_video_call_link  text default null,
  p_address          text default null,
  p_latitude         float8 default null,
  p_longitude        float8 default null,
  p_cover_image      text default null
)
returns public.event_page
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid   uuid := auth.uid();
  v_event public.event_page;
begin
  if v_uid is null then
    raise exception 'edit_event: no authenticated user';
  end if;

  if not exists (select 1 from public.event_page where id = p_event_id and is_deleted = false) then
    raise exception 'edit_event: event not found';
  end if;

  if not public.is_event_owner(p_event_id, v_uid) then
    raise exception 'edit_event: caller is not the event owner';
  end if;

  update public.event_page set
    name             = coalesce(p_name, name),
    event_type       = coalesce(p_event_type, event_type),
    description      = coalesce(p_description, description),
    start_date_time  = coalesce(p_start_date_time, start_date_time),
    end_date_time    = coalesce(p_end_date_time, end_date_time),
    video_call_link  = coalesce(p_video_call_link, video_call_link),
    "Address"        = coalesce(p_address, "Address"),
    latitude         = coalesce(p_latitude, latitude),
    logitude         = coalesce(p_longitude, logitude),
    cover_image      = coalesce(p_cover_image, cover_image),
    location         = case when p_latitude is not null and p_longitude is not null
                          then extensions.ST_SetSRID(extensions.ST_MakePoint(p_longitude, p_latitude), 4326)::extensions.geography
                          else location
                        end
  where id = p_event_id
  returning * into v_event;

  return v_event;
end;
$$;

comment on function public.edit_event(uuid, text, public.event_type, text, timestamptz, timestamptz, text, text, float8, float8, text) is
  'SECURITY DEFINER: owner-only event edit; only non-null args are applied.';

revoke all on function public.edit_event(uuid, text, public.event_type, text, timestamptz, timestamptz, text, text, float8, float8, text) from public;
grant execute on function public.edit_event(uuid, text, public.event_type, text, timestamptz, timestamptz, text, text, float8, float8, text) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- delete_event — soft delete only (is_deleted=true, event_status='removed'), and marks every
-- event_attending row for this event is_group_deleted=true (docs/features/06-events.md §5).
-- Owner or platform admin. Audited (destructive action, matches delete_group()).
-- ---------------------------------------------------------------------------------------------
create or replace function public.delete_event(p_event_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'delete_event: no authenticated user';
  end if;

  if not exists (select 1 from public.event_page where id = p_event_id and is_deleted = false) then
    raise exception 'delete_event: event not found';
  end if;

  if not (public.is_event_owner(p_event_id, v_uid) or public.is_admin()) then
    raise exception 'delete_event: caller is not the event owner or an admin';
  end if;

  update public.event_page
  set is_deleted = true, event_status = 'removed'
  where id = p_event_id;

  update public.event_attending
  set is_group_deleted = true
  where event_id = p_event_id;

  insert into public.audit_log (actor_id, action, target_table, target_id, details)
  values (v_uid, 'delete_event', 'event_page', p_event_id, jsonb_build_object());
end;
$$;

comment on function public.delete_event(uuid) is
  'SECURITY DEFINER: owner/admin soft-delete of an event; group-deletes every event_attending row. Audited.';

revoke all on function public.delete_event(uuid) from public;
grant execute on function public.delete_event(uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- update_event_location (UpdateEventLocationCall) — EXACT frontend contract: p_event_id, p_lat
-- and p_lon arrive as STRINGS (cast here), per docs/database/09-rpc-inventory.md §6 and the
-- literal JSON body in api_calls.dart. Owner-only.
-- ---------------------------------------------------------------------------------------------
create or replace function public.update_event_location(p_event_id uuid, p_lat text, p_lon text)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
  v_lat float8;
  v_lon float8;
begin
  if v_uid is null then
    raise exception 'update_event_location: no authenticated user';
  end if;

  if not public.is_event_owner(p_event_id, v_uid) then
    raise exception 'update_event_location: caller is not the event owner';
  end if;

  v_lat := p_lat::float8;
  v_lon := p_lon::float8;

  update public.event_page
  set location = extensions.ST_SetSRID(extensions.ST_MakePoint(v_lon, v_lat), 4326)::extensions.geography,
      latitude = v_lat,
      logitude = v_lon
  where id = p_event_id;
end;
$$;

comment on function public.update_event_location(uuid, text, text) is
  'SECURITY DEFINER: owner-only. Sets event_page.location/latitude/logitude from string lat/lon (frontend sends strings).';

revoke all on function public.update_event_location(uuid, text, text) from public;
grant execute on function public.update_event_location(uuid, text, text) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- invite_user_to_event (InviteUserToEventCall) — EXACT frontend contract: p_event_id,
-- p_attending_id. Upserts the event_attending row (the frontend's own two-path logic — RPC when a
-- row exists, direct insert otherwise — is consolidated into this single idempotent RPC so ALL
-- event_attending writes go through RPC, per CLAUDE.md §6). Does not downgrade an already-
-- attending user to invited-only.
-- ---------------------------------------------------------------------------------------------
create or replace function public.invite_user_to_event(p_event_id uuid, p_attending_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
  v_end timestamptz;
  v_row public.event_attending;
begin
  if v_uid is null then
    raise exception 'invite_user_to_event: no authenticated user';
  end if;

  if not exists (select 1 from public.event_page where id = p_event_id and is_deleted = false) then
    raise exception 'invite_user_to_event: event not found';
  end if;

  select end_date_time into v_end from public.event_page where id = p_event_id;

  select * into v_row from public.event_attending where event_id = p_event_id and attending_id = p_attending_id;

  if found then
    if coalesce(v_row.is_attending, false) then
      return; -- already attending — inviting is a no-op
    end if;
    update public.event_attending
    set is_invited = true, invited_by = v_uid, end_date_time = v_end
    where id = v_row.id;
  else
    insert into public.event_attending (event_id, attending_id, is_invited, invited_by, is_attending, end_date_time)
    values (p_event_id, p_attending_id, true, v_uid, false, v_end);
  end if;
end;
$$;

comment on function public.invite_user_to_event(uuid, uuid) is
  'SECURITY DEFINER: upserts an event_attending invite row (is_invited=true, invited_by=caller). No-op if already attending.';

revoke all on function public.invite_user_to_event(uuid, uuid) from public;
grant execute on function public.invite_user_to_event(uuid, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- rsvp_event (NEW) — self-RSVP only. Upserts the caller's own event_attending row. Replaces the
-- frontend's direct insert/update toggle (docs/features/06-events.md §5 "RSVP / Attend toggle").
-- ---------------------------------------------------------------------------------------------
create or replace function public.rsvp_event(p_event_id uuid, p_attending boolean)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
  v_end timestamptz;
begin
  if v_uid is null then
    raise exception 'rsvp_event: no authenticated user';
  end if;

  if not exists (select 1 from public.event_page where id = p_event_id and is_deleted = false) then
    raise exception 'rsvp_event: event not found';
  end if;

  select end_date_time into v_end from public.event_page where id = p_event_id;

  insert into public.event_attending (event_id, attending_id, is_invited, is_attending, end_date_time)
  values (p_event_id, v_uid, false, p_attending, v_end)
  on conflict (event_id, attending_id) do update
    set is_attending = p_attending;
end;
$$;

comment on function public.rsvp_event(uuid, boolean) is
  'SECURITY DEFINER: self-RSVP only. Upserts the caller''s event_attending row (is_attending toggle).';

revoke all on function public.rsvp_event(uuid, boolean) from public;
grant execute on function public.rsvp_event(uuid, boolean) to authenticated;

commit;

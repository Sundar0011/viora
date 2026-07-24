-- 0036_event_tables.sql
-- Purpose: Batch 5 (Events) tables — event_page, event_attending. Columns/types/nullability match
-- docs/database/04-tables-events-marketplace.md, cross-checked against the locked frontend Row
-- classes (event_page.dart, event_attending.dart).
--
-- RLS: ENABLE ROW LEVEL SECURITY on both tables, NO POLICIES in this file (deny-all to
-- anon/authenticated until reviewed). The proposed policy set lives in docs/rls-policies-draft.md
-- ("Batch 5 — Events, Marketplace & Storage") pending sign-off (CLAUDE.md §6.9).
--
-- community_id: kept as a vestigial compat column (int8, default 1, nullable, NO FK) on both
-- tables, per docs/decisions.md (2026-07-19, "Remove community concept") — both Row classes carry
-- the column and the locked frontend still sends/filters `= 1`.
--
-- Quirks preserved verbatim (CLAUDE.md §2 — frontend is the locked contract):
--   • event_page."Address" — capital "A", double-quoted every place it's referenced.
--   • event_page.logitude — misspelled (not "longitude"); event_page ALSO has correctly-spelled
--     "latitude" alongside it, so only the longitude column is misspelled.

begin;

-- ---------------------------------------------------------------------------------------------
-- event_page — one row per event. Soft-delete only (is_deleted/event_status). `location` is a
-- PostGIS geography point written ONLY by update_event_location()/create_event()/edit_event()
-- (never directly), separate from the human-readable "Address"/latitude/logitude columns.
-- ---------------------------------------------------------------------------------------------
create table public.event_page (
  id               uuid primary key default extensions.gen_random_uuid(),
  created_at       timestamptz not null default now(),
  community_id     int8 default 1, -- vestigial compat column, no FK; see file header
  admin_user       uuid not null references public."user" (id) on delete restrict,
  name             text not null,
  event_type       public.event_type not null,
  cover_image      text not null default '',
  video_call_link  text,
  location         extensions.geography(Point, 4326),
  start_date_time  timestamptz not null,
  end_date_time    timestamptz,
  description      text not null,
  is_deleted       boolean default false,
  attendee_count   int4 not null default 0,
  "Address"        text, -- quirk: capital "A", kept verbatim
  latitude         float8,
  logitude         float8, -- quirk: misspelled "logitude" (not "longitude"), kept verbatim
  event_status     public.lifecycle_status not null default 'active'
);

comment on table public.event_page is
  'One row per event (online/offline). Soft-delete only (is_deleted/event_status). Writes RPC-only (create_event/edit_event/delete_event). attendee_count is trigger-maintained from event_attending.';

-- admin_user FK'd `on delete restrict`: an event should not vanish via cascade if the creator's
-- account is later deleted — soft-delete the event explicitly instead (matches the "group"/"sale"
-- created_by precedent).
create index event_page_admin_user_idx on public.event_page (admin_user);
create index event_page_is_deleted_idx on public.event_page (is_deleted);
create index event_page_end_date_time_idx on public.event_page (end_date_time);
create index event_page_created_at_idx on public.event_page (created_at);
create index event_page_event_status_idx on public.event_page (event_status);
-- Lifecycle-filter composites for the list RPCs (upcoming = is_deleted=false AND end_date_time>now()).
create index event_page_lifecycle_idx on public.event_page (is_deleted, end_date_time);
create index event_page_lifecycle_created_idx on public.event_page (is_deleted, end_date_time, created_at);
-- GiST for distance/nearby queries against event location (no confirmed nearby-events screen today,
-- added defensively since the column is a geography point — TODO(confirm) if unused, drop later).
create index event_page_location_gix on public.event_page using gist (location);

alter table public.event_page enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

-- ---------------------------------------------------------------------------------------------
-- event_attending — join table for RSVP + invitations. One row per (event, user). UNIQUE
-- (event_id, attending_id) closes the duplicate-attendee-row gap flagged in
-- docs/features/06-events.md §8.6 (invite flow could otherwise insert twice).
-- ---------------------------------------------------------------------------------------------
create table public.event_attending (
  id                uuid primary key default extensions.gen_random_uuid(),
  created_at        timestamptz not null default now(),
  community_id      int8 default 1, -- vestigial compat column, no FK; see file header
  event_id          uuid not null references public.event_page (id) on delete cascade,
  attending_id      uuid not null references public."user" (id) on delete cascade,
  is_invited        boolean not null default false,
  invited_by        uuid references public."user" (id) on delete set null,
  is_attending       boolean default false,
  end_date_time     timestamptz,
  is_group_deleted  boolean default false,
  constraint event_attending_event_id_attending_id_key unique (event_id, attending_id)
);

comment on table public.event_attending is
  'RSVP/invite join row, one per (event, user). Writes only via rsvp_event()/invite_user_to_event()/create_event() (auto-attend)/delete_event() (group-delete flag).';

create index event_attending_event_id_idx on public.event_attending (event_id);
create index event_attending_attending_id_idx on public.event_attending (attending_id);
create index event_attending_invited_by_idx on public.event_attending (invited_by);
-- "my invited events" query composite (attending_id, is_invited, is_attending, end_date_time, is_group_deleted).
create index event_attending_my_invited_idx
  on public.event_attending (attending_id, is_invited, is_attending, end_date_time, is_group_deleted);

alter table public.event_attending enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

commit;

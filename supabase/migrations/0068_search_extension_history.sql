-- 0068_search_extension_history.sql
-- Purpose: Batch 7 (Notifications, Search & Moderation) — FINAL backend batch. This file starts
-- the Search & Tags portion:
--   (a) enable pg_trgm (trigram similarity/ILIKE-acceleration) into the `extensions` schema,
--       matching the 0001_extensions.sql convention (idempotent, `create extension if not exists
--       ... with schema extensions`).
--   (b) `search_history` table — the ONLY new Search table this batch adds (`tag` + `insert_tags`
--       already exist, Batch 2, 0008/0012 — NOT recreated here). Columns/types/nullability match
--       docs/database/06-tables-notifications-search-moderation.md, cross-checked against the
--       locked frontend Row class (search_history.dart).
--
-- community_id: kept as a vestigial compat column (int8, nullable, DEFAULT 1, NO FK) — matches the
-- Row class and every other vestigial column in this schema, per docs/decisions.md (2026-07-19,
-- "Remove community concept"). NOT used in RLS/RPC scoping.

begin;

-- pg_trgm: trigram GIN indexes for ILIKE/substring search (get_search_all_data/get_search_data/
-- tag_search) — chosen per docs/database/06-tables-notifications-search-moderation.md's
-- recommendation over full-text tsvector, since the frontend's search box is a plain substring
-- box (2000ms-debounced ILIKE-style matching), not a ranked/prefix search UI.
create extension if not exists pg_trgm with schema extensions;

-- ---------------------------------------------------------------------------------------------
-- search_history — one row per stored search term, per user. Read on page load (recent
-- searches), written on submit, bulk-deleted on "Clear". Writes go through update_search_data()
-- RPC (0070); SELECT/DELETE are owner-scoped RLS (0083) since the frontend does direct
-- queryRows/delete (CLAUDE.md §6 allows tightly-scoped RLS for trivial owner rows, decision #4 —
-- same precedent as sale_images).
-- ---------------------------------------------------------------------------------------------
create table public.search_history (
  id                  uuid primary key default extensions.gen_random_uuid(),
  created_at          timestamptz not null default now(),
  community_id        int8 default 1, -- vestigial compat column, no FK; see file header
  search              text not null,
  searched_by         uuid not null references public."user" (id) on delete cascade,
  last_updated_date   timestamptz
);

comment on table public.search_history is
  'One row per stored search term per user. Owner-scoped RLS (SELECT/DELETE); INSERT/UPDATE via update_search_data() RPC only.';

create index search_history_searched_by_idx on public.search_history (searched_by);
create index search_history_searched_by_created_at_idx on public.search_history (searched_by, created_at desc);
-- Candidate UNIQUE (searched_by, lower(search)) for true upsert/dedupe semantics — NOT added yet;
-- docs/database/06-tables-notifications-search-moderation.md flags this as unconfirmed
-- (update_search_data's exact dedupe behavior). update_search_data() (0070) implements a
-- manual find-then-update-or-insert upsert instead, so this works correctly even without the
-- constraint. -- TODO(confirm): add the UNIQUE constraint once "one row per distinct term" is
-- confirmed as the intended behavior (would also let the RPC use a real ON CONFLICT upsert).

alter table public.search_history enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md ("Batch 7") is reviewed and
-- applied (CLAUDE.md §6.9). See 0083_notifications_search_moderation_rls.sql.

commit;

-- 0017_follows_table.sql
-- Purpose: Batch 3 (Neighbors/Follows) — the `follows` table. Columns match the locked frontend
-- Row class (lib/backend/supabase/database/tables/follows.dart): id, created_at, community_id,
-- follower_id, following_id. FKs to public."user"(id) on delete cascade (real FK, unlike the
-- vestigial community_id compat column). UNIQUE(follower_id, following_id) is the toggle-source
-- of truth for user_follow() (0018_follows_functions.sql).
--
-- RLS: ENABLE ROW LEVEL SECURITY, NO POLICIES in this file (deny-all to anon/authenticated until
-- reviewed). The proposed policy set lives in docs/rls-policies-draft.md ("Batch 3 — Follows")
-- pending sign-off (CLAUDE.md §6.9).
--
-- community_id: kept as a vestigial compat column (int8, default 1, nullable, NO FK) per
-- docs/decisions.md (2026-07-19, "Remove community concept") — follows.dart carries the column
-- and AddFollowCall/GetNeighborhoodPeoplesCall still send/accept p_communityid.
--
-- "Friends" (used by can_view_post id=2, see_post_access) = MUTUAL follow: both
-- (A follows B) and (B follows A) rows exist. No separate "friends" table/flag.

begin;

-- ---------------------------------------------------------------------------------------------
-- follows — directed follow edge. A row means follower_id follows following_id.
-- ---------------------------------------------------------------------------------------------
create table public.follows (
  id            uuid primary key default extensions.gen_random_uuid(),
  created_at    timestamptz not null default now(),
  community_id  int8 default 1, -- vestigial compat column, no FK; see file header
  follower_id   uuid not null references public."user" (id) on delete cascade,
  following_id  uuid not null references public."user" (id) on delete cascade,
  constraint follows_follower_id_following_id_key unique (follower_id, following_id),
  constraint follows_no_self_follow check (follower_id <> following_id)
);

comment on table public.follows is
  'Directed follow edge (follower_id follows following_id). INSERT/DELETE only via user_follow() RPC (toggle). Mutual follow (both directions) = "friends" for see_post_access id=2.';

-- Index every FK. following_id also serves "who follows user X" (followers list); follower_id
-- also serves "who does user X follow" (following list).
create index follows_follower_id_idx on public.follows (follower_id);
create index follows_following_id_idx on public.follows (following_id);
-- Keyset-pagination-friendly composite indexes for get_followers/get_following ordering.
create index follows_following_id_created_at_idx on public.follows (following_id, created_at desc, id desc);
create index follows_follower_id_created_at_idx on public.follows (follower_id, created_at desc, id desc);

alter table public.follows enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md ("Batch 3 — Follows") is
-- reviewed and applied.

commit;

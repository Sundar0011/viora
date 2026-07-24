-- 0008_post_tables.sql
-- Purpose: Batch 2 tables — post, post_images, post_like, post_share, tag, see_post_access,
-- comment_post_access, post_comment, post_comment_likes, and blocks (brought forward from a
-- later moderation batch per this task's explicit instruction). Columns/types/nullability match
-- docs/database/02-tables-posts-comments.md, cross-checked against the locked frontend Row
-- classes (post.dart, post_images.dart, post_like.dart, post_share.dart, tag.dart,
-- see_post_access.dart, comment_post_access.dart, post_comment.dart, post_comment_likes.dart,
-- blocks.dart).
--
-- RLS: ENABLE ROW LEVEL SECURITY on every table below, NO POLICIES in this file (deny-all to
-- anon/authenticated until reviewed). The proposed policy set lives in
-- docs/rls-policies-draft.md ("Batch 2 — Posts & Comments") pending sign-off (CLAUDE.md §6.9).
--
-- community_id: kept as a vestigial compat column (int8, default 1, nullable, NO FK) only on the
-- tables whose frontend Row class actually carries it — post, post_images, post_like, post_share,
-- post_comment, post_comment_likes, blocks — per docs/decisions.md (2026-07-19, "Remove
-- community concept"). NOT added to tag / see_post_access / comment_post_access (frontend Row
-- classes for those three do not have the column).
--
-- post.group_id: the "group" table does not exist yet (Groups is a later batch — see
-- docs/database/03-tables-community-groups.md). The column is created here as a plain nullable
-- uuid with NO FK for now; the FK (`references public."group" (id) on delete set null`) will be
-- added by an ALTER TABLE in the Groups batch migration. -- TODO(confirm): revisit on delete
-- semantics (set null vs cascade) at that time, per docs/database/02-tables-posts-comments.md.

begin;

-- ---------------------------------------------------------------------------------------------
-- see_post_access — lookup: who may SEE a post. Three levels, stakeholder-confirmed 2026-07-19
-- (post-clarification, supersedes the earlier "Your Neighbourhood"/community-flavored wording):
--   id 1 = Everyone (anyone on or off SquaDD)
--   id 2 = Friends only (follow-graph based — NOT community, NOT geographic)
--   id 3 = Nearby only (geographic, via user_locations distance)
-- No community_id scoping anywhere; enforcement logic lives in public.can_view_post().
-- ---------------------------------------------------------------------------------------------
create table public.see_post_access (
  id          int4 primary key,
  created_at  timestamptz not null default now(),
  name        text not null
);

comment on table public.see_post_access is
  'Lookup: post view-scope options (Everyone / Friends only / Nearby). SELECT to authenticated; writes admin-only.';

insert into public.see_post_access (id, name) values
  (1, 'Everyone'),
  (2, 'Friends only'),
  (3, 'Nearby')
on conflict (id) do nothing;

alter table public.see_post_access enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

-- ---------------------------------------------------------------------------------------------
-- comment_post_access — lookup: who may COMMENT on a post. Seed only the two CONFIRMED rows
-- (1, 4). Ids 2/3 are referenced by UI branches but their exact label/semantics are unconfirmed
-- (docs/database/02-tables-posts-comments.md) — left unseeded rather than guessed.
-- -- TODO(confirm): seed ids 2/3 once their labels/semantics are confirmed with product.
-- ---------------------------------------------------------------------------------------------
create table public.comment_post_access (
  id          int4 primary key,
  created_at  timestamptz not null default now(),
  name        text not null
);

comment on table public.comment_post_access is
  'Lookup: who-can-comment options. SELECT to authenticated; writes admin-only.';

insert into public.comment_post_access (id, name) values
  (1, 'Anyone on SquaDD'),
  (4, 'No One')
on conflict (id) do nothing;

alter table public.comment_post_access enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

-- ---------------------------------------------------------------------------------------------
-- post — one neighborhood post. Author = user_id. Soft-delete only (is_deleted + post_status).
-- ---------------------------------------------------------------------------------------------
create table public.post (
  id                        uuid primary key default extensions.gen_random_uuid(),
  created_at                timestamptz not null default now(),
  user_id                   uuid not null references public."user" (id) on delete cascade,
  content                   text not null,
  content_text              text,
  likes_count               int4 default 0,
  comment_count             int4 default 0,
  share_count               int4 default 0,
  is_edited                 boolean default false,
  is_deleted                boolean default false,
  last_modified_date        timestamptz,
  see_post_access_id        int4 not null references public.see_post_access (id) on delete restrict,
  comment_post_access_id    int4 not null references public.comment_post_access (id) on delete restrict,
  community_id              int8 default 1, -- vestigial compat column, no FK; see file header
  is_group_post             boolean default false,
  group_id                  uuid, -- FK added later (Groups batch) — "group" table doesn't exist yet
  location                  text,
  post_status               public.lifecycle_status not null default 'active',
  tagged_people             jsonb,
  tldr                      text
);

comment on table public.post is
  'One neighborhood post: text + optional images, counters, access control, soft-delete.';

create index post_user_id_idx on public.post (user_id);
create index post_group_id_idx on public.post (group_id);
create index post_see_post_access_id_idx on public.post (see_post_access_id);
create index post_comment_post_access_id_idx on public.post (comment_post_access_id);
create index post_status_idx on public.post (post_status);
create index post_is_deleted_idx on public.post (is_deleted);
create index post_created_at_idx on public.post (created_at desc);
-- Primary feed-serving composite index (no community_id — no community scoping).
create index post_feed_idx on public.post (is_deleted, post_status, created_at desc);

alter table public.post enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

-- ---------------------------------------------------------------------------------------------
-- post_images — media rows attached to a post. Images only (no video, out of scope).
-- ---------------------------------------------------------------------------------------------
create table public.post_images (
  id            uuid primary key default extensions.gen_random_uuid(),
  created_at    timestamptz not null default now(),
  community_id  int8 default 1, -- vestigial compat column, no FK; see file header
  post_id       uuid not null references public.post (id) on delete cascade,
  image         text not null,
  e_media_type  text not null default 'image',
  user_id       uuid not null references public."user" (id) on delete cascade
);

comment on table public.post_images is
  'Media rows attached to a post (images only). Writes limited to the post author, via RPC.';

create index post_images_post_id_idx on public.post_images (post_id);
create index post_images_user_id_idx on public.post_images (user_id);

alter table public.post_images enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

-- ---------------------------------------------------------------------------------------------
-- post_like — one row per (user, post) like. Presence = liked. Written only via add_like RPC.
-- ---------------------------------------------------------------------------------------------
create table public.post_like (
  id            uuid primary key default extensions.gen_random_uuid(),
  created_at    timestamptz not null default now(),
  community_id  int8 default 1, -- vestigial compat column, no FK; see file header
  post_id       uuid not null references public.post (id) on delete cascade,
  user_id       uuid not null references public."user" (id) on delete cascade,
  constraint post_like_post_id_user_id_key unique (post_id, user_id)
);

comment on table public.post_like is
  'One row per (user, post) like. INSERT/DELETE only via add_like() RPC (toggle).';

create index post_like_post_id_idx on public.post_like (post_id);
create index post_like_user_id_idx on public.post_like (user_id);

alter table public.post_like enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

-- ---------------------------------------------------------------------------------------------
-- post_share — one row per share event. Written only via update_post_share_count RPC.
-- ---------------------------------------------------------------------------------------------
create table public.post_share (
  id            uuid primary key default extensions.gen_random_uuid(),
  created_at    timestamptz not null default now(),
  community_id  int8 default 1, -- vestigial compat column, no FK; see file header
  post_id       uuid not null references public.post (id) on delete cascade,
  user_id       uuid not null references public."user" (id) on delete cascade
);

comment on table public.post_share is
  'One row per share event of a post. INSERT only via update_post_share_count() RPC.';

create index post_share_post_id_idx on public.post_share (post_id);
create index post_share_user_id_idx on public.post_share (user_id);

alter table public.post_share enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

-- ---------------------------------------------------------------------------------------------
-- tag — post <-> user @mentions. AUTHORITATIVE source for tagging (post.tagged_people jsonb is
-- a denormalized cache, per docs/decisions.md 2026-07-19).
-- ---------------------------------------------------------------------------------------------
create table public.tag (
  id          uuid primary key default extensions.gen_random_uuid(),
  created_at  timestamptz not null default now(),
  post_id     uuid references public.post (id) on delete cascade, -- nullable per frontend Row class
  user_id     uuid not null references public."user" (id) on delete cascade,
  constraint tag_post_id_user_id_key unique (post_id, user_id)
);

comment on table public.tag is
  'Authoritative post <-> user tag/mention rows. INSERT only via insert_tags() RPC (post owner only).';

create index tag_post_id_idx on public.tag (post_id);
create index tag_user_id_idx on public.tag (user_id);

alter table public.tag enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

-- ---------------------------------------------------------------------------------------------
-- post_comment — one row per comment OR reply (single-level threading via parent_comment_id).
-- ---------------------------------------------------------------------------------------------
create table public.post_comment (
  id                  uuid primary key default extensions.gen_random_uuid(),
  created_at          timestamptz not null default now(),
  community_id        int8 default 1, -- vestigial compat column, no FK; see file header
  user_id             uuid not null references public."user" (id) on delete cascade,
  post_id             uuid not null references public.post (id) on delete cascade,
  comment             text not null,
  likes_count         int4 default 0,
  replies_count       int4 default 0,
  parent_comment_id   uuid references public.post_comment (id) on delete cascade,
  tldr                text
);

comment on table public.post_comment is
  'One row per comment or reply. Single-level threading (parent_comment_id). Writes via add_comment() RPC.';

create index post_comment_post_id_idx on public.post_comment (post_id);
create index post_comment_user_id_idx on public.post_comment (user_id);
create index post_comment_parent_comment_id_idx on public.post_comment (parent_comment_id);
create index post_comment_created_at_idx on public.post_comment (created_at desc);
create index post_comment_post_parent_idx on public.post_comment (post_id, parent_comment_id);

alter table public.post_comment enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

-- ---------------------------------------------------------------------------------------------
-- post_comment_likes — one row per (user, comment) like. Written only via add_comment_like RPC.
-- ---------------------------------------------------------------------------------------------
create table public.post_comment_likes (
  id            uuid primary key default extensions.gen_random_uuid(),
  created_at    timestamptz not null default now(),
  community_id  int8 default 1, -- vestigial compat column, no FK; see file header
  user_id       uuid not null references public."user" (id) on delete cascade,
  post_id       uuid not null references public.post (id) on delete cascade,
  comment_id    uuid not null references public.post_comment (id) on delete cascade,
  constraint post_comment_likes_comment_id_user_id_key unique (comment_id, user_id)
);

comment on table public.post_comment_likes is
  'One row per (user, comment) like. INSERT/DELETE only via add_comment_like() RPC (toggle).';

create index post_comment_likes_comment_id_idx on public.post_comment_likes (comment_id);
create index post_comment_likes_user_id_idx on public.post_comment_likes (user_id);
create index post_comment_likes_post_id_idx on public.post_comment_likes (post_id);

alter table public.post_comment_likes enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

-- ---------------------------------------------------------------------------------------------
-- blocks — two-way blocking (brought forward from the Moderation batch per this task's explicit
-- instruction, since every content read RPC in this batch must filter on it). Only the table +
-- the block-pair filter land now; block_user()/unblock_user() RPCs and report/mute UI stay in the
-- Moderation batch.
-- ---------------------------------------------------------------------------------------------
create table public.blocks (
  id            uuid primary key default extensions.gen_random_uuid(),
  created_at    timestamptz not null default now(),
  blocker_id    uuid not null references public."user" (id) on delete cascade,
  blocked_id    uuid not null references public."user" (id) on delete cascade,
  community_id  int8 default 1, -- vestigial compat column, no FK; see file header
  constraint blocks_blocker_id_blocked_id_key unique (blocker_id, blocked_id)
);

comment on table public.blocks is
  'Two-way block list. blocker_id blocks blocked_id. Owner (blocker) manages own rows; both directions filtered on content reads.';

create index blocks_blocker_id_idx on public.blocks (blocker_id);
create index blocks_blocked_id_idx on public.blocks (blocked_id);

alter table public.blocks enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

commit;

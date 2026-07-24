# Database Design — Posts, Feed & Comments Tables

> Part of `docs/database-design.md`. DESIGN ONLY — not applied. Source: `docs/features/
> 02-home-feed-posts.md`, `03-comments.md`.

### `post`
Purpose: one neighborhood post (text + optional images), counters, access control, soft-delete.

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK, default `gen_random_uuid()` |
| `created_at` | timestamptz | NO | default `now()` |
| `user_id` | uuid | NO | FK → `"user".id` (author) |
| `content` | text | NO | rich-text JSON string |
| `content_text` | text | YES | plain-text (TLDR source) |
| `likes_count` | int4 | YES | default `0`; trigger-maintained |
| `comment_count` | int4 | YES | default `0`; trigger-maintained |
| `share_count` | int4 | YES | default `0`; trigger-maintained |
| `is_edited` | bool | YES | default `false` |
| `is_deleted` | bool | YES | default `false` |
| `last_modified_date` | timestamptz | YES | set on edit |
| `see_post_access_id` | int4 | NO | FK → `see_post_access.id` |
| `comment_post_access_id` | int4 | NO | FK → `comment_post_access.id` |
| `community_id` | int8 | YES | vestigial compat column — no community feature; retained only because the locked frontend Row class sends/filters it (CLAUDE.md §2). Default `1`. **No FK.** Not used in RLS/scoping. |
| `is_group_post` | bool | YES | default `false` |
| `group_id` | uuid | YES | FK → `"group".id`, nullable |
| `location` | text | YES | free-text location string |
| `post_status` | `lifecycle_status` enum | NO | default `'active'` |
| `tagged_people` | jsonb | YES | inline tagged-people array (see Open Decisions re: dual source with `tag`) |
| `tldr` | text | YES | AI summary, edge-fn written |

PK: `id`. FKs: `user_id → "user".id on delete cascade`; `group_id → "group".id on delete set null`
(a post outlives a deleted group as an orphaned post — alternative is cascade; kept `set null`
since `is_group_post` flag still shows context; confirm with product); `see_post_access_id →
see_post_access.id on delete restrict`; `comment_post_access_id → comment_post_access.id on
delete restrict`. `community_id` has no FK (vestigial, see `03-tables-community-groups.md`).
Indexes: `user_id`, `group_id`, `see_post_access_id`, `comment_post_access_id`, `post_status`,
`is_deleted`, `created_at` (feed order); composite `(is_deleted, post_status, created_at desc)`
for feed queries (`community_id` dropped from the composite — no community scoping).
RLS intent: SELECT gated by `get_visible_posts` visibility (author, `see_post_access_id`
audience rule, follows, group membership — no community boundary) AND `is_deleted=false`. INSERT:
author = `auth.uid()`. UPDATE: author-or-admin only, and only via `update-user-post` edge fn / RPC
(not raw client `.update`, per CLAUDE.md §6 — see `10-open-decisions.md`). DELETE: none
(soft-delete only).

### `post_images`
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `community_id` | int8 | YES | vestigial compat column — no community feature; retained only because the locked frontend Row class sends/filters it (CLAUDE.md §2). Default `1`. **No FK.** Not used in RLS/scoping. |
| `post_id` | uuid | NO | FK → `post.id` |
| `image` | text | NO | public storage URL |
| `e_media_type` | text | NO | `'image'` only — video is **out of scope** (no video-upload UI in the frontend), see `07-storage-buckets.md` |
| `user_id` | uuid | NO | FK → uploader |

PK: `id`. FKs: `post_id → post.id on delete cascade`; `user_id → "user".id on delete cascade`.
`community_id` has no FK (vestigial, see `03-tables-community-groups.md`).
Indexes: `post_id`, `user_id`.
RLS intent: SELECT follows post visibility; writes limited to the post author, via
`insert_post_image_rows` RPC only.

### `post_like`
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `community_id` | int8 | YES | vestigial compat column — no community feature; retained only because the locked frontend Row class sends/filters it (CLAUDE.md §2). Default `1`. **No FK.** Not used in RLS/scoping. |
| `post_id` | uuid | NO | FK → `post.id` |
| `user_id` | uuid | NO | FK → liker |

PK: `id`. FKs: `post_id → post.id on delete cascade`; `user_id → "user".id on delete cascade`.
`community_id` has no FK (vestigial, see above).
Indexes: `post_id`, `user_id`; **unique `(post_id, user_id)`**.
RLS intent: INSERT/DELETE only via `add_like` RPC (toggle) — no direct client insert of the like
row itself (RPC keeps `post.likes_count` consistent atomically). SELECT per post visibility.

### `post_share`
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `community_id` | int8 | YES | vestigial compat column — no community feature; retained only because the locked frontend Row class sends/filters it (CLAUDE.md §2). Default `1`. **No FK.** Not used in RLS/scoping. |
| `post_id` | uuid | NO | FK → `post.id` |
| `user_id` | uuid | NO | FK → sharer |

PK: `id`. FKs: `post_id → post.id on delete cascade`; `user_id → "user".id on delete cascade`.
`community_id` has no FK (vestigial, see above).
Indexes: `post_id`, `user_id`.
RLS intent: INSERT only via `update_post_share_count` RPC.

### `tag` (post ↔ user @mentions)
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `post_id` | uuid | YES | FK → `post.id` (nullable per frontend Row class — flagged in Open Decisions) |
| `user_id` | uuid | NO | FK → tagged user |

PK: `id`. FKs: `post_id → post.id on delete cascade`; `user_id → "user".id on delete cascade`.
Indexes: `post_id`, `user_id`; unique `(post_id, user_id)` to dedupe tags per post.
RLS intent: SELECT follows post visibility; INSERT only via `insert_tags` RPC, which validates the
caller owns the post.

### `see_post_access` (lookup)
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | int4 | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `name` | text | NO | e.g. "Anyone on or off SquaDD" (id 1), "Your Neighbourhood Only" (2), "Nearby Neighbourhood" (3) |

RLS intent: SELECT `authenticated`; writes admin-only. Seed rows 1–3 per confirmed values.

### `comment_post_access` (lookup)
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | int4 | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `name` | text | NO | id 1 = "Anyone on SquaDD", id 4 = "No One"; ids 2/3 unconfirmed (Open Decisions) |

RLS intent: SELECT `authenticated`; writes admin-only. Seed rows 1 and 4 now; 2/3 pending
confirmation.

### `post_comment`
Purpose: one row per comment OR reply (single-level threading via `parent_comment_id`).

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK, default `gen_random_uuid()` (typed `text/uuid` mismatch flagged in Open Decisions; built as uuid — matches the majority of call sites) |
| `created_at` | timestamptz | NO | default `now()` |
| `community_id` | int8 | YES | vestigial compat column — no community feature; retained only because the locked frontend Row class sends/filters it (CLAUDE.md §2). Default `1`. **No FK.** Not used in RLS/scoping. |
| `user_id` | uuid | NO | FK → author |
| `post_id` | uuid | NO | FK → `post.id` |
| `comment` | text | NO | body |
| `likes_count` | int4 | YES | default `0`; trigger-maintained |
| `replies_count` | int4 | YES | default `0`; trigger-maintained |
| `parent_comment_id` | uuid | YES | self-FK; NULL = top-level |
| `tldr` | text | YES | optional AI summary (write path unconfirmed — Open Decisions) |

PK: `id`. FKs: `post_id → post.id on delete cascade`; `user_id → "user".id on delete cascade`;
`parent_comment_id → post_comment.id on delete cascade` (replies drop with parent).
`community_id` has no FK (vestigial, see `03-tables-community-groups.md`). Recommended CHECK:
`parent_comment_id` must reference a row whose own `parent_comment_id IS NULL` (enforces
single-level threading) — add as a trigger-based constraint since Postgres CHECK can't
self-reference other rows.
Indexes: `post_id`, `user_id`, `parent_comment_id`, `created_at`; composite
`(post_id, parent_comment_id)`.
RLS intent: SELECT gated by the post's `comment_post_access` rule (no community boundary).
INSERT: `auth.uid() = user_id`, post must exist and pass its `comment_post_access` rule — enforce
via a `add_comment` RPC (frontend currently does direct insert; CLAUDE.md §6 gap, see Open
Decisions). UPDATE/DELETE: none observed — admin-only if ever needed for moderation.

### `post_comment_likes`
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `community_id` | int8 | YES | vestigial compat column — no community feature; retained only because the locked frontend Row class sends/filters it (CLAUDE.md §2). Default `1`. **No FK.** Not used in RLS/scoping. |
| `user_id` | uuid | NO | FK → liker |
| `post_id` | uuid | NO | FK → `post.id` |
| `comment_id` | uuid | NO | FK → `post_comment.id` |

PK: `id`. FKs: `comment_id → post_comment.id on delete cascade`; `post_id → post.id on delete
cascade`; `user_id → "user".id on delete cascade`. `community_id` has no FK (vestigial, see
above).
Indexes: `comment_id`, `user_id`, `post_id`; **unique `(comment_id, user_id)`**.
RLS intent: no direct client writes — mutated only inside `add_comment_like` RPC (toggle). SELECT
follows the parent comment/post visibility (no community boundary).

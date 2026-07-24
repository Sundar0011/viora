# Database Design — Notifications, Search & Moderation Tables

> Part of `docs/database-design.md`. DESIGN ONLY — not applied. Source: `docs/features/
> 11-notifications.md`, `12-search-tags.md`, `13-moderation-reports-blocks.md`.

## Notifications

### `notifications`
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `sender_id` | uuid | NO | FK → `"user".id` (actor) |
| `receiver_id` | uuid | **NO** | FK → `"user".id`. **Made NOT NULL here** — the Row class marks it
  nullable but every query/RLS predicate keys on it; kept nullable in the frontend by mistake per
  feature doc §8.5 (flagged, not silently "fixed" without note). |
| `type` | text | YES | routing key: `post`/`comment`/`event`/`business`/`sale`/`group`/`invite`/`group_invite` — kept `text` (open set) |
| `notification_type` | text | YES | purpose unconfirmed — duplicate of `type`? kept as-is (Open Decisions) |
| `content` | text | NO | |
| `title` | text | YES | |
| `message` | text | YES | |
| `is_read` | bool | NO | default `false` |
| `is_deleted` | bool | NO | default `false` |
| `post_id` | uuid | YES | FK → `post.id` |
| `comment_id` | uuid | YES | FK → `post_comment.id` |
| `event_id` | uuid | YES | FK → `event_page.id` |
| `business_id` | uuid | YES | FK → `business_page.id` |
| `sale_id` | uuid | YES | FK → `sale.id` |
| `group_id` | uuid | YES | FK → `"group".id` |
| `message_id` | uuid | YES | FK → `messages.id` |

PK: `id`. FKs: `sender_id → "user".id on delete cascade`; `receiver_id → "user".id on delete
cascade`; entity FKs all `on delete cascade` (a deleted post/event/etc. also removes the
notifications that reference it — avoids dangling links the UI can't open).
Indexes: `(receiver_id, created_at desc)`, `(receiver_id, is_deleted, is_read)`, `sender_id`, and
every entity FK column.
RLS intent: SELECT only `receiver_id = auth.uid()`. UPDATE limited to own rows, only `is_read`/
`is_deleted` columns (via `WITH CHECK` matching `USING`). INSERT/DELETE **not** allowed to normal
users — rows are created server-side by producer triggers/RPCs owned by each source feature (like,
comment, follow/invite, event, group, business, sale — see `08-triggers-counters.md`).

**High-volume table note:** like `messages`, expect high insert volume. Recommend monthly
partitioning by `created_at` once volume justifies it; keyset pagination on `(receiver_id,
created_at, id)` for `get_notifications`, not offset pagination.

### `admin_notification`
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | int8 | NO | PK (bigint identity — differs from `notifications.id`) |
| `created_at` | timestamptz | NO | default `now()` |
| `title` | text | YES | |
| `content` | text | YES | |
| `sent_on` | timestamptz | YES | null until sent |
| `status` | text | YES | draft/scheduled/sent — value set unconfirmed (Open Decisions) |
| `audience_type` | text | YES | value set unconfirmed |
| `created_by` | uuid | YES | **NEW column** — no admin sender FK exists in the frontend Row class; added for audit traceability, flagged as new/optional in Open Decisions |

Indexes: `status`, `sent_on`, `audience_type`.
RLS intent: SELECT/INSERT/UPDATE **admin-only** (`is_admin()`). Fan-out to `notifications` rows +
push happens via an admin RPC / edge function, not client DML.

## Search

### `search_history`
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `community_id` | int8 | YES | vestigial compat column — no community feature; retained only because the locked frontend Row class sends/filters it (CLAUDE.md §2). Default `1`. **No FK.** Not used in RLS/scoping. |
| `search` | text | NO | |
| `searched_by` | uuid | NO | FK → `"user".id` |
| `last_updated_date` | timestamptz | YES | bumped on re-search (upsert semantics implied — Open Decisions) |

PK: `id`. FK: `searched_by → "user".id on delete cascade`. `community_id` has no FK (vestigial,
see `03-tables-community-groups.md`).
Indexes: `(searched_by, created_at desc)`. Candidate **unique** `(searched_by, lower(search))` if
`update_search_data` is confirmed to dedupe (Open Decisions) — not applied until confirmed.
RLS intent: SELECT/DELETE only `searched_by = auth.uid()`. No direct client INSERT — writes go
through `update_search_data` RPC only (frontend currently does direct SELECT/DELETE; per CLAUDE.md
§6 these must be RLS-enforced server-side regardless of the client's own filter).

### Full-text / trigram search columns
Recommend `pg_trgm` GIN indexes (`gin_trgm_ops`) on: `post.content_text`, `sale.title`,
`sale.description`, `event_page.name`, `"group".name`, `public_user_profile.name`,
`business_page.name`. This backs `get_search_all_data`, `get_search_data`, and `tag_search`
(`@mention` autocomplete on `public_user_profile.name`) without inventing new columns — indexes
only, no schema change to the searched tables themselves.

## Moderation

### `reports`
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `community_id` | int8 | YES | vestigial compat column — no community feature; retained only because the locked frontend Row class sends/filters it (CLAUDE.md §2). Default `1`. **No FK.** Not used in RLS/scoping. |
| `reported_by_user` | uuid | NO | FK → `"user".id` (reporter; forced to `auth.uid()` server-side) |
| `reported_user` | uuid | YES | FK → `"user".id`; **coerce client's `''` to `NULL`** in the RPC (Open Decisions) |
| `reason` | text | NO | |
| `report_type` | text | NO | `post`/`account`/`business`/`event`/`group`/`sale`/`message`; kept `text` (an empty-string value was observed, incompatible with a strict enum — Open Decisions) |
| `post_id` | uuid | YES | FK → `post.id` |
| `comment_id` | uuid | YES | FK → `post_comment.id` (column exists, unused by any current dialog) |
| `group_id` | uuid | YES | FK → `"group".id` |
| `business_page_id` | uuid | YES | FK → `business_page.id` |
| `event_id` | uuid | YES | FK → `event_page.id` |
| `sale_id` | uuid | YES | FK → `sale.id` |
| `report_status` | text | NO | default `'pending'` |
| `mail_sent` | bool | YES | default `false`; set by the admin-email trigger/edge fn only |

PK: `id`. FKs: `reported_by_user`, `reported_user → "user".id on delete cascade`/`set null`
(`reported_user` uses `set null` since the report should survive even if the target account is
later deleted); all entity FKs `on delete cascade` (a report tied to a deleted post/etc. is no
longer actionable). `community_id` has no FK (vestigial, see `03-tables-community-groups.md`).
Indexes: every real FK column, `report_status`, `mail_sent`, `report_type`.
RLS intent: INSERT via `report_content()` RPC only — validates `reported_by_user = auth.uid()`,
target exists, `report_type` matches the populated FK; `community_id` is accepted for frontend
compat but not used for any scoping/derivation. SELECT: **admin only** (moderation queue).
UPDATE/DELETE: admin only.

### `blocks`
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `blocker_id` | uuid | NO | FK → `"user".id` |
| `blocked_id` | uuid | NO | FK → `"user".id` |
| `community_id` | int8 | YES | vestigial compat column — no community feature; retained only because the locked frontend Row class sends/filters it (CLAUDE.md §2). Default `1`. **No FK.** Not used in RLS/scoping. |

PK: `id`. FKs: `blocker_id`, `blocked_id → "user".id on delete cascade`. `community_id` has no
FK (vestigial).
Indexes: `blocker_id`, `blocked_id`; **unique `(blocker_id, blocked_id)`**
(closes the duplicate-block gap flagged in the feature doc §8.5); index `(blocked_id, blocker_id)`
for reverse lookups.
RLS intent: SELECT only `blocker_id = auth.uid()` (and `blocked_id = auth.uid()` if reverse checks
are needed — minimally exposed). INSERT only `blocker_id = auth.uid()`, via `block_user(target)`
RPC (self-block guard, unique-constraint-safe). DELETE only own rows, via `unblock_user(target)`.

**Cross-feature filter (required, not a table):** every content-returning RPC (feed, search, chat
list, comments, business/event/group/sale lists) must exclude content authored by users in a
block relationship with the caller — direction (one-way vs two-way) is an **open product
decision**, see `10-open-decisions.md`.

### `audit_log` (NEW — required by CLAUDE.md §6.5, not present in any frontend Row class)
Purpose: append-only trail for every sensitive `SECURITY DEFINER` action (admin moderation
decisions, promotion approvals, account deletions, role changes).

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `actor_id` | uuid | YES | FK → `"user".id`, `on delete set null` (admin/user who performed the action) |
| `action` | text | NO | e.g. `'moderate_promotion'`, `'delete_account'`, `'assign_role'` |
| `target_table` | text | NO | |
| `target_id` | uuid | YES | |
| `details` | jsonb | YES | before/after or extra context |

Indexes: `actor_id`, `action`, `created_at desc`.
RLS intent: SELECT admin-only. INSERT only via the `SECURITY DEFINER` functions themselves
(no direct client/authenticated INSERT policy at all — write path is exclusively server-side
function calls running as the function owner). **This table is new — not in any feature doc —
flagged in `10-open-decisions.md` as a gap the frontend never surfaces (admin-only, no UI impact).**

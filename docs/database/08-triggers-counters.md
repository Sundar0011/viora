# Database Design — Triggers, Denormalized Counters & Scalability

> Part of `docs/database-design.md`. DESIGN ONLY — not applied.

## 1. Denormalized counters — recommended DB triggers
Every counter below is currently maintained by an **explicit client RPC call after each mutation**
(per the feature docs). This drifts if the client fails mid-flow (network drop between the DML
and the counter RPC). Recommendation: move every one of these to a DB trigger on the table that
actually changes, so the counter is self-healing and atomic with the mutation — the existing RPCs
can stay as thin wrappers (or be removed) once triggers own the counter.

| Counter | Lives on | Source table (trigger AFTER INSERT/DELETE/UPDATE) | Replaces RPC |
|---|---|---|---|
| `post.likes_count` | `post` | `post_like` | `add_like` (keep as the toggle RPC; trigger just recomputes) |
| `post.comment_count` | `post` | `post_comment` (top-level + replies both count, per feature doc §5) | `count_comment` |
| `post.share_count` | `post` | `post_share` | `update_post_share_count` (keep for the insert side) |
| `post_comment.likes_count` | `post_comment` | `post_comment_likes` | `add_comment_like` (keep as toggle; trigger recomputes) |
| `post_comment.replies_count` | `post_comment` (parent row) | `post_comment` (INSERT/DELETE where `parent_comment_id` is set) | `count_likes(p_type='reply')` |
| `"group".total_members` | `"group"` | `group_members` | `update_total_group_members` |
| `public_user_profile.post_count` | `public_user_profile` | `post` (per `user_id`) | `update_user_profile_counts(option:'post')` |
| `public_user_profile.group_count` | `public_user_profile` | `group_members` (per `user_id`) | `update_user_profile_counts(option:'group')` / `update_user_group_count` |
| `public_user_profile.event_count` | `public_user_profile` | `event_page` (per `admin_user`) | `update_user_profile_counts(option:'event')` |
| `public_user_profile.sale_count` | `public_user_profile` | `sale` (per `created_by`) | `update_user_profile_counts(option:'sale')` / `update_sale_count` |
| `public_user_profile.followers` / `.following` | `public_user_profile` (both sides) | `follows` | folded into `user_follow` RPC (keep RPC as the mutation entry point; trigger keeps counters correct even if the RPC's own bookkeeping has a bug) |
| `event_page.attendee_count` | `event_page` | `event_attending` (`is_attending=true` rows) | `update_event_attendee_count` |
| `sale` listing counts | n/a (no listing-level counter beyond profile `sale_count`) | — | — |
| `business_contacted` count | derived (no stored counter column — `get_contact_count` counts rows/distinct users, semantics TBD, see Open Decisions) | — | `get_contact_count` stays a read-time COUNT(*) |

Every trigger function: `SECURITY DEFINER` is **not** required for these (they only touch the
counter column on a row the trigger is already firing for); prefer `SECURITY INVOKER` triggers
that run as the table owner implicitly (trigger functions execute with the privileges of the
table owner by default regardless of INVOKER/DEFINER on the function itself — still `SET
search_path = public, pg_temp` for safety).

## 2. `updated_at` maintenance
Add a single generic `public.set_updated_at()` trigger function (`BEFORE UPDATE`, sets
`NEW.updated_at = now()`), attached to every table that has an `updated_at` column: `"user"`,
`public_user_profile`, `post`, `"group"`.

## 3. Pagination strategy
- **Feed (`post`), notifications (`notifications`), chat thread (`messages`), search history:**
  use **keyset pagination** (cursor on `(created_at, id)` or `(chat_id, created_at, id)`), not
  `OFFSET`/`LIMIT`. All of these are high-churn, frequently-inserted-at-the-top lists where offset
  pagination skips/duplicates rows as new rows arrive between page fetches, and gets slower as the
  offset grows.
- **Small/bounded lists** (group members, event attendees, followers/following, business pages):
  offset pagination is acceptable — bounded cardinality, no high insert churn during a single
  browsing session.
- RPCs that currently return an entire array in one call (`get_visible_posts`,
  `get_notifications`, `get_chat`) should be re-specified during RPC implementation to accept a
  cursor param (`p_after_created_at`, `p_after_id`) — this is a **behavior change from the current
  frontend contract** (which calls with no pagination args) and must be confirmed with
  frontend-dev before the RPC signature changes, since the frontend is locked (CLAUDE.md §2).
  Flagged in `10-open-decisions.md`.

## 4. High-volume tables — indexing & partitioning
- **`messages`**: highest expected write rate (every chat send). Composite index `(chat_id,
  created_at)` is mandatory from day one. Once volume justifies it (millions of rows / measurable
  query slowdown), range-partition by `created_at` (monthly). Do not partition prematurely —
  Postgres partitioning adds operational complexity (constraint exclusion, FK limitations across
  partitions) that isn't worth it at launch volume.
- **`notifications`**: second-highest write rate (every like/comment/follow/invite fan-out
  potentially inserts one row per recipient). Same treatment: `(receiver_id, created_at desc)`
  index now, monthly partitioning later if volume demands it.
- **`post`**: moderate write rate, high read rate (feed). Composite `(is_deleted, post_status,
  created_at desc)` is the primary feed-serving index (no `community_id` in the composite — no
  community scoping); no partitioning needed at expected Viora scale (single app, not global
  social-network scale).
- **`post_like` / `post_comment_likes` / `post_comment`**: moderate-to-high write rate under a
  popular post; the unique constraints double as the hot lookup indexes.

## 5. Realtime vs. counters
Where a trigger already recomputes a counter, that same trigger's `AFTER` block is also the
natural place to `perform realtime.broadcast_changes(...)` (or an equivalent Broadcast emit) to
the relevant private channel (e.g. `post:{post_id}` for likes/comments, `chat:{chat_id}` for
messages, `notifications:{receiver_id}` for new notifications) — this keeps the "maintain the
counter" and "notify subscribers" concerns colocated per mutation instead of duplicated across
every calling RPC. See each feature's Realtime section in `docs/features/*.md` for the specific
topic naming already recommended there.

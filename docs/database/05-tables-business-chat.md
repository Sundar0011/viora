# Database Design — Business Pages, Promotions & Chat Tables

> Part of `docs/database-design.md`. DESIGN ONLY — not applied. Source: `docs/features/
> 08-business-promotions.md`, `10-chat-messaging.md`.
>
> `community_id` columns below are **vestigial compat columns** (Decision: Remove Community
> Concept, `10-open-decisions.md`) — no community feature, no FK, `DEFAULT 1`, kept only because
> the locked frontend Row class sends/filters them (CLAUDE.md §2). Not used in RLS/scoping.

## Business

### `business_page`
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `community_id` | int8 | YES | vestigial compat column (see header note). Default `1`. **No FK.** |
| `admin_user` | uuid | NO | FK → `"user".id` (**page owner**, not a platform admin — do not confuse with `is_admin()`) |
| `name` | text | NO | |
| `bio` | text | NO | |
| `profile_picture` | text | YES | bucket `business-image` |
| `cover_image` | text | YES | bucket `business-image` |
| `services` | text[] | NO | |
| `website_link` | text | NO | |
| `email` | text | NO | |
| `phonenumber` | text | NO | |
| `is_deleted` | bool | NO | default `false` |
| `business_status` | `lifecycle_status` enum | NO | default `'active'` (insert path omits it today — DB default closes the gap) |

PK: `id`. FKs: `admin_user → "user".id on delete restrict`. `community_id` has no FK (vestigial).
Indexes: `admin_user`, `is_deleted`, `business_status`.
RLS intent: SELECT active/non-deleted pages, app-wide (no community boundary); owner sees own
regardless of state. INSERT/UPDATE/DELETE: owner-only via `create_business`/`update_business`/
`delete_business`/`restore_business` RPCs (no direct client DML — payments/moderation-adjacent,
strict per CLAUDE.md §6). **Restore must be owner-scoped** (`admin_user = auth.uid()`) — the
current frontend restore has no owner check (flagged gap, see Open Decisions).

### `business_promote`
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `community_id` | int8 | YES | vestigial compat column (see header note). Default `1`. **No FK.** |
| `business_page_id` | uuid | NO | FK → `business_page.id` |
| `business_promote_plans` | int8 | NO | FK → `business_promote_plans.id` |
| `reference_number` | int8 | NO | payment reference (int8 per frontend; confirm vs text overflow risk, Open Decisions) |
| `receipt` | text | YES | bucket `promote-receipts` (**private**) |
| `status` | text | NO | default `'under review'`; observed set: under review / live / ended / rejected / mismatch — kept `text` pending full confirmation |
| `plan_start_date` | timestamptz | YES | admin-set |
| `plan_end_date` | timestamptz | YES | admin-set |
| `admin_user` | uuid | NO | FK → `"user".id` (submitter/owner, not platform admin) |

PK: `id`. FKs: `business_page_id → business_page.id on delete cascade`; `business_promote_plans →
business_promote_plans.id on delete restrict`; `admin_user → "user".id on delete restrict`.
`community_id` has no FK (vestigial).
Indexes: `business_page_id`, `business_promote_plans`, `admin_user`, `status`; composite
`(business_page_id, admin_user)`.
RLS intent: SELECT owner + platform admin only. INSERT/UPDATE (submit/resubmit): owner only via
`submit_promotion`/`resubmit_promotion` RPCs — client must never set `status='live'`,
`plan_start_date`, `plan_end_date`, or another user's `reference_number`/receipt.
**Admin-only** transitions (`live`/`ended`/`rejected`/`mismatch` + dates) via
`moderate_promotion` RPC gated by `is_admin()`, audited to `audit_log`.

### `business_promote_plans` (admin-managed catalog)
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | int8 | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `community_id` | int8 | YES | vestigial compat column (see header note). Default `1`. **No FK.** Plans are global, not community-scoped. |
| `days_count` | int8 | NO | |
| `price` | numeric | NO | |
| `currency` | text | NO | |
| `image_url` | text | YES | |

Indexes: `price`.
RLS intent: SELECT `authenticated`; INSERT/UPDATE/DELETE admin-only.

### `business_contacted`
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `community_id` | int8 | YES | vestigial compat column (see header note). Default `1`. **No FK.** |
| `business_page_id` | uuid | NO | FK → `business_page.id` |
| `contacted_user` | uuid | NO | FK → `"user".id` |
| `last_contact_link` | text[] | NO | appended channels (`phone`/`email`) |

PK: `id`. FKs: `business_page_id → business_page.id on delete cascade`; `contacted_user →
"user".id on delete cascade`. `community_id` has no FK (vestigial).
Indexes: `business_page_id`, `contacted_user`; **unique `(business_page_id, contacted_user)`**
(one row per user, channels appended — see Open Decisions for the alternative "one row per tap"
semantics).
RLS intent: INSERT/UPDATE via `update_contacted` RPC only. SELECT: business owner (for counts) or
admin; count exposed via `get_contact_count` RPC.

## Chat & Messaging

### `chat`
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `community_id` | int8 | YES | vestigial compat column (see header note). Default `1`. **No FK.** |
| `last_message` | text | YES | denormalized preview |
| `last_message_date` | timestamptz | YES | |
| `first_message_date` | timestamptz | YES | |
| `last_message_user` | uuid | YES | FK → `"user".id` |
| `is_blocked` | bool | YES | default `false` |
| `blocked_by_user` | uuid | YES | FK → `"user".id` |
| `created_by` | uuid | NO | FK → `"user".id` |
| `chat_type` | text | NO | `'dm'` confirmed; `'sale'`/`'forsale'` exact value unconfirmed (Open Decisions) |

PK: `id`. FKs: `created_by → "user".id on delete restrict`; `last_message_user`,
`blocked_by_user → "user".id on delete set null`. `community_id` has no FK (vestigial).
Indexes: `created_by`, `chat_type`, `last_message_date`, `last_message_user`.
RLS intent: SELECT/UPDATE only chat members (`chat_users` where `user_id = auth.uid()` and
`is_deleted=false`). Writes admin-only by default; user mutations via `find_common_chat`/
`add_chat_users` RPCs. Preview-field updates (`last_message*`) move to a trigger, not client
`.update`.

### `chat_users`
| Column | Type | Null | Notes |
|---|---|---|---|
| `chat_id` | uuid | NO | FK → `chat.id`, part of composite PK |
| `user_id` | uuid | NO | FK → `"user".id`, part of composite PK |
| `community_id` | int8 | YES | vestigial compat column (see header note). Default `1`. **No FK.** |
| `created_at` | timestamptz | NO | default `now()` |
| `is_deleted` | bool | YES | default `false` |
| `deleted_date` | timestamptz | YES | |

PK: composite `(chat_id, user_id)` (Row class exposes no separate `id` — confirmed design choice,
see Open Decisions for the risk this carries if the frontend ever expects a single `id`).
FKs: `chat_id → chat.id on delete cascade`; `user_id → "user".id on delete cascade`.
`community_id` has no FK (vestigial).
Indexes: `chat_id`, `user_id`; composite `(user_id, is_deleted)`.
RLS intent: SELECT only the row's own `user_id` or fellow chat members (for membership checks).
INSERT via `add_chat_users` RPC (adds both participants). UPDATE (`is_deleted`) via
`soft_delete_chat_users`/`restore_chat_user` RPCs, scoped to the caller's own membership only.

### `messages`
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `chat_id` | uuid | NO | FK → `chat.id` |
| `community_id` | int8 | YES | vestigial compat column (see header note). Default `1`. **No FK.** |
| `sender_id` | uuid | NO | FK → `"user".id` |
| `message` | text | NO | body; `'image'` placeholder for image messages |
| `created_at` | timestamptz | NO | default `now()` |
| `e_message_type` | `e_message_type` enum | NO | `text`/`image` |
| `is_read` | bool | NO | default `false` |
| `file_url` | text | YES | |
| `file_type` | text | YES | |
| `islink` | bool | NO | default `false` |

PK: `id`. FKs: `chat_id → chat.id on delete cascade`; `sender_id → "user".id on delete cascade`.
`community_id` has no FK (vestigial).
Indexes: `(chat_id, created_at)` (thread fetch — also the keyset-pagination cursor, see
`08-triggers-counters.md`); `(chat_id, sender_id, is_read)` (mark-as-read/unread counts);
`sender_id`.
RLS intent: SELECT only chat members. INSERT: `sender_id = auth.uid()` AND caller is a member —
either a strict INSERT policy or a `send_message` RPC (recommended, so the `chat` preview-field
trigger and any push/broadcast fire atomically). UPDATE (`is_read`): only members, only rows where
`sender_id != auth.uid()`.

**High-volume table note:** `messages` is the highest-write-volume table in the schema (every
send). Recommend range-partitioning by `created_at` (monthly) once volume justifies it, and always
paginate the thread with a **keyset cursor** on `(chat_id, created_at, id)` rather than
`OFFSET`/`LIMIT` — see `08-triggers-counters.md` §3.

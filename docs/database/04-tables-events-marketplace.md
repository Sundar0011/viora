# Database Design — Events & Marketplace Tables

> Part of `docs/database-design.md`. DESIGN ONLY — not applied. Source: `docs/features/
> 06-events.md`, `07-marketplace-sale.md`.

## Events

### `event_page`
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `community_id` | int8 | YES | vestigial compat column — no community feature; retained only because the locked frontend Row class sends/filters it (CLAUDE.md §2). Default `1`. **No FK.** Not used in RLS/scoping. |
| `admin_user` | uuid | NO | FK → `"user".id` (owner/creator) |
| `name` | text | NO | |
| `event_type` | `event_type` enum | NO | `'Online'`/`'Offline'` |
| `cover_image` | text | NO | default `''`, updated after upload |
| `video_call_link` | text | YES | |
| `location` | `geography(Point,4326)` | YES | written by `update_event_location` RPC only |
| `start_date_time` | timestamptz | NO | |
| `end_date_time` | timestamptz | YES | = start if no end chosen |
| `description` | text | NO | |
| `is_deleted` | bool | YES | default `false` |
| `attendee_count` | int4 | NO | default `0`; trigger-maintained |
| `Address` | text | YES | **quirk: capital "A", kept verbatim** |
| `latitude` | float8 | YES | |
| `logitude` | float8 | YES | **quirk: misspelled "logitude" (not longitude), kept verbatim** |
| `event_status` | `lifecycle_status` enum | NO | default `'active'` (frontend insert omits it — DB default fixes Open Question #1 in the feature doc) |

PK: `id`. FKs: `admin_user → "user".id on delete restrict` (an event should not vanish via cascade
if the creator's account is later deleted — soft-delete the event explicitly instead).
`community_id` has no FK (vestigial, see `03-tables-community-groups.md`).
Indexes: `admin_user`, `is_deleted`, `end_date_time`, `created_at`, `event_status`; composite
`(is_deleted, end_date_time)`; `(is_deleted, end_date_time, created_at)`; **GiST** on `location`
(`community_id` dropped from all composites — no community scoping).
RLS intent: SELECT any authenticated user, excluding `is_deleted=true` (app-wide, no community
boundary). INSERT/UPDATE/DELETE: only `admin_user` (owner) or platform admin, via `create_event`/
`update_event`/`delete_event` RPCs (frontend currently direct DML — CLAUDE.md §6 gap, see Open
Decisions).

### `event_attending`
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `community_id` | int8 | YES | vestigial compat column — no community feature; retained only because the locked frontend Row class sends/filters it (CLAUDE.md §2). Default `1`. **No FK.** Not used in RLS/scoping. |
| `event_id` | uuid | NO | FK → `event_page.id` |
| `attending_id` | uuid | NO | FK → `"user".id` |
| `is_invited` | bool | NO | default `false` |
| `invited_by` | uuid | YES | FK → `"user".id` |
| `is_attending` | bool | YES | default `false` |
| `end_date_time` | timestamptz | YES | copied from event on invite |
| `is_group_deleted` | bool | YES | default `false`; set `true` when parent event soft-deletes |

PK: `id`. FKs: `event_id → event_page.id on delete cascade`; `attending_id → "user".id on delete
cascade`; `invited_by → "user".id on delete set null`. `community_id` has no FK (vestigial, see
above).
Indexes: `event_id`, `attending_id`, `invited_by`; composite `(attending_id,
is_invited, is_attending, end_date_time, is_group_deleted)`; **unique `(event_id, attending_id)`**
(closes the duplicate-attendee-row gap flagged in the feature doc §8.6).
RLS intent: SELECT the attendee, the inviter, or the event owner. INSERT/UPDATE: the acting user
for their own RSVP row; invites via `invite_user_to_event` RPC only.

## Marketplace / Sale

### `sale`
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `community_id` | int8 | YES | vestigial compat column — no community feature; retained only because the locked frontend Row class sends/filters it (CLAUDE.md §2). Default `1`. **No FK.** Not used in RLS/scoping. |
| `title` | text | NO | |
| `description` | text | NO | |
| `sale_category` | text | NO | **stores the category name, not an id** (kept per frontend contract — see Open Decisions) |
| `e_price_type` | `e_price_type` enum | NO | `'Free'`/`'Fixed'` |
| `price` | int8 | YES | null when Free |
| `location` | text | NO | human-readable place |
| `e_sale_type` | `e_sale_type` enum | NO | default `'selling'` |
| `created_by` | uuid | NO | FK → `"user".id` |
| `location_point` | `geography(Point,4326)` | NO | built server-side from lat/lng in `insert_sales_details` |
| `city` | text | NO | |
| `isdeleted` | bool | NO | default `false`; **quirk: no underscore, kept verbatim** |
| `latitude` | float8 | YES | |
| `longitude` | float8 | YES | |

PK: `id`. FKs: `created_by → "user".id on delete restrict` (soft-delete the listing rather than
cascade-losing it on account deletion). `community_id` has no FK (vestigial, see
`03-tables-community-groups.md`).
Indexes: `created_by`, `sale_category`, `e_sale_type`, `isdeleted`, `created_at`; **GiST** on
`location_point` (`community_id` dropped — no community scoping).
RLS intent: SELECT any authenticated user; hide `isdeleted=true` (app-wide, no community
boundary). Writes via `insert_sales_details`/`update_sale_without_image` RPCs; owner-only
delete/sold/undo, scoped to `created_by = auth.uid()` — see Open Decisions for the RPC-vs-RLS
choice.

### `sale_category` (lookup)
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `community_id` | int8 | YES | vestigial compat column — no community feature; retained only because the locked frontend Row class sends/filters it (CLAUDE.md §2). Default `1`. **No FK.** Not used in RLS/scoping (categories are global, not community-scoped). |
| `name` | text | YES | referenced by `sale.sale_category` (by string value, no FK constraint) |

Indexes: `name`.
RLS intent: SELECT `authenticated`; writes admin-only.

### `sale_images`
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `community_id` | int8 | YES | vestigial compat column — no community feature; retained only because the locked frontend Row class sends/filters it (CLAUDE.md §2). Default `1`. **No FK.** Not used in RLS/scoping. |
| `sale_id` | uuid | NO | FK → `sale.id` |
| `user_id` | uuid | YES | FK → uploader |
| `image` | text | YES | public URL, bucket `sales-images` |

PK: `id`. FKs: `sale_id → sale.id on delete cascade`; `user_id → "user".id on delete set null`.
`community_id` has no FK (vestigial, see above).
Indexes: `sale_id`, `user_id`.
RLS intent: SELECT follows `sale` visibility; INSERT/DELETE owner-only (`sale.created_by =
auth.uid()`), preferably via RPC alongside the storage upload.

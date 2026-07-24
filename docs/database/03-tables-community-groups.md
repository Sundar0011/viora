# Database Design — Follows & Groups Tables

> Part of `docs/database-design.md`. DESIGN ONLY — not applied. Source: `docs/features/
> 04-community-neighborhoods.md`, `05-groups.md`.

## Decision: Remove Community Concept (RESOLVED — see `10-open-decisions.md`)
The `community` table and every community-scoped access-control rule have been **removed from
this design.** There is no multi/single-community logic anywhere in RLS, RPC scoping, or FK
relationships. The physical `community_id` column is **kept only on tables whose frontend Row
class actually sends/filters it** (per `grep` of `lib/backend/supabase/database/tables/*.dart`),
redefined everywhere as a **vestigial compat column**: plain `int8`, `DEFAULT 1`, nullable, **no
FK**, never referenced by RLS or RPC WHERE-clause scoping. It exists only because the locked
FlutterFlow frontend (CLAUDE.md §2) still inserts/filters on it (hardcoded `= 1`). Every table
below that has this column is annotated accordingly.

### `follows`
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK, default `gen_random_uuid()` |
| `created_at` | timestamptz | NO | default `now()` |
| `community_id` | int8 | YES | vestigial compat column — no community feature; retained only because the locked frontend Row class sends/filters it (CLAUDE.md §2). Default `1`. **No FK.** Not used in RLS/scoping. |
| `follower_id` | uuid | NO | FK → `"user".id` |
| `following_id` | uuid | NO | FK → `"user".id` |

PK: `id`. FKs: `follower_id → "user".id on delete cascade`; `following_id → "user".id on delete
cascade`. `community_id` has no FK (vestigial, see above).
Indexes: `follower_id`, `following_id`; **unique `(follower_id, following_id)`** (community_id
dropped from the uniqueness key and from composite indexes — it carries no business meaning now).
RLS intent: SELECT where `follower_id = auth.uid()` OR `following_id = auth.uid()`. **No direct
client INSERT/DELETE** — mutate only through `user_follow` RPC (toggle: insert if absent, delete
if present; enforces `follower_id = auth.uid()`, blocks self-follow, respects `blocks`). RPC still
accepts `p_communityid` from the locked frontend call signature but does not use it for scoping —
see `09-rpc-inventory.md`.

## Groups

### `"group"`
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `community_id` | int8 | YES | vestigial compat column — no community feature; retained only because the locked frontend Row class sends/filters it (CLAUDE.md §2). Default `1`. **No FK.** Not used in RLS/scoping. |
| `created_by` | uuid | NO | FK → `"user".id` |
| `profile_picture` | text | YES | default `squadd/default_group_image/...` |
| `name` | text | NO | |
| `description` | text | YES | |
| `e_group_type` | `e_group_type` enum | NO | `open`/`private` |
| `e_discoverability` | text | NO | radio value — full set unconfirmed (Open Decisions), kept `text` |
| `updated_at` | timestamptz | YES | set on create/edit |
| `total_members` | int8 | NO | default `1`; trigger-maintained on `group_members` |
| `location` | text | NO | radio value |
| `isdeleted` | bool | NO | default `false`; **quirk: no underscore, kept verbatim** |
| `status` | `lifecycle_status` enum | NO | default `'active'` |

PK: `id`. FKs: `created_by → "user".id on delete restrict` (a group should not vanish because its
creator's row FK-cascades — soft-delete the group explicitly instead; confirm behavior with
product). `community_id` has no FK (vestigial, see above).
Indexes: `created_by`; composite `(isdeleted, status)` (community_id dropped from the composite —
it no longer scopes discovery).
RLS intent: SELECT by any authenticated user where `isdeleted=false` and `status='active'`
(app-wide discovery — there is no community boundary; private groups are listed, membership gates
content not existence). INSERT: authenticated, `created_by` forced to `auth.uid()`. UPDATE: group
admins (`group_admin` row) or `created_by` only; soft-delete restricted to admins. DELETE: none.

### `group_admin`
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `community_id` | int8 | YES | vestigial compat column — no community feature; retained only because the locked frontend Row class sends/filters it (CLAUDE.md §2). Default `1`. **No FK.** Not used in RLS/scoping. |
| `group_id` | uuid | NO | FK → `"group".id` |
| `user_id` | uuid | NO | FK → `"user".id` |
| `e_group_role` | text | NO | only `'admin'` observed; kept `text` + CHECK `= 'admin'` until more roles confirmed |

PK: `id`. FKs: `group_id → "group".id on delete cascade`; `user_id → "user".id on delete cascade`.
`community_id` has no FK (vestigial, see above).
Indexes: `group_id`, `user_id`; unique `(group_id, user_id)`.
RLS intent: SELECT group members. INSERT/DELETE admin-only, via `assign_group_admin` /
`delete_group_admin` RPCs which must block removing the group's last admin.

### `group_members`
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `community_id` | int8 | YES | vestigial compat column — no community feature; retained only because the locked frontend Row class sends/filters it (CLAUDE.md §2). Default `1`. **No FK.** Not used in RLS/scoping. |
| `user_id` | uuid | NO | FK → `"user".id` |
| `group_id` | uuid | NO | FK → `"group".id` |
| `is_requested` | bool | YES | |
| `requested_date` | timestamptz | YES | |
| `is_approved` | bool | YES | |
| `approved_by` | uuid | YES | FK → `"user".id` |
| `joined_at` | timestamptz | YES | |

PK: `id`. FKs: `group_id → "group".id on delete cascade`; `user_id → "user".id on delete cascade`;
`approved_by → "user".id on delete set null`. `community_id` has no FK (vestigial, see above).
Indexes: `group_id`, `user_id`; unique `(group_id, user_id)`.
RLS intent: SELECT members of the group; admins see all (incl. pending). INSERT/UPDATE/DELETE via
RPC only: `join_open_group` (self-join, open groups), `approve_join_request` (admin-only),
`leave_group` (self only).

### `group_members_invite`
| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `community_id` | int8 | YES | vestigial compat column — no community feature; retained only because the locked frontend Row class sends/filters it (CLAUDE.md §2). Default `1`. **No FK.** Not used in RLS/scoping. |
| `invited_by` | uuid | NO | FK → `"user".id` |
| `group_id` | uuid | NO | FK → `"group".id` |
| `invited_user` | uuid | NO | FK → `"user".id` |
| `is_member` | bool | NO | default `false` |
| `accepted_at` | timestamptz | YES | |

PK: `id`. FKs: `group_id → "group".id on delete cascade`; `invited_by`, `invited_user → "user".id
on delete cascade`. `community_id` has no FK (vestigial, see above).
Indexes: `group_id`, `invited_user`, `invited_by`.
RLS intent: SELECT invitee, inviter, group admins. INSERT via `invite_user_to_group` RPC
(`invited_by = auth.uid()`). UPDATE via `accept_group_invite` RPC (invitee) or admin.

### `group_user_status`
Purpose: per-user membership state machine (drives Join/Request/Invite/Member button).

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `community_id` | int8 | YES | vestigial compat column — no community feature; retained only because the locked frontend Row class sends/filters it (CLAUDE.md §2). Default `1`. **No FK.** Not used in RLS/scoping. |
| `user_id` | uuid | NO | FK → `"user".id` |
| `group_id` | uuid | NO | FK → `"group".id` |
| `is_requested` | bool | YES | |
| `is_invited` | bool | YES | |
| `is_approved` | bool | YES | |
| `is_member` | bool | YES | |
| `invited_by` | uuid | YES | FK → `"user".id` |
| `approved_by` | uuid | YES | FK → `"user".id` |
| `requested_date` | timestamptz | YES | |
| `invited_date` | timestamptz | YES | |
| `joined_at` | timestamptz | YES | |

PK: `id`. FKs: `group_id → "group".id on delete cascade`; `user_id`, `invited_by`, `approved_by →
"user".id on delete cascade`/`set null` (self `set null` for invited_by/approved_by so history
survives inviter deletion). `community_id` has no FK (vestigial, see above).
Indexes: unique `(group_id, user_id)`; `group_id`, `user_id`.
RLS intent: SELECT own row + group admins. INSERT/UPDATE/DELETE only via the state-machine RPCs
(`request_join_group`, `invite_user_to_group`, `accept_group_invite`, `approve_join_request`,
`leave_group`) — users mutate only their own status row; approvals admin-only.

### `blocks` (shared with Profile & Moderation features)
See `docs/database/06-tables-notifications-search-moderation.md` for the canonical definition —
Groups reuses the same table for block/unblock-in-group.

## Frontend reconciliation note
The frontend still ships a `CommunityTable`/`CommunityRow` Dart class
(`lib/backend/supabase/database/tables/community.dart`) bound to a `community` table. Since the
frontend is locked and must not be edited (CLAUDE.md §2), this Dart class is left in place but the
backend **does not create a `community` table** — nothing in the reviewed feature docs shows the
frontend actually querying/reading from `CommunityTable` at runtime (it is not used for scoping
by any RPC or query in the inventory). If a future audit finds a live call site that queries
`community` directly, surface it as a new decision before adding the table back.

# Database Design — Auth & Identity Tables

> Part of `docs/database-design.md` (index). DESIGN ONLY — not applied. Source: `docs/features/
> 01-auth-registration.md`, `09-profile-account.md`.

## Naming decision (OPEN — see `10-open-decisions.md` §1 for full writeup)
The user's split request (`user_main` = private core, `public_user` = public profile) maps onto
the frontend's **already-bound** table names:
- `user_main` → **`"user"`** (frontend table name, PascalCase-free but needs quoting — see index §1).
- `public_user` → **`public_user_profile`** (frontend table name).
- `user_roles` → **`user_roles`** (name already matches).

**Recommendation: keep the frontend's actual names** (`user`, `public_user_profile`,
`user_roles`). Renaming would require editing every FlutterFlow-generated Row class / table
binding under `lib/backend/supabase/database/tables/` and every call site — high risk for a
frontend that CLAUDE.md §2/§6 says is locked and must not be restructured. Columns and FKs are
identical either way; only the table identifier changes. **Left OPEN for user decision.**

---

### `"user"` (= user_main — private core identity)
Purpose: private/PII account record, 1:1 with `auth.users`.

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK, `references auth.users(id) on delete cascade` |
| `created_at` | timestamptz | NO | default `now()` |
| `first_name` | text | YES | |
| `last_name` | text | YES | |
| `email` | text | YES | |
| `mobile_number` | text | YES | national number, no CC |
| `mobile_number_cc` | text | YES | `"{cc}{mobile}"` |
| `address` | text | YES | |
| `city` | text | YES | |
| `flat` | text | YES | |
| `postal_code` | text | YES | |
| `blocked` | bool | YES | admin/moderation flag |
| `onboarding_completed` | bool | YES | default `false` |
| `is_deleted` | bool | YES | default `false`; soft-delete |
| `reason` | text | YES | delete/hibernate reason |
| `IsOwner` | bool | YES | **quirk: PascalCase column name, kept verbatim** (flagged in Open Decisions) |
| `last_signin_at` | timestamptz | YES | |
| `status` | text | YES | lifecycle text; only `'removed'` confirmed — full enum unconfirmed, kept `text` (see Open Decisions) |
| `updated_at` | timestamptz | YES | maintained by trigger — frontend updates this row |

PK: `id`. FK: `id → auth.users.id on delete cascade`.
Indexes: `email`, `mobile_number_cc` (lookup/uniqueness candidates — not unique per feature doc,
duplicates possible pre-launch; flag for product confirmation), `is_deleted`.
RLS intent (Decision: Identity RLS, `10-open-decisions.md`): **owner-only, no exceptions.** SELECT
and UPDATE gated by `id = (SELECT auth.uid())` — a user may read/update ONLY their own row. No
cross-user SELECT of this table at all (not even a "same community" carve-out — there is no
community concept, see Decision: Remove Community Concept). INSERT only via the `signup_finalize`
RPC. Admins do not get a blanket bypass here either unless a specific admin moderation RPC needs
it (`SECURITY DEFINER`, validated) — this table is PII and stays the narrowest-possible surface.
Public/other-user profile reads go to `public_user_profile` instead (see below).

### `user_roles`
Purpose: exactly one role per user, source of the JWT `app_metadata.role` claim.

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK, = `"user".id` (1:1, not a separate identity) |
| `created_at` | timestamptz | NO | default `now()` |
| `role` | `app_role` enum | NO | default `'user'`; only `'user'`/`'admin'` per requirement |
| `community_id` | int8 | YES | vestigial compat column — no community feature; retained only because the locked frontend Row class sends/filters it (CLAUDE.md §2). Default `1`. **No FK.** Not used in RLS/scoping (see Decision: Remove Community Concept, `10-open-decisions.md`). |

PK: `id`. FK: `id → "user".id on delete cascade`. `community_id` has no FK (vestigial, see above).
Indexes: `role`. (`community_id` no longer indexed — not used for filtering.)
RLS intent: SELECT own row + admin. INSERT/UPDATE/DELETE **admin-only / RPC-only** — this is the
JWT role source, never client-writable. `signup_finalize` RPC inserts with `role='user'` always,
ignoring any client-sent value (see index §4).

### `public_user_profile` (= public_user)
Purpose: publicly-readable profile + denormalized counters.

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK, = `"user".id` |
| `created_at` | timestamptz | NO | default `now()` |
| `name` | text | YES | `"{first} {last}"` |
| `profile_picture` | text | YES | URL; default `squadd/default_profile/...` |
| `city` | text | YES | |
| `last_seen_date` | timestamptz | YES | presence |
| `community_id` | int8 | YES | vestigial compat column — no community feature; retained only because the locked frontend Row class sends/filters it (CLAUDE.md §2). Default `1`. **No FK.** Not used in RLS/scoping. |
| `country` | text | YES | |
| `followers` | int8 | NO | default `0`; maintained by trigger on `follows` |
| `following` | int8 | NO | default `0`; maintained by trigger on `follows` |
| `logout_time` | time | YES | Postgres `time` |
| `cover_image` | text | YES | URL; default `squadd/default_cover_image/...` |
| `bio` | text | YES | |
| `gender` | text | YES | |
| `pronouns` | text | YES | |
| `post_count` | int8 | NO | default `0`; trigger on `post` |
| `group_count` | int8 | NO | default `0`; trigger on `group_members` |
| `event_count` | int8 | NO | default `0`; trigger on `event_page`/`event_attending` |
| `sale_count` | int8 | NO | default `0`; trigger on `sale` |
| `updated_at` | timestamptz | YES | trigger-maintained |

PK: `id`. FK: `id → "user".id on delete cascade`. `community_id` has no FK (vestigial, see above).
Indexes: `name` (trigram, for search — see `09-rpc-inventory.md`), `is_deleted` lookup via joined
`"user".is_deleted` (no own soft-delete column — confirm in Open Decisions). (`community_id` no
longer indexed — not used for filtering.)
RLS intent (Decision: Identity RLS, `10-open-decisions.md`): SELECT readable by **any
authenticated user** — this table is the app's public-facing profile surface. This is the
**PRIMARY read surface** for profile/display data: most profile and display reads hit
`public_user_profile`, not the private `"user"` table. Exclude rows whose `"user".is_deleted =
true` via a join/predicate. INSERT/UPDATE are owner-only, enforced via RPC / owner-scoped
`WITH CHECK (id = (SELECT auth.uid()))` — counters are RPC/trigger-maintained only, never
client-writable directly.

### `user_login`
Purpose: OTP store / rate-limit ledger. Edge-function-owned, no client access.

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `mobile_no_cc` | text | YES | |
| `email` | text | YES | |
| `otp` | text | NO | |
| `expiry_date` | timestamptz | NO | |
| `no_of_times` | numeric | NO | resend/attempt counter |
| `last_requested_date` | timestamptz | NO | |

PK: `id`. No FKs (identifier-keyed by email/mobile, not by user — pre-signup OTPs have no user yet).
Indexes: `email`, `mobile_no_cc`, `expiry_date` (cron purge).
RLS intent: **deny all** to `anon`/`authenticated`; only the `service_role` (edge functions) reads
or writes this table.

### `user_devices`
Purpose: one row per (user, device) push-token registration.

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK |
| `created_at` | timestamptz | NO | default `now()` |
| `user_id` | uuid | NO | FK → `"user".id` |
| `device_id` | text | NO | Android `androidInfo.id` / iOS `identifierForVendor` |
| `fcm_token` | text | NO | |
| `player_id` | text | YES | **NEW column** — OneSignal player id; the frontend calls
  `upsert_user_device(p_device_id, p_player_id)` but the Row class has no such column today (gap
  flagged in `docs/features/11-notifications.md` §8). Added here to close the gap; confirm with
  product before applying. |

PK: `id`. FK: `user_id → "user".id on delete cascade`.
Indexes: `user_id`; **unique `(user_id, device_id)`** (upsert target for both FCM + OneSignal RPCs).
RLS intent: SELECT/UPSERT own rows only, via `upsert_user_device_fcm` / `upsert_user_device` RPCs
only — no direct client DML.

### `user_locations`
Purpose: one saved home-location point per user (nearby/distance features depend on it).

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | uuid | NO | PK. **Also doubles as the owner reference** — RPCs take `p_userid`; feature
  docs could not confirm a separate `user_id` FK column exists. Modeled here as `id = "user".id`
  (one row per user), see Open Decisions for the alternative (`id` uuid PK + separate `user_id`
  FK, supporting multiple saved locations). |
| `created_at` | timestamptz | NO | default `now()` |
| `location` | `geography(Point,4326)` | NO | built server-side from `latitude`/`longitude` by
  `update_user_location` RPC; PostGIS confirmed required (index §2/§7). |
| `place` | text | YES | |
| `name` | text | YES | |
| `latitude` | float8 | YES | |
| `longitude` | float8 | YES | |

PK: `id`. FK (chosen design): `id → "user".id on delete cascade` (one home location per user —
matches every RPC signature and the realtime `id`-keyed subscription).
Indexes: **GiST** on `location` (nearby `ST_DWithin`/`ST_Distance`); btree on `latitude`,
`longitude` not needed once GiST exists.
RLS intent: SELECT own row only — other users' raw coordinates are **never** exposed directly to
clients; nearby lists are computed server-side by `SECURITY DEFINER` RPCs
(`get_followers_nearby`) that return only `distance_km`, never the raw point. Writes only via
`update_user_location` RPC.

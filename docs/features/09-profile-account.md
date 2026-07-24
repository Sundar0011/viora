# Feature: Profile & Account

> Source of truth = the Flutter frontend. This doc records what the backend MUST provide
> for this feature to work. Derived from `lib/` — do not invent behavior the code doesn't show.

## 1. Overview
- **What it is:** The user's identity surface. Covers the user's own profile hub, editing
  personal details / avatar / cover, viewing another user's profile, followers & following
  lists, "follow nearby" neighbours, blocked-users management, account lifecycle
  (verify-via-OTP, hibernate, delete, sign-out), change password, a support page, the user's
  full post list, and inviting neighbours.
- **Why it exists / user value:** Lets a neighbour present themselves, control their account,
  build their social graph (follow/unfollow, block), and manage privacy/lifecycle.
- **Related features:** Auth/onboarding (creates `user` + `public_user_profile` rows),
  Posts (`user_all_post` reads `post`), Groups (following-groups on other profile), Chat
  (DM initiation from other profile), Moderation/Report (block creation via
  `comp_three_dot_block_user` / `comp_block`), Events (invite following users).

## 2. Screens & widgets
| Screen / widget (path under `lib/pages/profile/`) | Purpose | Key actions |
|---|---|---|
| `profile/profile_widget` | Own profile hub / menu | Reads cached identity from `FFAppState`; Sign Out = delete `user_devices` row + `authManager.signOut()`; navigation into all sub-screens |
| `user_profile/user_profile_widget` | Edit own profile (avatar, cover, groups, counts) | Upload avatar→`cover-images`/`profile-images`, update `public_user_profile`, refresh counts via `update_user_profile_counts`, own post count via `post` query |
| `personal_details/personal_details_widget` | Edit name / bio / gender / pronouns | Update `user` (first/last name) + `public_user_profile` (name, bio, gender, pronouns) |
| `other_profile/other_profile_widget` | View another user's profile | Follow toggle (`user_follow` RPC), following-groups (`get_user_following_groups_with_status`), block/report via imported components, DM initiation (`chat`), own post count query |
| `followers/followers_widget` | List of people who follow me | Renders `FFAppState().followers` (JSON from `get_followers`); follow-back state via `follows` |
| `following/following_widget` | List of people I follow | Renders `FFAppState().AsFollowingList` (from `get_following`); follow/unfollow via `user_follow` |
| `comp_followers/comp_followers_widget` | Followers bottom-sheet variant | `follows` single-row lookup for button state |
| `comp_following/comp_following_widget` | Following bottom-sheet variant | Unfollow/follow toggle via `user_follow`; `follows` single-row lookup |
| `comp_follow_nearby/comp_follow_nearby_widget` | Follow neighbours nearby | `get_followers_nearby` RPC list; follow via `user_follow` |
| `blocked_users/blocked_users_widget` | List blocked users | Read `blocks` (blocker_id = me) + `public_user_profile`; Unblock via `CompUnblockUserWidget` |
| `comp_verify/comp_verify_widget` | OTP step for account **deletion** | `SendOtp` → `VerifiOtp`; on success set `user.is_deleted=true, status='removed'` + sign out |
| `comp_comfirm_delete_account/..._widget` | Confirm delete (business context) | Marks `business_page` deleted (business path); user-delete path runs through `comp_verify` |
| `delete_account/delete_account_widget` | Delete-account entry screen | Collects reason, routes into OTP verify flow |
| `hibernate_account/hibernate_account_widget` | Hibernate entry (reason) | Opens `comp_confirm_hibernate` (UI only — see §8) |
| `comp_confirm_hibernate` / `comp_hibernate_wait` | Hibernate confirm / wait | **No backend write found** (UI-only in frontend) |
| `comp_account_deleted` / `comp_account_hibernated` / `switch_profile_deleted` | Post-action info screens | Informational only |
| `change_password/change_password_widget` | Change password from settings | `ChangePassword` Edge Function (`change-password`) |
| `account_settings/account_settings_widget` | Settings menu | Navigation only — **no backend calls** |
| `supportpage/supportpage_widget` | Support / contact | `launchUrl(mailto:)` — no backend |
| `user_all_post/user_all_post_widget` | A user's full post list | Query `post` where `user_id` + `is_deleted=false` ordered by `created_at` |
| `comp_invite_neighbors` / `comp_invit_confirmation` | Invite neighbours | UI-only modal flow — **no backend call found** (see §8) |
| `neighborhoods` / `neighbourhoods_following` / `neighbourhood_explore` | Neighbourhood follow/explore | Community/neighbourhood follow surfaces (borders Community feature) |

## 3. Data model (tables & columns)

### `user` (private, one row per auth user)
- **Purpose:** Private/PII account record. Keyed to `auth.users.id`. Holds contact details,
  onboarding flag, and account lifecycle state.
- **Columns** (types from `UserRow` get/setField):
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid (String) | no | PK; = `auth.users.id` (matched on `currentUserUid`) |
  | `created_at` | timestamptz | no | default `now()` |
  | `first_name` | text | yes | edited in personal_details |
  | `last_name` | text | yes | edited in personal_details |
  | `email` | text | yes | |
  | `mobile_number` | text | yes | |
  | `mobile_number_cc` | text | yes | country code |
  | `address` | text | yes | |
  | `city` | text | yes | |
  | `flat` | text | yes | |
  | `postal_code` | text | yes | |
  | `blocked` | bool | yes | account-level blocked flag (admin/moderation) |
  | `onboarding_completed` | bool | yes | set during onboarding |
  | `is_deleted` | bool | yes | soft-delete; set `true` on account deletion |
  | `reason` | text | yes | deletion/hibernation reason |
  | `IsOwner` | bool | yes | **column name is PascalCase `IsOwner`** (not snake_case) |
  | `last_signin_at` | timestamptz | yes | |
  | `status` | text | yes | lifecycle state; observed value `'removed'` (see enum note §5) |

### `public_user_profile` (public-facing profile, one row per user)
- **Purpose:** Publicly readable profile shown on own/other profile. Denormalised counters.
- **Columns** (from `PublicUserProfileRow`):
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid (String) | no | PK; = `user.id` / `auth.uid()` |
  | `created_at` | timestamptz | no | default `now()` |
  | `name` | text | yes | "First Last"; updated with personal_details |
  | `profile_picture` | text | yes | public URL; default in `squadd/default_profile/...` |
  | `city` | text | yes | |
  | `last_seen_date` | timestamptz | yes | presence |
  | `community_id` | int8 | no | FK → community; NOT NULL |
  | `country` | text | yes | |
  | `followers` | int8 | no | counter (default 0) |
  | `following` | int8 | no | counter (default 0) |
  | `logout_time` | time | yes | Postgres `time` |
  | `cover_image` | text | yes | public URL; default in `squadd/default_cover_image/...` |
  | `bio` | text | yes | |
  | `gender` | text | yes | dropdown value |
  | `pronouns` | text | yes | dropdown value |
  | `post_count` | int8 | no | counter (default 0) |
  | `group_count` | int8 | no | counter (default 0) |
  | `event_count` | int8 | no | counter (default 0) |
  | `sale_count` | int8 | no | counter (default 0) |
- **FKs:** `id` → `user.id` (1:1); `community_id` → community.
- **Indexes needed:** `id` (PK), `community_id`, and any name search (for `get_followers`/`get_following` search).

### `follows`
- **Purpose:** Directed follow edge (follower → following) scoped to a community.
- **Columns** (from `FollowsRow`):
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid (String) | no | PK |
  | `created_at` | timestamptz | no | default `now()` |
  | `community_id` | int8 | no | FK → community |
  | `follower_id` | uuid (String) | no | FK → user (who follows) |
  | `following_id` | uuid (String) | no | FK → user (who is followed) |
- **FKs:** `follower_id` → user.id, `following_id` → user.id, `community_id` → community.
- **Indexes needed:** `follower_id`, `following_id`, `community_id`, and a **unique**
  `(follower_id, following_id)` (toggle relies on at-most-one edge — see §5).

### `blocks`
- **Purpose:** One user blocking another, community-scoped.
- **Columns** (from `BlocksRow`):
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid (String) | no | PK |
  | `created_at` | timestamptz | no | default `now()` |
  | `blocker_id` | uuid (String) | no | FK → user (who blocks) |
  | `blocked_id` | uuid (String) | no | FK → user (who is blocked) |
  | `community_id` | int8 | no | FK → community |
- **FKs:** `blocker_id` → user.id, `blocked_id` → user.id, `community_id` → community.
- **Indexes needed:** `blocker_id`, `blocked_id`, `community_id`, unique `(blocker_id, blocked_id)`.

### `user_locations`
- **Purpose:** Saved locations for a user (used by "follow nearby" / neighbourhood surfaces).
- **Columns** (from `UserLocationsRow`):
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid (String) | no | PK; passed as `id` = user id on insert |
  | `created_at` | timestamptz | no | default `now()` |
  | `location` | text | no | e.g. WKT/geo string |
  | `place` | text | yes | |
  | `name` | text | yes | |
  | `latitude` | float8 | yes | |
  | `longitude` | float8 | yes | |
- **Indexes needed:** whatever geo filter `get_followers_nearby` uses (lat/long or PostGIS index).

### Referenced-but-owned-elsewhere
- `post` (read for post counts / `user_all_post`), `user_devices` (deleted on sign-out),
  `business_page` (business delete path in `comp_comfirm_delete_account`), `chat` (DM init),
  `group_members` / `group_user_status` / `group_members_invite` (group-join actions embedded
  in profile screens — belong to Groups feature).

## 4. Backend calls (API / RPC / Edge)
All REST/RPC hit base `https://wgcqstmmkcdjnnpuvspr.supabase.co` (OLD project — Viora's own
project ref must replace this).

| Call / query | Type | Inputs | Returns | Called from |
|---|---|---|---|---|
| `AddFollowCall` → `rpc/user_follow` | RPC (POST) | `p_communityid` int, `p_followerid` uuid, `p_followingid` uuid; Bearer token | follow result | other_profile, following, comp_following, comp_follow_nearby, user_all_post |
| `get_followers` | RPC (via `supabase.rpc`, custom action) | `search_query` text | list of followers (JSON) | `custom_code/actions/load_followers_real_time.dart` → `FFAppState().followers`, `AsFollowersCount` |
| `get_following` | RPC (custom action) | `search_query` text | list of following (JSON) | `custom_code/actions/load_following_real_time.dart` → `FFAppState().AsFollowingList`, `AsFollowingCount` |
| `GetNeighborhoodPeoplesCall` → `rpc/get_followers_nearby` | RPC (POST) | `p_userid` uuid, `p_communityid` int | nearby people JSON | comp_follow_nearby, other_profile |
| `GetOtherUserFollowingGroupsrCall` → `rpc/get_user_following_groups_with_status` | RPC (POST) | `target_user_id` uuid | groups a user follows + status | other_profile |
| `UpdateUserProfileCountsCall` → `rpc/update_user_profile_counts` | RPC (POST) | `p_option` text (`'group'`, `'sale'`, `'post'`, `'event'`) | updates matching counter on `public_user_profile` | user_profile (options 'group' & 'sale' on load); also create/delete post/event/group/sale flows |
| `PublicUserProfileTable().update(...)` | Direct DML (PostgREST) | avatar/cover/name/bio/gender/pronouns | — | user_profile, personal_details |
| `UserTable().update(...)` | Direct DML | first/last name; or delete flags | — | personal_details, comp_verify |
| `AddUserLocationCall` → `/rest/v1/user_locations` | Direct REST insert | `id` uuid, `location` text | inserted row | (location save; used by nearby surfaces) |
| `ChangePasswordCall` → `functions/v1/change-password` | **Edge Function** (POST) | `old_password`, `new_password`; Bearer token (no apikey header) | success/error | change_password |
| `SendOtpCall` / `VerifiOtpCall` | Edge/REST (auth) | email or `mobileNoCc`, `otp` | verify result | comp_verify (delete flow) |
| `PostTable().queryRows(...)` | Direct DML | `user_id`, `is_deleted=false`, order `created_at` | posts | user_all_post, own/other profile post count |
| `FollowsTable().querySingleRow(...)` | Direct DML | `follower_id`+`following_id` | 0/1 row (follow-button state) | followers, following, comp_followers, comp_following, other_profile, neighbourhood_explore |
| `BlocksTable().queryRows(...)` | Direct DML | `blocker_id = me` | blocked rows | blocked_users |
| `BlocksTable().delete(...)` | Direct DML | `blocker_id`+`blocked_id` | — | `CompUnblockUserWidget` (invoked from blocked_users) |
| `UserDevicesTable().delete(...)` | Direct DML | `user_id`+`device_id` | — | profile_widget (Sign Out) |

## 5. Business rules & flows

### Own vs other profile
- **Own profile** (`profile_widget`, `user_profile_widget`) reads identity mostly from
  `FFAppState` (populated at login) and allows editing avatar/cover/name/bio/gender/pronouns
  and viewing private details. Editable only for `id = auth.uid()`.
- **Other profile** (`other_profile_widget`) reads `public_user_profile` for the target and a
  post count; it must **not** expose private `user` PII. On load it filters `is_deleted`
  (deleted users hidden). Actions: follow/unfollow, block/report, DM.

### Follow / unfollow (toggle + counters)
- A single RPC `user_follow(p_communityid, p_followerid, p_followingid)` is invoked on every
  follow-button tap regardless of current state ⇒ **it must be a toggle**: if a
  `(follower_id, following_id)` edge exists → delete it; else insert it.
- The RPC must keep counters consistent: increment/decrement `public_user_profile.followers`
  (on the followed user) and `.following` (on the follower). UI reads button state with a
  live `follows` single-row lookup, and counts via `get_followers`/`get_following` length.
- Enforce `follower_id = auth.uid()` inside the RPC (never trust caller); block self-follow.

### Followers / following lists
- Loaded by RPCs `get_followers(search_query)` / `get_following(search_query)` returning JSON
  arrays cached into `FFAppState`. `search_query` supports name search. Caller identity comes
  from `auth.uid()` (no user-id arg passed).

### Block / unblock
- **Block creation** happens outside these screens (moderation: `comp_three_dot_block_user` →
  `comp_block`). `blocked_users` screen lists rows where `blocker_id = auth.uid()` joined to
  `public_user_profile`. **Unblock** = `blocks.delete` matching `blocker_id`+`blocked_id`
  (via `CompUnblockUserWidget`). Blocks are community-scoped (`community_id`).

### Account lifecycle states
- **Active:** `is_deleted = false`, `status` normal.
- **Delete (soft):** via `delete_account` → `comp_verify` OTP. On verified OTP:
  `user.update({is_deleted:true, reason:<text>, status:'removed'})` for `id = auth.uid()`,
  then `authManager.signOut()` and route to Splash. `status` uses a `Status` enum
  (`.removed`); confirm full enum set with backend (see §8).
- **Hibernate:** `hibernate_account` → `comp_confirm_hibernate` → `comp_hibernate_wait`.
  **No DB write exists in the frontend** for hibernate (wait screen only `Navigator.pop`).
  Backend behaviour (e.g. a hibernated `status`, hiding profile, reactivation on next login)
  is **undefined in code** — see §8.
- **Verify:** the "verify" component (`comp_verify`) is an **OTP verification step used by the
  delete flow**, not an identity/badge verification. No `verified` column exists on `user` or
  `public_user_profile`.
- **Sign out:** delete this device's `user_devices` row (`user_id`+`device_id`), sign out,
  clear `FFAppState`, reset avatar/cover to defaults.

### Profile edit
- `personal_details`: validates first/last name forms, then updates `user` (first_name,
  last_name) and `public_user_profile` (name = "First Last", bio; gender/pronouns only if set).
- Avatar/cover (`user_profile`): pick media → upload to bucket (`profile-images` for avatar,
  `cover-images` for cover) → if old URL is not the default, delete old file via
  `deleteSupabaseFileFromPublicUrl` → update `public_user_profile.profile_picture`/`cover_image`.
- Counts: `update_user_profile_counts(p_option)` recomputes a counter; called with `'group'`
  and `'sale'` on `user_profile` load, and by post/event/group/sale create/delete flows.

### Change password
- `change-password` Edge Function receives `old_password`+`new_password` with only a Bearer
  token (no apikey). Must verify current password server-side before setting the new one.

### Invite neighbours / support
- Invite (`comp_invite_neighbors` → `comp_invit_confirmation`) is a UI-only modal flow — no
  backend call in code (see §8). Support page opens a `mailto:` link only.

## 6. Realtime / notifications
- **Followers list:** `custom_code/actions/load_followers_real_time.dart` subscribes to a
  **Postgres Changes** channel `followers_subscription` on tables `public.follows` and
  `public.public_user_profile` (event: all); on any change it re-runs `get_followers` and
  updates `FFAppState().followers` + `AsFollowersCount`.
- **Following list:** `load_following_real_time.dart` — channel `following_subscription`, same
  two tables, re-runs `get_following` → `AsFollowingList` + `AsFollowingCount`.
- Note: uses **Postgres Changes**, not Broadcast. Per CLAUDE.md §6 Realtime, reconsider whether
  Broadcast (private + authorized) is preferable during rebuild; if Postgres Changes is kept,
  RLS on `follows`/`public_user_profile` must gate what each client can see.
- No OneSignal/push triggers are wired directly from these profile screens.

## 7. Backend to build (Supabase rebuild checklist)
- [ ] **Tables:** `user`, `public_user_profile`, `follows`, `blocks`, `user_locations` with
      columns/types/nullability per §3. Keep exact column names incl. **`IsOwner`** (PascalCase)
      and `community_id int8 NOT NULL` on `public_user_profile`/`follows`/`blocks`.
- [ ] **FKs + indexes:** FK every id/community column; index `follows(follower_id)`,
      `follows(following_id)`, `blocks(blocker_id)`, `blocks(blocked_id)`, all `community_id`;
      unique `(follower_id, following_id)` and `(blocker_id, blocked_id)`; index
      `public_user_profile(community_id)` and name for search; geo index on `user_locations`.
- [ ] **RLS intent:**
      - `user` (private): SELECT own row only (`id = auth.uid()`) + admin; INSERT/UPDATE/DELETE
        own row via controlled paths or admin. Never expose PII to other users.
      - `public_user_profile`: SELECT allowed to authenticated community members (needed for
        other-profile, followers/following, search); UPDATE only own row (`id = auth.uid()`),
        and counters only via RPC. INSERT admin/onboarding. Exclude `is_deleted`/hibernated
        profiles from other users' reads.
      - `follows`: SELECT for involved users / community; **no direct client INSERT/DELETE** —
        mutate only through `user_follow` RPC.
      - `blocks`: SELECT only `blocker_id = auth.uid()`; INSERT/DELETE own blocks (self as
        blocker) — prefer RPC; community-scoped.
      - `user_locations`: SELECT/INSERT/UPDATE/DELETE own (`id = auth.uid()`).
- [ ] **RPC / functions:**
      - `user_follow(p_communityid, p_followerid, p_followingid)` — SECURITY DEFINER, toggle
        insert/delete, maintain `followers`/`following` counters, enforce
        `p_followerid = auth.uid()`, reject self-follow, respect blocks.
      - `get_followers(search_query)` / `get_following(search_query)` — return list for
        `auth.uid()` with name search; SECURITY INVOKER (respect RLS) preferred.
      - `get_followers_nearby(p_userid, p_communityid)` — nearby people via `user_locations`.
      - `get_user_following_groups_with_status(target_user_id)` — groups + follow status.
      - `update_user_profile_counts(p_option)` — recompute one counter for `auth.uid()`.
      - Account-delete: after OTP verify, set `is_deleted/reason/status` for own row (ideally an
        RPC/Edge that also handles cleanup) rather than raw client UPDATE.
- [ ] **Edge functions:** `change-password` (verify old password, set new; Bearer-only auth);
      OTP send/verify functions backing `SendOtp`/`VerifiOtp` for the delete flow.
- [ ] **Storage buckets:** `profile-images` (avatars), `cover-images` (covers), plus public
      `squadd` bucket holding `default_profile/` and `default_cover_image/` defaults. Policies:
      users write/delete only their own folder; public read for avatar/cover URLs.
- [ ] **Triggers / cron:** consider a trigger to keep `public_user_profile` counters accurate
      if not fully handled in RPCs; a job to hard-purge or anonymise `is_deleted` users.

## 8. Open questions & risks
1. **Hibernate has no backend implementation in the frontend.** The confirm/wait screens do
   not write any state. Define: is there a `status='hibernated'` (or similar), how is the
   profile hidden, and how does login reactivate it? The `user.status` enum needs its full
   value set (only `'removed'` is observed in code; `Status.removed.name` implies a Dart enum
   — confirm all members).
2. **"Verify account" is actually the delete-flow OTP step**, not identity verification, and
   there is no `verified`/badge column. Confirm no separate verification feature is expected.
3. **Account deletion uses a raw client `UserTable().update`** to set `is_deleted/status`.
   Per CLAUDE.md §6 this should move behind an RPC/Edge that validates `auth.uid()` and audits.
4. **`user_follow` toggle semantics are inferred** (same call for follow & unfollow). Confirm
   the RPC deletes on existing edge and updates both counters atomically; confirm self-follow
   and blocked-user handling.
5. **Invite neighbours has no backend call** — is a referral/invite record or share-link
   expected, or is it purely a native share? Currently only a confirmation modal.
6. **`community_id` scoping:** follows/blocks/profile all carry `community_id`. Confirm whether
   the social graph is per-community (a user re-follows in each community) or global.
7. **Realtime uses Postgres Changes** on `follows`/`public_user_profile`. Confirm RLS on those
   tables authorizes the subscription, or migrate to authorized private Broadcast per §6.
8. **`IsOwner` PascalCase column** breaks snake_case convention — keep as-is to match the
   frontend Row class (renaming breaks the app), or coordinate a frontend change.
9. **Counters vs source of truth:** `followers/following/post_count/...` are denormalised on
   `public_user_profile`; ensure every write path (follow RPC, post/event/group/sale flows)
   keeps them correct, or back them with triggers.
10. **Old project ref** `wgcqstmmkcdjnnpuvspr` is hardcoded across calls — must be replaced by
    Viora's own project during rebuild.

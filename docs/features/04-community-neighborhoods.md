# Feature: Community & Neighborhoods

> Source of truth = the Flutter frontend. This doc records what the backend MUST provide
> for this feature to work. Derived from `lib/` — do not invent behavior the code doesn't show.

## 1. Overview
- **What it is:** The neighborhood layer of Viora. A "community" is the top-level partition
  every user, post, group, business, chat, etc. belongs to (frontend always uses
  `FFAppState().communityId`, which defaults to `1`). Within a community the app finds people
  who live physically nearby (via each user's saved home location), shows who you already
  follow vs. other nearby people you could follow, and surfaces the neighborhood post feed and
  member/post counts. Users establish their place in a neighborhood by granting location access,
  which saves their home lat/lng.
- **Why it exists / user value:** Places each user in the right neighborhood by home address,
  lets them discover and follow nearby neighbors, and drives the neighborhood feed and
  "same neighbourhood" people lists (Nextdoor-style local network).
- **Related features:** Posts/feed (`get_neighbourhood_post_data` returns posts), Follows
  (user↔user follow used across profile/feed), Groups & Events (share `community_id`),
  Business pages & Chat (also scoped by `community_id`). See other `docs/features/*.md`.

## 2. Screens & widgets
| Screen / widget (path under `lib/`) | Purpose | Key actions |
|---|---|---|
| `pages/profile/neighborhoods/neighborhoods_widget.dart` | Main "Neighbourhoods" screen: lists people you follow in the neighborhood (name, city, distance). | On load calls `GetNeighborhoodPeoplesCall`; subscribes to realtime `follows` and refreshes; reads `$.following_users`, `$.name`, `$.city`, `$.distance_km`, `$.user_id`. |
| `pages/profile/neighbourhoods_following/neighbourhoods_following_widget.dart` | "Following" list variant for the neighborhood — renders `following_users` and `others`. | On load calls `GetNeighborhoodPeoplesCall`; reads `$.following_users`, `$.others`, `$.name`, `$.city`, `$.distance_km`, `$.user_id`. |
| `pages/profile/neighbourhood_explore/neighbourhood_explore_widget.dart` | Explore the neighborhood: total member/post counts + the neighborhood post feed. | On load calls `GetneighbourhoodPostsCall`; reads `$.total_user_count`, `$.total_post_count`, `$.posts[]` (post_id, content, images, user_id, user_name, profile_picture, created_at, likes_count, comment_count, share_count, group_id, comments, replies). |
| `pages/profile/comp_follow_nearby/comp_follow_nearby_widget.dart` | Bottom sheet "Same Neighbourhood": nearby people you don't follow yet, each with a Follow button. | On load calls `GetNeighborhoodPeoplesCall`; renders `$.others` (`others_count`); Follow → `AddFollowCall` then re-fetches; pops when `others_count == 0`. |
| `components/comp_location_permission_widget.dart` | Location-permission prompt that places the user in a neighborhood. | On allow: `actions.userLocation()` → `InsertUserLocationCall` (saves home lat/lng) → `GetNeighborhoodPeoplesCall` → updates `public_user_profile` city/country → navigates to Neighborhoods. |
| `pages/community/community/community_widget.dart` | Community landing (primarily Groups & Events UI; writes to `group_members`/`event_attending`). | Group join/leave inserts/updates + `UpdateTotalGroupMembersCall`; event RSVP via `EventAttendingTable` + `UpdateEventAttendeeCountCall`. NOTE: this is the Groups/Events feature; documented in its own file — listed here only because it lives under `pages/community/`. |
| `pages/community/followed_pages/followed_pages_widget.dart` | "Followed / Pending Invites" list of followed business pages. | **Static placeholder** — hardcoded picsum images and text, NO backend calls in the current frontend. |
| `pages/community/pending_invites/pending_invites_widget.dart` | Community-level pending invites list. | **Static placeholder** — NO backend calls (no `.from/.rpc/.insert/.select/.update/.delete`). |

## 3. Data model (tables & columns)

### `community`
- **Purpose:** Top-level neighborhood/community partition. Every scoped entity carries a
  `community_id` referencing this. Frontend defaults to community `1` (single active community
  today).
- **Columns:** (from `tables/community.dart`)
  | Column | Type | Null? | Notes (PK/FK/default/enum) |
  |---|---|---|---|
  | `id` | int (int8/serial) | NO | PK. Referenced as `community_id` by many tables. |
  | `created_at` | timestamptz | NO | default `now()`. |
  | `name` | text | NO | Community display name. |
- **Foreign keys / relationships:** Parent of `follows.community_id` and the `community_id`
  column on many tables (`event_page`, `event_attending`, `business_page`, `business_contacted`,
  `business_promote`, `blocks`, `chat`, `group_admin`, `post`, etc.).
- **Indexes needed:** PK on `id` (implicit).

### `follows`
- **Purpose:** User→user follow relationship, scoped to a community. Drives the neighborhood
  "following" lists and the Follow action.
- **Columns:** (from `tables/follows.dart`)
  | Column | Type | Null? | Notes (PK/FK/default/enum) |
  |---|---|---|---|
  | `id` | uuid (text) | NO | PK. `String` in Row class → uuid, default `gen_random_uuid()`. |
  | `created_at` | timestamptz | NO | default `now()`. |
  | `community_id` | int (int8) | NO | FK → `community.id`. |
  | `follower_id` | uuid | NO | FK → `auth.users.id` / `public_user_profile.id` (the follower = current user). |
  | `following_id` | uuid | NO | FK → `auth.users.id` / `public_user_profile.id` (the followed user). |
- **Foreign keys / relationships:** `community_id`→`community.id`; `follower_id`,`following_id`
  → user id. A row means `follower_id` follows `following_id` within `community_id`.
- **Indexes needed:** `community_id`, `follower_id`, `following_id`; plus a UNIQUE constraint on
  (`follower_id`,`following_id`,`community_id`) to prevent duplicate follows; index
  `(community_id, follower_id)` for "who I follow" lookups.

### `user_locations`
- **Purpose:** A user's saved home location(s). Powers "nearby" detection — the geo point used
  to compute distance between neighbors.
- **Columns:** (from `tables/user_locations.dart`)
  | Column | Type | Null? | Notes (PK/FK/default/enum) |
  |---|---|---|---|
  | `id` | uuid (text) | NO | PK. Also referenced as the user id linkage (see open questions). |
  | `created_at` | timestamptz | NO | default `now()`. |
  | `location` | text | NO | Geo point. Row exposes it as `String` — almost certainly a PostGIS `geography(Point,4326)`/`geometry` serialized to text (WKB hex). Set server-side by `update_user_location` from lat/lon. |
  | `place` | text | YES | Human place/address label (echoed by realtime `user_locations` sub). |
  | `name` | text | YES | Optional label/name for the location. |
  | `latitude` | double (float8) | YES | Home latitude. |
  | `longitude` | double (float8) | YES | Home longitude. |
- **Foreign keys / relationships:** Links to the user (see §8 — whether `id` IS the user id or
  there is a separate `user_id` column is unresolved by the frontend; RPCs take `p_userid`).
- **Indexes needed:** FK/user index; a **GiST spatial index on `location`** for distance queries
  (see §7). Index on `latitude`/`longitude` if bounding-box prefilter is used.

## 4. Backend calls (API / RPC / Edge)
All calls are Supabase RPC over PostgREST (`/rest/v1/rpc/<fn>`), `POST`, JSON body, with
`apikey` (anon) + `Authorization: Bearer <jwt>` headers.

| Call / query | Type | Inputs | Returns | Called from |
|---|---|---|---|---|
| `get_followers_nearby` (`GetNeighborhoodPeoplesCall`) | RPC | `p_userid` (uuid text), `p_communityid` (int) | JSON object: `following_users[]` (`user_id`, `name`, `city`, `distance_km`, `profile_picture`), `others[]` (same shape — nearby people NOT followed), `following_count`, `others_count`. | `neighborhoods`, `neighbourhoods_following`, `comp_follow_nearby`, `comp_location_permission` |
| `get_neighbourhood_post_data` (`GetneighbourhoodPostsCall`) | RPC | `p_userid` (uuid text), `p_communityid` (int) | JSON object: `total_user_count`, `total_post_count`, `posts[]` (`post_id`, `content`, `images[]`, `user_id`, `user_name`, `profile_picture`, `created_at`, `likes_count`, `comment_count`, `share_count`, `group_id`, `comments[]`, `replies[]`). | `neighbourhood_explore` |
| `user_follow` (`AddFollowCall`) | RPC | `p_communityid` (int), `p_followerid` (uuid), `p_followingid` (uuid) | (follow row / success) | `comp_follow_nearby` Follow button |
| `update_user_location` (`InsertUserLocationCall`) | RPC | `lat` (text), `lon` (text), `place_name` (text), `p_type` (text — e.g. `"update"`) | (updated location) — builds `location` geo point from lat/lon. | `comp_location_permission` |
| `get_following_users_not_attending_event` (`GetFollowingUsersCall`) | RPC | `p_event_id` (uuid text) | Users the caller follows who are not attending a given event (for event invites). | `events/event_details` — **event-scoped**, tangential to neighborhoods; listed because it reads the follow graph. |
| `public_user_profile.update(...)` | direct DML | `{city, country}` where `id = currentUserUid` | — | `comp_location_permission` (after saving location) |

## 5. Business rules & flows
1. **Join a neighborhood (location):** User taps "Allow Location Access" →
   `actions.userLocation()` gets device lat/lng → `update_user_location` RPC saves the home
   point (`p_type: "update"`, upsert semantics implied) → `get_followers_nearby` refreshes the
   nearby lists → `public_user_profile.city/country` updated → navigate to Neighborhoods.
2. **Nearby detection:** `get_followers_nearby` compares the caller's saved `user_locations`
   point against other users' points in the same `community_id` and returns each with
   `distance_km`. The frontend never sends a radius — the **radius/threshold and distance math
   live inside the RPC** (geo distance; see §7). Results are split into `following_users`
   (already followed) and `others` (not yet followed).
3. **Follow a neighbor:** In "Same Neighbourhood" sheet, tapping Follow calls `user_follow`
   with `follower_id = current user`, `following_id = target`, `community_id`. Then the list is
   re-fetched; if `others_count` becomes 0 the sheet auto-closes. The follow must move the
   person from `others` into `following_users` on next fetch (idempotent — needs the unique
   constraint from §3 so re-follow doesn't duplicate).
4. **Explore feed & counts:** `get_neighbourhood_post_data` returns `total_user_count`,
   `total_post_count`, and enriched `posts[]` for the community; used by the explore screen and
   kept live via realtime (see §6).
5. **Followed pages / Pending invites (community-level):** Currently **UI-only placeholders**
   with no backend wiring. No table/RPC is exercised by these two screens today — do not build
   backend for them until the frontend is wired (see §8).

## 6. Realtime / notifications
Mode in the frontend today is **Postgres Changes** (not Broadcast). CLAUDE.md §6 prefers private
Broadcast — flag for review during rebuild (see §7/§8).
- **`follows`** — `actions.subscribe('follows', cb)` (custom action `subscribe.dart`) listens to
  all Postgres changes on `public.follows` and re-runs `get_followers_nearby`. Used by the
  Neighborhoods screen so follow/unfollow updates the list live.
- **`user_locations`** — `initRealtimeUserLocations()` listens to all changes on
  `public.user_locations`, maintaining `FFAppState().userLocationsList` (`id`, `place`).
- **`post`** — `initRealtimeNeighbourhoodPostUpdates()` listens to all changes on `public.post`
  and smart-merges into `FFAppState().NeighbourHoodPost` (special-cases `*_count` fields to avoid
  overwriting positive counts with 0). Backs the neighborhood explore feed.
- No OneSignal/push is triggered from these neighborhood screens directly.

## 7. Backend to build (Supabase rebuild checklist)
- [ ] **Tables:** `community` (id, created_at, name), `follows` (id uuid, created_at,
      community_id, follower_id, following_id), `user_locations` (id, created_at, location geo,
      place, name, latitude, longitude). Add real FKs: `follows.community_id`→`community.id`,
      `follows.follower_id`/`following_id`→user id, `user_locations`→user id.
- [ ] **Indexes:** every FK on `follows`; UNIQUE(`follower_id`,`following_id`,`community_id`);
      composite `(community_id, follower_id)`; **GiST spatial index on `user_locations.location`**.
- [ ] **PostGIS (GEOSPATIAL — REQUIRED):** enable the `postgis` extension. `user_locations.location`
      is a geography/geometry point; `get_followers_nearby` needs `ST_DWithin` / `ST_Distance`
      (returned as `distance_km`) to find neighbors within a radius. Decide and document the
      radius (frontend sends none). `update_user_location` must build the point from lat/lon
      (e.g. `ST_SetSRID(ST_MakePoint(lon,lat),4326)::geography`).
- [ ] **RLS intent:**
  - `community` — SELECT for authenticated (members); INSERT/UPDATE/DELETE admin-only.
  - `follows` — SELECT where `follower_id = auth.uid()` OR `following_id = auth.uid()` (or all
    within one's community, per product); **no direct INSERT/UPDATE/DELETE** — go through
    `user_follow` RPC. Add an `unfollow` RPC when the frontend needs it.
  - `user_locations` — SELECT own row (nearby lists are computed server-side via SECURITY DEFINER
    RPC, so other users' raw coordinates are never exposed to the client); writes only via
    `update_user_location` RPC.
- [ ] **RPC / PL-pgSQL functions (validate `auth.uid()` inside; `SET search_path = public, pg_temp`):**
  - `get_followers_nearby(p_userid uuid, p_communityid int) returns json` — SECURITY DEFINER;
    geo distance vs caller's location; returns `following_users`, `others`, and their counts.
  - `get_neighbourhood_post_data(p_userid uuid, p_communityid int) returns json` — feed +
    `total_user_count`/`total_post_count`.
  - `user_follow(p_communityid int, p_followerid uuid, p_followingid uuid)` — must verify
    `p_followerid = auth.uid()`, prevent self-follow, upsert against the unique constraint.
  - `update_user_location(lat text, lon text, place_name text, p_type text)` — upsert caller's
    home point; verify `auth.uid()`; parse lat/lon to geography.
  - `get_following_users_not_attending_event(p_event_id uuid)` — (events feature; reads follow graph).
- [ ] **Storage:** none specific to this feature (profile pictures come from user profile).
- [ ] **Edge functions:** none required (device geocoding/lat-lng is client-side).
- [ ] **Triggers / cron:** none observed. Consider a follower/following counter maintenance
      trigger if counts are denormalized elsewhere.
- [ ] **Realtime:** `follows`, `user_locations`, `post` must be in the realtime publication.
      Per CLAUDE.md §6, evaluate moving to **private authorized Broadcast** with RLS on
      `realtime.messages`; the current frontend uses public Postgres Changes.

## 8. Open questions & risks
- **`user_locations` ↔ user linkage:** The Row class exposes only `id` (uuid), no explicit
  `user_id`. RPCs pass `p_userid`, and realtime keys on `id`. Confirm whether `id` **is** the
  user's uuid (1 location per user) or whether a separate `user_id` FK exists that FlutterFlow
  didn't generate. This determines the FK and the "one home location per user" rule.
- **`location` column type:** Row class types it as `String`. Confirm it is PostGIS
  `geography(Point,4326)` (text-serialized) and not a plain string; the whole nearby feature
  depends on it being a spatial type.
- **Nearby radius:** The frontend never supplies a radius/threshold — it is entirely inside
  `get_followers_nearby`. The exact radius (km) and whether it is per-community configurable
  must be confirmed and documented.
- **Community scoping:** `communityId` defaults to `1` everywhere and is never dynamically set
  in the reviewed code. Confirm whether Viora launches with a single fixed community or whether
  community assignment (by location) is planned — this affects `community` seeding and how a
  user is assigned a `community_id`.
- **Followed pages & Pending invites screens are non-functional placeholders** (hardcoded data,
  no queries). The header even says "Pending Invites (4)" as static text. Do NOT build backend
  for these until the frontend is wired; confirm intended data source (business page follows?
  community invites table?).
- **`others_count == 0` uses string compare** in `comp_follow_nearby` — ensure the RPC returns
  numeric JSON so the `!= 0` / `== 0` checks behave.
- **Unfollow path:** No unfollow RPC/DML appears in the neighborhood screens (only follow).
  Confirm where unfollow lives (likely the profile/follows feature) so `follows` DELETE is
  handled by an RPC, not direct client DML.
- **Realtime auth:** current `subscribe('follows')` and post/location subscriptions are public
  Postgres Changes — a security review is needed to ensure users can't stream other users'
  follow rows or raw locations once RLS is enforced.

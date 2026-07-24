# Viora — Decision Log

Every non-obvious decision (CLAUDE.md §7). Newest first. High-impact/ambiguous decisions are
asked before acting; smaller implementation choices are made and recorded here.

---

## 2026-07-20 — Rebrand to "Flock" + full UI redesign (UI-only)
- **Decision (high-impact — owner directed):** rename the app's user-facing brand from
  Viora/SQUADD to **"Flock — find your people,"** and do a **full UI redesign** (colors +
  screens). Owner: the old design/colors are unattractive.
- **Scope guardrail:** **UI-only.** No changes to app logic, state, navigation, or backend
  wiring (`_model.dart` files + `lib/backend/` untouched). Redesign happens in two layers —
  theme-level (`lib/flutter_flow/flutter_flow_theme.dart`) first, then per-screen
  `_widget.dart` polish. Phased: designer direction → apply to hero screens → owner approves →
  roll out to all screens.
- **Bundle ID stays `com.viora.app`** (technical package id unchanged). Only the user-visible
  name/label/splash/branding art becomes "Flock." Rationale: we just completed the painful
  Firebase/SHA bundle migration; changing the package id again = redoing it for zero user
  benefit. (Owner to veto if they want a true `com.flock.app` migration.)
- **Creative brief (owner's answers):** personality = playful & social; palette = designer's
  choice (moving off flat emerald green); themes = light **and** dark; inspiration =
  Instagram/Threads + Airbnb/Meetup (image-forward, warm, rounded, signature gradient).
- **Deliverables in progress:** `docs/design/flock-design-system.md` (token spec) + an HTML
  visual mockup of hero screens (onboarding/feed/profile, light+dark) for owner review.
- **Reversibility:** design spec/mockup are non-destructive (no app code changed yet).
  Implementation is theme-first, so the visual change is reversible via git before rollout.

---

## 2026-07-19 — Push trigger auth moved from GUCs → Supabase Vault (`0087`)
- **Feature:** How `trg_push_new_notification` gets the URL + service-role key to call the
  `send-notification` Edge Function.
- **Problem:** the 0082 design read two custom GUCs (`app.settings.edge_function_url`,
  `app.settings.service_role_key`) set via `alter database postgres set …`. On hosted Supabase that
  statement is **superuser-only — permission denied even in the SQL editor**, so the GUCs could never
  be set and push could never fire.
- **Decision (small implementation choice — recorded, not asked):** rewrite the trigger (`0087`) to
  read the service-role key from **Supabase Vault** (`vault.decrypted_secrets`, encrypted at rest)
  and **hardcode the non-secret function URL**. This is also more secure than a plaintext GUC (a GUC
  is readable via `current_setting()`/`pg_settings`). Vault access by `postgres` verified (has
  `usage`; SECURITY DEFINER trigger owned by postgres can read it).
- **Setup now:** one `select vault.create_secret('<service_role_key>', 'service_role_key', …)` run in
  the SQL editor (normal grant, works — unlike `alter database`). `FCM_SERVICE_ACCOUNT_JSON` remains
  an Edge Function secret (read inside Deno, not by the DB).
- **Files:** `supabase/migrations/0087_push_trigger_vault.sql` (new); `0082` header annotated as
  superseded (its function + realtime policy + pg_net parts still stand).
- **Reversibility:** Easy — `0087` is a `create or replace`; revert by restoring 0082's body (though
  the GUC path is unusable on hosted anyway).

---

## 2026-07-19 — Firebase migrated to Viora's own project (`viora-b75f7`)
- **Feature:** Moved the app off the old Firebase project `squadd-640af` (project #129801406213) onto
  a new self-owned project **`viora-b75f7`** (project #227687828358) — mirrors the Supabase self-hosting
  move. Covers both FCM push and Google Sign-In.
- **New identifiers (all confirmed consistent across the 3 config sources):**
  - Android OAuth client (type 1): `227687828358-a7n42d4kcp99qq9pepfie3ftlms0ltcu` (cert hash
    `dbe9be95…` = this machine's **debug** SHA-1).
  - Web OAuth client (type 3, `serverClientId`): `227687828358-d31670bp7mv46pmhtlpfh4jmpptstot4`.
  - iOS OAuth client (type 2): `227687828358-idhevrt5idtu6hr9ed03kf1tr7ou1l8d`.
- **Files updated:** `android/app/google-services.json` (new, oauth_client populated),
  `ios/Runner/GoogleService-Info.plist` (new), `lib/auth/supabase_auth/google_auth.dart` (iOS
  clientId + Web serverClientId), `ios/Runner/Info.plist` (REVERSED_CLIENT_ID URL scheme),
  `lib/backend/firebase/firebase_config.dart` (web Firebase options), `firebase/functions/package.json`
  (legacy CLI scripts repointed `-P viora-b75f7`). No `squadd-640af` / `129801406213` refs remain in
  code (only in this decision log as history).
- **Still pending (manual, stakeholder):**
  1. **iOS APNs key** upload to Firebase (Cloud Messaging tab) — required for iOS push.
  2. **`FCM_SERVICE_ACCOUNT_JSON`** secret + the 2 DB GUCs — regenerate the service account from the
     NEW project (`viora-b75f7`).
  3. **Supabase → Auth → Providers → Google:** set the new **Web client ID + secret**, add the iOS +
     Android client IDs to *Authorized Client IDs* (else `signInWithIdToken` fails audience check).
  4. **Production SHAs** (release/upload key + Play App Signing) must be added to the Firebase Android
     app before launch — only the machine's debug SHA is registered now.
- **Reversibility:** Easy (git) — mechanical config swap; the old project still exists until deleted.

---

## 2026-07-19 — App identity renamed to Viora (`com.viora.app`)
- **Feature:** Rebrand — bundle/package ID + display name changed off the old `com.company.squaDD`.
- **Decision (ASKED — high-impact, hard-to-reverse):** stakeholder chose bundle ID **`com.viora.app`**
  (used identically on Android + iOS) and confirmed the old ID is **not yet published**, so the rename
  is safe (no store migration). Display name set to **Viora**.
- **Files changed (both platforms, parity per §2):**
  - Android — `android/app/build.gradle` (`namespace` + `applicationId`), `AndroidManifest.xml` main
    (`package` + `android:label="Viora"`), debug/profile manifests (`package`), `MainActivity.kt`
    (`package com.viora.app` — file stays in the `com/example/my_project` dir; Kotlin doesn't require
    a matching path), `res/values/strings.xml` (`app_name=Viora`).
  - iOS — `Runner.xcodeproj/project.pbxproj` (3× `PRODUCT_BUNDLE_IDENTIFIER`), `Runner/Info.plist`
    (`CFBundleDisplayName` + `CFBundleName` = Viora). The `ImageNotification` folder is not a wired
    Xcode target, so it needs no ID change.
  - Dart — in-app Play Store share/download links (`app_state.dart`, `comp_invite_widget.dart`,
    `supportpage_widget.dart`, `profile_widget.dart`) repointed to `id=com.viora.app`.
- **NOT changed (deliberate):** the Dart package name (`squa_d_d` in `pubspec.yaml` — huge import
  blast radius, not user-facing); the `squadd://` deep-link scheme + `squadd.com` App Link host
  (separate rebrand item — would require updating the `send-notification` edge fn's `squadd://`
  URL + `setup_notifications.dart`); the two Firebase config files (`google-services.json`,
  `GoogleService-Info.plist`) — being replaced wholesale by the new Firebase project's downloads.
- **Consequence:** the Android build will NOT compile until the new `google-services.json`
  (registered under `com.viora.app`) is dropped in — the Google Services plugin validates
  `applicationId` against a `package_name` in that file. Register the new Firebase Android + iOS
  apps with `com.viora.app` (not `squaDD`).
- **Reversibility:** Easy (git) — mechanical string rename; revert by swapping the IDs back.

---

## 2026-07-19 — App repointed to Viora; auth/utility edge functions flagged as a gap
- **Feature:** Frontend cutover to Viora's Supabase project (`hlmymmlkgirafodcnkgg`).
- **Decisions / actions:**
  1. **`assets/environment_values/environment.json`** — `AnonKey` swapped to Viora's anon key;
     the leaked `sk_live_` `secretKey` blanked to `""` (must still be rotated at the provider +
     moved server-side — see Security remediation).
  2. **Swept the old project ref** `wgcqstmmkcdjnnpuvspr` → `hlmymmlkgirafodcnkgg` across all of
     `lib/` (97 occurrences, 16 files, incl. `supabase.dart` client URL, `api_calls.dart`,
     `app_state.dart` default-image URLs, custom widgets). App now runs consistently on Viora.
     Stakeholder chose "repoint now, build edge functions next."
  3. **NEW GAP surfaced — 9 edge functions not yet built in Viora:** `send-otp`, `verify_otp`,
     `authenticate-user`, `check-user-exist`, `check-user`, `reset-password`, `change-password`,
     `phone-signup`, `generate-tldr`. The DB layer (tables/RPCs/storage/realtime) + `send-notification`
     are live; these 9 were never part of the DB batches. **Consequence:** email/password + Google
     login work (Supabase Auth/GoTrue, not edge-fn); OTP/phone login, user-exist check, password
     reset/change, and TLDR **404 until these are built** — the next build task.
  4. **`app_state.dart` default-image URLs** now point at Viora's `squadd` bucket — those default
     profile/cover/business images must be uploaded into Viora's `squadd` bucket or they 404
     (minor asset-migration follow-up).
- **Reversibility:** Easy (git) — a mechanical ref swap; revert by swapping the ref back + restoring
  the old anon key.

---

## 2026-07-19 — Batch 7 (Notifications, Search & Moderation) applied — BACKEND REBUILD COMPLETE
- **Feature:** Backend build — final batch (`supabase/migrations/0068`–`0084`) applied to
  `hlmymmlkgirafodcnkgg`, plus the `send-notification` edge function deployed. Tables:
  search_history, reports, notifications, admin_notification. ~20 RPCs, notification producer
  triggers, FCM push, pg_trgm search. Advisors: 0 error, 0 anon. **Final DB: 39 tables (100% RLS),
  159 functions, 51 policies, 9 buckets.**
- **Decisions:**
  1. **Moderation** — `reports` (polymorphic via report_type + FK), `report_content` (generic) +
     `report_business` (backfilled from the Batch-6 stub); admin-only `get_reports`/
     `set_report_status` (audited). reports SELECT/UPDATE admin-only; INSERT via RPC.
  2. **Notifications trigger-driven** — a single internal `notify()` (never-self, block-aware) is
     called by producer triggers on post_like/post_comment/follows/group_user_status/
     event_attending/business_promote (NO changes to the already-applied RPCs). Types:
     post/comment/group/group_invite/event/invite/business/follow/report (some TODO-confirm).
     `get_notifications` grouped feed; mark read/deleted own-only.
  3. **FCM push** — `send-notification` edge function (FCM v1, service-account JWT), invoked by a
     best-effort `pg_net` trigger; the function is service-role-bearer-gated (hardened beyond the
     draft). Requires MANUAL setup: enable `pg_net`, set `FCM_SERVICE_ACCOUNT_JSON` secret + the two
     `app.settings.*` GUCs. Realtime badge = private Broadcast (realtime.messages policy = manual).
  4. **Search** — `pg_trgm` + trigram GIN indexes; `get_search_all_data`/`get_search_data`/
     `tag_search` (block-filtered), `update_search_data`; search_history owner-scoped RLS.
- **Reversibility:** Medium — schema/RLS/RPCs/edge fn; realtime + FCM pending manual privileged setup.

---

## 2026-07-19 — Batch 6 (Business & Chat) applied
- **Feature:** Backend build — Batch 6 (`supabase/migrations/0053`–`0067`) applied to
  `hlmymmlkgirafodcnkgg`. Tables: business_page, business_promote, business_promote_plans,
  business_contacted, chat, chat_users, messages. ~25 RPCs, promotion state machine, chat +
  realtime, preview/broadcast triggers. Advisors: 0 error, 0 anon.
- **Decisions:**
  1. **Promotion state machine** — owner uploads receipt via `create_or_update_promotion`
     (status='under review', dates cleared); a PLATFORM admin (`is_admin()`) sets
     live/ended/rejected/mismatch + dates via `admin_set_promotion_status` (audited).
     `promotion_status` derived at read time (live past plan_end_date reads as ended).
     `business_promote.admin_user` = the OWNER/submitter, NOT a platform admin.
  2. **Business RLS** — business_page public-read (active/non-deleted) + owner; business_promote &
     business_contacted owner+admin only. **`get_contact_count` PUBLIC** (`0067`, stakeholder):
     aggregate count visible to any signed-in user, individual contact rows stay owner/admin.
  3. **Chat** — members-only RLS; all writes RPC (find_common_chat find-or-creates, send_message
     block-enforced, soft-delete/restore own membership). last_message preview trigger-maintained.
  4. **Realtime = private authorized Broadcast** (§6): topics `chat:{chat_id}` + `user:{uid}:chats`,
     `realtime.messages` receive-RLS gated by chat membership, server-only publish via a broadcast
     trigger. **⚠️ The `realtime.messages` policy can't be applied via MCP** (postgres ≠ owner of
     realtime.messages) — must run via Supabase CLI (`supabase db push`) or Dashboard. Chat works
     via RPCs meanwhile. Frontend must repoint from its current public channels (TODO-frontend).
  5. **Storage backfill** (`0055`) — activated the Batch-5 forward-compat business-image/
     promote-receipts storage helpers with real queries now that business tables exist.
  6. **`reports` still doesn't exist** — `report_business`/`unreport_business` use the forward-compat
     `undefined_table` guard; no-op until the Moderation batch (7) creates `reports`.
- **Reversibility:** Medium — schema + RLS + RPCs; realtime policy pending a privileged apply.

---

## 2026-07-19 — Batch 5 (Events, Marketplace & Storage) applied
- **Feature:** Backend build — Batch 5 (`supabase/migrations/0035`–`0052`) applied to
  `hlmymmlkgirafodcnkgg`. Tables: event_page, event_attending, sale, sale_category, sale_images.
  ~30 RPCs, counter triggers (attendee_count/event_count/sale_count), table RLS, and the FIRST
  storage layer (9 buckets + storage.objects policies). Advisors: 0 error, 0 anon.
- **Decisions:**
  1. **Storage layer** — 9 buckets (post-images, sales-images, profile/cover, business-image,
     event, group-profile-image, promote-receipts PRIVATE, squadd). **Strict ownership** on
     writes: folder = entity id (or user id for profile/cover); uploads require owning the entity
     (row must exist first — confirmed true for sales). Public buckets are world-readable by URL;
     the 8 `public_bucket_allows_listing` advisor WARNs are accepted (images are meant public).
  2. **`sale_images` writes** — owner-scoped direct INSERT/DELETE RLS (added `is_sale_owner_self`),
     so the app's `uploadSalesImages` direct insert works without a frontend change.
     `add_sale_image()`/`delete_sale_image()` RPCs also exist as an alternative.
  3. **Events** — time-based lifecycle (`is_deleted=false AND end_date_time>now()`), RSVP toggle
     via `rsvp_event`, attendee_count trigger; all writes RPC-only. Backfilled the Batch-3
     `get_following_users_not_attending_event` stub to a real query now that `event_attending`
     exists.
  4. **Marketplace** — `get_sales_home_data` filters category + type + PostGIS distance + Closest
     sort fully server-side (offset pagination since distance isn't keyset-friendly). `sale`/
     `sale_category`/`sale_images` writes RPC-or-scoped; category stays name-based.
- **Open TODO(confirm):** `sale_category` unseeded (dropdown empty until real list added); event
  list ordering (`created_at asc` for "Latest" — matches frontend, maybe a frontend bug); Nearby
  radius 5km; storage path scheme for posts (verify create-before-upload); `event_count` =
  created events.
- **Reversibility:** Medium — schema + RLS + RPCs + buckets, all migration-tracked.

---

## 2026-07-19 — Batch 4 (Groups) applied
- **Feature:** Backend build — Batch 4 (`supabase/migrations/0024`–`0034`) applied to
  `hlmymmlkgirafodcnkgg`. 5 tables (`"group"`, `group_admin`, `group_members`,
  `group_members_invite`, `group_user_status`), ~20 RPCs, member-count trigger, group RLS. Added
  the deferred `post.group_id` FK. Advisors clean (0 error/anon).
- **Decisions:**
  1. **Private groups discoverable, request-to-join** — private group metadata is browsable so
     users can find & request; member list + posts gated to members/admins. Open groups: public
     member lists.
  2. **State machine** (`group_user_status`): open = instant join; private = request → admin
     approval; invite-accept for a private group converts to a request (TODO(confirm) two-step).
  3. **All privileged actions RPC-only** and admin-authority-checked (`is_group_admin`): approve/
     reject/invite/assign/revoke/delete/edit. Last-admin removal blocked (incl. a sole-admin
     `leave_group` guard — a small safety addition beyond the frontend's literal DML, recorded).
  4. **`block_user`/`unblock_user`** brought forward as user-level (not group-scoped) SECURITY
     DEFINER RPCs alongside the existing owner-scoped `blocks` RLS — reconcile with the future
     Moderation batch, not redefine.
- **Open TODO(confirm):** `e_discoverability`/`e_group_role` value sets (kept text); `"group"` has
  no geo column so `nearest` is a constant false; `group.created_by ON DELETE RESTRICT`;
  `group_members_invite` UNIQUE(group_id, invited_user) assumed.
- **Reversibility:** Medium — schema + RLS + RPCs, migration-tracked.

---

## 2026-07-19 — Batch 3 (Neighbors/Follows) applied
- **Feature:** Backend build — Batch 3 (`supabase/migrations/0017`–`0023`) applied to
  `hlmymmlkgirafodcnkgg`. Table `follows`; RPCs `user_follow`, `get_followers`, `get_following`,
  `get_followers_nearby`, `get_following_users_not_attending_event`; follower/following counter
  trigger; updated `can_view_post`/`get_post_user_data` to use real `follows` queries.
- **Decisions:**
  1. **`follows` reads = Option B (owner-involved):** SELECT only where the caller is the
     follower or followee; other users' lists go through block-filtered RPCs. Writes RPC-only via
     `user_follow()` (self-follow guarded by CHECK + code; counters trigger-maintained).
  2. **Friends-only post visibility now LIVE** — `can_view_post` id=2 replaced its Batch-2
     forward-compat stub with a direct mutual-follow query. (Mutual = both directions;
     TODO(confirm) mutual vs either-direction still open.)
  3. **Nearby people** (`get_followers_nearby`) — self-relative PostGIS, 5km default
     (TODO(confirm)), returns following_users[]/others[] + counts, block-filtered.
- **File/DB reconciliation:** fixed drift where Batch-2 inline hardening wasn't written back to
  files — `0009` helpers (`is_blocked_pair`/`can_view_post`/`can_comment_post`) now show
  internal-only grants; `0013` `trg_recompute_profile_post_count` now shows `SECURITY DEFINER`.
  Files again reproduce the applied DB from zero. `0022` re-ran the anon-execute lockdown for the
  new functions.
- **Reversibility:** Medium — schema + RLS + RPCs, migration-tracked.

---

## 2026-07-19 — Batch 2 (Posts & Comments) applied
- **Feature:** Backend build — Batch 2 (`supabase/migrations/0007`–`0016`) applied to
  `hlmymmlkgirafodcnkgg`. Tables: post, post_images, post_like, post_share, tag, see_post_access,
  comment_post_access, post_comment, post_comment_likes, blocks. ~30 RPCs, counter triggers.
- **Decisions:**
  1. **Post visibility = 3 levels** (`see_post_access`): 1 Everyone, 2 Friends only (mutual
     follow via `follows`, forward-compat until that table lands), 3 Nearby (PostGIS, 5km default
     — TODO confirm radius). No community. Enforced in `can_view_post()`.
  2. **Two-way blocking** filters every content read (`is_blocked_pair`). `blocks` table brought
     forward from Moderation; **block/unblock enabled now** via owner-scoped RLS INSERT/DELETE
     (self-block prevented) — approved rather than deferred.
  3. **Comment reads ride on post visibility** — a visible post shows its existing comments even
     when `comment_post_access='No One'` (that only blocks NEW comments). Approved.
  4. **Backend pagination + filtering** on all list RPCs (keyset, with DEFAULT args so the locked
     frontend's no-arg calls still work — TODO(frontend) to wire pagination).
  5. **Internal visibility helpers locked:** `can_view_post`, `can_comment_post`, `is_blocked_pair`
     revoked from clients (called only by SECURITY DEFINER fns as owner). RLS uses a self-scoped
     `can_view_post_self(post_id)` wrapper — the one visibility fn clients may call.
  6. **Blanket anon lockdown** (`0014`) — revoked EXECUTE from `anon` on all public functions
     (Viora has no anon RPCs); trigger functions revoked from all client roles (`0015`).
- **Bugs fixed before apply:** two `CREATE FUNCTION` arg-order errors (defaulted `p_communityid`
  preceding a required arg in `insert_post_image_rows` and `add_comment_like`) — moved the compat
  arg last. Made `trg_recompute_profile_post_count` SECURITY DEFINER (updates the locked
  counter column).
- **Reversibility:** Medium — schema + RLS + RPCs, all migration-tracked; droppable but the app
  contract depends on them.

---

## 2026-07-19 — Batch 1 identity RLS: admin PII read + counter lock
- **Feature:** Backend build — Batch 1 identity RLS (`supabase/migrations/0006_identity_rls.sql`,
  applied to project `hlmymmlkgirafodcnkgg`).
- **Decisions:**
  1. **Admins may read the private `"user"` row (PII).** Added `user_select_admin` (SELECT to
     authenticated where `is_admin()`). Admin UPDATE of PII is NOT granted — moderation writes go
     through a future validated `SECURITY DEFINER` RPC. (Stakeholder chose this over keeping PII
     fully private even from admins.)
  2. **Counter columns locked at column level.** `REVOKE UPDATE (followers, following,
     post_count, group_count, event_count, sale_count) ON public_user_profile FROM authenticated,
     anon` — clients can edit their own profile but cannot fabricate counts; only the
     `SECURITY DEFINER` counter triggers (later batch) write these.
  3. **Deferred:** hiding soft-deleted users' public profiles. The reviewed draft's `NOT EXISTS`
     check against `"user"` cannot work (owner-only RLS hides other users' rows), so profile read
     is "any authenticated user" for now; proper deleted-profile hiding ships in the
     Profile/Account batch with `delete_account`.
- **Also:** hardened two `get_advisors` warnings — revoked `signup_finalize` EXECUTE from `anon`,
  and revoked the pre-existing `rls_auto_enable()` event-trigger function (owner: postgres, NOT
  ours — kept because it auto-enables RLS on new tables) from all client roles so it isn't
  REST-callable. Remaining advisor notes (`user_login` deny-all, `signup_finalize` authenticated)
  are intentional.
- **Reversibility:** Easy — all RLS-policy/grant level, no schema or frontend impact.

---

## 2026-07-19 — Remaining open decisions settled (pre-build sign-off)
- **Feature:** Database design / backend build — the stakeholder answered every remaining open
  decision from `docs/database/10-open-decisions.md` so Phase 1 can proceed without pauses.
- **Decisions:**
  1. **Table names** — keep the frontend's actual names `"user"` and `public_user_profile`
     (NOT `user_main`/`public_user`). Zero frontend risk; `"user"` is double-quoted in SQL.
  2. **Role values** — `user_roles.role` uses **`customer`** (regular user) + **`admin`**. Keep
     `customer` (what the locked frontend inserts); do NOT force `user`. (Supersedes the early
     "user/admin" wording.)
  3. **Blocking** — **two-way**: when A blocks B, both stop seeing each other's content
     (posts, comments, profile, chat). Every content RPC filters both directions.
  4. **Push notifications** — **Firebase Cloud Messaging (FCM)** for BOTH Android and iOS. Drop
     the OneSignal `player_id` column; `user_devices` keeps `fcm_token` only.
  5. **User-facing writes** — go through **server functions (RPC)** for anything important
     (state machines, moderation, payments); tightly-scoped RLS only for trivial owner rows.
  6. **Saved location** — **one home location per user** (`user_locations.id = "user".id`).
  7. **Post tags** — the **`tag` table is authoritative**; `post.tagged_people` jsonb becomes a
     denormalized cache.
  8. **Audit log** — log **all sensitive/admin actions** to `audit_log`.
  9. **Unknown dropdown value sets** (group discoverability, comment access, chat_type,
     promotion status, report_type) — store as **plain text** for now; confirm exact values
     later from the live/admin (Operture) app.
  10. **Realtime** — **secure PRIVATE authorized channels** (Broadcast with RLS on
      `realtime.messages`), replacing the current public unauthorized Postgres-Changes usage
      (CLAUDE.md §6). (Stakeholder's "switch to public" was a typo — confirmed private.)
  11. **Pagination & filtering** — **all list/feed reads are paginated and filtered on the
      BACKEND**; the app must NOT fetch-all-and-filter client-side. This is now the standard for
      every list RPC. **Approved scope expansion:** the over-fetching frontend screens WILL be
      updated to call the paginated/backend-filtered RPCs (an explicit, authorized exception to
      "frontend is locked" — CLAUDE.md §2 — for pagination/filtering wiring only).
- **Reason:** stakeholder answers, captured to unblock the from-scratch build against Viora's own
  project (`hlmymmlkgirafodcnkgg`).
- **Reversibility:** Mixed — most are RLS/RPC-level (easy); two-way blocking and backend
  pagination touch many RPCs (medium); role value and table names are baked into every migration
  (hard once applied).

---

## 2026-07-19 — Remove community concept; video out of scope; identity table RLS (owner-only user, public-read profile)
- **Feature:** Database design (`docs/database-design.md`, `docs/database/*.md`) — three
  stakeholder decisions applied to the design docs only (no Supabase changes, no migrations).

- **Decision 1 — Identity table RLS:**
  - The private `"user"` table: SELECT/UPDATE **owner-only**, predicate `id = (SELECT
    auth.uid())`. No cross-user reads at all. INSERT only via `signup_finalize` RPC.
  - `public_user_profile`: SELECT readable by **any authenticated user** (this is the app's
    public-facing profile surface); writes remain owner-only (RPC / owner-scoped `WITH CHECK`).
    Documented as the **primary read surface** — most profile/display reads hit
    `public_user_profile`, not `"user"`.
  - **Reason:** stakeholder decision, separates PII (`"user"`) from the public profile object
    (`public_user_profile`) the app actually reads for display.
  - **Reversibility:** Easy — RLS-policy-only change, no schema/frontend impact.

- **Decision 2 — Remove the community concept:**
  - Dropped the `community` table entirely from the design (index, ERD, migration ordering,
    `docs/database/03-tables-community-groups.md`). No community-scoped RLS predicates, no
    community FK relationships, no multi/single-community logic, no RPC scoping by
    `community_id`.
  - **Frontend reconciliation (locked frontend, CLAUDE.md §2):** the FlutterFlow Row classes
    still carry `community_id` on many tables and the app still inserts/filters it (hardcoded
    `= 1`). Verified via `grep -rl "community_id" lib/backend/supabase/database/tables/`. Every
    one of those columns is **kept** as a vestigial compat column (`int8`, `DEFAULT 1`, nullable,
    **no FK**, never referenced by RLS/RPC scoping) — labeled per-table as: "vestigial compat
    column — no community feature; retained only because the locked frontend Row class
    sends/filters it (CLAUDE.md §2)." Tables kept: `user_roles`, `public_user_profile`,
    `follows`, `"group"`, `group_admin`, `group_members`, `group_members_invite`,
    `group_user_status`, `post`, `post_images`, `post_like`, `post_share`, `post_comment`,
    `post_comment_likes`, `event_page`, `event_attending`, `sale`, `sale_category`,
    `sale_images`, `business_page`, `business_promote`, `business_promote_plans`,
    `business_contacted`, `chat`, `chat_users`, `messages`, `search_history`, `reports`,
    `blocks`. No table needed the column removed — the prior draft already matched the frontend
    contract exactly (no table had `community_id` in the docs that the frontend Row class lacks).
    RPCs that accept `p_communityid`/`community_id` from the locked frontend keep that argument
    in their signature (so existing call sites keep working) but no longer use it for any
    WHERE-clause scoping — annotated per-RPC in `docs/database/09-rpc-inventory.md`.
  - The frontend's own `CommunityTable`/`CommunityRow` Dart class
    (`lib/backend/supabase/database/tables/community.dart`) is left untouched (frontend locked)
    but is not backed by a table in this design.
  - **Reason:** stakeholder decision — Viora does not ship a community/neighborhood-boundary
    feature.
  - **Reversibility:** Medium — re-adding `community` later requires recreating the table,
    re-pointing every vestigial `community_id` to a real FK, and reintroducing RLS/RPC scoping.

- **Decision 3 — Video removed from scope:**
  - Removed the `post-videos` bucket and all video mime-type/size/`e_media_type='video'` design
    from `docs/database/07-storage-buckets.md`. Storage is images only.
  - **Reason:** the app has no video-upload UI; designing server support ahead of a frontend
    feature that doesn't exist violates "frontend is locked/done, backend matches it" (CLAUDE.md
    §2). Revisit in future if a video-upload UI is built.
  - **Reversibility:** Easy — additive (new bucket + mime value + RPC/UI) when needed.

- **Docs updated:** `docs/database-design.md`, `docs/database/01-tables-auth-identity.md`,
  `docs/database/02-tables-posts-comments.md`, `docs/database/03-tables-community-groups.md`,
  `docs/database/04-tables-events-marketplace.md`, `docs/database/05-tables-business-chat.md`,
  `docs/database/06-tables-notifications-search-moderation.md`,
  `docs/database/07-storage-buckets.md`, `docs/database/09-rpc-inventory.md`,
  `docs/database/10-open-decisions.md` (all three items marked RESOLVED in a new §0, old open
  items renumbered, nothing deleted).

---

## 2026-07-18 — Supabase MCP via hosted HTTP endpoint, committed at project level
- **Feature:** Tooling / backend workflow.
- **Decision:** Configure the Supabase MCP in `.mcp.json` using the **hosted HTTP transport**
  (`https://mcp.supabase.com/mcp`) instead of the local `npx @supabase/mcp-server-supabase`
  server. Committed `.mcp.json` to the repo (removed it from `.gitignore`).
- **Reason:** The hosted endpoint authenticates via **OAuth in the browser**, so no access
  token lives in the file — it is safe to commit and share with the whole team, which is what
  "project-level" MCP means. The prior `.mcp.json.example` (npx + `SUPABASE_ACCESS_TOKEN`) was
  kept only as a fallback template.
- **Alternatives:** (a) Local npx server with a `SUPABASE_ACCESS_TOKEN` env var — keeps the file
  gitignored, requires each dev to set a token; (b) user-level MCP config — not shared with the
  project. Rejected in favor of the zero-secret hosted config.
- **Reversibility:** Easy. Swap `.mcp.json` back to the npx template and re-add the `.gitignore`
  line if a token-bearing config is ever needed.
- **Follow-ups (open):**
  1. **Scope to Viora's project once it exists** — append `?project_ref=<viora-ref>` (and
     consider `&read_only=true` for day-to-day) to the URL so the MCP can only touch Viora's own
     project. Defense-in-depth alongside the `guard-supabase-project.mjs` hook.
  2. Paste the ref into `.claude/viora-project-ref.txt` so the guard hook enforces it.
  3. For the rebuild we will need **write** access (apply_migration / execute_sql /
     deploy_edge_function) — do not lock the URL to read-only during Phase 1.

---

## 2026-07-21 — Signup rows created by client DML, not a trigger or `signup_finalize()`

- **Feature:** Auth / signup (fixes the infinite loading spinner after Google sign-in).
- **Decision:** Add self-scoped INSERT policies on `"user"` and `user_roles`, grant
  `select, insert` on `user_roles` to `authenticated`, and create the missing
  `update_user_location()` RPC — so the **locked frontend's own direct-DML signup path works**.
  Do **not** add a trigger on `auth.users`, and do not repoint the frontend at
  `signup_finalize()`.
- **Reason:** Three DB gaps stopped any profile row from ever being created: no INSERT policy on
  `"user"`, zero table grants on `user_roles` (so its RLS policies were dead letters), and
  `update_user_location()` documented but never created. CLAUDE.md §1 makes the frontend the
  contract — it does direct DML at `login_page_widget.dart:1115` and never calls
  `signup_finalize()` — so the DB was matched to it. A trigger was rejected because the app
  detects a new user by "does a `public.user` row exist"; pre-creating that row makes every new
  Google user look like a returning user and silently skips `LocationPageWidget`, leaving the
  location-based feed with no location.
- **Alternatives:** (a) Trigger on `auth.users` — rejected, skips location onboarding;
  (b) repoint the frontend to `signup_finalize()` — rejected, requires changing locked frontend
  logic, and that RPC has no `profile_picture`/`country`/`cover_image` params so it cannot serve
  the Google path as-is.
- **Security note:** `user_roles.role` is an enum feeding the JWT via
  `custom_access_token_hook`, so a bare `id = auth.uid()` policy would have allowed self-promotion
  to `admin`. The policy pins `role = 'customer'` and no UPDATE/DELETE was granted. Verified
  blocked by simulated-client test. `update_user_location()` was also revoked from `anon`.
- **Reversibility:** Easy. Drop the two policies, revoke the grants, and drop the function.
- **Deviation logged:** this supersedes Batch 1's "no direct client INSERT policy" intent for
  `"user"`/`user_roles` (docs/rls-policies-draft.md Batch 8). §6.6's "no direct client DML" rule
  and the locked frontend conflict; resolved in favour of the frontend, revisit if unlocked.
- **Follow-up:** `signup_finalize()` is now dead but still executable by `authenticated` — drop or
  revoke it before launch.

---

## 2026-07-21 — Design audit against the taste skills: removed residual SQUADD brand debris

- **Feature:** Flock UI redesign (audit pass, no logic changes).
- **Audit basis:** `.claude/skills/redesign-existing-projects/` checklist, run against live
  device screenshots of all five tabs rather than against the source alone.
- **Verdict:** the Flock token layer (palette, Sunrise gradient, Baloo 2 + Manrope, dark mode)
  passes. What failed was leftover SQUADD brand debris the redesign never reached — and it
  appeared on every screen, which is why it read as "the UI is not good".
- **Fixed (4):**
  1. **Bottom-nav selected icon was bright blue** on a pink-branded app, all 5 tabs. Cause: the
     nav loads pre-coloured PNGs from the old brand (`home_blue.png`, `community_blue.png`,
     `notification_blue.webp`, `loyalty_blue.webp`). Now tinted through the theme
     (`primary` selected / `secondaryText` idle) via `Image.asset(color:)`, whose default
     `BlendMode.srcIn` recolours artwork while preserving alpha. Also normalises the icon set,
     which previously mixed fill weights.
  2. **`greenColor1`/`greenColor2` were still SQUADD green** (`#128F63`). All 31 call sites
     across 8 files were checked first — every one is a SELECTED filter/tab chip, none carry
     success semantics — so the two tokens were retinted to brand instead of editing 8 files.
  3. **Notification empty state** `📭 No Notifications Yet` / "Stay tuned! ..." broke three audit
     rules at once (exclamation, Title Case, vague filler). Now "Nothing new yet" / "When
     neighbours react, invite or message you, it shows up here." (6 instances).
  4. **Skeleton shimmer was `Color(0xB2FFFFFF)`** — 70% opaque white, correct on a light
     skeleton but a flashing white slab on dark. Added a `shimmerHighlight` theme token
     (light `0xB2FFFFFF`, dark `0x33FFFFFF`) and replaced **114 hardcoded occurrences across
     13 files**.
- **Regression caught during verification:** tinting flattened the two-tone create button
  (`post_blue/grey.png` — a light plus cut into a diamond) into a solid shape, losing the plus.
  Those two are now explicitly NOT tinted, with an inline comment explaining why. Found only
  because the fix was screenshotted on-device, not assumed.
- **Deliberately NOT changed:** (a) filter chips clipped at the right edge — that is a
  horizontal-scroll peek affordance, not a bug; (b) the empty home feed renders nothing, but the
  feed is empty because the rebuilt database has no posts yet, so adding conditional empty-state
  rendering into a 1662-line generated widget would be guessing at the cause.
- **Reversibility:** Easy — all four are token or single-attribute changes. `flutter analyze`
  reports 0 errors across `lib/`; each fix was verified on-device before moving on.

---

## 2026-07-21 — App-wide polish sweep: colour compliance, micro-interactions, empty states

- **Feature:** Flock UI/UX pass across all 158 screen widgets. No logic changes.
- **Method:** Wrote `docs/design/flock-interaction-spec.md` as a single shared recipe, then ran six
  agents partitioned by directory (registration / home+post / group / profile / sale+business /
  events+chat+search+notification+components) so no two could touch the same file. A shared spec
  was essential — six independent agents would otherwise have invented six animation styles.
- **"Green active buttons" had FOUR distinct sources**, not one: hardcoded `#0F8849` (chat filter
  chips), `.secondary` teal on Creator/Admin badges (10 copies across 6 group screens, plus
  search, community, other_profile, user_profile), a literal `0x130B7A52` tab tint (marketplace),
  and the `@mention` highlight in `lib/custom_code/`. All now `.primary`; zero remain.
- **The eye icon had no `color:` at all** on all 10 password fields — it inherited the default
  icon theme. Now `.secondaryText`.
- **~260 `splashColor: Colors.transparent`** (FlutterFlow's default) replaced with a real ripple,
  plus haptics on meaningful actions. This, more than colour, is why the app felt lifeless.
- **18 lists now stagger in**; chips animate colour via `AnimatedContainer`; empty-state art
  enters with `easeOutBack`.
- **7 empty-state illustrations authored in-house** (SVG → PNG via sharp; no new dependency).
  Deliberately mid-tone so ONE asset reads on both light and dark instead of needing two sets.
  First cut placed the ground shadow at a fixed Y, which left it floating detached under the
  shorter compositions — regenerated with a per-illustration ground position.
- **Bugs the sweep surfaced that were never reported:** chat send icon was `.info` blue on a pink
  fill; the marketplace category arrow was `theme.white` on an unfilled container (invisible in
  dark mode); 21 RSVP icons had no colour.
- **Known gaps (not claimed as done):** small action-sheet components got colour + ripple but not
  a full haptic/stagger pass; `user_profile_widget.dart` (5711 lines) likewise. The 50 remaining
  `0x000B7A52` literals are alpha-`00` (invisible) — cosmetic debt only.
- **Safety:** full `lib/` backup taken before the sweep (the redesign is uncommitted, so
  `git checkout` would have destroyed it). `flutter analyze` → 0 errors at every checkpoint.

---

## 2026-07-21 — Unified the tab top bar (avatar + search + chat)

- **Symptom (owner):** "the top bar size is different in each tab."
- **Cause:** the top bar is NOT a shared component — it is hand-copied into each of the four
  tab roots (`home_page`, `community`, `notification`, `sale`) and the copies drifted. Three
  independent mismatches: avatar diameter (38 on home vs 32 elsewhere), avatar STYLE
  (`GradientAvatarRing` on home/community, a plain `ClipRRect` on notification/sale), and the
  search field radius (4 vs 16).
- **Decision:** converge all four on one spec — `GradientAvatarRing(diameter: 38, ringWidth: 2)`
  with the ring sizing its own child (no width/height on the inner `Image.network`), and
  `BorderRadius.circular(designToken.radius.md)` on the search field. Notification and sale also
  gained the missing `HapticFeedback.lightImpact()` on the avatar tap.
- **Why the radius TOKEN and not a `16.0` literal:** four hand-maintained copies is exactly how
  this drifted in the first place. A shared token means a future change moves all four together.
- **Verified:** all four headers captured on-device, cropped to the header band and stacked —
  avatar left edge, search start/end and chat icon land on identical x-coordinates. 0 analyze errors.
- **Known remaining risk / recommendation:** this fixes the symptom, not the structure. There are
  still FOUR copies of the top bar, so it can drift again. The real fix is extracting a shared
  `CompTopBar` widget (like the existing `comp_navbar`). Not done unasked — it is a structural
  change to FlutterFlow-generated code (CLAUDE.md §2 "do not restructure frontend"). Raise with
  the owner before the next feature touches these screens.

---

## 2026-07-21 — Marketplace skeleton spun forever: `get_sales_home_data` raised 42702

- **Symptom (owner):** "why the skeleton loader loading infinitly" on the marketplace tab.
- **NOT empty data.** I had twice told the owner this was "empty data, not UI" without checking.
  That was wrong. Pulling the device log showed a live SQL failure on every load:
  `42702 column reference "distance_km" is ambiguous`.
- **Cause:** `get_sales_home_data` is `RETURNS TABLE(id, created_at, ..., distance_km)`. In
  PL/pgSQL, RETURNS TABLE column names are ALSO variables in the function body. The final
  `ORDER BY distance_km` matched both the `candidates` CTE column and the OUT variable.
  `created_at` and `id` in the same ORDER BY were the same latent bug — Postgres only reports
  the first conflict it reaches.
- **Failure chain:** RPC raises -> `getSaleHomePage` (`lib/custom_code/actions/`) hits its
  `throw Exception(...)` branch -> the widget's loading flag is never cleared -> skeleton loops.
  A crash that presents as an infinite loading state.
- **Fix:** aliased the CTE (`from candidates c`) and qualified every ORDER BY reference, fixing
  all three collisions rather than only the reported one. Server-side only, no app rebuild.
- **Verified:** both `Newest` and `Closest` sort paths execute as a simulated authenticated
  caller; device log shows zero ambiguity errors after the change.
- **Swept for recurrence:** scanned all 159 `public` plpgsql set-returning functions for OUT
  column names referenced unqualified in an ORDER BY. Nine hits were all `p_limit` inside
  `LIMIT p_limit` (an IN parameter — regex false positives). No other function is affected.
- **Lesson (also added to the backend-dev playbook):** an infinite skeleton is a FAILED request
  until proven otherwise. Read `adb logcat` before theorising about empty data. Any custom action
  that `throw`s on non-200 will present its failure as a permanent loading state, because the
  FlutterFlow widget has no catch to reset the flag.

---

## 2026-07-21 — Full frontend↔backend wiring audit

Inventoried every backend endpoint the locked frontend calls and checked each one exists AND runs.

**RPCs — 62 called, 60 existed. Two gaps:**
- `search_profiles(p_search)` — **CREATED**. Powers @mention autocomplete in all three composers
  (`mention_text_field_widget`, `comment_mention_text_field_widget`, `mention_text_field_widge_edit`);
  the feature was silently dead everywhere. `SECURITY DEFINER` is required, not INVOKER, because
  the two-way block filter calls `is_blocked_pair()`, which is deliberately not granted to
  `authenticated`. Returns id/name/profile_picture, excludes self and soft-deleted users, prefix
  matches ranked first, capped at 20.
- `upsert_user_device(p_device_id, p_player_id)` — **NOT built, deliberately.** Its only caller,
  `oneSignalNotification`, is exported in `custom_code/actions/index.dart` but invoked NOWHERE.
  The live push path is FCM via `upsert_user_device_fcm`, which exists and works. Building it
  would also need a new `player_id` column on `user_devices`. Building schema for dead code is
  worse than leaving the gap documented.

**Edge functions — all 9 called by the app exist and are ACTIVE** (authenticate-user,
change-password, check-user, check-user-exist, generate-tldr, phone-signup, reset-password,
send-otp, verify_otp), plus send-notification.

**Tables — 39 referenced, 38 exist.** The only miss is `community`, whose concept was
deliberately dropped (decision 2026-07-19); `CommunityTable()` is never queried — the generated
Row class is a leftover artifact. `audit_log` exists and is intentionally untouched by the client.

**Runtime smoke test — 46 read RPCs invoked as a simulated authenticated caller:**
- 37 passed.
- 7 "failures" were `P0001` guards firing correctly on NULL input ("caller is not an admin",
  "post not visible to caller", "group not found"). Those are the security model working.
- `find_common_chat` hit a not-null violation on NULL input — it is find-or-create, so a write
  path; not a bug, and nothing was mutated (chat/chat_users still 0 rows, verified).
- **`tag_search` was a REAL bug — `42883: function similarity(text, text) does not exist`.**
  pg_trgm lives in `extensions` but the function pinned `search_path` to `public, pg_temp`.
  It failed for EVERY input, not just non-empty searches, because the name must resolve at plan
  time regardless of which CASE branch runs. Fixed by qualifying `extensions.similarity(...)` and
  adding `extensions` to the pinned path. Same defect class as `get_sales_home_data`'s PostGIS use.
  Swept for recurrence: no other function references pg_trgm/PostGIS without a resolvable path.

**Limitation, stated honestly:** write RPCs (create_post, send_message, rsvp_event, etc.) were
NOT smoke-tested, because invoking them would mutate real data. They are verified to EXIST with
the expected argument names; whether each runs cleanly is unproven until exercised through the app.

---

## 2026-07-21 — RPC signature audit (call payloads vs function parameters) + dead-code lockdown

- **Why:** PostgREST resolves an RPC by matching the JSON body keys to parameter NAMES. One
  renamed or missing parameter = 404 at runtime, invisible until a user taps the button. This is
  the exact class that hid `update_user_location` (missing) and `search_profiles` (missing).
- **Method:** parsed every RPC call payload out of `api_calls.dart` (per-class) and
  `lib/custom_code/**` (per call site), then diffed against `pg_proc.proargnames` in BOTH
  directions: keys the app sends that no parameter accepts, and required parameters (no default)
  the app never sends.
- **Result: 0 mismatches across all 59 endpoints.** No unknown keys, no omitted required params.
  The RPC layer is signature-correct end to end.
- **Correction to my own work:** an earlier pass reported `insert_sales_details` as missing
  `p_userid`. That was FALSE — I hand-transcribed the VALUES list into SQL and dropped the key.
  The generated extract always had it. Re-ran from the generated text verbatim; clean. Lesson:
  never retype generated data into a query — emit it programmatically.
- **`signup_finalize()` revoked from `anon` and `authenticated`.** It is SECURITY DEFINER and was
  reachable at `/rest/v1/rpc/signup_finalize`, but nothing in `lib/` calls it (the frontend does
  direct DML instead — see the 2026-07-21 signup decision). Live attack surface for an unused
  path. REVOKE not DROP, so a single GRANT restores it if the frontend is ever repointed.
- **Still open, deliberately:** write RPCs (create_post, send_message, rsvp_event, create_group,
  insert_sales_details...) are signature-verified but NOT runtime-tested, because invoking them
  would mutate real data. They must be exercised through the app to be considered proven.

---

## 2026-07-21 — UI Wave 1: mechanical consistency sweep (9 parallel agents)

- **Why:** the full-codebase UI review (`docs/design/ui-review-2026-07-21.md`) found the Flock
  design system is sound but the screens don't consume it. Wave 1 = the mechanical, no-design-input
  subset, split across 9 agents by **file domain** (not by task type) so no two agents ever held
  the same file. Task-splitting would have put five agents inside `search_widget.dart` at once.
- **Decision — bottom nav stays icon-only at 54dp; screen readers fixed via `Semantics` only.**
  Owner choice. Re-enabling the 10 disabled text labels would require growing the bar to ~64dp and
  shifting every screen's bottom inset. Accepted trade-off: TalkBack/VoiceOver now work, but new
  users still must learn 5 glyphs. Revisit only on user-testing evidence. Reversible.
- **Decision — `print()` gated, not deleted.** 439 bare `print()` shipped in release builds
  (frame cost on realtime hot paths + user/session data leaking into `adb logcat` and Xcode
  Console). Agents removed 69 that were FlutterFlow placeholder stubs. The remaining 370 live in
  `lib/custom_code/actions/**` and **50 are inside `catch` blocks** — deleting those would convert
  logged errors into silently swallowed ones, which §5 forbids. Built `lib/flutter_flow/app_log.dart`
  (`appLog` / `appLogError`, both `kDebugMode`-gated) and swapped all 370 across 30 files.
  Diagnostics preserved in debug, stripped from release. Reversible.
- **Decision — `if (false)` branches inventoried, not touched.** All 65 catalogued in
  `docs/design/if-false-inventory-2026-07-21.md` with a per-branch backend-risk column, because the
  Supabase rebuild means a "pure-UI" branch may read a column that no longer exists. Owner decides
  per area. Nothing enabled, nothing deleted.
- **Decision — theme-invariant overlays keep their literal colours.** `Color(0x1AFFFFFF)` (the
  translucent-white "Ending Soon" / "Sold out" pills drawn over arbitrary user photos behind a
  `BackdropFilter`) was deliberately NOT tokenised. Nearest token `accent4` is `0xCCFFFFFF` — 80%
  opaque and theme-varying — which would invert in dark mode and destroy an intentionally
  theme-invariant overlay. Applies in `sale_widget`, `ending_event_widget`, `latest_event_widget`,
  `community_widget`.
- **Method correction (important, affects future audits):** the review's census used single-line
  `grep`. `dart format` wraps long argument lists at deep nesting, so `GoogleFonts\n  .interTight(`
  and `fontSize:\n  10.0,` were invisible. Real counts were 2-4x higher than reported (e.g.
  `lib/pages/group/**`: 75 Inter sites, not 19; 59 colour literals, not 14). Those wrong counts were
  pasted into agent briefs as targets, and at least two agents reported "all fixed" while wrapped
  instances remained — caught only by independent multiline re-scan. **Standing rule: never census
  FlutterFlow Dart with a single-line grep.** Use `Grep(multiline: true)` with `\s*\n\s*`-tolerant
  patterns. The review doc carries this correction inline.
- **Verification:** `flutter analyze` across all of `lib/` — **0 errors**. 3,157 warnings, all
  pre-existing codegen categories (`unused_import` 2164, `unnecessary_non_null_assertion` 598, …);
  zero attributable to this pass or to the 5 new component files.
- **Still open (needs owner input):** the event grid `childAspectRatio` change (12 sites in
  `community_widget` left at 10px because the card already overflows at 360dp *today*, pre-existing);
  the two `post_blue.png` / `post_grey.png` nav assets still carrying the OLD pre-Flock blue; and
  whether the 22x22 unread badges may grow to survive >1.3x system text scale.

---

## 2026-07-21 — UI Wave 2: shared-component adoption (7 parallel agents)

Same domain-split as Wave 1 (by folder, never by task) so no two agents held a file. Verified end
state: `flutter analyze` across `lib/` → **0 errors**; warnings 3157 → 3153 (all pre-existing
codegen categories).

| Metric | Before | After |
|---|---|---|
| `Semantics` nodes | **0** | 165 |
| Cached images (`AppNetworkImage`) | 0 | 170 |
| ≥44dp icon buttons (`AppIconButton`) | 0 | 100 |
| Error states (`AsyncStateView`) | **0** | 42 |
| `EmptyState` sites | scattered/none | 26 |
| Screens with pull-to-refresh | 3 | 21 |

### Decisions
- **Post tab icon → code-drawn, not re-exported.** `post_blue.png` still carried the OLD pre-Flock
  blue in the primary nav. `flutter_svg` is not a dependency and §2 forbids adding one, so built
  `lib/components/post_tab_icon.dart` — a 45°-rotated rounded square in `theme.primary` with a
  counter-rotated "+" knockout. Now tracks raspberry in light / `#FF6F94` in dark automatically.
  The agent decoded both PNGs pixel-by-pixel (IHDR/IDAT parse) rather than eyeballing, and caught
  that its first constants were 25% too big; final silhouette matches to ~1%. Known imperfection:
  the two source rasters disagree with each other on stroke weight (blue 4px, grey 6px), so the
  new glyph splits the difference and is a pixel match to neither.
- **Event grid `childAspectRatio` 0.52 → 0.47** in `latest_event`, `ending_event` AND
  `community_widget` (×2 — found only because the events agent flagged it across a scope boundary).
  These cards **already clipped at 360dp before any of our changes**: cell = 155/0.52 = 298.1dp,
  chrome = 176dp, leaving 122.1dp for 137.2dp of content. At 0.47 → 153.8dp available, +16.6dp
  headroom. The `Container(height: 316/320)` on those cards is dead code — `SliverGridDelegate`
  passes `BoxConstraints.tight`, so ratio is the only lever. Left in place with an explanatory
  comment rather than deleted (out of scope, but it will mislead the next reader).
- **Notification card density — compromise, not the 44dp default.** Fitting 44dp targets grew the
  card 64 → 84.8dp (+33%) on a scanning screen. My first hypothesis (the row is already ≥44dp, so
  the target should fit free) was **wrong** — measured, the 64dp is 40dp content + 24dp padding, and
  the button is a `Column` sibling below the timestamp so heights add. The **header** was fully
  recoverable at zero cost (padding 12→9; `44+9+9 == 38+12+12 == 62dp`, every child re-centring to
  its exact original y). The **card** was not, so: All tab → `(20,4,20,4)` = 68.8dp (+7.5%); the five
  full-bleed tabs → `(20,6,20,8)` = 74.8dp (+17%) because they butt against a 1dp border and
  `(20,4,20,4)` would have cut neighbour content gap to 10dp. Rejected `Align(heightFactor:)` — it
  would look like a 44dp target while `RenderBox.hitTest` silently collapsed it to ~22dp.
- **`AppSkeletonList` made public** (was private `_ShimmerSkeletonList`). Two profile screens were
  stuck on a divergent `SimpleLoader` purely because the shimmer wasn't reachable outside
  `AsyncStateView`. Now on the single app-wide loading treatment, with `liveRegion` labels.
- **`shrinkWrap: true` → `Sliver` (92 sites) NOT done, deliberately.** Real perf win, but it is
  structural surgery on generated 5-10k-line files, §5 forbids restructuring the frontend, and we
  cannot run the app to verify. Breaking scroll on Search/Notifications would be far worse than the
  jank it fixes. Sequence: device-verify Wave 2 first, then convert one screen at a time with eyes on.
- **Existing `CompNoDataFoundWidget` empty states kept** rather than swapped for `EmptyState`.
  They already carry 160dp illustrations and good copy; replacing them with an icon-badge would be a
  downgrade and pure churn. `EmptyState` was added only where a list could previously render nothing.
- **`comp_no_data_found_widget.dart` NOT made scrollable.** Doing so would enable pull-to-refresh on
  empty states, but the safe recipe (`LayoutBuilder` + `ConstrainedBox` + `IntrinsicHeight`) crashes
  if any parent passes unbounded height, and the component is used by 27 screens whose parents were
  not audited. Correct fix is per-call-site (as done in `all_groups`/`nearest_groups`). Follow-up.

### Bugs found and fixed while adopting (none were in the brief)
- `comments_page` empty state never fired — it tested for `null` but the API returns an **empty
  list** for an uncommented post, so the most common case rendered a blank area.
- `supabase.channel(topic)` does **not** dedupe — naive refresh wiring would have added 5 realtime
  channels per pull. A fetch-only module (`lib/pages/group/group_list_refresh.dart`) was built instead.
- `getSaleHomePage` throws on non-200 uncaught → infinite refresh spinner, and a permanently
  stranded skeleton from `initState`. Now guarded.
- `other_profile` loading branch was `Expanded` inside a `Column` inside a `SingleChildScrollView`
  — a latent `RenderFlex … unbounded` crash.
- `message_page` runs `MessagesTable().queryRows()` with **no `limit`/`range`** and realtime re-runs
  it on every inbound message — the whole thread, every time. Pull-to-refresh was correctly SKIPPED
  there (it would snap the user from the oldest message back to the newest); the real feature is
  load-older-on-scroll-up, blocked on backend pagination. **Backend-dev item.**

### Incident
One agent ran `git stash` mid-pass while three others were writing, then `git stash pop`. It
self-reported rather than hiding it. Independently verified by the lead: stash list empty, no
conflict markers, and every Wave 1 + Wave 2 marker present. No work lost. A "never `git stash` in
this repo" rule is now at the top of the frontend-dev playbook.

### Open / carried forward
- Two card designs for one content type in Notifications (All tab = floating shadowed card; the five
  filtered tabs = full-bleed bordered rows). Real inconsistency, bigger than a padding fix.
- Notification row border uses `greyL2` rather than the semantic `theme.alternate` divider token.
- Home like button announces `'Like, N likes'` but never `'Liked, …'` — the filled-heart state lives
  in a nested `FutureBuilder` below the button; fixing it is a data-layer change.
- 16 `FlutterFlowIconButton`s in events/business still have no accessible name.
- Hardcoded Supabase project URL in `app_state.dart`, `api_calls.dart`, `get_sale_home_page.dart`
  — §5 violation, **backend-dev**.
- Not yet verified on a device: Android + iOS, notched hardware, Android "Largest" font scale.

---

## 2026-07-22 — Write paths were entirely blocked; RLS + feed contract fixed

Found by actually exercising the app on-device rather than reasoning about it.

**1. 16 of 22 tables the frontend writes to had NO write policy.** The backend was designed
RPC-first (writes via SECURITY DEFINER functions), but the locked frontend performs direct DML.
Creating a post failed with `42501 new row violates row-level security policy for table "post"`.
Every write feature was dead: posting, commenting, messaging, RSVP, selling, profile edits.
Added owner-scoped INSERT/UPDATE/DELETE policies for the unambiguous tables
(`owner_scoped_write_policies_batch_a`).

**2. The `INSERT .. RETURNING` trap - the subtle one.** After adding the INSERT policy the write
STILL failed. Proven by test: the same INSERT succeeds WITHOUT `RETURNING` and fails WITH it.
PostgREST always issues `INSERT .. RETURNING`, and Postgres applies the **SELECT** policy to the
RETURNING clause. The SELECT policies delegated to `can_view_post_self()` / `is_chat_member_self()`,
which are `STABLE SECURITY DEFINER` and cannot see the just-written row in their snapshot -> false.
Fixed by adding a direct ownership branch to each SELECT policy:
- `post`: `user_id = auth.uid() OR can_view_post_self(id)`
- `post_comment`: `user_id = auth.uid() OR ...`
- `chat`: `created_by = auth.uid() OR is_chat_member_self(id)`
- `messages`: `sender_id = auth.uid() OR is_chat_member_self(chat_id)`
- `post_images` / `tag`: owner-of-parent-post branch
This also fixes the related "my own post is missing from my feed" class of bug.
Also added the missing `chat_users` INSERT policy - without it a chat could be created but
never populated, so messaging could never work.

**3. Feed showed "null" for every author.** `get_visible_posts` was `RETURNS SETOF post` - raw
post columns. The feed card reads `user_name`, `user_profile_picture`, `user_city`, `post_images`
(home_page_widget getJsonField paths), none of which existed. Rewrote it to join
`public_user_profile` and aggregate `post_images` as jsonb. Return-type change required
DROP+CREATE; adding fields is backward compatible since the client reads named JSON keys.

**Verified on device:** signup -> post -> feed renders author/city/avatar. `add_like` verified via
RPC (row + counter trigger). Comment, chat-create, add-participant and send-message all verified
as INSERT..RETURNING exactly as PostgREST issues them.

**Two of my own test errors, recorded so they are not repeated:** passing `p_post_status => NULL`
overrides the default and matches nothing (made a working feed look broken); and declaring the
counter columns `bigint` from memory when they are `integer` (42804). Read information_schema,
do not guess types.

**Deliberately NOT done - needs product rules first:** `group`, `group_members`, `group_admin`,
`group_user_status`, `group_members_invite`, `business_promote`, `reports` still have no write
policies. A careless predicate on `group_admin` would let any user make themselves admin of any
group. Who may join an open vs private group, and who may grant admin, are product decisions.

---

## 2026-07-22 — Group / business / report write policies (product rules confirmed)

Owner decisions (2026-07-22): **open group = join instantly** (no approval); **granting admin =
existing group admins only**.

**Policies added:** `group` (insert own / update admin-only), `group_members` (insert = admin OR
self-into-an-OPEN-group; delete = self or admin), `group_admin` (insert/delete admin-only),
`group_user_status` (self or admin), `group_members_invite` (invitee, inviter or admin),
`business_promote` (business-page owner only), `reports` (insert/delete/select own;
status changes stay admin-only via the pre-existing UPDATE policy).

**Bug I introduced and fixed in the same session:** the first version of the `group_admin` INSERT
policy carried a "bootstrap" clause containing `not exists (select 1 from public.group_admin ...)`
- a subquery on the very table the policy guards. Postgres rejects that with
`42P17 infinite recursion detected in policy for relation "group_admin"`. A policy cannot read its
own table. (The `is_group_*` helpers are SECURITY DEFINER and were never implicated.)

**Correct approach:** seed the creator server-side with a SECURITY DEFINER trigger
(`trg_seed_group_creator` on `public."group"`), which inserts the creator into `group_admin`,
`group_members` and `group_user_status` at creation. The policy can then stay strictly
"existing group admins only" with **no escape hatch at all**. Creating a group now also correctly
makes you its first admin and member in one step.

**Verified by simulated multi-user tests (2 real accounts):**

| Case | Result |
|---|---|
| Create open group | PASS |
| Creator auto-seeded as admin | PASS |
| Outsider self-promotes to admin | **blocked** |
| Outsider edits someone else's group | **blocked** |
| Outsider joins OPEN group instantly | allowed (per product rule) |
| Outsider joins PRIVATE group directly | **blocked** - approval required |
| Outsider requests to join PRIVATE group | allowed |
| File a report | PASS |
| File a report AS another user (spoof) | **blocked** |

**Known gap:** direct DML bypasses the last-admin guard that lives inside `delete_group_admin()`.
A group can therefore be left with zero admins via a direct delete. Enforcing that needs either a
trigger or routing deletes back through the RPC - flagged, not fixed.

---

## 2026-07-22 — UI test of like / comment / share (found 2 more real bugs)

Driven through the actual app on-device, not just SQL.

**PASS:** like (toggles both ways, `post_like` row + `likes_count` trigger), comment via the
composer ("Great to be here" -> `comment_count` 2), share sheet opens and resolves internal
share targets via `get_internal_share`.

**BUG 1 - comments page crashed with a red error box.**
`NoSuchMethodError: Class '_Map' ... Tried calling: toList()` on
`columnGetlimitedPostLikesResponse.jsonBody.toList()`. The response was not an array but a
**4-key PostgREST error object** (`{code, details, hint, message}` - matching the reported
`_Map len:4`). Root cause: `GetlimitedPostLikesCall` sends `p_screenwidth` as a Dart **double**
(Flutter's MediaQuery width is fractional, e.g. 411.4285714285714) while the parameter was
declared `integer`, so PostgREST could not resolve the overload. Fixed server-side: parameter
retyped to `numeric` and floored internally (`get_limited_post_likes_accept_fractional_width`).
Lesson: any RPC parameter fed from a Flutter dimension must be numeric, never integer.

**BUG 2 - internal share failed with 42501 on `messages`.**
The app's order is: create chat -> insert message -> add participants. At the message step the
chat has no `chat_users` rows, so `is_chat_member_self()` was false and the insert was rejected;
every retry orphaned another empty chat. Fixed server-side (frontend locked) by also accepting
the chat's **creator** in the messages INSERT policy. Security preserved: a caller may still only
send as themselves, into a chat they belong to or created. Orphaned empty chats cleaned up.

**Flagged, not fixed:**
- The share deep link is `https://app.closefuture.io/share_redirect_squadd?...` - carries the OLD
  brand name and points at a closefuture.io host. Needs a Flock decision before launch.
- Recurring non-fatal `invalid input syntax for type uuid: "null"` on some row queries - the app
  passes the literal string "null" as a uuid somewhere. Cosmetic today, worth tracing.

---

## 2026-07-22 — Share deep link, "null" uuid guard, and seeded test users

**1. Share link now opens the app, not a web page.**
Was `https://app.closefuture.io/share_redirect_squadd?pagename=..&id=..` (old brand + a
CloseFuture host). Now `flock://flock.app/loadingPage?pageName=..&postId=..`.
A second bug surfaced doing this: `comp_share_widget` sent `pagename`/`id` but the route
declares `pageName`/`postId` - the web redirect had been silently translating them, so
repointing at the app without renaming would have opened a blank loading page. Fixed in all 5
occurrences. Registered the `flock` scheme in AndroidManifest and iOS Info.plist; the legacy
`squadd` scheme is retained so links already shared still resolve.
**Tradeoff (flagged):** a custom scheme opens the app reliably when installed, but messaging apps
often do not linkify `flock://`, and there is no store fallback if the app is absent. The
production answer is App Links / Universal Links on an owned domain (assetlinks.json +
apple-app-site-association). Deferred until the domain exists.

**2. `invalid input syntax for type uuid: "null"` fixed at the source.**
FlutterFlow's `valueOrDefault<String>(x, 'null')` substitutes the TEXT "null"; `eqOrNull` only
skipped Dart null, so the string reached uuid filters and raised 22P02 on every affected query.
Added `_isAbsent()` in `lib/backend/supabase/database/table.dart` so `eqOrNull`/`neqOrNull` treat
the literal "null" as absent, on both the filter and stream builders. One central change removes
the whole class. Verified on device: 0 occurrences after rebuild (was firing repeatedly).

**3. Seeded 8 test neighbours + 8 posts.**
`anitha.rajan@flocktest.dev` .. `suresh.babu@flocktest.dev`, password `Flocktest2026`, real bcrypt
hashes with `email_confirmed_at` set so they can actually sign in. Each has the full row set
(`user`, `user_roles`, `public_user_profile`, `user_locations`) scattered within ~3km of Kodumudi
so distance/nearby logic has real variation.
**Gotcha worth remembering:** the app stores post `content` as a Dart map toString
(`{text: ..., mentions: [], timestamp: 1784...}`), NOT strict JSON. Seeding with `{"text": "..."}`
produced cards that rendered author and actions but NO body text. Rewritten to the app's own
format; feed then rendered correctly.

---

## 2026-07-22 — Last-admin guard + the realtime subscribe bug (my theory was wrong)

**Last-admin hole closed.** `trg_prevent_last_group_admin_removal` (BEFORE DELETE on
`group_admin`) blocks removing the final admin of a live group. Put at the TABLE rather than in
`delete_group_admin()`, so RPC, direct DML and future code are all covered. Deleted groups are
exempt. Verified: last admin -> blocked; one of two -> allowed.

**The subscribe bug was NOT the loading-page double-run.** The stack trace showed
`init_realtime_group_updates.dart` creates ONE channel and calls `.subscribe()` on it THREE times
(once per table). Supabase permits exactly one subscribe per channel instance, so this threw on
EVERY app start - the double-run only made it more visible. Fixed by registering all handlers and
subscribing once. Audited every realtime action: channels == subscribes everywhere now
(chat 4/4, manage_groups 3/3, rest 1/1).

**Two wrong turns of mine, recorded so they are not repeated:**
1. First fix assumed the cause was double invocation and added a `freshRealtimeChannel()` helper
   that called `client.removeChannel()` fire-and-forget, then immediately re-requested
   `client.channel(name)` - `removeChannel` is ASYNC, so the cached already-subscribed instance
   came back and the error persisted.
2. Second attempt fixed that race with unique topics (`name`, `name#2`, ...) - correct in itself,
   but still not the actual defect. Only reading the stack trace found it.
The helper is retained: it genuinely makes repeat invocation safe. But the lesson is to read the
stack before theorising about a cause.

**Verified on device after rebuild:** `subscribe multiple times` 0, `RangeError` 0,
`invalid input syntax for type uuid` 0, and zero `E/flutter` lines on a cold start.

---

## 2026-07-22 — Marketplace filter semantics + four brand/copy fixes

**`get_sales_home_data` matched nothing on a fresh open — the app's own defaults were the bug.**
The RPC was correct in isolation; the app sends `p_category = 'All categories'` and
`p_type = 'Fixed'` from `FFAppState().SalesFilter` / `SalesTypeFilter`. Two mismatches:
`'All categories'` was compared literally against real category names, and `'Fixed'` was compared
against `e_sale_type` (`selling`/`sold`) when it is actually an **`e_price_type`** — the UI chips
are Free/Fixed, so `p_type` has always been the *price* filter. Every user's marketplace would
have been empty on first open. Migration `get_sales_home_data_match_frontend_filter_semantics`
treats `'All categories'`/`'all'` as no-filter and compares `p_type` against `e_price_type`.
Verified: app defaults -> 1 row, `Free` -> 0 rows, `Sports` + Closest -> 1 row, renders on device.

**Four brand/copy defects fixed (all flagged during testing, all user-approved):**

1. *Create Group / Create Event cover placeholder was old-brand blue.* `Header_(1).webp` (blue
   dots) replaced with a generated `assets/images/group_cover_placeholder.png` in the Flock
   palette (rose #FF6F94 / coral #FF9142 / amber #FFD166 on cream), deliberately low-contrast so
   it reads as an empty slot rather than artwork. Same asset was used by BOTH create screens.
2. *Group Type helper text was a verbatim copy of Discoverability's.* Both info boxes read
   "Groups visible on member profiles are listed...", which describes listed/unlisted, not
   open/private. The Group Type box now reads "Anyone can join an open group instantly. Private
   groups need admin approval." — which also matches the agreed product rule (open = join
   instantly).
3. *Marketplace empty state used the old grey `Layer_1.webp`.* Repointed `sales`, `yourslisting`
   and `salesfree` in `comp_no_data_found_widget.dart` to the Flock `empty_market.png`.
4. *Prices rendered in `£`.* Six hardcoded occurrences across sale / sale_details / search.
   **Decision:** rather than re-hardcoding `₹` six times, added `lib/app_constants.dart` with a
   single `kCurrencySymbol` const and referenced it from all six. Reason: one place to change if
   the app ever ships outside India. Alternative considered — a per-listing currency column —
   rejected as scope creep with no product requirement behind it. Reversible: delete the file and
   inline the literal.

**Still on the user to do (needs Supabase dashboard, no service-role key in this session):**
the *stored* default cover URL
`squadd/default_cover_image/Header_(1).webp` is written into `group`, `business_page` and user
cover rows (3 constants in `lib/app_state.dart`, 2 comparisons in the profile widgets), so
existing rows still point at the blue art. Overwriting that one storage object in place with
`assets/images/default_cover_image_flock.webp` fixes every existing and future row with no code
change and no data migration. Not done here because uploading needs a service-role key, which is
deliberately kept out of this session.

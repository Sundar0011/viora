# Viora — Roadmap & Status

Single glance at where the backend rebuild stands. Update as phases complete.

## 0. Foundation (project setup)
- [x] `CLAUDE.md` rulebook (Flutter + Supabase, Android+iOS, security model)
- [x] Agent team defined (`.claude/agents/`) + self-improving playbooks (`docs/agent-playbooks/`)
- [x] Skills installed (3× flutter, 2× supabase, ui-ux-pro-max)
- [x] Guardrail hooks (secret-block, supabase-project-guard, dart-format, playbook-reminder)
- [x] Permissions allowlist + slash commands (`/feature`, `/rls-audit`, `/scope-check`, `/deploy`)
- [x] `.gitignore` added
- [ ] **Create Viora's own Supabase project** → paste ref into `.claude/viora-project-ref.txt`
- [ ] **Connect Supabase MCP** → copy `.mcp.json.example` → `.mcp.json`, fill ref + set
      `SUPABASE_ACCESS_TOKEN`, restart Claude Code
- [x] Extract full backend contract from frontend → **`docs/features/` (13 feature specs + index)**

## 1. Backend rebuild (Supabase, from scratch) — IN PROGRESS (project `hlmymmlkgirafodcnkgg`)
Applied in ordered batches under `supabase/migrations/`. Each batch: author SQL (backend-dev) →
review → apply via MCP → `get_advisors` → RLS reviewed before policies apply.
- [x] **Batch 1 — Identity/Auth foundation** (0001–0006): extensions (pgcrypto, PostGIS),
      `app_role` enum, `"user"` / `user_roles` / `public_user_profile` / `user_login` /
      `user_devices` / `user_locations` / `audit_log`, JWT role hook, `signup_finalize`,
      `is_admin()`, `updated_at` triggers, and identity RLS. Advisors clean.
- [x] **Batch 2 — Posts, Comments, Likes, Shares, Tags, view-access, Blocks** (0007–0016):
      3-level post visibility (Everyone/Friends/Nearby, no community), two-way blocking (enabled),
      ~30 RPCs with backend pagination/filtering, counter triggers, full RLS. Advisors clean.
      Follows-dependent bits (Friends visibility, internal-share scoping) deny-close until Batch 3.
- [x] **Batch 3 — Neighbors/Follows** (0017–0023): `follows` table, follow/unfollow toggle,
      followers/following lists, nearby-people (PostGIS), follower/following counter triggers.
      **Friends-only post visibility now live** (can_view_post uses real follows). Advisors clean.
- [x] **Batch 4 — Groups** (0024–0034): 5 tables, request→approval state machine, admin roles,
      invites, in-group + user-level block, member-count triggers, discoverable-private-group RLS,
      `post.group_id` FK. `get_user_following_groups_with_status` (deferred from B3) built. Advisors clean.
- [x] **Batch 5 — Events, Marketplace & Storage** (0035–0052): event_page/event_attending (RSVP,
      time-based lifecycle, attendee triggers); sale/sale_category/sale_images (server-side
      distance/filter/sort browse, sold-state, sale_count trigger); **9 storage buckets + object
      RLS** (strict ownership). Backfilled the B3 event-invite stub. Advisors clean.
- [x] **Batch 6 — Business & Chat** (0053–0067): business_page/promote/plans/contacted (promotion
      state machine, admin moderation, public contact count); chat/chat_users/messages (find-or-create,
      send/read, block enforcement, preview trigger); **private authorized Broadcast realtime** (fn +
      trigger applied; the realtime.messages policy needs a CLI/Dashboard apply — see below).
      Storage helpers for business/receipts activated. Advisors clean.
- [x] **Batch 7 — Notifications, Search & Moderation** (0068–0084): `reports` (polymorphic) +
      report RPCs (activated the report_business stub); trigger-driven notifications + `notify()` +
      `get_notifications`; FCM `send-notification` edge function (deployed) + best-effort push
      trigger; `pg_trgm` search (`get_search_all_data`/`get_search_data`/`tag_search`) + `search_history`.
      Advisors clean.

**✅ Phase 1 (backend rebuild) is FUNCTIONALLY COMPLETE — 39 tables (100% RLS), 159 functions,
51 policies, 9 buckets, 1 edge function.** All 7 batches applied to `hlmymmlkgirafodcnkgg`.

### ⚠️ Manual steps to finish enabling everything (privileged / config — MCP can't do these)
- [ ] **Enable the Auth JWT hook** (Dashboard → Auth → Hooks → Custom Access Token →
      `public.custom_access_token_hook`) — until then roles aren't in the JWT (`is_admin()` etc. blind).
- [x] **Applied the two `realtime.messages` receive policies** (chat `0064`, notifications `0082`)
      via the Dashboard SQL editor — both policies present (`chat_broadcast_receive_authorized`,
      `notifications_broadcast_receive_own`). Frontend still needs repointing to the private topics
      (see follow-ups below).
- **FCM push** — `pg_net` ✅ enabled (`net.http_post` verified). Firebase migrated to Viora's own
  project **`viora-b75f7`** (Android/iOS/web configs + Google OAuth client IDs swapped; see
  decisions 2026-07-19). GUC approach dropped — hosted Supabase forbids `alter database … set`
  (superuser-only); replaced by **Vault** (`0087_push_trigger_vault.sql`). Remaining to go live:
  - [ ] Set `FCM_SERVICE_ACCOUNT_JSON` Edge Function secret (service account from `viora-b75f7`).
  - [ ] Store the service-role key in Vault: `select vault.create_secret('<key>','service_role_key',…)`.
  - [ ] iOS only — upload the **APNs `.p8` auth key** to Firebase → Cloud Messaging.
  - [ ] A real device logged in (writes its `fcm_token` to `user_devices`) — push targets only these.
  - [ ] Before launch — add **release/upload key SHA** + **Play App Signing SHA** to Firebase Android.
- [ ] **Seed lookup tables:** `sale_category`, `business_promote_plans` (empty → those dropdowns are blank).
- [ ] **Rotate the leaked `sk_live_` key** and move it server-side (see Security remediation below).
- [x] **Point the app at Viora** — `environment.json` anon key + swept old ref → Viora across
      `lib/` (97 refs). `secretKey` blanked (still needs rotation).
- [x] **9 auth/utility edge functions built + deployed** (10 total incl. send-notification):
      REAL — `authenticate-user` (login credential check), `check-user-exist`, `check-user`,
      `phone-signup` (no OTP gate, drops leaked x-secret-key), `change-password` (owner-only,
      verify_jwt on). STUBS (deferred, honest 503 / empty) — `send-otp`, `verify_otp`,
      `reset-password`, `generate-tldr`. **Password login + Google work end-to-end; OTP-gated
      signup/forgot-password blocked until a SMS/email provider is chosen** (or a frontend
      OTP-bypass for this phase).
- [ ] **Upload default images** (profile/cover/business) into Viora's `squadd` bucket (app_state.dart
      default URLs now point there).

### Frontend follow-ups (approved §2 exceptions — coordinate with frontend-dev)
- [ ] Wire pagination + backend-filtered/new RPCs on over-fetching screens (decision #11).
- [ ] Repoint chat + notification realtime to the private Broadcast topics (`chat:{id}`,
      `user:{id}:chats`, `user:{id}:notifications`); remove the old public channels.
- [ ] Verify post-image upload happens create-before-upload (strict storage policy).
- [ ] Apple Sign-In is declared but not wired (App Store blocker — feature 01 §8).
- [ ] Confirm the open `TODO(confirm)` items in `docs/database/10-open-decisions.md`.

## 2. Verify & ship
- [ ] tester: RLS/RPC security + Android+iOS parity
- [ ] security-reviewer: full audit (`/rls-audit`)
- [ ] release-deployment: Google Play + App Store

---

## 🔒 Security remediation (do early)
1. **Rotate the leaked `sk_live_` secret.** It is committed in
   `assets/environment_values/environment.json` and already in git history → treat as compromised.
   Rotate it at the provider now.
2. **Move the secret server-side.** `api_calls.dart` sends it as `x-secret-key`. During the
   rebuild, replace that direct client call with a Supabase Edge Function that holds the secret;
   the client authenticates with the user's Supabase JWT instead.
3. **Decide on the tracked config files.** `environment.json`, `google-services.json`, and
   `GoogleService-Info.plist` are tracked. Decide (with the user) whether to `git rm --cached`
   them and distribute via `.example` + secure channels. (High-impact → ask before doing.)

# Feature: Business Pages & Promotions

> Source of truth = the Flutter frontend. This doc records what the backend MUST provide
> for this feature to work. Derived from `lib/` — do not invent behavior the code doesn't show.

## 1. Overview
- **What it is:** Lets a community user create a business page (name, bio, services, contact
  details, profile/cover images), view it on a business home page, and let other users contact
  the business (website / email / phone). Owners can promote a page by picking a paid plan,
  uploading a payment receipt, and going through an admin-moderated promotion lifecycle
  (under review → live → ended, or rejected/mismatch). Pages can be reported, soft-deleted,
  and restored; contact taps are tracked as a "contacted" count.
- **Why it exists / user value:** Local businesses get a presence and paid visibility inside a
  neighborhood community; residents can discover and reach them.
- **Related features:** Reports/moderation (shared `reports` table), Chat (contacting via chat
  from business home), Communities (`community_id` scoping), Storage/images.

## 2. Screens & widgets
| Screen / widget (path under `lib/`) | Purpose | Key actions |
|---|---|---|
| `pages/business/create_page/` | Create OR edit a business page (`pageType == 'create'` / else edit) | Validates 6 form fields, uploads profile+cover images, `insert`/`update` `business_page` |
| `pages/business/my_pages/` | Owner's list of their business pages + promotion state routing | Reads `get_my_business`; on tap routes to Promote / UnderReview / Mismatch / Ended / Live / Rejected sheets based on `promotion_status` |
| `pages/business/business_home_page/` | Public business profile view | Reads `get_business_details`, contacted count; opens contact sheet; starts chat (`ChatTable().insert`) |
| `pages/business/comp_business_contact/` | Bottom sheet: website / email / phone | Each tap calls `update_contacted` RPC then launches URL/mail/tel |
| `pages/business/promote_business/` | Choose a promotion plan | Loads `business_promote_plans` ordered by price asc; passes chosen `planid` to upload_receipt |
| `pages/business/upload_receipt/` | Upload payment receipt + reference number | Uploads to `promote-receipts` bucket; `insert`/`update` `business_promote` with `status='under review'` |
| `pages/business/comp_promotion_received/` | Confirmation after receipt submitted | Informational only ("We've received your payment details") |
| `pages/business/comp_under_review/` | Promotion under admin review state | Informational |
| `pages/business/comp_mismatch/` | Payment details mismatch — resubmit | `update` `business_promote` reference_number + `status='under review'` |
| `pages/business/comp_promotion_is_live/` | Promotion live state (shows plan end date) | Informational / review |
| `pages/business/comp_promotion_ended/` | Promotion ended — renew | Route to renew (new promotion) |
| `pages/business/comp_promotion_rejected/` | Promotion rejected (refund note) | Route to renew |
| `pages/business/comp_delete_business/` | Confirm delete page | `update` `business_page` `is_deleted=true`, `business_status='removed'` |
| `pages/business/comp_business_deleted/` | Post-delete sheet with Undo | `update` `business_page` `is_deleted=false`, `business_status='active'` |
| `pages/business/comp_report_business/` | Report a business | `insert` into `reports` (`report_type='business'`) |
| `pages/business/comp_thankyou_report/` | Report confirmation | `delete` from `reports` (undo report) |
| `pages/business/comp_three_dot_edit_business/` | Owner 3-dot menu | Routes to edit / promotion-state sheets by `status` (`under review`/`ended`/`rejected`) |
| `pages/business/comp_three_dot_report_business/` | Non-owner 3-dot menu | Opens report sheet |

## 3. Data model (tables & columns)

### `business_page`
- **Purpose:** One row per business page created by a user in a community.
- **Columns:** (types from `lib/backend/supabase/database/tables/business_page.dart`)
  | Column | Type | Null? | Notes (PK/FK/default/enum) |
  |---|---|---|---|
  | `id` | uuid (String) | NO | PK (client reads `.id` as String) |
  | `created_at` | timestamptz | NO | default `now()` |
  | `community_id` | int8 | NO | FK → community; scopes page |
  | `admin_user` | uuid (String) | NO | FK → users; page owner (`currentUserUid`) |
  | `name` | text | NO | business name |
  | `bio` | text | NO | description |
  | `profile_picture` | text | YES | public URL in `business-image` bucket |
  | `cover_image` | text | YES | public URL in `business-image` bucket |
  | `services` | text[] (List<String>) | NO | array of service tags |
  | `website_link` | text | NO | |
  | `email` | text | NO | |
  | `phonenumber` | text | NO | stored as text (may contain +, spaces) |
  | `is_deleted` | bool | NO | soft-delete flag; default `false` |
  | `business_status` | text | NO | enum-like: `active` / `removed` / `suspended` (from `Status` enum in `enums.dart`) |
- **Foreign keys / relationships:** `admin_user` → users(id); `community_id` → community(id).
- **Indexes needed:** `admin_user`, `community_id`, `is_deleted`, `business_status`.

### `business_promote`
- **Purpose:** One promotion request per business page (owner submits receipt; admin moderates).
- **Columns:** (from `business_promote.dart`)
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid (String) | NO | PK |
  | `created_at` | timestamptz | NO | default `now()` |
  | `community_id` | int8 | NO | FK → community |
  | `business_page_id` | uuid (String) | NO | FK → business_page(id) |
  | `business_promote_plans` | int8 | NO | FK → business_promote_plans(id) (chosen plan) |
  | `reference_number` | int8 | NO | payment reference typed by user (`int.tryParse`) |
  | `receipt` | text | YES | public/authorized URL in `promote-receipts` bucket |
  | `status` | text | NO | lifecycle: `under review` (client-set); admin sets `live`/`ended`/`rejected`/`mismatch` |
  | `plan_start_date` | timestamptz | YES | set by admin on approval |
  | `plan_end_date` | timestamptz | YES | set by admin on approval; shown on Live sheet |
  | `admin_user` | uuid (String) | NO | owner who submitted (`currentUserUid`) — NOT a platform admin |
- **Foreign keys / relationships:** `business_page_id` → business_page(id); `business_promote_plans` → business_promote_plans(id); `admin_user` → users(id).
- **Indexes needed:** `business_page_id`, `business_promote_plans`, `admin_user`, `community_id`, `status`, composite `(business_page_id, admin_user)` (used by update matcher).

### `business_promote_plans`
- **Purpose:** Catalog of promotion pricing tiers (admin-managed).
- **Columns:** (from `business_promote_plans.dart`)
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | int8 | NO | PK (int) |
  | `created_at` | timestamptz | NO | default `now()` |
  | `community_id` | int8 | NO | FK → community (plans may be per-community) |
  | `days_count` | int8 | NO | promotion duration in days |
  | `price` | numeric/float8 (double) | NO | plan price |
  | `currency` | text | NO | currency symbol/code (rendered as prefix) |
  | `image_url` | text | YES | plan artwork |
- **Indexes needed:** `community_id`, `price` (ordered `price asc` in promote_business).

### `business_contacted`
- **Purpose:** Tracks that a user contacted a business (drives the "contacted count").
- **Columns:** (from `business_contacted.dart`)
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid (String) | NO | PK |
  | `created_at` | timestamptz | NO | default `now()` |
  | `community_id` | int8 | NO | FK → community |
  | `business_page_id` | uuid (String) | NO | FK → business_page(id) |
  | `contacted_user` | uuid (String) | NO | FK → users(id); who contacted |
  | `last_contact_link` | text[] (List<String>) | NO | contact channels used (e.g. `phone`/`email`) — appended over time |
- **Indexes needed:** `business_page_id`, `contacted_user`, `community_id`, likely unique `(business_page_id, contacted_user)` so a user counts once (upsert-style; see §8).

### `reports` (shared table — see moderation feature)
- Written here with: `community_id`, `reported_by_user`, `reported_user`, `reason`,
  `report_type='business'`, `business_page_id`. Returns `id` (used to allow undo via delete).

## 4. Backend calls (API / RPC / Edge)
All RPCs are Supabase REST `rpc/` POST calls against project ref `wgcqstmmkcdjnnpuvspr`
(the OLD project — Viora's new backend must recreate these). Anon key + user JWT sent.

| Call / query | Type | Inputs | Returns | Called from |
|---|---|---|---|---|
| `GetMyBusinessCall` → `rpc/get_my_business` | RPC | `p_userid`, `p_communityid` | List of owner's pages, each with derived `promotion_status`, `id`, `plan_end_date` | my_pages |
| `BusinessHomepageCall` → `rpc/get_business_details` | RPC | `p_businessid`, `p_userid` | Full business profile + promotion/contact context | business_home_page |
| `GetBusinessCall` → `rpc/get_all_business` | RPC | `p_userid`, `p_communityid` | All (promoted/active) businesses in community | discovery list |
| `GetSpecifiBusinessCall` → `rpc/get_specific_business` | RPC | `p_userid`, `p_communityid`, `p_businessid` | Single business record | business detail |
| `GetPromotionplanCall` → `rpc/get_promotion_plan` | RPC | `p_businessid` | Current promotion/plan for a business | promotion sheets |
| `UpdateContactedCall` → `rpc/update_contacted` | RPC | `p_userid`, `p_businessid`, `p_contactedby` (`phone`/`email`), `p_communityid` | upserts/append `business_contacted` | comp_business_contact |
| `GetContactedCountCall` → `rpc/get_contact_count` | RPC | `p_businessid` | contacted count for business | business_home_page |
| `BusinessPromotePlansTable().queryRows` | direct SELECT | order `price` asc | plan list | promote_business |
| `BusinessPageTable().insert` | direct INSERT | page fields (see create flow) | new row (`id`) | create_page (create) |
| `BusinessPageTable().update` | direct UPDATE | image URLs / edited fields; match `id` (+`admin_user`) | — | create_page, comp_delete_business, comp_business_deleted |
| `BusinessPromoteTable().insert` | direct INSERT | community_id, business_page_id, business_promote_plans, reference_number, [receipt], status=`under review`, admin_user | — | upload_receipt (type `new`) |
| `BusinessPromoteTable().update` | direct UPDATE | receipt/reference_number/status; match `(business_page_id, admin_user)` | — | upload_receipt (resubmit), comp_mismatch |
| `ReportsTable().insert` / `.delete` | direct INSERT/DELETE | report fields / by `id` | report row | comp_report_business, comp_thankyou_report |
| `ChatTable().insert` | direct INSERT | chat init (contact via chat) | — | business_home_page |
| Storage `promote-receipts` | Storage upload | folder = `businessId` | download URL | upload_receipt |
| Storage `business-image` | Storage upload (custom action `uploadBusinessImages`) | folder = business `id`; `profile_*`/`cover_*` files, upsert | public URLs | create_page |

> NOTE: The frontend performs **direct DML** (`.insert/.update/.delete`) on `business_page`,
> `business_promote`, and `reports`. Per CLAUDE.md §6 these MUST be migrated to validated RPCs
> in the rebuild (see §7). The current direct-write pattern is the thing being replaced.

## 5. Business rules & flows

### Create / edit page (create_page)
1. Sequential validation of 6 forms (name, services, bio, website, email, phone). All must pass.
2. **Create:** INSERT `business_page` with `community_id`, `admin_user=currentUserUid`,
   `is_deleted=false` (no `business_status` set on insert → needs a DB default of `active`).
3. Upload profile + cover via `uploadBusinessImages` (bucket `business-image`, folder = new `id`,
   `upsert:true`), then UPDATE the row with `profile_picture` + `cover_image` URLs.
4. **Edit:** upload images (keeping existing URLs if unchanged) then UPDATE editable fields,
   matching `id` == businessId. Navigate to my_pages.

### Contact business (comp_business_contact)
- Website/email/phone taps: if the viewer is NOT the owner (`userid != currentUserUid`), call
  `update_contacted` with `p_contactedby` = `phone`/`email`, then launch the link.
- `update_contacted` should upsert a `business_contacted` row (append channel to
  `last_contact_link`) and the count is read via `get_contact_count`.

### Promotion lifecycle (state machine)
`business_promote.status` string + RPC-derived `promotion_status` drive UI:
1. **(no promotion)** → user opens promote_business → picks a plan (`business_promote_plans`,
   cheapest preselected) → upload_receipt.
2. **upload_receipt (`type == 'new'`)** → INSERT `business_promote` with `status='under review'`
   (+ optional `receipt` URL + `reference_number`). Confirmation = comp_promotion_received.
3. **`under review`** → shows comp_under_review. Admin reviews receipt off-app.
4. **Admin decisions (backend/admin app — NOT in this frontend):**
   - Approve → `status='live'`, set `plan_start_date` + `plan_end_date` (= start + plan `days_count`).
   - Reject → `status='rejected'` (refund note shown; user can renew).
   - Payment mismatch → `status='mismatch'` → comp_mismatch → user resubmits reference/receipt →
     back to `status='under review'`.
   - Expiry → `status='ended'` (user can renew/create new).
5. **Renew / resubmit (`type != 'new'`)** → UPDATE existing `business_promote` row matched by
   `(business_page_id, admin_user)` setting `status='under review'` again.
- `promotion_status` values the frontend branches on: `under review`, `mismatch`, `ended`,
  `live`, `rejected` (plus a no-promotion default that routes to promote).

### Delete / restore (soft delete)
- Delete: UPDATE `business_page` `is_deleted=true`, `business_status='removed'`, matched by
  `(id, admin_user)` — owner-only.
- Undo/restore: UPDATE `is_deleted=false`, `business_status='active'`, matched by `id` only
  (⚠ no owner match on restore — see §8).

### Report / un-report
- Report: INSERT into `reports` (`report_type='business'`, `business_page_id`, reason = radio or
  free text). Returns `id`.
- Undo: comp_thankyou_report DELETEs the just-created report by `id`.

## 6. Realtime / notifications
- No realtime channels observed in the business pages. Promotion state changes are pulled on
  screen load (my_pages reads `get_my_business`), not pushed.
- Admin approval/rejection likely warrants a push (OneSignal/FCM) to the owner, but the frontend
  code here does not subscribe to one — **confirm** (see §8). Contacting via chat uses the chat
  feature's own realtime.

## 7. Backend to build (Supabase rebuild checklist)

### Tables + columns + FKs + indexes
- [ ] `business_page`, `business_promote`, `business_promote_plans`, `business_contacted` exactly
      as typed in §3 (snake_case, `id`/`created_at`, real FKs with `on delete`).
- [ ] Defaults: `business_page.business_status` default `'active'`, `is_deleted` default `false`
      (insert path does not set `business_status`).
- [ ] Index every FK + `status`/`business_status`/`is_deleted`/`price`; composite
      `(business_page_id, admin_user)` on `business_promote`; unique `(business_page_id,
      contacted_user)` on `business_contacted` (confirm — see §8).

### RLS intent (admin-only writes by default; user writes via RPC)
This feature touches **payments + moderation** → strict.
- [ ] **`business_page`**: RLS on. SELECT: active/non-deleted pages visible in community;
      owner sees own. INSERT/UPDATE/DELETE: owner-only, and only via RPC (`create_business`,
      `update_business`, `delete_business`, `restore_business`) that validate
      `admin_user = auth.uid()`. NO direct client DML (replace current `.insert/.update`).
- [ ] **`business_promote`**: RLS on. SELECT: owner + admin only. INSERT/UPDATE: owner only via
      RPC (`submit_promotion`, `resubmit_promotion`) — client must NOT be able to set
      `status='live'`, `plan_start_date`, `plan_end_date`, or the `reference_number`/receipt of
      another user's row. **Admin-only** transitions to `live`/`ended`/`rejected`/`mismatch`
      + start/end dates (via `is_admin()` RPC or admin console). Write to `audit_log`.
- [ ] **`business_promote_plans`**: SELECT: `authenticated`. INSERT/UPDATE/DELETE: **admin-only**
      (pricing data).
- [ ] **`business_contacted`**: RLS on. INSERT/UPDATE via `update_contacted` RPC only. SELECT:
      owner (for counts) / admin. Count exposed via `get_contact_count` RPC.
- [ ] **`reports`**: covered by moderation feature; business report path must set `report_type`
      server-side and validate reporter = `auth.uid()`.

### RPC / PL-pgSQL functions (recreate; validate auth in-function)
- [ ] `get_my_business(p_userid, p_communityid)` — owner's pages + derived `promotion_status`,
      `plan_end_date`.
- [ ] `get_business_details(p_businessid, p_userid)` — public profile + promotion/contact context.
- [ ] `get_all_business(p_userid, p_communityid)` — community business listing.
- [ ] `get_specific_business(p_userid, p_communityid, p_businessid)`.
- [ ] `get_promotion_plan(p_businessid)`.
- [ ] `update_contacted(p_userid, p_businessid, p_contactedby, p_communityid)` — upsert contact,
      append channel; SECURITY INVOKER preferred, validate `auth.uid()`.
- [ ] `get_contact_count(p_businessid)`.
- [ ] NEW (to remove direct DML): `create_business`, `update_business`, `delete_business`,
      `restore_business`, `submit_promotion`, `resubmit_promotion`, `report_business`,
      `unreport_business`. Owner-scoped, validate `auth.uid()`.
- [ ] Admin-only: `moderate_promotion(promote_id, decision, start_date, end_date)` setting
      `status` + dates, guarded by `is_admin()` JWT claim, audited.

### Storage buckets + policies
- [ ] `business-image` bucket — profile/cover images, path `= business_page.id/{profile|cover}_*`.
      Public read; write policy limited to the page owner's folder (upsert used).
- [ ] `promote-receipts` bucket — payment receipts, path `= businessId/*`. **Private/authorized**
      read (receipts are payment evidence — owner + admin only), owner-scoped write. Do NOT make
      public.

### Edge functions / triggers / cron
- [ ] Cron/trigger to auto-`ended` a promotion when `plan_end_date < now()` (frontend has an
      `ended` state but no client sets it → must be server-side).
- [ ] (Confirm) push notification to owner on admin approval/rejection.
- [ ] Optional trigger to maintain `business_page.updated_at` (frontend Row has no `updated_at`;
      confirm whether needed).

## 8. Open questions & risks
1. **`promotion_status` derivation:** it's returned by `get_my_business`/`get_business_details`
   and includes values (`live`, `mismatch`, `ended`) the client never writes. Confirm the exact
   mapping logic from `business_promote.status` + dates so the RPC reproduces it. `received`
   (per task brief) appears only as a UI confirmation component, not a stored/derived status
   value seen in code — confirm whether the backend uses a `received` status.
2. **`admin_user` naming:** on `business_promote` and `business_page`, `admin_user` = the page
   OWNER (currentUserUid), NOT a platform admin. Do not confuse with `is_admin()` moderation.
3. **Restore has no owner check:** comp_business_deleted UNDO matches on `id` only (no
   `admin_user`). Under proper RLS/RPC this must be owner-scoped or anyone could restore.
4. **Direct client DML today:** `business_page`, `business_promote`, `reports` are mutated
   directly from widgets — violates §6. Must move to validated RPCs; flag any FF form fields
   (`business_status` not set on insert; `reference_number` client-supplied) that need server
   validation.
5. **`reference_number` is int8** but is a payment reference — large refs may overflow int; some
   refs have leading zeros/letters. Confirm type should stay integer vs text.
6. **`business_contacted` uniqueness / count semantics:** does `update_contacted` insert one row
   per contact (count = taps) or upsert one row per user appending to `last_contact_link` (count
   = distinct users)? The array column suggests append-per-user; confirm `get_contact_count`
   counts rows vs distinct users, and add the matching unique constraint.
7. **Receipt privacy:** receipts are uploaded to `promote-receipts`; the download URL stored in
   `business_promote.receipt` — confirm bucket is private + only owner/admin can read.
8. **Plan scoping:** `business_promote_plans` has `community_id` — are plans per-community or
   global? promote_business queries ALL plans without filtering by community (`queryRows` no
   filter) — confirm intended scope.
9. **Suspended status:** `Status.suspended` exists in the enum but no business widget sets it —
   presumably admin-only moderation. Confirm.
10. **Notifications:** no push subscription in-app for promotion decisions — confirm whether the
    owner is notified (OneSignal/FCM) when admin approves/rejects/marks mismatch.

# Feature: Moderation — Reports, Blocking & Muting

> Source of truth = the Flutter frontend. This doc records what the backend MUST provide
> for this feature to work. Derived from `lib/` — do not invent behavior the code doesn't show.

## 1. Overview
- **What it is:** User-facing moderation tools. Users can (a) **report** a post, account,
  business page, event, group, sale listing, or chat message with a reason; (b) **block** /
  **unblock** another user; and (c) (UI only) **mute** a user. Reports are written to the
  `reports` table for **admin review**; blocks are written to the `blocks` table.
- **Why it exists / user value:** Lets neighbors flag abusive/unsafe content and stop unwanted
  interaction from specific users. Reports feed an admin moderation queue (the separate Operture
  admin app / `admin/verification` surfaces review reports).
- **Related features:** Posts/feed, Business pages, Events, Groups, Sale listings, Chat/messaging,
  Profile, Notifications (report emails). Blocking is a cross-feature filter (see §5).

## 2. Screens & widgets
| Screen / widget (path under `lib/`) | Purpose | Key actions |
|---|---|---|
| `pages/home/comp_report_post/` | Report a post | Pick reason radio (or "Something else" free text) → `ReportsTable().insert` `report_type='post'` → thank-you sheet |
| `pages/home/comp_report_account/` | Report a user/account (also used for chat message via `reportType`) | Insert with `report_type = widget.reportType` (e.g. `'message'`, or `''`) |
| `pages/home/comp_report_block/` | Combined "Only Block" / "Report & Block" sheet | `BlocksTable().insert`, and optionally `ReportsTable().insert` before blocking |
| `pages/home/comp_block/` | "Block <name>?" confirm sheet | Routes into `comp_report_block` with blocker/blocked ids |
| `pages/home/comp_three_dot_block_user/` | 3-dot menu: shows Block or Unblock (queries block state) + Report | `BlocksTable().querySingleRow` to decide label; opens block/unblock/report sheets |
| `pages/home/comp_mute/` | Mute sheet | **Non-functional UI stub** — buttons only `print(...)`, hard-coded name "Laurence", stray "Forgot Password?" title. No backend. |
| `pages/home/comp_mute_confirmation/` | Mute confirmation sheet | **Non-functional UI stub** — no backend calls. |
| `pages/home/comp_thankyou/` | "Thanks for reporting" confirmation | Display-only; takes `id` (report id) + `pageName`; no backend call |
| `pages/business/comp_report_business/` | Report a business page | Insert `report_type='business'`, sets `business_page_id` |
| `pages/business/comp_three_dot_report_business/` | 3-dot entry point | Opens `CompReportBusinessWidget` |
| `pages/events/comp_report_event/` | Report an event | Insert `report_type='event'`, sets `event_id` |
| `pages/group/comp_report_group/` | Report a group | Insert `report_type='group'`, sets `group_id` |
| `pages/group/comp_unblock_user/` | Unblock confirm sheet | `BlocksTable().delete` matching blocker+blocked |
| `pages/sale/comp_report_listing/` | Report a sale listing | Insert `report_type='sale'`, sets `sale_id` |
| `pages/sale/comp_three_dot_report_sale/` | 3-dot entry point | Opens `CompReportListingWidget` |
| `pages/profile/blocked_users/` | "Blocked Accounts" list | `BlocksTable().queryRows` where `blocker_id = currentUser`; each row → Unblock |
| `chat/message_page/` | Chat thread — block state + report ("Report Account" with `reportType:'message'`) | `BlocksTable().querySingleRow` to check if blocked |
| `chat/comp_manage_access/` | Chat access mgmt — block state | `BlocksTable().querySingleRow`; opens block/report sheets |
| `pages/search/search_widget.dart` | Search results 3-dot → report post | Opens report with `reportType:'post'` |

## 3. Data model (tables & columns)

### `reports`
- **Purpose:** One row per report submitted by a user against a target entity. Polymorphic:
  the `report_type` string names the entity kind, and the matching nullable FK column holds the
  target id. Reviewed by admins.
- **Columns** (types/nullability from `lib/backend/supabase/database/tables/reports.dart`):
  | Column | Type | Null? | Notes (PK/FK/default/enum) |
  |---|---|---|---|
  | `id` | uuid (string) | no | PK |
  | `created_at` | timestamptz | no | default `now()` |
  | `community_id` | int (int8/int4) | no | FK → community. Client sends `FFAppState().communityId` **or hard-codes `1`** (account/block/report_block dialogs pass `1`) — see §8 |
  | `reported_by_user` | uuid (string) | no | FK → user (`auth.users` / public profile). The reporter |
  | `reported_user` | uuid (string) | **yes** | FK → user. The target account/owner. Sometimes sent as empty string `''` (post "Something else" branch) — see §8 |
  | `reason` | text (string) | no | Either the selected radio label or free text (when "Something else") |
  | `report_type` | text (string) | no | Enum-like. Observed values: `post`, `account`, `business`, `event`, `group`, `sale`, `message`, and `''` (empty from `comp_manage_access`). See §5 |
  | `post_id` | uuid (string) | **yes** | FK → posts. Set only for `report_type='post'` |
  | `comment_id` | uuid (string) | **yes** | FK → post_comment. **Column exists but NO frontend dialog writes it** — reserved / unused so far |
  | `group_id` | uuid (string) | **yes** | FK → groups. Set for `report_type='group'` |
  | `business_page_id` | uuid (string) | **yes** | FK → business_page. Set for `report_type='business'` |
  | `event_id` | uuid (string) | **yes** | FK → events. Set for `report_type='event'` |
  | `sale_id` | uuid (string) | **yes** | FK → sale listing. Set for `report_type='sale'` |
  | `report_status` | text (string) | no | Enum-like. Client sends `'pending'` only in `comp_report_post`; all other dialogs omit it → **DB default must be `'pending'`**. Admin transitions it (e.g. reviewed/resolved) |
  | `mail_sent` | bool | **yes** | **Never set by the client.** Server-side (trigger/edge fn) sends the admin notification email and flags this. See §6 |
- **Foreign keys / relationships:** `reported_by_user`, `reported_user` → users; `community_id`
  → community; `post_id`, `comment_id`, `group_id`, `business_page_id`, `event_id`, `sale_id`
  each → their respective entity tables. All target FKs are nullable (only one is populated per row
  according to `report_type`).
- **Indexes needed:** every FK column above (`reported_by_user`, `reported_user`, `community_id`,
  `post_id`, `comment_id`, `group_id`, `business_page_id`, `event_id`, `sale_id`); plus
  `report_status` and `mail_sent` (admin queue filtering) and `report_type`.

### `blocks`
- **Purpose:** One row per (blocker → blocked) directed relationship. Presence of a row means the
  blocker has blocked the blocked user.
- **Columns** (from `lib/backend/supabase/database/tables/blocks.dart`):
  | Column | Type | Null? | Notes (PK/FK/default/enum) |
  |---|---|---|---|
  | `id` | uuid (string) | no | PK |
  | `created_at` | timestamptz | no | default `now()` |
  | `blocker_id` | uuid (string) | no | FK → user. The user who blocks (`currentUserUid`) |
  | `blocked_id` | uuid (string) | no | FK → user. The user being blocked |
  | `community_id` | int | no | FK → community. Client hard-codes `1` in every block insert — see §8 |
- **Foreign keys / relationships:** `blocker_id`, `blocked_id` → users; `community_id` → community.
- **Indexes needed:** `blocker_id`, `blocked_id`, `community_id`; recommend a **UNIQUE composite
  `(blocker_id, blocked_id)`** to prevent duplicate blocks (frontend inserts without an upsert
  guard — see §8), plus an index on `(blocked_id, blocker_id)` for reverse lookups.

### Mute
- **No table exists / is referenced.** Mute UI (`comp_mute`, `comp_mute_confirmation`) is a
  non-functional stub. No `mutes` table in `lib/backend/supabase/database/tables/`. Nothing to
  build for mute unless product decides to implement it (see §8).

## 4. Backend calls (API / RPC / Edge)
All moderation writes are **direct table DML from the client** (FlutterFlow `SupabaseTable`
helpers) — no RPC, no edge function, no `api_calls.dart` entry.

| Call / query | Type | Inputs | Returns | Called from |
|---|---|---|---|---|
| `ReportsTable().insert({...})` | direct INSERT | `reported_by_user`, `report_type`, `reason`, `community_id`, target id (`post_id`/`group_id`/`business_page_id`/`event_id`/`sale_id`), `reported_user`, (`report_status='pending'` in post only) | inserted `ReportsRow` (`id` used by thank-you sheet) | `comp_report_post`, `comp_report_account`, `comp_report_business`, `comp_report_event`, `comp_report_group`, `comp_report_listing`, `comp_report_block` |
| `BlocksTable().insert({...})` | direct INSERT | `blocker_id=currentUserUid`, `blocked_id`, `community_id=1` | inserted row | `comp_report_block` (Only Block / Report & Block) |
| `BlocksTable().querySingleRow(blocker_id, blocked_id)` | direct SELECT | current user + target | 0/1 `BlocksRow` (drives Block vs Unblock UI) | `comp_three_dot_block_user`, `chat/message_page`, `chat/comp_manage_access` |
| `BlocksTable().queryRows(blocker_id=currentUser)` | direct SELECT | current user | list of `BlocksRow` | `pages/profile/blocked_users` |
| `BlocksTable().delete(matching blocker_id & blocked_id)` | direct DELETE | current user + target | — | `comp_unblock_user` |

Note: `comp_report_block` "Report & Block" inserts a `reports` row **and** a `blocks` row
(two separate statements, not transactional). It sets `reported_by_user = widget.blockedByUserId`
(not necessarily `currentUserUid`) — see §8.

## 5. Business rules & flows

### Report flow (all entity types)
1. User opens the entity's 3-dot menu → "Report …" → report sheet.
2. Sheet shows a fixed **radio list of reasons** (per type, below) + a "Something else" option
   that reveals a free-text field (required if chosen; "Reason is required" validation).
3. On submit: insert one `reports` row. `reason` = selected label, or the typed text when
   "Something else". `report_type` and the matching target FK are set. `report_status` defaults
   to `pending`.
4. A "Thanks for reporting" bottom sheet (`comp_thankyou`) shows; it receives the new report `id`
   and a `pageName` for copy. No further client action.

**Report reasons by type (exact strings — these are the `reason` values):**
- **Post** (`report_type='post'`): It's spam · Hate speech or symbols · Harassment or bullying ·
  Misinformation · Nudity or sexual content · Violence or threat · Something else
- **Account** (`report_type` = passed-in, e.g. `account`/`message`/`''`): Does not live here ·
  Fake Name or business name · Duplicate Account · Inappropriate profile or photo · History of
  inconsistent moderation decisions · Discrimination or racial profiling · Something else
- **Business** (`business`): Fraudulent or fake business · Provides illegal or banned services ·
  Payment or billing issues · Unsafe or harmful experience · Incorrect business information ·
  Unresponsive or unreachable · Something else
- **Event** (`event`): Scam or misleading event description · Inappropriate or offensive content ·
  Payment or billing issues · Spamming or mass promotional event · Violates community guidelines ·
  Duplicate or already listed event · Something else
- **Group** (`group`): Promotes hate or violence · Contains inappropriate or explicit content ·
  Spreads false or misleading information · Used for spamming or scams · Offensive group name or
  description · Violates community guidelines · Something else
- **Sale listing** (`sale`): Scam or suspicious behavior · False or misleading information ·
  Inappropriate or offensive content · Prohibited or illegal item · Spam or repeated listings ·
  Wrong Location · Item already sold or not available · Something else

### Block flow
1. From a 3-dot menu / chat / profile, `comp_three_dot_block_user` runs
   `BlocksTable().querySingleRow(blocker_id=currentUser, blocked_id=target)`. If a row exists →
   show **Unblock**; else → show **Block**.
2. "Block" → `comp_block` ("Block <name>?" with copy "They won't be notified that you blocked
   them") → `comp_report_block` sheet with two buttons:
   - **Only Block** → insert `blocks` row (`blocker=currentUser`, `blocked=target`, `community_id=1`), close.
   - **Report & Block** → insert a `reports` row (reason from radio/text) **then** insert the
     `blocks` row.
3. **Blocked users are NOT notified** (explicit UI copy).

### Unblock flow
- `blocked_users` list shows everyone the current user blocked (`blocker_id = currentUser`),
  count label "N people are blocked by you", each joined to `PublicUserProfileTable` for name/city.
- Unblock → `comp_unblock_user` → `BlocksTable().delete` matching `blocker_id=currentUser` AND
  `blocked_id=target`.

### Cross-feature hiding rule (blocked / muted content)
- **Blocking is directional in the schema** (`blocker_id` → `blocked_id`). The frontend only uses
  `blocks` to (a) toggle Block/Unblock labels and (b) list blocked users. **There is NO client-side
  feed/search/comment filtering** that removes a blocked user's posts, comments, listings, events,
  or group activity (grep found no `notIn`/block-list filtering in feed/search queries).
- **Therefore the backend rebuild owns the hiding rule.** When rebuilt, feeds/search/chat/comment
  queries (most are RPCs — `get_chat`, `search_public_user_profiles`, feed RPCs, etc.) must
  **exclude content authored by users in a block relationship with the current user** — typically
  both directions (I don't see them, they don't see me). This is a required cross-feature filter to
  add to every content-returning RPC and/or enforce via RLS. Confirm one-way vs two-way with product
  (see §8).
- **Mute** currently has no data or effect anywhere.

## 6. Realtime / notifications
- **No realtime** channel for reports or blocks (block/unblock UI relies on `FutureBuilder`
  re-queries, not subscriptions).
- **Admin email on new report:** `reports.mail_sent` (bool) is never written by the client, and
  no post gets `report_status` beyond `pending`. This strongly implies a **server-side trigger or
  edge function** that, on `reports` INSERT, emails the moderation/admin address and sets
  `mail_sent = true`. Rebuild must provide this (edge function or DB trigger + mail provider).
- No OneSignal push is triggered from these dialogs.

## 7. Backend to build (Supabase rebuild checklist)
- [ ] **Table `reports`** with all columns in §3, real FKs (all target ids nullable), FK indexes,
      `report_status` default `'pending'`, `mail_sent` default `false`/null.
- [ ] **Table `blocks`** with columns in §3, FKs, and UNIQUE `(blocker_id, blocked_id)`.
- [ ] **RLS intent — `reports`** (per CLAUDE.md §6: admin-only writes by default, user writes via RPC):
  - INSERT: a normal user may create a report **only with `reported_by_user = auth.uid()`** — expose
    via a `report_content()` RPC that validates the reporter, the target exists, `report_type`
    matches the populated FK, and normalizes `community_id` (stop trusting the hard-coded `1`).
  - SELECT: **admin only** (moderation queue). A reporter should not read others' reports; decide
    whether they may read their own (see §8).
  - UPDATE/DELETE: **admin only** (status changes, resolution). Non-admins never mutate.
- [ ] **RLS intent — `blocks`**:
  - SELECT: only rows where `blocker_id = auth.uid()` (my block list) — and rows where
    `blocked_id = auth.uid()` if the app needs reverse checks; keep the fact-of-being-blocked
    minimally exposed.
  - INSERT: only with `blocker_id = auth.uid()`. UPDATE: none. DELETE: only own rows
    (`blocker_id = auth.uid()`) — unblock. Prefer RPCs `block_user(target)` / `unblock_user(target)`
    that set `blocker_id = auth.uid()` and enforce the unique constraint / self-block guard.
- [ ] **RPCs (SECURITY INVOKER preferred; validate `auth.uid()`):**
  - `report_content(report_type, target_id, reported_user, reason, community_id)` → returns new id.
  - `block_user(blocked_id)` / `unblock_user(blocked_id)`.
- [ ] **Cross-feature filter:** update every content-returning query/RPC (feed, search, chat,
      comments, business/event/group/sale lists) to exclude blocked relationships (§5).
- [ ] **Edge function / trigger:** on `reports` INSERT → email admin + set `mail_sent = true`.
- [ ] **Admin surface** (Operture admin app / `admin/verification`) reads `reports` and updates
      `report_status`. Ensure `is_admin()`-gated policies cover it.
- [ ] No storage buckets. No cron. **No mute** backend (unless product adds it).

## 8. Open questions & risks
1. **`community_id` inconsistency:** block inserts and several report dialogs hard-code `1`;
   post/group/business/event/sale reports use `FFAppState().communityId`. Backend should derive
   community server-side (from the target or the user) rather than trust the client value.
2. **`reported_user` empty string:** `comp_report_post` "Something else" branch sends
   `reported_user: ''`. As a uuid FK this must be **NULL**, not `''`. RPC/validation must coerce.
3. **`report_status` only set by post dialog:** all other dialogs omit it → depends entirely on a
   DB default of `'pending'`. Confirm the default and the full status enum (pending → ? → resolved).
4. **`comp_report_block` reporter id:** "Report & Block" sets `reported_by_user =
   widget.blockedByUserId` (the passed-in id), not `currentUserUid`. Verify this id actually equals
   the acting user; the RPC should force `reported_by_user = auth.uid()` regardless.
5. **Duplicate blocks:** no upsert/guard on `BlocksTable().insert` → repeat "Block" can create
   duplicate rows. Enforce UNIQUE `(blocker_id, blocked_id)` and make block idempotent.
6. **`comment_id` unused:** the column exists but no dialog writes it. Is comment reporting planned?
   Keep the column, or confirm it's dead.
7. **Blocking directionality:** define whether a block hides content **both ways** (blocker and
   blocked can't see each other) or one way. The schema is directional; the hiding rule is not
   implemented client-side, so the product decision must be encoded in the backend.
8. **Mute is unimplemented UI** (stub with `print()`, hard-coded "Laurence", stray "Forgot
   Password?" title). Decide: build a `mutes` table + hide-from-feed rule, or drop the screens.
   Nothing exists to document as real behavior today.
9. **No transaction** around "Report & Block" (two inserts). If the report succeeds and the block
   fails (or vice versa) the state is partial — an RPC should make it atomic.
10. **Reporter visibility:** should a user see the status/history of reports they filed? Frontend
    shows only a thank-you sheet, so currently no. Confirm before writing SELECT policy.

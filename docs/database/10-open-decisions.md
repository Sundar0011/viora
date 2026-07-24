# Database Design — Open Decisions

> Part of `docs/database-design.md`. These are decisions NOT yet made — surfaced per CLAUDE.md §7
> (batch all questions, ask before expanding scope, no silent decisions). Nothing here has been
> applied. Naming conflict is listed first per the task instructions. **RESOLVED** decisions are
> kept in place (not deleted) with their resolution recorded, per the "never delete, only
> supersede" rule — see `docs/decisions.md` for the dated log entry.

## 0. RESOLVED — Community, Video, Identity RLS (stakeholder decisions, 2026-07-19)
These three were decided by the stakeholder and are no longer open. Full rationale logged in
`docs/decisions.md` (2026-07-19 entry). Every downstream file has been updated accordingly.

### 0a. Remove Community Concept — RESOLVED
**Decision:** There is no community feature in Viora. The `community` table is removed from the
design entirely (no table, no seed row, no FK, no RLS/RPC scoping by community). Every RLS
predicate and RPC that previously said "community scope"/"community membership" now reflects
app-wide (no boundary) access.
**Frontend reconciliation (mandatory, since the frontend is locked — CLAUDE.md §2):** the
FlutterFlow frontend still has a `community_id` column in many Row classes and still
inserts/filters on it (hardcoded `= 1`). Per-table, the physical `community_id` column is:
- **KEPT** (as a vestigial compat column: `int8`, `DEFAULT 1`, nullable, **no FK**, never read by
  RLS or RPC WHERE clauses) on every table whose frontend Row class actually has the column —
  confirmed by grep of `lib/backend/supabase/database/tables/*.dart`: `user_roles`,
  `public_user_profile`, `follows`, `"group"`, `group_admin`, `group_members`,
  `group_members_invite`, `group_user_status`, `post`, `post_images`, `post_like`, `post_share`,
  `post_comment`, `post_comment_likes`, `event_page`, `event_attending`, `sale`, `sale_category`,
  `sale_images`, `business_page`, `business_promote`, `business_promote_plans`,
  `business_contacted`, `chat`, `chat_users`, `messages`, `search_history`, `reports`, `blocks`.
- **REMOVED** — no table in this design gained a new `community_id` that its frontend Row class
  doesn't already have, and none is dropped either: the design doc's prior `community_id` list
  already matched the frontend contract exactly (verified by grep). The only column removed
  outright is the `community` table itself.
- The frontend's `CommunityTable`/`CommunityRow` Dart class (`lib/backend/supabase/database/
  tables/community.dart`) is left as-is (frontend is locked) but is not backed by any table in
  this design — see the frontend reconciliation note in `03-tables-community-groups.md`.
**Reason:** stakeholder decision — Viora does not ship a community/neighborhood-boundary feature.
**Reversibility:** MEDIUM. Re-adding `community` later means: recreate the table, backfill/repoint
every vestigial `community_id` column to a real FK, and reintroduce RLS/RPC scoping — a full
follow-up design + migration pass, not a quick toggle.

### 0b. Video Out of Scope — RESOLVED
**Decision:** Video upload is NOT in scope. No `post-videos` bucket, no video mime types, no
`e_media_type='video'` design. Images only (`post-images`, `sales-images`, `profile-images`,
`cover-images`, `business-image`, `event`, `group-profile-image`, `promote-receipts`, `squadd`).
**Reason:** the app has no video-upload UI; building server-side support ahead of a frontend
feature that doesn't exist violates the "frontend is locked/done, backend matches it" rule
(CLAUDE.md §2).
**Reversibility:** EASY. Revisit in future — add a bucket + `e_media_type` value + RPC/UI when a
video-upload flow is actually built.

### 0c. Identity Table RLS — RESOLVED
**Decision:** The private `"user"` table is **owner-only, no exceptions**: SELECT and UPDATE
gated by `id = (SELECT auth.uid())`; no cross-user SELECT of the private row at all; INSERT only
via `signup_finalize`. `public_user_profile` is readable by **any authenticated user** (writes
remain owner-only via RPC/`WITH CHECK`) and is the **primary read surface** for profile/display
data — most reads hit `public_user_profile`, not `"user"`.
**Reason:** stakeholder decision, matches the existing intent that PII stays in `"user"` while
`public_user_profile` is the app's actual public-facing profile object.
**Reversibility:** EASY — purely an RLS policy change, no schema change, no frontend impact
(frontend already reads/writes these two tables in this shape).

### 0d. Remaining decisions — RESOLVED (2026-07-19, pre-build sign-off)
All items previously listed as open in §§1–7 below are now decided (see `docs/decisions.md`,
2026-07-19 "Remaining open decisions settled"). Sections 1–7 are kept for history; the resolution
of each is:
1. **Table names** → KEEP `"user"` / `public_user_profile` (option A). Not renamed.
2. **Role value** → `user_roles.role` = `customer` + `admin` (keep `customer`, do NOT force `user`).
3. **Direct-DML-vs-RPC** → RPC (server functions) for important writes; scoped RLS for trivial owner rows.
4. **Unknown enum/lookup sets** → store as plain `text` for now; confirm later from the Operture admin app.
5. **`user_locations`** → one location per user (`id = "user".id`).
6. **Push / `user_devices`** → Firebase FCM for Android + iOS; drop OneSignal `player_id`; keep `fcm_token`.
7. **`tagged_people` vs `tag`** → `tag` table authoritative; `post.tagged_people` = denormalized cache.
8. **`audit_log`** → log all sensitive/admin actions.
9. **Realtime** → secure PRIVATE authorized Broadcast (not public Postgres Changes).
10. **RPC pagination/filtering** → backend-driven pagination + filtering standard for all list RPCs;
    over-fetching frontend screens WILL be updated to match (authorized §2 exception, pagination wiring only).
11. **Blocking directionality** → TWO-WAY.

## 1. NAMING CONFLICT — `user_main`/`public_user` vs. frontend table names (OPEN)
The user's request splits identity into `user_main` (private core) and `public_user` (public
profile). The FlutterFlow frontend (locked, CLAUDE.md §2/§6 — must not be restructured) is
**already bound** to specific table names via generated Row classes under
`lib/backend/supabase/database/tables/`:
- `user_main` → the frontend's **`"user"`** table.
- `public_user` → the frontend's **`public_user_profile`** table.
- `user_roles` → name already matches (no conflict there).

**Two options:**
- **(A) Keep the frontend's actual names** (`user`, `public_user_profile`). Zero frontend risk —
  the generated Dart Row/Table classes keep working unmodified. Cost: the schema doc doesn't use
  the user's preferred naming; `"user"` must be double-quoted in every hand-written SQL statement
  since `USER` is a SQL keyword (not fatal, just a footgun for migration authors — documented in
  `docs/database-design.md` §1).
- **(B) Rename to `user_main` / `public_user`** and update every FlutterFlow-generated binding +
  call site across the Flutter app to match. Higher risk: touches a "locked, done" frontend
  (CLAUDE.md §2), large diff surface, retesting burden on both Android and iOS.

**This document's tables use option (A)** (frontend names, `"user"` / `public_user_profile`) as
the working design, per the instruction to use the least-risky option as the default while
leaving the final call open. **Recommend (A). Awaiting user confirmation before applying.**

## 2. Role value conflict: `user_roles.role`
The user's requirement pins `user_roles.role` to exactly `'user'`/`'admin'` (enum). The frontend's
current signup flow inserts `role: 'customer'` (hardcoded) directly from the client. Resolution
proposed in `docs/database-design.md` §4: the rebuild's `signup_finalize` RPC always writes
`role='user'`, ignoring the client's literal string, since `user_roles` writes must be admin/RPC-
only anyway per CLAUDE.md §6. **This silently changes an observable frontend-written value**
(`'customer'` → `'user'`) — the frontend never reads `user_roles.role` back for display (only the
JWT claim matters for authorization), so this is believed safe, but flagged for explicit
confirmation since it changes stored data vs. what the client sends.

## 3. Frontend quirks — kept verbatim (not silently renamed)
| Table.column | Quirk | Decision |
|---|---|---|
| `"user".IsOwner` | PascalCase, not snake_case | Kept verbatim — frontend does `getField<bool>('IsOwner')` |
| `event_page.Address` | Capital "A" | Kept verbatim |
| `event_page.logitude` | Misspelled (not "longitude") | Kept verbatim |
| `"group".isdeleted` | No underscore (inconsistent with `sale.isdeleted`, which matches, vs. `post.is_deleted`, `event_page.is_deleted`, `business_page.is_deleted`, which use the underscore) | Kept verbatim per table |
| `sale.isdeleted` | Same no-underscore quirk | Kept verbatim |
| `business_promote.admin_user` / `business_page.admin_user` | Means page **owner**, not platform admin — do not confuse with `is_admin()` JWT predicate | Documented, not renamed |

## 4. Direct client DML vs. RPC (CLAUDE.md §6.6) — decision needed per table
Every single feature doc flags the same pattern: the current frontend performs **direct
`.insert()`/`.update()`/`.delete()`** on `post`, `post_comment`, `"group"` + all its child tables,
`event_page`, `event_attending`, `sale`, `business_page`, `business_promote`, `chat`, `messages`,
`reports`, `blocks`, `search_history`, `"user"`, `user_roles`, `public_user_profile`. CLAUDE.md §6
requires user-facing writes to go through RPC. Two paths per table, decided individually during
RLS drafting (`docs/rls-policies-draft.md`):
- **(a) Move to RPC** — safest, matches CLAUDE.md §6 literally, adds server-side business-rule
  enforcement (e.g. can't self-approve a private group join). **Recommended default** for
  anything with a state machine or moderation/payment implication (Groups, Business/Promotion,
  Events, Reports).
- **(b) Tightly-scoped RLS** allowing exactly the direct DML shape the frontend already performs
  (e.g. `INSERT ... WITH CHECK (user_id = auth.uid())`), for simple owner-row writes with no
  state machine (e.g. `post_like`/`post_share` presence rows, `search_history` delete).
This document lists `(NEW)` RPC recommendations in `09-rpc-inventory.md` for the (a) cases;
**final choice per table is an open decision**, not yet made.

## 5. Unconfirmed enum / lookup value sets (kept `text`, not guessed as enums)
- `"group".e_discoverability` — radio value set unknown; only referenced, never enumerated in the
  frontend code reviewed.
- `group_admin.e_group_role` — only `'admin'` observed; unknown whether `'member'`/other roles
  are planned.
- `comment_post_access` — ids 1 and 4 confirmed (`Anyone on SquaDD` / `No One`); ids 2/3 implied
  by UI branches but not confirmed.
- `business_promote.status` — `under review` confirmed client-set; `live`/`ended`/`rejected`/
  `mismatch` confirmed as admin-set targets, but the exact `promotion_status` **derivation logic**
  (which combines `status` + dates) lives in an RPC not visible to the frontend.
- `reports.report_type` — an empty string `''` was observed from `comp_manage_access`, which is
  incompatible with a strict Postgres `ENUM`. Kept `text`; decide whether `''` should be coerced
  to a specific value (e.g. `'account'`) inside `report_content()`.
- `notifications.type` / `notification_type` — two columns, only `type` is used by the UI;
  purpose of `notification_type` is unconfirmed (possibly legacy/duplicate).
- `chat.chat_type` — only `'dm'` is written by the client; the "for sale" tab and
  `total_sale_chats` imply a second value (`'sale'` vs `'forsale'`) whose exact string and creator
  are unconfirmed.
- `admin_notification.status` / `.audience_type` — no admin compose screen exists in this Flutter
  app (lives in the separate Operture admin app); value sets must come from that app's owner.

## 6. Gaps the frontend reveals but doesn't resolve
- **`user_locations` linkage:** modeled here as `id = "user".id` (one home location per user, PK
  doubles as owner FK) since every RPC takes `p_userid` and no `user_id` column appears in the Row
  class. Alternative: a separate `user_id` FK + independent uuid `id`, supporting multiple saved
  locations per user. **Confirm which before applying.**
- **OneSignal `player_id`:** `user_devices` gets a new nullable `player_id` column to close the
  gap between the `upsert_user_device` RPC signature and the Row class (which has none today).
  Confirm OneSignal is actually the intended push path (vs. FCM-only) before committing to this.
- **`tagged_people` (post jsonb) vs. `tag` table:** both are written for the same mention data.
  Confirm which is authoritative; the other becomes a denormalized cache or is dropped.
- **`admin_notification.created_by`:** added as a new nullable column for audit traceability — no
  such column exists in the frontend Row class. Confirm before applying (admin-only, no frontend
  impact either way).
- **`audit_log` table:** entirely new, required by CLAUDE.md §6.5 for every `SECURITY DEFINER`
  sensitive action, but not present in any feature doc / frontend Row class. No frontend UI reads
  it. Confirm scope (which actions must be audited) before applying.
- **Video storage** — **RESOLVED**, see §0b above. Not built; images only.
- **Realtime mode:** every feature doc's current frontend uses public, unauthorized Postgres
  Changes (`'public:messages'`, `'test_messages_channel'`, etc.) — CLAUDE.md §6 requires private
  authorized Broadcast for app events. Each feature file already recommends the Broadcast topic
  naming; the actual migration off Postgres Changes is a cross-cutting decision to schedule, not
  yet made.
- **RPC pagination signature changes:** `08-triggers-counters.md` §3 recommends adding cursor args
  to `get_visible_posts`/`get_notifications`/`get_chat`. This changes the RPC signature the locked
  frontend currently calls with **no** pagination args — must be confirmed with frontend-dev
  before changing, or the RPCs must keep a no-cursor overload for backward compatibility.
- **Community scoping — RESOLVED**, see §0a above. No community concept; `community_id` kept only
  as a vestigial compat column on the tables the frontend Row classes already have it on.
- **Blocking directionality:** one-way vs. two-way content hiding is unresolved (feature doc §7).
  Every content-returning RPC's block-filter predicate depends on this decision.
- **Hibernate account:** no backend implementation exists anywhere in the frontend; not designed
  here beyond noting `"user".status` stays `text` (open enum) to leave room for a future
  `'hibernated'` value if product confirms the feature.

## 7. Summary — what's NOT yet decided (batch, per CLAUDE.md §7)
1. Naming: keep `user`/`public_user_profile` (recommended) vs. rename to `user_main`/`public_user`.
2. Confirm `signup_finalize` silently forcing `role='user'` over the client's `'customer'` string.
3. Direct-DML-vs-RPC choice, per table (§4 above) — default recommendation given, needs sign-off.
4. Every unconfirmed enum/lookup value set in §5.
5. `user_locations` linkage design (one-per-user vs. multi-location).
6. OneSignal `player_id` column addition + confirm OneSignal is live (vs. FCM-only).
7. `tagged_people` jsonb vs. `tag` table authority.
8. New `audit_log` table scope.
9. Realtime migration off public Postgres Changes — schedule.
10. RPC pagination signature changes — coordinate with frontend-dev or keep dual signatures.
11. Blocking directionality — one-way vs. two-way.

**RESOLVED (no longer open, kept for history — see §0 above and `docs/decisions.md`):**
Community concept removed (§0a); video upload out of scope (§0b); identity table RLS —
owner-only `"user"`, any-authenticated-read `public_user_profile` (§0c).

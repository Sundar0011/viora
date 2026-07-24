# Backend Dev — Self-Improving Playbook

This is backend-dev's private, evolving skill. **Read it fully before every task.**
**After every task, append a dated lesson** below: which SQL / RLS / RPC / migration pattern
produced good or bad output, and the fix. Supersede old lessons; never delete. Never edit the
upstream skills in `.claude/skills/`. Propose proven lessons for promotion into `CLAUDE.md`.

## Lessons learned

### 2026-07-19 — Full DB design pass (39+1 tables, 13 features), design-only deliverable
- **What worked well:** Reading all 13 `docs/features/*.md` fully before writing a single line of
  schema was essential — nearly every table has a documented quirk (`IsOwner`, `isdeleted` vs
  `is_deleted`, `logitude`, empty-string FK values, hardcoded `community_id=1`) that must be
  preserved verbatim, not "fixed," per the doc-first / frontend-locked rule (CLAUDE.md §2/§3).
  Cross-referencing each feature doc's own §8 "Open questions" caught most naming/behavior traps
  before they became schema mistakes.
  Splitting the design doc into `docs/database-design.md` (index + conventions + ERD + migration
  order) plus 10 area files under `docs/database/` kept every file under the 400-line cap (§5)
  without losing structure — do this proactively for any multi-feature deliverable, don't wait
  until a single file blows past 400 lines.
- **What to watch for next time:** the user's requested design (`user_main`/`public_user` split
  with exactly-two-role enum) directly conflicted with the frontend's already-bound table names
  (`user`, `public_user_profile`) and the frontend's hardcoded `role:'customer'` insert. Correct
  handling is to surface the conflict explicitly as Open Decision #1 (least-risky default =
  keep frontend names) rather than silently pick one — this matches CLAUDE.md §7's "no silent
  decisions" rule and the task's own explicit instruction. When a user's explicit ask and the
  locked frontend contract disagree, document both and let the option with the smaller frontend
  blast radius be the *default*, but never apply it without confirmation.
- **Reminder for the actual build phase:** this pass was DESIGN ONLY — no `apply_migration` /
  `execute_sql` / bucket creation was run, and none should be until `docs/rls-policies-draft.md`
  exists and is reviewed separately (§6.9), and the Supabase project ref is confirmed against
  `.claude/viora-project-ref.txt` (§6). Every `SECURITY DEFINER` function inventoried here still
  needs the full checklist (search_path pin, `auth.uid()` validation, REVOKE/GRANT, audit) applied
  at implementation time, not just noted in the design doc.

### 2026-07-19 — Retrofitting a "remove concept X" decision across an already-written design
- **What worked well:** before touching any file, `grep -rl "community_id" lib/backend/supabase/
  database/tables/*.dart` gave the exact, authoritative list of which frontend Row classes carry
  the column — comparing that list against every `docs/database/0N-*.md` table showed the prior
  draft's `community_id` usage already matched the frontend 1:1 (no table needed the column
  *removed*, only *redefined*). Doing this grep-and-diff pass FIRST turned a fuzzy "figure out
  what to keep vs. drop" task into a mechanical, low-risk edit pass — do this for any "the design
  doc already exists, now retrofit a scope-narrowing decision onto it" task before editing
  anything.
- **What worked well #2:** for a concept-removal (community) that spans 8+ files, editing file-
  by-file with a repeated fixed phrasing for the vestigial column ("vestigial compat column — no
  <X> feature; retained only because the locked frontend Row class sends/filters it (CLAUDE.md
  §2)") kept every file self-consistent and made it trivial to grep-verify completeness afterward
  (`grep -rn community <each file>` at the end of each edit pass caught leftover FK/index/RLS
  wording that a plain column-type edit would have missed, e.g. composite indexes and unique
  constraints that included the now-vestigial column, and RLS predicate prose like "community
  member"/"community-wide").
- **What to watch for next time:** RESOLVED decisions belong in the doc, not deleted — added a
  new `## 0. RESOLVED` section at the top of `10-open-decisions.md` rather than removing the old
  numbered items, and renumbered only the *open* summary list at the bottom while leaving the
  original numbered sections (§1-§6) intact with inline "— RESOLVED, see §0" pointers. This
  matches CLAUDE.md §9's "supersede, never delete" rule and kept the file's history legible.
  Also: when a locked-frontend table exists in Dart (e.g. `CommunityTable`) but the backing table
  is being dropped, don't silently ignore it — add an explicit "frontend reconciliation note"
  documenting that the Dart class is orphaned/unused rather than leaving a silent gap between the
  Dart binding and the schema.

### 2026-07-19 — Batch 1 (auth/identity) migrations authored as files only, no MCP calls
- **What worked well:** re-reading `docs/decisions.md` right before writing DDL caught a real
  conflict: `docs/database-design.md` §3/§4 still says `app_role` = `'user'`/`'admin'`, but the
  *later* 2026-07-19 "Remaining open decisions settled" entry supersedes that to `'customer'`/
  `'admin'`. When a design doc and a later decision-log entry disagree, the decision log (newest
  first, explicitly dated) wins — always check `docs/decisions.md` last/newest entries before
  trusting an earlier design doc's literal text, even inside the same document set. Also cross-
  checked every column against the actual frontend Row class (`lib/backend/supabase/database/
  tables/*.dart`) rather than trusting the design doc's prose alone — confirmed `user_devices` has
  no `player_id` getter (matches the decision to drop OneSignal), and that non-nullable Dart getters
  with `!` (e.g. `communityId`, `followers`) still get modeled with a SQL `default`, not `not null`
  without a default, when the design doc explicitly says "nullable, default 1" — the Dart `!`
  assumes the default always fills it, it doesn't imply a `not null` constraint is required.
- **SECURITY DEFINER auth hook detail:** `custom_access_token_hook` needs `grant execute ... to
  supabase_auth_admin` (not `authenticated`) plus an explicit `revoke ... from authenticated, anon,
  public` — GoTrue calls the hook as `supabase_auth_admin`, a role most migrations forget to grant
  to explicitly. Also grant `usage on schema public to supabase_auth_admin` or the hook can't even
  resolve the function.
- **Where the design doc under-specifies an RPC signature** (e.g. `signup_finalize` args were only
  described as "profile fields + first location" in `09-rpc-inventory.md`, no exact list): built the
  narrowest defensible signature from the frontend's actual `"user"` columns, deliberately left out
  the ambiguous "first location" part (kept `update_user_location` as a separate RPC/step instead of
  guessing a combined signature), and left a `TODO(confirm)` comment in the migration file itself —
  not just in a doc — so the gap survives into the applied schema's comments for the next person.
- **RLS draft file:** wrote `docs/rls-policies-draft.md` as executable-looking `sql` blocks with a
  one-line "Intent:" comment per policy (not prose only) — makes it trivial for the reviewer to
  copy-paste into the eventual apply migration, and for a future agent to diff "what was proposed"
  vs. "what got applied". Flagged a real gap inline (RLS is row-level, not column-level, so an
  owner-only UPDATE policy on `public_user_profile` still lets a client overwrite trigger-maintained
  counter columns like `followers`/`post_count` directly via PostgREST) rather than silently
  shipping a policy that looks safe but isn't — that's a column-level problem RLS alone can't solve,
  worth surfacing even when out of the current batch's scope.
- **Reminder:** this was FILES ONLY — no `apply_migration`/`execute_sql` was run. Migration files
  live in `supabase/migrations/000{1..4}_*.sql`; nothing is applied until the main thread reviews
  and runs them via Supabase MCP against `hlmymmlkgirafodcnkgg` (per `.claude/viora-project-ref.txt`).

### 2026-07-19 — Batch 2 (posts/comments/likes/shares/tags/blocks) authored as files only, no MCP calls
- **File-count vs. the 400-line cap:** the task listed exactly 4 filenames
  (`0007_post_enums.sql`..`0010_post_triggers.sql`), but a realistic line-count estimate of every
  requested RPC (helpers + feed reads + post CRUD + likes/shares/counts + comment RPCs) came to
  ~700+ lines before even counting triggers — far past CLAUDE.md §5's 400-line-per-file cap. Did
  the math up front (rough per-function line estimate x function count) BEFORE writing any SQL,
  then split into 7 files (`0007`..`0013`) grouped by concern (enums / tables / read-RPCs /
  write-RPCs / engagement-RPCs / comment-RPCs / triggers) instead of cramming everything into the
  4 requested names. When a task's suggested filenames and a hard CLAUDE.md line-cap conflict,
  estimate first, then split proactively and explain the deviation clearly in the final summary —
  don't discover the overflow mid-file and have to backtrack.
- **Mid-task requirement change (view-access semantics):** the coordinator revised the
  `see_post_access` semantics *after* tables/seed rows/the `can_view_post()` helper were already
  written (old: Everyone/Neighbourhood-geo/Nearby-geo; new: Everyone/Friends-via-follows/
  Nearby-geo). Handled by editing the seed INSERT + the helper function in place rather than
  rewriting from scratch — the block/is_deleted/author-always logic was untouched, only the
  id-2 branch changed from a second geography check to a follow-graph check. Cross-referenced the
  frontend's `follows.dart` Row class first to get the exact column names (`follower_id`,
  `following_id`) before writing the predicate, even though the `follows` table itself belongs to
  a later batch and doesn't exist yet.
- **Referencing a not-yet-created table from a DEFINER function, safely:** `can_view_post()`
  needs a `follows`-table query, but `follows` won't exist until the Neighbors/Follows batch.
  Because the function is `language plpgsql` (not `language sql`), Postgres does NOT validate
  table references at `CREATE FUNCTION` time — only at execution. Used `execute '...' using ...`
  (dynamic SQL) wrapped in a `begin...exception when undefined_table then ... end` block so (a)
  the migration applies cleanly today even though `follows` doesn't exist yet, (b) calling the
  function today safely returns `false` (deny) instead of erroring the whole feed query, and
  (c) once the `follows` table lands in its own batch, the same function starts working with zero
  further changes. This pattern (dynamic SQL + `undefined_table` exception guard) is the reusable
  fix whenever a batch's RPC needs to softly depend on a table owned by a not-yet-built batch.
- **Counters:** kept `add_like`/`update_post_share_count`/`add_comment_like` as the RPC write path
  (not tightly-scoped RLS on `post_like`/`post_share`) even though the task allowed RLS for
  "trivial owner-presence rows" — because the locked frontend already calls these by RPC name
  (`AddLikeCall`, `UpdatePostShareCountCall`), and CLAUDE.md's "match the frontend contract"
  rule outranks the optional RLS shortcut. Triggers still own the actual counter columns
  (`post.likes_count` etc.) on top of the RPC's row insert/delete, so counters self-heal even if
  the RPC's own bookkeeping ever has a bug — matches `08-triggers-counters.md`'s stated intent.
- **Reminder:** this was FILES ONLY — no `apply_migration`/`execute_sql` was run. Migration files
  live in `supabase/migrations/00{07..13}_*.sql`; nothing is applied until the main thread reviews
  `docs/rls-policies-draft.md` (Batch 2 section) and runs the migrations via Supabase MCP against
  `hlmymmlkgirafodcnkgg` (per `.claude/viora-project-ref.txt`).

### 2026-07-19 — Batch 5 (Events + Marketplace + Storage) authored as files only, no MCP calls
- **First batch to stand up `storage.objects` RLS — the ownership-check shape splits cleanly into
  two cases, and mixing them up silently breaks upsert.** "Folder = the uploader's own user id"
  (`profile-images`/`cover-images`) needs only a bare path comparison
  (`(storage.foldername(name))[1] = auth.uid()::text`), no table join. "Folder = an entity id"
  (`post-images`→post, `sales-images`→sale, `event`→event_page, `group-profile-image`→group) needs
  an ownership check against that entity's own table — reused the EXISTING self-scoped `_self` RLS
  wrapper for tables that already had one (`is_group_admin_self`, and the newly-added
  `is_event_owner_self` built in lockstep with this batch's own table), and a direct `EXISTS`
  subquery for tables with a plain owner column and no such wrapper yet (`post.user_id`,
  `sale.created_by`). Don't invent a third helper shape when a `_self` wrapper already exists for
  the entity — reuse it in the storage policy exactly as RLS policies on the entity's own table do.
- **A storage bucket whose owning table doesn't exist yet needs the SAME forward-compat pattern as
  a cross-batch RPC dependency — applied to RLS predicates, not just functions.**
  `business-image`/`promote-receipts` reference `business_page`/`business_promote`, both owned by
  the not-yet-built Business/Chat batch. Reused the `execute '...' using ...` +
  `exception when undefined_table then return false` pattern (previously only used inside
  `plpgsql` RPC bodies, e.g. `get_following_users_not_attending_event`) inside a new internal
  helper (`is_business_page_owner`/`is_business_promote_owner`), then wrapped each in the usual
  `_self` variant for the storage policy to call. This is a reusable third case: "entity table
  doesn't exist yet" storage buckets get a forward-compat helper pair (internal 2-arg + self
  1-arg), not a bare `true`/`false` policy and not a deferred migration — the bucket/policies still
  need to exist NOW (CLAUDE.md §6.1 "RLS mandatory on every table", extended here to "every bucket
  must have a real, if currently-always-denying, write policy").
- **A table-doc-confirmed enum value set outranks a feature-doc implementation aside describing the
  SAME column as "not a DB enum in the frontend."** `event_type` — the feature doc
  (`06-events.md` §3) says "not a DB enum in frontend / plain text from a radio button"; the table
  doc (`04-tables-events-marketplace.md`) lists it as `event_type enum NO 'Online'/'Offline'`, i.e.
  a CONFIRMED two-value set. Per CLAUDE.md §3's doc-first rule ("if doc and code disagree, the doc
  wins"), and matching the established `e_group_type` precedent (Batch 4: confirmed 2-value sets
  become real Postgres enums, unconfirmed ones stay `text`), made it a real enum — the feature
  doc's aside is describing the FRONTEND'S current lack of a DB constraint, not asserting the value
  set is unconfirmed or unbounded.
- **Two RPCs "for two different screens" turning out to be near-identical (`get_sales_details` /
  `get_sales_homepage`, same enriched single-listing JSON shape, different frontend call sites) —
  factor out ONE internal helper (`_sale_detail_jsonb`) rather than duplicating the query body.**
  Both keep their own frontend-required name/signature (arg-order/naming still must match the
  locked contract exactly), but the actual SELECT logic lives in one place — cheaper to keep
  correct than two independently-drifting copies. Same instinct as the Batch-3
  `can_view_post`/`get_post_user_data` pair, just made explicit as a named pattern this time.
- **A distance-sorted feed (`get_sales_home_data`'s "Closest" sort) cannot use this schema's
  standard keyset `(created_at, id)` pagination — `distance_km` isn't monotonic with either
  column.** Rather than force a keyset shape that doesn't actually work for one of the two sort
  modes, used plain `LIMIT/OFFSET` (`p_offset`) for this ONE RPC and said so explicitly in both the
  function comment and the RLS-draft review checklist, instead of quietly keeping the
  `p_after_created_at`/`p_after_id` args from every other list RPC and having them silently do
  nothing under 'Closest' sort. When a list's sort key genuinely isn't the same as its natural
  ordering column, the pagination SHAPE should change too, not just get papered over.
- **Reminder:** this was FILES ONLY — no `apply_migration`/`execute_sql`/bucket-creation was run.
  Migration files live in `supabase/migrations/00{35..52}.sql` (18 files — enums/tables/helpers
  split per concern across events, then marketplace, then a dedicated anon-lockdown re-run, then
  RLS, then storage bucket creation + storage RLS as the final two files, mirroring the file-count
  scale of Batch 4's similarly large scope). Nothing is applied until the main thread reviews
  `docs/rls-policies-draft.md` ("Batch 5 — Events, Marketplace & Storage") and runs the migrations
  via Supabase MCP against `hlmymmlkgirafodcnkgg` (per `.claude/viora-project-ref.txt`).

### 2026-07-19 — Batch 3 (Neighbors/Follows) authored as files only, no MCP calls
- **A task's literal instruction text can be stale/imprecise vs. the actual applied migrations —
  trust the applied SQL, not the prose.** The task brief said "counter triggers SECURITY DEFINER
  for locked public_user_profile columns" and "can_view_post ... already [revoked from
  authenticated]", both echoing `docs/decisions.md`'s prose. Actually reading the applied files
  (`0013_post_triggers.sql`, `0009_post_functions_reads.sql`) showed neither is true:
  `trg_recompute_profile_post_count` is `security invoker` (trigger functions run as table owner
  regardless of INVOKER/DEFINER — 0013's own header comment explains why), and `can_view_post` IS
  granted to `authenticated` (only `public`/`anon` are revoked). When "match the applied
  convention exactly" and a task's descriptive aside disagree, grep the actual applied `.sql` file
  and match THAT — used `security invoker` for the new `follows` counter trigger and re-asserted
  `can_view_post`'s real current grants (not the aside's claimed ones) in the backfill migration,
  and flagged the discrepancy explicitly in the final summary instead of silently "fixing" it.
- **Two functions with the same frontend RPC name across different feature docs' write-ups can
  still be a single already-built RPC** — `docs/features/04-community-neighborhoods.md` describes
  `get_neighbourhood_post_data` as returning a JSON object with `total_user_count`/
  `total_post_count`/enriched `posts[]`, but Batch 2 already built a same-named RPC returning
  `setof public.post` (posts authored by a user) for a *different* screen set (`user_all_post`,
  three-dot menu). Rather than guess which is "right" and redefine it, left the existing Batch 2
  function untouched (out of this batch's file list) and only implemented the RPCs this task's own
  scope list actually named — cross-check a feature doc's RPC table against `docs/database/
  09-rpc-inventory.md`'s "shared with §N" cross-references before assuming a name is unbuilt.
- **Forward-compat dependency on a not-yet-built batch's table, reused pattern:** the event-invite
  helper `get_following_users_not_attending_event` needs `event_attending`, which doesn't exist
  yet (Events is a later batch, not Groups — the task only told me to skip *group*-dependent RPCs).
  Reused the exact `execute '...' using ...` + `exception when undefined_table then return;`
  pattern from Batch 2's `can_view_post()` friends-check (now itself replaced in this batch) rather
  than inventing a new forward-compat idiom — one reusable pattern for "RPC needs a table owned by
  a future batch" keeps every batch's stub-guards consistent and easy to grep for later.
  Same-batch dependency (this batch's own `follows` table) does NOT need the guard — only
  cross-batch forward references do.
- **RLS draft recommendation grounded in an actual grep, not assumption:** the task prompt itself
  asserted "followers/following screens show other users' followers" as justification to consider
  open read — grepping every `FollowsTable()` call site first showed EVERY direct-client read is a
  `querySingleRow` where one side of the pair is always `currentUserUid` (button-state checks);
  the screens that show OTHER users' lists all go through SECURITY DEFINER RPCs, not raw table
  reads. Recommended the narrower owner-involved-only policy (mirrors the `blocks` precedent) with
  the grep evidence inline, rather than following the prompt's unverified premise — a task
  instruction's stated rationale should still be checked against the actual code before it drives
  a security recommendation.
- **Toggle RPCs that take a caller-supplied "which user is me" arg:** `user_follow`'s
  `p_followerid` and `get_followers_nearby`'s `p_userid` are both frontend-sent but security-
  sensitive if trusted. Declared them as accepted-but-ignored params (kept in the signature for
  frontend call compatibility, `auth.uid()` used internally regardless of the argument value) and
  said so explicitly in the function comment — clearer and more auditable than silently validating
  `arg = auth.uid()` and raising, since a future reader diffing the signature can see at a glance
  the arg is decorative, not authorizing.
- **Reminder:** this was FILES ONLY — no `apply_migration`/`execute_sql` was run. Migration files
  live in `supabase/migrations/00{17..21}_*.sql` (deviated from the requested `0017-0020` count by
  splitting the RPC file into `0018`/`0019` for the 400-line cap, same as the Batch 2 precedent —
  triggers/backfill renumbered to `0020`/`0021` accordingly). Nothing is applied until the main
  thread reviews `docs/rls-policies-draft.md` (Batch 3 section) and runs the migrations via
  Supabase MCP against `hlmymmlkgirafodcnkgg` (per `.claude/viora-project-ref.txt`).

### 2026-07-19 — Batch 4 (Groups) authored as files only, no MCP calls
- **A state machine with 5 interlocking tables needs its access-control helpers built BEFORE the
  read/write RPCs, and the client-facing wrappers built AFTER, in a THIRD pass.** Wrote
  `is_group_admin`/`is_group_approved_member`/`group_admin_count` (internal, explicit 2-arg,
  revoked from all client roles) in their own file first (`0026_group_helpers.sql`), then every
  read/write RPC in later files calls them directly with an explicit `v_uid` — never duplicate the
  "is this user an admin of this group" query inline per RPC. Only at the very end, in the RLS
  file, add the `_self` (auth.uid()-closed-over, granted-to-authenticated) wrapper variants — this
  mirrors `can_view_post`/`can_view_post_self` from Batch 2 exactly and is now a confirmed 3-batch
  pattern: **internal 2-arg helper (locked) -> other DEFINER functions call it directly -> a
  `_self` 0-arg-effective wrapper (granted) exists ONLY for RLS policies**, never the reverse.
- **`FOUND` is a single implicit plpgsql variable that gets clobbered by the NEXT SQL statement —
  capture it into a local boolean immediately if you need to branch on it after an intervening
  INSERT/UPDATE.** Caught this mid-write in `invite_users_to_group()`: `select ... into v_row; ...
  insert ... on conflict ...; if found and v_row.x then` silently tested the INSERT's FOUND, not
  the SELECT's. Fixed by adding `v_had_status := found;` directly after the SELECT, before any
  other statement runs. When a function does SELECT-then-branch-after-another-DML, always snapshot
  `FOUND` (or check `row is not null` instead of relying on `FOUND` at all) rather than trusting it
  survives untouched — this is an easy, silent correctness bug that no linter catches.
  Two consecutive-only usages (`select ... into v; if found ...` with NOTHING in between) are fine
  as-is (used correctly in `request_or_join_group`/`accept_invite`) — the rule is specifically
  about FOUND surviving across an intervening statement, not FOUND itself being unsafe.
- **When a task names ONE combined RPC (`request_or_join_group`) but an earlier design doc/
  inventory speculated TWO split RPCs (`join_open_group`/`request_join_group`), the task's literal
  instruction wins — build exactly what's named, don't "reconcile" by building both.** Cross-check
  `docs/database/09-rpc-inventory.md` against the actual task brief before assuming the inventory
  is current; it's a design-time artifact, the task brief (and, once applied, the DB itself) is the
  live source of truth. Same for `delete_group_admin` covering BOTH resign (self) and revoke
  (target) — the task's own RPC list said this explicitly ("revoke_group_admin (delete_group_admin
  per frontend)"), so one function with a `caller = target OR caller is admin` predicate was
  correct, not three separate functions.
- **A column with no data to back a requested feature (`nearest` on group lists) should return a
  clearly-flagged constant, not an invented approximation.** `"group".location` is a free-text
  radio value, not a geography point — there's no lat/lon to compute real distance from, unlike
  `user_locations`/`get_followers_nearby`'s actual PostGIS column. Returned `nearest` as a hardcoded
  `false` with an inline `-- TODO(confirm)` explaining exactly why (no geo column exists) rather
  than guessing a proxy (e.g. matching the `location` text string to the caller's city) — a fake
  proxy would look like it works and quietly ship wrong behavior; a flagged constant is honest
  about the actual gap.
- **A smaller safety decision (blocking `leave_group()` when the caller is the group's only admin,
  which the frontend does NOT do — it unconditionally deletes) is a "make the call and record it"
  case (CLAUDE.md §7), not a "silently match the frontend exactly" case** — the frontend's literal
  DML would let a group end up with zero admins, undermining `delete_group_admin()`'s own
  last-admin guard elsewhere. Implemented the stricter/safer version, flagged it explicitly inline
  in the migration's own comment AND in the RLS draft's review checklist (not just one or the
  other) so it survives into both the applied schema and the review doc.
- **Reminder:** this was FILES ONLY — no `apply_migration`/`execute_sql` was run. Migration files
  live in `supabase/migrations/00{24..34}_*.sql` (11 files — larger than Batch 2/3's split because
  this batch has 5 tables + ~25 RPCs + triggers + RLS, roughly 2.5x Batch 3's scope; estimated line
  counts per function group up front before splitting, same practice as the Batch 2 lesson).
  Nothing is applied until the main thread reviews `docs/rls-policies-draft.md` ("Batch 4 —
  Groups") and runs the migrations via Supabase MCP against `hlmymmlkgirafodcnkgg` (per
  `.claude/viora-project-ref.txt`).

### 2026-07-19 — Batch 6 (Business Pages & Promotions + Chat/Messaging + Realtime) authored as files only, no MCP calls
- **A task's prose can assert a dependency exists when it doesn't — verify with a grep, don't
  trust it, even for something as basic as "the reports table exists".** The task brief said
  "report business (reports insert — reports table exists)"; `grep -rn "create table.*reports"
  supabase/migrations/` showed no such table anywhere (Moderation is a still-unbuilt batch).
  Rather than either (a) silently building the `reports` table myself (scope creep — not asked for,
  and risks colliding with the real Moderation batch's design) or (b) skipping report_business()
  entirely, reused the established forward-compat pattern (dynamic SQL + `undefined_table`
  exception guard, same as the Batch-5 `is_business_page_owner` storage stub) so the RPC exists,
  compiles, and safely no-ops today, and flagged the discrepancy explicitly in three places (the
  migration file's own header comment, the RLS review checklist, and the final summary) rather than
  quietly "fixing" the task's incorrect premise.
- **Activating a Batch-5 forward-compat storage helper once its dependency table lands is a
  distinct migration file, not a side-effect of creating the table.** Per the task's explicit
  instruction, wrote a dedicated backfill (`0055_business_storage_helper_backfill.sql`) that
  `create or replace`s `is_business_page_owner`/`is_business_promote_owner` with direct static
  queries once `business_page`/`business_promote` exist, and re-asserts their exact grants — same
  shape as `0021_follows_backfill_view_access.sql`/`0042_event_backfill_invite_helper.sql`. Verified
  first that the stub's assumed column names (`admin_user`, `business_page_id`) actually matched
  the real table (they did) rather than assuming the backfill was a no-op-diff; noted the
  verification explicitly in the file so a future reader doesn't have to re-derive it. Functionally
  the OLD dynamic-SQL stub would have started working automatically the moment the table existed
  (dynamic SQL isn't validated at CREATE FUNCTION time) — the backfill is about removing the
  now-unnecessary dynamic-SQL/exception-guard overhead and confirming the assumption in writing, not
  about fixing broken behavior.
- **RLS policies on `realtime.messages` need a GRANTED `_self` wrapper, exactly like table RLS
  policies do — this is easy to miss because `realtime.messages` "feels" like infrastructure, not
  an app table.** First draft of the Broadcast-authorization policy called the internal
  `is_chat_member(chat_id, user_id)` helper directly from the `USING` clause; since that helper is
  `revoke all ... from public, anon, authenticated` (correct, for every OTHER internal helper in
  this schema), the policy would fail for every authenticated user at evaluation time even though
  the helper is `SECURITY DEFINER` — the querying role still needs bare EXECUTE to invoke a function
  at all inside its own policy expression. Fixed by creating `is_chat_member_self(chat_id)` (granted
  to `authenticated`) BEFORE the policy, in the same file — the `internal-2-arg-locked +
  self-scoped-1-arg-granted` split (established for table RLS: `is_event_owner`/
  `is_event_owner_self`, `is_group_admin`/`is_group_admin_self`) applies identically to
  `realtime.messages` policies, not just `public.*` table policies. Catch this class of bug by
  checking, for every helper referenced inside ANY `create policy ... using (...)` (table or
  `realtime.messages`), whether that helper shows up in a `revoke all ... from ... authenticated`
  statement anywhere else in the migration set — if it does, the policy needs the granted wrapper,
  not the raw internal function.
- **Private Broadcast + server-only publish is achievable with a SELECT-only policy on
  `realtime.messages` — no INSERT policy needed when every broadcast originates from a DB trigger.**
  `realtime.broadcast_changes()`/`realtime.send()` run as the calling function's role (here, the
  `SECURITY DEFINER` trigger owner), which bypasses the `realtime.messages` RLS the same way any
  other `SECURITY DEFINER` write bypasses a `public.*` table's RLS — so a client-authorization
  policy only needs to gate SELECT (who can *subscribe/receive*), never INSERT (who can *publish*),
  as long as the app never uses client-side `channel.send()`. Documented this explicitly in the
  migration's own comment (not just implied) so a future reader doesn't add an unnecessary/dangerous
  INSERT policy "to be safe."
- **A read RPC that derives a UI status word from stored columns (`business_promote.status` +
  `plan_end_date` -> `promotion_status`) must be `STABLE`, not `IMMUTABLE`, the moment it calls
  `now()` — caught before writing it to the migration, not after.** First draft of
  `_business_promotion_status()` was marked `immutable` (seemed reasonable for a pure
  computation-over-arguments helper with no table access) but its body compares `plan_end_date <
  now()`; `now()` is transaction-stable, not immutable, so the volatility category must match the
  actual function body, not the "looks like a pure function" intuition. General rule: any
  `language sql`/`plpgsql` helper that touches `now()`/`current_timestamp`/`clock_timestamp()`
  anywhere in its body is at best `STABLE` (never `IMMUTABLE`), regardless of how simple/pure the
  rest of the function looks.
- **`ON CONFLICT ... DO UPDATE SET col = coalesce(excluded.col, <table>.col)` must reference the
  target table UNQUALIFIED (just the table name), not schema-qualified (`public.table.col`).** Wrote
  `coalesce(excluded.receipt, public.business_promote.receipt)` initially by habit (this schema
  schema-qualifies almost everything else); the target-row correlation name inside an `ON CONFLICT
  DO UPDATE` clause is the bare table name (acting as its own implicit alias), not its
  schema-qualified form — checked every prior `ON CONFLICT DO UPDATE` in the codebase (Batch 4/5)
  before writing this one and found none schema-qualify the self-reference, which caught the
  inconsistency before it became an untested syntax risk. When writing a NEW `ON CONFLICT DO
  UPDATE` that self-references the pre-update row (not just `excluded.*`), grep prior examples in
  the same codebase first rather than applying the file's general schema-qualification habit
  uniformly.
- **A task's plain-English RPC name list can differ from the ACTUAL frontend REST endpoint name —
  resolve using the feature doc's literal `rpc/<name>` citation, not the prose.** The task listed
  "business_homepage"/"get_business" as RPC names; `docs/features/08-business-promotions.md` §4's
  own table shows the real endpoint names are `rpc/get_business_details`/`rpc/get_all_business`
  (the prose names are the Dart *widget/Call-class* names, e.g. `BusinessHomepageCall`, not the
  PostgREST function name PostgREST actually dispatches on). Used the literal `rpc/...` names from
  the doc's own citation (which is what the locked frontend actually calls over HTTP) and noted the
  task-prose-to-real-name mapping explicitly in the migration file header, rather than creating
  functions under the task's looser prose names (which would silently break the frontend contract).
- **Reminder:** this was FILES ONLY — no `apply_migration`/`execute_sql` was run. Migration files
  live in `supabase/migrations/00{53..66}_*.sql` (14 files — enums / business tables / storage-
  helper backfill / business reads-writes-admin RPCs (3 files) / chat tables / chat helpers / chat
  reads-writes RPCs (2 files) / chat preview trigger / chat realtime (RLS on `realtime.messages` +
  broadcast trigger) / business+chat table RLS / anon-lockdown re-run). All 14 files stayed under
  CLAUDE.md §5's 400-line cap (largest: `0057_business_functions_writes.sql` at 388 lines) —
  estimated per-function line counts up front (Batch 2 lesson) and split business reads/writes/admin
  and chat reads/writes into separate files proactively rather than discovering an overflow mid-file.
  Nothing is applied until the main thread reviews `docs/rls-policies-draft.md` ("Batch 6 —
  Business & Chat") and runs the migrations via Supabase MCP against `hlmymmlkgirafodcnkgg` (per
  `.claude/viora-project-ref.txt`).

### 2026-07-19 — Batch 7 (Notifications, Search & Moderation) — FINAL backend batch, files only
- **Build moderation's `reports` table FIRST, then immediately backfill the prior batch's stub in
  its OWN dedicated file, not folded into the RPC file that defines the new admin RPCs.** The task
  explicitly called this out ("other batches' stubs depend on `reports`"), and the Batch-6 playbook
  entry already showed the exact pattern to reuse (0055's business-storage-helper backfill). Kept
  `0075_reports_backfill_report_business.sql` as its own file (not merged into `0074`'s
  report_content/get_reports/set_report_status) so the "activate a forward-compat stub" diff stays
  isolated and easy to review/verify against the real table shape in one place — confirmed the
  Batch-6 stub's assumed column names (`community_id, reported_by_user, report_type,
  business_page_id, reason`) actually matched before writing the backfill, rather than assuming.
- **`auth.uid()` called from INSIDE a `SECURITY DEFINER` trigger still returns the ORIGINAL calling
  user's uid, not the function owner's** — this unblocked "business admin promotion status ->
  notify owner" without touching the already-applied `admin_set_promotion_status()` RPC (the task
  explicitly forbade modifying applied RPCs, only adding NEW triggers). `request.jwt.claims` is a
  whole-session/transaction-level GUC, unaffected by a function's SECURITY DEFINER privilege
  switch — the same reasoning `is_admin()` already relies on. When a trigger needs "who actually
  did this" and the triggering RPC didn't store an explicit actor column, check whether auth.uid()
  is still readable inside the trigger before reaching for a session-variable workaround
  (`set_config`) or modifying the RPC — it usually just works.
- **A DB write path needing to CALL an Edge Function (push notifications) is a THIRD "forward-
  compat-shaped" problem, distinct from the two already-catalogued ones (dynamic-SQL-guarded table
  reference; storage-helper stub)** — solved with a guarded `pg_net` call wrapped in `begin...
  exception when others then null; end;`, reading the target URL/service-role key from
  `current_setting('app.settings.*', true)` (the `true` "missing_ok" arg is essential — without it,
  an unset custom GUC raises instead of returning NULL). This is the reusable pattern for "a
  trigger's side-effect depends on infrastructure (extension/secret/network) that may not be
  configured yet at migration-apply time" — never let a best-effort side-effect (push delivery)
  risk failing the primary write (the notification row itself). Documented every required manual
  step (secret name, GUC names, exact CLI commands) inline in BOTH the migration file's header and
  the Edge Function's own header comment, not just one or the other.
- **`pg_net`'s functions are conventionally exposed under a schema literally named `net`
  (`net.http_post`), not whatever schema you happen to pass to `with schema` if you improvise one**
  — first draft used `with schema extensions` (matching this repo's usual extension-schema
  convention) and called `extensions.net.http_post(...)`, which is wrong: the extension's
  functions land directly IN the schema you name (`extensions.http_post`), there is no nested
  `net.` sub-schema created automatically. Fixed by `create schema if not exists net;` then
  `create extension if not exists pg_net with schema net;`, matching Supabase's own documented
  `net.http_post` call convention exactly. Check a new extension's OWN documented call convention
  before assuming it follows this repo's usual "put it in `extensions`" habit — pgcrypto/postgis
  are schema-agnostic by naming (their functions are called unqualified via search_path), pg_net
  is NOT (its functions are always schema-qualified `net.*` in every Supabase doc/example).
- **Two independent AFTER INSERT triggers on the SAME table (broadcast + push) is cleaner than one
  combined trigger function** — `trg_broadcast_new_notification` (realtime) and
  `trg_push_new_notification` (FCM via pg_net) are separate functions/triggers on `notifications`,
  even though both fire on the exact same event. This means a failure/exception in one is fully
  isolated from the other (Postgres runs each trigger independently; an exception in one aborts
  the whole statement unless THAT trigger's own body catches it — which only the push trigger does,
  deliberately, since push is best-effort and broadcast is not). Matches the general principle "one
  trigger, one concern" over cramming multiple side-effects into a single function — makes it
  trivial to disable/drop just one side-effect later without touching the other.
- **A "keep it simple" instruction for an ambiguous cross-cutting requirement (`reports.mail_sent`
  = "email admin") is still a case for reusing an EXISTING mechanism (notify()) rather than
  inventing a new one, with the gap flagged, not silently expanded into new scope.** Building a
  real transactional-email Edge Function + provider secret was NOT requested/in scope (no email
  provider was named anywhere in this batch's inputs) — reusing `notify()` to alert admins in-app
  and flagging "this is not a real email" explicitly in three places (migration header, RLS-draft
  checklist, final summary) is the correct-sized response to an explicit "keep simple" instruction
  paired with a stated TODO(confirm), rather than either skipping the mail_sent trigger entirely or
  quietly building a bigger email-sending feature that wasn't asked for.
- **Reminder:** this was FILES ONLY — no `apply_migration`/`execute_sql`/`deploy_edge_function` was
  run. Migration files live in `supabase/migrations/00{68..84}_*.sql` (17 files — search
  extension/table/indexes/functions (5 files), reports table/functions/backfill (3 files),
  notifications tables/notify-helper/triggers (2 files)/mail-trigger/read-functions/push-realtime
  (6 files), RLS, anon-lockdown re-run). New Edge Function:
  `supabase/functions/send-notification/index.ts` (FCM HTTP v1, service-account JWT signing via
  `npm:jose`). This is the FINAL backend batch — nothing is applied/deployed until the main thread
  reviews `docs/rls-policies-draft.md` ("Batch 7"), runs the migrations via Supabase MCP against
  `hlmymmlkgirafodcnkgg` (per `.claude/viora-project-ref.txt`), deploys the Edge Function, sets the
  `FCM_SERVICE_ACCOUNT_JSON` secret, and applies the ONE `realtime.messages` policy (0082) via CLI/
  Dashboard (same MCP-ownership limitation as Batch 6's chat realtime policy).

### 2026-07-19 — Auth/utility Edge Functions (9) authored as files only, password-only phase
- **For AUTH edge functions the HTTP STATUS CODE is the primary contract, and the app's `.error()`
  extractor dereferences with `!` — so every non-2xx MUST carry a non-null `error` string or the
  Flutter side crashes.** `ApiCallResponse.succeeded` is literally `statusCode >= 200 && < 300`
  (api_manager.dart:170); the widgets gate on `?.succeeded` and, on the failure branch, call e.g.
  `VaildateUserCall.error(json)!`. Grepped each Call class's static extractors AND each widget's
  consumption before deciding shapes: `authenticate-user`/`change-password` need `{error}` on
  failure (dereferenced with `!`); `check-user-exist` must ALWAYS return 200 with both
  `email_exists`+`mobile_number_exists` present booleans (read via `castToType<bool>` then `!= true`);
  `check-user` must always return 200 `{exists:<bool>}` (read with `!`). Don't guess an auth response
  shape from the endpoint name — read the exact `castToType<...>(getJsonField(response, r'$.field'))`
  extractor and the widget's `if (...succeeded)` / `.error(...)!` branch together.
- **A "verify the credential" edge function needs the GoTrue password grant, and there is NO admin
  API to check a password** — `supabase.auth.admin.*` can create/update/get users but cannot verify
  a password. The only server-side credential check is `POST ${SUPABASE_URL}/auth/v1/token?grant_type=
  password` with the ANON key (`apikey` + `Authorization: Bearer <anon>`), which mirrors exactly the
  client-side `signInWithPassword` the app runs next. `SUPABASE_ANON_KEY` IS auto-injected into every
  Edge Function (alongside `SUPABASE_URL`/`SUPABASE_SERVICE_ROLE_KEY`), so no custom secret is needed.
  Reused this same grant inside `change-password` to re-verify the OLD password (proof-of-ownership)
  before `admin.updateUserById` — an authenticated-but-hijacked session shouldn't silently rotate a pw.
- **Email-vs-phone detection from a single `identifier` field: `identifier.includes("@")` is
  sufficient here because the frontend already prepends the country code** (`${AsCountryCode}${number}`,
  default `+44`) for phone identifiers and never puts `@` in a phone — confirmed by reading
  login_page_widget.dart:862 (VaildateUser identifier) and verify_page (phone-signup phone). Phone is
  therefore always E.164-ish (`+` + digits); route to GoTrue `{phone}` vs `{email}` accordingly.
- **`verify_jwt` is a DEPLOY-TIME setting (CLI `--no-verify-jwt` / config.toml), not something the
  .ts file controls — so it must be documented, not coded.** No `supabase/config.toml` exists in this
  repo, so I documented the per-function choice in every file header AND the README table: FALSE for
  all pre-auth functions (the app sends the anon key as Bearer, not a user JWT), TRUE only for
  `change-password` (owner-only; also re-validated in-function via `auth.getUser(token)` and the user
  id derived SOLELY from the JWT, never from client input — CLAUDE.md §6).
- **Honest stubs for deferred security steps must NOT return 2xx** — `verify_otp` returning 200 would
  fake-succeed a verification with no real check (CLAUDE.md §6), and `reset-password` returning 200
  would imply a password actually rotated. Returned 503 `{success:false, deferred:true, error}` for
  send-otp/verify_otp/reset-password (never leaking a code), and the benign `200 {tldr:""}` only for
  the explicitly-skipped generate-tldr. Critically, this SURFACES a real frontend/backend mismatch to
  flag rather than paper over: the locked frontend gates email/phone signup + forgot-password behind
  `send-otp`→`verify_otp` and checks `.succeeded`, so with OTP deferred those flows are BLOCKED at
  that step (password LOGIN + Google signup still work). The honest 503 makes the block explicit and
  documented (README "reconciliation items" + final summary) instead of a silent dead-end — resolving
  it (real provider vs. a frontend OTP-bypass for the password-only phase) is a stakeholder decision.
- **Removed the leaked `x-secret-key` without breaking CORS:** `phone-signup`'s current client sends
  `x-secret-key: <FFDevEnvironmentValues().secretKey>` (a leaked secret, docs §8.3). The function
  DELIBERATELY ignores it (validates inputs + creates via `admin.createUser({phone, password,
  phone_confirm:true})` instead), but I kept `x-secret-key` in the CORS `Access-Control-Allow-Headers`
  allow-list so the current client's request doesn't fail preflight on Flutter Web — accept-and-ignore
  the header at the app layer while the secret is rotated, rather than rejecting it and breaking the
  live client. Inlined the CORS helper + `json()` builder per-function (not a shared import) so each
  folder deploys independently without cross-function import-path risk.
- **Reminder:** this was FILES ONLY — no `deploy_edge_function`/MCP was run. New files:
  `supabase/functions/{authenticate-user,check-user-exist,check-user,phone-signup,change-password,
  send-otp,verify_otp,reset-password,generate-tldr}/index.ts` + `supabase/functions/README.md`.
  Note `verify_otp` folder uses an UNDERSCORE to match the app's `/functions/v1/verify_otp` endpoint.
  Nothing is deployed until the main thread reviews and deploys (with the per-function `verify_jwt`
  flag from the README) against `hlmymmlkgirafodcnkgg` (per `.claude/viora-project-ref.txt`).

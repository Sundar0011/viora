# Viora — RLS Policies Draft

> **Batch 1 — Identity: APPLIED 2026-07-19** as `supabase/migrations/0006_identity_rls.sql`
> against project `hlmymmlkgirafodcnkgg`. Two review choices were made before applying:
> (1) admins MAY read the private `"user"` row (added `user_select_admin`);
> (2) counter columns on `public_user_profile` are locked via column-level `REVOKE UPDATE`.
> One item was deferred: hiding soft-deleted profiles (the draft's `NOT EXISTS` check can't work
> under owner-only RLS on `"user"`) — implemented later in the Profile/Account batch with the
> delete flow. Future batches keep following the review-before-apply gate below.
>
> Per CLAUDE.md §6.9: RLS policies are reviewed here BEFORE `apply_migration` ever runs them.
> Nothing in this file has been applied. The tables it covers already exist with
> `ENABLE ROW LEVEL SECURITY` and **no policies** (`supabase/migrations/0003_identity_tables.sql`)
> — meaning they are currently deny-all to `anon`/`authenticated`. Once this file is reviewed and
> approved, the policies below become a new migration (`0005_identity_rls.sql` or similar),
> applied via Supabase MCP against Viora's own project only.
>
> Every helper-function call in a policy is wrapped `(select helper())` so the planner evaluates
> it once per query, not once per row (CLAUDE.md §6.8, supabase-postgres-best-practices
> `security-rls-performance`). Every policy specifies `to authenticated` explicitly — `TO
> authenticated` alone is not sufficient authorization, so every policy also carries an ownership
> or role predicate (never a bare `true`).

## Batch 1 — Identity (`"user"`, `user_roles`, `public_user_profile`, `user_login`,
`user_devices`, `user_locations`, `audit_log`)

### `"user"` — owner-only, no exceptions (Decision: Identity RLS, docs/decisions.md 2026-07-19)

```sql
alter table public."user" enable row level security;

-- Intent: a user may read their own private/PII row, and no one else's.
create policy "user_select_own"
  on public."user"
  for select
  to authenticated
  using ( id = (select auth.uid()) );

-- Intent: a user may update their own row only; cannot reassign id to someone else's.
create policy "user_update_own"
  on public."user"
  for update
  to authenticated
  using ( id = (select auth.uid()) )
  with check ( id = (select auth.uid()) );

-- Intent: no direct client INSERT policy at all — rows are created only by the
-- SECURITY DEFINER signup_finalize() RPC (which runs as table owner, bypassing RLS).
-- Intent: no DELETE policy — accounts are soft-deleted (is_deleted/status) via delete_account()
-- RPC (Batch: Profile & Account), never hard-deleted by a client.
```

### `user_roles` — SELECT own row only; all writes admin/RPC-only

```sql
alter table public.user_roles enable row level security;

-- Intent: a user may see their own role row (e.g. to render admin-only UI conditionally).
create policy "user_roles_select_own"
  on public.user_roles
  for select
  to authenticated
  using ( id = (select auth.uid()) );

-- Intent: admins may see any role row (moderation/support tooling).
create policy "user_roles_select_admin"
  on public.user_roles
  for select
  to authenticated
  using ( (select public.is_admin()) );

-- Intent: no INSERT/UPDATE/DELETE policy for authenticated at all — this table is the JWT role
-- source; writes happen exclusively through signup_finalize() (INSERT) and any future
-- assign_role()-style SECURITY DEFINER admin RPC (UPDATE), never direct client DML.
```

### `public_user_profile` — public read, owner-only write (the app's PRIMARY profile read surface)

```sql
alter table public.public_user_profile enable row level security;

-- Intent: any authenticated user may read any (non-deleted) profile — this is the app's public
-- profile surface. Excludes profiles whose owner has soft-deleted their "user" row.
create policy "public_user_profile_select_authenticated"
  on public.public_user_profile
  for select
  to authenticated
  using (
    not exists (
      select 1 from public."user" u
      where u.id = public_user_profile.id
        and u.is_deleted = true
    )
  );

-- Intent: a user may insert their own profile row only (defense-in-depth; signup_finalize()
-- is the only expected writer today, running as table owner and bypassing this policy anyway).
create policy "public_user_profile_insert_own"
  on public.public_user_profile
  for insert
  to authenticated
  with check ( id = (select auth.uid()) );

-- Intent: a user may update their own profile fields (name, bio, images, etc.) only.
-- NOTE: this does NOT stop a client from writing the counter columns (followers/following/
-- post_count/group_count/event_count/sale_count) directly via PostgREST, since RLS is row-level,
-- not column-level. Counters must be re-asserted by their maintaining triggers (see
-- docs/database/08-triggers-counters.md) or this policy narrowed to a column allow-list once the
-- trigger batch lands. Flagged, not fixed here — Batch 1 is identity/auth only.
create policy "public_user_profile_update_own"
  on public.public_user_profile
  for update
  to authenticated
  using ( id = (select auth.uid()) )
  with check ( id = (select auth.uid()) );
```

### `user_login` — deny-all to client roles; service_role (edge functions) only

```sql
alter table public.user_login enable row level security;

-- Intent: no policy is added for anon/authenticated at all. RLS defaults to deny for every role
-- that isn't the table owner or a BYPASSRLS role; service_role has BYPASSRLS and reads/writes
-- this table directly from the send-otp / verify_otp / reset-password / phone-signup edge
-- functions. No SELECT/INSERT/UPDATE/DELETE policy is ever expected here.
```

### `user_devices` — owner-only, writes via RPC only

```sql
alter table public.user_devices enable row level security;

-- Intent: a user may see only their own registered devices.
create policy "user_devices_select_own"
  on public.user_devices
  for select
  to authenticated
  using ( user_id = (select auth.uid()) );

-- Intent: no direct client INSERT/UPDATE/DELETE policy — registration/refresh happens only via
-- the upsert_user_device_fcm() SECURITY DEFINER RPC (docs/database/09-rpc-inventory.md §1),
-- which validates auth.uid() = p_user_id internally and runs as table owner.
```

### `user_locations` — owner-only, writes via RPC only, raw coordinates never exposed to other users

```sql
alter table public.user_locations enable row level security;

-- Intent: a user may read only their own saved location point (raw lat/lon never exposed to any
-- other user; nearby lists are computed server-side by get_followers_nearby(), which returns only
-- distance_km).
create policy "user_locations_select_own"
  on public.user_locations
  for select
  to authenticated
  using ( id = (select auth.uid()) );

-- Intent: no direct client INSERT/UPDATE/DELETE policy — writes happen only via the
-- update_user_location() SECURITY DEFINER RPC, which validates auth.uid() and builds the
-- geography point server-side from lat/lon.
```

### `audit_log` — admin-only SELECT, no client writes at all

```sql
alter table public.audit_log enable row level security;

-- Intent: only admins may read the audit trail (moderation/support/compliance review).
create policy "audit_log_select_admin"
  on public.audit_log
  for select
  to authenticated
  using ( (select public.is_admin()) );

-- Intent: no INSERT/UPDATE/DELETE policy for any client-facing role. Every row is written by a
-- SECURITY DEFINER function running as table owner (e.g. signup_finalize()), which bypasses RLS.
-- Append-only by construction: no UPDATE/DELETE policy exists for any role, including admin.
```

---

## Review checklist before this is applied
- [ ] Confirm `"user"` truly gets no admin bypass (per Decision: Identity RLS — PII stays
      narrowest-possible; admin moderation of `"user"` would need its own validated
      `SECURITY DEFINER` RPC, not a blanket admin SELECT/UPDATE policy).
- [ ] Confirm the `public_user_profile_update_own` counter-column gap (noted inline above) is
      acceptable for Batch 1, or whether it should be deferred until Batch 1's tables get their
      trigger-maintained counters wired up in a later batch.
- [ ] Confirm Supabase project ref before `apply_migration` — must match
      `.claude/viora-project-ref.txt` (`hlmymmlkgirafodcnkgg`).

---

## Batch 2 — Posts & Comments (`post`, `post_images`, `post_like`, `post_share`, `tag`,
`see_post_access`, `comment_post_access`, `post_comment`, `post_comment_likes`, `blocks`)

> **APPLIED 2026-07-19** as `supabase/migrations/0016_post_rls.sql`. Changes from the draft below:
> (1) policies call the new self-scoped `can_view_post_self(post_id)` wrapper instead of
> `can_view_post(auth.uid(), …)` — the arbitrary-viewer helpers stay internal (not client-callable);
> (2) comment reads ride on post visibility (approved — existing comments stay readable even when
> `comment_post_access='No One'`); (3) blocking enabled now — `blocks` got owner-scoped
> INSERT/DELETE (self-block prevented) so the block button works, not deferred to Moderation.
>
> Original draft (for history):
> Tables already exist with `ENABLE ROW LEVEL SECURITY` and **no policies**
> (`supabase/migrations/0008_post_tables.sql`) — currently deny-all. Not applied until reviewed.
> Every helper call is wrapped `(select helper())`. All SELECT policies below layer on top of the
> `can_view_post()` / `can_comment_post()` / `is_blocked_pair()` SECURITY DEFINER helpers from
> `0009_post_functions_reads.sql`, which is why most SELECT policies here simply delegate to them
> rather than re-deriving the view-access + two-way-block logic inline in the policy predicate —
> this keeps the visibility rule defined in exactly one place (the helper functions) instead of
> duplicated between RLS and every read RPC.

### `post` — view-access + block-filtered SELECT; RPC-only writes

```sql
alter table public.post enable row level security;

-- Intent: a caller may SELECT a post only if can_view_post() allows it (author-always,
-- Everyone/Friends-only/Nearby per see_post_access_id) AND the author hasn't blocked/isn't
-- blocked by the caller (two-way).
create policy "post_select_visible"
  on public.post
  for select
  to authenticated
  using ( (select public.can_view_post((select auth.uid()), post.id)) );

-- Intent: no direct client INSERT/UPDATE/DELETE policy at all. Every write goes through
-- create_post() / update_user_post() / delete_post() (SECURITY DEFINER, owner-validated,
-- audited) per docs/decisions.md (2026-07-19, "User-facing writes").
```

### `post_images` — SELECT follows post visibility; writes via RPC only

```sql
alter table public.post_images enable row level security;

-- Intent: an image row is visible exactly when its parent post is visible to the caller.
create policy "post_images_select_visible"
  on public.post_images
  for select
  to authenticated
  using ( (select public.can_view_post((select auth.uid()), post_images.post_id)) );

-- Intent: no client INSERT/UPDATE/DELETE policy — rows are written only by
-- insert_post_image_rows() / update_user_post() (post-owner validated inside the RPC).
```

### `post_like` — SELECT follows post visibility; writes via `add_like()` RPC only

```sql
alter table public.post_like enable row level security;

-- Intent: a like row is visible exactly when its parent post is visible to the caller (drives
-- the filled/outline heart state via a direct client SELECT).
create policy "post_like_select_visible"
  on public.post_like
  for select
  to authenticated
  using ( (select public.can_view_post((select auth.uid()), post_like.post_id)) );

-- Intent: no client INSERT/DELETE policy — the locked frontend's AddLikeCall already goes
-- through add_like() (SECURITY DEFINER toggle), never a raw client insert/delete of this table.
```

### `post_share` — SELECT follows post visibility; writes via `update_post_share_count()` RPC only

```sql
alter table public.post_share enable row level security;

-- Intent: a share row is visible exactly when its parent post is visible to the caller.
create policy "post_share_select_visible"
  on public.post_share
  for select
  to authenticated
  using ( (select public.can_view_post((select auth.uid()), post_share.post_id)) );

-- Intent: no client INSERT/DELETE policy — writes only via update_post_share_count() RPC.
```

### `tag` — SELECT follows post visibility; writes via `insert_tags()` RPC only

```sql
alter table public.tag enable row level security;

-- Intent: a tag row is visible exactly when its parent post is visible to the caller. A NULL
-- post_id tag (frontend Row class allows it) is never selectable via this policy — TODO(confirm)
-- whether a post_id-less tag has any legitimate read path; none observed in the feature docs.
create policy "tag_select_visible"
  on public.tag
  for select
  to authenticated
  using (
    tag.post_id is not null
    and (select public.can_view_post((select auth.uid()), tag.post_id))
  );

-- Intent: no client INSERT/UPDATE/DELETE policy — writes only via insert_tags() RPC, which
-- validates the caller owns the post.
```

### `see_post_access` / `comment_post_access` — SELECT to authenticated; admin-only writes

```sql
alter table public.see_post_access enable row level security;
alter table public.comment_post_access enable row level security;

-- Intent: every authenticated user may read the (tiny, static) lookup rows.
create policy "see_post_access_select_authenticated"
  on public.see_post_access
  for select
  to authenticated
  using ( true );

create policy "comment_post_access_select_authenticated"
  on public.comment_post_access
  for select
  to authenticated
  using ( true );

-- Intent: no INSERT/UPDATE/DELETE policy for any client role — these are seeded, admin-curated
-- lookup tables; changes happen via a reviewed migration, not client writes.
```

### `post_comment` — SELECT via `comment_post_access` + block filter; writes via `add_comment()`
RPC only; no client UPDATE/DELETE (moderation is admin-only via `delete_comment()`)

```sql
alter table public.post_comment enable row level security;

-- Intent: a comment is visible exactly when its parent post is visible to the caller (comment
-- visibility rides on post visibility — comment_post_access only gates who may WRITE a comment,
-- not who may read existing ones, matching docs/features/03-comments.md's realtime-enrichment
-- flow which reads all comments on a visible post).
create policy "post_comment_select_visible"
  on public.post_comment
  for select
  to authenticated
  using ( (select public.can_view_post((select auth.uid()), post_comment.post_id)) );

-- Intent: no client INSERT/UPDATE/DELETE policy at all. INSERT goes through add_comment()
-- (validates comment_post_access + single-level threading); DELETE is admin-only via
-- delete_comment() (docs/features/03-comments.md §7 — no client delete path observed); no UPDATE
-- path exists anywhere in the frontend.
```

### `post_comment_likes` — SELECT follows parent comment/post visibility; writes via
`add_comment_like()` RPC only

```sql
alter table public.post_comment_likes enable row level security;

-- Intent: a comment-like row is visible exactly when its parent post is visible to the caller
-- (drives the filled-heart lookup on (comment_id, user_id)).
create policy "post_comment_likes_select_visible"
  on public.post_comment_likes
  for select
  to authenticated
  using ( (select public.can_view_post((select auth.uid()), post_comment_likes.post_id)) );

-- Intent: no client INSERT/DELETE policy — writes only via add_comment_like() RPC (toggle).
```

### `blocks` — owner (blocker) manages own rows only; no cross-user read

```sql
alter table public.blocks enable row level security;

-- Intent: a user may see only the blocks THEY created (their own block list). Being blocked by
-- someone else is never directly readable — that fact is only ever surfaced indirectly, via
-- content simply not appearing (is_blocked_pair() inside content read RPCs), never as a queryable
-- "who blocked me" list.
create policy "blocks_select_own"
  on public.blocks
  for select
  to authenticated
  using ( blocker_id = (select auth.uid()) );

-- Intent: this batch creates ONLY the table + the is_blocked_pair() read-side filter, per the
-- task's explicit scope. block_user()/unblock_user() RPCs (which would be the INSERT/DELETE path
-- for this table) and the report/mute UI are deferred to the Moderation batch — so NO
-- INSERT/UPDATE/DELETE policy is added here yet either; the table is effectively read-only
-- (owner-scoped) until that batch adds the write RPCs. -- TODO(confirm): when the Moderation
-- batch lands, block_user()/unblock_user() should be SECURITY DEFINER RPCs (self-block guard,
-- audit-worthy) per docs/database/09-rpc-inventory.md §13, not a direct client insert/delete
-- policy, to keep the self-block guard and audit log server-enforced.
```

---

## Review checklist — Batch 2 (things assumed/confirm before applying)
- [ ] **`see_post_access` semantics (2026-07-19 stakeholder clarification, applied):** id 1 =
      Everyone, id 2 = Friends only (mutual follow via the `follows` table), id 3 = Nearby
      (geographic via `user_locations`). The `follows` table does not exist yet (Neighbors/Follows
      batch) — `can_view_post()` guards the friends-check with an `undefined_table` exception
      handler and returns `false` (not visible) until that table lands. Re-verify Friends-only
      visibility once `follows` is created.
- [ ] **TODO(confirm): "Friends only" = mutual follow vs. either-direction.** Implemented as
      mutual (both directions) in `can_view_post()`.
- [ ] **TODO(confirm): "Nearby" radius.** Defaulted to 5km in `can_view_post()`
      (`0009_post_functions_reads.sql`) — confirm the real product radius.
- [ ] **TODO(confirm): `comment_post_access` ids 2/3.** Only ids 1 (Anyone) and 4 (No One) are
      seeded/confirmed; `can_comment_post()` denies by default for any other id.
- [ ] **TODO(confirm):** whether a `tag` row with `post_id IS NULL` has any legitimate read path
      (none found in the feature docs) — currently never selectable.
- [ ] **Comment read visibility rides on post visibility, not `comment_post_access_id`.**
      `comment_post_access_id` only gates who may INSERT a new comment (enforced by
      `add_comment()`/`can_comment_post()`), matching the realtime-enrichment read flow in
      docs/features/03-comments.md. Confirm this is the intended behavior (i.e. "No One can
      comment" does not also hide EXISTING comments from other readers).
- [ ] **`blocks` has no client INSERT/DELETE policy yet** — intentional, since `block_user()`/
      `unblock_user()` RPCs are explicitly deferred to the Moderation batch per this task's scope;
      until then the table can only be seeded by an admin/SQL, not created by end users blocking
      each other. Confirm this gap is acceptable for the interim between Batch 2 and the
      Moderation batch (i.e. two-way block FILTERING is live now, but end users cannot yet create
      a block via the app).
- [ ] Confirm Supabase project ref before `apply_migration` — must match
      `.claude/viora-project-ref.txt` (`hlmymmlkgirafodcnkgg`).

---

## Batch 3 — Follows (`follows`)

> **APPLIED 2026-07-19** as `supabase/migrations/0023_follows_rls.sql`. Approved **Option B
> (owner-involved SELECT)**: `follower_id = auth.uid() OR following_id = auth.uid()`; writes
> RPC-only via `user_follow()` (no client INSERT/UPDATE/DELETE). Other users' follower/following/
> nearby lists go through the block-filtered SECURITY DEFINER read RPCs (which bypass RLS).
>
> Original draft (for history):
> Tables already exist with `ENABLE ROW LEVEL SECURITY` and **no policies**
> (`supabase/migrations/0017_follows_table.sql`) — currently deny-all. Not applied until reviewed.
> Every helper call is wrapped `(select helper())`. Writes are RPC-only (`user_follow()`,
> `0018_follows_functions_toggle.sql`) — there is deliberately NO client INSERT/UPDATE/DELETE
> policy on `follows`, matching CLAUDE.md §6.2/§6.3 ("admin-only writes by default" / "user-facing
> writes go through RPC, not direct DML") and the locked frontend, which never inserts/deletes
> `follows` directly (only `FollowsTable().querySingleRow(...)` reads + `AddFollowCall` → RPC).

### `follows` — SELECT: two options, RECOMMENDATION = Option B (owner-involved only)

Every direct client read of `follows` observed in the locked frontend
(`grep -rn "FollowsTable()" lib/`) is a `querySingleRow` button-state check where **one side of
the pair is always `currentUserUid`** (e.g. `follower_id = currentUserUid AND following_id =
<other user>`, or the reverse) — see e.g. `lib/pages/profile/followers/followers_widget.dart`
line ~632. The screens that show OTHER users' follower/following LISTS
(`followers_widget`, `following_widget`, `neighborhoods_widget`, `comp_follow_nearby_widget`) all
go through the `get_followers()` / `get_following()` / `get_followers_nearby()` **SECURITY
DEFINER RPCs** (`0019_follows_functions_reads.sql`), which bypass RLS entirely (they read as the
function owner) and apply the two-way block filter themselves. So RLS on the raw table only needs
to satisfy the direct `querySingleRow` button-state reads, not the list screens.

**Option A — public read (any authenticated user), block-filtered:**
```sql
-- Intent: any authenticated user may see any follow edge, except pairs involving a user who has
-- blocked/is blocked by them (two-way). Matches "follower/following lists are normally public"
-- social-network norms (this is what Nextdoor/Instagram-style apps typically do).
create policy "follows_select_authenticated"
  on public.follows
  for select
  to authenticated
  using ( not (select public.is_blocked_pair((select auth.uid()), follows.follower_id))
      and not (select public.is_blocked_pair((select auth.uid()), follows.following_id)) );
```

**Option B — owner-involved only (RECOMMENDED):**
```sql
-- Intent: a user may see a follow edge only if THEY are one of the two parties (follower or
-- following). This covers every observed direct-client read (all querySingleRow button-state
-- checks always include auth.uid() as one side of the pair) while staying least-privilege —
-- matches the `blocks` table precedent from Batch 2 (owner-only reads, broader access served by
-- SECURITY DEFINER RPCs, not a public table-read policy). No block filter needed: a row where the
-- caller is a party to it is never itself sensitive (it's the caller's own follow action).
create policy "follows_select_involved"
  on public.follows
  for select
  to authenticated
  using (
    follower_id = (select auth.uid())
    or following_id = (select auth.uid())
  );

-- Intent: no INSERT/UPDATE/DELETE policy at all — every write goes through user_follow()
-- (SECURITY DEFINER, forces follower_id=auth.uid(), blocks self-follow, toggles), never direct
-- client DML.
```

**Recommendation: Option B.** It is strictly narrower than Option A, satisfies every direct-client
read path actually exercised by the locked frontend (confirmed by grep — see above), and mirrors
the already-approved `blocks` table pattern (owner-scoped SELECT; broader "who follows this OTHER
user" access is served exclusively by the DEFINER RPCs, which already exist and already
block-filter). Option A (public + block-filtered) is included for completeness in case product
wants follow graphs to be generally browsable later (e.g. a future "mutual friends" UI reading the
table directly) — but nothing in the current frontend needs it, so the least-privilege default
should win per CLAUDE.md §6.2 unless there's a concrete reason to open it up.

---

## Review checklist — Batch 3 (things assumed/confirm before applying)
- [ ] **Pick Option A vs Option B for `follows` SELECT** (see above) — recommendation is Option B
      (owner-involved only); confirm or override.
- [ ] **TODO(confirm): "Nearby" radius for `get_followers_nearby()`** — defaulted to 5km, matching
      `can_view_post()`'s existing Nearby default from Batch 2. Same open item, not newly
      introduced here.
- [ ] **TODO(confirm): `get_followers_nearby`/`get_followers`/`get_following` ignore/override the
      caller-supplied `p_userid`/`p_followerid` where the feature doc says "caller's own location
      only" or "forces follower_id=auth.uid()"** — confirm this is acceptable vs. exposing a
      genuine "view another user's followers/following/nearby" capability (none observed in the
      locked frontend; every call site passes the current user's own id).
- [ ] **TODO(confirm): `get_following_users_not_attending_event` assumed `event_attending` column
      names** (`event_id`, `attending_id`, `is_attending`) — the table doesn't exist yet (Events
      batch); guarded with an `undefined_table` exception handler (returns empty set today, same
      forward-compat pattern as Batch 2's `can_view_post()` friends-check). Re-verify once Events
      lands.
- [ ] **TODO(frontend):** `get_followers`/`get_following`/`get_followers_nearby` all added
      pagination args with DEFAULTs (backward-compatible with the locked frontend's existing
      no-pagination calls) — wire real pagination once the followers/following/nearby screens
      paginate instead of loading full lists into `FFAppState()`.
- [ ] Confirm Supabase project ref before `apply_migration` — must match
      `.claude/viora-project-ref.txt` (`hlmymmlkgirafodcnkgg`).

---

## Batch 4 — Groups (`"group"`, `group_admin`, `group_members`, `group_members_invite`,
`group_user_status`)

> **APPLIED 2026-07-19** as `supabase/migrations/0034_group_rls.sql`. Approved: **private groups
> are discoverable** (browsable/requestable) with member lists gated to members/admins; open groups
> have public member lists; all writes RPC-only. Adds `is_group_admin_self`/`is_group_member_self`
> client wrappers (raw helpers stay internal).
>
> Original draft (for history):
> Tables already exist with `ENABLE ROW LEVEL SECURITY` and **no policies**
> (`supabase/migrations/0025_group_tables.sql`) — currently deny-all. The policy set below lives in
> `supabase/migrations/0034_group_rls.sql`, written but NOT run — apply only after this section is
> reviewed and approved (CLAUDE.md §6.9). Every helper call is wrapped `(select helper())`. **Every
> table's writes are RPC-only** — no INSERT/UPDATE/DELETE policy exists anywhere below; all group
> mutations go through the SECURITY DEFINER RPCs in `0029_group_functions_writes_membership.sql`
> and `0030_group_functions_writes_admin.sql`, which bypass RLS as table owner (matches the
> `post`/`follows` precedent — RLS is the deny-all floor, RPCs are the validated keyed doors, per
> CLAUDE.md's mental model).
>
> Two new self-scoped wrapper predicates are added in `0034` (mirroring `can_view_post_self()`
> from Batch 2): `is_group_admin_self(group_id)` and `is_group_member_self(group_id)`. The
> underlying `is_group_admin()`/`is_group_approved_member()` helpers (`0026_group_helpers.sql`) are
> revoked from `authenticated` — an RLS policy evaluated as the querying role cannot call a
> function it has no EXECUTE grant on, even if that function is `SECURITY DEFINER` — so the
> self-scoped, client-granted wrappers are the only group-membership/admin predicates a policy may
> use.

### `"group"` — GROUP VISIBILITY MODEL (recommendation, see checklist below)

```sql
alter table public."group" enable row level security;

-- Intent: any authenticated user may see any non-deleted, active group's metadata (name,
-- description, e_group_type, e_discoverability, location, total_members, etc.) — INCLUDING
-- private groups. Membership gates the MEMBER LIST and admin roster, not the group's existence;
-- this matches docs/features/05-groups.md's "all_groups"/"nearest_groups" browse screens, which
-- list both open and private groups so a user can see a private group and tap Request to join it.
create policy "group_select_discoverable"
  on public."group"
  for select
  to authenticated
  using ( isdeleted = false and status = 'active' );

-- Intent: no INSERT/UPDATE/DELETE policy at all. Every write goes through create_group() /
-- edit_group() / delete_group() (SECURITY DEFINER, admin-validated, delete_group audited).
```

### `group_admin` — visible to the admin themself, any group admin, any approved member, or
anyone if the group is OPEN (admin badges are part of the public member list for open groups)

```sql
alter table public.group_admin enable row level security;

create policy "group_admin_select_visible"
  on public.group_admin
  for select
  to authenticated
  using (
    group_admin.user_id = (select auth.uid())
    or (select public.is_group_admin_self(group_admin.group_id))
    or (select public.is_group_member_self(group_admin.group_id))
    or exists (
      select 1 from public."group" g
      where g.id = group_admin.group_id and g.e_group_type = 'open' and g.isdeleted = false
    )
  );

-- Intent: no INSERT/UPDATE/DELETE policy — writes only via assign_group_admin() /
-- delete_group_admin() (both admin-validated, block removing the last admin, audited).
```

### `group_members` — MEMBER LIST VISIBILITY MODEL (recommendation, see checklist below):
open groups -> any authenticated user; private groups -> approved members + admins only

```sql
alter table public.group_members enable row level security;

create policy "group_members_select_visible"
  on public.group_members
  for select
  to authenticated
  using (
    group_members.user_id = (select auth.uid())
    or (select public.is_group_admin_self(group_members.group_id))
    or (select public.is_group_member_self(group_members.group_id))
    or exists (
      select 1 from public."group" g
      where g.id = group_members.group_id and g.e_group_type = 'open' and g.isdeleted = false
    )
  );

-- Intent: no INSERT/UPDATE/DELETE policy — writes only via request_or_join_group() /
-- accept_invite() / approve_join_request() / leave_group().
```

### `group_members_invite` — visible to the invitee, the inviter, or any admin of the group

```sql
alter table public.group_members_invite enable row level security;

create policy "group_members_invite_select_visible"
  on public.group_members_invite
  for select
  to authenticated
  using (
    group_members_invite.invited_user = (select auth.uid())
    or group_members_invite.invited_by = (select auth.uid())
    or (select public.is_group_admin_self(group_members_invite.group_id))
  );

-- Intent: no INSERT/UPDATE/DELETE policy — writes only via invite_users_to_group() /
-- accept_invite() / approve_join_request().
```

### `group_user_status` — visible to the row's own user, or any admin of the group

```sql
alter table public.group_user_status enable row level security;

-- Intent: admins need to see pending requests/invites (is_requested/is_invited rows for OTHER
-- users) in order to approve/reject them via the moderation RPCs.
create policy "group_user_status_select_visible"
  on public.group_user_status
  for select
  to authenticated
  using (
    group_user_status.user_id = (select auth.uid())
    or (select public.is_group_admin_self(group_user_status.group_id))
  );

-- Intent: no INSERT/UPDATE/DELETE policy — writes only via the group state-machine RPCs
-- (request_or_join_group / accept_invite / decline_invite / approve_join_request /
-- reject_join_request / invite_users_to_group / leave_group).
```

### `blocks` (shared, already applied in Batch 2 — `0016_post_rls.sql`)
No change needed for Groups. `block_user()`/`unblock_user()` (`0030_group_functions_writes_admin.sql`)
are an ADDITIONAL validated entrypoint layered on top of the already-applied owner-scoped
INSERT/DELETE/SELECT RLS (self-block prevented) — they do not narrow or replace it.

---

## Review checklist — Batch 4 (things assumed/confirm before applying)
- [ ] **GROUP VISIBILITY MODEL (recommendation):** any authenticated user may see a private group's
      metadata (name/description/location/etc.) so they can find and request to join it — only the
      MEMBER LIST (`group_members`/`group_admin`) is gated to members/admins for private groups.
      This matches `docs/features/05-groups.md` §5's own RLS-intent notes ("private groups are
      still listed for discovery; membership gates content, not existence"). Confirm this is the
      intended privacy model (alternative: hide private groups from non-members entirely, which
      would break the "Request to join a private group I discovered" flow shown in the browse
      screens).
- [ ] **MEMBER LIST VISIBILITY for OPEN groups (recommendation):** any authenticated user may see
      the full approved-member list + admin roster of an OPEN group (docs/features/05-groups.md §7's
      "Public/open group members may be visible community-wide — confirm" open question). Confirm
      vs. a narrower "members/admins only, regardless of open/private" model.
- [ ] **`e_discoverability` value set unknown** — kept `text`, not seeded/enumerated anywhere.
      `get_groups_with_user_status()`/`get_specific_group_with_user_status()` return it but do not
      filter/branch on it (no confirmed semantics to enforce). -- TODO(confirm)
- [ ] **`e_group_role` value set:** only `'admin'` observed; `group_admin.e_group_role` is `text` +
      `CHECK (e_group_role = 'admin')` rather than an enum, per decision #9. If a second role value
      (e.g. `'moderator'`) is ever confirmed, this CHECK and every `is_group_admin()` call site
      (which today = "has ANY group_admin row") need revisiting.
- [ ] **`e_group_type` value set:** CONFIRMED `open`/`private` (docs/features/05-groups.md §5) —
      made a real Postgres enum (`public.e_group_type`, `0024_group_enums.sql`), unlike
      `e_discoverability`/`e_group_role` above.
- [ ] **`nearest` field is a hardcoded `false`.** The `"group"` table has NO geography column
      (`location` is a free-text radio value, not lat/lon) — there is no data to compute real
      distance from for `nearest_groups`. -- TODO(confirm): what "nearest" should actually mean,
      and whether `"group"` needs a geography column added later (would require its own migration
      + create_group()/edit_group() changes, out of this batch's scope).
- [ ] **Invite → request conversion for PRIVATE-group invites** (`accept_invite()`): accepting an
      invite to a private group sets `is_requested=true` (still needs admin approval) rather than
      joining immediately, per `docs/features/05-groups.md` §5 and its own §8 open question #7.
      Confirmed as implemented, not re-derived — re-verify this two-step design is intended.
- [ ] **`group_members_invite` UNIQUE(group_id, invited_user)** — NOT explicitly stated in the
      feature doc; assumed as the simplest state-machine-safe model (one live/historical invite row
      per user per group, re-invites upsert it). -- TODO(confirm)
- [ ] **`leave_group()` blocks leaving as the group's only admin** — a safety addition NOT observed
      in the frontend (which unconditionally deletes `group_members`/`group_admin`/
      `group_user_status` on leave, per docs/features/05-groups.md §5's literal DML description).
      Added for consistency with `delete_group_admin()`'s last-admin guard, recorded as a smaller
      implementation decision (CLAUDE.md §7) rather than silently diverging from the documented
      frontend behavior. -- TODO(confirm) whether this stricter behavior is desired, or whether the
      frontend's unconditional-leave should be matched exactly instead.
- [ ] **`block_user()`/`unblock_user()` front-load the Moderation batch's recommended RPC
      signature** (`docs/database/09-rpc-inventory.md` §13) since the Groups screens
      (`comp_report_block`/`comp_unblock_user`) need block/unblock now. They are layered on top of
      the already-applied Batch 2 `blocks` RLS (owner-scoped INSERT/DELETE), not a replacement for
      it. -- TODO(confirm): when the Moderation batch is built, reconcile rather than redefine.
- [ ] **`"group".created_by` FK is `on delete restrict`** (not cascade/set null) — a group cannot
      lose its creator without either transferring ownership or soft-deleting the group first.
      -- TODO(confirm) with product.
- [ ] **`post.group_id` FK is `on delete set null`** (`0025_group_tables.sql`, per this task's
      literal instruction) — a deleted group does NOT cascade-delete its member posts; they survive
      as ungrouped. -- TODO(confirm) set null vs cascade, per `docs/database/02-tables-posts-comments.md`.
- [ ] **Block filter on group list reads is applied against the group's CREATOR** (closest
      analogue to a "people" filter for a group-of-content list, since a group itself isn't a
      user row) — `get_groups_with_user_status()`/`get_specific_group_with_user_status()`. Member/
      admin/invite LIST reads (`get_group_members_with_admin_status`, `get_available_users_to_invite`,
      `get_invited_users_for_group`, `invite_users_to_group`) block-filter each listed/targeted USER
      directly (the more literal two-way-block application). -- TODO(confirm) both are the intended
      interpretation of "two-way block filter on every group people/member/invite list read."
- [ ] Confirm Supabase project ref before `apply_migration` — must match
      `.claude/viora-project-ref.txt` (`hlmymmlkgirafodcnkgg`).

---

## Batch 5 — Events, Marketplace & Storage (APPLIED 2026-07-19)

> **APPLIED** as `0050_event_marketplace_rls.sql` (table RLS) + `0052_storage_rls.sql` (storage
> objects). Two approved choices: (1) `sale_images` allows **owner-scoped direct INSERT/DELETE**
> (added `is_sale_owner_self` wrapper) so the app's direct image-row write works, not RPC-only;
> (2) **strict storage ownership** — uploads to post/sale/event/group folders require owning the
> entity (row must exist first). 8 `public_bucket_allows_listing` advisor WARNs are accepted
> (public image buckets are intentionally world-readable via URL). Original draft below.

Tables: `event_page`, `event_attending`, `sale`, `sale_category`, `sale_images`. Plus
`storage.objects` policies for every bucket created in `0051_storage_buckets.sql`. Migration
files: `supabase/migrations/0035`–`0052`. Nothing in this section has been applied — files only,
per this task's explicit instruction; the main thread reviews and runs them via Supabase MCP.

### `event_page` — visible-only SELECT, RPC-only writes

```sql
create policy "event_page_select_visible" on public.event_page for select to authenticated
  using ( is_deleted = false );
-- Intent: any authenticated user may see any non-deleted event (no community boundary, matches
-- docs/database/04-tables-events-marketplace.md's RLS intent). No INSERT/UPDATE/DELETE policy —
-- writes only via create_event()/edit_event()/delete_event() (0038).
```

### `event_attending` — attendee/inviter/owner-visible SELECT, RPC-only writes

```sql
create policy "event_attending_select_visible" on public.event_attending for select to authenticated
  using (
    event_attending.attending_id = (select auth.uid())
    or event_attending.invited_by = (select auth.uid())
    or (select public.is_event_owner_self(event_attending.event_id))
  );
-- Intent: a row is visible to the attendee themself, the person who invited them, or the event's
-- owner (matches docs/database/04-tables-events-marketplace.md's RLS intent). No INSERT/UPDATE/
-- DELETE policy — writes only via rsvp_event()/invite_user_to_event()/create_event() (auto-attend)
-- /delete_event() (group-delete flag) (0038).
```

### `sale` — visible-only SELECT, RPC-only writes

```sql
create policy "sale_select_visible" on public.sale for select to authenticated
  using ( isdeleted = false );
-- Intent: any authenticated user may see any non-deleted listing (no community boundary). No
-- INSERT/UPDATE/DELETE policy — writes only via insert_sales_details()/update_sale_without_image()
-- /set_sale_deleted()/set_sale_type() (0045).
```

### `sale_category` — lookup table, admin-curated

```sql
create policy "sale_category_select_authenticated" on public.sale_category for select to authenticated
  using ( true );
-- Intent: readable by any authenticated user (dropdown/filter sheet). No client write policy —
-- admin-curated via migration only, matching the see_post_access/comment_post_access precedent
-- (0016_post_rls.sql). No seed rows shipped in this batch — see review checklist.
```

### `sale_images` — visibility follows parent `sale`, RPC-only writes

```sql
create policy "sale_images_select_visible" on public.sale_images for select to authenticated
  using (
    exists (
      select 1 from public.sale s
      where s.id = sale_images.sale_id and s.isdeleted = false
    )
  );
-- Intent: an image is visible whenever its parent sale is visible. No INSERT/UPDATE/DELETE
-- policy — writes only via add_sale_image()/delete_sale_image() (0045, NEW RPCs closing the
-- CLAUDE.md §6 gap where the frontend currently does direct sale_images DML).
```

### `storage.objects` — per-bucket policies (`0052_storage_rls.sql`)

```sql
-- Public image buckets (post-images, sales-images, profile-images, cover-images, event,
-- group-profile-image, business-image, squadd): SELECT open to anon+authenticated (public URLs).
-- INSERT/UPDATE/DELETE scoped to the owner's folder:
--   • profile-images / cover-images — folder = the uploader's OWN user id, direct path check
--     ((storage.foldername(name))[1] = auth.uid()::text). No table join.
--   • post-images — folder = post_id; ownership via EXISTS against public.post (post.user_id).
--   • sales-images — folder = sale_id; ownership via EXISTS against public.sale (sale.created_by).
--   • event — folder = event_id; ownership via is_event_owner_self() (new self-scoped wrapper,
--     0050_event_marketplace_rls.sql).
--   • group-profile-image — folder = group_id; ownership via the EXISTING is_group_admin_self()
--     (0034_group_rls.sql) — any admin of the group may manage its banner.
--   • business-image — folder = business_page_id; ownership via a NEW forward-compat helper
--     is_business_page_owner_self() (business_page doesn't exist yet — Business/Chat batch; the
--     helper returns false / denies writes until that table lands, same pattern as
--     get_following_users_not_attending_event's Batch-3 forward-compat stub).
--   • squadd — admin-only writes (is_admin()); public read (static default assets).
--
-- promote-receipts (PRIVATE — no public/anon SELECT policy at all): SELECT restricted to the
-- business page owner (business_promote.admin_user = auth.uid(), via a NEW forward-compat
-- is_business_promote_owner_self() helper — business_promote doesn't exist yet, same forward-compat
-- treatment as business-image) OR is_admin(). INSERT/UPDATE/DELETE restricted to the owner's own
-- business_page_id folder.
```

### Review checklist — Batch 5 (things assumed/confirm before applying)
- [ ] **Event visibility model:** `event_page`/`event_attending` SELECT is open to ANY
      authenticated user (no community boundary, no "friends only" tier like posts) — matches the
      table doc's RLS intent literally. Confirm this is intended vs. a narrower model (e.g. events
      only visible to followers/nearby, mirroring `can_view_post`'s three-tier model). -- TODO(confirm)
- [ ] **`event_status`/`event_type` kept as REAL enums** (`event_page.event_status` reuses
      `lifecycle_status`; `event_type` is a NEW 2-value enum) — the feature doc itself calls
      `event_type` "not a DB enum in frontend", but the table doc confirms exactly two values
      ('Online'/'Offline'); the table doc (schema source of truth) was followed over the feature
      doc's implementation-detail aside. -- TODO(confirm) if a third event_type value is ever
      needed, this enum needs a migration to add it.
- [ ] **`get_all_events`/`get_latest_events` order `created_at ASCENDING`** (oldest-first) for
      screens literally named "Latest"/"All" — preserved verbatim from
      `docs/features/06-events.md` §5's documented query behavior, even though it reads backwards
      for a "Latest" screen. -- TODO(confirm) with product whether this should be `DESC` instead.
- [ ] **`get_my_created_events` filters `admin_user = caller`**, DEVIATING from the literal
      (unfiltered) frontend query flagged in `docs/features/06-events.md` §8.4 as a possible
      frontend bug. A smaller implementation decision (CLAUDE.md §7) — the alternative (matching
      the frontend's literal unfiltered behavior) would make "My events" show every upcoming
      event, not just the caller's own. -- TODO(confirm) with product.
- [ ] **`public_user_profile.event_count` = events CREATED by the user** (not events attended) —
      chosen as the direct analogue of `post_count`/`group_count` (content the user OWNS).
      -- TODO(confirm): could alternatively mean "events the user is attending".
- [ ] **`sale_category` ships with ZERO seed rows** — no confirmed category name list exists
      anywhere in the reviewed frontend/docs (`docs/features/07-marketplace-sale.md` §3). The
      category dropdown/filter sheet will render EMPTY until rows are seeded.
      -- TODO(confirm): the real category list (e.g. from the live Operture reference app) before
      this table is usable end-to-end.
- [ ] **Marketplace browse feed (`get_sales_home_data`) distance reference point = the CALLER's
      own saved `user_locations` row** (not a community centroid — no such concept exists per
      `docs/decisions.md` "Remove community concept"). Matches `get_followers_nearby`'s existing
      precedent. -- TODO(confirm): `docs/features/07-marketplace-sale.md` §8 leaves the reference
      point explicitly unconfirmed.
- [ ] **`p_distance` sentinel for "any distance"** — treated as `null` OR `<= 0` (no distance
      filter applied). -- TODO(confirm): the feature doc flags the real sentinel value(s) used by
      `comp_kms_filter`'s fixed km list as unconfirmed.
- [ ] **`get_sales_home_data` uses OFFSET pagination (`p_offset`), not keyset** — a deliberate
      deviation from every other list RPC in this schema, because 'Closest' sort orders by
      `distance_km`, which isn't monotonic with `(created_at, id)`. -- TODO(frontend): wire
      `p_offset` once the browse feed needs more than one page.
- [ ] **`insert_sales_details` REQUIRES lat/lon** (raises if either is null), resolving the open
      question in `docs/features/07-marketplace-sale.md` §8 ("latitude/longitude nullable but
      location_point non-null — reconcile") by making location mandatory at the RPC level.
      -- TODO(confirm) with product — the create-listing screens already validate a chosen place
      client-side, so this should never trip in practice, but confirm no listing flow allows
      skipping location entirely.
- [ ] **`sale.sale_category` stays NAME-based (no FK)** — matches the locked frontend contract
      verbatim (`docs/features/07-marketplace-sale.md` §8: "frontend contract is name-based,
      changing it breaks the app"). Renaming/deleting a `sale_category` row silently orphans any
      `sale` rows that reference the old name string. -- TODO(confirm) accepted risk.
- [ ] **`add_sale_image`/`delete_sale_image`/`set_sale_deleted`/`set_sale_type` are NEW RPCs**, not
      part of the locked frontend's observed call list — they replace the frontend's direct
      `SaleImagesTable()`/`SaleTable().update` DML per CLAUDE.md §6. -- TODO(frontend): wire
      `comp_sold_delete`/`comp_sale_delete`/the image-edit flow to call these instead of direct DML.
- [ ] **STORAGE PATH SCHEMES ASSUMED** (per `docs/database/07-storage-buckets.md`'s own
      convention, cross-checked against each upload call site's literal folder argument):
      - `post-images`, `sales-images`, `event`, `group-profile-image`, `business-image`,
        `promote-receipts` — folder = the ENTITY id (post/sale/event/group/business_page),
        ownership checked by joining back to that entity's owner column. **Confirmed** for
        post-images/sales-images/event/group-profile-image (entity tables exist and their owner
        columns are directly queryable/RLS-visible-to-owner).
      - `business-image`/`promote-receipts` — **NOT YET VERIFIABLE**: `business_page`/
        `business_promote` don't exist yet (Business/Chat batch). Forward-compat helpers deny all
        writes until that batch lands; re-verify the folder-name assumption (`business_page_id` as
        first path segment, `{profile|cover}_<file>`/`<file>` as the filename) once that batch's
        actual upload call sites are read.
      - `profile-images`/`cover-images` — folder = the UPLOADER's own `user_id`. **Confirmed**
        directly from `docs/database/07-storage-buckets.md`'s table.
      - `squadd` — fixed known admin-managed paths (`default_group_image/`, `default_profile/`,
        `default_cover_image/`), no per-user folder; admin-only writes. **Confirmed**.
- [ ] **`squadd` bucket size/mime limits are NOT specified in the doc** ("n/a (admin-curated)") —
      a defensive `5MB` + image-only limit was applied here rather than leaving it unlimited.
      -- TODO(confirm) with whoever manages the default asset uploads.
- [ ] Confirm Supabase project ref before `apply_migration` — must match
      `.claude/viora-project-ref.txt` (`hlmymmlkgirafodcnkgg`).

---

## Batch 6 — Business & Chat

> **APPLIED 2026-07-19** (`0053`–`0067`). Table RLS = `0065`; realtime auth = `0064`. Approved:
> business_page public-read (active), business_promote/business_contacted owner+admin only, chat/
> chat_users/messages members-only. **`get_contact_count` opened to PUBLIC** (`0067`) per
> stakeholder — aggregate count public, individual contact rows stay owner/admin. **⚠️ MANUAL STEP:**
> the `realtime.messages` receive policy (`0064`) could NOT be applied via MCP (postgres isn't owner
> of `realtime.messages`); apply via `supabase db push` (CLI) or the Dashboard with an elevated role.
> Chat works fully via RPCs meanwhile; only live push waits on that policy + the frontend repoint.
> Original draft below.

> **[superseded]** NOT YET APPLIED — files only, per this task's explicit instruction. Migration files:
> `supabase/migrations/0053`–`0066`. The main thread reviews this section and runs the migrations
> via Supabase MCP against Viora's own project only (`hlmymmlkgirafodcnkgg`, confirm ref first).

Tables: `business_promote_plans`, `business_page`, `business_promote`, `business_contacted`,
`chat`, `chat_users`, `messages`. Plus `realtime.messages` authorization policies for private
Broadcast (chat/messaging realtime).

### `business_promote_plans` — lookup table, admin-curated

```sql
create policy "business_promote_plans_select_authenticated" on public.business_promote_plans for select to authenticated
  using ( true );
-- Intent: any authenticated user can see the pricing catalog (dropdown). No client write policy —
-- admin-curated (no seed rows shipped in this batch, no admin-write RPC built yet either —
-- TODO(confirm) whether an admin RPC or a future admin console manages this table).
```

### `business_page` — active/non-deleted visible app-wide, owner sees own regardless of state

```sql
create policy "business_page_select_visible" on public.business_page for select to authenticated
  using (
    (is_deleted = false and business_status = 'active')
    or admin_user = (select auth.uid())
  );
-- Intent: matches docs/database/05-tables-business-chat.md's RLS intent — no community boundary,
-- no two-way BLOCK filter at the RLS layer (block filtering happens in get_all_business/
-- get_business_details/get_specific_business, 0056, since RLS cannot cheaply evaluate "is the
-- CALLER blocked by THIS row's owner" without a per-row helper call — recommend keeping it in the
-- RPCs, matching the sale/event precedent of "no community boundary" RLS + RPC-side filtering).
-- No INSERT/UPDATE/DELETE policy — writes only via create_business_page()/edit_business_page()/
-- delete_business_page()/restore_business_page() (0057).
```

### `business_promote` — owner (submitter) or platform admin only

```sql
create policy "business_promote_select_owner_admin" on public.business_promote for select to authenticated
  using (
    admin_user = (select auth.uid())
    or (select public.is_admin())
  );
-- Intent: payments + moderation-adjacent data — strict. admin_user here is the SUBMITTER (page
-- owner), NOT a platform admin; is_admin() is the separate platform-admin JWT-claim check. No
-- INSERT/UPDATE policy — writes only via create_or_update_promotion() (owner) /
-- admin_set_promotion_status() (platform admin, audited) (0057/0058).
```

### `business_contacted` — business owner or platform admin only

```sql
create policy "business_contacted_select_owner_admin" on public.business_contacted for select to authenticated
  using (
    (select public.is_business_page_owner_self(business_contacted.business_page_id))
    or (select public.is_admin())
  );
-- Intent: matches the table-doc RLS intent ("owner (for counts) / admin"). No INSERT/UPDATE
-- policy — writes only via update_contacted() (0057). -- TODO(confirm): the feature doc's
-- business_home_page screen implies visitors also see a "N people contacted" count, which would
-- need a broader SELECT (or a dedicated public count RPC bypassing this policy, which
-- get_contact_count() already does via SECURITY DEFINER — see review checklist below).
```

### `chat` — non-soft-deleted members only

```sql
create policy "chat_select_member" on public.chat for select to authenticated
  using ( (select public.is_chat_member_self(chat.id)) );
-- Intent: matches docs/database/05-tables-business-chat.md's RLS intent. No INSERT/UPDATE/DELETE
-- policy — writes only via find_common_chat()/add_chat_users() (0062); last_message* preview and
-- realtime broadcast are trigger-driven (0063/0064), both SECURITY DEFINER (bypass RLS as owner).
```

### `chat_users` — own row or fellow member

```sql
create policy "chat_users_select_member" on public.chat_users for select to authenticated
  using (
    chat_users.user_id = (select auth.uid())
    or (select public.is_chat_member_self(chat_users.chat_id))
  );
-- Intent: a user sees their own membership row, or any row for a chat they belong to (participant
-- lookups). No INSERT/UPDATE/DELETE policy — writes only via add_chat_users()/
-- soft_delete_chat_users()/restore_chat_user() (0062).
```

### `messages` — non-soft-deleted members of the parent chat only

```sql
create policy "messages_select_member" on public.messages for select to authenticated
  using ( (select public.is_chat_member_self(messages.chat_id)) );
-- Intent: RPC-ONLY writes chosen over a scoped client INSERT/UPDATE policy (both were viable per
-- docs/features/10-chat-messaging.md §7) — send_message()/mark_messages_read() (0062) so the
-- last_message preview trigger and the realtime broadcast trigger fire atomically with every
-- insert, regardless of caller. No INSERT/UPDATE/DELETE policy on this table.
```

### `realtime.messages` — private, authorized Broadcast (chat realtime)

```sql
create policy "chat_broadcast_receive_authorized"
on "realtime"."messages"
for select
to authenticated
using (
  realtime.messages.extension = 'broadcast'
  and (
    (
      (select realtime.topic()) like 'chat:%'
      and (select public.is_chat_member_self(split_part((select realtime.topic()), ':', 2)::uuid))
    )
    or (select realtime.topic()) = ('user:' || (select auth.uid())::text || ':chats')
  )
);
-- Intent: replaces the frontend's current PUBLIC, UNAUTHORIZED Postgres Changes channels
-- (`public:messages`, `chat_table_realtime`, `chat_users_table_realtime`, `messages_table_realtime`,
-- and a debug `test_messages_channel` — docs/features/10-chat-messaging.md §6) with PRIVATE,
-- RLS-authorized Broadcast per CLAUDE.md §6 and docs/decisions.md (2026-07-19, "Realtime").
--
-- TOPIC NAMING (frontend MUST subscribe to these exact topics going forward):
--   - `chat:{chat_id}` — per-conversation topic; receivable only by non-soft-deleted chat_users
--     members of that chat.
--   - `user:{auth.uid()}:chats` — per-user topic; receivable only by that user; carries a
--     lightweight "a chat you're in changed" signal (chat_id/last_message/last_message_date) to
--     drive the chat-list screen instead of a public chat/chat_users subscription.
--
-- Only a SELECT (receive) policy exists — NO INSERT (client-side broadcast send) policy. Every
-- broadcast event is emitted SERVER-SIDE by the trg_broadcast_new_message trigger (0064), which
-- calls realtime.broadcast_changes() (full message payload -> chat:{chat_id}) and realtime.send()
-- (lightweight refresh ping -> each member's user:{uid}:chats), both as the trigger owner
-- (SECURITY DEFINER), so clients can never spoof a broadcast onto another user's/chat's topic.
```

### Review checklist — Batch 6 (things assumed/confirm before applying)
- [ ] **`business_page`/`business_promote`/`business_contacted` block filtering lives in the RPCs,
      NOT in RLS** — the SELECT policies above are intentionally "no community boundary, no block
      predicate" (block-filtering a second user's row from RLS would need a per-row helper call
      keyed off the CALLER, which is exactly what `is_blocked_pair()` already does inside
      `get_all_business`/`get_business_details`/`get_specific_business`, 0056). Confirm this split
      (RLS = visibility state, RPC = block filter) is the intended model, consistent with the
      post/sale/event precedent. -- TODO(confirm)
- [ ] **`get_contact_count()` is owner/admin-gated (fails closed, returns 0 for anyone else)** —
      chosen as the SAFE DEFAULT per CLAUDE.md §6 ("deny by default"), but the feature doc's
      `business_home_page` screen implies a PUBLIC "N people contacted" count shown to any visitor.
      -- TODO(confirm) with product: if the count must be public, relax `get_contact_count()` to
      skip the owner/admin check (the underlying `business_contacted` table RLS would stay
      owner/admin-only either way, since the count RPC is SECURITY DEFINER and bypasses it).
- [ ] **`business_promote_plans` has NO admin-write RPC in this batch** — INSERT/UPDATE/DELETE are
      admin-only per the table-doc RLS intent, but no `create_promotion_plan`/`edit_promotion_plan`
      RPC was built (out of this batch's explicit RPC list). Plans must be seeded/managed via direct
      migration or a future admin-console batch. -- TODO(confirm) whether an admin RPC is needed now
      or can wait.
- [ ] **`business_promote` UNIQUE (business_page_id, admin_user) is a NEW constraint**, beyond the
      table doc's plain composite INDEX — added so `create_or_update_promotion()` can use a single
      idempotent UPSERT. This means at most ONE promotion row (current or historical) exists per
      (page, submitter) at a time; resubmitting always overwrites the same row (plan/reference/
      receipt/status/dates), there is no history of past promotion cycles. -- TODO(confirm): if
      historical promotion records must be kept (e.g. for a "renew" flow that shows past promos),
      this constraint needs to be relaxed and the RPC logic revisited.
- [ ] **`reports` table does NOT exist yet** (Moderation is a later, not-yet-built batch —
      confirmed via `grep -rn "create table.*reports" supabase/migrations/`, contrary to this
      task's own prose which assumed it exists). `report_business()`/`unreport_business()` (0057)
      use the SAME forward-compat dynamic-SQL + `undefined_table`-exception-guard pattern as
      `is_business_page_owner`'s Batch-5 stub — they currently no-op (return null) and will
      self-activate once `reports` lands. The assumed column shape
      (`community_id, reported_by_user, report_type, business_page_id, reason`) is a GUESS based on
      `docs/database/09-rpc-inventory.md` §13's `report_content()` signature and may not match the
      real `reports` table once the Moderation batch defines it. -- TODO(confirm): reconcile column
      names with the Moderation batch rather than assume this guess is correct.
- [ ] **`find_common_chat()` now FIND-OR-CREATES the chat** (a deliberate behavior change from the
      frontend's literal "search-only, client inserts if not found" flow), per this task's explicit
      instruction — closes the CLAUDE.md §6 direct-DML gap on `chat`/`chat_users` insert. The
      frontend's existing "if !chat_found, call add_chat_users" branch remains a harmless no-op
      against the row this RPC already created (add_chat_users is idempotent). -- TODO(frontend):
      confirm no frontend logic depends on `chat_found=false` meaning "chat row does not yet exist"
      (e.g. skipping some UI step) — it now only means "was newly created by this call."
- [ ] **`chat_type` stays `text`, NOT an enum** — `'dm'` confirmed; `'sale'`/`'forsale'` value and
      who creates those chats (marketplace feature, not `comp_new_message`) remain unconfirmed, per
      docs/decisions.md's "Unknown dropdown value sets" decision. -- TODO(confirm)
- [ ] **`messages`/`chat` writes are STRICT RPC-only** (no scoped client INSERT policy chosen for
      `messages`, unlike `sale_images`' owner-scoped direct-insert precedent from Batch 5) — chosen
      so the last-message-preview trigger and the realtime broadcast trigger always fire atomically
      with every insert. -- TODO(frontend): repoint `message_page`'s direct `MessagesTable.insert`/
      `ChatTable.update` calls to `send_message()`, and the mark-as-read `.update` call to
      `mark_messages_read()`.
- [ ] **Realtime topic naming is a NEW design** (not observed anywhere in the current frontend,
      which uses public unauthorized channels) — `chat:{chat_id}` and `user:{uid}:chats`.
      -- TODO(frontend): THIS IS THE FLAGGED §6 MIGRATION — repoint every chat realtime subscription
      to these private topics using `{config: {private: true}}` Broadcast channels; remove
      `test_messages_channel` and the three Postgres-Changes channels in
      `init_realtime_chat_updates.dart` entirely.
- [ ] **`business_promote_plans.id` is `int8` (not `uuid`)** — the only int8-PK table built so far
      in this batch/schema, preserved verbatim per the frontend Row class
      (`business_promote_plans.dart`). -- TODO(confirm) accepted, matches the "reference_number
      int8" and "last_contact_link array" quirks this task explicitly asked to preserve.
- [ ] **`business_promote.reference_number` stays `int8`** (payment reference) — feature doc §8.5's
      open question (overflow/leading-zero risk for real payment references) is NOT resolved here,
      kept as-is pending product confirmation.
- [ ] **`_business_promotion_status()` derives `'ended'` at READ TIME** for a `'live'` promotion
      whose `plan_end_date` has passed, even before any admin/cron flips the stored `status` column
      — closes part of the feature doc §7 "auto-ended" gap without a scheduled job in this batch.
      -- TODO(confirm): whether a `pg_cron` job should ALSO write `status='ended'` back to the row
      (recommended for consistency with anything that queries `business_promote.status` directly,
      e.g. a future admin console) — no cron job was requested or built in this batch.
- [ ] Confirm Supabase project ref before `apply_migration` — must match
      `.claude/viora-project-ref.txt` (`hlmymmlkgirafodcnkgg`).

---

## Batch 7 — Notifications, Search & Moderation (FINAL backend batch)

> **APPLIED 2026-07-19** (`0068`–`0084`; table RLS = `0083`). Standard RLS (no new product
> decisions): notifications receiver-only; admin_notification admin-only; search_history owner-only
> (SELECT/DELETE); reports admin-only (SELECT/UPDATE), INSERT via RPC. Edge function
> `send-notification` deployed (verify_jwt off; service-role-bearer gated internally). **⚠️ MANUAL:**
> the `realtime.messages` notification policy (`0082`) needs a CLI/Dashboard apply; and FCM push
> needs `pg_net` enabled + `FCM_SERVICE_ACCOUNT_JSON` secret + the two `app.settings.*` GUCs.
> Original notes below.

Migrations `0068`–`0084`. Tables: `search_history`, `reports`, `notifications`,
`admin_notification`. `tag`/`insert_tags` (Batch 2), `blocks`/`block_user`/`unblock_user`
(Batch 2/4), and `user_devices` (Batch 1) already exist — NOT recreated. pg_trgm + pg_net
extensions enabled. New Edge Function: `supabase/functions/send-notification/index.ts`.

### `notifications` — receiver-only, RPC-only writes

```sql
create policy "notifications_select_own"
  on public.notifications for select to authenticated
  using ( receiver_id = (select auth.uid()) and is_deleted = false );
-- Intent: matches docs/database/06-tables-notifications-search-moderation.md's RLS intent
-- exactly. No INSERT/UPDATE/DELETE policy — INSERT only via notify() (0077, called from every
-- producer trigger, 0078/0079/0080); UPDATE (is_read/is_deleted) only via
-- mark_notification_read()/mark_notification_deleted() (0081), both SECURITY DEFINER and
-- receiver_id=auth.uid()-scoped. RPC-only chosen over a scoped client UPDATE policy so the
-- column-level restriction (is_read/is_deleted only, never sender_id/content/etc.) is enforced in
-- one place, matching the messages precedent (Batch 6) over the public_user_profile counter-
-- column-REVOKE precedent (Batch 1).
```

### `admin_notification` — admin-only

```sql
create policy "admin_notification_select_admin" on public.admin_notification for select to authenticated
  using ( (select public.is_admin()) );
create policy "admin_notification_insert_admin" on public.admin_notification for insert to authenticated
  with check ( (select public.is_admin()) );
create policy "admin_notification_update_admin" on public.admin_notification for update to authenticated
  using ( (select public.is_admin()) ) with check ( (select public.is_admin()) );
-- Intent: no Flutter compose/send screen exists (feature doc §2 — admin UI is the separate
-- Operture app); table + RLS exist so that app has somewhere to write. No DELETE policy (no
-- documented delete flow). No fan-out-to-notifications/push RPC built in this batch (out of
-- scope — no admin compose screen to reverse-engineer a signature from).
```

### `search_history` — owner-only (direct client SELECT/DELETE, RPC-only INSERT/UPDATE)

```sql
create policy "search_history_select_own" on public.search_history for select to authenticated
  using ( searched_by = (select auth.uid()) );
create policy "search_history_delete_own" on public.search_history for delete to authenticated
  using ( searched_by = (select auth.uid()) );
-- Intent: matches the sale_images precedent (decision #4, "tightly-scoped RLS only for trivial
-- owner rows") — the frontend does direct queryRows/delete against this table, not RPC calls, for
-- reads and the "Clear" action. INSERT/UPDATE stay RPC-only (update_search_data, 0070) since the
-- frontend never inserts/updates this table directly (only on submit, via the RPC).
```

### `reports` — reporter INSERT via RPC only; admin SELECT/UPDATE only

```sql
create policy "reports_select_admin" on public.reports for select to authenticated
  using ( (select public.is_admin()) );
create policy "reports_update_admin" on public.reports for update to authenticated
  using ( (select public.is_admin()) ) with check ( (select public.is_admin()) );
-- Intent: matches docs/database/06-tables-notifications-search-moderation.md's RLS intent. No
-- INSERT policy at all — report_content()/report_business()/unreport_business() (0074/0075) are
-- SECURITY DEFINER and bypass RLS as owner, so a direct client INSERT is impossible regardless of
-- policy. No DELETE policy — reports are never deleted, only status-transitioned
-- (set_report_status, 0074).
```

### `realtime.messages` — private, authorized Broadcast (notification badge, OPTIONAL)

```sql
create policy "notifications_broadcast_receive_own"
on "realtime"."messages"
for select
to authenticated
using (
  realtime.messages.extension = 'broadcast'
  and (select realtime.topic()) = ('user:' || (select auth.uid())::text || ':notifications')
);
-- Intent: OPTIONAL live-refresh signal per docs/features/11-notifications.md §6's recommendation
-- (the frontend currently has NO realtime subscription for notifications at all — pure
-- polling-by-refetch after every state change). Simpler than the chat precedent (0064): only ONE
-- topic shape (`user:{uid}:notifications`, no shared per-entity topic), so no `is_..._self()`
-- helper wrapper was needed — a bare `auth.uid()` comparison suffices. Same
-- "SELECT-only, no INSERT" authorization model: every broadcast is server-triggered
-- (trg_broadcast_new_notification, 0082), never client-sent.
```

### Review checklist — Batch 7 (things assumed/confirm before applying)
- [ ] **`realtime.messages` policy above CANNOT be applied via MCP** (same `postgres` ≠ owner of
      `realtime.messages` limitation as Batch 6, 0064) — apply via `supabase db push` (CLI) or the
      Dashboard. Notifications work fully via RPC meanwhile (get_notifications polling).
- [ ] **`notify()` type strings are NOT fully within the confirmed observed set** — `'follow'`
      (0078, follows trigger) and `'report'` (0080, admin report alert) are NEW type strings not
      listed in docs/features/11-notifications.md §3's confirmed set (post/comment/event/
      business/sale/group/invite/group_invite). `'follow'` has no dedicated tab in
      `get_notifications()` (folds into `all` only); `'report'` is intentionally admin-only
      (never shown to a normal user's `get_notifications()` result since admins are the only
      receivers). -- TODO(confirm) with product whether these are the right strings, or whether
      follow/report notifications are out of scope entirely.
- [ ] **`get_notifications()` tab-bucketing is a NEW mapping**, not verifiable against a live RPC
      (feature doc §8.6: the exact field list/join logic was reverse-engineered from
      `getJsonField` paths, not a real backend). Chosen mapping: `post` bucket = types
      `post`+`comment`; `group` = `group`+`group_invite`; `event` = `event`+`invite`; `business` =
      `business`; `sale` = `sale`; `all` = everything. -- TODO(confirm) this mapping matches the
      real intended tab semantics (especially whether `invite`, used by BOTH event-invites and the
      routing table's generic "invite" case, should also appear under a different tab).
- [ ] **`notification_type` column is carried but UNUSED** by every trigger/RPC in this batch
      (always NULL on insert) — feature doc §8.1 leaves its purpose unconfirmed; kept as a column
      only, per the design doc's "kept as-is (Open Decisions)" note.
- [ ] **`reports.mail_sent` trigger does NOT send a real email** — it creates in-app admin
      notifications via `notify()` and sets `mail_sent=true` once those succeed (0080's header
      comment explains the gap in detail). If a real email alert is required, a dedicated Edge
      Function + email-provider secret (not currently in scope) is the recommended follow-up.
      -- TODO(confirm) with product whether the in-app admin notification satisfies the "email the
      moderation/admin address" requirement, or whether real email delivery must be added.
- [ ] **FCM push requires MANUAL secret/setting setup before it works** (0082's header comment +
      `send-notification/index.ts`'s header comment list every step): the `FCM_SERVICE_ACCOUNT_JSON`
      Edge Function secret, and the two Postgres GUCs (`app.settings.edge_function_url`,
      `app.settings.service_role_key`) the `trg_push_new_notification` trigger reads. Until those
      are set, the trigger's pg_net call is a guarded no-op (never fails the notification write
      itself) and no push is sent — in-app notifications + get_notifications() still work fully.
- [ ] **`search_history` has NO unique/dedupe constraint** — `update_search_data()` (0070) does a
      manual find-then-update-or-insert (case-insensitive on `search`) instead of a real `ON
      CONFLICT` upsert, per docs/database/06-tables-notifications-search-moderation.md's
      "candidate UNIQUE, not applied until confirmed" note. -- TODO(confirm) whether the UNIQUE
      constraint should be added (would let a true upsert replace the manual find-then-branch).
- [ ] **`get_search_all_data()`/`get_search_data()` matching is plain trigram-backed `ILIKE
      '%term%'`**, NOT ranked/full-text — docs/features/12-search-tags.md §8.1 leaves this open;
      substring ILIKE was chosen to match the frontend's own live-typing/debounce UX (no ranking
      UI exists). -- TODO(confirm) with product if ranked/full-text matching is actually wanted.
- [ ] **`tag_search()` scope is APP-WIDE** (any user, not same-network/followers-only) —
      feature doc §8.6 leaves this open; app-wide chosen as the least-restrictive default,
      consistent with every other discovery RPC in this schema (get_all_business/
      get_groups_with_user_status/etc., all app-wide/no-community per docs/decisions.md).
      -- TODO(confirm) with product if @mention autocomplete should be scoped narrower (e.g.
      followers/mutual-follows only).
- [ ] **`get_search_data()`'s duplicate top-level `eventData` array** (alongside the normal
      `events` array, both populated identically when `p_type='event'`) is preserved verbatim per
      the documented return shape (feature doc §4's literal citation) — the frontend's own reason
      for the duplication is unconfirmed. -- TODO(confirm) whether `eventData` can be dropped once
      the real frontend call site is inspected.
- [ ] **`report_content()`'s target-FK validation is per-`report_type`, not generic** — 'account'/
      'message'/`''` report_types carry no entity FK (only `reported_user`, coerced from `''` to
      NULL) per the feature doc's own dialog-by-dialog description; any OTHER unrecognized
      `report_type` string raises an exception rather than silently inserting an all-NULL-FK row.
      -- TODO(confirm): whether new report_type strings should be added to this whitelist as new
      report dialogs are built, or whether the whitelist should be relaxed.
- [ ] **`report_business()`/`unreport_business()` backfill (0075) assumed the Batch-6 stub's
      column guess was correct** — verified `community_id, reported_by_user, report_type,
      business_page_id, reason` all exist on the real `reports` table (0073) with matching types,
      so this is a pure dynamic-SQL-removal backfill, not a column-name fix (0075's header comment
      states this explicitly).
- [ ] **Reporter visibility into their own filed reports is STILL not exposed** (feature doc
      §8.10, carried over unresolved from Batch 6/the original moderation doc) — `reports_select_
      admin` is the ONLY SELECT policy; a reporter cannot see the status of a report they filed
      (matches the frontend's thank-you-sheet-only behavior). -- TODO(confirm) with product whether
      a reporter-can-see-own-reports SELECT policy should be added.
- [ ] **`get_reports()`/`set_report_status()` have NO reverse-engineerable shape to verify against**
      (feature doc §1 — no Flutter admin screen exists; the Operture admin app is a separate
      codebase not read as part of this batch). The signatures/shapes here are the simplest
      defensible contract (raw `setof public.reports` / updated row), NOT verified against
      Operture's actual admin UI. -- TODO(confirm) with the Operture app's owner before the admin
      app is wired to these RPCs.
- [ ] Confirm Supabase project ref before `apply_migration` — must match
      `.claude/viora-project-ref.txt` (`hlmymmlkgirafodcnkgg`).

---

## Batch 8 — Signup row creation (APPLIED 2026-07-21)

> **APPLIED** as migrations `signup_insert_policies_location_rpc_and_defaults`,
> `grant_user_roles_privileges_to_authenticated`, `revoke_update_user_location_from_anon`
> against `hlmymmlkgirafodcnkgg`. Approved by the user after review of both options.

### Symptom

A Google sign-in authenticated successfully, then the app hung on the loading spinner forever.
`lib/pages/loading_page/loading_page_widget.dart:69` threw
`Null check operator used on a null value`, killing the `initState` callback before its
`context.goNamed(HomePageWidget.routeName)` on line 267 could run.

State at the time: `auth.users` = 1 row; `user`, `public_user_profile`, `user_locations` = 0 rows.

### Root causes (three, all in the DB)

1. **No INSERT policy on `"user"`.** Batches 1's design assumed rows would be created by the
   `signup_finalize()` RPC. That RPC exists and is granted to `authenticated`, but **`lib/` never
   calls it** (`grep -rn signup_finalize lib/` → no hits; it appears only in `docs/`). The locked
   frontend instead does direct DML at `login_page_widget.dart:1115`,
   `create_account_page_widget.dart:949`, and `verify_page_widget.dart:537/658`. RLS denied the
   first insert and the whole signup chain died.
2. **`user_roles` had RLS + policies but ZERO table grants.** Policies only filter rows a role is
   already privileged to touch, so `user_roles_select_own` could never fire and
   `UserRolesTable().insert()` failed with `permission denied for table user_roles`.
3. **`update_user_location()` did not exist.** `InsertUserLocationCall`
   (`api_calls.dart:1503`) POSTs to `/rest/v1/rpc/update_user_location` from the Location page,
   `comp_neighbour_location`, `comp_location_permission`, and `verify_page`. The function was
   documented but never created, so `user_locations` could never be populated — which would have
   crashed line 77 (`location!.firstOrNull!.latitude!`) even after signup was fixed.

### Resolution — frontend contract wins

CLAUDE.md §1: "the backend must be built to match what the frontend expects." The frontend is
locked, so the DB was adjusted to the DML it actually performs rather than the RPC-first design
recorded in Batch 1. `signup_finalize()` is now dead code — see the follow-up below.

**A trigger on `auth.users` was explicitly rejected.** The app detects a new user by checking
whether a `public.user` row exists. A trigger that pre-creates that row makes every new Google
user look like a returning user, so the app skips `LocationPageWidget` and never collects their
location — silently breaking the location-based feed instead of loudly breaking signup.

### Policies added

| Table | Policy | WITH CHECK |
|---|---|---|
| `"user"` | `user_insert_own` | `id = (select auth.uid())` |
| `user_roles` | `user_roles_insert_own_customer` | `id = (select auth.uid()) and role = 'customer'::app_role` |

`user_locations` deliberately got **no** INSERT/UPDATE policy — every write goes through the
SECURITY DEFINER `update_user_location()` RPC, which bypasses RLS. (`AddUserLocationCall`,
`api_calls.dart:1322`, does a direct REST insert but is dead code — no call site in `lib/`.)

#### Privilege-escalation guard

`user_roles.role` is the `app_role` enum. A bare `id = auth.uid()` INSERT policy would let any
user insert `role = 'admin'` for themselves, and the `custom_access_token_hook` would then mint
them an admin JWT. The policy pins `role = 'customer'`, and only `select, insert` were granted —
**no UPDATE/DELETE**, so a client cannot elevate itself after the fact either.

### `update_user_location(lat, lon, place_name, p_type)`

`SECURITY DEFINER`, `SET search_path = public, extensions, pg_temp` (PostGIS lives in
`extensions`, so `ST_MakePoint` will not resolve on a bare `public, pg_temp` path). Validates
`auth.uid()` is non-null and always keys the row to the JWT subject — the caller cannot write
another user's location. Range-checks lat/lon. Upserts, which satisfies both `p_type='create'`
(signup) and `p_type='update'` (later edits); `p_type` itself is accepted for signature
compatibility and is otherwise advisory.

Parameter names are load-bearing: PostgREST maps JSON body keys to parameter names, so
`lat`/`lon`/`place_name`/`p_type` must not be renamed or the app gets a 404.

Granted to `authenticated` only. `anon` was revoked explicitly — Supabase's default privileges
issue a *direct* EXECUTE grant to `anon` on new public functions, which `revoke ... from public`
does not remove (caught by the `anon_security_definer_function_executable` advisor).

### Column defaults (crash-proofing)

The loading page force-unwraps nine nullable columns. Defaults make NULL impossible even if a
signup path omits the field, with no frontend logic change:

`user.first_name/last_name/address/flat` → `''`;
`public_user_profile.name/profile_picture/city` → `''`;
`user_locations.latitude/longitude` → `0`.

Columns were left nullable (not `NOT NULL`) so no existing insert path starts failing a
constraint. Existing NULLs were backfilled in the same migration.

### Verified (simulated as a real `authenticated` client via `request.jwt.claims`)

| Test | Result |
|---|---|
| Insert own `user` row | PASS |
| Insert own `user_roles` as `customer` | PASS |
| Insert own `public_user_profile` | PASS |
| Insert `user_roles` as `admin` (escalation) | **blocked** |
| `UPDATE user_roles SET role='admin'` (escalation) | **blocked** |
| Insert a `user` row for someone else's id | **blocked** |
| `update_user_location()` RPC | PASS (13.0827, 80.2707 / Chennai) |

Test rows were deleted afterwards so the real signup starts from a clean slate.

### Follow-ups (open)

- [ ] **`signup_finalize()` is now dead code** — it is `SECURITY DEFINER`, granted to
      `authenticated`, and reachable at `/rest/v1/rpc/signup_finalize`, but nothing calls it. It
      should be revoked/dropped, or the frontend repointed to it, so there aren't two divergent
      signup paths. Decide before launch.
- [ ] **Batch 1's "no client INSERT policy" intent is now superseded** for `"user"`/`user_roles`.
      The §6.6 "no direct client DML" rule and the locked frontend genuinely conflict here; this
      batch resolved it in favour of the frontend. Revisit if the frontend is ever unlocked.
- [ ] **Audit other tables for the same grant gap** — `user_roles` had RLS + policies but no
      grants, so its policies were dead. Other tables may share the defect; policies alone are not
      evidence that a path works.

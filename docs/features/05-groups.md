# Feature: Groups

> Source of truth = the Flutter frontend. This doc records what the backend MUST provide
> for this feature to work. Derived from `lib/` — do not invent behavior the code doesn't show.

## 1. Overview
- **What it is:** Neighborhood interest groups inside a community. Users create/edit/delete
  groups, browse nearby/all groups, join open groups or request to join private ones, invite
  friends, accept/decline invites, manage members and admins (assign / resign / revoke), block
  and unblock users, and leave groups. Groups have a running member count.
- **Why it exists / user value:** Lets neighbors organize around shared interests within their
  local community, with public (open) and private (invite/request) access controls.
- **Related features:** community (`community_id` scopes every group), user profile (member-count
  rollups via `UpdateUserProfileCounts` / `update_user_group_count`), chat (group posts/chat use
  `ChatTable` — separate feature), reports/blocks (shared `blocks` + `reports` tables).

## 2. Screens & widgets
All paths under `lib/pages/`.

| Screen / widget | Purpose | Key actions |
|---|---|---|
| `group/create_group/` | Create a new group (name, description, type, discoverability, location, banner image) | Insert `group` + `group_admin`(admin) + `group_members` + `group_user_status`; upload banner; `update_user_group_count` |
| `group/edit_group/` | Edit group name/description/location/banner | `GroupTable.update` (by `id`); re-upload banner |
| `group/comp_delete_group/` | Soft-delete a group | `GroupTable.update` → `isdeleted=true`, `status='removed'`; `UpdateUserProfileCounts(option:'group')` |
| `group/all_groups/` | Browse all groups in community with per-user status | Join open / request private / accept invite (see §5) |
| `group/nearest_groups/` | Browse nearest groups (same join/request/invite actions as all_groups) | Same as all_groups |
| `group/my_group/` | The current user's groups + management surface (largest widget; repeats join/request/invite/approve blocks) | Join/request/invite/approve/admin actions |
| `group/group_details/` | Single group detail (posts, members, actions) | Join/request/invite; group chat/posts |
| `group/about_group/` | Group "about" panel | Insert chat/report rows; join actions |
| `group/comp_group_members/`, `comp_private_group_members/` | Member lists (public vs private group) | View members / open admin & block actions |
| `group/comp_joining_request/` | Admin approves pending join requests | Approve: update `group_user_status` + `group_members_invite`, insert `group_members`, recount |
| `group/comp_invite_friends/` | Invite friends / users to the group | Insert `group_members_invite` (+ insert/update `group_user_status`); uses `InviteFriends` RPC |
| `group/comp_review_invite/` | Review an invite received | Accept/decline invite |
| `group/comp_assign_admin/`, `comp_confirm_admin_role/` | Assign a member as admin | Insert `group_admin` (role `admin`); refresh members via `GroupMembers` RPC |
| `group/comp_resign_admin/` | Current admin resigns own admin role | `delete_group_admin` RPC (self) |
| `group/comp_revoke_admin/` | Revoke another user's admin role | `delete_group_admin` RPC (target user) |
| `group/comp_leave_group/` | Leave a group | Delete `group_members` + `group_admin` + `group_user_status` for the user; `update_total_group_members` |
| `group/comp_unblock_user/` | Unblock a user | `BlocksTable.delete` (blocker=current, blocked=target) |
| `group/comp_report_group/` | Report a group | Insert `reports` rows (`reason`) |
| `group/comp_share_group/` | Share a group | Share sheet (no direct DML observed) |
| `group/comp_no_groups_available/`, `comp_group_1/`, `comp_group_2/` | Empty-state / card presentational components | Navigation only |
| `groups/` | Top-level groups landing/list | Lists groups (uses group list RPCs) |
| `home/specific_user_groups/` | View another user's groups | `get_user_following_groups_with_status` RPC (`GetOtherUserFollowingGroupsr`) |
| `home/comp_report_block/` (shared) | Report + BLOCK a user (used for block-in-group) | Insert `blocks` (`blocker_id`,`blocked_id`,`community_id`) |

## 3. Data model (tables & columns)
Types/nullability read from the FlutterFlow Row classes under
`lib/backend/supabase/database/tables/`.

### `group`
- **Purpose:** A group within a community.
- **Columns:**
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid (string) | no | PK |
  | `created_at` | timestamptz | no | default `now()` |
  | `community_id` | int (int8) | no | FK → community; scopes the group |
  | `created_by` | uuid (string) | no | FK → user (creator) |
  | `profile_picture` | text | yes | banner/profile image URL; defaults to a fixed `squadd/default_group_image` URL |
  | `name` | text | no | group name |
  | `description` | text | yes | group description |
  | `e_group_type` | text (enum-like) | no | `'open'` or `'private'` (see §5) |
  | `e_discoverability` | text (enum-like) | no | discoverability setting (radio value from create/edit) |
  | `updated_at` | timestamptz | yes | set on create/edit via `getCurrentUtcTime()` |
  | `total_members` | int (int8) | no | running member count; created with `1`; kept in sync by `update_total_group_members` RPC |
  | `location` | text | no | location radio value |
  | `isdeleted` | bool | no | soft-delete flag (delete sets `true`) |
  | `status` | text | no | lifecycle; `Status` enum serialized name: `active` / `removed` / `suspended` (delete sets `'removed'`) |
- **Foreign keys:** `community_id` → community; `created_by` → user profile.
- **Indexes needed:** `community_id`, `created_by`, and a filter index on
  `(community_id, isdeleted, status)` for list queries.

### `group_admin`
- **Purpose:** Which users are admins of a group.
- **Columns:**
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid (string) | no | PK |
  | `created_at` | timestamptz | no | default `now()` |
  | `community_id` | int (int8) | no | FK → community |
  | `group_id` | uuid (string) | no | FK → group |
  | `user_id` | uuid (string) | no | FK → user |
  | `e_group_role` | text | no | role string; only observed value `'admin'` |
- **FKs:** `group_id` → group (`on delete cascade`); `user_id` → user; `community_id` → community.
- **Indexes needed:** `group_id`, `user_id`, `community_id`; unique `(group_id, user_id)`
  recommended (one admin row per user per group).

### `group_members`
- **Purpose:** Actual/approved membership rows (source for member counts).
- **Columns:**
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid (string) | no | PK |
  | `created_at` | timestamptz | no | default `now()` |
  | `community_id` | int (int8) | no | FK → community |
  | `user_id` | uuid (string) | no | FK → user |
  | `group_id` | uuid (string) | no | FK → group |
  | `is_requested` | bool | yes | true when the row originated from a request flow |
  | `requested_date` | timestamptz | yes | when requested |
  | `is_approved` | bool | yes | approved membership |
  | `approved_by` | uuid (string) | yes | admin/user who approved (self on open-join) |
  | `joined_at` | timestamptz | yes | join timestamp |
- **FKs:** `group_id` → group (`on delete cascade`); `user_id` → user; `community_id` → community.
- **Indexes needed:** `group_id`, `user_id`, `community_id`; unique `(group_id, user_id)`
  recommended. `update_total_group_members` counts by `group_id`.

### `group_members_invite`
- **Purpose:** Outstanding invites sent to users.
- **Columns:**
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid (string) | no | PK |
  | `created_at` | timestamptz | no | default `now()` |
  | `community_id` | int (int8) | no | FK → community |
  | `invited_by` | uuid (string) | no | FK → user (inviter) |
  | `group_id` | uuid (string) | no | FK → group |
  | `invited_user` | uuid (string) | no | FK → user (invitee) |
  | `is_member` | bool | no | set `true` when invite accepted |
  | `accepted_at` | timestamptz | yes | when the invite was accepted |
- **FKs:** `group_id` → group (`on delete cascade`); `invited_by`,`invited_user` → user;
  `community_id` → community.
- **Indexes needed:** `group_id`, `invited_user`, `invited_by`, `community_id`.

### `group_user_status`
- **Purpose:** Per-user membership STATE MACHINE for a group (the single row the UI reads to
  decide which button — Join / Request / Invite / Member — to show). Booleans are combined
  into a derived `user_status` string by the list RPCs.
- **Columns:**
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid (string) | no | PK |
  | `created_at` | timestamptz | no | default `now()` |
  | `community_id` | int (int8) | no | FK → community |
  | `user_id` | uuid (string) | no | FK → user |
  | `group_id` | uuid (string) | no | FK → group |
  | `is_requested` | bool | yes | user has requested to join (private) |
  | `is_invited` | bool | yes | user has been invited |
  | `is_approved` | bool | yes | request/invite approved |
  | `is_member` | bool | yes | user is an active member |
  | `invited_by` | uuid (string) | yes | inviter |
  | `approved_by` | uuid (string) | yes | approver |
  | `requested_date` | timestamptz | yes | |
  | `invited_date` | timestamptz | yes | |
  | `joined_at` | timestamptz | yes | |
- **FKs:** `group_id` → group (`on delete cascade`); `user_id`,`invited_by`,`approved_by` → user;
  `community_id` → community.
- **Indexes needed:** unique `(group_id, user_id)` (one status row per user per group — required
  because insert-vs-update paths depend on existence); plus `group_id`, `user_id`.

### `blocks` (shared — used by block/unblock in group)
- **Purpose:** User-to-user blocks; used to block/unblock people encountered in a group.
- **Columns:**
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid (string) | no | PK |
  | `created_at` | timestamptz | no | default `now()` |
  | `blocker_id` | uuid (string) | no | FK → user (who blocks) |
  | `blocked_id` | uuid (string) | no | FK → user (who is blocked) |
  | `community_id` | int (int8) | no | FK → community |
- **FKs:** `blocker_id`,`blocked_id` → user; `community_id` → community.
- **Indexes needed:** `(blocker_id, blocked_id)` unique; `blocked_id`.
- **Note:** the block INSERT is performed by the shared `home/comp_report_block/` component
  (`reportType` differentiates contexts). Unblock (`BlocksTable.delete`) is in
  `group/comp_unblock_user/`.

## 4. Backend calls (API / RPC / Edge)
All RPCs are Supabase PostgREST `POST /rest/v1/rpc/<fn>` (project ref in URLs is the OLD project
`wgcqstmmkcdjnnpuvspr` — must be repointed to Viora's own project). Direct table ops go through
the FlutterFlow `SupabaseTable` wrapper (PostgREST REST on the table).

| Call / query | Type | Inputs | Returns | Called from |
|---|---|---|---|---|
| `get_groups_with_user_status` (`GetGroupsWithUserStatusCall`) | RPC | none (auth user) | list of groups + derived `user_status`, `e_group_type`, `total_members`, `nearest`, `invited_by_user_id` | all_groups / nearest_groups / groups list |
| `get_specific_group_with_user_status` (`SpecificGroupCall`) | RPC | `p_group_id` | single group row + `user_status`, `nearest`, counts | group_details / about_group |
| `get_group_members_with_admin_status` (`GroupMembersCall`) | RPC | `p_group_id`, `p_search_text` | members with admin flag | member lists, assign/resign/revoke refresh |
| `get_available_users_to_invite` (`InviteFriendsCall`) | RPC | `p_search_text`, `p_group_id`, `p_community_id` | invitable users + their `user_status` | comp_invite_friends |
| `get_invited_users_for_group` (`GetInvitedUsersForGroupCall`) | RPC | `p_community_id`, `p_group_id`, `p_search_text` | already-invited users | invite management |
| `get_user_following_groups_with_status` (`GetOtherUserFollowingGroupsrCall`) | RPC | `target_user_id` | another user's groups + status | home/specific_user_groups |
| `delete_group_admin` (`DeleteAdminCall`) | RPC | `p_group_id`, `p_user_id` | — | comp_resign_admin (self), comp_revoke_admin (target) |
| `update_total_group_members` (`UpdateTotalGroupMembersCall`) | RPC | `p_group_id` | — (recomputes `group.total_members`) | after join/leave/approve |
| `update_user_group_count` (`UpdateUserGroupCountCall`) | RPC | none (auth user) | — (updates the user's group count) | after create_group |
| `check_group_member` (`CheckGroupMemberShareCall`) | RPC | `p_userid`, `p_postid` | membership check for sharing a post into a group | share flow |
| `update_user_profile_counts` (`UpdateUserProfileCountsCall`, `option:'group'`) | RPC | `option` | — | create/delete group profile-count rollup |
| `group` insert/update | direct DML | see §5 | row | create_group, edit_group, comp_delete_group |
| `group_admin` insert/delete | direct DML | community_id, group_id, user_id, e_group_role | — | create_group, comp_confirm_admin_role, comp_leave_group |
| `group_members` insert/delete | direct DML | membership fields | — | create/join/approve/leave |
| `group_members_invite` insert/update | direct DML | invite fields | — | comp_invite_friends, approve/accept flows |
| `group_user_status` insert/update/delete | direct DML | state booleans | — | join/request/invite/approve/leave |
| `blocks` insert/delete | direct DML | blocker_id, blocked_id, community_id | — | comp_report_block (insert), comp_unblock_user (delete) |

## 5. Business rules & flows

### Group types & visibility
- `e_group_type` = `'open'` or `'private'`.
  - **Open:** any community user may join instantly (no approval).
  - **Private:** users must **request** to join; an admin approves. Invited users can join.
- `e_discoverability` and `location` are radio-selected on create/edit; the list RPCs use them
  (plus `nearest`) to decide what a user sees.
- The list RPCs return a derived `user_status` string that drives the button shown. Observed
  values: `join` (open, not member → join instantly), `request` (private, not member → request),
  `requested` (request pending), `invite` (user has an invite pending), `not_member`, and a
  member/joined state. `e_group_type` is also returned so the invite-accept path branches on
  open vs private.

### Create group (`create_group`)
1. Insert `group` with `community_id`, `created_by=currentUser`, name, description,
   `e_group_type`, `e_discoverability`, `updated_at`, default `profile_picture`, `total_members=1`,
   `location`.
2. Insert `group_admin` (`e_group_role='admin'`, creator).
3. Insert `group_members` (creator, `is_requested=false`, `is_approved=true`,
   `approved_by=self`, `joined_at`, `requested_date`).
4. Insert `group_user_status` (creator, `is_member=true`, `joined_at`).
5. `update_user_group_count` (auth user).
6. If a banner was picked: upload to storage bucket `group-profile-image` (folder = group id),
   then `GroupTable.update` `profile_picture`.
7. `update_user_profile_counts(option:'group')`.

### Edit group (`edit_group`)
- `GroupTable.update` name/description/location/`updated_at`/`profile_picture` matched by `id`.
  (Note: on save it currently RESETS `profile_picture` to the default URL, then re-uploads the
  new banner and updates again if a file was chosen — see §8.)

### Delete group (`comp_delete_group`) — SOFT DELETE
- `GroupTable.update` → `isdeleted=true`, `status='removed'` matched by `id`. No hard delete.
- `update_user_profile_counts(option:'group')`; navigate to Community.

### Join OPEN group (all_groups / nearest_groups / my_group / group_details; `user_status=='join'`)
1. Insert `group_members` (self, `is_requested=false`, `is_approved=true`, `approved_by=self`,
   `requested_date`, `joined_at`).
2. Insert `group_user_status` (self, `is_requested=false`, `is_invited=false`, `is_member=true`,
   `joined_at`).
3. `update_total_group_members(p_group_id)`.

### Request to join PRIVATE group (`user_status=='request'`)
- Insert `group_user_status` (self, `is_requested=true`, `is_invited=false`, `is_member=false`,
  `is_approved=false`, `requested_date`). No `group_members` row yet, no count change.
- (A "requested" state then shows; cancel path updates `is_requested=false`.)

### Invite friends (`comp_invite_friends`)
For each selected user (branch on their current `user_status`):
- **If `requested`** (user already requested): insert `group_members_invite`
  (`invited_by=self`, `invited_user`, `is_member=false`) AND **update** existing
  `group_user_status` → `is_invited=true`, `invited_by=self`, `invited_date`, `is_requested=false`.
- **Else** (`not_member`): insert `group_members_invite` AND **insert** a new
  `group_user_status` (`is_requested=false`, `is_invited=true`, `is_approved=false`,
  `is_member=false`, `invited_by=self`, `invited_date`).
- Invitable users come from `get_available_users_to_invite`.

### Accept an invite (list screens; `user_status=='invite'`)
- **Open group invite:** insert `group_members` (`approved_by=invited_by`, `joined_at`),
  insert `group_user_status` (`is_invited=true`, `is_member=true`, `is_approved=true`,
  `invited_by`), update `group_members_invite` → `is_member=true` (matched by group_id +
  invited_by + invited_user), then `update_total_group_members`.
- **Private group invite:** update `group_user_status` → `is_requested=true` + `requested_date`
  (converts the invite into a request that an admin then approves).

### Approve a join request (`comp_joining_request`, admin)
1. Update `group_user_status` (target user) → `is_approved=true`, `is_member=true`,
   `approved_by=currentUser`, `joined_at`.
2. Update `group_members_invite` (target) → `is_member=true`, `accepted_at` (if an invite row
   exists).
3. Insert `group_members` (target, `is_approved=true`, `approved_by=currentUser`, `joined_at`).
4. `update_total_group_members(p_group_id)`.

### Admins
- **Assign admin** (`comp_assign_admin` → `comp_confirm_admin_role`): insert `group_admin`
  (`community_id`, `group_id`, `user_id`, `e_group_role='admin'`), then refresh member list via
  `get_group_members_with_admin_status`.
- **Resign admin** (`comp_resign_admin`): `delete_group_admin(p_group_id, p_user_id=self)`.
- **Revoke admin** (`comp_revoke_admin`): `delete_group_admin(p_group_id, p_user_id=target)`.
- Only the `'admin'` role value is observed. Group creator is the initial admin.

### Leave group (`comp_leave_group`)
- Delete `group_members`, `group_admin`, and `group_user_status` rows for
  (`group_id`, `user_id=self`), then `update_total_group_members(p_group_id)`.

### Block / unblock in group
- **Block:** insert `blocks` (`blocker_id=self`, `blocked_id=target`, `community_id`) via the
  shared `comp_report_block` component.
- **Unblock** (`comp_unblock_user`): `BlocksTable.delete` where `blocker_id=self` AND
  `blocked_id=target`.

### Member counts
- `group.total_members` is the authoritative displayed count, recomputed server-side by
  `update_total_group_members(p_group_id)` after every join / approve / leave. Frontend never
  increments it manually (except the literal `1` set at creation).
- The current user's own group count is recomputed by `update_user_group_count` (after create)
  and by `update_user_profile_counts(option:'group')` (after create/delete).

## 6. Realtime / notifications
- No explicit Supabase Realtime channel (Broadcast or Postgres Changes) subscriptions were found
  in the group screens; lists are refreshed by re-calling the RPCs and `safeSetState`.
- No OneSignal/push trigger code is present in these group widgets. Invite/request/approval
  notifications, if desired, are NOT implemented in the frontend here — confirm before adding.

## 7. Backend to build (Supabase rebuild checklist)

### Tables + columns + FKs + indexes
- [ ] `group`, `group_admin`, `group_members`, `group_members_invite`, `group_user_status` per §3.
- [ ] Confirm/create `blocks` (shared) per §3.
- [ ] FKs with `on delete cascade` from all group-child tables → `group.id`.
- [ ] Unique constraints: `group_user_status(group_id,user_id)`, `group_members(group_id,user_id)`,
      `group_admin(group_id,user_id)`, `blocks(blocker_id,blocked_id)`.
- [ ] Index every FK (`group_id`, `user_id`, `community_id`, `invited_user`, `invited_by`,
      `created_by`, `approved_by`) and list filters (`community_id`,`isdeleted`,`status`).
- [ ] Add DB CHECK or enum for `e_group_type` (`open`/`private`) and `status`
      (`active`/`removed`/`suspended`). Confirm allowed `e_discoverability` / `e_group_role` values.

### RLS intent (per CLAUDE.md §6 — RLS mandatory, deny by default, user writes via RPC)
- [ ] **`group`**
  - SELECT: any authenticated user in the same `community_id` may see groups where
    `isdeleted=false` and `status='active'` — needed for discovery. (Private groups are still
    listed for discovery; membership gates content, not existence.)
  - INSERT: authenticated user; `created_by` forced to `auth.uid()`.
  - UPDATE: only group admins (`group_admin` row) or `created_by`. Soft-delete
    (`isdeleted`,`status`) restricted to admins.
  - DELETE: none (soft-delete only).
- [ ] **`group_admin`**
  - SELECT: members of the group / community.
  - INSERT/DELETE: **admin-only**, and must go through validated RPC (`delete_group_admin`
    already exists for delete; assign should get a matching RPC). Prevent removing the last admin.
- [ ] **`group_members`**
  - SELECT: members of the group; admins see all (incl. pending). Public/open group members may
    be visible community-wide — confirm.
  - INSERT/UPDATE/DELETE: via RPC that validates: open group → self-join allowed; private group →
    only after approval; leave → self only; approve → admin only.
- [ ] **`group_members_invite`**
  - SELECT: the invitee, the inviter, and group admins.
  - INSERT: group members/admins (inviter = `auth.uid()`), via RPC.
  - UPDATE: invitee (accept) / admin, via RPC.
- [ ] **`group_user_status`**
  - SELECT: the row's `user_id` and group admins.
  - INSERT/UPDATE/DELETE: via RPC enforcing the state machine (§5); users mutate only their own
    status; approvals admin-only.
- [ ] **`blocks`**: SELECT/INSERT/DELETE limited to `blocker_id = auth.uid()`.
- [ ] Wrap all helper predicates (e.g. `is_group_admin(group_id)`, `is_group_member(group_id)`)
      as `(SELECT ...)` in policies; mark `STABLE SECURITY INVOKER`, `SET search_path`.

### RPC / PL-pgSQL functions to (re)create
- [ ] `get_groups_with_user_status()` → groups in caller's community + derived `user_status`,
      `e_group_type`, `total_members`, `nearest`, `invited_by_user_id`.
- [ ] `get_specific_group_with_user_status(p_group_id)`.
- [ ] `get_group_members_with_admin_status(p_group_id, p_search_text)`.
- [ ] `get_available_users_to_invite(p_search_text, p_group_id, p_community_id)`.
- [ ] `get_invited_users_for_group(p_community_id, p_group_id, p_search_text)`.
- [ ] `get_user_following_groups_with_status(target_user_id)`.
- [ ] `delete_group_admin(p_group_id, p_user_id)` — validate caller is admin (or self-resign);
      block removing last admin.
- [ ] `update_total_group_members(p_group_id)` — recompute `group.total_members = count(group_members)`.
- [ ] `update_user_group_count()` — recompute the caller's group count.
- [ ] `check_group_member(p_userid, p_postid)`.
- [ ] `update_user_profile_counts(option)` (shared; supports `option='group'`).
- [ ] **Recommended new RPCs** to satisfy CLAUDE.md "user writes via RPC" (frontend currently
      does direct DML for join/request/invite/approve/leave): `join_open_group`,
      `request_join_group`, `invite_user_to_group`, `accept_group_invite`, `approve_join_request`,
      `assign_group_admin`, `leave_group`. Each validates auth + group type + membership state and
      keeps `group_user_status` / `group_members` / counts consistent atomically.
- [ ] All `SECURITY DEFINER` fns: `SET search_path=public,pg_temp`, validate `auth.uid()`,
      `REVOKE ALL FROM PUBLIC`, `GRANT EXECUTE TO authenticated`.

### Storage
- [ ] Bucket `group-profile-image` (public read; write restricted to group admins/creator).
      Files stored under folder = `group.id`. A default image lives at
      `squadd/default_group_image/default_group_image.png` (public bucket `squadd`).

### Triggers / cron
- [ ] Consider triggers on `group_members` INSERT/DELETE to keep `group.total_members` in sync
      instead of relying on the client to call `update_total_group_members` (client can skip it).
- [ ] No cron observed for this feature.

## 8. Open questions & risks
1. **Client does privileged direct DML.** Join/request/invite/approve/leave and admin-assign are
   direct `.insert/.update/.delete` from the client — violates CLAUDE.md §6 (user writes must go
   through validated RPC). Rebuild should move these behind RPCs; RLS alone can't enforce the
   state machine (e.g. preventing self-approval into a private group). **Confirm this migration.**
2. **Member count integrity.** `total_members` is maintained by an explicit client RPC call after
   each mutation; if the client fails mid-flow the count drifts. A DB trigger is safer — confirm.
3. **Old project ref hardcoded.** Every RPC URL points to `wgcqstmmkcdjnnpuvspr.supabase.co`.
   Must be repointed to Viora's own project and driven from env, not hardcoded.
4. **`e_discoverability` / `e_group_role` value sets unknown.** Only `e_group_type` (`open`/
   `private`) and `e_group_role='admin'` are visible in code. Need the full allowed value lists
   (radio options) — check `create_group`/`edit_group` radio definitions to enumerate.
5. **`status` enum mismatch.** Dart `Status` enum = `active/removed/suspended`, but `group.status`
   is a plain text column. Confirm the DB column is text (or a Postgres enum) and its default
   (`active`?).
6. **Edit resets banner to default.** `edit_group` sets `profile_picture` to the default URL on
   every save, then re-uploads only if a new file was chosen. If a user edits text without
   re-picking an image, the existing custom banner may be lost. Confirm intended behavior.
7. **Private-group invite → request conversion.** Accepting an invite to a *private* group only
   sets `is_requested=true` (still needs admin approval), while an *open*-group invite joins
   immediately. Confirm this two-step design is intended.
8. **`user_status` derivation.** The exact boolean→string mapping (`join`/`request`/`requested`/
   `invite`/`not_member`/member) lives inside the list RPCs, which we cannot read from the
   frontend. Must reconstruct the mapping precisely from the button conditions in
   `all_groups`/`nearest_groups`/`my_group`/`group_details`.
9. **Block-in-group scope.** The block INSERT uses the shared `home/comp_report_block` component
   and the community-wide `blocks` table — blocks are user-level, not group-scoped. Confirm
   whether a group-scoped block is expected or user-level blocking is sufficient.
10. **Notifications absent.** No push/realtime for invites, requests, or approvals in the group
    widgets. Confirm whether the rebuild should add them (OneSignal/Firebase per stack).
11. **Cascade on soft-delete.** Because delete is soft (`isdeleted=true`), child rows
    (`group_members`, etc.) are NOT removed. Confirm list RPCs filter deleted groups everywhere.

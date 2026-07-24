-- 0025_group_tables.sql
-- Purpose: Batch 4 (Groups) tables — "group", group_admin, group_members, group_members_invite,
-- group_user_status. Columns/types/nullability match docs/database/03-tables-community-groups.md,
-- cross-checked against the locked frontend Row classes (group.dart, group_admin.dart,
-- group_members.dart, group_members_invite.dart, group_user_status.dart). Also adds the DEFERRED
-- post.group_id FK now that "group" exists (per 0008_post_tables.sql's own header note).
--
-- RLS: ENABLE ROW LEVEL SECURITY on every table below, NO POLICIES in this file (deny-all to
-- anon/authenticated until reviewed). The proposed policy set lives in docs/rls-policies-draft.md
-- ("Batch 4 — Groups") pending sign-off (CLAUDE.md §6.9).
--
-- community_id: kept as a vestigial compat column (int8, default 1, nullable, NO FK) on all five
-- tables below, per docs/decisions.md (2026-07-19, "Remove community concept") — every one of
-- these Row classes carries the column and the locked frontend still sends/filters `= 1`.
--
-- "group" is a RESERVED word in Postgres — double-quoted everywhere in this file and every other
-- Groups-batch file.
--
-- Quirk preserved verbatim: "group".isdeleted has NO underscore (matches the frontend Row class
-- getter `isdeleted`, unlike every other soft-delete flag in this schema which uses `is_deleted`).

begin;

-- ---------------------------------------------------------------------------------------------
-- "group" — a neighborhood interest group. created_by = creator, who becomes the initial admin
-- (enforced by create_group() RPC, not by a DB constraint). Soft-delete only (isdeleted/status).
-- ---------------------------------------------------------------------------------------------
create table public."group" (
  id                 uuid primary key default extensions.gen_random_uuid(),
  created_at         timestamptz not null default now(),
  community_id       int8 default 1, -- vestigial compat column, no FK; see file header
  created_by         uuid not null references public."user" (id) on delete restrict,
  profile_picture    text default 'squadd/default_group_image/default_group_image.png', -- TODO(confirm): exact full public URL once the `squadd` bucket is provisioned (docs/database/07-storage-buckets.md)
  name               text not null,
  description        text,
  e_group_type       public.e_group_type not null,
  e_discoverability  text not null, -- TODO(confirm): full radio-option value set (kept text, decision #9)
  updated_at         timestamptz,
  total_members      int8 not null default 1, -- trigger-maintained from group_members (0032)
  location           text not null,
  isdeleted          boolean not null default false, -- quirk: no underscore, kept verbatim
  status             public.lifecycle_status not null default 'active'
);

comment on table public."group" is
  'A neighborhood interest group. Soft-delete only (isdeleted/status). Writes RPC-only (create_group/edit_group/delete_group).';

-- created_by is FK'd `on delete restrict`: a group should not silently vanish/orphan because its
-- creator's row cascades away — the creator must transfer ownership or the group must be
-- explicitly soft-deleted first. -- TODO(confirm) with product.
create index group_created_by_idx on public."group" (created_by);
create index group_isdeleted_status_idx on public."group" (isdeleted, status);
-- List/discovery ordering (no community_id — no community scoping, per docs/decisions.md).
create index group_feed_idx on public."group" (isdeleted, status, created_at desc);

alter table public."group" enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

-- ---------------------------------------------------------------------------------------------
-- group_admin — which users are admins of a group. Only 'admin' role value observed; kept as
-- `text` + CHECK rather than an enum (decision #9), per docs/database/03-tables-community-groups.md.
-- ---------------------------------------------------------------------------------------------
create table public.group_admin (
  id            uuid primary key default extensions.gen_random_uuid(),
  created_at    timestamptz not null default now(),
  community_id  int8 default 1, -- vestigial compat column, no FK; see file header
  group_id      uuid not null references public."group" (id) on delete cascade,
  user_id       uuid not null references public."user" (id) on delete cascade,
  e_group_role  text not null default 'admin',
  constraint group_admin_e_group_role_check check (e_group_role = 'admin'), -- TODO(confirm): only value observed in the locked frontend
  constraint group_admin_group_id_user_id_key unique (group_id, user_id)
);

comment on table public.group_admin is
  'One row per (group, admin-user). Writes only via assign_group_admin()/delete_group_admin() RPCs, which block removing the last admin.';

create index group_admin_group_id_idx on public.group_admin (group_id);
create index group_admin_user_id_idx on public.group_admin (user_id);

alter table public.group_admin enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

-- ---------------------------------------------------------------------------------------------
-- group_members — actual/approved membership rows (source of truth for group.total_members and
-- public_user_profile.group_count, both trigger-maintained — see 0032_group_triggers.sql).
-- ---------------------------------------------------------------------------------------------
create table public.group_members (
  id              uuid primary key default extensions.gen_random_uuid(),
  created_at      timestamptz not null default now(),
  community_id    int8 default 1, -- vestigial compat column, no FK; see file header
  user_id         uuid not null references public."user" (id) on delete cascade,
  group_id        uuid not null references public."group" (id) on delete cascade,
  is_requested    boolean,
  requested_date  timestamptz,
  is_approved     boolean,
  approved_by     uuid references public."user" (id) on delete set null,
  joined_at       timestamptz,
  constraint group_members_group_id_user_id_key unique (group_id, user_id)
);

comment on table public.group_members is
  'Approved/actual membership rows. Writes only via the group state-machine RPCs (request_or_join_group/accept_invite/approve_join_request/leave_group).';

create index group_members_group_id_idx on public.group_members (group_id);
create index group_members_user_id_idx on public.group_members (user_id);
create index group_members_approved_by_idx on public.group_members (approved_by);
-- Counter-trigger source query index (group_id, is_approved).
create index group_members_group_id_approved_idx on public.group_members (group_id, is_approved);

alter table public.group_members enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

-- ---------------------------------------------------------------------------------------------
-- group_members_invite — outstanding invites. UNIQUE(group_id, invited_user) -- TODO(confirm): the
-- feature doc doesn't state this explicitly, but the accept/approve flows match-and-update a
-- single invite row "by group_id + invited_by + invited_user"; a stricter UNIQUE(group_id,
-- invited_user) (one live invite per user per group, re-invite = upsert) is assumed here as the
-- simplest state-machine-safe model. Revisit if multiple concurrent inviters per user is a real
-- requirement.
-- ---------------------------------------------------------------------------------------------
create table public.group_members_invite (
  id            uuid primary key default extensions.gen_random_uuid(),
  created_at    timestamptz not null default now(),
  community_id  int8 default 1, -- vestigial compat column, no FK; see file header
  invited_by    uuid not null references public."user" (id) on delete cascade,
  group_id      uuid not null references public."group" (id) on delete cascade,
  invited_user  uuid not null references public."user" (id) on delete cascade,
  is_member     boolean not null default false,
  accepted_at   timestamptz,
  constraint group_members_invite_group_id_invited_user_key unique (group_id, invited_user) -- TODO(confirm), see above
);

comment on table public.group_members_invite is
  'Outstanding/historical invites. Writes only via invite_users_to_group()/accept_invite()/approve_join_request() RPCs.';

create index group_members_invite_group_id_idx on public.group_members_invite (group_id);
create index group_members_invite_invited_user_idx on public.group_members_invite (invited_user);
create index group_members_invite_invited_by_idx on public.group_members_invite (invited_by);

alter table public.group_members_invite enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

-- ---------------------------------------------------------------------------------------------
-- group_user_status — per-(user,group) state machine row driving the Join/Request/Invite/Member
-- button. UNIQUE(group_id, user_id) required — the RPCs depend on insert-vs-update-by-existence.
-- ---------------------------------------------------------------------------------------------
create table public.group_user_status (
  id              uuid primary key default extensions.gen_random_uuid(),
  created_at      timestamptz not null default now(),
  community_id    int8 default 1, -- vestigial compat column, no FK; see file header
  user_id         uuid not null references public."user" (id) on delete cascade,
  group_id        uuid not null references public."group" (id) on delete cascade,
  is_requested    boolean,
  is_invited      boolean,
  is_approved     boolean,
  is_member       boolean,
  invited_by      uuid references public."user" (id) on delete set null,
  approved_by     uuid references public."user" (id) on delete set null,
  requested_date  timestamptz,
  invited_date    timestamptz,
  joined_at       timestamptz,
  constraint group_user_status_group_id_user_id_key unique (group_id, user_id)
);

comment on table public.group_user_status is
  'Per-user membership state machine (drives Join/Request/Invite/Member button). Writes only via the group state-machine RPCs.';

create index group_user_status_group_id_idx on public.group_user_status (group_id);
create index group_user_status_user_id_idx on public.group_user_status (user_id);
create index group_user_status_invited_by_idx on public.group_user_status (invited_by);
create index group_user_status_approved_by_idx on public.group_user_status (approved_by);

alter table public.group_user_status enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

-- ---------------------------------------------------------------------------------------------
-- post.group_id — DEFERRED FK from 0008_post_tables.sql, added now that "group" exists.
-- TODO(confirm): on delete set null vs cascade, per docs/database/02-tables-posts-comments.md —
-- `set null` chosen so a deleted group doesn't cascade-delete member posts (posts survive as
-- ungrouped), matching this task's literal instruction.
-- ---------------------------------------------------------------------------------------------
alter table public.post
  add constraint post_group_id_fkey foreign key (group_id) references public."group" (id) on delete set null;

commit;

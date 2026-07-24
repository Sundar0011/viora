-- 0054_business_tables.sql
-- Purpose: Batch 6 (Business Pages & Promotions) tables — business_promote_plans, business_page,
-- business_promote, business_contacted. Columns/types/nullability match docs/database/
-- 05-tables-business-chat.md, cross-checked against the locked frontend Row classes
-- (business_page.dart, business_promote.dart, business_promote_plans.dart, business_contacted.dart).
-- Created in dependency order: plans -> page -> promote (FKs both plans and page) -> contacted.
--
-- RLS: ENABLE ROW LEVEL SECURITY on all four tables, NO POLICIES in this file (deny-all to
-- anon/authenticated until reviewed). The proposed policy set lives in docs/rls-policies-draft.md
-- ("Batch 6 — Business & Chat") pending sign-off (CLAUDE.md §6.9).
--
-- community_id: kept as a vestigial compat column (int8, nullable, DEFAULT 1, NO FK) on all four
-- tables, per docs/decisions.md (2026-07-19, "Remove community concept") — every one of these Row
-- classes carries the column and the locked frontend still sends/filters `= 1`.
--
-- IMPORTANT NAMING NOTE (preserved verbatim, CLAUDE.md §2): `admin_user` on business_page AND
-- business_promote means the PAGE OWNER / SUBMITTER (currentUserUid), NOT a platform admin. Do
-- not confuse with public.is_admin() (JWT role claim) used throughout this batch for MODERATION
-- authority (admin_set_promotion_status).

begin;

-- ---------------------------------------------------------------------------------------------
-- business_promote_plans — admin-managed catalog of promotion pricing tiers. int8 identity PK per
-- the frontend Row class (business_promote_plans.dart: `id` is an int, not uuid — unlike every
-- other table in this batch). Global (no community scoping) despite the vestigial community_id
-- column, matching the sale_category precedent (0043).
-- ---------------------------------------------------------------------------------------------
create table public.business_promote_plans (
  id            int8 generated always as identity primary key,
  created_at    timestamptz not null default now(),
  community_id  int8 default 1, -- vestigial compat column, no FK; see file header
  days_count    int8 not null,
  price         numeric not null,
  currency      text not null,
  image_url     text
);

comment on table public.business_promote_plans is
  'Admin-managed catalog of promotion pricing tiers. Global (no community scoping). SELECT to authenticated; INSERT/UPDATE/DELETE admin-only (no client write RPC in this batch — seeded/managed via migration or a future admin console).';

create index business_promote_plans_price_idx on public.business_promote_plans (price);

alter table public.business_promote_plans enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

-- ---------------------------------------------------------------------------------------------
-- business_page — one row per business page. admin_user = PAGE OWNER (see file header note).
-- ---------------------------------------------------------------------------------------------
create table public.business_page (
  id               uuid primary key default extensions.gen_random_uuid(),
  created_at       timestamptz not null default now(),
  community_id     int8 default 1, -- vestigial compat column, no FK; see file header
  admin_user       uuid not null references public."user" (id) on delete restrict,
  name             text not null,
  bio              text not null,
  profile_picture  text,
  cover_image      text,
  services         text[] not null default '{}',
  website_link     text not null,
  email            text not null,
  phonenumber      text not null,
  is_deleted       boolean not null default false,
  business_status  public.lifecycle_status not null default 'active'
);

comment on table public.business_page is
  'One business page per owner submission. admin_user = the PAGE OWNER (currentUserUid), NOT a platform admin. Soft-delete only (is_deleted + business_status=removed). Writes RPC-only (create_business_page/edit_business_page/delete_business_page/restore_business_page).';

-- admin_user FK'd `on delete restrict`: a page should not silently vanish/orphan because its
-- owner's account cascades away — soft-delete the page explicitly instead (matches
-- "group"/"event_page"/sale.created_by precedent).
create index business_page_admin_user_idx on public.business_page (admin_user);
create index business_page_is_deleted_idx on public.business_page (is_deleted);
create index business_page_business_status_idx on public.business_page (business_status);

alter table public.business_page enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

-- ---------------------------------------------------------------------------------------------
-- business_promote — one promotion request per business page. admin_user = the SUBMITTER (page
-- owner), NOT a platform admin (see file header note). status is text (unconfirmed full value
-- set, kept per docs/decisions.md 2026-07-19 "Unknown dropdown value sets" decision); observed
-- values: 'under review' (client-set via create_or_update_promotion), 'live'/'ended'/'rejected'/
-- 'mismatch' (platform-admin-set via admin_set_promotion_status, is_admin()-gated).
--
-- UNIQUE (business_page_id, admin_user): added beyond the table doc's plain composite INDEX so
-- create_or_update_promotion() can use a single idempotent UPSERT (ON CONFLICT) instead of a
-- separate insert-vs-update branch — matches the doc's own description of the update path
-- ("match (business_page_id, admin_user)"), i.e. at most one active promotion request per
-- (page, submitter) pair at a time. -- TODO(confirm): if a business is ever allowed multiple
-- concurrent/historical promotion rows per owner, this UNIQUE constraint must be relaxed and
-- create_or_update_promotion's upsert logic revisited.
-- ---------------------------------------------------------------------------------------------
create table public.business_promote (
  id                       uuid primary key default extensions.gen_random_uuid(),
  created_at               timestamptz not null default now(),
  community_id             int8 default 1, -- vestigial compat column, no FK; see file header
  business_page_id         uuid not null references public.business_page (id) on delete cascade,
  business_promote_plans   int8 not null references public.business_promote_plans (id) on delete restrict,
  reference_number         int8 not null, -- payment reference, int8 per frontend; TODO(confirm) overflow/leading-zero risk (feature doc §8.5)
  receipt                  text, -- bucket promote-receipts (PRIVATE)
  status                   text not null default 'under review',
  plan_start_date          timestamptz,
  plan_end_date            timestamptz,
  admin_user               uuid not null references public."user" (id) on delete restrict,
  unique (business_page_id, admin_user)
);

comment on table public.business_promote is
  'One promotion request per (business_page, submitter). admin_user = the SUBMITTER (page owner), NOT a platform admin. status lifecycle: under review (owner-set) -> live/ended/rejected/mismatch (platform-admin-set via admin_set_promotion_status, audited). Writes RPC-only.';

create index business_promote_business_page_id_idx on public.business_promote (business_page_id);
create index business_promote_plans_fk_idx on public.business_promote (business_promote_plans);
create index business_promote_admin_user_idx on public.business_promote (admin_user);
create index business_promote_status_idx on public.business_promote (status);

alter table public.business_promote enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

-- ---------------------------------------------------------------------------------------------
-- business_contacted — tracks that a user contacted a business. UNIQUE (business_page_id,
-- contacted_user): one row per user, channels APPENDED into last_contact_link over time — resolves
-- feature doc §8.6's open question ("insert one row per tap" vs "upsert one row per user") in
-- favor of the append-per-user reading (matches the array column's own shape), so
-- get_contact_count() counts DISTINCT contacting users, not total taps.
-- ---------------------------------------------------------------------------------------------
create table public.business_contacted (
  id                 uuid primary key default extensions.gen_random_uuid(),
  created_at         timestamptz not null default now(),
  community_id       int8 default 1, -- vestigial compat column, no FK; see file header
  business_page_id   uuid not null references public.business_page (id) on delete cascade,
  contacted_user     uuid not null references public."user" (id) on delete cascade,
  last_contact_link  text[] not null default '{}',
  unique (business_page_id, contacted_user)
);

comment on table public.business_contacted is
  'One row per (business_page, contacting user); last_contact_link channels appended over time. Writes via update_contacted() RPC only. SELECT: business owner or platform admin.';

create index business_contacted_business_page_id_idx on public.business_contacted (business_page_id);
create index business_contacted_contacted_user_idx on public.business_contacted (contacted_user);

alter table public.business_contacted enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

commit;

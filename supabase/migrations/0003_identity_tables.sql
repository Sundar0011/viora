-- 0003_identity_tables.sql
-- Purpose: create the auth/identity foundation tables — "user", user_roles,
-- public_user_profile, user_login, user_devices, user_locations — plus the new audit_log table
-- required by CLAUDE.md §6.5 for every SECURITY DEFINER action. Columns/types/nullability match
-- docs/database/01-tables-auth-identity.md exactly, which matches the locked frontend Row
-- classes under lib/backend/supabase/database/tables/ (verified against user.dart,
-- user_roles.dart, public_user_profile.dart, user_login.dart, user_devices.dart,
-- user_locations.dart).
--
-- RLS: ENABLE ROW LEVEL SECURITY on every table below, but NO POLICIES are added in this file.
-- Until policies are applied, every table is effectively deny-all to anon/authenticated (only
-- superuser/table-owner or SECURITY DEFINER functions can read/write). The reviewed policy set
-- lives in docs/rls-policies-draft.md pending user sign-off, per CLAUDE.md §6.9 — apply only
-- after that review, in a separate migration.
--
-- community_id: kept as a vestigial compat column (int8, default 1, nullable, NO FK) only on
-- user_roles and public_user_profile, per docs/decisions.md (2026-07-19, "Remove community
-- concept") — the only two identity tables whose frontend Row class actually has the column.

begin;

-- ---------------------------------------------------------------------------------------------
-- "user" — private/PII core identity, 1:1 with auth.users. "user" is a reserved word: every
-- reference in raw SQL must be double-quoted.
-- ---------------------------------------------------------------------------------------------
create table public."user" (
  id                     uuid primary key references auth.users (id) on delete cascade,
  created_at             timestamptz not null default now(),
  first_name             text,
  last_name              text,
  email                  text,
  mobile_number          text,
  mobile_number_cc       text,
  address                text,
  city                   text,
  flat                   text,
  postal_code            text,
  blocked                boolean,
  onboarding_completed   boolean default false,
  is_deleted             boolean default false,
  reason                 text,
  "IsOwner"              boolean, -- quirk: PascalCase, kept verbatim (frontend: getField<bool>('IsOwner'))
  last_signin_at         timestamptz,
  status                 text, -- lifecycle text; only 'removed' confirmed, full set unconfirmed (see 10-open-decisions.md)
  updated_at             timestamptz
);

comment on table public."user" is
  'Private/PII core identity, 1:1 with auth.users. Owner-only access — see docs/rls-policies-draft.md.';

create index user_email_idx on public."user" (email);
create index user_mobile_number_cc_idx on public."user" (mobile_number_cc);
create index user_is_deleted_idx on public."user" (is_deleted);

alter table public."user" enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied (CLAUDE.md §6.9).

-- ---------------------------------------------------------------------------------------------
-- user_roles — exactly one role per user; source of the JWT app_metadata.role claim.
-- ---------------------------------------------------------------------------------------------
create table public.user_roles (
  id            uuid primary key references public."user" (id) on delete cascade,
  created_at    timestamptz not null default now(),
  role          public.app_role not null default 'customer',
  community_id  int8 default 1 -- vestigial compat column, no FK; see file header
);

comment on table public.user_roles is
  'Exactly one role per user; JWT role claim source. Client-writable only via signup_finalize RPC.';

create index user_roles_role_idx on public.user_roles (role);

alter table public.user_roles enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied (CLAUDE.md §6.9).

-- ---------------------------------------------------------------------------------------------
-- public_user_profile — publicly-readable profile + denormalized counters. The app's PRIMARY
-- read surface for profile/display data (see docs/decisions.md, Identity Table RLS).
-- ---------------------------------------------------------------------------------------------
create table public.public_user_profile (
  id                uuid primary key references public."user" (id) on delete cascade,
  created_at        timestamptz not null default now(),
  name              text,
  profile_picture   text,
  city              text,
  last_seen_date    timestamptz,
  community_id      int8 default 1, -- vestigial compat column, no FK; see file header
  country           text,
  followers         int8 not null default 0, -- maintained by trigger on follows (later batch)
  following         int8 not null default 0, -- maintained by trigger on follows (later batch)
  logout_time       time,
  cover_image       text,
  bio               text,
  gender            text,
  pronouns          text,
  post_count        int8 not null default 0, -- maintained by trigger on post (later batch)
  group_count       int8 not null default 0, -- maintained by trigger on group_members (later batch)
  event_count       int8 not null default 0, -- maintained by trigger on event_page/event_attending (later batch)
  sale_count        int8 not null default 0, -- maintained by trigger on sale (later batch)
  updated_at        timestamptz
);

comment on table public.public_user_profile is
  'Public-facing profile + counters. Readable by any authenticated user; owner-only writes via RPC.';

-- Trigram index for name search (get_search_all_data / tag_search) — pg_trgm is enabled in the
-- migration batch that first needs it; TODO(confirm): enable pg_trgm here if search RPCs land
-- before that batch, otherwise this index is created alongside pg_trgm later.
create index public_user_profile_name_idx on public.public_user_profile (name);

alter table public.public_user_profile enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied (CLAUDE.md §6.9).

-- ---------------------------------------------------------------------------------------------
-- user_login — OTP store / rate-limit ledger. Edge-function-owned (service_role), no client
-- access at all. Not user-keyed (pre-signup OTPs have no user yet) — no FK to "user".
-- ---------------------------------------------------------------------------------------------
create table public.user_login (
  id                    uuid primary key default extensions.gen_random_uuid(),
  created_at            timestamptz not null default now(),
  mobile_no_cc          text,
  email                 text,
  otp                   text not null,
  expiry_date           timestamptz not null,
  no_of_times           numeric not null,
  last_requested_date   timestamptz not null
);

comment on table public.user_login is
  'OTP store / rate-limit ledger. service_role only — no anon/authenticated access at all.';

create index user_login_email_idx on public.user_login (email);
create index user_login_mobile_no_cc_idx on public.user_login (mobile_no_cc);
create index user_login_expiry_date_idx on public.user_login (expiry_date);

alter table public.user_login enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied (CLAUDE.md §6.9).

-- ---------------------------------------------------------------------------------------------
-- user_devices — one row per (user, device) push-token registration. FCM only per
-- docs/decisions.md (2026-07-19): no OneSignal player_id column.
-- ---------------------------------------------------------------------------------------------
create table public.user_devices (
  id           uuid primary key default extensions.gen_random_uuid(),
  created_at   timestamptz not null default now(),
  user_id      uuid not null references public."user" (id) on delete cascade,
  device_id    text not null,
  fcm_token    text not null,
  constraint user_devices_user_id_device_id_key unique (user_id, device_id)
);

comment on table public.user_devices is
  'One row per (user, device) FCM push-token registration. Owner-only, writes via RPC only.';

create index user_devices_user_id_idx on public.user_devices (user_id);

alter table public.user_devices enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied (CLAUDE.md §6.9).

-- ---------------------------------------------------------------------------------------------
-- user_locations — one saved home-location point per user. id doubles as the owner FK
-- (id = "user".id), per docs/decisions.md (2026-07-19, "Saved location").
-- ---------------------------------------------------------------------------------------------
create table public.user_locations (
  id           uuid primary key references public."user" (id) on delete cascade,
  created_at   timestamptz not null default now(),
  location     extensions.geography(Point, 4326) not null,
  place        text,
  name         text,
  latitude     float8,
  longitude    float8
);

comment on table public.user_locations is
  'One home-location point per user. Owner-only SELECT; writes only via update_user_location RPC.';

create index user_locations_location_gix on public.user_locations using gist (location);

alter table public.user_locations enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied (CLAUDE.md §6.9).

-- ---------------------------------------------------------------------------------------------
-- audit_log — NEW, required by CLAUDE.md §6.5. Append-only trail for every sensitive
-- SECURITY DEFINER action. Not present in any frontend Row class (admin-only, no UI impact).
-- ---------------------------------------------------------------------------------------------
create table public.audit_log (
  id            uuid primary key default extensions.gen_random_uuid(),
  created_at    timestamptz not null default now(),
  actor_id      uuid references public."user" (id) on delete set null,
  action        text not null,
  target_table  text not null,
  target_id     uuid,
  details       jsonb
);

comment on table public.audit_log is
  'Append-only audit trail for sensitive SECURITY DEFINER actions. Admin-only SELECT, server-side INSERT only.';

create index audit_log_actor_id_idx on public.audit_log (actor_id);
create index audit_log_action_idx on public.audit_log (action);
create index audit_log_created_at_idx on public.audit_log (created_at desc);

alter table public.audit_log enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied (CLAUDE.md §6.9).

commit;

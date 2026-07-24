-- 0004_identity_functions.sql
-- Purpose: identity-layer functions —
--   (a) public.is_admin() — STABLE SECURITY INVOKER role-check helper for RLS (CLAUDE.md §6.8),
--       reads the JWT app_metadata claim, never a per-row table lookup.
--   (b) public.custom_access_token_hook(event jsonb) — Postgres Auth Hook (CLAUDE.md §6.7):
--       injects user_roles.role into app_metadata.role on every token issue/refresh.
--   (c) public.signup_finalize(...) — SECURITY DEFINER RPC that creates the "user" /
--       public_user_profile / user_roles rows for the just-created auth.uid(), always forcing
--       role = 'customer' (docs/decisions.md 2026-07-19), replacing the client's direct inserts.
--   (d) public.trigger_set_updated_at() — generic BEFORE UPDATE trigger, applied to "user" and
--       public_user_profile (the only two identity tables with an updated_at column).
--
-- Every SECURITY DEFINER function below follows CLAUDE.md §6.5 in full: validates auth.uid()
-- inside the function body, pins search_path = public, pg_temp, REVOKEs EXECUTE from PUBLIC and
-- GRANTs only to the narrowest role that legitimately calls it, and writes to audit_log where
-- the action is auditable.

begin;

-- ---------------------------------------------------------------------------------------------
-- (a) is_admin() — RLS helper. STABLE + SECURITY INVOKER (runs with caller's own privileges;
-- reads only the caller's own JWT, never another user's row) so it is always safe to expose.
-- Callers must wrap it as (select public.is_admin()) in RLS policies (CLAUDE.md §6.8) so the
-- planner evaluates it once per query, not once per row.
-- ---------------------------------------------------------------------------------------------
create or replace function public.is_admin()
returns boolean
language sql
stable
security invoker
set search_path = public, pg_temp
as $$
  select coalesce(
    (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin',
    false
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

-- ---------------------------------------------------------------------------------------------
-- (b) custom_access_token_hook — Auth Hook, invoked by GoTrue on every token issue/refresh.
-- MUST be SECURITY DEFINER (GoTrue calls it as supabase_auth_admin, which has no direct grant on
-- public.user_roles); runs as the function owner, which bypasses RLS on user_roles by default
-- (table owner is never subject to its own RLS policies unless FORCE ROW LEVEL SECURITY is set,
-- which is intentionally not set on user_roles). search_path is pinned to prevent a
-- search-path-hijack of `public.user_roles`.
-- ---------------------------------------------------------------------------------------------
create or replace function public.custom_access_token_hook(event jsonb)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  claims     jsonb;
  v_user_id  uuid;
  v_role     public.app_role;
begin
  v_user_id := (event ->> 'user_id')::uuid;

  select role into v_role
  from public.user_roles
  where id = v_user_id;

  claims := coalesce(event -> 'claims', '{}'::jsonb);

  if v_role is not null then
    claims := jsonb_set(
      claims,
      '{app_metadata,role}',
      to_jsonb(v_role::text),
      true
    );
  end if;

  event := jsonb_set(event, '{claims}', claims);
  return event;
end;
$$;

comment on function public.custom_access_token_hook(jsonb) is
  'Postgres Auth Hook: injects user_roles.role into app_metadata.role on every token issue/refresh.';

-- Auth Hooks are called exclusively by the supabase_auth_admin role — grant execution only to
-- it, and explicitly revoke from every client-facing role so it can never be called directly.
grant usage on schema public to supabase_auth_admin;
grant execute on function public.custom_access_token_hook(jsonb) to supabase_auth_admin;
revoke execute on function public.custom_access_token_hook(jsonb) from authenticated, anon, public;

-- Defense-in-depth (function already bypasses RLS as SECURITY DEFINER/table owner): explicit
-- read grant for supabase_auth_admin on the one table the hook queries, and an explicit revoke
-- from client-facing roles so the table is never reachable outside this function or admin/RPC
-- paths.
grant select on public.user_roles to supabase_auth_admin;
revoke all on public.user_roles from authenticated, anon, public;

-- ---------------------------------------------------------------------------------------------
-- (c) signup_finalize — replaces the locked frontend's direct client inserts into "user",
-- public_user_profile, and user_roles. SECURITY DEFINER because the target tables are
-- deny-all-by-default (no client INSERT policy exists or will exist for user_roles).
--
-- TODO(confirm): the exact argument list/order is not specified anywhere in
-- docs/database/09-rpc-inventory.md ("profile fields + first location" is the only description).
-- This signature covers every "user" column the frontend Row class actually populates at signup
-- (first_name/last_name/email/mobile_number/mobile_number_cc/address/city/flat/postal_code).
-- The "first location" part of the description is deliberately NOT included here — writing
-- user_locations is left to the existing update_user_location RPC (docs/database/09-rpc-
-- inventory.md §1) called as a separate step, to avoid guessing a combined signature. Confirm
-- with the actual signup flow (or Operture reference) whether signup_finalize should also accept
-- lat/lon/place and insert user_locations in the same transaction.
-- ---------------------------------------------------------------------------------------------
create or replace function public.signup_finalize(
  p_first_name        text,
  p_last_name         text,
  p_email             text default null,
  p_mobile_number     text default null,
  p_mobile_number_cc  text default null,
  p_address           text default null,
  p_city              text default null,
  p_flat              text default null,
  p_postal_code       text default null
)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid   uuid;
  v_name  text;
begin
  -- Never trust a client-supplied id — the row belongs to whoever is authenticated right now.
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'signup_finalize: no authenticated user';
  end if;

  if exists (select 1 from public."user" where id = v_uid) then
    raise exception 'signup_finalize: identity already finalized for this user';
  end if;

  insert into public."user" (
    id, first_name, last_name, email, mobile_number, mobile_number_cc,
    address, city, flat, postal_code, onboarding_completed, is_deleted
  )
  values (
    v_uid, p_first_name, p_last_name, p_email, p_mobile_number, p_mobile_number_cc,
    p_address, p_city, p_flat, p_postal_code, false, false
  );

  v_name := nullif(trim(both ' ' from coalesce(p_first_name, '') || ' ' || coalesce(p_last_name, '')), '');

  insert into public.public_user_profile (id, name, city, community_id)
  values (v_uid, v_name, p_city, 1);

  -- Always 'customer', regardless of any client-sent role value (docs/decisions.md 2026-07-19).
  insert into public.user_roles (id, role, community_id)
  values (v_uid, 'customer', 1);

  insert into public.audit_log (actor_id, action, target_table, target_id, details)
  values (
    v_uid,
    'signup_finalize',
    'user',
    v_uid,
    jsonb_build_object('email', p_email)
  );

  return v_uid;
end;
$$;

comment on function public.signup_finalize(text, text, text, text, text, text, text, text, text) is
  'SECURITY DEFINER: creates "user" / public_user_profile / user_roles for auth.uid() at signup. Always forces role=customer.';

revoke all on function public.signup_finalize(
  text, text, text, text, text, text, text, text, text
) from public;
grant execute on function public.signup_finalize(
  text, text, text, text, text, text, text, text, text
) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- (d) trigger_set_updated_at — generic BEFORE UPDATE trigger. SECURITY INVOKER (default; no
-- privilege escalation needed for a same-row column set), search_path pinned defensively.
-- ---------------------------------------------------------------------------------------------
create or replace function public.trigger_set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists set_updated_at on public."user";
create trigger set_updated_at
  before update on public."user"
  for each row
  execute function public.trigger_set_updated_at();

drop trigger if exists set_updated_at on public.public_user_profile;
create trigger set_updated_at
  before update on public.public_user_profile
  for each row
  execute function public.trigger_set_updated_at();

commit;

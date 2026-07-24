-- 0006_identity_rls.sql
-- RLS policies for the Batch 1 identity tables. Reviewed in docs/rls-policies-draft.md and
-- approved 2026-07-19 with two stakeholder choices baked in:
--   • Admins MAY read the private "user" row (PII) — admin SELECT policy added.
--   • Counter columns on public_user_profile are LOCKED now via column-level REVOKE so clients
--     cannot fabricate their own counts; only triggers (SECURITY DEFINER, later batch) change them.
--
-- Deferred (documented, not shipped broken): hiding soft-deleted users' public profiles. The
-- draft's NOT EXISTS check against "user" cannot work because "user" is owner-only RLS (the
-- subquery can't see other users' rows). Proper deleted-profile hiding is implemented in the
-- Profile/Account batch alongside the delete_account flow. For now public_user_profile is readable
-- by any authenticated user (Decision 0c).
--
-- Every helper call is wrapped (select ...) so the planner evaluates it once per query (§6.8).

begin;

-- ============================ "user" — owner-only + admin read ============================
create policy "user_select_own"
  on public."user" for select to authenticated
  using ( id = (select auth.uid()) );

-- Admins may read any private row (moderation/support). Stakeholder decision 2026-07-19.
create policy "user_select_admin"
  on public."user" for select to authenticated
  using ( (select public.is_admin()) );

create policy "user_update_own"
  on public."user" for update to authenticated
  using ( id = (select auth.uid()) )
  with check ( id = (select auth.uid()) );
-- No INSERT policy: rows created only by signup_finalize() (runs as owner, bypasses RLS).
-- No DELETE policy: accounts are soft-deleted via RPC, never hard-deleted by a client.
-- No admin UPDATE policy: admin moderation writes go through a validated SECURITY DEFINER RPC.

-- ============================ user_roles — own + admin read, no client writes ============
create policy "user_roles_select_own"
  on public.user_roles for select to authenticated
  using ( id = (select auth.uid()) );

create policy "user_roles_select_admin"
  on public.user_roles for select to authenticated
  using ( (select public.is_admin()) );
-- No write policies: writes only via signup_finalize() / future admin assign_role() RPC.

-- ============================ public_user_profile — public read, owner write =============
-- Intentional public-read surface (Decision 0c): any authenticated user may read any profile.
-- `true` is deliberate here (this table IS the public profile surface), not an accidental open.
create policy "public_user_profile_select_authenticated"
  on public.public_user_profile for select to authenticated
  using ( true );

create policy "public_user_profile_insert_own"
  on public.public_user_profile for insert to authenticated
  with check ( id = (select auth.uid()) );

create policy "public_user_profile_update_own"
  on public.public_user_profile for update to authenticated
  using ( id = (select auth.uid()) )
  with check ( id = (select auth.uid()) );

-- Lock the trigger-maintained counter columns: clients can update their own profile row, but NOT
-- these columns. Only SECURITY DEFINER counter triggers (later batch) may write them.
revoke update (followers, following, post_count, group_count, event_count, sale_count)
  on public.public_user_profile from authenticated, anon;

-- ============================ user_login — no client policy (deny-all) ===================
-- Intentionally empty: service_role (edge functions) has BYPASSRLS; no anon/authenticated access.

-- ============================ user_devices — owner read, RPC writes ======================
create policy "user_devices_select_own"
  on public.user_devices for select to authenticated
  using ( user_id = (select auth.uid()) );
-- No write policies: registration/refresh only via upsert_user_device_fcm() RPC.

-- ============================ user_locations — owner-only ================================
create policy "user_locations_select_own"
  on public.user_locations for select to authenticated
  using ( id = (select auth.uid()) );
-- No write policies: writes only via update_user_location() RPC (builds the point server-side).

-- ============================ audit_log — admin read only, append-only ===================
create policy "audit_log_select_admin"
  on public.audit_log for select to authenticated
  using ( (select public.is_admin()) );
-- No INSERT/UPDATE/DELETE policy for any client role: rows written only by SECURITY DEFINER
-- functions (owner, bypasses RLS). Append-only by construction.

commit;
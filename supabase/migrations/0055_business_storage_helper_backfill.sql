-- 0055_business_storage_helper_backfill.sql
-- Purpose: now that business_page/business_promote exist (0054), replace the Batch-5 forward-compat
-- stubs `is_business_page_owner`/`is_business_promote_owner` (0052_storage_rls.sql), which used
-- dynamic SQL + an `undefined_table` exception guard because neither table existed yet. Same
-- backfill pattern as 0021_follows_backfill_view_access.sql / 0042_event_backfill_invite_helper.sql:
-- a DIRECT static query, `create or replace` with the IDENTICAL signature so every existing
-- grant / dependent storage policy (0052) keeps working unchanged.
--
-- Column-name verification (per this task's explicit instruction):
--   - is_business_page_owner(p_business_page_id, p_user_id): the 0052 stub assumed
--     `business_page.admin_user`. CONFIRMED — 0054_business_tables.sql creates business_page with
--     an `admin_user` column (the page owner). No change needed to the predicate shape.
--   - is_business_promote_owner(p_business_page_id, p_user_id): the 0052 stub assumed
--     `business_promote.business_page_id` + `business_promote.admin_user`. CONFIRMED — 0054 creates
--     business_promote with both columns exactly as assumed (admin_user = the submitter/owner, NOT
--     a platform admin). No change needed to the predicate shape.
-- Both stubs' assumed column names matched the real schema exactly — this backfill only removes the
-- dynamic-SQL/exception-guard wrapper, it does not change the query logic.
--
-- Grants are re-asserted exactly as applied in 0052: internal 2-arg form revoked from all client
-- roles (public, anon, authenticated); _self 1-arg wrapper form revoked from public/anon, granted to
-- authenticated (the only form storage RLS policies may call).

begin;

-- ---------------------------------------------------------------------------------------------
-- is_business_page_owner — true if p_user_id is the admin_user (owner) of business_page
-- p_business_page_id. No longer forward-compat-guarded — business_page is a real table (0054).
-- ---------------------------------------------------------------------------------------------
create or replace function public.is_business_page_owner(p_business_page_id uuid, p_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1 from public.business_page bp
    where bp.id = p_business_page_id and bp.admin_user = p_user_id
  );
$$;

comment on function public.is_business_page_owner(uuid, uuid) is
  'True if p_user_id owns business_page p_business_page_id. Direct query — business_page now exists (0054). Internal helper.';

revoke all on function public.is_business_page_owner(uuid, uuid) from public, anon, authenticated;

-- is_business_page_owner_self(uuid) already exists (0052) as a thin wrapper calling the internal
-- form above with auth.uid() — its body is unaffected by this backfill (no create-or-replace
-- needed), but re-assert its grants defensively so this migration is self-contained.
revoke all on function public.is_business_page_owner_self(uuid) from public, anon;
grant execute on function public.is_business_page_owner_self(uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- is_business_promote_owner — true if p_user_id is the admin_user (submitter/owner, NOT a
-- platform admin) of the business_promote row for p_business_page_id. No longer forward-compat-
-- guarded — business_promote is a real table (0054). Matches the UNIQUE (business_page_id,
-- admin_user) constraint (0054) — at most one qualifying row per pair.
-- ---------------------------------------------------------------------------------------------
create or replace function public.is_business_promote_owner(p_business_page_id uuid, p_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1 from public.business_promote bpr
    where bpr.business_page_id = p_business_page_id and bpr.admin_user = p_user_id
  );
$$;

comment on function public.is_business_promote_owner(uuid, uuid) is
  'True if p_user_id owns the business_promote row for p_business_page_id. Direct query — business_promote now exists (0054). Internal helper.';

revoke all on function public.is_business_promote_owner(uuid, uuid) from public, anon, authenticated;

revoke all on function public.is_business_promote_owner_self(uuid) from public, anon;
grant execute on function public.is_business_promote_owner_self(uuid) to authenticated;

commit;

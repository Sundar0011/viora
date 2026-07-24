-- 0005_fix_function_grants.sql
-- Purpose: close two SECURITY DEFINER API-exposure warnings from `get_advisors` (security).
--
-- 1. signup_finalize — 0004 granted it to `authenticated` and revoked from `public`, but Supabase's
--    default privileges also grant EXECUTE to `anon` explicitly, which `revoke ... from public`
--    does not remove. It's not exploitable (the body raises on `auth.uid() is null`), but a signup
--    finalizer has no business being anon-callable. Revoke it from anon.
-- 2. rls_auto_enable() — a pre-existing event-trigger function (owner: postgres, NOT created by
--    Viora migrations) that auto-enables RLS on new public tables. It's useful and kept, but it is
--    an event-trigger function that must never be reachable via /rest/v1/rpc. Event triggers fire
--    independently of EXECUTE grants, so revoking from client roles closes the API exposure without
--    disabling the auto-RLS behavior.

begin;

revoke execute on function public.signup_finalize(
  text, text, text, text, text, text, text, text, text
) from anon;

revoke execute on function public.rls_auto_enable() from anon, authenticated, public;

commit;
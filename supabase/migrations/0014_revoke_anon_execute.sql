-- 0014_revoke_anon_execute.sql
-- Purpose: close the `anon_security_definer_function_executable` advisor warnings (23 of them
-- after Batch 2). Supabase's default privileges grant EXECUTE on new public functions to BOTH
-- anon and authenticated explicitly, so the per-function `revoke ... from public` does not remove
-- the anon grant. Viora has NO legitimately anon-callable RPC — signup happens post-auth via
-- signup_finalize (authenticated), OTP/reset via service_role edge functions — so every public
-- function should be authenticated-only (or narrower). This blanket-revokes EXECUTE from anon on
-- all current public functions. It does NOT touch grants to authenticated or supabase_auth_admin,
-- so the auth hook and all authenticated RPCs keep working. Idempotent (revoking a non-grant is a
-- no-op). Future batches inherit the same default grant, so re-run/extend this per batch.

begin;

do $$
declare
  r record;
begin
  for r in
    select p.oid::regprocedure as sig
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
  loop
    execute format('revoke execute on function %s from anon', r.sig);
  end loop;
end;
$$;

commit;
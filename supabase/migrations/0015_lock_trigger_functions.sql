-- 0015_lock_trigger_functions.sql
-- Purpose: trigger functions are invoked by the trigger mechanism, never as RPCs, and need NO
-- execute grant to fire. But Supabase's default privileges still grant EXECUTE on them to
-- anon/authenticated, which (for the SECURITY DEFINER counter trigger trg_recompute_profile_post_count)
-- shows up as an `anon/authenticated_security_definer_function_executable` advisor warning and
-- needlessly exposes them via /rest/v1/rpc. Revoke EXECUTE from every client role on all
-- trigger-returning functions in public. Triggers keep firing normally.

begin;

do $$
declare
  r record;
begin
  for r in
    select p.oid::regprocedure as sig
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    join pg_type t on t.oid = p.prorettype
    where n.nspname = 'public'
      and t.typname = 'trigger'
  loop
    execute format('revoke execute on function %s from public, anon, authenticated', r.sig);
  end loop;
end;
$$;

commit;
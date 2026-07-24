-- 0084_revoke_anon_execute_batch7.sql
-- Re-run the anon lockdown (see 0014) AND the trigger-function client lockdown (see 0015) so
-- Batch 7's new public functions (search/moderation/notification helpers, read/write/admin RPCs,
-- every new trigger function, and notify()) aren't anon-callable or REST-exposed. Supabase
-- default-grants EXECUTE to anon/authenticated on new functions; both blanket loops are idempotent
-- and safe to re-run (matches 0022/0033/0049/0066 exactly).
begin;

do $$
declare r record;
begin
  for r in
    select p.oid::regprocedure as sig
    from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
  loop
    execute format('revoke execute on function %s from anon', r.sig);
  end loop;
end;
$$;

do $$
declare r record;
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

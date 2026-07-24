-- 0022_revoke_anon_execute_batch3.sql
-- Re-run the anon lockdown (see 0014) so Batch 3's new public functions (user_follow, get_followers,
-- get_following, get_followers_nearby, get_following_users_not_attending_event) aren't anon-callable
-- via /rest/v1/rpc. Supabase default-grants EXECUTE to anon on new functions; revoke it. Idempotent.
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
commit;

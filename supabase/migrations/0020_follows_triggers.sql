-- 0020_follows_triggers.sql
-- Purpose: Batch 3 counter triggers — follows insert/delete recomputes BOTH affected users'
-- public_user_profile.followers/.following (self-healing denormalized counts, per
-- docs/decisions.md 2026-07-19 "Denormalized counters ... maintained by DB TRIGGERS").
--
-- Per docs/database/08-triggers-counters.md §1 and the APPLIED 0013_post_triggers.sql precedent
-- (trg_recompute_profile_post_count, which also writes the locked post_count column): SECURITY
-- DEFINER is NOT required for trigger functions — they run with the privileges of the TABLE
-- OWNER regardless of INVOKER/DEFINER on the function, so the column-level
-- `revoke update (followers, following) ... from authenticated, anon` (0006_identity_rls.sql)
-- does not block the owner-run trigger. Plain SECURITY INVOKER is used here to match that
-- established convention exactly; search_path is still pinned defensively.
--
-- Trigger functions are never called as RPCs — EXECUTE is revoked from every client role below
-- (matching 0015_lock_trigger_functions.sql's rationale) so they aren't exposed via /rest/v1/rpc.

begin;

-- ---------------------------------------------------------------------------------------------
-- follows -> public_user_profile.followers (on following_id) and .following (on follower_id).
-- Recomputes BOTH affected users on insert/delete (a row touches two different profiles, unlike
-- the single-user post/like/comment counters).
-- ---------------------------------------------------------------------------------------------
-- SECURITY DEFINER (consistent with trg_recompute_profile_post_count as applied): writes the
-- column-locked public_user_profile.followers/.following, so it runs as owner. Client execute is
-- revoked below, so it's never REST-callable.
create or replace function public.trg_recompute_follow_counts()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_follower_id  uuid := coalesce(new.follower_id, old.follower_id);
  v_following_id uuid := coalesce(new.following_id, old.following_id);
begin
  update public.public_user_profile
  set following = (select count(*) from public.follows where follower_id = v_follower_id)
  where id = v_follower_id;

  update public.public_user_profile
  set followers = (select count(*) from public.follows where following_id = v_following_id)
  where id = v_following_id;

  return coalesce(new, old);
end;
$$;

drop trigger if exists follows_recompute_counts on public.follows;
create trigger follows_recompute_counts
  after insert or delete on public.follows
  for each row
  execute function public.trg_recompute_follow_counts();

revoke all on function public.trg_recompute_follow_counts() from public, anon, authenticated;

commit;

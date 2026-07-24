-- 0032_group_triggers.sql
-- Purpose: Batch 4 (Groups) counter triggers — self-healing denormalized counts, per
-- docs/decisions.md (2026-07-19, "Denormalized counters ... maintained by DB TRIGGERS"). Fires on
-- group_members insert/delete/update-of-is_approved and recomputes BOTH:
--   (a) "group".total_members (approved members of that group)
--   (b) public_user_profile.group_count (groups that user is an approved member of)
--
-- Per docs/database/08-triggers-counters.md §1 and the APPLIED 0013_post_triggers.sql /
-- 0020_follows_triggers.sql precedent: writing public_user_profile.group_count (a column-locked
-- counter, per 0006_identity_rls.sql's `revoke update (... group_count ...) from authenticated`)
-- requires SECURITY DEFINER so the trigger runs as table owner regardless of the triggering DML
-- path's own privileges. group.total_members has no such column-level lock (the group table has
-- no owner-write RLS policy at all — writes are 100% RPC-only, see 0034_group_rls.sql), but
-- SECURITY DEFINER is used for both here for consistency with the established pattern.
--
-- Trigger functions are never called as RPCs — EXECUTE is revoked from every client role below
-- (matching 0015_lock_trigger_functions.sql / 0020_follows_triggers.sql), so they aren't exposed
-- via /rest/v1/rpc.

begin;

-- ---------------------------------------------------------------------------------------------
-- group_members -> "group".total_members and public_user_profile.group_count. A single
-- insert/delete/update touches exactly one group and one user, so only that pair is recomputed
-- (unlike follows, which touches two different users per row).
-- ---------------------------------------------------------------------------------------------
create or replace function public.trg_recompute_group_member_counts()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_group_id uuid := coalesce(new.group_id, old.group_id);
  v_user_id  uuid := coalesce(new.user_id, old.user_id);
begin
  update public."group"
  set total_members = (
    select count(*) from public.group_members where group_id = v_group_id and coalesce(is_approved, false)
  )
  where id = v_group_id;

  update public.public_user_profile
  set group_count = (
    select count(*) from public.group_members where user_id = v_user_id and coalesce(is_approved, false)
  )
  where id = v_user_id;

  -- Cross-user edge case: if user_id somehow changes on UPDATE (not expected by any RPC above,
  -- but defensive, matches 0013's trg_recompute_profile_post_count precedent), also recompute the
  -- old owner's count.
  if tg_op = 'UPDATE' and old.user_id is distinct from new.user_id then
    update public.public_user_profile
    set group_count = (
      select count(*) from public.group_members where user_id = old.user_id and coalesce(is_approved, false)
    )
    where id = old.user_id;
  end if;

  return coalesce(new, old);
end;
$$;

drop trigger if exists group_members_recompute_counts on public.group_members;
create trigger group_members_recompute_counts
  after insert or delete or update of is_approved, user_id, group_id on public.group_members
  for each row
  execute function public.trg_recompute_group_member_counts();

revoke all on function public.trg_recompute_group_member_counts() from public, anon, authenticated;

commit;

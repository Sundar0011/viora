-- 0018_follows_functions_toggle.sql
-- Purpose: Batch 3 — user_follow() toggle RPC. Split out from a single "0018_follows_functions.sql"
-- to respect CLAUDE.md §5's 400-line-per-file cap (read RPCs + nearby + event-invite helper live
-- in 0019_follows_functions_reads.sql) — see backend-dev playbook lesson dated 2026-07-19 for the
-- Batch 2 precedent of this same split.
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5: validates auth.uid() inside, pins
-- search_path = public, pg_temp, REVOKEs EXECUTE from PUBLIC, GRANTs only to authenticated.

begin;

-- ---------------------------------------------------------------------------------------------
-- user_follow — toggle a follows row (p_followerid is IGNORED and forced to auth.uid(); never
-- trust the caller-supplied value, per CLAUDE.md §6.5). Self-follow is rejected (also enforced at
-- the DB level by follows_no_self_follow). p_communityid kept as a compat arg only (unused), per
-- docs/decisions.md (2026-07-19, "Remove community concept"). Counters (public_user_profile
-- followers/following) are maintained by triggers, not here — see 0020_follows_triggers.sql.
-- Not audited: a normal social toggle, not an admin/sensitive action (matches add_like() in
-- 0011_post_functions_engagement.sql, which is the same shape of toggle RPC).
-- ---------------------------------------------------------------------------------------------
create or replace function public.user_follow(
  p_followingid  uuid,
  p_communityid  int8 default null, -- compat arg only, unused
  p_followerid   uuid default null  -- IGNORED; forced to auth.uid() below
)
returns boolean
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid        uuid := auth.uid();
  v_following  boolean;
begin
  if v_uid is null then
    raise exception 'user_follow: no authenticated user';
  end if;

  if p_followingid is null then
    raise exception 'user_follow: p_followingid is required';
  end if;

  if v_uid = p_followingid then
    raise exception 'user_follow: cannot follow yourself';
  end if;

  -- Target user must exist and not be soft-deleted (defensive; FK alone would still allow
  -- following a soft-deleted-but-not-yet-purged account).
  if not exists (
    select 1 from public."user" where id = p_followingid and coalesce(is_deleted, false) = false
  ) then
    raise exception 'user_follow: target user not found';
  end if;

  if exists (
    select 1 from public.follows where follower_id = v_uid and following_id = p_followingid
  ) then
    delete from public.follows where follower_id = v_uid and following_id = p_followingid;
    v_following := false;
  else
    insert into public.follows (follower_id, following_id) values (v_uid, p_followingid);
    v_following := true;
  end if;

  return v_following;
end;
$$;

comment on function public.user_follow(uuid, int8, uuid) is
  'SECURITY DEFINER: toggles a follows row for auth.uid() -> p_followingid. p_followerid ignored (forced to auth.uid()); p_communityid unused (compat). Counters maintained by trigger.';

revoke all on function public.user_follow(uuid, int8, uuid) from public;
grant execute on function public.user_follow(uuid, int8, uuid) to authenticated;

commit;

-- 0042_event_backfill_invite_helper.sql
-- Purpose: now that `event_attending` exists (0036_event_tables.sql), replace the Batch-3 forward-
-- compat stub `get_following_users_not_attending_event` (0019_follows_functions_reads.sql), which
-- used dynamic SQL + an `undefined_table` exception guard because `event_attending` didn't exist
-- yet. Same backfill pattern as 0021_follows_backfill_view_access.sql's replacement of
-- can_view_post()'s friends-check stub: a DIRECT static query, `create or replace` with the
-- IDENTICAL signature so every existing grant / dependent call site keeps working unchanged.
--
-- Column names used below (event_id, attending_id, is_attending) match 0036_event_tables.sql
-- exactly, closing the 0019 file's own TODO(confirm) about assumed column names.
--
-- Grants are re-asserted exactly as applied in 0019: revoked from public; granted to
-- authenticated (0019 did not explicitly revoke from anon — the blanket anon lockdown in 0022
-- handled that, and 0046_revoke_anon_execute_batch5.sql re-runs the same blanket lockdown for this
-- batch's own new functions).

begin;

-- ---------------------------------------------------------------------------------------------
-- get_following_users_not_attending_event (GetFollowingUsersCall) — event-invite helper: users
-- the caller follows who are not (yet) attending p_event_id. Block-filtered (two-way), keyset-
-- paginated. No longer forward-compat-guarded — event_attending is a real table as of this batch.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_following_users_not_attending_event(
  p_event_id          uuid,
  p_limit             int4 default 50,
  p_after_created_at  timestamptz default null,
  p_after_id          uuid default null
)
returns table (user_id uuid, name text, profile_picture text, city text)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'get_following_users_not_attending_event: no authenticated user';
  end if;

  return query
  select prof.id, prof.name, prof.profile_picture, prof.city
  from public.follows f
  join public.public_user_profile prof on prof.id = f.following_id
  where f.follower_id = v_uid
    and not public.is_blocked_pair(v_uid, prof.id)
    and not exists (
      select 1 from public.event_attending ea
      where ea.event_id = p_event_id and ea.attending_id = prof.id and ea.is_attending = true
    )
    and (
      p_after_created_at is null
      or (f.created_at, f.id) < (p_after_created_at, p_after_id)
    )
  order by f.created_at desc, f.id desc
  limit least(greatest(p_limit, 1), 200);
end;
$$;

comment on function public.get_following_users_not_attending_event(uuid, int4, timestamptz, uuid) is
  'Users auth.uid() follows, not attending p_event_id, block-filtered. Direct query — event_attending now exists (0036).';

revoke all on function public.get_following_users_not_attending_event(uuid, int4, timestamptz, uuid) from public;
grant execute on function public.get_following_users_not_attending_event(uuid, int4, timestamptz, uuid) to authenticated;

commit;

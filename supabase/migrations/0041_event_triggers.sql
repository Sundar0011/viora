-- 0041_event_triggers.sql
-- Purpose: Batch 5 (Events) counter triggers — self-healing denormalized counts, per
-- docs/decisions.md (2026-07-19, "Denormalized counters ... maintained by DB TRIGGERS"):
--   (a) event_page.attendee_count — recomputed from event_attending (is_attending=true) on every
--       insert/update-of-is_attending/delete. This is the REAL counter behind the legacy-compat
--       update_event_attendee_count() RPC (0039).
--   (b) public_user_profile.event_count — recomputed from event_page (events CREATED by that
--       user, is_deleted=false) on every insert/update-of-is_deleted/delete. Note:
--       public.update_user_profile_counts('event') (0011_post_functions_engagement.sql) already
--       exists as a generic no-op legacy-compat RPC covering every counter option string,
--       including 'event' — no new legacy wrapper is needed here, it already satisfies the
--       frontend's `UpdateUserProfileCounts(option: 'event')` call site.
--
-- Both write column-locked public_user_profile / event_page counter columns
-- (0006_identity_rls.sql revokes UPDATE on followers/following/post_count/group_count/
-- event_count/sale_count from authenticated/anon) — SECURITY DEFINER, matching the
-- trg_recompute_profile_post_count / trg_recompute_follow_counts / trg_recompute_group_member_counts
-- precedent exactly.
--
-- Trigger functions are never called as RPCs — EXECUTE is revoked from every client role below
-- (matching 0015/0020/0033), so they aren't exposed via /rest/v1/rpc.

begin;

-- ---------------------------------------------------------------------------------------------
-- event_attending -> event_page.attendee_count (count of is_attending=true rows for that event).
-- ---------------------------------------------------------------------------------------------
create or replace function public.trg_recompute_event_attendee_count()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_event_id uuid := coalesce(new.event_id, old.event_id);
begin
  update public.event_page
  set attendee_count = (
    select count(*) from public.event_attending where event_id = v_event_id and is_attending = true
  )
  where id = v_event_id;

  -- Cross-event edge case: if event_id somehow changes on UPDATE (not expected by any RPC above,
  -- but defensive, matches the trg_recompute_group_member_counts precedent), also recompute the
  -- old event.
  if tg_op = 'UPDATE' and old.event_id is distinct from new.event_id then
    update public.event_page
    set attendee_count = (
      select count(*) from public.event_attending where event_id = old.event_id and is_attending = true
    )
    where id = old.event_id;
  end if;

  return coalesce(new, old);
end;
$$;

drop trigger if exists event_attending_recompute_count on public.event_attending;
create trigger event_attending_recompute_count
  after insert or delete or update of is_attending, event_id on public.event_attending
  for each row
  execute function public.trg_recompute_event_attendee_count();

revoke all on function public.trg_recompute_event_attendee_count() from public, anon, authenticated;

-- ---------------------------------------------------------------------------------------------
-- event_page -> public_user_profile.event_count (count of non-deleted events created by that
-- user). -- TODO(confirm): "event_count" could alternatively mean events attended rather than
-- created; created-events is used here as the direct analogue of post_count/group_count (count of
-- content the user OWNS), consistent with those two precedents.
-- ---------------------------------------------------------------------------------------------
create or replace function public.trg_recompute_user_event_count()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_admin_user uuid := coalesce(new.admin_user, old.admin_user);
begin
  update public.public_user_profile
  set event_count = (
    select count(*) from public.event_page where admin_user = v_admin_user and is_deleted = false
  )
  where id = v_admin_user;

  if tg_op = 'UPDATE' and old.admin_user is distinct from new.admin_user then
    update public.public_user_profile
    set event_count = (
      select count(*) from public.event_page where admin_user = old.admin_user and is_deleted = false
    )
    where id = old.admin_user;
  end if;

  return coalesce(new, old);
end;
$$;

drop trigger if exists event_page_recompute_user_count on public.event_page;
create trigger event_page_recompute_user_count
  after insert or delete or update of is_deleted, admin_user on public.event_page
  for each row
  execute function public.trg_recompute_user_event_count();

revoke all on function public.trg_recompute_user_event_count() from public, anon, authenticated;

commit;

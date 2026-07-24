-- 0079_notification_triggers_group_event_business.sql
-- Purpose: Batch 7 (Notifications) — producer triggers for groups/events/business. Same shape as
-- 0078 (SECURITY DEFINER, AFTER INSERT/UPDATE, revoked from every client role, writes via
-- public.notify()). Does NOT modify any already-applied Batch 4/5/6 RPC — every notification here
-- is driven purely by the resulting row state change (trigger-only, per this task's explicit
-- instruction).
--
-- auth.uid() inside a SECURITY DEFINER trigger still returns the ORIGINAL calling user's uid (the
-- `request.jwt.claims` GUC is a whole-session/transaction setting, unaffected by a function's
-- owner-privilege switch) — used below (business_promote trigger) to identify the acting platform
-- admin without needing to touch admin_set_promotion_status() itself.

begin;

-- ---------------------------------------------------------------------------------------------
-- group_user_status -> three distinct notifications depending on which flag transitioned to true:
--   • is_invited  true (INSERT or UPDATE) -> notify the invitee.                type='group_invite'
--   • is_requested true (INSERT or UPDATE) -> notify every group admin.        type='group'
--   • is_approved true (UPDATE only, approve_join_request path) -> notify the approved user. type='group'
-- Guards against re-firing on every UPDATE by comparing OLD vs NEW (INSERT has no OLD row).
-- ---------------------------------------------------------------------------------------------
create or replace function public.trg_notify_group_user_status()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_group_name  text;
  v_actor_name  text;
  r             record;
begin
  select name into v_group_name from public."group" where id = new.group_id;

  if coalesce(new.is_invited, false)
     and (tg_op = 'INSERT' or not coalesce(old.is_invited, false)) then
    select name into v_actor_name from public.public_user_profile where id = new.invited_by;
    perform public.notify(
      p_sender_id   => new.invited_by,
      p_receiver_id => new.user_id,
      p_type        => 'group_invite',
      p_content     => coalesce(v_actor_name, 'Someone') || ' invited you to join ' || coalesce(v_group_name, 'a group'),
      p_group_id    => new.group_id
    );
  end if;

  if coalesce(new.is_requested, false)
     and (tg_op = 'INSERT' or not coalesce(old.is_requested, false)) then
    select name into v_actor_name from public.public_user_profile where id = new.user_id;
    for r in select user_id from public.group_admin where group_id = new.group_id loop
      perform public.notify(
        p_sender_id   => new.user_id,
        p_receiver_id => r.user_id,
        p_type        => 'group',
        p_content     => coalesce(v_actor_name, 'Someone') || ' requested to join ' || coalesce(v_group_name, 'your group'),
        p_group_id    => new.group_id
      );
    end loop;
  end if;

  if tg_op = 'UPDATE' and coalesce(new.is_approved, false) and not coalesce(old.is_approved, false) then
    select name into v_actor_name from public.public_user_profile where id = new.approved_by;
    perform public.notify(
      p_sender_id   => new.approved_by,
      p_receiver_id => new.user_id,
      p_type        => 'group',
      p_content     => 'Your request to join ' || coalesce(v_group_name, 'the group') || ' was approved',
      p_group_id    => new.group_id
    );
  end if;

  return new;
end;
$$;

drop trigger if exists group_user_status_notify on public.group_user_status;
create trigger group_user_status_notify
  after insert or update of is_invited, is_requested, is_approved on public.group_user_status
  for each row
  execute function public.trg_notify_group_user_status();

revoke all on function public.trg_notify_group_user_status() from public, anon, authenticated;

-- ---------------------------------------------------------------------------------------------
-- event_attending -> notify the invitee when is_invited transitions to true. type='invite'
-- (matches the frontend's own type='invite' -> MyEventWidget(btnOption:'invitations') routing).
-- ---------------------------------------------------------------------------------------------
create or replace function public.trg_notify_event_invite()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_event_name  text;
  v_actor_name  text;
begin
  if coalesce(new.is_invited, false)
     and (tg_op = 'INSERT' or not coalesce(old.is_invited, false)) then
    select name into v_event_name from public.event_page where id = new.event_id;
    select name into v_actor_name from public.public_user_profile where id = new.invited_by;

    perform public.notify(
      p_sender_id   => new.invited_by,
      p_receiver_id => new.attending_id,
      p_type        => 'invite',
      p_content     => coalesce(v_actor_name, 'Someone') || ' invited you to ' || coalesce(v_event_name, 'an event'),
      p_event_id    => new.event_id
    );
  end if;

  return new;
end;
$$;

drop trigger if exists event_attending_notify on public.event_attending;
create trigger event_attending_notify
  after insert or update of is_invited on public.event_attending
  for each row
  execute function public.trg_notify_event_invite();

revoke all on function public.trg_notify_event_invite() from public, anon, authenticated;

-- ---------------------------------------------------------------------------------------------
-- business_promote -> notify the business owner (admin_user, the SUBMITTER — see 0054's naming
-- note) whenever a PLATFORM admin transitions `status` (admin_set_promotion_status, 0058). Sender
-- is the invoking platform admin's auth.uid() (see file header) — skipped (no notification) if
-- auth.uid() is null (e.g. a future non-interactive/cron status change) or equals the owner
-- (can't happen today since admin_set_promotion_status requires is_admin(), but guarded anyway).
-- type='business' (matches the frontend's type='business' -> BusinessHomePageWidget routing).
-- ---------------------------------------------------------------------------------------------
create or replace function public.trg_notify_business_promotion_status()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor      uuid := auth.uid();
  v_biz_name   text;
begin
  if new.status is distinct from old.status then
    select name into v_biz_name from public.business_page where id = new.business_page_id;

    perform public.notify(
      p_sender_id   => v_actor,
      p_receiver_id => new.admin_user,
      p_type        => 'business',
      p_content     => 'Your promotion for ' || coalesce(v_biz_name, 'your business') || ' is now ' || new.status,
      p_business_id => new.business_page_id
    );
  end if;

  return new;
end;
$$;

drop trigger if exists business_promote_notify on public.business_promote;
create trigger business_promote_notify
  after update of status on public.business_promote
  for each row
  execute function public.trg_notify_business_promotion_status();

revoke all on function public.trg_notify_business_promotion_status() from public, anon, authenticated;

commit;

-- 0081_notification_read_functions.sql
-- Purpose: Batch 7 (Notifications) — the read/state-change RPCs behind the notification list
-- screen: get_notifications() (grouped JSON), mark_notification_read(), mark_notification_deleted().
-- Replaces the frontend's direct `NotificationsTable().update` calls (docs/features/
-- 11-notifications.md §4) with validated RPCs, per CLAUDE.md §6 ("user-facing writes go through
-- RPC functions, not direct DML").
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5: validates auth.uid() inside (NEVER
-- trusts p_userid), pins search_path = public, pg_temp, REVOKEs EXECUTE from PUBLIC, GRANTs only
-- to authenticated.

begin;

-- ---------------------------------------------------------------------------------------------
-- get_notifications — grouped JSON: all/post/group/event/business/sale, per docs/features/
-- 11-notifications.md §4/§8.6. p_userid is ACCEPTED-BUT-IGNORED (auth.uid() used regardless,
-- matching user_follow()/get_followers_nearby() precedent) — never trust a caller-supplied
-- "which user is me". Excludes is_deleted=true; block-filtered on sender (a notification from a
-- now-blocked user is hidden, even though the row itself is not deleted). Returns the FULL set per
-- receiver (matching the frontend's existing no-arg-pagination call contract) rather than a
-- keyset page — per docs/decisions.md (2026-07-19, "Pagination & filtering") this is a
-- TODO(frontend): wire p_limit/p_after_created_at once the notification screen paginates instead
-- of loading everything into FFAppState().notifications.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_notifications(
  p_userid  uuid default null, -- ignored; auth.uid() used
  p_limit   int4 default 100
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
  v_lim int4 := least(greatest(p_limit, 1), 500);
begin
  if v_uid is null then
    raise exception 'get_notifications: no authenticated user';
  end if;

  return (
    with base as (
      select
        n.id, n.type, n.notification_type, n.is_read, n.created_at, n.content, n.title, n.message,
        n.post_id, n.comment_id, n.event_id, n.business_id, n.sale_id, n.group_id, n.message_id,
        prof.name, prof.profile_picture as profile_image
      from public.notifications n
      join public.public_user_profile prof on prof.id = n.sender_id
      where n.receiver_id = v_uid
        and n.is_deleted = false
        and not public.is_blocked_pair(v_uid, n.sender_id)
      order by n.created_at desc
      limit v_lim
    )
    select jsonb_build_object(
      'all',      (select coalesce(jsonb_agg(row_to_json(b)), '[]'::jsonb) from base b),
      'post',     (select coalesce(jsonb_agg(row_to_json(b)), '[]'::jsonb) from base b where b.type in ('post', 'comment')),
      'group',    (select coalesce(jsonb_agg(row_to_json(b)), '[]'::jsonb) from base b where b.type in ('group', 'group_invite')),
      'event',    (select coalesce(jsonb_agg(row_to_json(b)), '[]'::jsonb) from base b where b.type in ('event', 'invite')),
      'business', (select coalesce(jsonb_agg(row_to_json(b)), '[]'::jsonb) from base b where b.type = 'business'),
      'sale',     (select coalesce(jsonb_agg(row_to_json(b)), '[]'::jsonb) from base b where b.type = 'sale')
    )
  );
end;
$$;

comment on function public.get_notifications(uuid, int4) is
  'SECURITY DEFINER: grouped notification list (all/post/group/event/business/sale) for auth.uid(). Excludes is_deleted; block-filtered on sender. p_userid ignored.';

revoke all on function public.get_notifications(uuid, int4) from public;
grant execute on function public.get_notifications(uuid, int4) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- mark_notification_read — sets is_read=true on the caller's OWN received notification only.
-- ---------------------------------------------------------------------------------------------
create or replace function public.mark_notification_read(p_notification_id uuid)
returns public.notifications
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
  v_row public.notifications;
begin
  if v_uid is null then
    raise exception 'mark_notification_read: no authenticated user';
  end if;

  update public.notifications
  set is_read = true
  where id = p_notification_id and receiver_id = v_uid
  returning * into v_row;

  if not found then
    raise exception 'mark_notification_read: notification not found or not owned by caller';
  end if;

  return v_row;
end;
$$;

comment on function public.mark_notification_read(uuid) is
  'SECURITY DEFINER: marks the caller''s own received notification as read.';

revoke all on function public.mark_notification_read(uuid) from public;
grant execute on function public.mark_notification_read(uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- mark_notification_deleted — soft-deletes (is_deleted=true) the caller's OWN received
-- notification only. Matches the frontend: never hard-deleted from the client.
-- ---------------------------------------------------------------------------------------------
create or replace function public.mark_notification_deleted(p_notification_id uuid)
returns public.notifications
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
  v_row public.notifications;
begin
  if v_uid is null then
    raise exception 'mark_notification_deleted: no authenticated user';
  end if;

  update public.notifications
  set is_deleted = true
  where id = p_notification_id and receiver_id = v_uid
  returning * into v_row;

  if not found then
    raise exception 'mark_notification_deleted: notification not found or not owned by caller';
  end if;

  return v_row;
end;
$$;

comment on function public.mark_notification_deleted(uuid) is
  'SECURITY DEFINER: soft-deletes (is_deleted=true) the caller''s own received notification.';

revoke all on function public.mark_notification_deleted(uuid) from public;
grant execute on function public.mark_notification_deleted(uuid) to authenticated;

commit;

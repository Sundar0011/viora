-- 0077_notify_helper_device_rpc.sql
-- Purpose: Batch 7 (Notifications) —
--   (a) public.notify(...) — the ONE internal insert path into `notifications`. Every producer
--       trigger in this batch (0078/0079) and the reports mail trigger (0080) calls this, never
--       INSERTs into `notifications` directly, so the "never notify self" / "block-aware" /
--       "receiver must exist" rules live in exactly one place.
--   (b) public.upsert_user_device_fcm(p_device_id, p_fcm_token) — referenced by the frontend since
--       Batch 1 (docs/database/09-rpc-inventory.md §1) but never created until now. FCM only per
--       docs/decisions.md (2026-07-19, "Push notifications") — upsert_user_device()
--       (OneSignal player_id) is DELIBERATELY NOT built; `user_devices` has no player_id column
--       (same decision).
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5: validates auth.uid() inside, pins
-- search_path = public, pg_temp, REVOKEs EXECUTE from PUBLIC, GRANTs only to authenticated
-- (notify() is internal-only — locked from ALL client roles, called only by other SECURITY
-- DEFINER functions/triggers, matching the is_blocked_pair/can_view_post precedent).

begin;

-- ---------------------------------------------------------------------------------------------
-- notify — internal helper: inserts one notifications row, unless the receiver is null, the
-- receiver IS the sender (never notify yourself), or the two users are in a two-way block
-- relationship (public.is_blocked_pair, 0009). Returns the new row's id, or NULL if suppressed.
-- Does NOT call the push edge function directly — a separate AFTER INSERT trigger on
-- `notifications` (0082) fires the push/realtime side-effects, keeping this helper a pure,
-- synchronous DB write.
-- ---------------------------------------------------------------------------------------------
create or replace function public.notify(
  p_sender_id    uuid,
  p_receiver_id  uuid,
  p_type         text,
  p_content      text,
  p_title        text default null,
  p_message      text default null,
  p_post_id      uuid default null,
  p_comment_id   uuid default null,
  p_event_id     uuid default null,
  p_business_id  uuid default null,
  p_sale_id      uuid default null,
  p_group_id     uuid default null,
  p_message_id   uuid default null
)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_id uuid;
begin
  if p_receiver_id is null or p_sender_id is null or p_sender_id = p_receiver_id then
    return null; -- never notify yourself; a missing receiver is a no-op, not an error
  end if;

  if public.is_blocked_pair(p_sender_id, p_receiver_id) then
    return null; -- two-way block suppresses the notification entirely
  end if;

  insert into public.notifications (
    sender_id, receiver_id, type, content, title, message,
    post_id, comment_id, event_id, business_id, sale_id, group_id, message_id
  )
  values (
    p_sender_id, p_receiver_id, p_type, p_content, p_title, p_message,
    p_post_id, p_comment_id, p_event_id, p_business_id, p_sale_id, p_group_id, p_message_id
  )
  returning id into v_id;

  return v_id;
end;
$$;

comment on function public.notify(uuid, uuid, text, text, text, text, uuid, uuid, uuid, uuid, uuid, uuid, uuid) is
  'Internal helper: the ONLY insert path into notifications. Never-notify-self + two-way-block-aware. Called only by producer triggers (0078/0079) and the reports mail trigger (0080), never directly by clients.';

revoke all on function public.notify(uuid, uuid, text, text, text, text, uuid, uuid, uuid, uuid, uuid, uuid, uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------------------------------
-- upsert_user_device_fcm — registers/refreshes the caller's FCM push token for one device.
-- Upsert on (user_id, device_id) — matches the UNIQUE constraint already on user_devices (0003).
-- ---------------------------------------------------------------------------------------------
create or replace function public.upsert_user_device_fcm(
  p_device_id  text,
  p_fcm_token  text
)
returns public.user_devices
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
  v_row public.user_devices;
begin
  if v_uid is null then
    raise exception 'upsert_user_device_fcm: no authenticated user';
  end if;
  if p_device_id is null or btrim(p_device_id) = '' then
    raise exception 'upsert_user_device_fcm: device_id is required';
  end if;
  if p_fcm_token is null or btrim(p_fcm_token) = '' then
    raise exception 'upsert_user_device_fcm: fcm_token is required';
  end if;

  insert into public.user_devices (user_id, device_id, fcm_token)
  values (v_uid, p_device_id, p_fcm_token)
  on conflict (user_id, device_id) do update
    set fcm_token = excluded.fcm_token
  returning * into v_row;

  return v_row;
end;
$$;

comment on function public.upsert_user_device_fcm(text, text) is
  'SECURITY DEFINER: upserts the caller''s FCM push token for one device, on (user_id, device_id).';

revoke all on function public.upsert_user_device_fcm(text, text) from public;
grant execute on function public.upsert_user_device_fcm(text, text) to authenticated;

commit;

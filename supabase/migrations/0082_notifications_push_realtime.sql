-- 0082_notifications_push_realtime.sql
--
-- ⚠️ APPLY NOTE (matches the 0064_chat_realtime.sql precedent): the `create policy ... on
-- realtime.messages` below CANNOT be applied by the Supabase MCP (its role is `postgres`, which is
-- NOT a member/owner of `supabase_realtime_admin`, the owner of realtime.messages). Apply that ONE
-- policy via `supabase db push` (CLI) or the Dashboard; everything else in this file (the function
-- + both triggers) applies cleanly via MCP. Until the policy is applied, private notification-badge
-- subscriptions are denied, but notifications still work fully via get_notifications()/
-- mark_notification_read()/mark_notification_deleted() (0081) — this file only adds the OPTIONAL
-- live-refresh signal.
--
-- Purpose: Batch 7 (Notifications) — two independent AFTER INSERT triggers on `notifications`:
--   (a) trg_broadcast_new_notification — OPTIONAL private Broadcast to `user:{uid}:notifications`
--       (per docs/features/11-notifications.md §6's recommendation and CLAUDE.md §6), so the
--       badge/list can update live instead of polling-by-refetch (the frontend's current
--       behavior, kept as the fallback).
--   (b) trg_push_new_notification — calls the `send-notification` Edge Function (this batch's
--       `supabase/functions/send-notification/index.ts`) via pg_net (`net.http_post`), which looks
--       up the receiver's `user_devices.fcm_token`s and sends the push through Firebase Cloud
--       Messaging. Wrapped in an exception guard so a missing/misconfigured pg_net extension or
--       unset server settings NEVER fails the notification INSERT itself — push delivery is
--       best-effort, in-app delivery (the row itself) is not.
--
-- ⚠️ SUPERSEDED (2026-07-19): the GUC approach below (`app.settings.edge_function_url` +
-- `app.settings.service_role_key`) is NOT usable on hosted Supabase — `alter database ... set`
-- is superuser-only (permission denied even in the SQL editor). `0087_push_trigger_vault.sql`
-- replaces `trg_push_new_notification` with a version that reads the service-role key from
-- Supabase Vault and hardcodes the (non-secret) function URL. Ignore GUC step 2 below; do the
-- Vault `create_secret` call from 0087 instead. (pg_net step 1 still applies and is done.)
--
-- REQUIRED MANUAL SETUP (documented here + in the final task summary, NOT done by this migration):
--   1. Enable the `pg_net` extension (attempted below, `create extension if not exists pg_net`;
--      some Supabase plans require enabling it via Dashboard > Database > Extensions instead of
--      SQL — if the `create extension` below errors, do it there first, then re-run this file).
--   2. Set two server-level custom GUCs so the trigger knows where/how to call the Edge Function
--      (Dashboard > Project Settings > Database > Custom Postgres config, OR
--      `alter database postgres set app.settings.edge_function_url = '...'`):
--        app.settings.edge_function_url   = 'https://<project-ref>.supabase.co/functions/v1/send-notification'
--        app.settings.service_role_key    = '<service_role_key>' (server-side secret; NEVER the anon key, NEVER in client code)
--   3. Deploy `supabase/functions/send-notification/index.ts` and set its OWN secrets
--      (`FCM_SERVICE_ACCOUNT_JSON`) via `supabase secrets set` — see that file's header for detail.

begin;

-- pg_net conventionally lives in its own `net` schema (Supabase's own docs/hosted default use
-- `net.http_post`, not `extensions.http_post`) — create that schema first so `with schema net`
-- succeeds even on a project where pg_net isn't already pre-installed.
create schema if not exists net;
create extension if not exists pg_net with schema net;

-- ---------------------------------------------------------------------------------------------
-- (a) Private Broadcast: `user:{uid}:notifications`. RLS below gates SUBSCRIBE (receive) only —
-- no INSERT (client-side send) policy, matching the chat precedent (0064) exactly: every
-- broadcast event originates server-side from this trigger, which runs as its SECURITY DEFINER
-- owner and bypasses the receive-only policy (that policy only gates the SUBSCRIBER, not this
-- publish path).
-- ---------------------------------------------------------------------------------------------
create or replace function public.trg_broadcast_new_notification()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform realtime.send(
    jsonb_build_object(
      'id', new.id,
      'type', new.type,
      'content', new.content,
      'created_at', new.created_at
    ),
    'new_notification',
    'user:' || new.receiver_id::text || ':notifications',
    true
  );

  return new;
end;
$$;

drop trigger if exists notifications_broadcast_new on public.notifications;
create trigger notifications_broadcast_new
  after insert on public.notifications
  for each row
  execute function public.trg_broadcast_new_notification();

revoke all on function public.trg_broadcast_new_notification() from public, anon, authenticated;

create policy "notifications_broadcast_receive_own"
on "realtime"."messages"
for select
to authenticated
using (
  realtime.messages.extension = 'broadcast'
  and (select realtime.topic()) = ('user:' || (select auth.uid())::text || ':notifications')
);

comment on policy "notifications_broadcast_receive_own" on "realtime"."messages" is
  'Private Broadcast authorization: user:{uid}:notifications receivable only by that user. No client-side send (INSERT) policy — server-trigger-only (trg_broadcast_new_notification).';

-- ---------------------------------------------------------------------------------------------
-- (b) Push delivery — best-effort pg_net call to the send-notification Edge Function. Guarded so
-- a missing extension/unset settings can NEVER fail the notifications INSERT (push is best-effort;
-- the in-app row + realtime broadcast above already succeeded by the time this runs).
-- ---------------------------------------------------------------------------------------------
create or replace function public.trg_push_new_notification()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_url  text;
  v_key  text;
begin
  begin
    v_url := current_setting('app.settings.edge_function_url', true);
    v_key := current_setting('app.settings.service_role_key', true);

    if v_url is not null and v_key is not null then
      perform net.http_post(
        url      => v_url,
        headers  => jsonb_build_object('Content-Type', 'application/json', 'Authorization', 'Bearer ' || v_key),
        body     => jsonb_build_object(
          'notification_id', new.id,
          'receiver_id', new.receiver_id,
          'sender_id', new.sender_id,
          'type', new.type,
          'title', new.title,
          'content', new.content
        )
      );
    end if;
  exception when others then
    -- Best-effort: pg_net missing, settings unset, or the Edge Function unreachable must never
    -- fail the notification write itself. -- TODO(confirm): consider logging failures to
    -- audit_log if silent push failures become an operational concern.
    null;
  end;

  return new;
end;
$$;

drop trigger if exists notifications_push_new on public.notifications;
create trigger notifications_push_new
  after insert on public.notifications
  for each row
  execute function public.trg_push_new_notification();

revoke all on function public.trg_push_new_notification() from public, anon, authenticated;

commit;

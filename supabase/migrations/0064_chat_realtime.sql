-- 0064_chat_realtime.sql
--
-- ⚠️ APPLY NOTE (2026-07-19): the `create policy ... on realtime.messages` below CANNOT be applied
-- by the Supabase MCP (its role is `postgres`, which is NOT a member/owner of
-- `supabase_realtime_admin` who owns realtime.messages → "must be owner of relation messages").
-- The function + trigger in this file WERE applied via MCP (migration `0064a_chat_realtime_fn_trigger`).
-- The realtime.messages RECEIVE policy must be applied with an elevated role — via `supabase db push`
-- (CLI, which runs migrations as supabase_admin) OR the Supabase Dashboard. Until it is, PRIVATE
-- channel subscriptions are denied, so clients won't receive live pushes (chat still works fully via
-- the RPCs — send_message/get_chat/mark_messages_read — the trigger still publishes). This file keeps
-- the full desired state so a CLI rebuild-from-zero reproduces it.
--
-- Purpose: Batch 6 (Chat) REALTIME — replaces the current frontend's PUBLIC, UNAUTHORIZED Postgres
-- Changes channels (`public:messages`, `chat_table_realtime`, `chat_users_table_realtime`,
-- `messages_table_realtime`, and a debug `test_messages_channel` — docs/features/
-- 10-chat-messaging.md §6) with PRIVATE, RLS-AUTHORIZED Broadcast, per CLAUDE.md §6 ("All Broadcast
-- channels must be private and authorized with RLS on realtime.messages") and docs/decisions.md
-- (2026-07-19, "Realtime ... secure PRIVATE authorized channels").
--
-- TOPIC NAMING (the exact channels the frontend MUST subscribe to):
--   - `chat:{chat_id}`      — one topic per conversation. New-message events for that thread.
--   - `user:{auth.uid()}:chats` — one topic per user. Lightweight "a chat you're in changed"
--     signal (new message / preview update), used to drive the chat-list screen instead of a
--     public `chat`/`chat_users` Postgres Changes subscription.
--
-- -- TODO(frontend): the app currently subscribes to public unauthorized channels
-- (`public:messages`, `chat_table_realtime`, etc. — see the feature doc §6 citation above). This is
-- the flagged §6 migration: repoint `message_page` to `supabase.channel('chat:' + chatId, {config:
-- {private: true}})` and the chat-list screen to `supabase.channel('user:' + myUid + ':chats',
-- {config: {private: true}})`, both using Broadcast (`.on('broadcast', {event: ...}, cb)`), and
-- remove `test_messages_channel` and the three `init_realtime_chat_updates.dart` Postgres Changes
-- channels entirely.
--
-- AUTHORIZATION MODEL: only a SELECT (receive) policy is granted below — no INSERT (client-side
-- broadcast send) policy exists, so a client can never publish onto another user's topic. ALL
-- broadcast events originate server-side from the trigger below, which calls realtime.send()/
-- realtime.broadcast_changes() as the trigger owner (bypasses RLS, matches every other SECURITY
-- DEFINER trigger in this schema) — this is the officially recommended "Realtime Authorization"
-- pattern (RLS on realtime.messages + (select realtime.topic()) helper), verified against the
-- `supabase` skill's security checklist before writing.

begin;

-- ---------------------------------------------------------------------------------------------
-- is_chat_member_self — self-scoped wrapper (the only chat-membership helper granted to clients),
-- matching the is_event_owner/is_event_owner_self split (0037/0050): the internal is_chat_member()
-- (0060) is revoked from `authenticated`, so the RLS policy below (evaluated as the querying role)
-- cannot call it directly even though it is SECURITY DEFINER — the caller still needs EXECUTE to
-- invoke it at all. Created HERE (ahead of the table-RLS file, 0065) because this policy is its
-- first consumer; 0065's chat_users/chat/messages policies reuse this same wrapper.
-- ---------------------------------------------------------------------------------------------
create or replace function public.is_chat_member_self(p_chat_id uuid)
returns boolean language sql stable security definer
set search_path = public, pg_temp as $$
  select public.is_chat_member(p_chat_id, auth.uid());
$$;
comment on function public.is_chat_member_self(uuid) is
  'Self-scoped is_chat_member(chat, auth.uid()) — the only chat-membership helper granted to clients (for RLS on realtime.messages and on chat/chat_users/messages, 0065).';
revoke all on function public.is_chat_member_self(uuid) from public, anon;
grant execute on function public.is_chat_member_self(uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- realtime.messages RLS — a user may RECEIVE broadcasts on `chat:{chat_id}` only if they are a
-- non-soft-deleted member of that chat, and on `user:{uid}:chats` only for their OWN uid. No
-- policy exists for extension <> 'broadcast' (Presence/Postgres Changes stay deny-all here).
-- ---------------------------------------------------------------------------------------------
create policy "chat_broadcast_receive_authorized"
on "realtime"."messages"
for select
to authenticated
using (
  realtime.messages.extension = 'broadcast'
  and (
    (
      (select realtime.topic()) like 'chat:%'
      and (select public.is_chat_member_self(split_part((select realtime.topic()), ':', 2)::uuid))
    )
    or (select realtime.topic()) = ('user:' || (select auth.uid())::text || ':chats')
  )
);

comment on policy "chat_broadcast_receive_authorized" on "realtime"."messages" is
  'Private Broadcast authorization: chat:{chat_id} receivable only by non-deleted chat_users members; user:{uid}:chats receivable only by that user. No client-side send (INSERT) policy — server-trigger-only.';

-- ---------------------------------------------------------------------------------------------
-- trg_broadcast_new_message — AFTER INSERT on messages. Broadcasts the full new-message payload to
-- the chat's private topic (realtime.broadcast_changes, the officially recommended row-change
-- broadcast helper), then sends a lightweight refresh signal to every member's own
-- user:{uid}:chats topic (realtime.send) so the chat-list screen can re-fetch via get_chat()
-- instead of receiving the message content directly. Both calls run as the trigger owner
-- (SECURITY DEFINER), bypassing the receive-only RLS policy above (that policy only gates
-- SUBSCRIBER access, not this server-side publish path).
-- ---------------------------------------------------------------------------------------------
create or replace function public.trg_broadcast_new_message()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  r record;
begin
  perform realtime.broadcast_changes(
    'chat:' || new.chat_id::text, -- topic
    'INSERT',                     -- event
    tg_op,                        -- operation
    'messages',                   -- table
    'public',                     -- schema
    new,
    null
  );

  for r in
    select cu.user_id
    from public.chat_users cu
    where cu.chat_id = new.chat_id and coalesce(cu.is_deleted, false) = false
  loop
    perform realtime.send(
      jsonb_build_object(
        'chat_id', new.chat_id,
        'last_message', case when new.e_message_type = 'image' then 'image' else new.message end,
        'last_message_date', new.created_at
      ),
      'chat_list_update',
      'user:' || r.user_id::text || ':chats',
      true
    );
  end loop;

  return new;
end;
$$;

drop trigger if exists messages_broadcast_new on public.messages;
create trigger messages_broadcast_new
  after insert on public.messages
  for each row
  execute function public.trg_broadcast_new_message();

revoke all on function public.trg_broadcast_new_message() from public, anon, authenticated;

commit;

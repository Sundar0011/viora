-- 0062_chat_functions_writes.sql
-- Purpose: Batch 6 (Chat) write RPCs — find_common_chat, add_chat_users, soft_delete_chat_users,
-- restore_chat_user, send_message (NEW), mark_messages_read (NEW). Closes the CLAUDE.md §6 direct-
-- client-DML gap on `chat`/`messages` flagged in docs/features/10-chat-messaging.md §7/§8 — ALL
-- writes to chat/chat_users/messages are RPC-only (no client INSERT/UPDATE/DELETE policy, 0065).
--
-- Argument names/order match the EXACT frontend-observed contract (docs/database/09-rpc-inventory.md
-- §10 / docs/features/10-chat-messaging.md §4): find_common_chat(user2) and get_chat(search_query)
-- use bare names (no p_ prefix — literal JSON body keys); add_chat_users/restore_chat_user use the
-- p_-prefixed names the frontend already sends. Required args first, defaulted args last (the
-- arg-order bug fix from Batch 2, re-applied here).
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5.

begin;

-- ---------------------------------------------------------------------------------------------
-- find_common_chat (FindCommonChatCall -> rpc/find_common_chat) — FIND-OR-CREATE the 1:1 'dm'
-- chat between auth.uid() and user2 (per THIS TASK's explicit instruction — a deliberate behavior
-- change from the frontend's literal "search only, then client inserts if not found" flow, which
-- otherwise leaves `chat`/chat_users writes as direct client DML). Block-aware: raises if either
-- user has blocked the other. add_chat_users() remains idempotent so the frontend's existing
-- "if not chat_found, call AddChatUsersCall" branch is a harmless no-op against the row this
-- function already created.
-- ---------------------------------------------------------------------------------------------
create or replace function public.find_common_chat(user2 uuid)
returns table (chat_id uuid, chat_found boolean)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid   uuid := auth.uid();
  v_chat  uuid;
begin
  if v_uid is null then
    raise exception 'find_common_chat: no authenticated user';
  end if;
  if user2 = v_uid then
    raise exception 'find_common_chat: cannot chat with yourself';
  end if;
  if public.is_blocked_pair(v_uid, user2) then
    raise exception 'find_common_chat: blocked';
  end if;

  select c.id into v_chat
  from public.chat c
  join public.chat_users cu1 on cu1.chat_id = c.id and cu1.user_id = v_uid
  join public.chat_users cu2 on cu2.chat_id = c.id and cu2.user_id = user2
  where c.chat_type = 'dm'
  limit 1;

  if found then
    return query select v_chat, true;
    return;
  end if;

  insert into public.chat (community_id, first_message_date, created_by, chat_type)
  values (1, now(), v_uid, 'dm')
  returning id into v_chat;

  insert into public.chat_users (chat_id, user_id, community_id, is_deleted)
  values (v_chat, v_uid, 1, false), (v_chat, user2, 1, false);

  return query select v_chat, false;
end;
$$;

comment on function public.find_common_chat(uuid) is
  'SECURITY DEFINER: find-or-create the 1:1 dm chat between auth.uid() and user2. Block-aware.';

revoke all on function public.find_common_chat(uuid) from public;
grant execute on function public.find_common_chat(uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- add_chat_users (AddChatUsersCall) — EXACT frontend contract: p_chat_id, p_community_id, p_user2
-- (all originally required, no defaults). Adds BOTH auth.uid() and p_user2 as members (idempotent —
-- ON CONFLICT DO NOTHING per member so re-calling after find_common_chat's auto-create is a no-op).
-- Caller must already be the chat's creator or an existing member (cannot add users to an arbitrary
-- chat). p_community_id kept as a compat arg only (unused).
-- ---------------------------------------------------------------------------------------------
create or replace function public.add_chat_users(p_chat_id uuid, p_community_id int8, p_user2 uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'add_chat_users: no authenticated user';
  end if;

  if not exists (select 1 from public.chat where id = p_chat_id) then
    raise exception 'add_chat_users: chat not found';
  end if;

  if not (
    exists (select 1 from public.chat where id = p_chat_id and created_by = v_uid)
    or public.is_chat_member(p_chat_id, v_uid)
  ) then
    raise exception 'add_chat_users: caller is not the chat creator or a member';
  end if;

  if public.is_blocked_pair(v_uid, p_user2) then
    raise exception 'add_chat_users: blocked';
  end if;

  insert into public.chat_users (chat_id, user_id, community_id, is_deleted)
  values (p_chat_id, v_uid, 1, false), (p_chat_id, p_user2, 1, false)
  on conflict (chat_id, user_id) do update set is_deleted = false;
end;
$$;

comment on function public.add_chat_users(uuid, int8, uuid) is
  'SECURITY DEFINER: adds both auth.uid() and p_user2 as chat_users members (idempotent). p_community_id unused (compat).';

revoke all on function public.add_chat_users(uuid, int8, uuid) from public;
grant execute on function public.add_chat_users(uuid, int8, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- soft_delete_chat_users (SoftdeletechatusersCall) — EXACT frontend contract: `user_ids` (bare
-- name, JSON body `{ user_ids: [...] }`), a list of OTHER users' ids. Soft-deletes ONLY auth.uid()'s
-- own chat_users membership for every 'dm' chat shared with each listed user (never the other
-- participant's row).
-- ---------------------------------------------------------------------------------------------
create or replace function public.soft_delete_chat_users(user_ids uuid[])
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'soft_delete_chat_users: no authenticated user';
  end if;

  update public.chat_users cu
  set is_deleted = true, deleted_date = now()
  where cu.user_id = v_uid
    and cu.chat_id in (
      select cu2.chat_id from public.chat_users cu2 where cu2.user_id = any(user_ids)
    );
end;
$$;

comment on function public.soft_delete_chat_users(uuid[]) is
  'SECURITY DEFINER: soft-deletes auth.uid()''s own chat_users rows for chats shared with each listed other-user id.';

revoke all on function public.soft_delete_chat_users(uuid[]) from public;
grant execute on function public.soft_delete_chat_users(uuid[]) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- restore_chat_user (RestoreChatUserCall) — EXACT frontend contract: p_chat_id, p_user_id. Caller
-- must equal p_user_id (self only — cannot restore another user's membership).
-- ---------------------------------------------------------------------------------------------
create or replace function public.restore_chat_user(p_chat_id uuid, p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'restore_chat_user: no authenticated user';
  end if;
  if p_user_id <> v_uid then
    raise exception 'restore_chat_user: caller must equal p_user_id';
  end if;

  update public.chat_users
  set is_deleted = false, deleted_date = null
  where chat_id = p_chat_id and user_id = v_uid;
end;
$$;

comment on function public.restore_chat_user(uuid, uuid) is
  'SECURITY DEFINER: self-only. Clears is_deleted on the caller''s own chat_users membership row.';

revoke all on function public.restore_chat_user(uuid, uuid) from public;
grant execute on function public.restore_chat_user(uuid, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- send_message (NEW, recommended) — validates chat membership + not-blocked, inserts the message.
-- chat.last_message* preview update happens via the AFTER INSERT trigger (0063), NOT inline here,
-- so every insert path (this RPC, or any future one) stays consistent. Realtime broadcast is also
-- trigger-driven (0064) — independent of this RPC's own transaction succeeding.
-- ---------------------------------------------------------------------------------------------
create or replace function public.send_message(
  p_chat_id    uuid,
  p_message    text,
  p_type       public.e_message_type default 'text',
  p_file_url   text default null,
  p_file_type  text default null
)
returns public.messages
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid   uuid := auth.uid();
  v_other uuid;
  v_row   public.messages;
begin
  if v_uid is null then
    raise exception 'send_message: no authenticated user';
  end if;

  if not public.is_chat_member(p_chat_id, v_uid) then
    raise exception 'send_message: caller is not a member of this chat';
  end if;

  select cu.user_id into v_other
  from public.chat_users cu
  where cu.chat_id = p_chat_id and cu.user_id <> v_uid
  limit 1;

  if v_other is not null and public.is_blocked_pair(v_uid, v_other) then
    raise exception 'send_message: blocked';
  end if;

  if exists (select 1 from public.chat where id = p_chat_id and coalesce(is_blocked, false) = true) then
    raise exception 'send_message: chat is blocked';
  end if;

  insert into public.messages (chat_id, sender_id, message, e_message_type, is_read, file_url, file_type, islink)
  values (p_chat_id, v_uid, p_message, p_type, false, p_file_url, p_file_type, false)
  returning * into v_row;

  return v_row;
end;
$$;

comment on function public.send_message(uuid, text, public.e_message_type, text, text) is
  'SECURITY DEFINER: NEW. Validates membership + not-blocked, inserts a message. Preview update + realtime broadcast are trigger-driven.';

revoke all on function public.send_message(uuid, text, public.e_message_type, text, text) from public;
grant execute on function public.send_message(uuid, text, public.e_message_type, text, text) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- mark_messages_read (NEW) — flips is_read=true on the other participant's unread messages in a
-- chat the caller is a member of. Never touches the caller's own sent messages.
-- ---------------------------------------------------------------------------------------------
create or replace function public.mark_messages_read(p_chat_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'mark_messages_read: no authenticated user';
  end if;

  if not public.is_chat_member(p_chat_id, v_uid) then
    raise exception 'mark_messages_read: caller is not a member of this chat';
  end if;

  update public.messages
  set is_read = true
  where chat_id = p_chat_id and sender_id <> v_uid and is_read = false;
end;
$$;

comment on function public.mark_messages_read(uuid) is
  'SECURITY DEFINER: NEW. Marks the other participant''s unread messages read for a chat the caller is a member of.';

revoke all on function public.mark_messages_read(uuid) from public;
grant execute on function public.mark_messages_read(uuid) to authenticated;

commit;

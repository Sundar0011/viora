-- 0063_chat_triggers.sql
-- Purpose: Batch 6 (Chat) preview-field trigger — keeps chat.last_message/last_message_date/
-- last_message_user current on every messages INSERT, replacing the frontend's direct `ChatTable
-- .update` call (docs/features/10-chat-messaging.md §5.B / §7). Image messages store the literal
-- string 'image' as the preview (matches the frontend's own client-side preview text).
--
-- Writes the otherwise RPC-only `chat` table — SECURITY DEFINER, matching the
-- trg_recompute_user_sale_count/trg_recompute_user_event_count precedent (0048/0041). Trigger
-- function is never called as an RPC — EXECUTE revoked from every client role below (matches
-- 0015/0020/0033/0041/0048), so it isn't exposed via /rest/v1/rpc.

begin;

create or replace function public.trg_chat_message_preview()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  update public.chat
  set last_message      = case when new.e_message_type = 'image' then 'image' else new.message end,
      last_message_date = new.created_at,
      last_message_user = new.sender_id
  where id = new.chat_id;

  return new;
end;
$$;

drop trigger if exists messages_update_chat_preview on public.messages;
create trigger messages_update_chat_preview
  after insert on public.messages
  for each row
  execute function public.trg_chat_message_preview();

revoke all on function public.trg_chat_message_preview() from public, anon, authenticated;

commit;

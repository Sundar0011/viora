-- 0061_chat_functions_reads.sql
-- Purpose: Batch 6 (Chat) read RPC — get_chat (GetChatCall -> rpc/get_chat). Split out of the
-- write RPCs (0062) to respect CLAUDE.md §5's 400-line-per-file cap (Batch 2/4/5 precedent).
--
-- get_chat output fields match docs/features/10-chat-messaging.md §4's exact list: chat_id,
-- user_id (other participant), chat_type, profile_picture, name, last_message, last_message_date,
-- unread_message_count, total_dm_chats, total_sale_chats, total_unread_message_count,
-- chat_created_at, first_message_date, last_message_user, is_blocked, blocked_by_user. Returns
-- ONLY the caller's non-deleted chats (chat_users.user_id = auth.uid(), is_deleted = false),
-- two-way-block-filtered against the other participant, filterable by search_query (matches the
-- other participant's name). Pagination args ADDED with DEFAULTs (backward-compatible with the
-- locked frontend's `{ search_query }`-only call). -- TODO(frontend): wire pagination once the
-- chat list screen paginates instead of loading everything into FFAppState().matchedUsers.

begin;

create or replace function public.get_chat(
  search_query                text default null,
  p_limit                     int4 default 30,
  p_after_last_message_date   timestamptz default null,
  p_after_chat_id             uuid default null
)
returns table (
  chat_id                     uuid,
  user_id                     uuid,
  chat_type                   text,
  profile_picture             text,
  name                        text,
  last_message                text,
  last_message_date           timestamptz,
  chat_created_at             timestamptz,
  first_message_date          timestamptz,
  last_message_user           uuid,
  is_blocked                  boolean,
  blocked_by_user             uuid,
  unread_message_count        int8,
  total_dm_chats               int8,
  total_sale_chats             int8,
  total_unread_message_count  int8
)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'get_chat: no authenticated user';
  end if;

  return query
  with my_chats as (
    select c.*
    from public.chat c
    join public.chat_users cu on cu.chat_id = c.id
    where cu.user_id = v_uid and coalesce(cu.is_deleted, false) = false
  ),
  other as (
    select mc.id as chat_id, cu2.user_id as other_user_id
    from my_chats mc
    join public.chat_users cu2 on cu2.chat_id = mc.id and cu2.user_id <> v_uid
  ),
  totals as (
    select
      count(*) filter (where mc.chat_type = 'dm') as total_dm,
      count(*) filter (where mc.chat_type <> 'dm') as total_sale,
      (
        select count(*) from public.messages m
        where m.chat_id in (select id from my_chats) and m.sender_id <> v_uid and m.is_read = false
      ) as total_unread
    from my_chats mc
  )
  select
    mc.id,
    o.other_user_id,
    mc.chat_type,
    prof.profile_picture,
    prof.name,
    mc.last_message,
    mc.last_message_date,
    mc.created_at,
    mc.first_message_date,
    mc.last_message_user,
    mc.is_blocked,
    mc.blocked_by_user,
    (
      select count(*) from public.messages m
      where m.chat_id = mc.id and m.sender_id <> v_uid and m.is_read = false
    ),
    t.total_dm,
    t.total_sale,
    t.total_unread
  from my_chats mc
  join other o on o.chat_id = mc.id
  left join public.public_user_profile prof on prof.id = o.other_user_id
  cross join totals t
  where not public.is_blocked_pair(v_uid, o.other_user_id)
    and (search_query is null or btrim(search_query) = '' or prof.name ilike '%' || search_query || '%')
    and (
      p_after_last_message_date is null
      or (coalesce(mc.last_message_date, mc.created_at), mc.id) < (p_after_last_message_date, p_after_chat_id)
    )
  order by coalesce(mc.last_message_date, mc.created_at) desc, mc.id desc
  limit least(greatest(p_limit, 1), 100);
end;
$$;

comment on function public.get_chat(text, int4, timestamptz, uuid) is
  'Enriched chat-list for auth.uid(): non-deleted chats, block-filtered, paginated. Args added with DEFAULTs for backward compat.';

revoke all on function public.get_chat(text, int4, timestamptz, uuid) from public;
grant execute on function public.get_chat(text, int4, timestamptz, uuid) to authenticated;

commit;

-- 0059_chat_tables.sql
-- Purpose: Batch 6 (Chat & Messaging) tables — chat, chat_users, messages. Columns/types/
-- nullability match docs/database/05-tables-business-chat.md, cross-checked against the locked
-- frontend Row classes (chat.dart, chat_users.dart, messages.dart).
--
-- RLS: ENABLE ROW LEVEL SECURITY on all three tables, NO POLICIES in this file (deny-all to
-- anon/authenticated until reviewed). The proposed policy set lives in docs/rls-policies-draft.md
-- ("Batch 6 — Business & Chat") pending sign-off (CLAUDE.md §6.9).
--
-- community_id: vestigial compat column (int8, nullable, DEFAULT 1, NO FK) on all three tables,
-- per docs/decisions.md (2026-07-19, "Remove community concept") — matches every Row class.
--
-- chat_users has NO separate `id` column — composite PRIMARY KEY (chat_id, user_id), confirmed
-- design choice per docs/database/05-tables-business-chat.md (Row class exposes no id getter).
--
-- All three tables' writes are RPC-only (no client INSERT/UPDATE/DELETE policy anywhere) —
-- find_common_chat/add_chat_users/get_chat/soft_delete_chat_users/restore_chat_user/send_message/
-- mark_messages_read (0061), plus the last-message-preview trigger (0062) and the realtime
-- broadcast trigger (0063), all bypass RLS as SECURITY DEFINER/table-owner.

begin;

-- ---------------------------------------------------------------------------------------------
-- chat — one row per conversation. Denormalized last-message preview fields kept current by a
-- trigger on messages INSERT (0062), NOT by client `.update` (closes the CLAUDE.md §6 direct-DML
-- gap flagged in docs/features/10-chat-messaging.md §7).
-- ---------------------------------------------------------------------------------------------
create table public.chat (
  id                  uuid primary key default extensions.gen_random_uuid(),
  created_at          timestamptz not null default now(),
  community_id        int8 default 1, -- vestigial compat column, no FK; see file header
  last_message        text,
  last_message_date   timestamptz,
  first_message_date  timestamptz,
  last_message_user   uuid references public."user" (id) on delete set null,
  is_blocked          boolean default false,
  blocked_by_user     uuid references public."user" (id) on delete set null,
  created_by          uuid not null references public."user" (id) on delete restrict,
  chat_type           text not null default 'dm' -- 'dm' confirmed; 'sale'/'forsale' TODO(confirm) exact value, see docs/database/05-tables-business-chat.md
);

comment on table public.chat is
  'One row per conversation. last_message*/last_message_user kept current by a trigger on messages INSERT (0062). Writes RPC-only (find_common_chat/add_chat_users).';

create index chat_created_by_idx on public.chat (created_by);
create index chat_chat_type_idx on public.chat (chat_type);
create index chat_last_message_date_idx on public.chat (last_message_date);
create index chat_last_message_user_idx on public.chat (last_message_user);

alter table public.chat enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

-- ---------------------------------------------------------------------------------------------
-- chat_users — membership join table with per-user soft-delete (hide a chat without destroying it
-- for the other participant). Composite PK (chat_id, user_id) — see file header.
-- ---------------------------------------------------------------------------------------------
create table public.chat_users (
  chat_id       uuid not null references public.chat (id) on delete cascade,
  user_id       uuid not null references public."user" (id) on delete cascade,
  community_id  int8 default 1, -- vestigial compat column, no FK; see file header
  created_at    timestamptz not null default now(),
  is_deleted    boolean default false,
  deleted_date  timestamptz,
  primary key (chat_id, user_id)
);

comment on table public.chat_users is
  'Chat membership, composite PK (chat_id, user_id), per-user soft-delete (is_deleted/deleted_date). Writes RPC-only (add_chat_users/soft_delete_chat_users/restore_chat_user).';

create index chat_users_chat_id_idx on public.chat_users (chat_id);
create index chat_users_user_id_idx on public.chat_users (user_id);
create index chat_users_user_id_is_deleted_idx on public.chat_users (user_id, is_deleted);

alter table public.chat_users enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

-- ---------------------------------------------------------------------------------------------
-- messages — individual chat messages (text or image), per-message read state. Highest write
-- volume table in the schema — see docs/database/05-tables-business-chat.md's "High-volume table
-- note" (future range-partitioning by created_at, keyset pagination on (chat_id, created_at, id)).
-- ---------------------------------------------------------------------------------------------
create table public.messages (
  id               uuid primary key default extensions.gen_random_uuid(),
  chat_id          uuid not null references public.chat (id) on delete cascade,
  community_id     int8 default 1, -- vestigial compat column, no FK; see file header
  sender_id        uuid not null references public."user" (id) on delete cascade,
  message          text not null,
  created_at       timestamptz not null default now(),
  e_message_type   public.e_message_type not null default 'text',
  is_read          boolean not null default false,
  file_url         text,
  file_type        text,
  islink           boolean not null default false
);

comment on table public.messages is
  'Individual chat messages. Writes RPC-only (send_message/mark_messages_read); last_message preview + realtime broadcast are trigger-driven (0062/0063).';

create index messages_chat_id_created_at_idx on public.messages (chat_id, created_at);
create index messages_chat_id_sender_id_is_read_idx on public.messages (chat_id, sender_id, is_read);
create index messages_sender_id_idx on public.messages (sender_id);

alter table public.messages enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

commit;

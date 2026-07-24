# Feature: Chat & Messaging

> Source of truth = the Flutter frontend. This doc records what the backend MUST provide
> for this feature to work. Derived from `lib/` — do not invent behavior the code doesn't show.

## 1. Overview
- **What it is:** 1:1 direct messaging between neighbours. A user finds/creates a common chat
  with another user, sends text and image messages, sees a chat list with last-message previews
  and unread counts, and can bulk soft-delete (hide) chats. Messages and chat-list state update
  in realtime.
- **Why it exists / user value:** Private communication layer for the neighborhood network and
  marketplace — lets neighbours talk 1:1 (and, per `chat_type`, sale-related threads).
- **Related features:** user/profile search (`fetchSearchProfilesRealtime` — new-message user
  picker), blocking/reporting (`blocks` table via `comp_manage_access`), notifications
  (OneSignal + FCM, presumed for new-message pushes), communities (`community_id` scoping).

## 2. Screens & widgets
| Screen / widget (path under `lib/`) | Purpose | Key actions |
|---|---|---|
| `chat/chat/chat_widget.dart` | Main chat list (tabs: `all` / `dms` / `forsale`) | Load list via `GetChatCall`; pull-to-refresh; enter select mode; select-all; bulk soft-delete via `SoftdeletechatusersCall`; open a chat |
| `chat/message_page/message_page_widget.dart` | 1:1 conversation thread | Query messages (`MessagesTable.queryRows`); send text (`MessagesTable.insert` + `ChatTable.update`); send image (upload + insert); subscribe/mark-as-read via custom actions |
| `chat/comp_new_message/comp_new_message_widget.dart` | New-message bottom sheet: search users, start chat | `fetchSearchProfilesRealtime` (user search); `FindCommonChatCall`; if found → `RestoreChatUserCall`; else `ChatTable.insert` + `AddChatUsersCall`; navigate to message page |
| `chat/comp_manage_chat/comp_manage_chat_widget.dart` | Chat-list overflow menu | "Select chats" (enter select mode), "New Chat" (open new-message sheet) |
| `chat/comp_manage_access/comp_manage_access_widget.dart` | Per-conversation access menu | Block / Report the other user (reads `blocks` table). No chat-table writes. |
| `chat/archived_chats_page/archived_chats_page_widget.dart` | Archived chats screen | Static/placeholder in current code — no backend calls found. See §8. |

## 3. Data model (tables & columns)
Types/nullability read from the FlutterFlow Row classes under
`lib/backend/supabase/database/tables/`.

### `chat`
- **Purpose:** One row per conversation. Holds denormalized last-message preview fields and
  block state for the chat-list UI.
- **Columns:**
  | Column | Type | Null? | Notes (PK/FK/default/enum) |
  |---|---|---|---|
  | `id` | uuid | no | PK (string in Dart; default `gen_random_uuid()`) |
  | `community_id` | int8/int | no | FK → `community`; always `1` in current inserts |
  | `last_message` | text | yes | denormalized preview of most recent message |
  | `last_message_date` | timestamptz | yes | set on each send |
  | `first_message_date` | timestamptz | yes | set at chat creation (UTC) |
  | `last_message_user` | uuid (text) | yes | sender of last message; FK → `users` |
  | `created_at` | timestamptz | no | default `now()` |
  | `is_blocked` | bool | yes | true when chat is blocked |
  | `blocked_by_user` | uuid (text) | yes | who blocked; FK → `users` |
  | `created_by` | uuid (text) | no | FK → `users`; chat creator |
  | `chat_type` | text | no | enum-like: `'dm'` (created here); `'sale'`/`'forsale'` implied by list tabs & `total_sale_chats` |
- **Foreign keys / relationships:** `community_id`→`community.id`; `created_by`, `last_message_user`,
  `blocked_by_user`→`users.id`. One `chat` has many `messages` and many `chat_users`.
- **Indexes needed:** `community_id`, `created_by`, `chat_type`, `last_message_date` (list ordering),
  `last_message_user`.

### `chat_users`
- **Purpose:** Membership join table — which users belong to a chat. Carries per-user soft-delete
  so a user can hide/leave a chat without destroying it for the other participant.
- **Columns:**
  | Column | Type | Null? | Notes (PK/FK/default/enum) |
  |---|---|---|---|
  | `chat_id` | uuid | no | FK → `chat.id` (part of composite PK — see §8) |
  | `user_id` | uuid | no | FK → `users.id` (part of composite PK — see §8) |
  | `community_id` | int8/int | no | FK → `community`; `1` in current code |
  | `created_at` | timestamptz | no | default `now()` |
  | `is_deleted` | bool | yes | true = chat hidden/soft-deleted for this user |
  | `deleted_date` | timestamptz | yes | when soft-deleted |
- **Foreign keys / relationships:** `chat_id`→`chat.id` (on delete cascade), `user_id`→`users.id`,
  `community_id`→`community.id`. Row class exposes **no `id`** → composite key `(chat_id, user_id)`.
- **Indexes needed:** `chat_id`, `user_id`, composite `(user_id, is_deleted)` (list filtering),
  `community_id`.

### `messages`
- **Purpose:** Individual chat messages (text or image), with per-message read state.
- **Columns:**
  | Column | Type | Null? | Notes (PK/FK/default/enum) |
  |---|---|---|---|
  | `id` | uuid | no | PK (default `gen_random_uuid()`) |
  | `chat_id` | uuid | no | FK → `chat.id` (on delete cascade) |
  | `community_id` | int8/int | no | FK → `community`; `1` in current inserts |
  | `sender_id` | uuid (text) | no | FK → `users.id` |
  | `message` | text | no | text body; `'image'` placeholder for image messages |
  | `created_at` | timestamptz | no | default `now()`; thread ordered ascending by this |
  | `e_message_type` | text | no | enum-like: `'text'`, `'image'` |
  | `is_read` | bool | no | default `false`; set true by mark-as-read |
  | `file_url` | text | yes | image/file URL (Supabase Storage) |
  | `file_type` | text | yes | MIME/type of attachment |
  | `islink` | bool | no | message contains a link (default `false`) |
- **Foreign keys / relationships:** `chat_id`→`chat.id`, `sender_id`→`users.id`,
  `community_id`→`community.id`. Many `messages` per `chat`.
- **Indexes needed:** `chat_id` (thread query), composite `(chat_id, created_at)` (ordered fetch),
  `(chat_id, sender_id, is_read)` (mark-as-read + unread counts), `sender_id`, `community_id`.

## 4. Backend calls (API / RPC / Edge)
Base URL in code: `https://wgcqstmmkcdjnnpuvspr.supabase.co` — this is the OLD project; the rebuild
targets Viora's own project (CLAUDE.md §6). All RPCs are called via PostgREST `/rest/v1/rpc/...`
with `apikey` (anon) + `Authorization: Bearer <jwt>`.

| Call / query | Type | Inputs | Returns | Called from |
|---|---|---|---|---|
| `find_common_chat` (`FindCommonChatCall`) | RPC | body `{ user2 }` (JWT identifies user1) | array; fields `chat_id`, `chat_found` (bool) | `comp_new_message` — before starting a chat |
| `add_chat_users` (`AddChatUsersCall`) | RPC | `p_chat_id`, `p_community_id`, `p_user2` | (success) | `comp_new_message` — after creating a new chat |
| `get_chat` (`GetChatCall`) | RPC | `{ search_query }` (JWT = current user) | enriched chat-list array (see fields below) | `chat_widget` initState + pull-to-refresh |
| `soft_delete_chat_users` (`SoftdeletechatusersCall`) | RPC | `{ user_ids: [...] }` (other-user ids to hide, JWT = current user) | (success) | `chat_widget` — bulk delete in select mode |
| `restore_chat_user` (`RestoreChatUserCall`) | RPC | `p_chat_id`, `p_user_id` | (success) | `comp_new_message` — when a soft-deleted common chat is reopened |
| `messages` thread query | Direct (`MessagesTable.queryRows`) | `chat_id == chatId`, order `created_at` asc | `List<MessagesRow>` | `message_page` `FutureBuilder` |
| Send text message | Direct (`MessagesTable.insert`) | `{chat_id, community_id:1, sender_id, message, e_message_type:'text', is_read:false}` | inserted row | `message_page` text field submit |
| Send image message | Direct (`MessagesTable.insert`) | `{chat_id, sender_id, e_message_type:'image', is_read:false, file_url, community_id:1, message:'image'}` | inserted row | `message_page` image send |
| Update chat preview | Direct (`ChatTable.update`) | set `last_message`, `last_message_date`(UTC), `last_message_user` where `id==chatId` | — | `message_page` after each send |
| Create chat | Direct (`ChatTable.insert`) | `{community_id:1, first_message_date, created_by, chat_type:'dm'}` | inserted `ChatRow` | `comp_new_message` (new chat path) |
| Mark-as-read | Direct (`.from('messages').update`) | set `is_read:true` where `chat_id==` & `sender_id != me` & `is_read==false` | — | `subscribeToMessagesAndMarkAsRead` action |

**`get_chat` output fields consumed by the UI** (must be produced by the RPC):
`chat_id`, `user_id`, `chat_type`, `profile_picture`, `name`, `last_message`, `last_message_date`,
`unread_message_count`, `total_dm_chats`, `total_sale_chats`, `total_unread_message_count`,
plus (referenced by realtime merge logic) `chat_created_at`, `first_message_date`,
`last_message_user`, `is_blocked`, `blocked_by_user`. It returns **only the current user's
non-deleted** chats (join `chat_users` on `user_id = auth.uid()` and `is_deleted` false), enriched
with the other participant's profile and aggregate/unread counters, filterable by `search_query`.

## 5. Business rules & flows

### A. Start / reopen a 1:1 chat (`comp_new_message`)
1. User searches profiles (`fetchSearchProfilesRealtime`) and taps "Message" on a profile.
2. `FindCommonChatCall(user2)` checks whether a chat already exists between current user and `user2`.
3. If `chat_found == true`: call `RestoreChatUserCall(p_chat_id, p_user_id=user2)` (un-deletes the
   membership so a previously hidden chat reappears), then navigate to `message_page` with that `chat_id`.
4. If not found: `ChatTable.insert({community_id:1, first_message_date:now(UTC), created_by:me,
   chat_type:'dm'})`; then `AddChatUsersCall(chat_id, community_id:'1', user2)` to add memberships;
   navigate to `message_page` with the new `chat_id`.
   - **Note:** `add_chat_users` must add BOTH participants (current user + `user2`) to `chat_users`
     — the client only passes `user2`, so the RPC derives the creator from `auth.uid()`.

### B. Send a message (`message_page`)
1. Text: validated by `isMessageValid` custom action; on valid → insert into `messages`
   (`e_message_type:'text'`, `is_read:false`), then update `chat` preview fields.
2. Image: upload to Storage → insert message (`e_message_type:'image'`, `file_url`, `message:'image'`)
   → update `chat` preview (`last_message:'image'`).
3. `community_id` is hardcoded to `1` in the client; `last_message_date` uses `getCurrentUtcTime()`.

### C. Read the thread & mark-as-read (`message_page`)
1. Thread = all `messages` where `chat_id == chatId`, ordered `created_at` ascending.
2. On page load: `subscribeToMessagesAndMarkAsRead(chatId, currentUserId)` opens a
   `.stream()` on `messages` for this chat; whenever the other user's unread messages arrive it
   bulk-updates `is_read = true` for `chat_id == & sender_id != me & is_read == false`.
3. Also `subscribe('messages', refresh)` re-runs the thread query to append new messages and
   auto-scrolls. On dispose: `cancelMessageSubscription(chatId)` cancels the stream.

### D. Chat list (`chat_widget`)
1. Load via `GetChatCall(search_query:' ')` → stored in `FFAppState().matchedUsers`.
2. Tabs `all` / `dms` / `forsale` filter using `total_dm_chats` / `total_sale_chats` counters and
   `chat_type`.
3. Pull-to-refresh re-calls `GetChatCall`.

### E. Soft-delete (hide) chats (`chat_widget` select mode)
1. Enter select mode; "Select all" runs `selectAllUsers()` which collects the `user_id` of each
   listed chat into `FFAppState().userIds`.
2. Delete → `SoftdeletechatusersCall(user_ids)` — passes the list of **other-user ids**; the RPC
   marks the current user's `chat_users` rows (`is_deleted=true`, `deleted_date=now()`) for the
   chats shared with those users. It is a per-user soft-delete, not a hard delete.
3. `restore_chat_user` reverses this for a single `(chat_id, user_id)` when the chat is reopened (flow A.3).

### Ownership / state rules the backend must enforce
- A user may only read/list chats they are a member of (`chat_users` with `is_deleted=false`).
- A user may only send messages in chats they belong to; `sender_id` must equal `auth.uid()`.
- Mark-as-read may only flip `is_read` on messages **not** sent by the caller.
- Soft-delete/restore may only touch the caller's own `chat_users` rows.
- Block state (`is_blocked`/`blocked_by_user`) should stop sends once set (implied; confirm §8).

## 6. Realtime / notifications

### Current frontend implementation (what the code does today)
- **Postgres Changes** everywhere:
  - `message_page`: `subscribe('messages', …)` uses `.channel('public:messages').onPostgresChanges(all, table:'messages')`, and a separate `.from('messages').stream(primaryKey:['id']).eq('chat_id', …)` for mark-as-read.
  - `init_realtime_chat_updates.dart`: three channels — `chat_table_realtime`, `chat_users_table_realtime`, `messages_table_realtime` — each `onPostgresChanges(all)` on `chat` / `chat_users` / `messages`, merging into `FFAppState().matchedUsers` (updates last message, unread counts, removes chats when the current user's membership is deleted or `is_deleted` flips). Also a debug `test_messages_channel`.
- These channels are **public and unauthorized** (`'public:messages'`, `'test_messages_channel'`) and the `.stream()` filters only by `chat_id` — they rely on Postgres Changes respecting RLS, which requires RLS to be correctly configured on `messages`, `chat`, `chat_users`. **This violates CLAUDE.md §6** (channels must be private + authorized; Broadcast preferred for app events).

### Recommendation for the rebuild
- **Use private, authorized Broadcast for the app-event fan-out** (new message arrived, unread-count
  changes, chat-list updates) — CLAUDE.md §6 marks Broadcast as the default for "notifications, live
  counts, chat activity." Emit broadcasts from DB triggers (`realtime.broadcast_changes`) on
  `messages`/`chat` INSERT/UPDATE onto a per-chat topic (e.g. `chat:{chat_id}`) and a per-user
  topic for list/unread updates (e.g. `user:{uid}:chats`).
- **All channels MUST be private and RLS-authorized** via policies on `realtime.messages`: a user may
  only subscribe to `chat:{chat_id}` if they are a non-deleted member of that chat, and only to
  their own `user:{uid}:chats` topic. Never expose message contents to non-members.
- **Justification for Broadcast over Postgres Changes:** the message thread and chat list are
  high-frequency app events, not a case where a raw row-change must directly drive one widget;
  Broadcast scales better, keeps channels private by default, and avoids exposing the WAL/table
  structure. Keep the read-side (thread history, `get_chat`) as normal RLS-gated queries; realtime
  only signals "refresh"/deltas. If Postgres Changes is retained for expediency, it MUST run on
  private authorized channels with RLS enforced on all three tables (no `public:`/test channels).
- **Push notifications:** OneSignal + Firebase Messaging exist in the project (`setup_notifications`,
  `set_f_c_m_token_and_update_database`). A new-message push to the recipient is expected but is
  **not wired in the chat widgets** reviewed — confirm trigger/edge-function ownership (§8).

## 7. Backend to build (Supabase rebuild checklist)
- [ ] **Tables:** `chat`, `chat_users`, `messages` with exact columns/types above; FKs to
      `users`/`community` with sensible `on delete` (cascade `messages`/`chat_users` on `chat` delete);
      `chat_users` composite PK `(chat_id, user_id)`; defaults (`gen_random_uuid()`, `now()`,
      `is_read=false`, `islink=false`).
- [ ] **Indexes:** all FK columns; `messages(chat_id, created_at)`; `messages(chat_id, sender_id, is_read)`;
      `chat_users(user_id, is_deleted)`; `chat(chat_type)`, `chat(last_message_date)`.
- [ ] **RLS intent (deny by default):**
      - `SELECT`: only members (`chat_users` where `user_id = auth.uid()` and `is_deleted=false`) can
        read a `chat`, its `messages`, and its `chat_users`.
      - `messages INSERT`: allowed via RLS only if `sender_id = auth.uid()` AND caller is a member —
        or route through an RPC (preferred per §6). Client currently does direct insert; either add a
        strict INSERT policy or add a `send_message` RPC.
      - `messages UPDATE (is_read)`: only members, only rows where `sender_id != auth.uid()` — or via RPC.
      - `chat`/`chat_users` writes: **admin-only by default**; user mutations go through the RPCs below.
- [ ] **RPC / PL-pgSQL functions** (all validate `auth.uid()`; SECURITY INVOKER unless bypass needed;
      DEFINER ones `SET search_path=public,pg_temp`, REVOKE PUBLIC / GRANT authenticated):
      - `find_common_chat(user2 uuid)` → `{chat_id, chat_found}` — finds a `dm` chat shared by
        `auth.uid()` and `user2`.
      - `add_chat_users(p_chat_id, p_community_id, p_user2)` — inserts membership rows for BOTH
        `auth.uid()` and `p_user2` (DEFINER likely, to write membership).
      - `get_chat(search_query text)` — returns the current user's non-deleted chats enriched with
        the other participant profile (`name`, `profile_picture`, `user_id`), `last_message*`,
        `unread_message_count`, and aggregates `total_dm_chats`/`total_sale_chats`/
        `total_unread_message_count`; supports search.
      - `soft_delete_chat_users(user_ids text[])` — sets `is_deleted=true`, `deleted_date=now()` on
        `auth.uid()`'s membership for chats shared with each listed other-user.
      - `restore_chat_user(p_chat_id, p_user_id)` — clears `is_deleted` for the caller's membership.
      - (Recommended) `send_message(...)` to move message inserts + `chat` preview update server-side.
- [ ] **Storage:** bucket for chat image attachments (`file_url`); RLS so only chat members can
      read/write a chat's images. Confirm bucket name (§8).
- [ ] **Triggers:** on `messages` INSERT → update `chat.last_message/last_message_date/last_message_user`
      (currently done client-side; move to trigger for consistency) and emit realtime Broadcast + push.
- [ ] **Realtime:** per-chat + per-user private Broadcast topics; RLS policies on `realtime.messages`
      authorizing subscription by chat membership / self.
- [ ] **Push:** new-message notification via OneSignal/FCM (trigger or edge function) — confirm scope.
- [ ] **Cron:** none identified for chat.

## 8. Open questions & risks
- **`chat_users` primary key:** Row class exposes no `id` — assumed composite `(chat_id, user_id)`.
  Confirm before creating the table (affects RPC upserts and restore logic).
- **`chat_type` value set:** only `'dm'` is written by the client; the list has a `forsale` tab and
  `total_sale_chats`. Confirm the sale/marketplace chat type name (`'sale'` vs `'forsale'`) and who
  creates those chats (likely the marketplace feature, not `comp_new_message`).
- **`community_id` always `1`:** hardcoded in every insert/call. Is chat single-community for now, or
  should it derive from the users' community? Confirm before adding the FK/constraint.
- **`soft_delete_chat_users` semantics:** input is a list of **other users' ids**, not chat ids or
  membership ids. Confirm the RPC resolves "chats I share with these users" and soft-deletes only the
  caller's own membership rows (never the other participant's).
- **Direct client writes to `messages`/`chat`:** current code does `MessagesTable.insert` and
  `ChatTable.update`/`insert` directly from the client, which conflicts with §6 ("user-facing writes
  go through RPC"). Decide: strict RLS INSERT/UPDATE policies vs. `send_message` RPC. Preview-field
  update should move to a trigger regardless.
- **Realtime authorization gap:** existing channels are public/unauthorized and include a debug
  `test_messages_channel`. Must be replaced with private authorized channels (§6) — flagged as a risk.
- **Block enforcement:** `chat.is_blocked`/`blocked_by_user` exist and `comp_manage_access` offers
  block/report (via `blocks` table), but no code path prevents sending when blocked. Confirm the
  backend must reject messages / hide chat once blocked.
- **Read receipts scope:** mark-as-read flips a single boolean `is_read` per message (no per-user
  read state / group semantics), implying strictly 1:1. Confirm no group-chat requirement despite the
  generic `chat_users` join table.
- **Archived chats:** `archived_chats_page` has no backend calls in the reviewed code — confirm
  whether "archive" is a real backend state (distinct from `chat_users.is_deleted`) or an unbuilt/
  placeholder screen. No `is_archived` column exists on any of the three tables.
- **Push notifications:** not wired in chat widgets; confirm the trigger/edge function that notifies
  the recipient of a new message and which feature owns it.
- **Base project ref:** all URLs point to `wgcqstmmkcdjnnpuvspr` (old project). Rebuild must target
  Viora's own project (§6) — do not reuse this ref.

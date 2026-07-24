-- 0065_business_chat_rls.sql
-- RLS policies for Batch 6 tables (business_promote_plans, business_page, business_promote,
-- business_contacted, chat, chat_users, messages). Reviewed in docs/rls-policies-draft.md
-- ("Batch 6 — Business & Chat") pending sign-off (CLAUDE.md §6.9) — DO NOT apply until that
-- review is complete.
--
-- Adds one new self-scoped wrapper for business ownership (is_business_page_owner_self /
-- is_business_promote_owner_self already exist from 0052/0055 — reused here, not redefined).
-- is_chat_member_self already exists from 0064 (chat realtime) — reused here for chat/chat_users/
-- messages, not redefined.
--
-- All writes on every table in this batch are RPC-only — no client INSERT/UPDATE/DELETE policy
-- anywhere in this file, matching the post/follows/group/event/marketplace precedent (writes go
-- through the SECURITY DEFINER RPCs in 0057/0058/0062, which bypass RLS as table owner).

begin;

-- ---------------------------------------------------------------------------------------------
-- business_promote_plans — lookup table, readable by any authenticated user (dropdown/plan list);
-- admin-curated (no client write policy, no seed rows shipped in this batch — see review checklist).
-- ---------------------------------------------------------------------------------------------
create policy "business_promote_plans_select_authenticated" on public.business_promote_plans for select to authenticated
  using ( true );

-- ---------------------------------------------------------------------------------------------
-- business_page — active/non-deleted pages visible app-wide (no community boundary, no block
-- filter at the RLS layer — block filtering happens in the read RPCs, 0056, since RLS cannot see
-- the CALLER's identity relative to a second user without a helper call per row); the owner also
-- sees their own page regardless of state. Writes RPC-only (0057).
-- ---------------------------------------------------------------------------------------------
create policy "business_page_select_visible" on public.business_page for select to authenticated
  using (
    (is_deleted = false and business_status = 'active')
    or admin_user = (select auth.uid())
  );

-- ---------------------------------------------------------------------------------------------
-- business_promote — SELECT owner (submitter) or platform admin only (payments/moderation-
-- adjacent — strict, per docs/database/05-tables-business-chat.md's RLS intent). Writes RPC-only
-- (create_or_update_promotion/admin_set_promotion_status, 0057/0058).
-- ---------------------------------------------------------------------------------------------
create policy "business_promote_select_owner_admin" on public.business_promote for select to authenticated
  using (
    admin_user = (select auth.uid())
    or (select public.is_admin())
  );

-- ---------------------------------------------------------------------------------------------
-- business_contacted — SELECT the business page owner or platform admin only (matches the
-- table-doc RLS intent: "owner (for counts) / admin"). Writes RPC-only (update_contacted, 0057).
-- ---------------------------------------------------------------------------------------------
create policy "business_contacted_select_owner_admin" on public.business_contacted for select to authenticated
  using (
    (select public.is_business_page_owner_self(business_contacted.business_page_id))
    or (select public.is_admin())
  );

-- ---------------------------------------------------------------------------------------------
-- chat — SELECT only for non-soft-deleted members (is_chat_member_self, 0064). Writes RPC-only
-- (find_common_chat/add_chat_users, 0062; preview/broadcast triggers, 0063/0064).
-- ---------------------------------------------------------------------------------------------
create policy "chat_select_member" on public.chat for select to authenticated
  using ( (select public.is_chat_member_self(chat.id)) );

-- ---------------------------------------------------------------------------------------------
-- chat_users — SELECT the row's own user_id, or any fellow member of that chat (for membership
-- checks / participant lookups). Writes RPC-only (add_chat_users/soft_delete_chat_users/
-- restore_chat_user, 0062).
-- ---------------------------------------------------------------------------------------------
create policy "chat_users_select_member" on public.chat_users for select to authenticated
  using (
    chat_users.user_id = (select auth.uid())
    or (select public.is_chat_member_self(chat_users.chat_id))
  );

-- ---------------------------------------------------------------------------------------------
-- messages — SELECT only for non-soft-deleted members of the parent chat. Writes RPC-only
-- (send_message/mark_messages_read, 0062) — a stricter choice than a scoped client INSERT policy,
-- matching the recommendation in docs/features/10-chat-messaging.md §7 ("send_message RPC
-- preferred ... so the chat preview-field trigger and any push/broadcast fire atomically").
-- ---------------------------------------------------------------------------------------------
create policy "messages_select_member" on public.messages for select to authenticated
  using ( (select public.is_chat_member_self(messages.chat_id)) );

commit;

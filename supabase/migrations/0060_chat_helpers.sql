-- 0060_chat_helpers.sql
-- Purpose: Batch 6 (Chat) internal helper predicate, used by every chat RPC + RLS policy in this
-- batch. Mirrors is_event_owner()/is_sale_owner()/is_group_admin() (0037/0044/0026): explicit
-- 2-arg internal helper is revoked from ALL client roles (called only by other SECURITY DEFINER
-- functions, as owner). The client-facing 0-arg-effective wrapper (is_chat_member_self) is added
-- later, in the RLS file (0064), matching the is_event_owner/is_event_owner_self split precedent.
--
-- Two-way block enforcement reuses the EXISTING public.is_blocked_pair() (0009, locked, internal-
-- only) — no new block helper needed for chat.

begin;

-- ---------------------------------------------------------------------------------------------
-- is_chat_member — true if p_user_id is a NON-soft-deleted member of chat p_chat_id.
-- ---------------------------------------------------------------------------------------------
create or replace function public.is_chat_member(p_chat_id uuid, p_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1 from public.chat_users cu
    where cu.chat_id = p_chat_id and cu.user_id = p_user_id and coalesce(cu.is_deleted, false) = false
  );
$$;

comment on function public.is_chat_member(uuid, uuid) is
  'True if p_user_id is a non-soft-deleted member of chat p_chat_id. Internal helper — called only by other SECURITY DEFINER chat functions and by is_chat_member_self() (0064, for RLS).';

revoke all on function public.is_chat_member(uuid, uuid) from public, anon, authenticated;

commit;

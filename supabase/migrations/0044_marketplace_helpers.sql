-- 0044_marketplace_helpers.sql
-- Purpose: Batch 5 (Marketplace) internal helper predicate, used by every write RPC in this
-- batch. Mirrors is_event_owner()/is_group_admin() (0037/0026): explicit-2-arg internal helper is
-- revoked from ALL client roles (called only by other SECURITY DEFINER functions, as owner).
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5: pins search_path = public, pg_temp.

begin;

-- ---------------------------------------------------------------------------------------------
-- is_sale_owner — true if p_user_id is the created_by (seller) of p_sale_id.
-- ---------------------------------------------------------------------------------------------
create or replace function public.is_sale_owner(p_sale_id uuid, p_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1 from public.sale s
    where s.id = p_sale_id and s.created_by = p_user_id
  );
$$;

comment on function public.is_sale_owner(uuid, uuid) is
  'True if p_user_id is the created_by (seller) of p_sale_id. Internal helper — called only by other SECURITY DEFINER marketplace functions.';

revoke all on function public.is_sale_owner(uuid, uuid) from public, anon, authenticated;

commit;

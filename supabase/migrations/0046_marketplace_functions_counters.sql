-- 0046_marketplace_functions_counters.sql
-- Purpose: Batch 5 (Marketplace) — legacy-compat counter RPC (UpdateSaleCountCall). The REAL
-- counter is trigger-owned (0048_marketplace_triggers.sql, SECURITY DEFINER, fires on every sale
-- insert/update-of-isdeleted/delete) — this RPC is kept only because the locked frontend still
-- calls it explicitly after create listing (docs/features/07-marketplace-sale.md §5). Matches the
-- update_user_group_count()/update_event_attendee_count() precedent: an actual IDEMPOTENT
-- recompute, harmless/redundant once the trigger has already run, self-healing if it ever didn't.
--
-- p_userid (UpdateSaleCountCall's only arg) is ACCEPTED but IGNORED — always recomputes the
-- CALLER's (auth.uid()) own counter, same "accepted-but-ignored" pattern as
-- get_followers_nearby()'s p_userid (0019_follows_functions_reads.sql lesson): there is no
-- legitimate reason to let a client recompute another user's counter.
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5.

begin;

-- ---------------------------------------------------------------------------------------------
-- update_sale_count (UpdateSaleCountCall) — recomputes the CALLER's public_user_profile.sale_count
-- (count of non-deleted sale rows created_by = auth.uid()).
-- ---------------------------------------------------------------------------------------------
create or replace function public.update_sale_count(p_userid uuid default null)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'update_sale_count: no authenticated user';
  end if;

  update public.public_user_profile
  set sale_count = (
    select count(*) from public.sale where created_by = v_uid and isdeleted = false
  )
  where id = v_uid;
end;
$$;

comment on function public.update_sale_count(uuid) is
  'Legacy-compat idempotent recompute of the caller''s public_user_profile.sale_count. Real counter is trigger-maintained (0048). p_userid ignored (forced to auth.uid()).';

revoke all on function public.update_sale_count(uuid) from public;
grant execute on function public.update_sale_count(uuid) to authenticated;

commit;

-- 0048_marketplace_triggers.sql
-- Purpose: Batch 5 (Marketplace) counter trigger — public_user_profile.sale_count, self-healing
-- denormalized count per docs/decisions.md (2026-07-19, "Denormalized counters ... maintained by
-- DB TRIGGERS"). Recomputed from sale (non-deleted rows created_by = that user) on every
-- insert/update-of-isdeleted/delete. This is the REAL counter behind the legacy-compat
-- update_sale_count() RPC (0046).
--
-- Writes the column-locked public_user_profile.sale_count (0006_identity_rls.sql revokes UPDATE
-- on it from authenticated/anon) — SECURITY DEFINER, matching the trg_recompute_user_event_count/
-- trg_recompute_profile_post_count/trg_recompute_group_member_counts precedent exactly.
--
-- Trigger function is never called as an RPC — EXECUTE is revoked from every client role below
-- (matching 0015/0020/0033/0041), so it isn't exposed via /rest/v1/rpc.

begin;

-- ---------------------------------------------------------------------------------------------
-- sale -> public_user_profile.sale_count (count of non-deleted listings created by that user).
-- ---------------------------------------------------------------------------------------------
create or replace function public.trg_recompute_user_sale_count()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_created_by uuid := coalesce(new.created_by, old.created_by);
begin
  update public.public_user_profile
  set sale_count = (
    select count(*) from public.sale where created_by = v_created_by and isdeleted = false
  )
  where id = v_created_by;

  if tg_op = 'UPDATE' and old.created_by is distinct from new.created_by then
    update public.public_user_profile
    set sale_count = (
      select count(*) from public.sale where created_by = old.created_by and isdeleted = false
    )
    where id = old.created_by;
  end if;

  return coalesce(new, old);
end;
$$;

drop trigger if exists sale_recompute_user_count on public.sale;
create trigger sale_recompute_user_count
  after insert or delete or update of isdeleted, created_by on public.sale
  for each row
  execute function public.trg_recompute_user_sale_count();

revoke all on function public.trg_recompute_user_sale_count() from public, anon, authenticated;

commit;

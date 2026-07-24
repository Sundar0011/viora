-- 0031_group_functions_counters.sql
-- Purpose: Batch 4 (Groups) — legacy-compat counter RPCs (UpdateTotalGroupMembersCall,
-- UpdateUserGroupCountCall). The REAL counters are trigger-owned (0032_group_triggers.sql,
-- SECURITY DEFINER, fires on every group_members insert/delete/is_approved change) — these two
-- RPCs are kept only because the locked frontend still calls them explicitly after
-- join/approve/leave/create (docs/features/05-groups.md §5). Unlike Batch 2/3's identically-named
-- "legacy compat" functions (which became pure no-ops once triggers took over), these do an actual
-- IDEMPOTENT recompute — harmless/redundant when the trigger already ran, but self-healing if it
-- ever didn't (e.g. a future direct-SQL fix that bypassed the trigger).
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5.

begin;

-- ---------------------------------------------------------------------------------------------
-- update_total_group_members — recomputes group.total_members = count of approved group_members.
-- No ownership check beyond "group exists" — a deterministic, idempotent recompute has no
-- unauthorized side effect, matching the Batch 2/3 legacy-compat precedent.
-- ---------------------------------------------------------------------------------------------
create or replace function public.update_total_group_members(p_group_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if auth.uid() is null then
    raise exception 'update_total_group_members: no authenticated user';
  end if;

  update public."group"
  set total_members = (
    select count(*) from public.group_members where group_id = p_group_id and coalesce(is_approved, false)
  )
  where id = p_group_id;
end;
$$;

comment on function public.update_total_group_members(uuid) is
  'Legacy-compat idempotent recompute of group.total_members. Real counter is trigger-maintained (0032).';

revoke all on function public.update_total_group_members(uuid) from public;
grant execute on function public.update_total_group_members(uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- update_user_group_count — recomputes the CALLER's own public_user_profile.group_count.
-- ---------------------------------------------------------------------------------------------
create or replace function public.update_user_group_count()
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'update_user_group_count: no authenticated user';
  end if;

  update public.public_user_profile
  set group_count = (
    select count(*) from public.group_members where user_id = v_uid and coalesce(is_approved, false)
  )
  where id = v_uid;
end;
$$;

comment on function public.update_user_group_count() is
  'Legacy-compat idempotent recompute of the caller''s public_user_profile.group_count. Real counter is trigger-maintained (0032).';

revoke all on function public.update_user_group_count() from public;
grant execute on function public.update_user_group_count() to authenticated;

commit;

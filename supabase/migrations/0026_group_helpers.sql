-- 0026_group_helpers.sql
-- Purpose: Batch 4 (Groups) internal helper predicates, used by every write/read RPC in this
-- batch. Mirrors the is_blocked_pair()/can_view_post() pattern from 0009_post_functions_reads.sql:
-- explicit-arg internal helpers are revoked from ALL client roles (called only by other
-- SECURITY DEFINER functions, as owner); self-scoped `_self` wrappers (used by RLS policies) are
-- added later in 0034_group_rls.sql, matching 0016_post_rls.sql's can_view_post_self() pattern.
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5: pins search_path = public, pg_temp.
-- These three are pure predicates (no auth.uid() call inside — the caller passes the user id
-- explicitly, same shape as is_blocked_pair(p_user_a, p_user_b)).

begin;

-- ---------------------------------------------------------------------------------------------
-- is_group_admin — true if p_user_id is an admin of p_group_id.
-- ---------------------------------------------------------------------------------------------
create or replace function public.is_group_admin(p_group_id uuid, p_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1 from public.group_admin ga
    where ga.group_id = p_group_id and ga.user_id = p_user_id
  );
$$;

comment on function public.is_group_admin(uuid, uuid) is
  'True if p_user_id is an admin of p_group_id. Internal helper — called only by other SECURITY DEFINER group functions.';

revoke all on function public.is_group_admin(uuid, uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------------------------------
-- is_group_approved_member — true if p_user_id has an approved group_members row for p_group_id.
-- ---------------------------------------------------------------------------------------------
create or replace function public.is_group_approved_member(p_group_id uuid, p_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1 from public.group_members gm
    where gm.group_id = p_group_id and gm.user_id = p_user_id and coalesce(gm.is_approved, false)
  );
$$;

comment on function public.is_group_approved_member(uuid, uuid) is
  'True if p_user_id is an approved member of p_group_id. Internal helper — called only by other SECURITY DEFINER group functions.';

revoke all on function public.is_group_approved_member(uuid, uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------------------------------
-- group_admin_count — number of admins on p_group_id. Used to block removing the last admin.
-- ---------------------------------------------------------------------------------------------
create or replace function public.group_admin_count(p_group_id uuid)
returns int4
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select count(*)::int4 from public.group_admin ga where ga.group_id = p_group_id;
$$;

comment on function public.group_admin_count(uuid) is
  'Number of admin rows on p_group_id. Internal helper — used to block removing the last admin.';

revoke all on function public.group_admin_count(uuid) from public, anon, authenticated;

commit;

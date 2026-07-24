-- 0034_group_rls.sql
-- RLS policies for Batch 4 tables. Reviewed in docs/rls-policies-draft.md ("Batch 4 — Groups")
-- pending sign-off (CLAUDE.md §6.9) — DO NOT apply until that review is complete.
--
-- Adds two self-scoped wrapper predicates (is_group_admin_self / is_group_member_self), matching
-- 0016_post_rls.sql's can_view_post_self() pattern: the internal is_group_admin()/
-- is_group_approved_member() helpers (0026) are revoked from `authenticated`, so an RLS policy
-- (evaluated as the querying role) cannot call them directly — even though they're SECURITY
-- DEFINER, the caller still needs EXECUTE to invoke them at all. These wrappers are the only
-- group-membership/admin predicates granted to `authenticated`, used exclusively by RLS below.
--
-- All writes on every table in this batch are RPC-only — no client INSERT/UPDATE/DELETE policy
-- anywhere in this file, matching the `post`/`follows` precedent (writes go through the
-- SECURITY DEFINER RPCs in 0029/0030, which bypass RLS as table owner).

begin;

-- Self-scoped wrappers for RLS (the only group-membership/admin helpers granted to clients).
create or replace function public.is_group_admin_self(p_group_id uuid)
returns boolean language sql stable security definer
set search_path = public, pg_temp as $$
  select public.is_group_admin(p_group_id, auth.uid());
$$;
comment on function public.is_group_admin_self(uuid) is
  'Self-scoped is_group_admin(group, auth.uid()) — the only group-admin helper granted to clients (for RLS).';
revoke all on function public.is_group_admin_self(uuid) from public, anon;
grant execute on function public.is_group_admin_self(uuid) to authenticated;

create or replace function public.is_group_member_self(p_group_id uuid)
returns boolean language sql stable security definer
set search_path = public, pg_temp as $$
  select public.is_group_approved_member(p_group_id, auth.uid());
$$;
comment on function public.is_group_member_self(uuid) is
  'Self-scoped is_group_approved_member(group, auth.uid()) — the only group-membership helper granted to clients (for RLS).';
revoke all on function public.is_group_member_self(uuid) from public, anon;
grant execute on function public.is_group_member_self(uuid) to authenticated;

-- "group" — discovery: any authenticated user may see any non-deleted, active group's metadata
-- (name/description/type/location/etc.), including PRIVATE groups (membership gates the MEMBER
-- LIST and content, not the group's existence — matches docs/features/05-groups.md's own "all
-- groups" browse screen, which lists both open and private groups so users can request to join).
create policy "group_select_discoverable" on public."group" for select to authenticated
  using ( isdeleted = false and status = 'active' );
-- No INSERT/UPDATE/DELETE policy — writes only via create_group()/edit_group()/delete_group().

-- group_admin — visible to: the admin row's own user, any admin of the group, any approved member
-- of the group, or anyone (if the group is OPEN — admin badges are part of public member lists).
create policy "group_admin_select_visible" on public.group_admin for select to authenticated
  using (
    group_admin.user_id = (select auth.uid())
    or (select public.is_group_admin_self(group_admin.group_id))
    or (select public.is_group_member_self(group_admin.group_id))
    or exists (
      select 1 from public."group" g
      where g.id = group_admin.group_id and g.e_group_type = 'open' and g.isdeleted = false
    )
  );
-- No INSERT/UPDATE/DELETE policy — writes only via assign_group_admin()/delete_group_admin().

-- group_members — same visibility model as group_admin (open groups: member lists are public;
-- private groups: members/admins only). RECOMMENDATION, see review checklist below.
create policy "group_members_select_visible" on public.group_members for select to authenticated
  using (
    group_members.user_id = (select auth.uid())
    or (select public.is_group_admin_self(group_members.group_id))
    or (select public.is_group_member_self(group_members.group_id))
    or exists (
      select 1 from public."group" g
      where g.id = group_members.group_id and g.e_group_type = 'open' and g.isdeleted = false
    )
  );
-- No INSERT/UPDATE/DELETE policy — writes only via request_or_join_group()/accept_invite()/
-- approve_join_request()/leave_group().

-- group_members_invite — visible to: the invitee, the inviter, or any admin of the group.
create policy "group_members_invite_select_visible" on public.group_members_invite for select to authenticated
  using (
    group_members_invite.invited_user = (select auth.uid())
    or group_members_invite.invited_by = (select auth.uid())
    or (select public.is_group_admin_self(group_members_invite.group_id))
  );
-- No INSERT/UPDATE/DELETE policy — writes only via invite_users_to_group()/accept_invite()/
-- approve_join_request().

-- group_user_status — visible to: the row's own user, or any admin of the group (admins need to
-- see pending requests/invites to approve/reject them).
create policy "group_user_status_select_visible" on public.group_user_status for select to authenticated
  using (
    group_user_status.user_id = (select auth.uid())
    or (select public.is_group_admin_self(group_user_status.group_id))
  );
-- No INSERT/UPDATE/DELETE policy — writes only via the group state-machine RPCs (0029/0030).

commit;

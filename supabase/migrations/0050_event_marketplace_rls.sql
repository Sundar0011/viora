-- 0050_event_marketplace_rls.sql
-- RLS policies for Batch 5 tables (event_page, event_attending, sale, sale_category,
-- sale_images). Reviewed in docs/rls-policies-draft.md ("Batch 5 — Events, Marketplace &
-- Storage") pending sign-off (CLAUDE.md §6.9) — DO NOT apply until that review is complete.
--
-- Adds one self-scoped wrapper (is_event_owner_self), matching 0016_post_rls.sql's
-- can_view_post_self() / 0034_group_rls.sql's is_group_admin_self() pattern: the internal
-- is_event_owner() helper (0037) is revoked from `authenticated`, so an RLS policy (evaluated as
-- the querying role) cannot call it directly. This wrapper is the only event-ownership predicate
-- granted to `authenticated`, used exclusively by RLS below.
--
-- All writes on every table in this batch are RPC-only — no client INSERT/UPDATE/DELETE policy
-- anywhere in this file, matching the post/follows/group precedent (writes go through the
-- SECURITY DEFINER RPCs in 0038/0045, which bypass RLS as table owner).

begin;

-- Self-scoped wrapper for RLS (the only event-owner helper granted to clients).
create or replace function public.is_event_owner_self(p_event_id uuid)
returns boolean language sql stable security definer
set search_path = public, pg_temp as $$
  select public.is_event_owner(p_event_id, auth.uid());
$$;
comment on function public.is_event_owner_self(uuid) is
  'Self-scoped is_event_owner(event, auth.uid()) — the only event-owner helper granted to clients (for RLS).';
revoke all on function public.is_event_owner_self(uuid) from public, anon;
grant execute on function public.is_event_owner_self(uuid) to authenticated;

-- Self-scoped sale-owner wrapper for RLS (is_sale_owner is internal-only). Used by the
-- sale_images owner-scoped write policies below (approved 2026-07-19: the app inserts sale_images
-- rows directly after uploading, so a scoped owner INSERT/DELETE policy is allowed here rather
-- than forcing add_sale_image()/delete_sale_image() RPC).
create or replace function public.is_sale_owner_self(p_sale_id uuid)
returns boolean language sql stable security definer
set search_path = public, pg_temp as $$
  select public.is_sale_owner(p_sale_id, auth.uid());
$$;
comment on function public.is_sale_owner_self(uuid) is
  'Self-scoped is_sale_owner(sale, auth.uid()) — the only sale-owner helper granted to clients (for RLS).';
revoke all on function public.is_sale_owner_self(uuid) from public, anon;
grant execute on function public.is_sale_owner_self(uuid) to authenticated;

-- event_page — visible-only SELECT (excludes soft-deleted events, no community boundary, matches
-- docs/database/04-tables-events-marketplace.md's RLS intent); writes RPC-only.
create policy "event_page_select_visible" on public.event_page for select to authenticated
  using ( is_deleted = false );

-- event_attending — SELECT to the attendee, the inviter, or the event's owner (per table doc).
create policy "event_attending_select_visible" on public.event_attending for select to authenticated
  using (
    event_attending.attending_id = (select auth.uid())
    or event_attending.invited_by = (select auth.uid())
    or (select public.is_event_owner_self(event_attending.event_id))
  );

-- sale — visible-only SELECT (excludes soft-deleted listings, no community boundary, matches
-- docs/database/04-tables-events-marketplace.md's RLS intent); writes RPC-only.
create policy "sale_select_visible" on public.sale for select to authenticated
  using ( isdeleted = false );

-- sale_category — lookup table, readable by any authenticated user; admin-curated via migration
-- (no client writes), matching the see_post_access/comment_post_access precedent (0016_post_rls.sql).
create policy "sale_category_select_authenticated" on public.sale_category for select to authenticated
  using ( true );

-- sale_images — SELECT follows parent sale visibility; writes RPC-only
-- (add_sale_image()/delete_sale_image(), 0045).
create policy "sale_images_select_visible" on public.sale_images for select to authenticated
  using (
    exists (
      select 1 from public.sale s
      where s.id = sale_images.sale_id and s.isdeleted = false
    )
  );

-- sale_images writes: owner-scoped direct DML (approved 2026-07-19). A user may insert an image
-- row only for a sale they own and only tagged with their own user_id; may delete only rows on
-- their own sale. (add_sale_image()/delete_sale_image() RPCs remain as an alternative path.)
create policy "sale_images_insert_own" on public.sale_images for insert to authenticated
  with check (
    (select public.is_sale_owner_self(sale_images.sale_id))
    and (sale_images.user_id is null or sale_images.user_id = (select auth.uid()))
  );
create policy "sale_images_delete_own" on public.sale_images for delete to authenticated
  using ( (select public.is_sale_owner_self(sale_images.sale_id)) );

commit;

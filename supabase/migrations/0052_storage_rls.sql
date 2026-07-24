-- 0052_storage_rls.sql
-- storage.objects RLS policies for every bucket created in 0051_storage_buckets.sql. Reviewed in
-- docs/rls-policies-draft.md ("Batch 5 — Events, Marketplace & Storage") pending sign-off
-- (CLAUDE.md §6.9) — DO NOT apply until that review is complete.
--
-- Path convention (docs/database/07-storage-buckets.md): `<owner-or-entity-id>/<filename>`.
-- Public buckets: SELECT open to anon+authenticated (public URLs); INSERT/UPDATE/DELETE scoped to
-- the owner's folder, checked via `(storage.foldername(name))[1]`. UPSERT (FileOptions(upsert:
-- true), used by several upload flows) needs INSERT + SELECT + UPDATE together — SELECT is public
-- on every public bucket here, so only INSERT/UPDATE are added per bucket below.
--
-- Two ownership shapes:
--   (1) folder = the UPLOADER's own user id (profile-images, cover-images) — plain
--       `(storage.foldername(name))[1] = auth.uid()::text` check, no table join needed.
--   (2) folder = an ENTITY id (post_id/sale_id/event_id/group_id/business_page_id) — ownership is
--       checked via `(select <entity>_owner_self(entity_id))`, reusing the SAME self-scoped RLS
--       wrapper functions already built for the entity's own table RLS (is_event_owner_self,
--       is_group_admin_self) wherever one already exists, or a NEW forward-compat helper below for
--       entities whose owning table doesn't exist yet (business-image, promote-receipts —
--       business_page/business_promote are a later batch).
--
-- FORWARD-COMPAT NOTE (business-image, promote-receipts): business_page/business_promote don't
-- exist yet (Business/Chat batch). The two helpers below use the SAME dynamic-SQL +
-- `undefined_table`-exception-guard pattern as can_view_post()'s Batch-2 friends-check /
-- get_following_users_not_attending_event()'s Batch-3 event-attending check: they apply cleanly
-- today (deny by default, since the tables don't exist) and self-activate with zero further
-- changes once that batch's tables land.

begin;

-- ---------------------------------------------------------------------------------------------
-- Forward-compat helpers for business-image / promote-receipts (business_page/business_promote do
-- not exist yet). Internal 2-arg form is revoked from all client roles; self-scoped 1-arg wrapper
-- (auth.uid()-closed-over) is the only form granted to `authenticated`, used by storage policies
-- below — matches the is_event_owner/is_event_owner_self split (0037/0050).
-- ---------------------------------------------------------------------------------------------
create or replace function public.is_business_page_owner(p_business_page_id uuid, p_user_id uuid)
returns boolean
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_owner boolean := false;
begin
  begin
    execute 'select exists (select 1 from public.business_page where id = $1 and admin_user = $2)'
      into v_owner using p_business_page_id, p_user_id;
  exception when undefined_table then
    v_owner := false; -- business_page not created yet (Business/Chat batch) — deny by default.
  end;
  return coalesce(v_owner, false);
end;
$$;

comment on function public.is_business_page_owner(uuid, uuid) is
  'True if p_user_id owns business_page p_business_page_id. Forward-compat: returns false until business_page exists. Internal helper.';

revoke all on function public.is_business_page_owner(uuid, uuid) from public, anon, authenticated;

create or replace function public.is_business_page_owner_self(p_business_page_id uuid)
returns boolean language sql stable security definer
set search_path = public, pg_temp as $$
  select public.is_business_page_owner(p_business_page_id, auth.uid());
$$;
comment on function public.is_business_page_owner_self(uuid) is
  'Self-scoped is_business_page_owner(page, auth.uid()) — the only business-page-owner helper granted to clients (for storage RLS). Forward-compat, see is_business_page_owner().';
revoke all on function public.is_business_page_owner_self(uuid) from public, anon;
grant execute on function public.is_business_page_owner_self(uuid) to authenticated;

create or replace function public.is_business_promote_owner(p_business_page_id uuid, p_user_id uuid)
returns boolean
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_owner boolean := false;
begin
  begin
    execute 'select exists (select 1 from public.business_promote where business_page_id = $1 and admin_user = $2)'
      into v_owner using p_business_page_id, p_user_id;
  exception when undefined_table then
    v_owner := false; -- business_promote not created yet (Business/Chat batch) — deny by default.
  end;
  return coalesce(v_owner, false);
end;
$$;

comment on function public.is_business_promote_owner(uuid, uuid) is
  'True if p_user_id owns the business_promote row for p_business_page_id. Forward-compat: returns false until business_promote exists. Internal helper.';

revoke all on function public.is_business_promote_owner(uuid, uuid) from public, anon, authenticated;

create or replace function public.is_business_promote_owner_self(p_business_page_id uuid)
returns boolean language sql stable security definer
set search_path = public, pg_temp as $$
  select public.is_business_promote_owner(p_business_page_id, auth.uid());
$$;
comment on function public.is_business_promote_owner_self(uuid) is
  'Self-scoped is_business_promote_owner(page, auth.uid()) — the only receipt-owner helper granted to clients (for storage RLS). Forward-compat.';
revoke all on function public.is_business_promote_owner_self(uuid) from public, anon;
grant execute on function public.is_business_promote_owner_self(uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- post-images — public read; write scoped to the owning post's author. Folder = post_id.
-- ---------------------------------------------------------------------------------------------
create policy "post_images_bucket_select" on storage.objects for select to anon, authenticated
  using ( bucket_id = 'post-images' );
create policy "post_images_bucket_insert" on storage.objects for insert to authenticated
  with check (
    bucket_id = 'post-images'
    and exists (
      select 1 from public.post p
      where p.id::text = (storage.foldername(name))[1] and p.user_id = (select auth.uid())
    )
  );
create policy "post_images_bucket_update" on storage.objects for update to authenticated
  using (
    bucket_id = 'post-images'
    and exists (
      select 1 from public.post p
      where p.id::text = (storage.foldername(name))[1] and p.user_id = (select auth.uid())
    )
  );
create policy "post_images_bucket_delete" on storage.objects for delete to authenticated
  using (
    bucket_id = 'post-images'
    and exists (
      select 1 from public.post p
      where p.id::text = (storage.foldername(name))[1] and p.user_id = (select auth.uid())
    )
  );

-- ---------------------------------------------------------------------------------------------
-- sales-images — public read; write scoped to the owning sale's seller. Folder = sale_id.
-- ---------------------------------------------------------------------------------------------
create policy "sales_images_bucket_select" on storage.objects for select to anon, authenticated
  using ( bucket_id = 'sales-images' );
create policy "sales_images_bucket_insert" on storage.objects for insert to authenticated
  with check (
    bucket_id = 'sales-images'
    and exists (
      select 1 from public.sale s
      where s.id::text = (storage.foldername(name))[1] and s.created_by = (select auth.uid())
    )
  );
create policy "sales_images_bucket_update" on storage.objects for update to authenticated
  using (
    bucket_id = 'sales-images'
    and exists (
      select 1 from public.sale s
      where s.id::text = (storage.foldername(name))[1] and s.created_by = (select auth.uid())
    )
  );
create policy "sales_images_bucket_delete" on storage.objects for delete to authenticated
  using (
    bucket_id = 'sales-images'
    and exists (
      select 1 from public.sale s
      where s.id::text = (storage.foldername(name))[1] and s.created_by = (select auth.uid())
    )
  );

-- ---------------------------------------------------------------------------------------------
-- profile-images / cover-images — public read; write scoped to the uploader's OWN id (folder =
-- user_id, not an entity id).
-- ---------------------------------------------------------------------------------------------
create policy "profile_images_bucket_select" on storage.objects for select to anon, authenticated
  using ( bucket_id = 'profile-images' );
create policy "profile_images_bucket_insert" on storage.objects for insert to authenticated
  with check ( bucket_id = 'profile-images' and (storage.foldername(name))[1] = (select auth.uid())::text );
create policy "profile_images_bucket_update" on storage.objects for update to authenticated
  using ( bucket_id = 'profile-images' and (storage.foldername(name))[1] = (select auth.uid())::text );
create policy "profile_images_bucket_delete" on storage.objects for delete to authenticated
  using ( bucket_id = 'profile-images' and (storage.foldername(name))[1] = (select auth.uid())::text );

create policy "cover_images_bucket_select" on storage.objects for select to anon, authenticated
  using ( bucket_id = 'cover-images' );
create policy "cover_images_bucket_insert" on storage.objects for insert to authenticated
  with check ( bucket_id = 'cover-images' and (storage.foldername(name))[1] = (select auth.uid())::text );
create policy "cover_images_bucket_update" on storage.objects for update to authenticated
  using ( bucket_id = 'cover-images' and (storage.foldername(name))[1] = (select auth.uid())::text );
create policy "cover_images_bucket_delete" on storage.objects for delete to authenticated
  using ( bucket_id = 'cover-images' and (storage.foldername(name))[1] = (select auth.uid())::text );

-- ---------------------------------------------------------------------------------------------
-- event — public read; write scoped to the owning event's admin_user. Folder = event_id.
-- ---------------------------------------------------------------------------------------------
create policy "event_bucket_select" on storage.objects for select to anon, authenticated
  using ( bucket_id = 'event' );
create policy "event_bucket_insert" on storage.objects for insert to authenticated
  with check (
    bucket_id = 'event'
    and (select public.is_event_owner_self(((storage.foldername(name))[1])::uuid))
  );
create policy "event_bucket_update" on storage.objects for update to authenticated
  using (
    bucket_id = 'event'
    and (select public.is_event_owner_self(((storage.foldername(name))[1])::uuid))
  );
create policy "event_bucket_delete" on storage.objects for delete to authenticated
  using (
    bucket_id = 'event'
    and (select public.is_event_owner_self(((storage.foldername(name))[1])::uuid))
  );

-- ---------------------------------------------------------------------------------------------
-- group-profile-image — public read; write scoped to a group ADMIN. Folder = group_id.
-- ---------------------------------------------------------------------------------------------
create policy "group_profile_image_bucket_select" on storage.objects for select to anon, authenticated
  using ( bucket_id = 'group-profile-image' );
create policy "group_profile_image_bucket_insert" on storage.objects for insert to authenticated
  with check (
    bucket_id = 'group-profile-image'
    and (select public.is_group_admin_self(((storage.foldername(name))[1])::uuid))
  );
create policy "group_profile_image_bucket_update" on storage.objects for update to authenticated
  using (
    bucket_id = 'group-profile-image'
    and (select public.is_group_admin_self(((storage.foldername(name))[1])::uuid))
  );
create policy "group_profile_image_bucket_delete" on storage.objects for delete to authenticated
  using (
    bucket_id = 'group-profile-image'
    and (select public.is_group_admin_self(((storage.foldername(name))[1])::uuid))
  );

-- ---------------------------------------------------------------------------------------------
-- business-image — public read; write scoped to the owning business_page's admin_user.
-- Folder = business_page_id. Forward-compat (business_page doesn't exist yet) — INSERT/UPDATE/
-- DELETE deny until that batch lands (is_business_page_owner_self() returns false).
-- ---------------------------------------------------------------------------------------------
create policy "business_image_bucket_select" on storage.objects for select to anon, authenticated
  using ( bucket_id = 'business-image' );
create policy "business_image_bucket_insert" on storage.objects for insert to authenticated
  with check (
    bucket_id = 'business-image'
    and (select public.is_business_page_owner_self(((storage.foldername(name))[1])::uuid))
  );
create policy "business_image_bucket_update" on storage.objects for update to authenticated
  using (
    bucket_id = 'business-image'
    and (select public.is_business_page_owner_self(((storage.foldername(name))[1])::uuid))
  );
create policy "business_image_bucket_delete" on storage.objects for delete to authenticated
  using (
    bucket_id = 'business-image'
    and (select public.is_business_page_owner_self(((storage.foldername(name))[1])::uuid))
  );

-- ---------------------------------------------------------------------------------------------
-- promote-receipts — PRIVATE. SELECT restricted to the business page owner OR admin. INSERT
-- restricted to the owner's own business_page_id folder. NO public/anon SELECT policy at all.
-- Folder = business_page_id. Forward-compat (business_promote doesn't exist yet).
-- ---------------------------------------------------------------------------------------------
create policy "promote_receipts_bucket_select" on storage.objects for select to authenticated
  using (
    bucket_id = 'promote-receipts'
    and (
      (select public.is_business_promote_owner_self(((storage.foldername(name))[1])::uuid))
      or (select public.is_admin())
    )
  );
create policy "promote_receipts_bucket_insert" on storage.objects for insert to authenticated
  with check (
    bucket_id = 'promote-receipts'
    and (select public.is_business_promote_owner_self(((storage.foldername(name))[1])::uuid))
  );
create policy "promote_receipts_bucket_update" on storage.objects for update to authenticated
  using (
    bucket_id = 'promote-receipts'
    and (select public.is_business_promote_owner_self(((storage.foldername(name))[1])::uuid))
  );
create policy "promote_receipts_bucket_delete" on storage.objects for delete to authenticated
  using (
    bucket_id = 'promote-receipts'
    and (select public.is_business_promote_owner_self(((storage.foldername(name))[1])::uuid))
  );

-- ---------------------------------------------------------------------------------------------
-- squadd — public read (static admin-managed defaults, e.g. default_group_image/, default_profile/,
-- default_cover_image/); writes admin-only (no user uploads).
-- ---------------------------------------------------------------------------------------------
create policy "squadd_bucket_select" on storage.objects for select to anon, authenticated
  using ( bucket_id = 'squadd' );
create policy "squadd_bucket_insert" on storage.objects for insert to authenticated
  with check ( bucket_id = 'squadd' and (select public.is_admin()) );
create policy "squadd_bucket_update" on storage.objects for update to authenticated
  using ( bucket_id = 'squadd' and (select public.is_admin()) );
create policy "squadd_bucket_delete" on storage.objects for delete to authenticated
  using ( bucket_id = 'squadd' and (select public.is_admin()) );

commit;

-- 0045_marketplace_functions_writes.sql
-- Purpose: Batch 5 (Marketplace) write RPCs. insert_sales_details/update_sale_without_image keep
-- their EXACT frontend-observed names + argument names (docs/database/09-rpc-inventory.md §7,
-- cross-checked against the literal JSON bodies in lib/backend/api_requests/api_calls.dart
-- InsertSaleDetailsCall/UpdateSaleWithoutImageCall). set_sale_deleted/set_sale_type/
-- add_sale_image/delete_sale_image are NEW RPCs replacing the frontend's direct
-- SaleTable().update / sale_images insert/delete DML (docs/features/07-marketplace-sale.md §8:
-- "Direct client writes bypass RPC ... per CLAUDE.md §6 these should be ... moved behind
-- SECURITY DEFINER RPCs. Decision needed." — decided: move them, matching the
-- create_event/edit_event/delete_event precedent). -- TODO(frontend) to wire
-- comp_sold_delete/comp_sale_delete and the image-edit flow to these RPCs.
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5: validates auth.uid() inside, pins
-- search_path = public, pg_temp, REVOKEs EXECUTE from PUBLIC, GRANTs only to authenticated.
-- Only set_sale_deleted(true) (a soft delete) is audited, matching the delete_group()/
-- delete_event() precedent — sold/available/undo/image edits are everyday actions, not audited.

begin;

-- ---------------------------------------------------------------------------------------------
-- insert_sales_details (InsertSaleDetailsCall) — EXACT frontend contract: community_id, title,
-- description, sale_category, e_price_type, price, location, e_sale_type, p_userid, lon, lat,
-- city (all always sent by the client, per the literal JSON body — no SQL defaults needed).
-- Builds location_point server-side from lat/lon. p_userid is VALIDATED (must equal auth.uid()),
-- per docs/database/09-rpc-inventory.md §7 ("auth.uid()=p_userid"). community_id kept as a compat
-- arg only (unused). -- TODO(confirm): lat/lon are required here (raises if either is null) to
-- satisfy location_point's NOT NULL constraint — closes the open question in
-- docs/features/07-marketplace-sale.md §8 ("latitude/longitude nullable but location_point
-- non-null — reconcile").
-- ---------------------------------------------------------------------------------------------
create or replace function public.insert_sales_details(
  community_id   int8,
  title          text,
  description    text,
  sale_category  text,
  e_price_type   public.e_price_type,
  price          int8,
  location       text,
  e_sale_type    public.e_sale_type,
  p_userid       uuid,
  lon            float8,
  lat            float8,
  city           text
)
returns public.sale
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid  uuid := auth.uid();
  v_sale public.sale;
begin
  if v_uid is null then
    raise exception 'insert_sales_details: no authenticated user';
  end if;
  if p_userid is not null and p_userid <> v_uid then
    raise exception 'insert_sales_details: p_userid does not match the authenticated user';
  end if;
  if title is null or btrim(title) = '' then
    raise exception 'insert_sales_details: title is required';
  end if;
  if lat is null or lon is null then
    raise exception 'insert_sales_details: a chosen location (lat/lon) is required';
  end if;

  insert into public.sale (
    title, description, sale_category, e_price_type, price, location, e_sale_type,
    created_by, location_point, city, isdeleted, latitude, longitude
  )
  values (
    title, description, sale_category, e_price_type, price, location,
    coalesce(e_sale_type, 'selling'),
    v_uid,
    extensions.ST_SetSRID(extensions.ST_MakePoint(lon, lat), 4326)::extensions.geography,
    city, false, lat, lon
  )
  returning * into v_sale;

  return v_sale;
end;
$$;

comment on function public.insert_sales_details(int8, text, text, text, public.e_price_type, int8, text, public.e_sale_type, uuid, float8, float8, text) is
  'SECURITY DEFINER: creates a sale listing for auth.uid() (p_userid validated). community_id unused (compat).';

revoke all on function public.insert_sales_details(int8, text, text, text, public.e_price_type, int8, text, public.e_sale_type, uuid, float8, float8, text) from public;
grant execute on function public.insert_sales_details(int8, text, text, text, public.e_price_type, int8, text, public.e_sale_type, uuid, float8, float8, text) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- update_sale_without_image (UpdateSaleWithoutImageCall) — EXACT frontend contract: city,
-- description, e_price_type, lat, location, lon, price, sale_category, sale_id, title (all always
-- sent). Owner-only. Rebuilds location_point from lat/lon on every edit. Does NOT touch
-- e_sale_type/community_id/created_by/isdeleted, per docs/features/07-marketplace-sale.md §5.
-- ---------------------------------------------------------------------------------------------
create or replace function public.update_sale_without_image(
  city           text,
  description    text,
  e_price_type   public.e_price_type,
  lat            float8,
  location       text,
  lon            float8,
  price          int8,
  sale_category  text,
  sale_id        uuid,
  title          text
)
returns public.sale
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid  uuid := auth.uid();
  v_sale public.sale;
begin
  if v_uid is null then
    raise exception 'update_sale_without_image: no authenticated user';
  end if;

  if not exists (select 1 from public.sale where id = sale_id and isdeleted = false) then
    raise exception 'update_sale_without_image: sale not found';
  end if;

  if not public.is_sale_owner(sale_id, v_uid) then
    raise exception 'update_sale_without_image: caller is not the sale owner';
  end if;

  update public.sale set
    title          = title,
    description    = description,
    sale_category  = sale_category,
    e_price_type   = e_price_type,
    price          = price,
    location       = location,
    city           = city,
    latitude       = lat,
    longitude      = lon,
    location_point = case when lat is not null and lon is not null
                       then extensions.ST_SetSRID(extensions.ST_MakePoint(lon, lat), 4326)::extensions.geography
                       else location_point
                     end
  where id = sale_id
  returning * into v_sale;

  return v_sale;
end;
$$;

comment on function public.update_sale_without_image(text, text, public.e_price_type, float8, text, float8, int8, text, uuid, text) is
  'SECURITY DEFINER: owner-only sale edit. Does not touch e_sale_type/isdeleted/created_by.';

revoke all on function public.update_sale_without_image(text, text, public.e_price_type, float8, text, float8, int8, text, uuid, text) from public;
grant execute on function public.update_sale_without_image(text, text, public.e_price_type, float8, text, float8, int8, text, uuid, text) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- set_sale_deleted (NEW) — owner-only soft delete / undo (comp_sold_delete / comp_sale_delete
-- "Undo" snackbar). Audited only when p_isdeleted=true.
-- ---------------------------------------------------------------------------------------------
create or replace function public.set_sale_deleted(p_sale_id uuid, p_isdeleted boolean)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'set_sale_deleted: no authenticated user';
  end if;

  if not public.is_sale_owner(p_sale_id, v_uid) then
    raise exception 'set_sale_deleted: caller is not the sale owner';
  end if;

  update public.sale set isdeleted = p_isdeleted where id = p_sale_id;

  if p_isdeleted then
    insert into public.audit_log (actor_id, action, target_table, target_id, details)
    values (v_uid, 'set_sale_deleted', 'sale', p_sale_id, jsonb_build_object());
  end if;
end;
$$;

comment on function public.set_sale_deleted(uuid, boolean) is
  'SECURITY DEFINER: owner-only. Soft-delete (true) or undo (false) a sale listing. Audited on delete.';

revoke all on function public.set_sale_deleted(uuid, boolean) from public;
grant execute on function public.set_sale_deleted(uuid, boolean) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- set_sale_type (NEW) — owner-only Mark Sold / Mark Available toggle.
-- ---------------------------------------------------------------------------------------------
create or replace function public.set_sale_type(p_sale_id uuid, p_e_sale_type public.e_sale_type)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'set_sale_type: no authenticated user';
  end if;

  if not public.is_sale_owner(p_sale_id, v_uid) then
    raise exception 'set_sale_type: caller is not the sale owner';
  end if;

  update public.sale set e_sale_type = p_e_sale_type where id = p_sale_id;
end;
$$;

comment on function public.set_sale_type(uuid, public.e_sale_type) is
  'SECURITY DEFINER: owner-only. Sets sale.e_sale_type (Mark Sold / Mark Available).';

revoke all on function public.set_sale_type(uuid, public.e_sale_type) from public;
grant execute on function public.set_sale_type(uuid, public.e_sale_type) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- add_sale_image (NEW) — owner-only. Replaces the frontend's direct sale_images insert in the
-- uploadSalesImages action (storage upload itself stays client-side; this RPC only records the
-- resulting public URL row).
-- ---------------------------------------------------------------------------------------------
create or replace function public.add_sale_image(p_sale_id uuid, p_image text)
returns public.sale_images
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
  v_row public.sale_images;
begin
  if v_uid is null then
    raise exception 'add_sale_image: no authenticated user';
  end if;

  if not public.is_sale_owner(p_sale_id, v_uid) then
    raise exception 'add_sale_image: caller is not the sale owner';
  end if;

  insert into public.sale_images (sale_id, user_id, image)
  values (p_sale_id, v_uid, p_image)
  returning * into v_row;

  return v_row;
end;
$$;

comment on function public.add_sale_image(uuid, text) is
  'SECURITY DEFINER: owner-only. Records a sale_images row after the client uploads to the sales-images bucket.';

revoke all on function public.add_sale_image(uuid, text) from public;
grant execute on function public.add_sale_image(uuid, text) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- delete_sale_image (NEW) — owner-only. Replaces the frontend's direct SaleImagesTable().delete.
-- ---------------------------------------------------------------------------------------------
create or replace function public.delete_sale_image(p_image_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid    uuid := auth.uid();
  v_sale_id uuid;
begin
  if v_uid is null then
    raise exception 'delete_sale_image: no authenticated user';
  end if;

  select sale_id into v_sale_id from public.sale_images where id = p_image_id;
  if v_sale_id is null then
    raise exception 'delete_sale_image: image not found';
  end if;

  if not public.is_sale_owner(v_sale_id, v_uid) then
    raise exception 'delete_sale_image: caller is not the sale owner';
  end if;

  delete from public.sale_images where id = p_image_id;
end;
$$;

comment on function public.delete_sale_image(uuid) is
  'SECURITY DEFINER: owner-only. Deletes a sale_images row (storage file deletion stays client-side).';

revoke all on function public.delete_sale_image(uuid) from public;
grant execute on function public.delete_sale_image(uuid) to authenticated;

commit;

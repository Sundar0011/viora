-- 0047_marketplace_functions_reads.sql
-- Purpose: Batch 5 (Marketplace) read RPCs. get_yours_sales_details/get_sales_details/
-- get_sales_homepage/get_sales_home_data/get_sale_images keep their EXACT frontend-observed names
-- + argument names (docs/database/09-rpc-inventory.md §7, cross-checked against the literal JSON
-- bodies in lib/backend/api_requests/api_calls.dart and lib/custom_code/actions/
-- get_sale_home_page.dart). Pagination args are ADDED with DEFAULTs so the locked frontend's
-- existing calls keep working (arg-order rule respected: added/optional args always AFTER every
-- frontend-required arg).
--
-- NOTE on INVOKER vs DEFINER: docs/database/09-rpc-inventory.md §7 labels these "INVOKER", but
-- every read RPC below needs is_blocked_pair() (revoked from all client roles) and/or must read
-- other users' rows beyond what a plain SELECT policy exposes — SECURITY DEFINER is used, matching
-- the ACTUAL applied convention in every prior batch (get_visible_posts/get_followers/
-- get_neighbourhood_post_data are all `security definer` despite similar doc wording; see the
-- backend-dev playbook lesson dated 2026-07-19, "trust the applied SQL, not the prose").
--
-- get_sales_home_data (the browse feed) is the batch's critical server-side filter/sort per
-- docs/decisions.md (2026-07-19, "Pagination & filtering"): category + sale_type + distance(kms)
-- + sort (Newest/Closest) are ALL applied in SQL, never fetched-all-and-filtered client-side.
-- Distance is computed against the CALLER's own saved location (user_locations), same reference
-- point as get_followers_nearby() (0019) — TODO(confirm): the feature doc leaves the reference
-- point (viewer vs community centroid) unconfirmed; caller's-own-location was chosen as the only
-- data actually available (no community centroid concept exists per docs/decisions.md).
-- 'Closest' sort needs an OFFSET-based p_offset (not keyset) since distance isn't monotonic with
-- (created_at, id) — a deliberate, documented deviation from every other list RPC's keyset
-- pagination in this schema. -- TODO(frontend): wire p_offset once the browse feed paginates
-- beyond one page.
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5: validates auth.uid() inside, pins
-- search_path = public, pg_temp, REVOKEs EXECUTE from PUBLIC, GRANTs only to authenticated.

begin;

-- ---------------------------------------------------------------------------------------------
-- (a) _sale_detail_jsonb — internal helper: enriched single-sale JSON (sale fields + seller name/
-- profile_picture + images[] + is_owner + distance_km vs p_viewer_id's saved location). Shared by
-- get_sales_details and get_sales_homepage, which are otherwise near-identical per the frontend
-- contract (single-listing detail, different call sites). Internal-only, revoked from all client
-- roles.
-- ---------------------------------------------------------------------------------------------
create or replace function public._sale_detail_jsonb(p_sale_id uuid, p_viewer_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_my_location extensions.geography;
  v_result      jsonb;
begin
  select location into v_my_location from public.user_locations where id = p_viewer_id;

  select jsonb_build_object(
    'id', s.id,
    'created_at', s.created_at,
    'title', s.title,
    'description', s.description,
    'sale_category', s.sale_category,
    'e_price_type', s.e_price_type,
    'price', s.price,
    'location', s.location,
    'e_sale_type', s.e_sale_type,
    'created_by', s.created_by,
    'city', s.city,
    'isdeleted', s.isdeleted,
    'latitude', s.latitude,
    'longitude', s.longitude,
    'seller_name', prof.name,
    'seller_profile_picture', prof.profile_picture,
    'distance_km', case when v_my_location is null then null
                     else extensions.ST_Distance(s.location_point, v_my_location) / 1000.0
                   end,
    'is_owner', s.created_by = p_viewer_id,
    'images', (
      select coalesce(jsonb_agg(si.image order by si.created_at), '[]'::jsonb)
      from public.sale_images si
      where si.sale_id = s.id
    )
  )
  into v_result
  from public.sale s
  join public.public_user_profile prof on prof.id = s.created_by
  where s.id = p_sale_id;

  return v_result;
end;
$$;

comment on function public._sale_detail_jsonb(uuid, uuid) is
  'Internal helper: enriched single-sale detail JSON, shared by get_sales_details/get_sales_homepage.';

revoke all on function public._sale_detail_jsonb(uuid, uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------------------------------
-- (b) get_yours_sales_details (GetSalesDataCall) — EXACT frontend contract: p_userid, p_filter
-- ('all'/'selling'/'sold'). p_userid is VALIDATED against auth.uid() (this RPC only ever returns
-- the CALLER's own listings).
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_yours_sales_details(
  p_userid            uuid,
  p_filter            text,
  p_limit             int4 default 20,
  p_after_created_at  timestamptz default null,
  p_after_id          uuid default null
)
returns setof public.sale
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'get_yours_sales_details: no authenticated user';
  end if;
  if p_userid is not null and p_userid <> v_uid then
    raise exception 'get_yours_sales_details: p_userid does not match the authenticated user';
  end if;

  return query
  select s.*
  from public.sale s
  where s.created_by = v_uid
    and (p_filter is null or p_filter = '' or p_filter = 'all' or s.e_sale_type::text = p_filter)
    and (
      p_after_created_at is null
      or (s.created_at, s.id) < (p_after_created_at, p_after_id)
    )
  order by s.created_at desc, s.id desc
  limit least(greatest(p_limit, 1), 100);
end;
$$;

comment on function public.get_yours_sales_details(uuid, text, int4, timestamptz, uuid) is
  'Caller''s own sale listings, filtered by p_filter (all/selling/sold), keyset-paginated.';

revoke all on function public.get_yours_sales_details(uuid, text, int4, timestamptz, uuid) from public;
grant execute on function public.get_yours_sales_details(uuid, text, int4, timestamptz, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- (c) get_sales_details (GetSalesDetailsCall) — EXACT frontend contract: p_salesid, p_userid.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_sales_details(p_salesid uuid, p_userid uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'get_sales_details: no authenticated user';
  end if;
  if not exists (select 1 from public.sale where id = p_salesid and isdeleted = false) then
    return null;
  end if;
  return public._sale_detail_jsonb(p_salesid, v_uid);
end;
$$;

comment on function public.get_sales_details(uuid, uuid) is
  'Single sale detail JSON (see _sale_detail_jsonb). p_userid unused beyond auth (caller identity comes from auth.uid()).';

revoke all on function public.get_sales_details(uuid, uuid) from public;
grant execute on function public.get_sales_details(uuid, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- (d) get_sales_homepage (GetSaleHomePageSalesCall) — EXACT frontend contract: p_userid,
-- p_communityid, p_saleid. Same enriched shape as get_sales_details (see file header — the two
-- RPCs are near-identical per the frontend contract, different call sites). p_communityid kept as
-- a compat arg only (unused).
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_sales_homepage(p_userid uuid, p_communityid int8, p_saleid uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'get_sales_homepage: no authenticated user';
  end if;
  if not exists (select 1 from public.sale where id = p_saleid and isdeleted = false) then
    return null;
  end if;
  return public._sale_detail_jsonb(p_saleid, v_uid);
end;
$$;

comment on function public.get_sales_homepage(uuid, int8, uuid) is
  'Single sale detail JSON for sale_details_widget on load (see _sale_detail_jsonb). p_communityid unused (compat).';

revoke all on function public.get_sales_homepage(uuid, int8, uuid) from public;
grant execute on function public.get_sales_homepage(uuid, int8, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- (e) get_sales_home_data (getSaleHomePage custom action) — EXACT frontend contract: p_userid,
-- p_category, p_type, p_distance, p_sort, p_communityid. THE browse feed — category + sale_type +
-- distance(kms) + sort (Newest/Closest) ALL applied server-side (see file header). Block-filtered.
-- Empty-string p_category/p_type/p_sort and non-positive p_distance are treated as "no filter" /
-- default sort ('Newest'). p_communityid kept as a compat arg only (unused).
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_sales_home_data(
  p_userid       uuid,
  p_category     text,
  p_type         text,
  p_distance     int4,
  p_sort         text,
  p_communityid  int8,
  p_limit        int4 default 20,
  p_offset       int4 default 0
)
returns table (
  id             uuid,
  created_at     timestamptz,
  title          text,
  description    text,
  sale_category  text,
  e_price_type   public.e_price_type,
  price          int8,
  location       text,
  e_sale_type    public.e_sale_type,
  created_by     uuid,
  city           text,
  latitude       float8,
  longitude      float8,
  distance_km    float8
)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid         uuid := auth.uid();
  v_my_location extensions.geography;
  v_limit       int4 := least(greatest(p_limit, 1), 100);
  v_offset      int4 := greatest(p_offset, 0);
begin
  if v_uid is null then
    raise exception 'get_sales_home_data: no authenticated user';
  end if;

  select ul.location into v_my_location from public.user_locations ul where ul.id = v_uid;

  return query
  with candidates as (
    select
      s.id, s.created_at, s.title, s.description, s.sale_category, s.e_price_type, s.price,
      s.location, s.e_sale_type, s.created_by, s.city, s.latitude, s.longitude,
      case when v_my_location is null then null
        else extensions.ST_Distance(s.location_point, v_my_location) / 1000.0
      end as distance_km
    from public.sale s
    where s.isdeleted = false
      and not public.is_blocked_pair(v_uid, s.created_by)
      and (p_category is null or p_category = '' or s.sale_category = p_category)
      and (p_type is null or p_type = '' or p_type = 'all' or s.e_sale_type::text = p_type)
      and (
        p_distance is null or p_distance <= 0 or v_my_location is null
        or extensions.ST_DWithin(s.location_point, v_my_location, p_distance * 1000)
      )
  )
  select * from candidates
  order by
    case when p_sort = 'Closest' then distance_km end asc nulls last,
    case when p_sort = 'Closest' then null else created_at end desc,
    id desc
  limit v_limit offset v_offset;
end;
$$;

comment on function public.get_sales_home_data(uuid, text, text, int4, text, int8, int4, int4) is
  'Marketplace browse feed: category + sale_type + distance(kms) + sort (Newest/Closest), all server-side. Block-filtered, offset-paginated (Closest sort is not keyset-friendly). p_communityid unused (compat).';

revoke all on function public.get_sales_home_data(uuid, text, text, int4, text, int8, int4, int4) from public;
grant execute on function public.get_sales_home_data(uuid, text, text, int4, text, int8, int4, int4) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- (f) get_sale_images (GetSalesImagesCall) — EXACT frontend contract: p_saleid.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_sale_images(p_saleid uuid)
returns setof public.sale_images
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
begin
  if auth.uid() is null then
    raise exception 'get_sale_images: no authenticated user';
  end if;

  return query
  select si.* from public.sale_images si where si.sale_id = p_saleid order by si.created_at asc;
end;
$$;

comment on function public.get_sale_images(uuid) is
  'All sale_images rows for p_saleid (edit-with-photos prefill).';

revoke all on function public.get_sale_images(uuid) from public;
grant execute on function public.get_sale_images(uuid) to authenticated;

commit;

-- 0071_search_functions_global.sql
-- Purpose: Batch 7 (Search) — get_search_all_data(), the main global-search RPC behind the search
-- screen's live-typing box. Returns one JSON object with six arrays (posts/sales/events/groups/
-- nearby_users/business_pages), per docs/features/12-search-tags.md §4. p_userid/p_communityid are
-- ACCEPTED-BUT-IGNORED (auth.uid() used regardless, matching the user_follow()/get_followers_
-- nearby() precedent, 0018/0019) — never trust a caller-supplied "which user is me" argument.
--
-- Matching (docs/database/06-tables-notifications-search-moderation.md's recommendation, TODO
-- (confirm) with product per the feature doc §8.1): trigram-backed ILIKE '%term%' substring match
-- against each entity's searchable text column(s) (0069's GIN indexes). p_type narrows to one
-- section ('all' returns every section); sale filters (p_category/p_sale_type/p_sort/p_distance)
-- apply only within the sales array, matching get_sales_home_data's own filter semantics (0047).
-- Each section is capped at p_limit rows (default 20) — NOT full keyset pagination (the frontend
-- calls this on every keystroke with no pagination args), but still backend-limited per
-- docs/decisions.md (2026-07-19, "Pagination & filtering").
--
-- Visibility / blocking: posts respect can_view_post_self (see_post_access); sales/events/groups/
-- business_pages are filtered to is_deleted=false / isdeleted=false / active-lifecycle only
-- (no per-row community/ownership gate beyond that, matching the sale/event/group/business list
-- RPC precedent — block-filtering is enforced per-row via is_blocked_pair against each entity's
-- owner/author). nearby_users excludes the caller and any user in a block relationship.

begin;

create or replace function public.get_search_all_data(
  p_search_text  text,
  p_userid       uuid default null,             -- ignored; auth.uid() used
  p_type         text default 'all',            -- 'all'/'post'/'neighbourhood'/'business'/'group'/'event'/'sale'
  p_category     text default 'All categories', -- sale filter, only applied when p_type in ('all','sale')
  p_sale_type    text default 'Fixed',           -- sale filter
  p_sort         text default 'Newest',          -- sale filter: 'Newest' or 'Closest'
  p_distance     int4 default 10,                -- sale filter, km
  p_limit        int4 default 20,
  p_communityid  int8 default null              -- compat arg only, unused
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid       uuid := auth.uid();
  v_term      text := coalesce(btrim(p_search_text), '');
  v_pattern   text := '%' || v_term || '%';
  v_want_all  boolean := (p_type is null or p_type = 'all');
  v_lim       int4 := least(greatest(p_limit, 1), 50);
  v_loc       extensions.geography;
begin
  if v_uid is null then
    raise exception 'get_search_all_data: no authenticated user';
  end if;

  select location into v_loc from public.user_locations where id = v_uid;

  return jsonb_build_object(
    'posts', case when v_want_all or p_type = 'post' then (
      select coalesce(jsonb_agg(row_to_json(p)), '[]'::jsonb) from (
        select po.*
        from public.post po
        where po.is_deleted = false
          and coalesce(po.content_text, po.content) ilike v_pattern
          and not public.is_blocked_pair(v_uid, po.user_id)
          and public.can_view_post(v_uid, po.id)
        order by po.created_at desc
        limit v_lim
      ) p
    ) else '[]'::jsonb end,

    'sales', case when v_want_all or p_type = 'sale' then (
      select coalesce(jsonb_agg(row_to_json(s)), '[]'::jsonb) from (
        select sa.*,
          case when v_loc is not null then extensions.ST_Distance(v_loc, sa.location_point) / 1000.0 else null end as distance_km
        from public.sale sa
        where sa.isdeleted = false
          and (sa.title ilike v_pattern or sa.description ilike v_pattern)
          and (p_category is null or p_category = '' or p_category = 'All categories' or sa.sale_category = p_category)
          and (p_sale_type is null or p_sale_type = '' or p_sale_type = 'all' or sa.e_sale_type::text = p_sale_type)
          and not public.is_blocked_pair(v_uid, sa.created_by)
          and (
            p_distance is null or p_distance <= 0 or v_loc is null
            or extensions.ST_DWithin(sa.location_point, v_loc, p_distance * 1000)
          )
        order by case when p_sort = 'Closest' and v_loc is not null
                    then extensions.ST_Distance(v_loc, sa.location_point) end asc nulls last,
                 sa.created_at desc
        limit v_lim
      ) s
    ) else '[]'::jsonb end,

    'events', case when v_want_all or p_type = 'event' then (
      select coalesce(jsonb_agg(row_to_json(e)), '[]'::jsonb) from (
        select ep.*
        from public.event_page ep
        where ep.is_deleted = false
          and ep.name ilike v_pattern
          and not public.is_blocked_pair(v_uid, ep.admin_user)
        order by ep.created_at desc
        limit v_lim
      ) e
    ) else '[]'::jsonb end,

    'groups', case when v_want_all or p_type = 'group' then (
      select coalesce(jsonb_agg(row_to_json(g)), '[]'::jsonb) from (
        select gr.*
        from public."group" gr
        where gr.isdeleted = false
          and gr.name ilike v_pattern
          and not public.is_blocked_pair(v_uid, gr.created_by)
        order by gr.created_at desc
        limit v_lim
      ) g
    ) else '[]'::jsonb end,

    'nearby_users', case when v_want_all or p_type = 'neighbourhood' then (
      select coalesce(jsonb_agg(row_to_json(u)), '[]'::jsonb) from (
        select pr.id, pr.name, pr.profile_picture, pr.city
        from public.public_user_profile pr
        where pr.id <> v_uid
          and pr.name ilike v_pattern
          and not public.is_blocked_pair(v_uid, pr.id)
        order by pr.name asc
        limit v_lim
      ) u
    ) else '[]'::jsonb end,

    'business_pages', case when v_want_all or p_type = 'business' then (
      select coalesce(jsonb_agg(row_to_json(b)), '[]'::jsonb) from (
        select bp.*
        from public.business_page bp
        where bp.is_deleted = false
          and bp.name ilike v_pattern
          and not public.is_blocked_pair(v_uid, bp.admin_user)
        order by bp.created_at desc
        limit v_lim
      ) b
    ) else '[]'::jsonb end
  );
end;
$$;

comment on function public.get_search_all_data(text, uuid, text, text, text, text, int4, int4, int8) is
  'SECURITY DEFINER: global search across posts/sales/events/groups/nearby_users/business_pages, trigram-matched, block-filtered, p_type-narrowed. p_userid ignored; p_communityid unused (compat).';

revoke all on function public.get_search_all_data(text, uuid, text, text, text, text, int4, int4, int8) from public;
grant execute on function public.get_search_all_data(text, uuid, text, text, text, text, int4, int4, int8) to authenticated;

commit;

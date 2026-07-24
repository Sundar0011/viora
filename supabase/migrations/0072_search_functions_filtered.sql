-- 0072_search_functions_filtered.sql
-- Purpose: Batch 7 (Search) — get_search_data(), the "refine by explicit id set" companion to
-- get_search_all_data() (0071), per docs/database/09-rpc-inventory.md §12. Same six-array JSON
-- shape, but restricted to `p_ids` within the single section named by `p_type` (every other
-- section returns empty) — the caller already knows the ids (e.g. re-applying sale filters to an
-- in-hand result set), per docs/features/12-search-tags.md §4/§8.4 (exact caller/origin of p_ids
-- is unconfirmed in the frontend — TODO(confirm)). Also returns a top-level `eventData` array
-- (same rows as `events`, duplicated at the top level) per the documented return shape — the
-- frontend's own reason for a second top-level copy is unconfirmed (TODO(confirm), feature doc
-- §4 citation "plus top-level eventData list").
--
-- p_userid/p_community are ACCEPTED-BUT-IGNORED (auth.uid() used regardless, matching the
-- get_search_all_data/user_follow precedent) — never trust a caller-supplied "which user is me".

begin;

create or replace function public.get_search_data(
  p_ids       uuid[],
  p_userid    uuid default null,  -- ignored; auth.uid() used
  p_type      text default 'post',
  p_community int8 default null  -- compat arg only, unused
)
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
    raise exception 'get_search_data: no authenticated user';
  end if;

  return jsonb_build_object(
    'posts', case when p_type = 'post' then (
      select coalesce(jsonb_agg(row_to_json(p)), '[]'::jsonb) from (
        select po.* from public.post po
        where po.id = any(p_ids) and po.is_deleted = false
          and not public.is_blocked_pair(v_uid, po.user_id)
          and public.can_view_post(v_uid, po.id)
      ) p
    ) else '[]'::jsonb end,

    'sales', case when p_type = 'sale' then (
      select coalesce(jsonb_agg(row_to_json(s)), '[]'::jsonb) from (
        select sa.* from public.sale sa
        where sa.id = any(p_ids) and sa.isdeleted = false
          and not public.is_blocked_pair(v_uid, sa.created_by)
      ) s
    ) else '[]'::jsonb end,

    'events', case when p_type = 'event' then (
      select coalesce(jsonb_agg(row_to_json(e)), '[]'::jsonb) from (
        select ep.* from public.event_page ep
        where ep.id = any(p_ids) and ep.is_deleted = false
          and not public.is_blocked_pair(v_uid, ep.admin_user)
      ) e
    ) else '[]'::jsonb end,

    'eventData', case when p_type = 'event' then (
      select coalesce(jsonb_agg(row_to_json(e)), '[]'::jsonb) from (
        select ep.* from public.event_page ep
        where ep.id = any(p_ids) and ep.is_deleted = false
          and not public.is_blocked_pair(v_uid, ep.admin_user)
      ) e
    ) else '[]'::jsonb end,

    'groups', case when p_type = 'group' then (
      select coalesce(jsonb_agg(row_to_json(g)), '[]'::jsonb) from (
        select gr.* from public."group" gr
        where gr.id = any(p_ids) and gr.isdeleted = false
          and not public.is_blocked_pair(v_uid, gr.created_by)
      ) g
    ) else '[]'::jsonb end,

    'nearby_users', case when p_type = 'neighbourhood' then (
      select coalesce(jsonb_agg(row_to_json(u)), '[]'::jsonb) from (
        select pr.id, pr.name, pr.profile_picture, pr.city
        from public.public_user_profile pr
        where pr.id = any(p_ids) and pr.id <> v_uid
          and not public.is_blocked_pair(v_uid, pr.id)
      ) u
    ) else '[]'::jsonb end,

    'business_pages', case when p_type = 'business' then (
      select coalesce(jsonb_agg(row_to_json(b)), '[]'::jsonb) from (
        select bp.* from public.business_page bp
        where bp.id = any(p_ids) and bp.is_deleted = false
          and not public.is_blocked_pair(v_uid, bp.admin_user)
      ) b
    ) else '[]'::jsonb end
  );
end;
$$;

comment on function public.get_search_data(uuid[], uuid, text, int8) is
  'SECURITY DEFINER: refine-by-id-set companion to get_search_all_data(); populates only the p_type-named section (+ duplicate top-level eventData for event). p_userid ignored; p_community unused (compat).';

revoke all on function public.get_search_data(uuid[], uuid, text, int8) from public;
grant execute on function public.get_search_data(uuid[], uuid, text, int8) to authenticated;

commit;

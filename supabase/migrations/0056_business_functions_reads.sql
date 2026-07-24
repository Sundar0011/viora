-- 0056_business_functions_reads.sql
-- Purpose: Batch 6 (Business Pages & Promotions) read RPCs, preserving the ACTUAL frontend REST
-- endpoint names from docs/features/08-business-promotions.md §4 (`rpc/<name>`), not the loose
-- widget-call-class prose ("BusinessHomepageCall" etc. are Dart wrapper names, not the RPC name):
--   get_my_business, get_business_details, get_all_business, get_specific_business,
--   get_promotion_plan, get_contact_count.
--
-- (a) public._business_promotion_status() — internal: derives the UI-facing promotion_status from
--     business_promote.status + plan_end_date (feature doc §8.1's open question). A 'live'
--     promotion whose plan_end_date has already passed is derived as 'ended' at READ TIME even
--     before any cron/admin flips the stored column — closes part of the feature doc's "auto-ended"
--     gap (§7) without requiring a scheduled job in this batch. -- TODO(confirm): whether a
--     cron/trigger should ALSO write status='ended' back to the row (recommended, out of scope here
--     — no pg_cron job requested for this batch).
-- (b) get_my_business — caller-owned pages + derived promotion_status + plan_end_date.
-- (c) get_business_details — full public profile + promotion/contact context for one page.
-- (d) get_all_business — app-wide active/non-deleted business directory, block-filtered, paginated.
-- (e) get_specific_business — single active page (block-filtered), no promotion context.
-- (f) get_promotion_plan — current promotion + plan details for a page; owner/admin only.
-- (g) get_contact_count — contacted-user count for a page; owner/admin only (table-doc RLS intent).
--     -- TODO(confirm): the feature doc's business_home_page screen implies a PUBLIC "N people
--     contacted" count is shown to any visitor, which would conflict with this stricter owner/admin
--     gate. Chose the stricter default (CLAUDE.md §6 "deny by default"); flagged in the RLS review
--     checklist for product to confirm.
--
-- p_userid/p_communityid args are ACCEPTED BUT IGNORED where the doc marks them compat-only —
-- auth.uid() is used internally regardless of the caller-supplied value (Batch 3 precedent).
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5: validates auth.uid() inside, pins
-- search_path = public, pg_temp, REVOKEs EXECUTE from PUBLIC, GRANTs only to authenticated.

begin;

-- ---------------------------------------------------------------------------------------------
-- (a) _business_promotion_status — internal derivation helper, called only by the read RPCs below.
-- ---------------------------------------------------------------------------------------------
create or replace function public._business_promotion_status(p_status text, p_plan_end_date timestamptz)
returns text
language sql
stable
security invoker
set search_path = public, pg_temp
as $$
  select case
    when p_status is null then null
    when p_status = 'live' and p_plan_end_date is not null and p_plan_end_date < now() then 'ended'
    else p_status
  end;
$$;

comment on function public._business_promotion_status(text, timestamptz) is
  'Derives the UI-facing promotion_status: a live promotion past plan_end_date reads as ended. Internal helper.';

revoke all on function public._business_promotion_status(text, timestamptz) from public, anon, authenticated;

-- ---------------------------------------------------------------------------------------------
-- (b) get_my_business (GetMyBusinessCall -> rpc/get_my_business) — caller's own pages (any
-- is_deleted/business_status state — owner sees everything), each enriched with the derived
-- promotion_status + plan_end_date from its most recent business_promote row (at most one per
-- owner per page, per the UNIQUE (business_page_id, admin_user) constraint, 0054).
-- p_userid is accepted but IGNORED — auth.uid() is used regardless (Batch 3 precedent).
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_my_business(
  p_userid       uuid,
  p_communityid  int8 default null -- compat arg only, unused
)
returns table (
  id                uuid,
  name              text,
  bio               text,
  profile_picture   text,
  cover_image       text,
  services          text[],
  website_link      text,
  email             text,
  phonenumber       text,
  is_deleted        boolean,
  business_status   public.lifecycle_status,
  promotion_status  text,
  plan_end_date     timestamptz,
  created_at        timestamptz
)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'get_my_business: no authenticated user';
  end if;

  return query
  select
    bp.id, bp.name, bp.bio, bp.profile_picture, bp.cover_image, bp.services,
    bp.website_link, bp.email, bp.phonenumber, bp.is_deleted, bp.business_status,
    public._business_promotion_status(bpr.status, bpr.plan_end_date),
    bpr.plan_end_date,
    bp.created_at
  from public.business_page bp
  left join public.business_promote bpr
    on bpr.business_page_id = bp.id and bpr.admin_user = v_uid
  where bp.admin_user = v_uid
  order by bp.created_at desc;
end;
$$;

comment on function public.get_my_business(uuid, int8) is
  'Owner''s own business pages + derived promotion_status/plan_end_date. p_userid ignored (auth.uid() used); p_communityid unused (compat).';

revoke all on function public.get_my_business(uuid, int8) from public;
grant execute on function public.get_my_business(uuid, int8) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- (c) get_business_details (BusinessHomepageCall -> rpc/get_business_details) — full profile for
-- the business_home_page screen. Block-filtered against the page owner; owner/admin also see
-- promotion_status (visitors do not — matches the business_promote SELECT RLS intent). p_userid
-- accepted but IGNORED for auth purposes (auth.uid() used); still used for the is_owner flag.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_business_details(p_businessid uuid, p_userid uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid    uuid := auth.uid();
  v_owner  uuid;
  v_result jsonb;
begin
  if v_uid is null then
    raise exception 'get_business_details: no authenticated user';
  end if;

  select admin_user into v_owner from public.business_page where id = p_businessid;
  if v_owner is null then
    return null; -- not found
  end if;

  if public.is_blocked_pair(v_uid, v_owner) then
    return null;
  end if;

  select jsonb_build_object(
    'id', bp.id,
    'name', bp.name,
    'bio', bp.bio,
    'profile_picture', bp.profile_picture,
    'cover_image', bp.cover_image,
    'services', bp.services,
    'website_link', bp.website_link,
    'email', bp.email,
    'phonenumber', bp.phonenumber,
    'is_deleted', bp.is_deleted,
    'business_status', bp.business_status,
    'admin_user', bp.admin_user,
    'is_owner', (bp.admin_user = v_uid),
    'promotion_status', case
      when bp.admin_user = v_uid or (select public.is_admin())
        then public._business_promotion_status(bpr.status, bpr.plan_end_date)
      else null
    end,
    'plan_end_date', case
      when bp.admin_user = v_uid or (select public.is_admin()) then bpr.plan_end_date
      else null
    end
  )
  into v_result
  from public.business_page bp
  left join public.business_promote bpr
    on bpr.business_page_id = bp.id and bpr.admin_user = bp.admin_user
  where bp.id = p_businessid
    and (bp.admin_user = v_uid or (bp.is_deleted = false and bp.business_status = 'active'));

  return v_result;
end;
$$;

comment on function public.get_business_details(uuid, uuid) is
  'Full business profile for business_home_page. Block-filtered; promotion_status only shown to owner/admin. p_userid used for is_owner only, not for auth.';

revoke all on function public.get_business_details(uuid, uuid) from public;
grant execute on function public.get_business_details(uuid, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- (d) get_all_business (GetBusinessCall -> rpc/get_all_business) — app-wide active/non-deleted
-- directory, block-filtered against each page's owner, keyset-paginated (DEFAULT args, backward
-- compatible). p_userid/p_communityid accepted per the frontend contract; p_userid is used only
-- for the block filter reference point (validated = auth.uid() internally).
-- -- TODO(frontend): wire pagination args once the discovery list paginates.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_all_business(
  p_userid            uuid,
  p_communityid       int8 default null, -- compat arg only, unused
  p_limit             int4 default 20,
  p_after_created_at  timestamptz default null,
  p_after_id          uuid default null
)
returns setof public.business_page
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'get_all_business: no authenticated user';
  end if;

  return query
  select bp.*
  from public.business_page bp
  where bp.is_deleted = false
    and bp.business_status = 'active'
    and not public.is_blocked_pair(v_uid, bp.admin_user)
    and (
      p_after_created_at is null
      or (bp.created_at, bp.id) < (p_after_created_at, p_after_id)
    )
  order by bp.created_at desc, bp.id desc
  limit least(greatest(p_limit, 1), 100);
end;
$$;

comment on function public.get_all_business(uuid, int8, int4, timestamptz, uuid) is
  'App-wide active business directory, block-filtered, paginated. p_communityid unused (compat).';

revoke all on function public.get_all_business(uuid, int8, int4, timestamptz, uuid) from public;
grant execute on function public.get_all_business(uuid, int8, int4, timestamptz, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- (e) get_specific_business (GetSpecifiBusinessCall -> rpc/get_specific_business) — single page,
-- block-filtered, visible if active/non-deleted OR the caller is the owner.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_specific_business(p_userid uuid, p_communityid int8, p_businessid uuid)
returns public.business_page
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid  uuid := auth.uid();
  v_page public.business_page;
begin
  if v_uid is null then
    raise exception 'get_specific_business: no authenticated user';
  end if;

  select bp.* into v_page
  from public.business_page bp
  where bp.id = p_businessid
    and not public.is_blocked_pair(v_uid, bp.admin_user)
    and (bp.admin_user = v_uid or (bp.is_deleted = false and bp.business_status = 'active'));

  return v_page;
end;
$$;

comment on function public.get_specific_business(uuid, int8, uuid) is
  'Single business page, block-filtered, visible if active/non-deleted or caller is owner. p_communityid unused (compat).';

revoke all on function public.get_specific_business(uuid, int8, uuid) from public;
grant execute on function public.get_specific_business(uuid, int8, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- (f) get_promotion_plan (GetPromotionplanCall -> rpc/get_promotion_plan) — current
-- business_promote row + joined plan details for a page. Owner or platform admin only (matches
-- business_promote's SELECT RLS intent); returns null for anyone else instead of raising, so a
-- non-owner call fails closed without erroring the screen.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_promotion_plan(p_businessid uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid    uuid := auth.uid();
  v_owner  uuid;
  v_result jsonb;
begin
  if v_uid is null then
    raise exception 'get_promotion_plan: no authenticated user';
  end if;

  select admin_user into v_owner from public.business_page where id = p_businessid;
  if v_owner is null then
    return null;
  end if;

  if v_owner <> v_uid and not public.is_admin() then
    return null;
  end if;

  select jsonb_build_object(
    'id', bpr.id,
    'business_page_id', bpr.business_page_id,
    'status', bpr.status,
    'promotion_status', public._business_promotion_status(bpr.status, bpr.plan_end_date),
    'reference_number', bpr.reference_number,
    'receipt', bpr.receipt,
    'plan_start_date', bpr.plan_start_date,
    'plan_end_date', bpr.plan_end_date,
    'plan', jsonb_build_object(
      'id', plan.id,
      'days_count', plan.days_count,
      'price', plan.price,
      'currency', plan.currency,
      'image_url', plan.image_url
    )
  )
  into v_result
  from public.business_promote bpr
  join public.business_promote_plans plan on plan.id = bpr.business_promote_plans
  where bpr.business_page_id = p_businessid and bpr.admin_user = v_owner;

  return v_result;
end;
$$;

comment on function public.get_promotion_plan(uuid) is
  'Current promotion + plan details for a business page. Owner/admin only; returns null otherwise (fail closed, no error).';

revoke all on function public.get_promotion_plan(uuid) from public;
grant execute on function public.get_promotion_plan(uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- (g) get_contact_count (GetContactedCountCall -> rpc/get_contact_count) — count of DISTINCT
-- users who contacted a page (business_contacted is one row per user, per 0054's UNIQUE
-- constraint). Owner/admin only per the table-doc RLS intent; returns 0 (fail closed, no error)
-- for anyone else. -- TODO(confirm): see file header — may need to be public per the feature doc's
-- business_home_page "contacted count" display.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_contact_count(p_businessid uuid)
returns int8
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid   uuid := auth.uid();
  v_owner uuid;
begin
  if v_uid is null then
    raise exception 'get_contact_count: no authenticated user';
  end if;

  select admin_user into v_owner from public.business_page where id = p_businessid;
  if v_owner is null or (v_owner <> v_uid and not public.is_admin()) then
    return 0;
  end if;

  return (select count(*) from public.business_contacted where business_page_id = p_businessid);
end;
$$;

comment on function public.get_contact_count(uuid) is
  'Count of distinct users who contacted a business page. Owner/admin only; returns 0 otherwise (fail closed).';

revoke all on function public.get_contact_count(uuid) from public;
grant execute on function public.get_contact_count(uuid) to authenticated;

commit;

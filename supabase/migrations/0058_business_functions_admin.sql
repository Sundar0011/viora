-- 0058_business_functions_admin.sql
-- Purpose: Batch 6 admin-only promotion moderation RPC. PLATFORM admin (is_admin() JWT claim) only
-- — do NOT confuse with business_promote.admin_user (the page owner/submitter, see 0054's header
-- note). Audited per CLAUDE.md §6.5 (payments + moderation action).

begin;

-- ---------------------------------------------------------------------------------------------
-- admin_set_promotion_status (admin_set_promotion_status) — platform-admin-only transition of a
-- promotion's status to 'live'/'ended'/'rejected'/'mismatch', optionally setting plan_start_date/
-- plan_end_date (required in practice for 'live', per feature doc §5 step 4 "Approve -> status
-- live, set plan_start_date + plan_end_date = start + plan days_count" — the days_count math is
-- left to the caller/admin console, not computed here, since no plan lookup is passed).
-- p_status is NOT constrained to a hard enum at the type level (business_promote.status stays text
-- per docs/decisions.md "Unknown dropdown value sets"), but IS validated against the confirmed
-- admin-settable value set inside this function.
-- ---------------------------------------------------------------------------------------------
create or replace function public.admin_set_promotion_status(
  p_promote_id       uuid,
  p_status           text,
  p_plan_start_date  timestamptz default null,
  p_plan_end_date    timestamptz default null
)
returns public.business_promote
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid   uuid := auth.uid();
  v_promo public.business_promote;
begin
  if v_uid is null then
    raise exception 'admin_set_promotion_status: no authenticated user';
  end if;

  if not public.is_admin() then
    raise exception 'admin_set_promotion_status: caller is not a platform admin';
  end if;

  if p_status not in ('live', 'ended', 'rejected', 'mismatch') then
    raise exception 'admin_set_promotion_status: invalid status %', p_status;
  end if;

  update public.business_promote
  set status           = p_status,
      plan_start_date  = coalesce(p_plan_start_date, plan_start_date),
      plan_end_date    = coalesce(p_plan_end_date, plan_end_date)
  where id = p_promote_id
  returning * into v_promo;

  if not found then
    raise exception 'admin_set_promotion_status: promotion not found';
  end if;

  insert into public.audit_log (actor_id, action, target_table, target_id, details)
  values (
    v_uid, 'admin_set_promotion_status', 'business_promote', p_promote_id,
    jsonb_build_object(
      'status', p_status,
      'plan_start_date', p_plan_start_date,
      'plan_end_date', p_plan_end_date
    )
  );

  return v_promo;
end;
$$;

comment on function public.admin_set_promotion_status(uuid, text, timestamptz, timestamptz) is
  'SECURITY DEFINER: PLATFORM admin-only (is_admin()) transition of business_promote.status to live/ended/rejected/mismatch + dates. Audited.';

revoke all on function public.admin_set_promotion_status(uuid, text, timestamptz, timestamptz) from public;
grant execute on function public.admin_set_promotion_status(uuid, text, timestamptz, timestamptz) to authenticated;

commit;

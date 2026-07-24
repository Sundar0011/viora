-- 0075_reports_backfill_report_business.sql
-- Purpose: Batch 7 (Moderation) — now that `reports` exists (0073), replace the Batch-6
-- forward-compat stubs report_business()/unreport_business() (0057_business_functions_writes.sql)
-- with DIRECT static queries, same backfill pattern as 0021/0042/0055 (activate a forward-compat
-- helper once its dependency table lands, in its own dedicated migration, not as a side-effect of
-- creating the table).
--
-- Verified the stub's assumed column shape against the REAL reports table (0073): `community_id,
-- reported_by_user, report_type, business_page_id, reason` all exist with matching types — the
-- guess flagged in docs/rls-policies-draft.md ("Batch 6" review checklist, "TODO(confirm):
-- reconcile column names with the Moderation batch") turned out correct, so this is a pure
-- dynamic-SQL-removal backfill, not a column-name fix.
--
-- create or replace with the SAME signature — every existing grant is preserved automatically;
-- grants are re-asserted explicitly below anyway, matching the 0055 precedent.

begin;

create or replace function public.report_business(p_business_id uuid, p_reason text)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
  v_id  uuid;
begin
  if v_uid is null then
    raise exception 'report_business: no authenticated user';
  end if;
  if not exists (select 1 from public.business_page where id = p_business_id) then
    raise exception 'report_business: business page not found';
  end if;

  insert into public.reports (reported_by_user, report_type, business_page_id, reason)
  values (v_uid, 'business', p_business_id, nullif(p_reason, ''))
  returning id into v_id;

  return v_id;
end;
$$;

comment on function public.report_business(uuid, text) is
  'SECURITY DEFINER: inserts a business report against public.reports (backfilled, was a forward-compat stub — see 0057).';

revoke all on function public.report_business(uuid, text) from public;
grant execute on function public.report_business(uuid, text) to authenticated;

create or replace function public.unreport_business(p_report_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'unreport_business: no authenticated user';
  end if;

  delete from public.reports where id = p_report_id and reported_by_user = v_uid;
end;
$$;

comment on function public.unreport_business(uuid) is
  'SECURITY DEFINER: deletes the caller''s own business report (backfilled, was a forward-compat stub — see 0057).';

revoke all on function public.unreport_business(uuid) from public;
grant execute on function public.unreport_business(uuid) to authenticated;

commit;

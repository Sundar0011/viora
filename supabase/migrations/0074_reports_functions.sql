-- 0074_reports_functions.sql
-- Purpose: Batch 7 (Moderation) — report_content() (the general-purpose polymorphic report RPC,
-- replacing the client's direct ReportsTable().insert() across post/account/event/group/sale/
-- message dialogs) + two admin-only moderation-queue RPCs (get_reports/set_report_status).
-- business_page reporting keeps its OWN dedicated report_business()/unreport_business() (0057),
-- now backfilled to real inserts against this table in 0075 — NOT redefined here.
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5: validates auth.uid() inside, pins
-- search_path = public, pg_temp, REVOKEs EXECUTE from PUBLIC, GRANTs only to authenticated.

begin;

-- ---------------------------------------------------------------------------------------------
-- report_content — polymorphic report insert. Forces reported_by_user = auth.uid() (never trusts
-- the "Report & Block" dialog's own blockedByUserId arg, per feature doc §8.4). Coerces the
-- frontend's observed empty-string `reported_user: ''` to NULL (feature doc §8.2). Validates that
-- exactly the target FK matching p_report_type is populated (and that the target row exists),
-- per docs/database/06-tables-notifications-search-moderation.md's RLS intent. report_status
-- defaults to 'pending' (column default) regardless of whether the caller sends one (matches the
-- frontend's own inconsistency — only comp_report_post sends it explicitly).
-- ---------------------------------------------------------------------------------------------
create or replace function public.report_content(
  p_report_type    text,
  p_reason         text,
  p_target_id      uuid default null,
  p_reported_user  uuid default null,
  p_community_id   int8 default null -- compat arg only, unused
)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid            uuid := auth.uid();
  v_id             uuid;
  v_reported_user  uuid;
  v_post_id        uuid;
  v_comment_id     uuid;
  v_group_id       uuid;
  v_business_id    uuid;
  v_event_id       uuid;
  v_sale_id        uuid;
begin
  if v_uid is null then
    raise exception 'report_content: no authenticated user';
  end if;
  if p_reason is null or btrim(p_reason) = '' then
    raise exception 'report_content: reason is required';
  end if;

  -- Coerce the frontend's observed empty-string reported_user to NULL (feature doc §8.2).
  v_reported_user := nullif(p_reported_user::text, '')::uuid;

  case p_report_type
    when 'post' then
      if not exists (select 1 from public.post where id = p_target_id) then
        raise exception 'report_content: post not found';
      end if;
      v_post_id := p_target_id;
    when 'group' then
      if not exists (select 1 from public."group" where id = p_target_id) then
        raise exception 'report_content: group not found';
      end if;
      v_group_id := p_target_id;
    when 'business' then
      if not exists (select 1 from public.business_page where id = p_target_id) then
        raise exception 'report_content: business page not found';
      end if;
      v_business_id := p_target_id;
    when 'event' then
      if not exists (select 1 from public.event_page where id = p_target_id) then
        raise exception 'report_content: event not found';
      end if;
      v_event_id := p_target_id;
    when 'sale' then
      if not exists (select 1 from public.sale where id = p_target_id) then
        raise exception 'report_content: sale listing not found';
      end if;
      v_sale_id := p_target_id;
    when 'account', 'message', '' then
      -- Account/message reports carry no entity FK — only reported_user (coerced above).
      null;
    else
      raise exception 'report_content: unrecognized report_type %', p_report_type;
  end case;

  insert into public.reports (
    reported_by_user, reported_user, reason, report_type,
    post_id, comment_id, group_id, business_page_id, event_id, sale_id
  )
  values (
    v_uid, v_reported_user, p_reason, p_report_type,
    v_post_id, v_comment_id, v_group_id, v_business_id, v_event_id, v_sale_id
  )
  returning id into v_id;

  return v_id;
end;
$$;

comment on function public.report_content(text, text, uuid, uuid, int8) is
  'SECURITY DEFINER: polymorphic report insert (post/group/business/event/sale/account/message). Forces reported_by_user=auth.uid(); coerces reported_user='''' to NULL; validates target FK matches report_type. p_community_id unused (compat).';

revoke all on function public.report_content(text, text, uuid, uuid, int8) from public;
grant execute on function public.report_content(text, text, uuid, uuid, int8) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- get_reports — admin-only moderation queue read. Paginated (keyset on created_at/id), optional
-- report_status filter. -- TODO(confirm): exact shape the Operture admin app expects; this returns
-- the raw reports rows (setof public.reports) as the simplest defensible contract since no admin
-- screen exists in the Flutter frontend to reverse-engineer a JSON shape from (feature doc §1).
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_reports(
  p_status            text default null,
  p_limit             int4 default 20,
  p_after_created_at  timestamptz default null,
  p_after_id          uuid default null
)
returns setof public.reports
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
begin
  if not public.is_admin() then
    raise exception 'get_reports: caller is not an admin';
  end if;

  return query
  select r.*
  from public.reports r
  where (p_status is null or r.report_status = p_status)
    and (
      p_after_created_at is null
      or (r.created_at, r.id) < (p_after_created_at, p_after_id)
    )
  order by r.created_at desc, r.id desc
  limit least(greatest(p_limit, 1), 100);
end;
$$;

comment on function public.get_reports(text, int4, timestamptz, uuid) is
  'SECURITY DEFINER: admin-only (is_admin()) paginated moderation queue read, optional report_status filter.';

revoke all on function public.get_reports(text, int4, timestamptz, uuid) from public;
grant execute on function public.get_reports(text, int4, timestamptz, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- set_report_status — admin-only status transition (e.g. pending -> reviewed/resolved/dismissed;
-- exact full enum unconfirmed, kept as free text per docs/decisions.md "Unknown dropdown value
-- sets"). Audited per CLAUDE.md §6.5 (admin moderation decision).
-- ---------------------------------------------------------------------------------------------
create or replace function public.set_report_status(
  p_report_id  uuid,
  p_status     text
)
returns public.reports
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid  uuid := auth.uid();
  v_row  public.reports;
begin
  if v_uid is null then
    raise exception 'set_report_status: no authenticated user';
  end if;
  if not public.is_admin() then
    raise exception 'set_report_status: caller is not an admin';
  end if;
  if p_status is null or btrim(p_status) = '' then
    raise exception 'set_report_status: status is required';
  end if;

  update public.reports
  set report_status = p_status
  where id = p_report_id
  returning * into v_row;

  if not found then
    raise exception 'set_report_status: report not found';
  end if;

  insert into public.audit_log (actor_id, action, target_table, target_id, details)
  values (v_uid, 'set_report_status', 'reports', p_report_id, jsonb_build_object('status', p_status));

  return v_row;
end;
$$;

comment on function public.set_report_status(uuid, text) is
  'SECURITY DEFINER: admin-only (is_admin()) report_status transition. Audited.';

revoke all on function public.set_report_status(uuid, text) from public;
grant execute on function public.set_report_status(uuid, text) to authenticated;

commit;

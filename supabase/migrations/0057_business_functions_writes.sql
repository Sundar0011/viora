-- 0057_business_functions_writes.sql
-- Purpose: Batch 6 (Business Pages & Promotions) owner-scoped write RPCs — closes the CLAUDE.md
-- §6 direct-client-DML gap flagged in docs/features/08-business-promotions.md §4/§7
-- (business_page/business_promote/reports are currently mutated by direct `.insert`/`.update`).
--
-- Function names per THIS TASK's explicit instruction (supersedes docs/database/09-rpc-inventory.md
-- §8's earlier suggested names create_business/update_business/delete_business/restore_business/
-- submit_promotion/resubmit_promotion — matches the Batch 4 lesson "a task's literal instruction
-- wins over an earlier design doc's speculative naming"):
--   create_business_page / edit_business_page / delete_business_page / restore_business_page
--   create_or_update_promotion (single RPC covering both the "new" and "resubmit" upload_receipt
--     flows, per feature doc §5 steps 2 and 5 — both set status back to 'under review')
--   report_business / unreport_business
--
-- restore_business_page is NOT in the task's literal RPC list but IS required to close feature doc
-- §8.3's flagged gap ("comp_business_deleted UNDO matches on id only, no admin_user — anyone could
-- restore"): added as owner-scoped, matching docs/database/05-tables-business-chat.md's stated RLS
-- intent ("Restore must be owner-scoped"). Recorded here per CLAUDE.md §7 (smaller implementation
-- decision, not silently skipped).
--
-- reports table does NOT exist yet (Moderation is a later, not-yet-built batch — confirmed via
-- `grep -rn "create table.*reports" supabase/migrations/`, contrary to this task's prose which
-- assumed it already exists). report_business/unreport_business use the SAME forward-compat
-- dynamic-SQL + `undefined_table`-exception-guard pattern as is_business_page_owner's Batch-5 stub
-- (0052) / can_view_post's Batch-2 friends-check: they apply cleanly today (report silently
-- no-ops, returns null) and self-activate once the Moderation batch creates `reports`.
--
-- update_contacted keeps its EXACT frontend-observed arg order (p_userid, p_businessid,
-- p_contactedby, p_communityid — all originally required, no defaults, per the literal
-- UpdateContactedCall body) per docs/database/09-rpc-inventory.md §8.
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5. Only delete_business_page is audited
-- (destructive action, matches delete_event/delete_group precedent) — create/edit/restore/promote/
-- contact are everyday owner actions, not audited (also matches the Batch 5 precedent).

begin;

-- ---------------------------------------------------------------------------------------------
-- create_business_page — creator becomes admin_user (owner). business_status defaults to 'active'
-- at the DB level (0054) even though the frontend's insert path never sets it (feature doc §5 step
-- 2's documented gap — closed by the column default, not by this RPC).
-- ---------------------------------------------------------------------------------------------
create or replace function public.create_business_page(
  p_name           text,
  p_bio            text,
  p_services       text[],
  p_website_link   text,
  p_email          text,
  p_phonenumber    text,
  p_profile_picture text default null,
  p_cover_image    text default null,
  p_communityid    int8 default null -- compat arg only, unused
)
returns public.business_page
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid  uuid := auth.uid();
  v_page public.business_page;
begin
  if v_uid is null then
    raise exception 'create_business_page: no authenticated user';
  end if;
  if p_name is null or btrim(p_name) = '' then
    raise exception 'create_business_page: name is required';
  end if;

  insert into public.business_page (
    admin_user, name, bio, services, website_link, email, phonenumber,
    profile_picture, cover_image, is_deleted, business_status
  )
  values (
    v_uid, p_name, p_bio, coalesce(p_services, '{}'), p_website_link, p_email, p_phonenumber,
    p_profile_picture, p_cover_image, false, 'active'
  )
  returning * into v_page;

  return v_page;
end;
$$;

comment on function public.create_business_page(text, text, text[], text, text, text, text, text, int8) is
  'SECURITY DEFINER: creates a business page; creator becomes admin_user (owner). p_communityid unused (compat).';

revoke all on function public.create_business_page(text, text, text[], text, text, text, text, text, int8) from public;
grant execute on function public.create_business_page(text, text, text[], text, text, text, text, text, int8) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- edit_business_page — owner-only. Only provided (non-null) fields are updated. services uses a
-- NULL sentinel (not empty array) so an intentional "clear all services" edit is still possible by
-- passing an empty array explicitly.
-- ---------------------------------------------------------------------------------------------
create or replace function public.edit_business_page(
  p_business_id     uuid,
  p_name            text default null,
  p_bio             text default null,
  p_services        text[] default null,
  p_website_link    text default null,
  p_email           text default null,
  p_phonenumber     text default null,
  p_profile_picture text default null,
  p_cover_image     text default null
)
returns public.business_page
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid  uuid := auth.uid();
  v_page public.business_page;
begin
  if v_uid is null then
    raise exception 'edit_business_page: no authenticated user';
  end if;

  if not public.is_business_page_owner(p_business_id, v_uid) then
    raise exception 'edit_business_page: caller is not the business page owner';
  end if;

  update public.business_page set
    name             = coalesce(p_name, name),
    bio              = coalesce(p_bio, bio),
    services         = coalesce(p_services, services),
    website_link     = coalesce(p_website_link, website_link),
    email            = coalesce(p_email, email),
    phonenumber      = coalesce(p_phonenumber, phonenumber),
    profile_picture  = coalesce(p_profile_picture, profile_picture),
    cover_image      = coalesce(p_cover_image, cover_image)
  where id = p_business_id
  returning * into v_page;

  return v_page;
end;
$$;

comment on function public.edit_business_page(uuid, text, text, text[], text, text, text, text, text) is
  'SECURITY DEFINER: owner-only business page edit; only non-null args are applied.';

revoke all on function public.edit_business_page(uuid, text, text, text[], text, text, text, text, text) from public;
grant execute on function public.edit_business_page(uuid, text, text, text[], text, text, text, text, text) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- delete_business_page — soft delete only (is_deleted=true, business_status='removed'). Owner or
-- platform admin. Audited (destructive/moderation-adjacent action).
-- ---------------------------------------------------------------------------------------------
create or replace function public.delete_business_page(p_business_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'delete_business_page: no authenticated user';
  end if;

  if not (public.is_business_page_owner(p_business_id, v_uid) or public.is_admin()) then
    raise exception 'delete_business_page: caller is not the business page owner or an admin';
  end if;

  update public.business_page
  set is_deleted = true, business_status = 'removed'
  where id = p_business_id;

  insert into public.audit_log (actor_id, action, target_table, target_id, details)
  values (v_uid, 'delete_business_page', 'business_page', p_business_id, jsonb_build_object());
end;
$$;

comment on function public.delete_business_page(uuid) is
  'SECURITY DEFINER: owner/admin soft-delete of a business page. Audited.';

revoke all on function public.delete_business_page(uuid) from public;
grant execute on function public.delete_business_page(uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- restore_business_page (NEW, owner-scoped — closes feature doc §8.3's no-owner-check gap; see
-- file header) — undo a soft delete. Owner-only (unlike the frontend's literal id-only UPDATE).
-- ---------------------------------------------------------------------------------------------
create or replace function public.restore_business_page(p_business_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'restore_business_page: no authenticated user';
  end if;

  if not public.is_business_page_owner(p_business_id, v_uid) then
    raise exception 'restore_business_page: caller is not the business page owner';
  end if;

  update public.business_page
  set is_deleted = false, business_status = 'active'
  where id = p_business_id;
end;
$$;

comment on function public.restore_business_page(uuid) is
  'SECURITY DEFINER: owner-only restore of a soft-deleted business page (owner-scoped, NEW — see file header).';

revoke all on function public.restore_business_page(uuid) from public;
grant execute on function public.restore_business_page(uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- create_or_update_promotion (upload_receipt "new" + resubmit/mismatch flows) — owner-only.
-- UPSERTs on the UNIQUE (business_page_id, admin_user) constraint (0054). Always sets
-- status='under review' and CLEARS any prior plan_start_date/plan_end_date (a resubmit after
-- mismatch/rejection must go back through full admin review, not keep stale approval dates).
-- Client can never set status='live'/dates directly — those are admin_set_promotion_status-only.
-- ---------------------------------------------------------------------------------------------
create or replace function public.create_or_update_promotion(
  p_business_id       uuid,
  p_plan_id           int8,
  p_reference_number  int8,
  p_receipt           text default null
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
    raise exception 'create_or_update_promotion: no authenticated user';
  end if;

  if not public.is_business_page_owner(p_business_id, v_uid) then
    raise exception 'create_or_update_promotion: caller is not the business page owner';
  end if;

  if not exists (select 1 from public.business_promote_plans where id = p_plan_id) then
    raise exception 'create_or_update_promotion: plan not found';
  end if;

  insert into public.business_promote (
    business_page_id, business_promote_plans, reference_number, receipt,
    status, plan_start_date, plan_end_date, admin_user
  )
  values (
    p_business_id, p_plan_id, p_reference_number, p_receipt,
    'under review', null, null, v_uid
  )
  on conflict (business_page_id, admin_user) do update
    set business_promote_plans = excluded.business_promote_plans,
        reference_number       = excluded.reference_number,
        receipt                = coalesce(excluded.receipt, business_promote.receipt),
        status                 = 'under review',
        plan_start_date        = null,
        plan_end_date          = null
  returning * into v_promo;

  return v_promo;
end;
$$;

comment on function public.create_or_update_promotion(uuid, int8, int8, text) is
  'SECURITY DEFINER: owner-only. Upserts business_promote (create-new or resubmit-after-mismatch/rejection), always resetting status=under review and clearing plan dates.';

revoke all on function public.create_or_update_promotion(uuid, int8, int8, text) from public;
grant execute on function public.create_or_update_promotion(uuid, int8, int8, text) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- update_contacted (UpdateContactedCall -> rpc/update_contacted) — EXACT frontend arg order
-- (all originally required, no defaults). Upserts business_contacted (one row per contacting
-- user, per 0054's UNIQUE constraint), appending p_contactedby to last_contact_link if not already
-- present. p_userid accepted but IGNORED — auth.uid() used regardless (Batch 3 precedent).
-- p_contactedby is NOT constrained to a fixed enum (kept free text per docs/decisions.md 2026-07-19
-- "Unknown dropdown value sets ... store as plain text").
-- ---------------------------------------------------------------------------------------------
create or replace function public.update_contacted(p_userid uuid, p_businessid uuid, p_contactedby text, p_communityid int8)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'update_contacted: no authenticated user';
  end if;
  if p_contactedby is null or btrim(p_contactedby) = '' then
    raise exception 'update_contacted: p_contactedby is required';
  end if;
  if not exists (select 1 from public.business_page where id = p_businessid) then
    raise exception 'update_contacted: business page not found';
  end if;

  insert into public.business_contacted (business_page_id, contacted_user, last_contact_link)
  values (p_businessid, v_uid, array[p_contactedby])
  on conflict (business_page_id, contacted_user) do update
    set last_contact_link = case
      when p_contactedby = any(business_contacted.last_contact_link)
        then business_contacted.last_contact_link
      else array_append(business_contacted.last_contact_link, p_contactedby)
    end;
end;
$$;

comment on function public.update_contacted(uuid, uuid, text, int8) is
  'SECURITY DEFINER: upserts business_contacted, appending the contact channel. p_userid ignored (auth.uid() used); p_communityid unused (compat).';

revoke all on function public.update_contacted(uuid, uuid, text, int8) from public;
grant execute on function public.update_contacted(uuid, uuid, text, int8) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- report_business / unreport_business (NEW) — forward-compat: `reports` does NOT exist yet
-- (Moderation batch, not yet built — see file header). Dynamic SQL + `undefined_table` exception
-- guard, same pattern as is_business_page_owner's Batch-5 stub. Returns null (no-op) today;
-- self-activates once `reports` lands. -- TODO(confirm): reconcile with the Moderation batch's own
-- report_content() RPC (docs/database/09-rpc-inventory.md §13) rather than redefine.
-- ---------------------------------------------------------------------------------------------
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

  begin
    execute
      'insert into public.reports (community_id, reported_by_user, report_type, business_page_id, reason)
       values ($1, $2, $3, $4, $5) returning id'
      into v_id
      using 1, v_uid, 'business', p_business_id, nullif(p_reason, '');
  exception when undefined_table then
    v_id := null; -- reports not created yet (Moderation batch) — no-op until it lands.
  end;

  return v_id;
end;
$$;

comment on function public.report_business(uuid, text) is
  'SECURITY DEFINER: inserts a business report. Forward-compat: no-ops (returns null) until public.reports exists (Moderation batch).';

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

  begin
    execute 'delete from public.reports where id = $1 and reported_by_user = $2'
      using p_report_id, v_uid;
  exception when undefined_table then
    null; -- reports not created yet (Moderation batch) — no-op until it lands.
  end;
end;
$$;

comment on function public.unreport_business(uuid) is
  'SECURITY DEFINER: deletes the caller''s own business report (undo). Forward-compat, see report_business().';

revoke all on function public.unreport_business(uuid) from public;
grant execute on function public.unreport_business(uuid) to authenticated;

commit;

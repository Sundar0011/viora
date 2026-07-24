-- 0073_reports_table.sql
-- Purpose: Batch 7 (Moderation) — the `reports` table. Built FIRST in this batch (per this task's
-- explicit instruction) because the Batch-6 forward-compat stubs report_business()/
-- unreport_business() (0057_business_functions_writes.sql) already assume it exists and no-op via
-- an `undefined_table` exception guard until it lands — see 0075 for their backfill.
--
-- Columns/types/nullability match docs/database/06-tables-notifications-search-moderation.md,
-- cross-checked against the locked frontend Row class (reports.dart). Polymorphic: report_type
-- names the entity kind, and exactly one of the nullable target FK columns is populated to match.
--
-- `blocks` already exists (Batch 2, 0008_post_tables.sql, brought forward) — NOT recreated here.
--
-- community_id: kept as a vestigial compat column (int8, nullable, DEFAULT 1, NO FK) — matches the
-- Row class, per docs/decisions.md (2026-07-19, "Remove community concept"). Several report
-- dialogs hard-code `1`, others send FFAppState().communityId — this column is never used for
-- scoping/derivation regardless of what the client sends (docs/features/13-moderation-reports-
-- blocks.md §8.1).

begin;

create table public.reports (
  id                  uuid primary key default extensions.gen_random_uuid(),
  created_at          timestamptz not null default now(),
  community_id        int8 default 1, -- vestigial compat column, no FK; see file header
  reported_by_user    uuid not null references public."user" (id) on delete cascade,
  reported_user       uuid references public."user" (id) on delete set null, -- report survives even if the target account is later deleted
  reason              text not null,
  report_type         text not null, -- 'post'/'account'/'business'/'event'/'group'/'sale'/'message'; kept text (an empty-string value was observed in the frontend, incompatible with a strict enum) per docs/decisions.md "Unknown dropdown value sets"
  post_id             uuid references public.post (id) on delete cascade,
  comment_id          uuid references public.post_comment (id) on delete cascade, -- column exists, unused by any current dialog (feature doc §3)
  group_id            uuid references public."group" (id) on delete cascade,
  business_page_id    uuid references public.business_page (id) on delete cascade,
  event_id            uuid references public.event_page (id) on delete cascade,
  sale_id             uuid references public.sale (id) on delete cascade,
  report_status       text not null default 'pending',
  mail_sent           boolean default false
);

comment on table public.reports is
  'One row per report against a target entity (polymorphic via report_type + matching nullable FK). INSERT via report_content()/report_business() RPC only; SELECT/UPDATE admin-only.';

create index reports_reported_by_user_idx on public.reports (reported_by_user);
create index reports_reported_user_idx on public.reports (reported_user);
create index reports_post_id_idx on public.reports (post_id);
create index reports_comment_id_idx on public.reports (comment_id);
create index reports_group_id_idx on public.reports (group_id);
create index reports_business_page_id_idx on public.reports (business_page_id);
create index reports_event_id_idx on public.reports (event_id);
create index reports_sale_id_idx on public.reports (sale_id);
create index reports_report_status_idx on public.reports (report_status);
create index reports_mail_sent_idx on public.reports (mail_sent);
create index reports_report_type_idx on public.reports (report_type);
-- Admin queue ordering composite (status filter + recency).
create index reports_status_created_at_idx on public.reports (report_status, created_at desc);

alter table public.reports enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md ("Batch 7") is reviewed and
-- applied (CLAUDE.md §6.9). See 0083_notifications_search_moderation_rls.sql.

commit;

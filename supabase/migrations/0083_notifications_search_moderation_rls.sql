-- 0083_notifications_search_moderation_rls.sql
-- RLS policies for Batch 7 tables (notifications, admin_notification, search_history, reports).
-- `blocks` RLS already exists (Batch 2, 0016_post_rls.sql) — NOT touched here. Reviewed in
-- docs/rls-policies-draft.md ("Batch 7") pending sign-off (CLAUDE.md §6.9). Every helper call is
-- wrapped `(select ...)` so the planner evaluates it once per query (§6.8).

begin;

-- ============================ notifications — receiver-only, state-change columns only =========
-- SELECT: only the caller's own received, non-deleted rows (get_notifications also enforces this,
-- belt-and-braces). UPDATE: own rows only, and only is_read/is_deleted (enforced at the RPC layer
-- via mark_notification_read/mark_notification_deleted, 0081 — no direct client UPDATE policy is
-- added here since ALL writes go through those two RPCs, matching the "messages" precedent of
-- choosing RPC-only over a scoped client UPDATE policy). No INSERT/DELETE policy for any client
-- role — rows are created only by notify() (0077, SECURITY DEFINER, bypasses RLS as owner).
create policy "notifications_select_own"
  on public.notifications for select to authenticated
  using ( receiver_id = (select auth.uid()) and is_deleted = false );
-- No INSERT/UPDATE/DELETE policy: writes are RPC-only (notify()/mark_notification_read()/
-- mark_notification_deleted()), all SECURITY DEFINER and bypass RLS as owner.

-- ============================ admin_notification — admin-only =================================
create policy "admin_notification_select_admin"
  on public.admin_notification for select to authenticated
  using ( (select public.is_admin()) );
create policy "admin_notification_insert_admin"
  on public.admin_notification for insert to authenticated
  with check ( (select public.is_admin()) );
create policy "admin_notification_update_admin"
  on public.admin_notification for update to authenticated
  using ( (select public.is_admin()) )
  with check ( (select public.is_admin()) );
-- No DELETE policy: broadcasts are not deleted by any documented flow; add one later if the
-- Operture admin app needs it.

-- ============================ search_history — owner-only ======================================
-- Matches the sale_images precedent (decision #4): the frontend does direct client queryRows/
-- delete, so scoped owner RLS is acceptable in place of forcing an RPC for reads/deletes. INSERT/
-- UPDATE stay RPC-only (update_search_data, 0070) — no client INSERT/UPDATE policy is added, since
-- the frontend never does a direct insert/update against this table (only queryRows + delete).
create policy "search_history_select_own"
  on public.search_history for select to authenticated
  using ( searched_by = (select auth.uid()) );
create policy "search_history_delete_own"
  on public.search_history for delete to authenticated
  using ( searched_by = (select auth.uid()) );
-- No INSERT/UPDATE policy: writes only via update_search_data() RPC (SECURITY DEFINER, bypasses
-- RLS as owner) — matches the table's own comment.

-- ============================ reports — reporter INSERT via RPC only; admin read/write ==========
-- SELECT: admin-only moderation queue (docs/features/13-moderation-reports-blocks.md §8.10 —
-- "reporter visibility" TODO(confirm): the frontend shows only a static thank-you sheet, no report-
-- status screen, so reporters do NOT get a SELECT policy here; get_reports() itself is also
-- admin-gated). UPDATE/DELETE: admin-only (set_report_status() RPC, 0074). No INSERT policy at
-- all — report_content()/report_business() (0074/0075) are SECURITY DEFINER and bypass RLS as
-- owner, so a direct client INSERT is impossible regardless.
create policy "reports_select_admin"
  on public.reports for select to authenticated
  using ( (select public.is_admin()) );
create policy "reports_update_admin"
  on public.reports for update to authenticated
  using ( (select public.is_admin()) )
  with check ( (select public.is_admin()) );
-- No INSERT/DELETE policy: INSERT only via report_content()/report_business() (SECURITY DEFINER);
-- no DELETE flow exists for reports (admin transitions report_status instead of deleting).

commit;

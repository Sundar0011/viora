-- 0080_reports_mail_sent_trigger.sql
-- Purpose: Batch 7 (Moderation) — the `reports.mail_sent` trigger. Per docs/features/
-- 13-moderation-reports-blocks.md §6, `mail_sent` is never written by the client and strongly
-- implies a server-side mechanism that alerts admins on every new report and then flags the row.
--
-- IMPLEMENTATION CHOICE (simple, per this task's explicit instruction "keep simple"): reuses the
-- notify() helper (0077) to create an IN-APP notification for every platform admin
-- (user_roles.role = 'admin'), then marks mail_sent = true once those notifications are written.
-- type='report' — NOT in docs/features/11-notifications.md §3's confirmed observed set (that set
-- describes end-USER-facing notification types only); an admin-only report alert is a distinct,
-- internal use of the same table, so a new type string is used deliberately rather than
-- overloading an existing user-facing one.
--
-- -- TODO(confirm): this does NOT send an actual email. No email provider/secret was specified in
-- scope. If a real email alert is required (matching the literal "emails the moderation/admin
-- address" wording in the feature doc), the recommended follow-up is a dedicated Edge Function
-- (e.g. `send-report-alert`, mirroring `send-notification`'s pg_net-trigger pattern in 0082) using
-- a transactional-email provider's API key as a server-side secret (Resend/SendGrid/etc. — none
-- currently in scope). `mail_sent` is set true here once the IN-APP admin notification succeeds,
-- which may need renaming/splitting from a real "email sent" flag once that Edge Function exists.

begin;

create or replace function public.trg_reports_notify_admins()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_reporter_name  text;
  r                record;
begin
  select name into v_reporter_name from public.public_user_profile where id = new.reported_by_user;

  for r in
    select ur.id as admin_id
    from public.user_roles ur
    where ur.role = 'admin'
  loop
    -- Admin alerts bypass the normal never-notify-self / two-way-block suppression semantics of
    -- notify() only incidentally (an admin is never the reporter in practice); notify() itself
    -- still applies both guards, which is the desired behavior (an admin who happens to be the
    -- reporter, or who has blocked/been blocked by the reporter, does not need a self-alert).
    perform public.notify(
      p_sender_id   => new.reported_by_user,
      p_receiver_id => r.admin_id,
      p_type        => 'report',
      p_content     => coalesce(v_reporter_name, 'Someone') || ' submitted a ' || new.report_type || ' report: ' || new.reason
    );
  end loop;

  update public.reports set mail_sent = true where id = new.id;

  return new;
end;
$$;

drop trigger if exists reports_notify_admins on public.reports;
create trigger reports_notify_admins
  after insert on public.reports
  for each row
  execute function public.trg_reports_notify_admins();

revoke all on function public.trg_reports_notify_admins() from public, anon, authenticated;

commit;

-- 0076_notifications_tables.sql
-- Purpose: Batch 7 (Notifications) — `notifications` + `admin_notification` tables.
-- `user_devices` already exists (Batch 1, 0003_identity_tables.sql, FCM-only per
-- docs/decisions.md 2026-07-19 "Push notifications") — NOT recreated here; its
-- upsert_user_device_fcm() RPC (referenced since Batch 1 but never created) is added in 0077.
--
-- Columns/types/nullability match docs/database/06-tables-notifications-search-moderation.md,
-- cross-checked against the locked frontend Row classes (notifications.dart,
-- admin_notification.dart).
--
-- receiver_id made NOT NULL here (the Row class marks it nullable, but every query/RLS predicate
-- keys on it — the Row class's nullability is a frontend-generator quirk, not a real "no
-- recipient" case, per the design doc's flagged note). No client INSERT/DELETE policy at all —
-- rows are created server-side only, by the notify() helper (0077) called from producer triggers
-- (0078/0079) or admin/report flows (0080).

begin;

-- ---------------------------------------------------------------------------------------------
-- notifications — one row per in-app notification. High-volume table (like `messages`) —
-- keyset-paginate on (receiver_id, created_at, id), not offset, once a paginated read RPC is
-- built (get_notifications, 0081, currently returns the full grouped set to match the frontend's
-- existing no-arg call contract, per docs/decisions.md "Pagination & filtering" — TODO(frontend)).
-- ---------------------------------------------------------------------------------------------
create table public.notifications (
  id                 uuid primary key default extensions.gen_random_uuid(),
  created_at         timestamptz not null default now(),
  sender_id          uuid not null references public."user" (id) on delete cascade,
  receiver_id        uuid not null references public."user" (id) on delete cascade,
  type               text, -- routing key: post/comment/event/business/sale/group/invite/group_invite/follow (open set, kept text per docs/decisions.md "Unknown dropdown value sets")
  notification_type  text, -- second type field, purpose unconfirmed (feature doc §8.1) — kept as-is, unused by any RPC/trigger in this batch
  content            text not null,
  title              text,
  message            text,
  is_read            boolean not null default false,
  is_deleted         boolean not null default false,
  post_id            uuid references public.post (id) on delete cascade,
  comment_id         uuid references public.post_comment (id) on delete cascade,
  event_id           uuid references public.event_page (id) on delete cascade,
  business_id        uuid references public.business_page (id) on delete cascade,
  sale_id            uuid references public.sale (id) on delete cascade,
  group_id           uuid references public."group" (id) on delete cascade,
  message_id         uuid references public.messages (id) on delete cascade
);

comment on table public.notifications is
  'One row per in-app notification. receiver_id made NOT NULL (frontend Row class marks it nullable by generator quirk — every read/RLS predicate keys on it). INSERT/DELETE server-side only (notify() helper, 0077); UPDATE limited to own is_read/is_deleted.';

create index notifications_receiver_id_created_at_idx on public.notifications (receiver_id, created_at desc);
create index notifications_receiver_id_deleted_read_idx on public.notifications (receiver_id, is_deleted, is_read);
create index notifications_sender_id_idx on public.notifications (sender_id);
create index notifications_post_id_idx on public.notifications (post_id);
create index notifications_comment_id_idx on public.notifications (comment_id);
create index notifications_event_id_idx on public.notifications (event_id);
create index notifications_business_id_idx on public.notifications (business_id);
create index notifications_sale_id_idx on public.notifications (sale_id);
create index notifications_group_id_idx on public.notifications (group_id);
create index notifications_message_id_idx on public.notifications (message_id);

alter table public.notifications enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md ("Batch 7") is reviewed and
-- applied (CLAUDE.md §6.9). See 0083_notifications_search_moderation_rls.sql.

-- ---------------------------------------------------------------------------------------------
-- admin_notification — admin-composed broadcast/announcement. int8 identity PK (differs from
-- notifications.id, matches the frontend Row class exactly). No admin compose/send screen exists
-- in the Flutter frontend (feature doc §2 note — the admin UI lives in the separate Operture app);
-- this table + RLS exist so that app has somewhere to write, per docs/database/06-tables-
-- notifications-search-moderation.md.
-- ---------------------------------------------------------------------------------------------
create table public.admin_notification (
  id             int8 generated always as identity primary key,
  created_at     timestamptz not null default now(),
  title          text,
  content        text,
  sent_on        timestamptz, -- null until sent (draft/scheduled)
  status         text,        -- draft/scheduled/sent — value set unconfirmed (docs/decisions.md "Unknown dropdown value sets")
  audience_type  text,        -- target audience selector — value set unconfirmed
  created_by     uuid references public."user" (id) on delete set null -- NEW column: no admin-sender FK exists in the frontend Row class; added for audit traceability (design doc, flagged as new/optional)
);

comment on table public.admin_notification is
  'Admin-composed broadcast/announcement. No Flutter compose screen exists (admin UI is the separate Operture app). SELECT/INSERT/UPDATE admin-only.';

create index admin_notification_status_idx on public.admin_notification (status);
create index admin_notification_sent_on_idx on public.admin_notification (sent_on);
create index admin_notification_audience_type_idx on public.admin_notification (audience_type);
create index admin_notification_created_by_idx on public.admin_notification (created_by);

alter table public.admin_notification enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md ("Batch 7") is reviewed and
-- applied (CLAUDE.md §6.9). See 0083_notifications_search_moderation_rls.sql.

commit;

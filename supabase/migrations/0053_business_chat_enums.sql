-- 0053_business_chat_enums.sql
-- Purpose: Batch 6 (Business Pages & Promotions + Chat/Messaging) enum types.
--
-- e_message_type: earmarked by name in 0002_enums.sql's own header comment ("... e_message_type
-- ... are created in the migration batch for the feature that owns them, not here"). CONFIRMED
-- two values ('text'/'image') per docs/database/05-tables-business-chat.md `messages.e_message_type`.
--
-- business_page.business_status REUSES the EXISTING public.lifecycle_status enum
-- ('active'/'removed'/'suspended', 0007_post_enums.sql) — no new enum needed, matching the
-- "group".status / event_page.event_status precedent (0024/0035).
--
-- business_promote.status and chat.chat_type stay `text` (NOT enums) — per docs/decisions.md
-- (2026-07-19, "Unknown dropdown value sets ... store as plain text for now"): business_promote
-- status's full value set (under review/live/ended/rejected/mismatch) and chat_type's full value
-- set ('dm' confirmed; 'sale'/'forsale' unconfirmed) are both flagged TODO(confirm) in
-- docs/database/05-tables-business-chat.md.

begin;

do $$
begin
  if not exists (select 1 from pg_type where typname = 'e_message_type') then
    create type public.e_message_type as enum ('text', 'image');
  end if;
end;
$$;

commit;

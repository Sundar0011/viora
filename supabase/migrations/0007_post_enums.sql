-- 0007_post_enums.sql
-- Purpose: post-lifecycle enum type for Batch 2 (Posts, Comments, Likes, Shares, Tags, Blocks).
-- Only the enum(s) actually needed by this batch's tables live here — see docs/database/
-- 02-tables-posts-comments.md ("post_status | lifecycle_status enum | NO | default 'active'").
--
-- e_media_type on post_images is intentionally kept as plain `text` (not an enum) per the task
-- decision "images only, keep post_images.e_media_type exactly as the frontend has it" — the
-- frontend Row class types it as a String, not a Dart enum, and only ever sends 'image'.

begin;

do $$
begin
  if not exists (select 1 from pg_type where typname = 'lifecycle_status') then
    create type public.lifecycle_status as enum ('active', 'removed', 'suspended');
  end if;
end;
$$;

commit;

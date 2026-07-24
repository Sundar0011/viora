-- 0051_storage_buckets.sql
-- Purpose: create every storage bucket per docs/database/07-storage-buckets.md's "Existing
-- buckets (confirmed by the frontend contract)" table. This is the FIRST storage migration in the
-- whole rebuild — post-images/profile-images/cover-images have needed a bucket since Batch 1/2,
-- and this batch adds sales-images/event/group-profile-image/promote-receipts/business-image/
-- squadd on top. Idempotent (`on conflict (id) do nothing`).
--
-- Public flag / size / mime-type limits per bucket, straight from the storage-buckets doc table.
-- Video is OUT OF SCOPE (docs/decisions.md 2026-07-19, "Video removed from scope") — every bucket
-- below is images-only (+ promote-receipts also allows application/pdf per the doc).
--
-- Object-level RLS policies (storage.objects) are in 0052_storage_rls.sql, reviewed in
-- docs/rls-policies-draft.md ("Batch 5 — Events, Marketplace & Storage") pending sign-off
-- (CLAUDE.md §6.9) — bucket creation alone does not expose any file; storage.objects has RLS
-- enabled by default on every Supabase project and DENIES all access until policies exist.

begin;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('post-images',         'post-images',         true,  10485760, array['image/jpeg', 'image/png', 'image/webp']),
  ('sales-images',        'sales-images',         true,  10485760, array['image/jpeg', 'image/png', 'image/webp']),
  ('profile-images',      'profile-images',       true,  5242880,  array['image/jpeg', 'image/png', 'image/webp']),
  ('cover-images',        'cover-images',         true,  5242880,  array['image/jpeg', 'image/png', 'image/webp']),
  ('business-image',      'business-image',       true,  5242880,  array['image/jpeg', 'image/png', 'image/webp']),
  ('promote-receipts',    'promote-receipts',     false, 10485760, array['image/jpeg', 'image/png', 'application/pdf']),
  ('event',               'event',                true,  10485760, array['image/jpeg', 'image/png', 'image/webp']),
  ('group-profile-image', 'group-profile-image',  true,  5242880,  array['image/jpeg', 'image/png', 'image/webp']),
  ('squadd',              'squadd',               true,  5242880,  array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

commit;

-- 0001_extensions.sql
-- Purpose: enable the Postgres extensions required by the identity/auth foundation (Batch 1)
-- and by later geo-dependent tables (user_locations here; sale/event_page in later batches).
-- Idempotent: safe to re-run. Installed into the dedicated `extensions` schema (Supabase
-- convention) rather than `public`, per supabase-postgres-best-practices (least-privilege,
-- keep `public` free of extension-owned objects).

begin;

-- pgcrypto: provides gen_random_uuid(), used as the default for every uuid PK in this schema.
create extension if not exists pgcrypto with schema extensions;

-- postgis: provides geography(Point,4326), used by user_locations.location in this batch and
-- by sale.location_point / event_page.location in later batches (see docs/database-design.md §2).
create extension if not exists postgis with schema extensions;

commit;

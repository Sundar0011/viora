-- 0035_event_marketplace_enums.sql
-- Purpose: Batch 5 (Events + Marketplace) enum types, earmarked by name in 0002_enums.sql's own
-- header comment ("... e_price_type, e_sale_type, event_type ... created in the migration batch
-- for the feature that owns them"). `event_page.event_status` reuses the EXISTING
-- public.lifecycle_status enum ('active'/'removed'/'suspended', 0007_post_enums.sql) — no new
-- enum needed for it, matching the "group.status" precedent (0024_group_enums.sql).
--
-- event_type: CONFIRMED two values ('Online'/'Offline') per docs/database/04-tables-events-
-- marketplace.md (`event_type` enum NO). The feature doc (06-events.md §3) calls it "not a DB
-- enum in frontend / plain text from a radio button" — the table doc's confirmed enum wins per
-- CLAUDE.md §3 ("doc-first ... if doc and code disagree, the doc wins"); kept as a real enum, not
-- text+CHECK, since exactly two values are confirmed (mirrors e_group_type's precedent).
--
-- e_price_type: CONFIRMED two values ('Free'/'Fixed') per docs/database/04-tables-events-
-- marketplace.md and docs/features/07-marketplace-sale.md §3.
-- e_sale_type: CONFIRMED two values ('selling'/'sold') per the same docs.

begin;

do $$
begin
  if not exists (select 1 from pg_type where typname = 'event_type') then
    create type public.event_type as enum ('Online', 'Offline');
  end if;
end;
$$;

do $$
begin
  if not exists (select 1 from pg_type where typname = 'e_price_type') then
    create type public.e_price_type as enum ('Free', 'Fixed');
  end if;
end;
$$;

do $$
begin
  if not exists (select 1 from pg_type where typname = 'e_sale_type') then
    create type public.e_sale_type as enum ('selling', 'sold');
  end if;
end;
$$;

commit;

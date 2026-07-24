-- 0024_group_enums.sql
-- Purpose: Batch 4 (Groups) — group-scoped enum type. `group.status` reuses the existing
-- public.lifecycle_status enum ('active'/'removed'/'suspended') created in 0007_post_enums.sql —
-- no new enum needed for it.
--
-- e_group_type: CONFIRMED two values ('open'/'private') per docs/features/05-groups.md §5 — made
-- a real enum (unlike e_discoverability/e_group_role, whose value sets are unconfirmed and stay
-- `text` per docs/decisions.md 2026-07-19 decision #9).
-- e_discoverability: kept `text` — full radio-option value set is NOT confirmed anywhere in the
-- reviewed frontend code (docs/features/05-groups.md §8 open question #4). -- TODO(confirm)
-- e_group_role (group_admin table): kept `text` + a CHECK constraint (added in 0025) restricting
-- it to the one CONFIRMED value 'admin' — no enum, per docs/database/03-tables-community-groups.md.

begin;

do $$
begin
  if not exists (select 1 from pg_type where typname = 'e_group_type') then
    create type public.e_group_type as enum ('open', 'private');
  end if;
end;
$$;

commit;

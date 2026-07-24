-- 0002_enums.sql
-- Purpose: identity-scoped enum types for Batch 1. Feature-specific enums (lifecycle_status,
-- e_group_type, e_message_type, e_price_type, e_sale_type, event_type) are created in the
-- migration batch for the feature that owns them, not here.
--
-- app_role values are 'customer' / 'admin' per docs/decisions.md (2026-07-19, "Remaining open
-- decisions settled") which SUPERSEDES the earlier 'user'/'admin' wording in
-- docs/database-design.md §3 and §4. 'customer' matches the value the locked frontend already
-- hardcodes on signup; only signup_finalize (SECURITY DEFINER) is allowed to write user_roles.

begin;

do $$
begin
  if not exists (select 1 from pg_type where typname = 'app_role') then
    create type public.app_role as enum ('customer', 'admin');
  end if;
end;
$$;

commit;

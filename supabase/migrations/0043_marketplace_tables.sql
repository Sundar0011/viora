-- 0043_marketplace_tables.sql
-- Purpose: Batch 5 (Marketplace) tables — sale, sale_category, sale_images. Columns/types/
-- nullability match docs/database/04-tables-events-marketplace.md, cross-checked against the
-- locked frontend Row classes (sale.dart, sale_category.dart, sale_images.dart).
--
-- RLS: ENABLE ROW LEVEL SECURITY on all three tables, NO POLICIES in this file (deny-all to
-- anon/authenticated until reviewed). The proposed policy set lives in docs/rls-policies-draft.md
-- ("Batch 5 — Events, Marketplace & Storage") pending sign-off (CLAUDE.md §6.9).
--
-- community_id: kept as a vestigial compat column (int8, NO FK) on all three tables, per
-- docs/decisions.md (2026-07-19, "Remove community concept") — every one of these Row classes
-- carries the column and the locked frontend still sends/filters `= 1`. `sale.community_id` is
-- NOT NULL default 1 (frontend always sends it); `sale_category.community_id` and
-- `sale_images.community_id` are nullable default 1, matching each Row class's nullability.
--
-- Quirk preserved verbatim (CLAUDE.md §2): sale.isdeleted has NO underscore (matches the frontend
-- Row class getter `isdeleted`, same pattern as "group".isdeleted in Batch 4).
--
-- sale.sale_category stores the CATEGORY NAME as a string (matches sale_category.name), NOT an id
-- FK — kept exactly per the locked frontend contract (docs/features/07-marketplace-sale.md §8:
-- "Confirm whether to keep name-based or switch to id FK — frontend contract is name-based,
-- changing it breaks the app"). No FK constraint from sale.sale_category to sale_category.name.
--
-- sale_category SEED DATA: no confirmed category name list exists anywhere in the reviewed
-- frontend/docs (docs/features/07-marketplace-sale.md §3: "no community filter is applied in the
-- query", no hardcoded option list observed). Left UNSEEDED. -- TODO(confirm): the real category
-- list (e.g. from the live Operture reference app) before this table is usable end-to-end; the
-- category dropdown/filter sheet will render empty until rows exist.

begin;

-- ---------------------------------------------------------------------------------------------
-- sale — one row per marketplace listing. Soft-delete only (isdeleted). location_point is a
-- PostGIS geography point built server-side from lat/lng inside insert_sales_details() (never
-- written directly by the client).
-- ---------------------------------------------------------------------------------------------
create table public.sale (
  id              uuid primary key default extensions.gen_random_uuid(),
  created_at      timestamptz not null default now(),
  community_id    int8 not null default 1, -- vestigial compat column, no FK; see file header
  title           text not null,
  description     text not null,
  sale_category   text not null, -- stores sale_category.name by VALUE, no FK; see file header
  e_price_type    public.e_price_type not null,
  price           int8, -- null when e_price_type = 'Free'
  location        text not null,
  e_sale_type     public.e_sale_type not null default 'selling',
  created_by      uuid not null references public."user" (id) on delete restrict,
  location_point  extensions.geography(Point, 4326) not null,
  city            text not null,
  isdeleted       boolean not null default false, -- quirk: no underscore, kept verbatim
  latitude        float8,
  longitude       float8
);

comment on table public.sale is
  'One row per marketplace listing. Soft-delete only (isdeleted). Writes RPC-only (insert_sales_details/update_sale_without_image/set_sale_deleted/set_sale_type).';

-- created_by FK'd `on delete restrict`: a listing should not silently vanish/orphan because its
-- seller's account cascades away — soft-delete the listing explicitly instead (matches
-- "group"/"event_page" created_by/admin_user precedent).
create index sale_created_by_idx on public.sale (created_by);
create index sale_sale_category_idx on public.sale (sale_category);
create index sale_e_sale_type_idx on public.sale (e_sale_type);
create index sale_isdeleted_idx on public.sale (isdeleted);
create index sale_created_at_idx on public.sale (created_at);
create index sale_location_point_gix on public.sale using gist (location_point);

alter table public.sale enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

-- ---------------------------------------------------------------------------------------------
-- sale_category — lookup of category names for the create/edit dropdown and the category filter
-- sheet. Global (no community scoping) despite the vestigial community_id column. Admin-curated:
-- no client write policy exists or will exist (matches see_post_access/comment_post_access
-- lookup-table precedent from 0016_post_rls.sql).
-- ---------------------------------------------------------------------------------------------
create table public.sale_category (
  id            uuid primary key default extensions.gen_random_uuid(),
  created_at    timestamptz not null default now(),
  community_id  int8 default 1, -- vestigial compat column, no FK; see file header
  name          text
);

comment on table public.sale_category is
  'Lookup of category names shown in the create/edit dropdown and category filter sheet. Admin-curated (no client writes); referenced by sale.sale_category BY VALUE, no FK.';

create index sale_category_name_idx on public.sale_category (name);

alter table public.sale_category enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

-- ---------------------------------------------------------------------------------------------
-- sale_images — zero-or-more photos per listing. Bucket `sales-images`, path `<sale_id>/<file>`.
-- ---------------------------------------------------------------------------------------------
create table public.sale_images (
  id            uuid primary key default extensions.gen_random_uuid(),
  created_at    timestamptz not null default now(),
  community_id  int8 default 1, -- vestigial compat column, no FK; see file header
  sale_id       uuid not null references public.sale (id) on delete cascade,
  user_id       uuid references public."user" (id) on delete set null,
  image         text
);

comment on table public.sale_images is
  'Zero-or-more photos per sale listing (bucket sales-images, path <sale_id>/<file>). Writes only via add_sale_image()/delete_sale_image() RPCs.';

create index sale_images_sale_id_idx on public.sale_images (sale_id);
create index sale_images_user_id_idx on public.sale_images (user_id);

alter table public.sale_images enable row level security;
-- No policies here — deny-all until docs/rls-policies-draft.md is reviewed and applied.

commit;

-- 0069_search_trigram_indexes.sql
-- Purpose: Batch 7 (Search) — trigram GIN indexes (gin_trgm_ops, pg_trgm enabled in 0068) on every
-- text column the search RPCs (0071/0072) and tag_search (0070) filter with ILIKE '%term%', per
-- docs/database/06-tables-notifications-search-moderation.md's "Full-text / trigram search
-- columns" recommendation. Index-only — no schema change to the searched tables themselves.
--
-- public_user_profile.name already has a plain btree index (public_user_profile_name_idx, 0003)
-- for exact/prefix lookups elsewhere; this ADDS a trigram GIN index alongside it (btree and GIN
-- trigram serve different query shapes — a substring/@mention ILIKE needs the trigram index,
-- btree alone can't accelerate it).

begin;

create index post_content_text_trgm_idx
  on public.post using gin (content_text extensions.gin_trgm_ops);

create index sale_title_trgm_idx
  on public.sale using gin (title extensions.gin_trgm_ops);

create index sale_description_trgm_idx
  on public.sale using gin (description extensions.gin_trgm_ops);

create index event_page_name_trgm_idx
  on public.event_page using gin (name extensions.gin_trgm_ops);

create index group_name_trgm_idx
  on public."group" using gin (name extensions.gin_trgm_ops);

create index business_page_name_trgm_idx
  on public.business_page using gin (name extensions.gin_trgm_ops);

create index public_user_profile_name_trgm_idx
  on public.public_user_profile using gin (name extensions.gin_trgm_ops);

commit;

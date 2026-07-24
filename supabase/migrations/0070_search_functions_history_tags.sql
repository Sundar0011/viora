-- 0070_search_functions_history_tags.sql
-- Purpose: Batch 7 (Search) — update_search_data() + tag_search(). `insert_tags` already exists
-- (Batch 2, 0010_post_functions_writes.sql) — NOT recreated here.
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5: validates auth.uid() inside, pins
-- search_path = public, pg_temp, REVOKEs EXECUTE from PUBLIC, GRANTs only to authenticated.

begin;

-- ---------------------------------------------------------------------------------------------
-- update_search_data — persists/bumps a search term for the CALLER. Per
-- docs/database/09-rpc-inventory.md §12, forces searched_by from validated auth.uid(), never
-- trusts p_userid. p_community_id kept as a compat arg only (unused), matching every other
-- *communityid RPC in this schema. Manual find-then-update-or-insert upsert (no UNIQUE constraint
-- on (searched_by, lower(search)) yet — see 0068's header note) — implements the "bump
-- last_updated_date if the term already exists for this user" reading of the RPC name + the
-- nullable last_updated_date column (docs/features/12-search-tags.md §8.2, TODO(confirm) with
-- product if insert-always is actually intended instead).
-- ---------------------------------------------------------------------------------------------
create or replace function public.update_search_data(
  p_search_text    text,
  p_userid         uuid default null,   -- accepted-but-ignored, auth.uid() used regardless (matches user_follow precedent, 0018)
  p_community_id   int8 default null    -- compat arg only, unused
)
returns public.search_history
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid  uuid := auth.uid();
  v_row  public.search_history;
begin
  if v_uid is null then
    raise exception 'update_search_data: no authenticated user';
  end if;
  if p_search_text is null or btrim(p_search_text) = '' then
    raise exception 'update_search_data: search text is required';
  end if;

  select * into v_row
  from public.search_history
  where searched_by = v_uid and lower(search) = lower(btrim(p_search_text));

  if found then
    update public.search_history
    set last_updated_date = now()
    where id = v_row.id
    returning * into v_row;
  else
    insert into public.search_history (search, searched_by)
    values (btrim(p_search_text), v_uid)
    returning * into v_row;
  end if;

  return v_row;
end;
$$;

comment on function public.update_search_data(text, uuid, int8) is
  'SECURITY DEFINER: upsert/bump a search_history row for auth.uid() (case-insensitive dedupe by term). p_userid ignored; p_community_id unused (compat).';

revoke all on function public.update_search_data(text, uuid, int8) from public;
grant execute on function public.update_search_data(text, uuid, int8) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- tag_search — @mention user-name autocomplete. Trigram similarity on public_user_profile.name.
-- Scope: app-wide (all users), matching the app-wide/no-community precedent for every other
-- discovery RPC in this schema (get_all_business/get_groups_with_user_status/etc.) —
-- -- TODO(confirm): docs/features/12-search-tags.md §8.6 leaves "all users vs same-network only"
-- open; app-wide chosen as the least-restrictive default consistent with the rest of the schema.
-- Two-way block-filtered (never suggest a user who is in a block relationship with the caller).
-- Empty search_name returns the first p_limit users (matches "empty term returns
-- all/initial users" per the feature doc).
-- ---------------------------------------------------------------------------------------------
create or replace function public.tag_search(
  search_name  text default '',
  p_limit      int4 default 20
)
returns table (id uuid, name text, profile_image text)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'tag_search: no authenticated user';
  end if;

  return query
  select p.id, p.name, p.profile_picture
  from public.public_user_profile p
  where p.id <> v_uid
    and not public.is_blocked_pair(v_uid, p.id)
    and (
      search_name is null or btrim(search_name) = ''
      or p.name ilike '%' || search_name || '%'
    )
  order by
    case when search_name is null or btrim(search_name) = '' then 0
         else similarity(coalesce(p.name, ''), search_name) end desc,
    p.name asc
  limit least(greatest(p_limit, 1), 50);
end;
$$;

comment on function public.tag_search(text, int4) is
  'SECURITY DEFINER: @mention user autocomplete on public_user_profile.name (trigram), app-wide, two-way-block-filtered.';

revoke all on function public.tag_search(text, int4) from public;
grant execute on function public.tag_search(text, int4) to authenticated;

commit;

-- 0019_follows_functions_reads.sql
-- Purpose: Batch 3 — follow-graph read RPCs. Continuation of 0018, split for the 400-line cap.
-- Covers: get_followers, get_following, get_followers_nearby, get_following_users_not_attending_event.
-- Every read is two-way block-filtered (is_blocked_pair, from 0009_post_functions_reads.sql) and
-- backend-paginated per docs/decisions.md (2026-07-19, "Pagination & filtering") — pagination args
-- are ADDED with DEFAULTs so the locked frontend's existing no-pagination calls keep working.
--
-- SKIPPED per this task's explicit scope: get_user_following_groups_with_status (target_user_id) —
-- depends on the "group" table, which does not exist yet (Groups batch). Deferred there.
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5: validates auth.uid() inside, pins
-- search_path = public, pg_temp, REVOKEs EXECUTE from PUBLIC, GRANTs only to authenticated.

begin;

-- ---------------------------------------------------------------------------------------------
-- get_followers — people who follow p_userid (defaults to auth.uid() when null, so the locked
-- frontend's existing no-p_userid call, `get_followers(search_query)`, keeps working and stays
-- self-scoped). Block-filtered, keyset-paginated, optional name search_query.
-- -- TODO(frontend): wire pagination args (p_after_created_at/p_after_id) once the followers
-- screen paginates instead of loading the whole list into FFAppState().followers.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_followers(
  p_userid            uuid default null,
  search_query        text default null,
  p_limit             int4 default 50,
  p_after_created_at  timestamptz default null,
  p_after_id          uuid default null
)
returns table (user_id uuid, name text, profile_picture text, city text, created_at timestamptz)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid    uuid := auth.uid();
  v_target uuid;
begin
  if v_uid is null then
    raise exception 'get_followers: no authenticated user';
  end if;

  v_target := coalesce(p_userid, v_uid);

  return query
  select prof.id, prof.name, prof.profile_picture, prof.city, f.created_at
  from public.follows f
  join public.public_user_profile prof on prof.id = f.follower_id
  where f.following_id = v_target
    and not public.is_blocked_pair(v_uid, f.follower_id)
    and (search_query is null or search_query = '' or prof.name ilike '%' || search_query || '%')
    and (
      p_after_created_at is null
      or (f.created_at, f.id) < (p_after_created_at, p_after_id)
    )
  order by f.created_at desc, f.id desc
  limit least(greatest(p_limit, 1), 200);
end;
$$;

comment on function public.get_followers(uuid, text, int4, timestamptz, uuid) is
  'Followers of p_userid (default auth.uid()); block-filtered, name-searchable, keyset-paginated.';

revoke all on function public.get_followers(uuid, text, int4, timestamptz, uuid) from public;
grant execute on function public.get_followers(uuid, text, int4, timestamptz, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- get_following — people p_userid follows (defaults to auth.uid()). Same filters/pagination as
-- get_followers. -- TODO(frontend): wire pagination args once the following screen paginates.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_following(
  p_userid            uuid default null,
  search_query        text default null,
  p_limit             int4 default 50,
  p_after_created_at  timestamptz default null,
  p_after_id          uuid default null
)
returns table (user_id uuid, name text, profile_picture text, city text, created_at timestamptz)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid    uuid := auth.uid();
  v_target uuid;
begin
  if v_uid is null then
    raise exception 'get_following: no authenticated user';
  end if;

  v_target := coalesce(p_userid, v_uid);

  return query
  select prof.id, prof.name, prof.profile_picture, prof.city, f.created_at
  from public.follows f
  join public.public_user_profile prof on prof.id = f.following_id
  where f.follower_id = v_target
    and not public.is_blocked_pair(v_uid, f.following_id)
    and (search_query is null or search_query = '' or prof.name ilike '%' || search_query || '%')
    and (
      p_after_created_at is null
      or (f.created_at, f.id) < (p_after_created_at, p_after_id)
    )
  order by f.created_at desc, f.id desc
  limit least(greatest(p_limit, 1), 200);
end;
$$;

comment on function public.get_following(uuid, text, int4, timestamptz, uuid) is
  'Users p_userid follows (default auth.uid()); block-filtered, name-searchable, keyset-paginated.';

revoke all on function public.get_following(uuid, text, int4, timestamptz, uuid) from public;
grant execute on function public.get_following(uuid, text, int4, timestamptz, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- get_followers_nearby (GetNeighborhoodPeoplesCall) — nearby people vs the CALLER's own saved
-- location only (p_userid is accepted for frontend compat but IGNORED/forced to auth.uid(), per
-- docs/features/04-community-neighborhoods.md §7: "never expose raw coords" / geo distance vs
-- caller's own location only). Returns following_users[]/others[] (user_id, name, city,
-- distance_km, profile_picture) + following_count/others_count, matching the documented shape.
-- Radius: 5km, matching can_view_post()'s Nearby default -- TODO(confirm) real product radius.
-- p_communityid kept as a compat arg only (unused). Each bucket is bounded by p_limit
-- (default 50) -- TODO(frontend): wire real pagination once this screen needs more than one page.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_followers_nearby(
  p_userid       uuid default null, -- IGNORED; forced to auth.uid() below
  p_communityid  int8 default null, -- compat arg only, unused
  p_limit        int4 default 50
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid           uuid := auth.uid();
  v_my_location   extensions.geography;
  v_radius_m      float8 := 5000; -- TODO(confirm) "Nearby" radius default (5km)
  v_limit         int4 := least(greatest(p_limit, 1), 200);
  v_following     jsonb;
  v_others        jsonb;
begin
  if v_uid is null then
    raise exception 'get_followers_nearby: no authenticated user';
  end if;

  select location into v_my_location from public.user_locations where id = v_uid;

  if v_my_location is null then
    -- No saved location yet — cannot compute distance to anyone.
    return jsonb_build_object(
      'following_users', '[]'::jsonb, 'others', '[]'::jsonb,
      'following_count', 0, 'others_count', 0
    );
  end if;

  with candidates as (
    select
      prof.id as user_id, prof.name, prof.city, prof.profile_picture,
      extensions.ST_Distance(ul.location, v_my_location) / 1000.0 as distance_km,
      exists (
        select 1 from public.follows f where f.follower_id = v_uid and f.following_id = prof.id
      ) as is_following
    from public.user_locations ul
    join public.public_user_profile prof on prof.id = ul.id
    join public."user" u on u.id = ul.id and coalesce(u.is_deleted, false) = false
    where ul.id <> v_uid
      and not public.is_blocked_pair(v_uid, ul.id)
      and extensions.ST_DWithin(ul.location, v_my_location, v_radius_m)
  )
  select
    coalesce((select jsonb_agg(to_jsonb(c) - 'is_following' order by c.distance_km)
              from (select * from candidates where is_following order by distance_km limit v_limit) c),
             '[]'::jsonb),
    coalesce((select jsonb_agg(to_jsonb(c) - 'is_following' order by c.distance_km)
              from (select * from candidates where not is_following order by distance_km limit v_limit) c),
             '[]'::jsonb)
  into v_following, v_others;

  return jsonb_build_object(
    'following_users', v_following,
    'others', v_others,
    'following_count', jsonb_array_length(v_following),
    'others_count', jsonb_array_length(v_others)
  );
end;
$$;

comment on function public.get_followers_nearby(uuid, int8, int4) is
  'Nearby people vs caller''s own saved location (5km, TODO(confirm)); returns following_users[]/others[] + counts. p_userid ignored (forced to auth.uid()); p_communityid unused.';

revoke all on function public.get_followers_nearby(uuid, int8, int4) from public;
grant execute on function public.get_followers_nearby(uuid, int8, int4) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- get_following_users_not_attending_event (GetFollowingUsersCall) — event-invite helper: users
-- the caller follows who are not (yet) attending p_event_id. The `event_attending` table does not
-- exist yet (Events is a later batch) — guarded with an `undefined_table` exception handler, same
-- forward-compat pattern as can_view_post()'s friends-check in 0009_post_functions_reads.sql, so
-- this migration applies cleanly today and returns an empty set until Events lands, instead of
-- erroring. -- TODO(confirm): exact event_attending column names (assumed event_id, attending_id,
-- is_attending) once that batch defines the table.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_following_users_not_attending_event(
  p_event_id          uuid,
  p_limit             int4 default 50,
  p_after_created_at  timestamptz default null,
  p_after_id          uuid default null
)
returns table (user_id uuid, name text, profile_picture text, city text)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'get_following_users_not_attending_event: no authenticated user';
  end if;

  begin
    return query execute
      'select prof.id, prof.name, prof.profile_picture, prof.city
       from public.follows f
       join public.public_user_profile prof on prof.id = f.following_id
       where f.follower_id = $1
         and not public.is_blocked_pair($1, prof.id)
         and not exists (
           select 1 from public.event_attending ea
           where ea.event_id = $2 and ea.attending_id = prof.id and ea.is_attending = true
         )
         and ($3::timestamptz is null or (f.created_at, f.id) < ($3, $4))
       order by f.created_at desc, f.id desc
       limit least(greatest($5, 1), 200)'
      using v_uid, p_event_id, p_after_created_at, p_after_id, p_limit;
  exception when undefined_table then
    -- `event_attending` not created yet (Events batch) — return empty set instead of erroring.
    return;
  end;
end;
$$;

comment on function public.get_following_users_not_attending_event(uuid, int4, timestamptz, uuid) is
  'Users auth.uid() follows, not attending p_event_id. Forward-compat: returns empty until event_attending exists (Events batch). See TODO(confirm) inline.';

revoke all on function public.get_following_users_not_attending_event(uuid, int4, timestamptz, uuid) from public;
grant execute on function public.get_following_users_not_attending_event(uuid, int4, timestamptz, uuid) to authenticated;

commit;

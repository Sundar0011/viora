-- 0009_post_functions_reads.sql
-- Purpose: Batch 2 helper predicates + read RPCs (feed/post detail). Split out of a single
-- "0009_post_functions.sql" to respect CLAUDE.md §5's 400-line-per-file cap — see the
-- backend-dev playbook lesson dated 2026-07-19 for why. Covers:
--   (a) public.is_blocked_pair()      — two-way block predicate, used by every content read below.
--   (b) public.can_view_post()        — see_post_access_id enforcement: 1=Everyone, 2=Friends
--                                        only (follow-graph), 3=Nearby (geographic). No community
--                                        anywhere (stakeholder clarification 2026-07-19).
--   (c) public.can_comment_post()     — comment_post_access_id enforcement.
--   (d) public.get_visible_posts()    — main feed, paginated + filtered + block-filtered.
--   (e) public.get_neighbourhood_post_data() — posts authored by a given user, same filters.
--   (f) public.get_post_user_data()   — single post detail JSON.
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5: validates auth.uid() inside, pins
-- search_path = public, pg_temp, REVOKEs EXECUTE from PUBLIC, GRANTs only to authenticated.

begin;

-- ---------------------------------------------------------------------------------------------
-- (a) is_blocked_pair — true if either user has blocked the other (two-way block, per
-- docs/decisions.md 2026-07-19). SECURITY DEFINER so it can read all `blocks` rows regardless of
-- caller (the `blocks` table itself stays owner-only-readable per docs/rls-policies-draft.md).
-- ---------------------------------------------------------------------------------------------
create or replace function public.is_blocked_pair(p_user_a uuid, p_user_b uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1 from public.blocks b
    where (b.blocker_id = p_user_a and b.blocked_id = p_user_b)
       or (b.blocker_id = p_user_b and b.blocked_id = p_user_a)
  );
$$;

comment on function public.is_blocked_pair(uuid, uuid) is
  'True if either user has blocked the other (two-way). Used by every content read RPC.';

-- Internal helper: called only by other SECURITY DEFINER functions (as owner). Locked from all
-- client roles (matches what was applied — see docs/decisions.md 2026-07-19 Batch 2).
revoke all on function public.is_blocked_pair(uuid, uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------------------------------
-- (b) can_view_post — enforces post.see_post_access_id, three stakeholder-confirmed levels
-- (2026-07-19 clarification; no community anywhere):
--   id 1 = Everyone            -> always visible.
--   id 2 = Friends only        -> viewer must be a "friend" of the author via the follow graph
--                                  (public.follows: follower_id, following_id). Defaulted to
--                                  MUTUAL follow (author follows viewer AND viewer follows
--                                  author). -- TODO(confirm): friends = mutual follow vs.
--                                  follower/following either-direction.
--                                  The `follows` table does not exist yet (Neighbors/Follows
--                                  batch) — guarded with an EXCEPTION handler so this function is
--                                  forward-compatible: returns false (not visible) until that
--                                  table lands, instead of failing the whole feed query.
--   id 3 = Nearby only         -> geographic distance via user_locations (PostGIS). Radius is a
--                                  TODO(confirm) default.
-- Author always sees their own post regardless of access id.
-- ---------------------------------------------------------------------------------------------
create or replace function public.can_view_post(p_viewer_id uuid, p_post_id uuid)
returns boolean
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_author_id       uuid;
  v_access_id       int4;
  v_is_deleted      boolean;
  v_is_friend       boolean;
  v_viewer_location extensions.geography;
  v_author_location extensions.geography;
  v_distance_m      float8;
begin
  select user_id, see_post_access_id, is_deleted
  into v_author_id, v_access_id, v_is_deleted
  from public.post
  where id = p_post_id;

  if not found then
    return false;
  end if;

  if v_author_id = p_viewer_id then
    return true; -- author always sees their own post (edit/delete UI included)
  end if;

  if v_is_deleted then
    return false;
  end if;

  if public.is_blocked_pair(p_viewer_id, v_author_id) then
    return false;
  end if;

  if v_access_id = 1 then
    return true; -- "Everyone"
  end if;

  if v_access_id = 2 then
    -- "Friends only" = mutual follow. TODO(confirm): mutual vs. either-direction.
    v_is_friend := false;
    begin
      execute
        'select exists (select 1 from public.follows where follower_id = $1 and following_id = $2)
           and exists (select 1 from public.follows where follower_id = $2 and following_id = $1)'
        into v_is_friend
        using v_author_id, p_viewer_id;
    exception when undefined_table then
      -- `follows` table not created yet (Neighbors/Follows batch) — deny by default until it lands.
      v_is_friend := false;
    end;
    return coalesce(v_is_friend, false);
  end if;

  if v_access_id = 3 then
    select location into v_viewer_location from public.user_locations where id = p_viewer_id;
    select location into v_author_location from public.user_locations where id = v_author_id;

    if v_viewer_location is null or v_author_location is null then
      return false; -- cannot evaluate geography without both saved locations
    end if;

    v_distance_m := extensions.ST_Distance(v_viewer_location, v_author_location);
    return v_distance_m <= 5000; -- TODO(confirm) "Nearby" radius default (5km)
  end if;

  return false;
end;
$$;

comment on function public.can_view_post(uuid, uuid) is
  'Enforces post.see_post_access_id: 1=Everyone, 2=Friends only (mutual follow, TODO(confirm)), 3=Nearby (geo, TODO(confirm) radius).';

-- Internal helper: the client-facing entrypoint is can_view_post_self() (0016). Locked from all
-- client roles so the arbitrary-viewer form can't be probed via RPC.
revoke all on function public.can_view_post(uuid, uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------------------------------
-- (c) can_comment_post — enforces post.comment_post_access_id. Must first pass can_view_post.
-- Author always may comment. id 1 = anyone, id 4 = no one. ids 2/3 unconfirmed -> deny by
-- default. -- TODO(confirm): seed + semantics for comment_post_access ids 2/3.
-- ---------------------------------------------------------------------------------------------
create or replace function public.can_comment_post(p_viewer_id uuid, p_post_id uuid)
returns boolean
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_author_id  uuid;
  v_access_id  int4;
begin
  if not public.can_view_post(p_viewer_id, p_post_id) then
    return false;
  end if;

  select user_id, comment_post_access_id into v_author_id, v_access_id
  from public.post
  where id = p_post_id;

  if v_author_id = p_viewer_id then
    return true;
  end if;

  if v_access_id = 1 then
    return true;
  end if;

  return false; -- id 4 ("No One") and unconfirmed 2/3 both deny
end;
$$;

comment on function public.can_comment_post(uuid, uuid) is
  'Enforces post.comment_post_access_id (1=anyone, 4=no one; 2/3 TODO(confirm), denied by default).';

-- Internal helper: called only by add_comment() (as owner). Locked from all client roles.
revoke all on function public.can_comment_post(uuid, uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------------------------------
-- (d) get_visible_posts — main feed. Original frontend contract calls it with NO args
-- (GetPostCall); pagination/filter args are ADDED with DEFAULTs so the existing call keeps
-- working (backward-compatible). -- TODO(frontend): wire pagination args (p_after_created_at/
-- p_after_id) once the feed screen paginates instead of loading the whole feed into
-- FFAppState().AsPost, per docs/decisions.md (2026-07-19, "Pagination & filtering").
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_visible_posts(
  p_limit             int4 default 20,
  p_after_created_at  timestamptz default null,
  p_after_id          uuid default null,
  p_post_status       public.lifecycle_status default 'active'
)
returns setof public.post
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'get_visible_posts: no authenticated user';
  end if;

  return query
  select p.*
  from public.post p
  where p.is_deleted = false
    and p.post_status = p_post_status
    and not public.is_blocked_pair(v_uid, p.user_id)
    and public.can_view_post(v_uid, p.id)
    and (
      p_after_created_at is null
      or (p.created_at, p.id) < (p_after_created_at, p_after_id)
    )
  order by p.created_at desc, p.id desc
  limit least(greatest(p_limit, 1), 100);
end;
$$;

comment on function public.get_visible_posts(int4, timestamptz, uuid, public.lifecycle_status) is
  'Main feed: paginated, view-access-filtered, two-way-block-filtered. Args added with DEFAULTs for backward compat.';

revoke all on function public.get_visible_posts(int4, timestamptz, uuid, public.lifecycle_status) from public;
grant execute on function public.get_visible_posts(int4, timestamptz, uuid, public.lifecycle_status) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- (e) get_neighbourhood_post_data — posts authored by p_userid, visible to the caller, same
-- filters as get_visible_posts. p_communityid kept as a compat arg only (unused), per
-- docs/database/09-rpc-inventory.md. Pagination args added with DEFAULTs (backward-compatible).
-- -- TODO(frontend): wire pagination args once callers (neighbourhood_explore/user_all_post/
-- three-dot menu) paginate.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_neighbourhood_post_data(
  p_userid            uuid,
  p_communityid       int8 default null, -- compat arg only, unused
  p_limit             int4 default 20,
  p_after_created_at  timestamptz default null,
  p_after_id          uuid default null
)
returns setof public.post
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'get_neighbourhood_post_data: no authenticated user';
  end if;

  return query
  select p.*
  from public.post p
  where p.user_id = p_userid
    and p.is_deleted = false
    and not public.is_blocked_pair(v_uid, p.user_id)
    and public.can_view_post(v_uid, p.id)
    and (
      p_after_created_at is null
      or (p.created_at, p.id) < (p_after_created_at, p_after_id)
    )
  order by p.created_at desc, p.id desc
  limit least(greatest(p_limit, 1), 100);
end;
$$;

comment on function public.get_neighbourhood_post_data(uuid, int8, int4, timestamptz, uuid) is
  'Posts authored by p_userid, view-access + block filtered, paginated. p_communityid unused (compat).';

revoke all on function public.get_neighbourhood_post_data(uuid, int8, int4, timestamptz, uuid) from public;
grant execute on function public.get_neighbourhood_post_data(uuid, int8, int4, timestamptz, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- (f) get_post_user_data — single post detail JSON for the post-detail screen.
-- -- TODO(confirm): `following` is always returned false — the `follows` table doesn't exist yet
-- (Neighbors/Follows batch); wire it up once that table lands.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_post_user_data(p_postid uuid, p_userid uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid    uuid := auth.uid();
  v_result jsonb;
begin
  if v_uid is null then
    raise exception 'get_post_user_data: no authenticated user';
  end if;

  if not public.can_view_post(v_uid, p_postid) then
    return null;
  end if;

  select jsonb_build_object(
    'name', prof.name,
    'city', prof.city,
    'profile_image', prof.profile_picture,
    'images_count', (select count(*) from public.post_images pi where pi.post_id = p_postid),
    'following', false, -- TODO(confirm): wire up once `follows` table exists
    'liked_users', (
      select coalesce(jsonb_agg(pl.user_id), '[]'::jsonb)
      from public.post_like pl
      where pl.post_id = p_postid
        and not public.is_blocked_pair(v_uid, pl.user_id)
    ),
    'see_post_access_id', p.see_post_access_id,
    'comment_post_access_id', p.comment_post_access_id,
    'content', p.content,
    'images', (
      select coalesce(jsonb_agg(pi.image order by pi.created_at), '[]'::jsonb)
      from public.post_images pi
      where pi.post_id = p_postid
    )
  )
  into v_result
  from public.post p
  join public.public_user_profile prof on prof.id = p.user_id
  where p.id = p_postid;

  return v_result;
end;
$$;

comment on function public.get_post_user_data(uuid, uuid) is
  'Single post detail JSON for the post-detail screen. Respects view-access + two-way block.';

revoke all on function public.get_post_user_data(uuid, uuid) from public;
grant execute on function public.get_post_user_data(uuid, uuid) to authenticated;

commit;

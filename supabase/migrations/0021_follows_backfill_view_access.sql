-- 0021_follows_backfill_view_access.sql
-- Purpose: now that `follows` exists (0017_follows_table.sql), replace the two Batch 2
-- forward-compat stubs that referenced it before it existed:
--   • can_view_post() — the dynamic-SQL + `undefined_table`-guarded friends check (see_post_access
--     id=2) is replaced with a DIRECT static mutual-follow query against public.follows. Nothing
--     else in the function changes (author-always, is_deleted, block filter, Everyone, Nearby all
--     untouched, copied verbatim from 0009_post_functions_reads.sql).
--   • get_post_user_data() — the hardcoded 'following' => false is replaced with a real
--     mutual-exclusive "does the viewer follow the post author" check against public.follows.
--     Nothing else in the function changes (copied verbatim from 0009_post_functions_reads.sql).
-- Both are `create or replace` (same signature) so every existing grant / dependent object (RLS
-- policy can_view_post_self, read RPCs that call can_view_post) keeps working unchanged. Grants are
-- re-asserted exactly as they are today: can_view_post stays internal-shaped (revoked from public
-- and anon; still granted to authenticated, matching 0009 — the RLS wrapper can_view_post_self is
-- the client-facing entrypoint, per 0016_post_rls.sql); get_post_user_data stays granted to
-- authenticated, revoked from anon/public.

begin;

-- ---------------------------------------------------------------------------------------------
-- can_view_post — enforces post.see_post_access_id, three stakeholder-confirmed levels
-- (2026-07-19 clarification; no community anywhere):
--   id 1 = Everyone            -> always visible.
--   id 2 = Friends only        -> viewer must be a "friend" of the author, i.e. MUTUAL follow
--                                  (author follows viewer AND viewer follows author), now a
--                                  direct static query against public.follows (table exists as of
--                                  0017_follows_table.sql). -- TODO(confirm): friends = mutual
--                                  follow vs. follower/following either-direction (unchanged open
--                                  item from Batch 2).
--   id 3 = Nearby only         -> geographic distance via user_locations (PostGIS). Radius is a
--                                  TODO(confirm) default (unchanged from Batch 2).
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
    select
      exists (select 1 from public.follows where follower_id = v_author_id and following_id = p_viewer_id)
      and exists (select 1 from public.follows where follower_id = p_viewer_id and following_id = v_author_id)
    into v_is_friend;
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
  'Enforces post.see_post_access_id: 1=Everyone, 2=Friends only (mutual follow via public.follows, TODO(confirm)), 3=Nearby (geo, TODO(confirm) radius).';

-- Internal helper (unchanged from applied state): client-facing entrypoint is can_view_post_self()
-- (0016). Locked from all client roles; create-or-replace preserves this.
revoke all on function public.can_view_post(uuid, uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------------------------------
-- get_post_user_data — single post detail JSON for the post-detail screen. 'following' now
-- reflects whether the caller (auth.uid()) follows the post author, via public.follows.
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
    'following', exists (
      select 1 from public.follows where follower_id = v_uid and following_id = p.user_id
    ),
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
  'Single post detail JSON for the post-detail screen. Respects view-access + two-way block. following = real follows() check.';

revoke all on function public.get_post_user_data(uuid, uuid) from public, anon;
grant execute on function public.get_post_user_data(uuid, uuid) to authenticated;

commit;

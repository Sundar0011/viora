-- 0011_post_functions_engagement.sql
-- Purpose: Batch 2 likes/shares/count RPCs. Continuation of 0010, split for the 400-line cap.
-- post.likes_count / post.share_count are TRIGGER-maintained (see 0013_post_triggers.sql, per
-- docs/decisions.md 2026-07-19 "Denormalized counters"); these RPCs only mutate the underlying
-- rows (post_like/post_share) plus a couple of legacy compat wrappers the locked frontend still
-- calls, kept as safe idempotent recomputes rather than manual increments (avoids double-count
-- drift against the trigger).

begin;

-- ---------------------------------------------------------------------------------------------
-- add_like — toggle a post_like row for (p_userid, p_postid). p_communityid compat-only, unused.
-- Trigger on post_like recomputes post.likes_count.
-- ---------------------------------------------------------------------------------------------
create or replace function public.add_like(
  p_userid       uuid,
  p_postid       uuid,
  p_communityid  int8 default null -- compat arg only, unused
)
returns boolean
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid   uuid := auth.uid();
  v_liked boolean;
begin
  if v_uid is null or v_uid <> p_userid then
    raise exception 'add_like: auth.uid() mismatch';
  end if;

  if not public.can_view_post(v_uid, p_postid) then
    raise exception 'add_like: post not visible to caller';
  end if;

  if exists (select 1 from public.post_like where post_id = p_postid and user_id = v_uid) then
    delete from public.post_like where post_id = p_postid and user_id = v_uid;
    v_liked := false;
  else
    insert into public.post_like (post_id, user_id) values (p_postid, v_uid);
    v_liked := true;
  end if;

  return v_liked;
end;
$$;

comment on function public.add_like(uuid, uuid, int8) is
  'SECURITY DEFINER: toggles a post_like row for auth.uid(). p_communityid unused (compat).';

revoke all on function public.add_like(uuid, uuid, int8) from public;
grant execute on function public.add_like(uuid, uuid, int8) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- count_likes — legacy compat wrapper. Real counters are trigger-maintained; this idempotently
-- recomputes so any stray client call cannot desync anything. -- TODO(confirm): exact semantics
-- of p_type='post' vs 'reply' were ambiguous in the frontend (docs/features/03-comments.md §8);
-- 'reply' recomputes the target comment's replies_count, 'post' is a no-op (post.comment_count is
-- fully trigger-owned by post_comment inserts/deletes).
-- ---------------------------------------------------------------------------------------------
create or replace function public.count_likes(
  p_type       text,
  p_post_id    uuid,
  p_commentid  uuid default null
)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if auth.uid() is null then
    raise exception 'count_likes: no authenticated user';
  end if;

  if p_type = 'reply' and p_commentid is not null then
    update public.post_comment
    set replies_count = (
      select count(*) from public.post_comment r where r.parent_comment_id = p_commentid
    )
    where id = p_commentid;
  end if;
  -- p_type = 'post': no-op, post.comment_count is trigger-maintained (0013_post_triggers.sql).
end;
$$;

comment on function public.count_likes(text, uuid, uuid) is
  'Legacy compat wrapper: idempotent recompute only. Counters are trigger-owned; see TODO(confirm) inline.';

revoke all on function public.count_likes(text, uuid, uuid) from public;
grant execute on function public.count_likes(text, uuid, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- get_post_likes — users who liked a post (bounded list; block-filtered).
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_post_likes(p_postid uuid, p_limit int4 default 100, p_offset int4 default 0)
returns table (user_id uuid, name text, profile_picture text)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'get_post_likes: no authenticated user';
  end if;
  if not public.can_view_post(v_uid, p_postid) then
    raise exception 'get_post_likes: post not visible to caller';
  end if;

  return query
  select pl.user_id, prof.name, prof.profile_picture
  from public.post_like pl
  join public.public_user_profile prof on prof.id = pl.user_id
  where pl.post_id = p_postid
    and not public.is_blocked_pair(v_uid, pl.user_id)
  order by pl.created_at desc
  limit least(greatest(p_limit, 1), 200)
  offset greatest(p_offset, 0);
end;
$$;

comment on function public.get_post_likes(uuid, int4, int4) is
  'Users who liked a post; block-filtered, offset-paginated (bounded list).';

revoke all on function public.get_post_likes(uuid, int4, int4) from public;
grant execute on function public.get_post_likes(uuid, int4, int4) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- get_limited_post_likes — liked-user avatars fit to a given screen width. Width->count formula
-- kept simple. -- TODO(confirm): exact avatar-width/gap constants used by comp_likes_widget.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_limited_post_likes(p_postid uuid, p_screenwidth int4)
returns table (user_id uuid, name text, profile_picture text)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid   uuid := auth.uid();
  v_limit int4;
begin
  if v_uid is null then
    raise exception 'get_limited_post_likes: no authenticated user';
  end if;
  if not public.can_view_post(v_uid, p_postid) then
    raise exception 'get_limited_post_likes: post not visible to caller';
  end if;

  v_limit := greatest(least(coalesce(p_screenwidth, 200) / 40, 20), 1); -- TODO(confirm) width/avatar formula

  return query
  select pl.user_id, prof.name, prof.profile_picture
  from public.post_like pl
  join public.public_user_profile prof on prof.id = pl.user_id
  where pl.post_id = p_postid
    and not public.is_blocked_pair(v_uid, pl.user_id)
  order by pl.created_at desc
  limit v_limit;
end;
$$;

comment on function public.get_limited_post_likes(uuid, int4) is
  'Liked-user avatars limited to fit p_screenwidth; block-filtered. See TODO(confirm) inline.';

revoke all on function public.get_limited_post_likes(uuid, int4) from public;
grant execute on function public.get_limited_post_likes(uuid, int4) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- get_internal_share — shareable in-app user list for p_userid (= auth.uid()). Block-filtered.
-- -- TODO(confirm): proper "shareable users" set (e.g. followers) deferred until the `follows`
-- table exists (Neighbors/Follows batch) — currently returns other users app-wide, bounded.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_internal_share(p_userid uuid, p_limit int4 default 50)
returns table (user_id uuid, name text, profile_picture text)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null or v_uid <> p_userid then
    raise exception 'get_internal_share: auth.uid() mismatch';
  end if;

  return query
  select prof.id, prof.name, prof.profile_picture
  from public.public_user_profile prof
  where prof.id <> v_uid
    and not public.is_blocked_pair(v_uid, prof.id)
  order by prof.name
  limit least(greatest(p_limit, 1), 200);
end;
$$;

comment on function public.get_internal_share(uuid, int4) is
  'Shareable in-app users for auth.uid(), block-filtered. See TODO(confirm): follower-scoping deferred.';

revoke all on function public.get_internal_share(uuid, int4) from public;
grant execute on function public.get_internal_share(uuid, int4) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- update_post_share_count — inserts a post_share row; trigger recomputes post.share_count.
-- p_communityid compat-only, unused.
-- ---------------------------------------------------------------------------------------------
create or replace function public.update_post_share_count(
  p_postid       uuid,
  p_userid       uuid,
  p_communityid  int8 default null -- compat arg only, unused
)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null or v_uid <> p_userid then
    raise exception 'update_post_share_count: auth.uid() mismatch';
  end if;
  if not public.can_view_post(v_uid, p_postid) then
    raise exception 'update_post_share_count: post not visible to caller';
  end if;

  insert into public.post_share (post_id, user_id) values (p_postid, v_uid);
end;
$$;

comment on function public.update_post_share_count(uuid, uuid, int8) is
  'SECURITY DEFINER: records a share event for auth.uid(). p_communityid unused (compat).';

revoke all on function public.update_post_share_count(uuid, uuid, int8) from public;
grant execute on function public.update_post_share_count(uuid, uuid, int8) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- add_post_count / update_user_profile_counts — legacy compat wrappers. public_user_profile
-- counters are now trigger-maintained (0013_post_triggers.sql); both are no-ops beyond
-- auth validation, kept only so old frontend call sites don't error.
-- ---------------------------------------------------------------------------------------------
create or replace function public.add_post_count(p_userid uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if auth.uid() is null or auth.uid() <> p_userid then
    raise exception 'add_post_count: auth.uid() mismatch';
  end if;
  -- no-op: public_user_profile.post_count is trigger-maintained.
end;
$$;

comment on function public.add_post_count(uuid) is
  'Legacy compat no-op: post_count is trigger-maintained on post insert/delete.';

revoke all on function public.add_post_count(uuid) from public;
grant execute on function public.add_post_count(uuid) to authenticated;

create or replace function public.update_user_profile_counts(p_option text)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if auth.uid() is null then
    raise exception 'update_user_profile_counts: no authenticated user';
  end if;
  -- no-op: all public_user_profile counters are trigger-maintained per source table.
end;
$$;

comment on function public.update_user_profile_counts(text) is
  'Legacy compat no-op: all public_user_profile counters are trigger-maintained.';

revoke all on function public.update_user_profile_counts(text) from public;
grant execute on function public.update_user_profile_counts(text) to authenticated;

commit;

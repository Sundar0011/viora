-- 0012_comment_functions.sql
-- Purpose: Batch 2 comment RPCs. Continuation of the post_functions series, split for the
-- 400-line cap. Covers: get_post_comments_with_user, get_post_comments, add_comment (NEW,
-- replaces the locked frontend's direct PostCommentTable().insert), add_comment_like,
-- count_comment, delete_comment (admin-only moderation, per docs/features/03-comments.md §7 —
-- "none observed" client delete path).

begin;

-- ---------------------------------------------------------------------------------------------
-- get_post_comments_with_user — all comments + replies for a post, enriched with author name/
-- avatar. Block-filtered, respects can_view_post. Paginated with DEFAULTs added for backward
-- compat (frontend currently calls with only p_post_id). -- TODO(frontend): wire pagination once
-- comments_page paginates instead of loading the whole thread.
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_post_comments_with_user(
  p_post_id  uuid,
  p_limit    int4 default 50,
  p_offset   int4 default 0
)
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
    raise exception 'get_post_comments_with_user: no authenticated user';
  end if;
  if not public.can_view_post(v_uid, p_post_id) then
    raise exception 'get_post_comments_with_user: post not visible to caller';
  end if;

  select jsonb_build_object(
    'comments', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', c.id, 'user_name', prof.name, 'profile_picture', prof.profile_picture,
        'created_at', c.created_at, 'comment', c.comment, 'tldr', c.tldr,
        'likes_count', c.likes_count, 'replies_count', c.replies_count
      ) order by c.created_at desc)
      from public.post_comment c
      join public.public_user_profile prof on prof.id = c.user_id
      where c.post_id = p_post_id
        and c.parent_comment_id is null
        and not public.is_blocked_pair(v_uid, c.user_id)
      limit least(greatest(p_limit, 1), 200)
      offset greatest(p_offset, 0)
    ), '[]'::jsonb),
    'replies', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', c.id, 'user_name', prof.name, 'profile_picture', prof.profile_picture,
        'created_at', c.created_at, 'comment', c.comment, 'tldr', c.tldr,
        'likes_count', c.likes_count, 'replies_count', c.replies_count,
        'parent_comment_id', c.parent_comment_id
      ) order by c.created_at desc)
      from public.post_comment c
      join public.public_user_profile prof on prof.id = c.user_id
      where c.post_id = p_post_id
        and c.parent_comment_id is not null
        and not public.is_blocked_pair(v_uid, c.user_id)
    ), '[]'::jsonb)
  )
  into v_result;

  return v_result;
end;
$$;

comment on function public.get_post_comments_with_user(uuid, int4, int4) is
  '{comments[], replies[]} for a post, block-filtered. Pagination args added with DEFAULTs (backward-compatible).';

revoke all on function public.get_post_comments_with_user(uuid, int4, int4) from public;
grant execute on function public.get_post_comments_with_user(uuid, int4, int4) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- get_post_comments — single comment + its replies. Built against the majority-of-call-sites
-- uuid/text id type (docs/database/02-tables-posts-comments.md), not the int seen in one
-- component. -- TODO(confirm): comp_comment_widget/GetPostCommentsCall typed p_commentid as int;
-- built here as uuid to match get_post_comments_with_user / add_comment_like / direct eq('id',..)
-- ---------------------------------------------------------------------------------------------
create or replace function public.get_post_comments(p_commentid uuid, p_userid uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid    uuid := auth.uid();
  v_result jsonb;
  v_postid uuid;
begin
  if v_uid is null or v_uid <> p_userid then
    raise exception 'get_post_comments: auth.uid() mismatch';
  end if;

  select post_id into v_postid from public.post_comment where id = p_commentid;
  if v_postid is null then
    return null;
  end if;
  if not public.can_view_post(v_uid, v_postid) then
    return null;
  end if;

  select jsonb_build_object(
    'profile', prof.profile_picture,
    'name', prof.name,
    'comment', c.comment,
    'replied', c.replies_count,
    'replies', coalesce((
      select jsonb_agg(jsonb_build_object('name', rprof.name, 'comment', r.comment) order by r.created_at desc)
      from public.post_comment r
      join public.public_user_profile rprof on rprof.id = r.user_id
      where r.parent_comment_id = c.id
        and not public.is_blocked_pair(v_uid, r.user_id)
    ), '[]'::jsonb)
  )
  into v_result
  from public.post_comment c
  join public.public_user_profile prof on prof.id = c.user_id
  where c.id = p_commentid;

  return v_result;
end;
$$;

comment on function public.get_post_comments(uuid, uuid) is
  'Single comment + its replies, block-filtered. See TODO(confirm) re: id typing.';

revoke all on function public.get_post_comments(uuid, uuid) from public;
grant execute on function public.get_post_comments(uuid, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- add_comment (NEW) — replaces the locked frontend's direct PostCommentTable().insert for both
-- top-level comments and replies. Validates auth.uid(), post exists + passes
-- comment_post_access, and (via the post_comment_single_level_threading trigger,
-- 0013_post_triggers.sql) that a reply's parent is itself top-level.
-- post.comment_count / parent replies_count are trigger-maintained on insert.
-- ---------------------------------------------------------------------------------------------
create or replace function public.add_comment(
  p_post_id             uuid,
  p_comment             text,
  p_parent_comment_id   uuid default null
)
returns public.post_comment
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid     uuid := auth.uid();
  v_comment public.post_comment;
begin
  if v_uid is null then
    raise exception 'add_comment: no authenticated user';
  end if;

  if not public.can_comment_post(v_uid, p_post_id) then
    raise exception 'add_comment: caller may not comment on this post';
  end if;

  if p_parent_comment_id is not null and not exists (
    select 1 from public.post_comment where id = p_parent_comment_id and post_id = p_post_id
  ) then
    raise exception 'add_comment: parent comment not found on this post';
  end if;

  insert into public.post_comment (user_id, post_id, comment, likes_count, replies_count, parent_comment_id)
  values (v_uid, p_post_id, p_comment, 0, 0, p_parent_comment_id)
  returning * into v_comment;

  return v_comment;
end;
$$;

comment on function public.add_comment(uuid, text, uuid) is
  'SECURITY DEFINER: creates a comment/reply for auth.uid(). Replaces direct client PostCommentTable().insert.';

revoke all on function public.add_comment(uuid, text, uuid) from public;
grant execute on function public.add_comment(uuid, text, uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- add_comment_like — toggle a post_comment_likes row. p_communityid/p_postid compat args
-- retained for signature parity with the locked frontend call. Trigger recomputes
-- post_comment.likes_count.
-- ---------------------------------------------------------------------------------------------
-- NOTE: p_communityid (defaulted, vestigial) moved LAST so it doesn't precede the required
-- p_commentid — Postgres requires every param after a defaulted one to also have a default.
-- RPC calls are by name, so order is transparent to the frontend.
create or replace function public.add_comment_like(
  p_userid       uuid,
  p_postid       uuid,
  p_commentid    uuid,
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
    raise exception 'add_comment_like: auth.uid() mismatch';
  end if;
  if not public.can_view_post(v_uid, p_postid) then
    raise exception 'add_comment_like: post not visible to caller';
  end if;

  if exists (select 1 from public.post_comment_likes where comment_id = p_commentid and user_id = v_uid) then
    delete from public.post_comment_likes where comment_id = p_commentid and user_id = v_uid;
    v_liked := false;
  else
    insert into public.post_comment_likes (user_id, post_id, comment_id) values (v_uid, p_postid, p_commentid);
    v_liked := true;
  end if;

  return v_liked;
end;
$$;

comment on function public.add_comment_like(uuid, uuid, uuid, int8) is
  'SECURITY DEFINER: toggles a post_comment_likes row for auth.uid(). p_communityid unused (compat).';

revoke all on function public.add_comment_like(uuid, uuid, uuid, int8) from public;
grant execute on function public.add_comment_like(uuid, uuid, uuid, int8) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- count_comment — legacy compat wrapper. post.comment_count is trigger-maintained
-- (0013_post_triggers.sql); idempotent recompute so a stray client call can't desync it.
-- ---------------------------------------------------------------------------------------------
create or replace function public.count_comment(p_postid uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if auth.uid() is null then
    raise exception 'count_comment: no authenticated user';
  end if;

  update public.post
  set comment_count = (select count(*) from public.post_comment where post_id = p_postid)
  where id = p_postid;
end;
$$;

comment on function public.count_comment(uuid) is
  'Legacy compat wrapper: idempotently recomputes post.comment_count (trigger-owned in normal operation).';

revoke all on function public.count_comment(uuid) from public;
grant execute on function public.count_comment(uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- delete_comment — admin-only moderation delete (no client delete path was observed in the
-- frontend, per docs/features/03-comments.md §7). Hard delete: cascades to replies via FK.
-- Audited.
-- ---------------------------------------------------------------------------------------------
create or replace function public.delete_comment(p_comment_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'delete_comment: no authenticated user';
  end if;
  if not public.is_admin() then
    raise exception 'delete_comment: admin only';
  end if;

  delete from public.post_comment where id = p_comment_id;

  insert into public.audit_log (actor_id, action, target_table, target_id, details)
  values (v_uid, 'delete_comment', 'post_comment', p_comment_id, jsonb_build_object());
end;
$$;

comment on function public.delete_comment(uuid) is
  'SECURITY DEFINER, admin-only: hard-deletes a comment (moderation). Replies cascade via FK. Audited.';

revoke all on function public.delete_comment(uuid) from public;
grant execute on function public.delete_comment(uuid) to authenticated;

commit;

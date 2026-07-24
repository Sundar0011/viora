-- 0010_post_functions_writes.sql
-- Purpose: Batch 2 post CRUD RPCs (create/edit/delete/images/tags). Continuation of
-- 0009_post_functions_reads.sql, split to respect the 400-line-per-file cap (CLAUDE.md §5).
-- Per docs/decisions.md (2026-07-19, "User-facing writes"): anything with counters/state/
-- access-rules goes through a validated SECURITY DEFINER RPC, not raw client DML — covers the
-- direct-client `.insert`/`.update` gaps flagged in docs/features/02-home-feed-posts.md §8.

begin;

-- ---------------------------------------------------------------------------------------------
-- create_post — replaces the locked frontend's direct PostTable().insert. Forces
-- user_id = auth.uid(); ignores any client-sent counters/is_deleted/is_edited. Audited.
-- ---------------------------------------------------------------------------------------------
create or replace function public.create_post(
  p_content                text,
  p_content_text            text default null,
  p_see_post_access_id      int4 default 1,
  p_comment_post_access_id  int4 default 1,
  p_location                text default null,
  p_tagged_people           jsonb default null
)
returns public.post
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid  uuid := auth.uid();
  v_post public.post;
begin
  if v_uid is null then
    raise exception 'create_post: no authenticated user';
  end if;

  if not exists (select 1 from public.see_post_access where id = p_see_post_access_id) then
    raise exception 'create_post: invalid see_post_access_id';
  end if;
  if not exists (select 1 from public.comment_post_access where id = p_comment_post_access_id) then
    raise exception 'create_post: invalid comment_post_access_id';
  end if;

  insert into public.post (
    user_id, content, content_text, see_post_access_id, comment_post_access_id,
    location, tagged_people, likes_count, comment_count, share_count,
    is_edited, is_deleted, post_status
  )
  values (
    v_uid, p_content, p_content_text, p_see_post_access_id, p_comment_post_access_id,
    p_location, p_tagged_people, 0, 0, 0, false, false, 'active'
  )
  returning * into v_post;

  insert into public.audit_log (actor_id, action, target_table, target_id, details)
  values (v_uid, 'create_post', 'post', v_post.id, jsonb_build_object());

  return v_post;
end;
$$;

comment on function public.create_post(text, text, int4, int4, text, jsonb) is
  'SECURITY DEFINER: creates a post for auth.uid(). Replaces direct client PostTable().insert.';

revoke all on function public.create_post(text, text, int4, int4, text, jsonb) from public;
grant execute on function public.create_post(text, text, int4, int4, text, jsonb) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- update_user_post — RPC equivalent of the `update-user-post` edge function (content, access
-- ids, image_urls[]; sets is_edited/last_modified_date). Image URLs are already-uploaded storage
-- public URLs (upload itself stays client-side, per docs/features/02-home-feed-posts.md §5).
-- Owner-only.
-- ---------------------------------------------------------------------------------------------
create or replace function public.update_user_post(
  p_post_id                 uuid,
  p_content                 text default null,
  p_content_text            text default null,
  p_see_post_access_id      int4 default null,
  p_comment_post_access_id  int4 default null,
  p_image_urls              text[] default null
)
returns public.post
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid   uuid := auth.uid();
  v_owner uuid;
  v_post  public.post;
  v_url   text;
begin
  if v_uid is null then
    raise exception 'update_user_post: no authenticated user';
  end if;

  select user_id into v_owner from public.post where id = p_post_id for update;
  if v_owner is null then
    raise exception 'update_user_post: post not found';
  end if;
  if v_owner <> v_uid then
    raise exception 'update_user_post: not the post owner';
  end if;

  update public.post set
    content = coalesce(p_content, content),
    content_text = coalesce(p_content_text, content_text),
    see_post_access_id = coalesce(p_see_post_access_id, see_post_access_id),
    comment_post_access_id = coalesce(p_comment_post_access_id, comment_post_access_id),
    is_edited = true,
    last_modified_date = now()
  where id = p_post_id
  returning * into v_post;

  if p_image_urls is not null then
    delete from public.post_images where post_id = p_post_id;
    foreach v_url in array p_image_urls loop
      insert into public.post_images (post_id, image, e_media_type, user_id)
      values (p_post_id, v_url, 'image', v_uid);
    end loop;
  end if;

  insert into public.audit_log (actor_id, action, target_table, target_id, details)
  values (v_uid, 'update_user_post', 'post', p_post_id, jsonb_build_object());

  return v_post;
end;
$$;

comment on function public.update_user_post(uuid, text, text, int4, int4, text[]) is
  'SECURITY DEFINER: owner-only post edit. Replaces the update-user-post edge fn as a PL/pgSQL RPC.';

revoke all on function public.update_user_post(uuid, text, text, int4, int4, text[]) from public;
grant execute on function public.update_user_post(uuid, text, text, int4, int4, text[]) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- delete_post — soft delete only (is_deleted=true, post_status='removed'). Owner-only. Audited.
-- ---------------------------------------------------------------------------------------------
create or replace function public.delete_post(p_post_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid   uuid := auth.uid();
  v_owner uuid;
begin
  if v_uid is null then
    raise exception 'delete_post: no authenticated user';
  end if;

  select user_id into v_owner from public.post where id = p_post_id for update;
  if v_owner is null then
    raise exception 'delete_post: post not found';
  end if;
  if v_owner <> v_uid then
    raise exception 'delete_post: not the post owner';
  end if;

  update public.post
  set is_deleted = true, post_status = 'removed'
  where id = p_post_id;

  insert into public.audit_log (actor_id, action, target_table, target_id, details)
  values (v_uid, 'delete_post', 'post', p_post_id, jsonb_build_object());
end;
$$;

comment on function public.delete_post(uuid) is
  'SECURITY DEFINER: owner-only soft-delete of a post (is_deleted=true, post_status=removed).';

revoke all on function public.delete_post(uuid) from public;
grant execute on function public.delete_post(uuid) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- insert_post_image_rows — bulk-insert post_images rows for a post the caller owns.
-- p_communityid kept as a compat arg only (unused).
-- ---------------------------------------------------------------------------------------------
-- NOTE: p_communityid (defaulted, vestigial) moved LAST so it doesn't precede the required
-- p_postid — Postgres requires every param after a defaulted one to also have a default.
-- RPC calls are by name, so order is transparent to the frontend.
create or replace function public.insert_post_image_rows(
  p_userid       uuid,
  p_postid       uuid,
  image_urls     text[] default array[]::text[],
  media_type     text default 'image',
  p_communityid  int8 default null -- compat arg only, unused
)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid   uuid := auth.uid();
  v_owner uuid;
  v_url   text;
begin
  if v_uid is null or v_uid <> p_userid then
    raise exception 'insert_post_image_rows: auth.uid() mismatch';
  end if;

  select user_id into v_owner from public.post where id = p_postid;
  if v_owner is null or v_owner <> v_uid then
    raise exception 'insert_post_image_rows: caller does not own this post';
  end if;

  foreach v_url in array image_urls loop
    insert into public.post_images (post_id, image, e_media_type, user_id)
    values (p_postid, v_url, coalesce(media_type, 'image'), v_uid);
  end loop;
end;
$$;

comment on function public.insert_post_image_rows(uuid, uuid, text[], text, int8) is
  'SECURITY DEFINER: bulk-inserts post_images for a post owned by auth.uid(). p_communityid unused (compat).';

revoke all on function public.insert_post_image_rows(uuid, uuid, text[], text, int8) from public;
grant execute on function public.insert_post_image_rows(uuid, uuid, text[], text, int8) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- insert_tags — validates the caller owns the post; dedupes via the unique (post_id,user_id)
-- constraint. Also refreshes the denormalized post.tagged_people cache (tag table is
-- authoritative, per docs/decisions.md 2026-07-19).
-- ---------------------------------------------------------------------------------------------
create or replace function public.insert_tags(p_post_id uuid, p_user_ids uuid[])
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid   uuid := auth.uid();
  v_owner uuid;
begin
  if v_uid is null then
    raise exception 'insert_tags: no authenticated user';
  end if;

  select user_id into v_owner from public.post where id = p_post_id;
  if v_owner is null or v_owner <> v_uid then
    raise exception 'insert_tags: caller does not own this post';
  end if;

  insert into public.tag (post_id, user_id)
  select p_post_id, u from unnest(p_user_ids) as u
  on conflict (post_id, user_id) do nothing;

  update public.post
  set tagged_people = (
    select coalesce(jsonb_agg(t.user_id), '[]'::jsonb)
    from public.tag t
    where t.post_id = p_post_id
  )
  where id = p_post_id;
end;
$$;

comment on function public.insert_tags(uuid, uuid[]) is
  'SECURITY DEFINER: post-owner-only tag insert; refreshes post.tagged_people cache from the authoritative tag table.';

revoke all on function public.insert_tags(uuid, uuid[]) from public;
grant execute on function public.insert_tags(uuid, uuid[]) to authenticated;

commit;

-- 0013_post_triggers.sql
-- Purpose: Batch 2 counter triggers (self-healing denormalized counts, per docs/decisions.md
-- 2026-07-19 "Denormalized counters ... maintained by DB TRIGGERS") plus the single-level
-- comment-threading validation trigger recommended in docs/database/02-tables-posts-comments.md.
--
-- Per docs/database/08-triggers-counters.md §1: SECURITY DEFINER is NOT required for these —
-- trigger functions run with the privileges of the table owner regardless of INVOKER/DEFINER on
-- the function, so plain SECURITY INVOKER is used; search_path is still pinned defensively.

begin;

-- ---------------------------------------------------------------------------------------------
-- post_like -> post.likes_count
-- ---------------------------------------------------------------------------------------------
create or replace function public.trg_recompute_post_likes_count()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
  v_post_id uuid := coalesce(new.post_id, old.post_id);
begin
  update public.post
  set likes_count = (select count(*) from public.post_like where post_id = v_post_id)
  where id = v_post_id;
  return coalesce(new, old);
end;
$$;

drop trigger if exists post_like_recompute_likes_count on public.post_like;
create trigger post_like_recompute_likes_count
  after insert or delete on public.post_like
  for each row
  execute function public.trg_recompute_post_likes_count();

-- ---------------------------------------------------------------------------------------------
-- post_share -> post.share_count
-- ---------------------------------------------------------------------------------------------
create or replace function public.trg_recompute_post_share_count()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
  v_post_id uuid := coalesce(new.post_id, old.post_id);
begin
  update public.post
  set share_count = (select count(*) from public.post_share where post_id = v_post_id)
  where id = v_post_id;
  return coalesce(new, old);
end;
$$;

drop trigger if exists post_share_recompute_share_count on public.post_share;
create trigger post_share_recompute_share_count
  after insert or delete on public.post_share
  for each row
  execute function public.trg_recompute_post_share_count();

-- ---------------------------------------------------------------------------------------------
-- post_comment -> post.comment_count (top-level + replies both count, per docs/features/
-- 03-comments.md §5) AND, when the row is a reply, the parent's replies_count.
-- ---------------------------------------------------------------------------------------------
create or replace function public.trg_recompute_post_comment_counts()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
  v_post_id   uuid := coalesce(new.post_id, old.post_id);
  v_parent_id uuid := coalesce(new.parent_comment_id, old.parent_comment_id);
begin
  update public.post
  set comment_count = (select count(*) from public.post_comment where post_id = v_post_id)
  where id = v_post_id;

  if v_parent_id is not null then
    update public.post_comment
    set replies_count = (select count(*) from public.post_comment where parent_comment_id = v_parent_id)
    where id = v_parent_id;
  end if;

  return coalesce(new, old);
end;
$$;

drop trigger if exists post_comment_recompute_counts on public.post_comment;
create trigger post_comment_recompute_counts
  after insert or delete on public.post_comment
  for each row
  execute function public.trg_recompute_post_comment_counts();

-- ---------------------------------------------------------------------------------------------
-- post_comment_likes -> post_comment.likes_count
-- ---------------------------------------------------------------------------------------------
create or replace function public.trg_recompute_comment_likes_count()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
  v_comment_id uuid := coalesce(new.comment_id, old.comment_id);
begin
  update public.post_comment
  set likes_count = (select count(*) from public.post_comment_likes where comment_id = v_comment_id)
  where id = v_comment_id;
  return coalesce(new, old);
end;
$$;

drop trigger if exists post_comment_likes_recompute_count on public.post_comment_likes;
create trigger post_comment_likes_recompute_count
  after insert or delete on public.post_comment_likes
  for each row
  execute function public.trg_recompute_comment_likes_count();

-- ---------------------------------------------------------------------------------------------
-- post -> public_user_profile.post_count (per author). Counts non-deleted posts only.
-- ---------------------------------------------------------------------------------------------
-- SECURITY DEFINER: this trigger writes the column-locked public_user_profile.post_count, so it
-- runs as owner to bypass the client-facing column REVOKE regardless of the triggering write path.
create or replace function public.trg_recompute_profile_post_count()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id uuid;
begin
  v_user_id := coalesce(new.user_id, old.user_id);

  update public.public_user_profile
  set post_count = (
    select count(*) from public.post where user_id = v_user_id and is_deleted = false
  )
  where id = v_user_id;

  -- Cross-user edge case: if user_id somehow changes on UPDATE (not expected by any RPC above,
  -- but defensive), also recompute the old owner's count.
  if tg_op = 'UPDATE' and old.user_id is distinct from new.user_id then
    update public.public_user_profile
    set post_count = (
      select count(*) from public.post where user_id = old.user_id and is_deleted = false
    )
    where id = old.user_id;
  end if;

  return coalesce(new, old);
end;
$$;

drop trigger if exists post_recompute_profile_post_count on public.post;
create trigger post_recompute_profile_post_count
  after insert or delete or update of is_deleted, user_id on public.post
  for each row
  execute function public.trg_recompute_profile_post_count();

-- ---------------------------------------------------------------------------------------------
-- Single-level comment threading: a reply's parent must itself be top-level (parent_comment_id
-- IS NULL), per docs/database/02-tables-posts-comments.md recommended CHECK (Postgres CHECK
-- can't self-reference other rows, hence a BEFORE INSERT trigger).
-- ---------------------------------------------------------------------------------------------
create or replace function public.trg_enforce_single_level_threading()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
  v_parent_of_parent uuid;
begin
  if new.parent_comment_id is not null then
    select parent_comment_id into v_parent_of_parent
    from public.post_comment
    where id = new.parent_comment_id;

    if v_parent_of_parent is not null then
      raise exception 'post_comment: cannot reply to a reply (single-level threading only)';
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists post_comment_single_level_threading on public.post_comment;
create trigger post_comment_single_level_threading
  before insert on public.post_comment
  for each row
  execute function public.trg_enforce_single_level_threading();

commit;

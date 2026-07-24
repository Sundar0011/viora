-- 0078_notification_triggers_posts_follows.sql
-- Purpose: Batch 7 (Notifications) — producer triggers for posts/comments/follows. Each is
-- SECURITY DEFINER (writes the otherwise server-only `notifications` table via public.notify(),
-- 0077), AFTER INSERT, and revoked from every client role below (matches the
-- trg_recompute_*/trg_chat_message_preview precedent, 0013/0032/0041/0048/0063 — trigger
-- functions are never called as RPCs).
--
-- TYPE VALUES used here match the CONFIRMED observed set from docs/features/11-notifications.md
-- §3 (post/comment/event/business/sale/group/invite/group_invite) wherever a fit exists.
-- 'follow' is NOT in that confirmed set (the frontend's notification list has no dedicated
-- follow-tab routing) — used anyway since a "X started followed you" event has no other type to
-- fold into, and it naturally lands in the 'all' bucket (get_notifications, 0081, only special-
-- cases post/group/event/business/sale into their own tab arrays). -- TODO(confirm) with product
-- whether 'follow' is the right type string, or whether follow notifications are out of scope.

begin;

-- ---------------------------------------------------------------------------------------------
-- post_like -> notify the post's author. type='post' (opens CommentsPageWidget(postId), matching
-- the frontend's own type='post' routing — a like has no distinct 'like' type in the confirmed
-- set, feature doc §8.1).
-- ---------------------------------------------------------------------------------------------
create or replace function public.trg_notify_post_like()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_author_id uuid;
  v_liker_name text;
begin
  select user_id into v_author_id from public.post where id = new.post_id;
  select name into v_liker_name from public.public_user_profile where id = new.user_id;

  perform public.notify(
    p_sender_id   => new.user_id,
    p_receiver_id => v_author_id,
    p_type        => 'post',
    p_content     => coalesce(v_liker_name, 'Someone') || ' liked your post',
    p_post_id     => new.post_id
  );

  return new;
end;
$$;

drop trigger if exists post_like_notify on public.post_like;
create trigger post_like_notify
  after insert on public.post_like
  for each row
  execute function public.trg_notify_post_like();

revoke all on function public.trg_notify_post_like() from public, anon, authenticated;

-- ---------------------------------------------------------------------------------------------
-- post_comment -> notify the post's author (type='comment'); if the comment is a reply
-- (parent_comment_id set), ALSO notify the parent comment's author (a distinct notification,
-- also type='comment' — no separate 'reply' type exists in the confirmed set).
-- ---------------------------------------------------------------------------------------------
create or replace function public.trg_notify_post_comment()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_post_author_id     uuid;
  v_parent_author_id   uuid;
  v_commenter_name     text;
begin
  select user_id into v_post_author_id from public.post where id = new.post_id;
  select name into v_commenter_name from public.public_user_profile where id = new.user_id;

  perform public.notify(
    p_sender_id   => new.user_id,
    p_receiver_id => v_post_author_id,
    p_type        => 'comment',
    p_content     => coalesce(v_commenter_name, 'Someone') || ' commented on your post',
    p_post_id     => new.post_id,
    p_comment_id  => new.id
  );

  if new.parent_comment_id is not null then
    select user_id into v_parent_author_id from public.post_comment where id = new.parent_comment_id;

    if v_parent_author_id is distinct from v_post_author_id then
      perform public.notify(
        p_sender_id   => new.user_id,
        p_receiver_id => v_parent_author_id,
        p_type        => 'comment',
        p_content     => coalesce(v_commenter_name, 'Someone') || ' replied to your comment',
        p_post_id     => new.post_id,
        p_comment_id  => new.id
      );
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists post_comment_notify on public.post_comment;
create trigger post_comment_notify
  after insert on public.post_comment
  for each row
  execute function public.trg_notify_post_comment();

revoke all on function public.trg_notify_post_comment() from public, anon, authenticated;

-- ---------------------------------------------------------------------------------------------
-- follows -> notify the followed user. type='follow' (TODO(confirm), see file header).
-- ---------------------------------------------------------------------------------------------
create or replace function public.trg_notify_follow()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_follower_name text;
begin
  select name into v_follower_name from public.public_user_profile where id = new.follower_id;

  perform public.notify(
    p_sender_id   => new.follower_id,
    p_receiver_id => new.following_id,
    p_type        => 'follow',
    p_content     => coalesce(v_follower_name, 'Someone') || ' started following you'
  );

  return new;
end;
$$;

drop trigger if exists follows_notify on public.follows;
create trigger follows_notify
  after insert on public.follows
  for each row
  execute function public.trg_notify_follow();

revoke all on function public.trg_notify_follow() from public, anon, authenticated;

commit;

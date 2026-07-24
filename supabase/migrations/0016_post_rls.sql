-- 0016_post_rls.sql
-- RLS policies for Batch 2 tables. Reviewed in docs/rls-policies-draft.md ("Batch 2") and
-- approved 2026-07-19. Two stakeholder choices baked in:
--   • Comment reads ride on POST visibility (a visible post shows its existing comments even when
--     comment_post_access = 'No One'; that setting only blocks NEW comments).
--   • Blocking is enabled NOW: owner-scoped INSERT/DELETE on blocks (self-block prevented). The
--     feed already filters blocked users both directions (is_blocked_pair in the read RPCs).
--
-- Technical fix vs. the draft: policies call a NEW self-scoped wrapper can_view_post_self(post_id)
-- instead of can_view_post(auth.uid(), post_id). can_view_post/is_blocked_pair/can_comment_post
-- are internal-only (revoked from authenticated), so a policy USING clause evaluated as the
-- authenticated role cannot call them directly. The wrapper (SECURITY DEFINER, uses auth.uid()
-- internally, granted to authenticated) is the one visibility entrypoint the client role may call;
-- the arbitrary-viewer can_view_post stays internal (prevents probing another user's visibility).

begin;

-- Self-scoped visibility wrapper for RLS policies (the only client-callable visibility fn).
create or replace function public.can_view_post_self(p_post_id uuid)
returns boolean language sql stable security definer
set search_path = public, pg_temp as $$
  select public.can_view_post(auth.uid(), p_post_id);
$$;
comment on function public.can_view_post_self(uuid) is
  'Self-scoped can_view_post(auth.uid(), post) — the only visibility helper granted to clients (for RLS).';
revoke all on function public.can_view_post_self(uuid) from public, anon;
grant execute on function public.can_view_post_self(uuid) to authenticated;

-- post — visible-only SELECT; writes RPC-only (no client DML policy).
create policy "post_select_visible" on public.post for select to authenticated
  using ( (select public.can_view_post_self(post.id)) );

-- post_images — SELECT follows parent post visibility; writes RPC-only.
create policy "post_images_select_visible" on public.post_images for select to authenticated
  using ( (select public.can_view_post_self(post_images.post_id)) );

-- post_like — SELECT follows parent post visibility; writes via add_like() RPC only.
create policy "post_like_select_visible" on public.post_like for select to authenticated
  using ( (select public.can_view_post_self(post_like.post_id)) );

-- post_share — SELECT follows parent post visibility; writes via update_post_share_count() RPC.
create policy "post_share_select_visible" on public.post_share for select to authenticated
  using ( (select public.can_view_post_self(post_share.post_id)) );

-- tag — SELECT follows parent post visibility (null post_id never selectable); writes via insert_tags().
create policy "tag_select_visible" on public.tag for select to authenticated
  using ( tag.post_id is not null and (select public.can_view_post_self(tag.post_id)) );

-- Lookup tables — readable by any authenticated user; admin-curated via migration (no client writes).
create policy "see_post_access_select_authenticated" on public.see_post_access for select to authenticated
  using ( true );
create policy "comment_post_access_select_authenticated" on public.comment_post_access for select to authenticated
  using ( true );

-- post_comment — SELECT rides on post visibility (existing comments stay readable even when
-- comment_post_access='No One' — approved 2026-07-19). Writes via add_comment(); delete admin-only.
create policy "post_comment_select_visible" on public.post_comment for select to authenticated
  using ( (select public.can_view_post_self(post_comment.post_id)) );

-- post_comment_likes — SELECT follows parent post visibility; writes via add_comment_like() RPC.
create policy "post_comment_likes_select_visible" on public.post_comment_likes for select to authenticated
  using ( (select public.can_view_post_self(post_comment_likes.post_id)) );

-- blocks — owner (blocker) manages own rows. SELECT own; INSERT/DELETE own (self-block prevented).
-- Enabled now (approved 2026-07-19) so the block button works; matches the frontend's direct
-- BlocksTable insert/delete, which is a trivial owner-row write (decision #4 allows scoped RLS).
create policy "blocks_select_own" on public.blocks for select to authenticated
  using ( blocker_id = (select auth.uid()) );
create policy "blocks_insert_own" on public.blocks for insert to authenticated
  with check ( blocker_id = (select auth.uid()) and blocker_id <> blocked_id );
create policy "blocks_delete_own" on public.blocks for delete to authenticated
  using ( blocker_id = (select auth.uid()) );

commit;
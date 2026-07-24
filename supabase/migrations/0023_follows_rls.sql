-- 0023_follows_rls.sql
-- RLS for the follows table. Reviewed in docs/rls-policies-draft.md ("Batch 3 — Follows") and
-- approved 2026-07-19 as Option B (owner-involved SELECT): a user may directly read a follow row
-- only if they are the follower or the followee. Other users' follower/following/nearby lists go
-- through the SECURITY DEFINER read RPCs (get_followers/get_following/get_followers_nearby), which
-- bypass RLS and block-filter themselves. Writes are RPC-only via user_follow() (self-follow
-- guarded, counters trigger-maintained) — no client INSERT/UPDATE/DELETE policy.
begin;

create policy "follows_select_own_involved" on public.follows for select to authenticated
  using ( follower_id = (select auth.uid()) or following_id = (select auth.uid()) );
-- No INSERT/UPDATE/DELETE policy: follow/unfollow only via user_follow() RPC.

commit;

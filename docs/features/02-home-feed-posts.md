# Feature: Home Feed & Posts

> Source of truth = the Flutter frontend. This doc records what the backend MUST provide
> for this feature to work. Derived from `lib/` — do not invent behavior the code doesn't show.

## 1. Overview
- **What it is:** The neighborhood feed and the post lifecycle behind it — creating, editing,
  deleting text/image posts; per-post view + comment access control; likes; internal (in-app)
  and external sharing; an AI-generated TLDR summary; and lookup tables for special post-type
  placeholders (poll / safety / thank-neighbor "deleted" screens).
- **Why it exists / user value:** The feed is the core Nextdoor-style surface where neighbors
  post updates, react (like), and share posts to each other via DM or the OS share sheet.
- **Related features:** Comments (`comments_page`, `comment_post_access`), Follows
  (`follows` table, feed visibility), Groups (group posts), Chat/Messages (internal share
  sends a post link as a DM), User profile post counts.

## 2. Screens & widgets
| Screen / widget (path under `lib/`) | Purpose | Key actions |
|---|---|---|
| `pages/home/home_page/home_page_widget.dart` | Main neighborhood feed | Renders `FFAppState().AsPost` (from `get_visible_posts`); loading state via `pageName='loading'`; per-item likes/images lookups |
| `pages/home/comp_loading/` | Feed skeleton/loading placeholder | Shown while feed refreshes |
| `pages/home/comp_likes/comp_likes_widget.dart` | Bottom sheet listing users who liked a post | `GetLikedUsers` / `GetlimitedPostLikes` |
| `pages/home/comp_post_delete/comp_post_delete_widget.dart` | Delete-post confirmation | Soft-delete via `PostTable().update` (`is_deleted=true`, `post_status='removed'`) |
| `pages/home/comp_three_dot_edit_post/` | Post "…" menu (edit/delete entry) | Routes to edit / delete, uses neighbourhood post fetch |
| `pages/home/comp_three_dot_block_user/`, `comp_block/`, `comp_mute*/`, `comp_report_*/` | Moderation actions on a post/author | (block/mute/report — separate feature; touch feed) |
| `pages/home/comp_home_text/` | Renders post rich-text body | Displays `content` / `content_text` |
| `pages/post/create_post/create_post_widget.dart` | Compose a new post | `PostTable().insert` → tag rows → storage upload → `InsertImageUrls` → profile count → `GenerateTLDR` → optional group tagging |
| `pages/post/editpost/editpost_widget.dart` | Edit an existing post | `uploadSupabaseStorageFiles` → `UpdatePost` (edge) → `GenerateTLDR` |
| `pages/post/comp_view_access/comp_view_access_widget.dart` | "Who can see the post?" + "Comment Control" chooser | Sets `FFAppState().postControl` / `.commentControl`; on edit writes `see_post_access_id` / `comment_post_access_id` |
| `pages/post/create_poll_deleted/`, `post_about_safety_deleted/`, `thank_neighbor_deleted/` | Placeholder "this post type was deleted/deprecated" screens | Static screens only — no live create flow found in feed |
| `components/comp_post_like_widget.dart` | Like/unlike toggle + like count | `AddLike` (toggle), reads `post_like` for current user, opens `CompLikesWidget` |
| `components/dummylikecomponent_widget.dart` | Optimistic/placeholder like UI | Visual only |
| `components/comp_share_widget.dart` | Share sheet (in-app users + OS share) | `InternalShare` (user list), `UpdatePostShareCount`, sends post-link DM via `MessagesTable`/`ChatTable`, `Share.share(...)` |
| `components/comp_pageview_widget.dart` | Swipeable image carousel for post images | Displays `post_images` |

## 3. Data model (tables & columns)
Types/nullability read from the FlutterFlow Row classes under
`lib/backend/supabase/database/tables/`.

### `post`
- **Purpose:** One neighborhood post (text + optional images), with counters, access control,
  soft-delete, and AI summary.
- **Columns:**
  | Column | Type | Null? | Notes (PK/FK/default/enum) |
  |---|---|---|---|
  | `id` | uuid (String) | no | PK. Client does not send it on insert (DB default `gen_random_uuid()` expected). |
  | `created_at` | timestamptz | no | default `now()` |
  | `user_id` | uuid (String) | no | FK → author (`users`/`profiles`). Set to `currentUserUid` on insert |
  | `content` | text (String) | no | Rich-text JSON string (`FFAppState().richTextContent`) |
  | `content_text` | text (String) | yes | Plain-text version of body (source for TLDR) |
  | `likes_count` | int4 | yes | default 0; maintained by `add_like` |
  | `comment_count` | int4 | yes | default 0; maintained by comments feature |
  | `share_count` | int4 | yes | default 0; maintained by `update_post_share_count` |
  | `is_edited` | bool | yes | default false; set true on edit (via `update-user-post`) |
  | `is_deleted` | bool | yes | default false; set true on soft-delete |
  | `last_modified_date` | timestamptz | yes | set on edit |
  | `see_post_access_id` | int4 | no | FK → `see_post_access.id` (view scope) |
  | `comment_post_access_id` | int4 | no | FK → `comment_post_access.id` (who may comment) |
  | `community_id` | int4 | no | FK → community/neighborhood; from `FFAppState().communityId` |
  | `is_group_post` | bool | yes | default false; true when posted into a group |
  | `group_id` | uuid (String) | yes | FK → `group.id` when `is_group_post` |
  | `location` | text (String) | yes | Optional post location string |
  | `post_status` | text (String) | no | Enum-like: `active` / `removed` / `suspended` (Dart `Status` enum). Set `removed` on delete |
  | `tagged_people` | jsonb (List) | — | Array of tagged people (names/ids) stored inline on the post |
  | `tldr` | text (String) | yes | AI-generated summary, written by `generate-tldr` edge fn |
- **Foreign keys / relationships:** `user_id`→user; `community_id`→community; `group_id`→group;
  `see_post_access_id`→`see_post_access`; `comment_post_access_id`→`comment_post_access`.
- **Indexes needed:** `user_id`, `community_id`, `group_id`, `see_post_access_id`,
  `comment_post_access_id`, `post_status`, `is_deleted`, and `created_at` (feed ordering).

### `post_images`
- **Purpose:** Media rows attached to a post (one row per image/media file).
- **Columns:**
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid (String) | no | PK |
  | `created_at` | timestamptz | no | default `now()` |
  | `community_id` | int4 | no | FK → community |
  | `post_id` | uuid (String) | no | FK → `post.id` (on delete cascade expected) |
  | `image` | text (String) | no | Public storage URL |
  | `e_media_type` | text (String) | no | Media type, e.g. `'image'` (passed as `media_type`) |
  | `user_id` | uuid (String) | no | FK → uploader |
- **Indexes needed:** `post_id`, `community_id`, `user_id`.

### `post_like`
- **Purpose:** One row per (user, post) like. Presence = liked; delete = unliked.
- **Columns:**
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid (String) | no | PK |
  | `created_at` | timestamptz | no | default `now()` |
  | `community_id` | int4 | no | FK → community |
  | `post_id` | uuid (String) | no | FK → `post.id` |
  | `user_id` | uuid (String) | no | FK → liker |
- **Indexes needed:** `post_id`, `user_id`, and a UNIQUE (`post_id`,`user_id`) to enforce
  single like. Client reads with `.eq(post_id).eq(user_id)` to render filled/outline heart.

### `post_share`
- **Purpose:** One row per share event of a post by a user.
- **Columns:**
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid (String) | no | PK |
  | `created_at` | timestamptz | no | default `now()` |
  | `community_id` | int4 | no | FK → community |
  | `post_id` | uuid (String) | no | FK → `post.id` |
  | `user_id` | uuid (String) | no | FK → sharer |
- **Indexes needed:** `post_id`, `user_id`, `community_id`.

### `tag`
- **Purpose:** Join rows tagging users on a post (mentions/tagged people).
- **Columns:**
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid (String) | no | PK |
  | `created_at` | timestamptz | no | default `now()` |
  | `post_id` | uuid (String) | yes | FK → `post.id` |
  | `user_id` | uuid (String) | no | FK → tagged user |
- **Note:** `post.tagged_people` (jsonb) ALSO stores tagged people inline — the app writes both
  the inline array and the `tag` join rows. Confirm which is authoritative (see §8).
- **Indexes needed:** `post_id`, `user_id`.

### `see_post_access` (lookup)
- **Purpose:** View-scope lookup referenced by `post.see_post_access_id`.
- **Columns:** `id` int4 PK, `created_at` timestamptz, `name` text (not null).
- **Known values (from `comp_view_access`):** `1` = "Anyone on or off SquaDD",
  `2` = "Your Neighbourhood Only", `3` = "Nearby Neighbourhood".

### `comment_post_access` (lookup)
- **Purpose:** Who-can-comment lookup referenced by `post.comment_post_access_id`.
- **Columns:** `id` int4 PK, `created_at` timestamptz, `name` text (not null).
- **Known values (from `comp_view_access`):** `1` = "Anyone on SquaDD", `4` = "No One".
  (UI branches also imply 2/3 = neighbourhood scopes — confirm full set, see §8.)

## 4. Backend calls (API / RPC / Edge)
Project ref in all URLs: **`wgcqstmmkcdjnnpuvspr`** (legacy project — NOT Viora's own; see §8).

| Call / query | Type | Inputs | Returns | Called from |
|---|---|---|---|---|
| `get_visible_posts` (`GetPostCall`) | RPC (POST, no body) | (JWT only) | Full visible-post feed list (JSON) → cached in `FFAppState().AsPost` | `home_page`, after create/delete |
| `get_neighbourhood_post_data` (`GetneighbourhoodPostsCall`) | RPC | `p_userid`, `p_communityid` | Neighborhood-scoped post list | `neighbourhood_explore`, `user_all_post`, three-dot menu |
| `get_post_user_data` (`GetPostUserDataCall`) | RPC | `p_postid`, `p_userid` | `{name, city, profile_image, images_count, following, liked_users[], see_post_access_id, comment_post_access_id, content, images[]}` | Post detail |
| `PostTable().insert({...})` | direct DML | post fields (§3) | inserted `PostRow` (`id`) | `create_post` |
| `PostTable().update({...})` | direct DML | `group_id`/`is_group_post` (create); `see/comment_post_access_id` (view-access edit); `is_deleted`+`post_status` (delete) | — | `create_post`, `comp_view_access`, `comp_post_delete` |
| `update-user-post` (`UpdatePostCall`) | **Edge fn** | `user_id`, `post_id`, `see_post_access_id`, `comment_post_access_id`, `content`, `image_urls[]` | success | `editpost` |
| `insert_post_image_rows` (`InsertImageUrlsCall`) | RPC | `p_userid`, `p_communityid`, `p_postid`, `image_urls[]`, `media_type` | — | `create_post` |
| `SupaFlow.client.storage.from('post-images').uploadBinary(...)` | Storage | binary file, path=`<postId>/<file>` | public URL | `create_post`, `editpost` (`uploadSupabaseStorageFiles`) |
| `insert_tags` (`InsertTagsCall`) | RPC | `p_post_id`, `p_user_ids` | — | (tag flow) |
| `tag` insert via `insertTagRows` action | direct DML | `[{post_id, user_id}...]` | bool | `create_post` custom action |
| `add_like` (`AddLikeCall`) | RPC | `p_userid`, `p_postid`, `p_communityid` | toggles like; updates `likes_count` | `comp_post_like` |
| `PostLikeTable().querySingleRow(...)` | direct DML (SELECT) | `post_id`,`user_id` | like row or none (heart state) | `comp_post_like`, `home_page` |
| `count_likes` (`CountLikesCall`) | RPC | `p_type`, `p_post_id`, `p_commentid` | like count (post or comment) | likes UI |
| `get_post_likes` (`GetLikedUsersCall`) | RPC | `p_postid` | users who liked | `comp_likes` |
| `get_limited_post_likes` (`GetlimitedPostLikesCall`) | RPC | `p_postid`, `p_screenwidth` | limited liked-user avatars (fit to width) | `comp_likes` |
| `get_internal_share` (`InternalShareCall`) | RPC | `p_userid` | shareable in-app user list | `comp_share` |
| `update_post_share_count` (`UpdatePostShareCountCall`) | RPC | `p_postid`, `p_userid`, `p_communityid` | inserts `post_share` + bumps `share_count` | `comp_share` |
| `add_post_count` (`PostCountIncrementCall`) | RPC | `p_userid` | increments user's post count | (post-count flow) |
| `update_user_profile_counts` (`UpdateUserProfileCountsCall`) | RPC | `p_option` (`'post'`) | adjusts profile counters | `create_post`, `comp_post_delete` |
| `generate-tldr` (`GenerateTLDRCall`) | **Edge fn** | `comment_id`, `post_id`, `text` | writes `post.tldr` (AI summary) | `create_post`, `editpost` |
| `deleteSupabaseFileFromPublicUrl(url)` | Storage | public URL | removes storage object | edit/replace image flows |

## 5. Business rules & flows
**Create post (`create_post`):**
1. `PostTable().insert` with `user_id=currentUserUid`, `content` (rich-text JSON), counters=0,
   `is_edited/is_deleted=false`, `see_post_access_id=postControl`,
   `comment_post_access_id=commentControl`, `community_id`, `tagged_people`. Returns new `id`.
2. `insertTagRows(postId, taggedUserIds)` → inserts into `tag`.
3. Upload each selected image to Storage bucket **`post-images`**, folder = post `id`; collect
   public URLs.
4. `insert_post_image_rows` with the URLs + `media_type='image'`.
5. `update_user_profile_counts(option:'post')` (increment author post count).
6. `generate-tldr(post_id, text)` → AI summary saved to `post.tldr`.
7. If posted into a group: `PostTable().update` sets `group_id` + `is_group_post=true`.
8. Refresh feed via `get_visible_posts` → `FFAppState().AsPost`.

**Edit post (`editpost`):** upload any new images to `post-images` → `update-user-post` edge fn
(sets content, access ids, image_urls; marks `is_edited`, `last_modified_date`) → `generate-tldr`
again → navigate home on success.

**View / comment access:** chosen in `comp_view_access`. On create these live in
`FFAppState().postControl` / `.commentControl` and are written at insert. On `pageType=='edit'`
the sheet writes `see_post_access_id` + `comment_post_access_id` directly via `PostTable().update`.
Feed visibility (`get_visible_posts`) must enforce these scopes server-side (neighborhood/nearby/
public + follows + group membership).

**Delete post (soft):** `comp_post_delete` sets `is_deleted=true` and `post_status='removed'`,
then refreshes feed and decrements profile post count. No hard delete observed.

**Likes:** `add_like` is a toggle — heart state derived by querying `post_like` for
(`post_id`,`user_id`). Like adds/removes a `post_like` row and keeps `post.likes_count` in sync.
`count_likes` / `get_post_likes` / `get_limited_post_likes` power the count and liker list.

**Share:** two paths, both first call `update_post_share_count` (inserts `post_share`, bumps
`share_count`): (a) **internal** — pick a user from `get_internal_share`, find/create a DM chat,
insert a `messages` row carrying `${URL}?pagename=...&id=<postId>` link; (b) **external** —
OS share sheet via `Share.share(<deep link>)`.

**Feed sources:** main feed = `get_visible_posts` (no args, JWT-scoped, cached in
`FFAppState().AsPost`); neighborhood/profile lists = `get_neighbourhood_post_data`
(`p_userid`,`p_communityid`).

**Special post types (poll / safety / thank-neighbor):** only "…deleted" placeholder screens
exist in `pages/post/`; no active create flow for these types was found in the feed code. Treat
as deprecated/removed unless product says otherwise (see §8).

## 6. Realtime / notifications
- No Supabase Realtime channel subscriptions found in the feed/post widgets — the feed refreshes
  by re-calling `get_visible_posts` after mutations (create/delete), not via live subscription.
- Likes/hearts update by re-querying `post_like` and resetting a `Completer` (manual refresh).
- Push (OneSignal/FCM) not wired in these widgets; tags/likes may trigger notifications
  server-side — confirm (see §8). Note `editpost` passes `FFAppState().fcmToken` as the TLDR
  `token` arg (likely a bug — should be the JWT).

## 7. Backend to build (Supabase rebuild checklist)
- [ ] Tables: `post`, `post_images`, `post_like`, `post_share`, `tag`, `see_post_access`,
      `comment_post_access` — columns/types/FKs per §3; seed the two lookup tables with known
      values (see_post: 1/2/3; comment: 1/…/4).
- [ ] Indexes: every FK above + `post.created_at`, `post.post_status`, `post.is_deleted`;
      UNIQUE(`post_like.post_id`,`user_id`).
- [ ] RLS (deny-by-default):
      - `post`: SELECT gated by `get_visible_posts` visibility rules (author, community/
        neighborhood scope via `see_post_access_id`, follows, group membership, `is_deleted=false`).
        INSERT/UPDATE/DELETE author-or-admin only; user writes should go through RPC/edge, not the
        raw `PostTable().insert`/`update` the frontend currently uses (see §8 security gap).
      - `post_images`/`tag`: writes limited to the post author; SELECT follows post visibility.
      - `post_like`/`post_share`: INSERT/DELETE limited to `auth.uid() = user_id`; SELECT per post
        visibility.
      - lookups: SELECT to `authenticated`; no client writes.
- [ ] RPCs (PL/pgSQL) to (re)build: `get_visible_posts`, `get_neighbourhood_post_data`,
      `get_post_user_data`, `add_like`, `count_likes`, `get_post_likes`, `get_limited_post_likes`,
      `insert_post_image_rows`, `insert_tags`, `get_internal_share`, `update_post_share_count`,
      `add_post_count`, `update_user_profile_counts`. Each: validate `auth.uid()`, enforce
      ownership/community, SECURITY INVOKER unless a counter update needs DEFINER (then follow §6
      hard rules — search_path, REVOKE/GRANT, audit).
- [ ] Storage bucket **`post-images`** (public read) with policies: authenticated upload to a
      path prefixed by their own post's id; object owner/author delete only.
- [ ] Edge functions: `update-user-post` (edit flow) and `generate-tldr` (AI summary). Both take
      the user JWT. **`generate-tldr` almost certainly calls an external AI API — its API key is a
      server-side secret and must live in edge-function env, never in the client.** Verify no
      `sk_*` leaks (CLAUDE.md §5 known issue).
- [ ] Triggers/counters: keep `likes_count`/`share_count`/`comment_count` consistent (trigger or
      inside the RPCs). Confirm whether TLDR should also run via a DB trigger vs. client call.

## 8. Open questions & risks
1. **Wrong project ref.** All URLs point to `wgcqstmmkcdjnnpuvspr.supabase.co` — the legacy
   backend, NOT Viora's own project. The rebuild must recreate all of the above in Viora's
   dedicated project and repoint the client.
2. **Direct client DML violates the security model.** Create/delete/view-access use
   `PostTable().insert`/`.update` and `tag` insert directly from the client (CLAUDE.md §6 forbids
   this for non-trivial tables). Decide whether to keep these as direct DML behind strict RLS or
   move them to RPCs. Frontend is "done", so RLS must make the existing direct calls safe.
3. **`generate-tldr` secrets.** Confirm which AI provider it calls and that the key is server-only.
   Also `editpost` passes `FFAppState().fcmToken` (not the JWT) as its `token` — likely a bug;
   confirm the edge fn's auth expectation.
4. **Tagging stored twice** — inline `post.tagged_people` (jsonb) AND `tag` rows AND an
   `insert_tags` RPC AND an `insertTagRows` client action. Determine the authoritative source and
   whether `insert_tags` vs `insertTagRows` are both live.
5. **Lookup value sets unconfirmed.** `see_post_access` (1/2/3 seen) and `comment_post_access`
   (1 and 4 seen; UI implies 2/3) need their full row sets confirmed before seeding.
6. **`get_visible_posts` visibility logic is opaque** (no args, JWT-only). The exact filter
   (community/neighborhood radius, follows, groups, blocked/muted users, `post_status`,
   `is_deleted`) must be reverse-engineered from product intent — the frontend only consumes the
   result.
7. **Special post types (poll/safety/thank-neighbor)** appear only as "deleted" placeholder
   screens. Confirm they are deprecated (no schema needed) vs. a feature to rebuild.
8. **Counters vs. rows.** `likes_count`/`share_count` are denormalized on `post` and also derivable
   from `post_like`/`post_share`. Confirm the RPCs/triggers keep them in sync and are the only
   writers.
9. **`community_id` hardcoding.** Some flows use `community_id: 1` literally (e.g. chat on share).
   Confirm whether community is always 1 today or truly multi-community.

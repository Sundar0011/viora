# Feature: Comments

> Source of truth = the Flutter frontend. This doc records what the backend MUST provide
> for this feature to work. Derived from `lib/` — do not invent behavior the code doesn't show.

## 1. Overview
- **What it is:** Users comment on a post, reply to a comment (one level of threading),
  like a comment, and see running counts (likes per comment, replies per comment, total
  comments per post). Comments and their replies are shown on the full-screen `CommentsPage`
  for a post.
- **Why it exists / user value:** Neighborhood-style discussion under each post — the primary
  engagement surface after likes.
- **Related features:** Posts (post row, `comment_count`, `comment_post_access_id`), Likes
  (post likes — sibling flow `AddLikeCall`/`post_like`), Post access control
  (`comment_post_access` / `see_post_access` lookups), Notifications (comment/reply/like push —
  not directly visible in this feature's widgets).

## 2. Screens & widgets
| Screen / widget (path under `lib/`) | Purpose | Key actions |
|---|---|---|
| `pages/comments_page/comments_page_widget.dart` | Full comment thread for one post (header post preview, like/comment/share bar, comment list, reply list, add-comment / add-reply input) | Load all comments (`get_post_comments_with_user`), add comment (direct `insert`), add reply (direct `insert` w/ `parent_comment_id`), like a comment (`add_comment_like`), recount (`count_comment`, `count_likes`), realtime refresh |
| `pages/comments_page/comments_page_model.dart` | State for the page: `AsComments`/`AsCommentReplies` app-state, text controllers, request completers, `postData` JSON | Holds `apiResultpio` (all comments), `apiResultmhc` (post user data), like/reply results |
| `pages/home/comp_comment/comp_comment_widget.dart` | Single-comment component (avatar, text, like toggle, replies count, "Add reply", nested replies list) — used where a comment is embedded by `commentId` | Load one comment (`get_post_comments`), like (`add_comment_like`), open reply input via app-state |
| `pages/home/comp_comment/comp_comment_model.dart` | State for the single-comment component | Holds `commentJson`, completers |
| `pages/post/comp_view_access/comp_view_access_widget.dart` | Sets who may comment / see a post (radio of `comment_post_access` names); writes `comment_post_access_id` onto the post | `PostTable().update({comment_post_access_id, see_post_access_id})` |
| `custom_code/actions/init_realtime_comment_updates.dart` | Realtime listener on `post_comment` that keeps `AsComments`/`AsCommentReplies` live | Postgres Changes subscription |

## 3. Data model (tables & columns)
Column types + nullability taken from the FlutterFlow Row classes.

### `post_comment`
- **Purpose:** One row per comment OR reply on a post. A reply is a `post_comment` row whose
  `parent_comment_id` points at another `post_comment.id` (single-level threading).
- **Columns:**
  | Column | Type | Null? | Notes (PK/FK/default/enum) |
  |---|---|---|---|
  | `id` | text/uuid (Dart `String`) | no | PK. Client queries `eq('id', ...)`; see §8 re: id type. |
  | `created_at` | timestamptz | no | default `now()`; used for newest-first sort |
  | `community_id` | int (`int`) | no | FK → community; set from `post.community_id` on insert |
  | `user_id` | text/uuid (`String`) | no | FK → user (author) |
  | `post_id` | text/uuid (`String`) | no | FK → `post.id` |
  | `comment` | text (`String`) | no | comment/reply body |
  | `likes_count` | int (`int?`) | yes | inserted as `0`; maintained by `count_likes` / `add_comment_like` |
  | `replies_count` | int (`int?`) | yes | inserted as `0`; maintained by `count_likes` (p_type='reply') |
  | `parent_comment_id` | text/uuid (`String?`) | yes | FK → `post_comment.id`; NULL = top-level comment, non-NULL = reply |
  | `tldr` | text (`String?`) | yes | optional summary shown in list (`$.tldr`) |
- **Foreign keys / relationships:** `post_id`→`post.id`, `user_id`→user profile,
  `community_id`→community, `parent_comment_id`→`post_comment.id` (self-ref, `on delete cascade`
  expected so replies drop with parent).
- **Indexes needed:** `post_id`, `user_id`, `community_id`, `parent_comment_id`, `created_at`
  (sort), and composite `(post_id, parent_comment_id)` for splitting comments vs replies.

### `post_comment_likes`
- **Purpose:** One row per (user, comment) like. Presence of a row = the current user liked
  that comment (drives the filled-heart icon). No unlike column — toggle is server-side.
- **Columns:**
  | Column | Type | Null? | Notes (PK/FK/default/enum) |
  |---|---|---|---|
  | `id` | text/uuid (`String`) | no | PK |
  | `created_at` | timestamptz | no | default `now()` |
  | `community_id` | int (`int`) | no | FK → community |
  | `user_id` | text/uuid (`String`) | no | FK → user (liker) |
  | `post_id` | text/uuid (`String`) | no | FK → `post.id` |
  | `comment_id` | text/uuid (`String`) | no | FK → `post_comment.id` |
- **Foreign keys / relationships:** `comment_id`→`post_comment.id` (`on delete cascade`),
  `post_id`→`post.id`, `user_id`→user, `community_id`→community.
- **Indexes needed:** `comment_id`, `user_id`, `post_id`, `community_id`, and a **unique**
  composite `(comment_id, user_id)` (one like per user per comment) — also the exact filter the
  client uses (`comment_id` + `user_id`, and `community_id`+`post_id`+`comment_id`+`user_id`).

### `comment_post_access`
- **Purpose:** Small lookup table of "who can comment on a post" options (radio choices). The
  chosen row's `id` is stored on the post as `post.comment_post_access_id`.
- **Columns:**
  | Column | Type | Null? | Notes (PK/FK/default/enum) |
  |---|---|---|---|
  | `id` | int (`int`) | no | PK (small int; referenced by `post.comment_post_access_id`) |
  | `created_at` | timestamptz | no | default `now()` |
  | `name` | text (`String`) | no | display label of the access option (e.g. everyone/followers) |
- **Foreign keys / relationships:** referenced by `post.comment_post_access_id` (int FK).
- **Indexes needed:** PK only (tiny lookup table). Seed rows required (see §8 for exact set).

### Related columns on `post` (not owned here, but this feature reads/writes them)
- `post.comment_count` — `int?` (`comment_count`), total comments on the post; maintained by
  `count_comment` RPC; shown next to the forum icon.
- `post.comment_post_access_id` — `int` (not null), FK → `comment_post_access.id`; who may comment.

## 4. Backend calls (API / RPC / Edge)
All RPCs are Supabase REST `POST /rest/v1/rpc/<fn>` with headers `apikey` (anon) + `Authorization: Bearer <jwt>`.

| Call / query | Type | Inputs | Returns | Called from |
|---|---|---|---|---|
| `GetPostAllCommentsCall` → `rpc/get_post_comments_with_user` | RPC | `p_post_id` (text) | JSON `{ "comments": [...], "replies": [...] }`; each item has `id, user_name, profile_picture, created_at, comment, tldr, likes_count, replies_count` (replies also carry `parent_comment_id`) | `comments_page` on load → `FFAppState().AsComments` / `AsCommentReplies` |
| `GetPostCommentsCall` → `rpc/get_post_comments` | RPC | `p_commentid` (**int**), `p_userid` (text) | JSON for one comment: `profile, name, comment, replied, replies[...]` (each reply `name, comment`) | `comp_comment` component (load + realtime refresh) |
| `AddCommentLikeCall` → `rpc/add_comment_like` | RPC | `p_userid` (text), `p_postid` (text), `p_communityid` (int), `p_commentid` (text) | toggles like: inserts/deletes `post_comment_likes` row + updates that comment's `likes_count` | Like tap in `comments_page` (list item) and `comp_comment` |
| `UpdateCommentCountCall` → `rpc/count_comment` | RPC | `p_postid` (text) | recomputes & writes `post.comment_count` | After every comment/reply insert in `comments_page` |
| `CountLikesCall` → `rpc/count_likes` | RPC | `p_type` (`'post'` \| `'reply'`), `p_post_id` (text), `p_commentid` (**unquoted** in body) | recomputes counts; `p_type='reply'` updates parent comment `replies_count`, `p_type='post'` used after top-level comment | After comment insert (`'post'`) and reply insert (`'reply'`) |
| `GetPostUserDataCall` → `rpc/...` (post header) | RPC | `p_postid`, `p_userid`, token | post author JSON (`name, profile_image, city, images, images_count, comment_post_access_id`) | `comments_page` header (context only) |
| `PostCommentTable().insert({...})` | direct DML | top-level: `user_id, post_id, community_id, comment, likes_count:0, replies_count:0`; reply: same **+ `parent_comment_id`** | inserted row | Add-comment / add-reply `TextFormField.onFieldSubmitted` in `comments_page` |
| `PostCommentTable().querySingleRow(eq id)` | direct SELECT | `id` = commentId | `PostCommentRow` | `comp_comment` and `comments_page` (per-comment) |
| `PostCommentLikesTable().querySingleRow(...)` | direct SELECT | `comment_id`+`user_id` (also `community_id`+`post_id` variant) | 0/1 `PostCommentLikesRow` → filled-heart state | Like icon in `comments_page` & `comp_comment` |
| `PostTable().update({comment_post_access_id, see_post_access_id})` | direct UPDATE | matches `post.id` | — | `comp_view_access` (edit) — sets who can comment |

## 5. Business rules & flows

**Add a top-level comment (`comments_page`):**
1. Trim input; if empty, clear and stop.
2. `PostCommentTable().insert` with `user_id=currentUser`, `post_id`, `community_id` (from the
   post row), `comment`, `likes_count:0`, `replies_count:0` (no `parent_comment_id`).
3. Call `count_comment(p_postid)` → updates `post.comment_count`.
4. Call `count_likes(p_type:'post', p_post_id, p_commentid=FFAppState().CommentId)`.
5. Clear inputs; reset request completer so the list refetches.

**Add a reply (`comments_page`, reply input visible only when `postCommentPostId == postId` &&
`showReply`):**
1. "Add reply" tap sets app-state: `showReply=true`, `postCommentPostId=postId`,
   `CommentId=<the comment's id>`, `postCommentUserName=<author>`.
2. On submit: `PostCommentTable().insert` same as above **plus `parent_comment_id =
   FFAppState().CommentId`**.
3. Call `count_comment(p_postid)` (reply also counts toward the post total).
4. Call `count_likes(p_type:'reply', p_post_id, p_commentid=FFAppState().CommentId)` → updates
   the **parent** comment's `replies_count`.
5. `showReply=false`; clear inputs.

**Like / unlike a comment:**
- Tap heart → `add_comment_like(p_userid, p_postid, p_communityid, p_commentid)`. This is a
  **server-side toggle**: if the user already has a `post_comment_likes` row for that comment it
  is removed, else inserted; the comment's `likes_count` is recomputed. UI never inserts the
  like row directly.
- Filled-heart state is derived by a direct `post_comment_likes` lookup on
  `(comment_id, user_id)` (empty result = not liked).

**Comments vs replies split:** `get_post_comments_with_user` returns two arrays. The UI shows
top-level `comments` in a list; for each comment it renders matching `replies` via client
helpers `functions.checkCommentReplyPresent(AsCommentReplies, commentId)` and
`functions.returnCommentReplies(AsCommentReplies, commentId)` (matched by `parent_comment_id`).
Only **one level** of threading exists (reply UI is not shown on replies themselves).

**Ordering:** newest-first (realtime handler sorts `created_at` descending).

**Access control:** the post carries `comment_post_access_id` (who may comment), set on create
(`create_post`) and edit (`comp_view_access`). The frontend only stores/reads the id + label; it
does not itself block commenting — enforcement is expected server-side (see §8).

## 6. Realtime / notifications
- **Mode: Postgres Changes** (not Broadcast). `init_realtime_comment_updates.dart` opens channel
  `public:post_comment` and subscribes to `event: all` on `public.post_comment`.
- On INSERT/UPDATE it enriches the row by fetching `public_user_profile` (`name`,
  `profile_picture`, `city`) via `eq(id=user_id).eq(community_id).single()`, then merges into the
  live list. `parent_comment_id != null` routes the row to `AsCommentReplies`, else `AsComments`.
  DELETE removes it. List is re-sorted newest-first.
- Generic `subscribe('post')` / `subscribe('post_comment')` / `unsubscribe(...)` helpers gate the
  page/component refresh completers (1s delay before subscribing).
- **Implication for rebuild:** `post_comment` must be added to the `supabase_realtime`
  publication, and `public_user_profile` must be selectable by `(id, community_id)` for the
  enrichment query. No push-notification code is present in these comment widgets.

## 7. Backend to build (Supabase rebuild checklist)
- [ ] **Tables:** `post_comment`, `post_comment_likes`, `comment_post_access` with columns/types
      per §3. Add FKs: `post_comment.post_id→post.id`, `user_id→user`, `community_id→community`,
      `parent_comment_id→post_comment.id (on delete cascade)`; `post_comment_likes.comment_id→
      post_comment.id (on delete cascade)`, `post_id`, `user_id`, `community_id`.
- [ ] **Indexes:** every FK above + `post_comment.created_at`, composite
      `post_comment(post_id, parent_comment_id)`, **unique** `post_comment_likes(comment_id, user_id)`.
- [ ] **Seed** `comment_post_access` rows (confirm exact set/labels — see §8).
- [ ] **RLS intent:**
  - `post_comment` SELECT: members of the community / per post `comment_post_access` rule.
    INSERT/UPDATE/DELETE: **via RPC only** (admin-only direct DML) — but note the frontend
    currently does **direct `insert`** (see §8 risk). At minimum INSERT must validate
    `auth.uid() = user_id`, post exists, and commenter passes the post's `comment_post_access`.
  - `post_comment_likes`: no direct client writes — mutated only inside `add_comment_like`.
    SELECT limited to community members (client reads own like state).
  - `comment_post_access`: SELECT to `authenticated` (lookup); no client writes.
- [ ] **RPC / PL-pgSQL functions:**
  - `get_post_comments_with_user(p_post_id)` → `{comments, replies}` enriched w/ user_name,
    profile_picture, created_at, likes_count, replies_count, tldr. SECURITY INVOKER preferred.
  - `get_post_comments(p_commentid, p_userid)` → single comment + its replies (fields: profile,
    name, comment, replied, replies[]). **Note `p_commentid` typed int** (see §8).
  - `add_comment_like(p_userid, p_postid, p_communityid, p_commentid)` → toggle like row +
    recompute `post_comment.likes_count`. Must validate `auth.uid()=p_userid`. Audit-worthy.
  - `count_comment(p_postid)` → recompute & set `post.comment_count`.
  - `count_likes(p_type, p_post_id, p_commentid)` → recompute counts; `'reply'` updates parent
    `replies_count`. (Confirm whether it also/instead touches likes — name vs usage ambiguous, §8.)
- [ ] **Triggers / cron:** consider triggers on `post_comment` insert/delete to maintain
      `post.comment_count`, parent `replies_count`, and on `post_comment_likes` to maintain
      `likes_count` — the app currently does this via explicit RPC calls, so triggers are
      optional but would make counts self-healing.
- [ ] **Realtime:** add `post_comment` to the realtime publication; keep `public_user_profile`
      selectable by `(id, community_id)` for enrichment.
- [ ] **Storage / Edge:** none for this feature.

## 8. Open questions & risks
- **`post_comment.id` type mismatch.** Row class exposes `id` as `String` (uuid-like), but
  `comp_comment_widget` declares `commentId` as **`int?`** and `GetPostCommentsCall.p_commentid`
  is **int**, while `add_comment_like`/list queries pass `id` as a string. Confirm the real PK
  type — likely `uuid`/text; the int typing in `comp_comment`/`get_post_comments` needs
  reconciling (may be legacy or a numeric id path). Build to match whichever the majority of
  calls (`get_post_comments_with_user`, direct `eq('id', ...)`, `add_comment_like`) use = **text/uuid**.
- **Direct client `insert` into `post_comment`** violates the CLAUDE.md §6 rule ("user-facing
  writes go through RPC, no raw client DML on non-trivial tables"). The frontend inserts comments
  and replies directly. Decision needed: either (a) wrap in an `add_comment` RPC and rewire the
  data layer, or (b) allow a tightly-scoped INSERT policy validating `auth.uid()=user_id` +
  access rule. Flag for security review.
- **`count_likes` semantics.** Name says "likes" but it's called after comment/reply inserts
  with `p_type` `'post'`/`'reply'`, apparently to recompute `replies_count`. Confirm exactly
  which counter(s) it writes and for which target row (parent comment vs post).
- **`add_comment_like` toggle direction.** UI assumes tapping toggles (like/unlike) and re-derives
  state from a `post_comment_likes` lookup. Confirm the RPC both inserts and deletes and keeps
  `likes_count` in sync. No dedicated "remove comment like" call exists.
- **`comment_post_access` seed set unknown.** The exact rows/labels (e.g. "Everyone",
  "Followers", "Only me") and how they map to the enforcement predicate are not visible in these
  widgets — confirm the option set and the server-side rule that uses `post.comment_post_access_id`
  when returning/allowing comments. Parallel `see_post_access` table governs visibility.
- **Reply depth.** Only one level of replies is rendered (no reply-to-reply UI). Backend should
  either forbid `parent_comment_id` pointing at a row that itself has a parent, or the UI simply
  won't surface deeper threads — confirm intended constraint.
- **`community_id` on comment** is taken from the post row client-side; server should derive it
  from the post to avoid spoofing.
- **`tldr` on comments** is read (`$.tldr`) but no write path for it appears in the comment insert
  — confirm whether comment `tldr` is generated server-side (like post tldr) or unused.

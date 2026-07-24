# Feature: Search & Tags

> Source of truth = the Flutter frontend. This doc records what the backend MUST provide
> for this feature to work. Derived from `lib/` — do not invent behavior the code doesn't show.

## 1. Overview
- **What it is:** A global search screen that queries every major Viora entity — posts,
  sales listings, events, groups, nearby users (neighbourhood), and business pages — from a
  single text box, with per-type tab filtering and sale-specific filters (category, sale type,
  distance, sort). It records per-user search history (recall + clear) and powers `@mention`
  tag autocomplete (searching users to tag) plus persistence of the tags chosen on a post.
- **Why it exists / user value:** One entry point to find anything in the neighbourhood;
  quick recall of past searches; and the ability to tag other users when composing content.
- **Related features:** Posts/Home feed, Sales marketplace (category/km/sort filters reused
  here), Groups, Events, Business pages, Nearby users/Neighbourhood. Search results deep-link
  into those features. Tag creation is consumed by the post-composer flow.

## 2. Screens & widgets
| Screen / widget (path under `lib/`) | Purpose | Key actions |
|---|---|---|
| `pages/search/search_widget.dart` | Main search screen (single 831KB widget: search bar, type tabs, per-type result lists, filter chips, history list) | Type in search box → `GetAllSearch`; submit → `UpdateSearchHistory`; pick a type tab → re-run `GetAllSearch` with `pType`; open sale filters; tap history row → re-run search; Clear → delete history |
| `pages/search/search_model.dart` | Page state/model | Holds `optionChoosed` (active type), `searchEmpty`, `showData`, `isSearchHistory`, `isSearchHistoryPresent` (history query result), the many `ApiCallResponse` holders, realtime completers |
| `custom_code/widgets/tag_text_field.dart` | `@mention` tag input with inline autocomplete | On `@` + typed term → POST `tag_search`; renders suggestion list; `selectSuggestion` inserts `@name`, stores `{id,name}` in `FFAppState().tagList`; backspace removes a tag |
| `custom_code/widgets/mention_text_field_widget.dart` | Alternate mention field (collects `taggedUserId` list) | Same `@mention` pattern, feeds tagged user ids for `insert_tags` |
| `pages/sale/comp_category_filter/…`, `comp_kms_filter/…`, `comp_sales_sort/…` | Sale filter/sort chips reused inside search | Set `FFAppState().SalesFilter` / `SalesKmFilter` / `SalesSort` / `SalesTypeFilter`, then re-run `GetAllSearch` |

## 3. Data model (tables & columns)

### `search_history`
- **Purpose:** One row per stored search term, per user, per community. Read on page load to
  show recent searches; written on submit; bulk-deleted on "Clear".
- **Columns:** (types from `lib/backend/supabase/database/tables/search_history.dart`)
  | Column | Type | Null? | Notes (PK/FK/default/enum) |
  |---|---|---|---|
  | `id` | `uuid` (Dart `String`) | NOT NULL | PK, default `gen_random_uuid()` |
  | `created_at` | `timestamptz` (Dart `DateTime`) | NOT NULL | default `now()`; used for `.order('created_at')` |
  | `community_id` | `int8`/`int4` (Dart `int`) | NOT NULL | FK → `community.id`; filter key |
  | `search` | `text` (Dart `String`) | NOT NULL | the stored search term |
  | `searched_by` | `uuid` (Dart `String`) | NOT NULL | FK → user (`auth.users`/profile) that ran the search; filter key |
  | `last_updated_date` | `timestamptz` (Dart `DateTime?`) | NULL | updated when an existing term is re-searched (implied by RPC name `update_search_data`) |
- **Foreign keys / relationships:** `community_id` → community; `searched_by` → app user.
  A user's history is scoped by `(community_id, searched_by)`.
- **Indexes needed:** `searched_by`, `community_id`, composite `(community_id, searched_by)`
  (exact filter used on load + delete), and `(community_id, searched_by, created_at DESC)` to
  serve the ordered history list. Consider a UNIQUE `(community_id, searched_by, lower(search))`
  if the RPC is meant to upsert/dedupe terms (see §8).

### `tag`
- **Purpose:** Records that a user was tagged (`@mention`) in a post. Written via the
  `insert_tags` RPC when a post with mentions is created.
- **Columns:** (types from `lib/backend/supabase/database/tables/tag.dart`)
  | Column | Type | Null? | Notes (PK/FK/default/enum) |
  |---|---|---|---|
  | `id` | `uuid` (Dart `String`) | NOT NULL | PK, default `gen_random_uuid()` |
  | `created_at` | `timestamptz` (Dart `DateTime`) | NOT NULL | default `now()` |
  | `post_id` | `uuid` (Dart `String?`) | NULL | FK → `post.id` (nullable in the Row class) |
  | `user_id` | `uuid` (Dart `String`) | NOT NULL | FK → the tagged user |
- **Foreign keys / relationships:** `post_id` → `post` (one post has many tag rows);
  `user_id` → app user (the person tagged). NOTE: this is **user @mention tagging**, not
  hashtag/topic tagging.
- **Indexes needed:** `post_id`, `user_id`, and composite `(post_id, user_id)`; add a UNIQUE
  `(post_id, user_id)` to prevent duplicate tags of the same user on the same post.

> The `tag_search` autocomplete searches **users** (returns `{id, name}`), i.e. it queries a
> users/profile table, not the `tag` table. The `tag` table only stores the resulting
> post↔user tag links.

## 4. Backend calls (API / RPC / Edge)
All RPCs are PostgREST `POST /rest/v1/rpc/<fn>` against project ref `wgcqstmmkcdjnnpuvspr`
(the OLD project — Viora's rebuild targets its own ref). Definitions in
`lib/backend/api_requests/api_calls.dart`.

| Call / query | Type | Inputs | Returns | Called from |
|---|---|---|---|---|
| `GetAllSearchCall` → `rpc/get_search_all_data` | RPC | `p_search_text`, `p_userid`, `p_communityid` (int), `p_type`, `p_category`, `p_sale_type`, `p_sort`, `p_distance` (int) | JSON object with arrays: `posts`, `sales`, `events`, `groups`, `nearby_users`, `business_pages` | `search_widget.dart` TextField `onChanged` (debounced 2s, min 3 chars); type-tab taps; history-row tap |
| `GetSpecifFilterSearchCall` → `rpc/get_search_data` | RPC | `p_userid`, `p_community` (int), `p_type`, `p_ids` (JSON array of ids) | Same shaped object (`posts`/`sales`/`events`/`groups`/`nearby_users`/`business_pages`) plus top-level `eventData` list | Filtered/refined result fetch by explicit id set (e.g. after applying filters) |
| `TagSearchCall` → `rpc/tag_search` | RPC | `search_name` (string) | JSON **array** of users `[{ id, name, … }]` | `tag_text_field.dart` `_searchUsers` (raw `http.post`, 300ms debounce after `@`) and `TagSearchCall.call` |
| `UpdateSearchHistoryCall` → `rpc/update_search_data` | RPC | `p_community_id` (int), `p_search_text`, `p_userid` | (not consumed by UI) | TextField `onFieldSubmitted` — persists/updates the searched term |
| `InsertTagsCall` → `rpc/insert_tags` | RPC | `p_post_id`, `p_user_ids` (serialized list of user ids) | (not consumed by UI) | Post-composer flow — bulk-inserts `tag` rows for a post's mentions |

**Direct table operations (client `.from(...)` via generated table classes) in `search_widget.dart`:**
| Op | Table | Filter / order | Line |
|---|---|---|---|
| `queryRows` | `search_history` | `eq community_id`, `eq searched_by` (load), also `.order('created_at')` in the history `FutureBuilder` | ~62, ~9670 |
| `delete` | `search_history` | `eq community_id`, `eq searched_by` (Clear = wipe this user's history in this community) | ~9612 |

## 5. Business rules & flows
1. **Type filter (`optionChoosed` → `p_type`).** Tabs: `all`, `post`, `neighbourhood`,
   `business`, `group`, `event`, `sale`. Selecting a tab sets `optionChoosed` and immediately
   re-runs `GetAllSearch` with the current search text and the same sale filter params.
2. **Live typing search.** `onChanged` is debounced **2000ms**. It only fires `GetAllSearch`
   when `textController.text.length >= 3`. If length `== 0` → `searchEmpty = true` (show empty
   state); `1–2` chars → no call. On success the whole JSON body is stored in
   `FFAppState().SearchData` and the six result sections render from it.
3. **Sale filters** (passed on every `GetAllSearch`): `p_category` = `FFAppState().SalesFilter`
   (default `'All categories'`), `p_sale_type` = `SalesTypeFilter` (default `'Fixed'`),
   `p_sort` = `SalesSort` (default `'Newest'`), `p_distance` = `SalesKmFilter` (int, default
   `10`). These are set/reset on page load and adjusted via the reused sale filter components.
4. **Search history — read.** On page load, `search_history` is queried by
   `(community_id, searched_by)`; if any rows exist `isSearchHistory = true` and the history
   list renders (ordered by `created_at`). Tapping a history row copies its `search` into the
   box, forces `optionChoosed = 'all'`, and runs `GetAllSearch`.
5. **Search history — write.** Only on **submit** (`onFieldSubmitted`) does
   `UpdateSearchHistory` (`rpc/update_search_data`) run with the term. The RPC name + the
   nullable `last_updated_date` column imply an **upsert/bump-existing** semantics rather than
   always-insert (must confirm — see §8).
6. **Search history — clear.** "Clear" deletes ALL `search_history` rows for
   `(community_id, searched_by)` and sets `isSearchHistory = false`.
7. **Tag autocomplete flow.** Typing `@` (or `@term`) triggers `tag_search` with `search_name`
   (300ms debounce); results populate `FFAppState().tagSuggestions`. Selecting a suggestion
   inserts `@name` in the display text but stores the raw `user_id` in the internal text and
   appends `{id,name}` to `FFAppState().tagList`. Empty `search_name` returns all/initial users.
8. **Tag persistence.** When the composed post is saved, `insert_tags` is called with the
   post id + the collected user ids, creating one `tag` row per `(post_id, user_id)`.
9. **Scoping.** All search/history operations are scoped to the current `communityId` and the
   current user (`currentUserUid`) + JWT (`currentJwtToken`).

## 6. Realtime / notifications
- The search page subscribes (custom `actions.subscribe`) to `post`, `event_page`, and
  `event_attending` channels to invalidate/refresh in-flight result completers when those
  entities change while results are shown. Mode is the app's existing custom realtime action
  layer — treat as **Broadcast** (private/authorized) per CLAUDE.md §6; confirm against the
  Realtime feature doc. No push notifications originate from search/tags themselves.
- Tagging a user in a post is a plausible notification trigger, but the search/tag frontend
  does not itself send a notification — any "you were tagged" push would live in the post/
  notification feature (confirm — §8).

## 7. Backend to build (Supabase rebuild checklist)
- [ ] **Tables:** `search_history` (cols per §3, FKs `community_id`→community,
      `searched_by`→user, `on delete cascade`), `tag` (cols per §3, FKs `post_id`→post
      `on delete cascade`, `user_id`→user `on delete cascade`).
- [ ] **Indexes:** `search_history(community_id, searched_by, created_at DESC)`;
      `tag(post_id)`, `tag(user_id)`, UNIQUE `tag(post_id, user_id)`; optional UNIQUE
      `search_history(community_id, searched_by, lower(search))` if terms dedupe.
- [ ] **Search query mechanism (decide + document):** `get_search_all_data`, `get_search_data`,
      and `tag_search` do the actual matching server-side. For neighbourhood-scale substring
      search, recommend **`pg_trgm` GIN indexes** (`gin_trgm_ops`) on the searchable text
      columns (post body, sale title/desc, event title, group name, user display name,
      business name) so `ILIKE '%term%'` stays fast; OR a Postgres **full-text** (`tsvector` +
      GIN) approach with a generated column if ranked/prefix matching is wanted. `tag_search`
      on user names is a strong fit for a **trigram index on `lower(name)`** to support the
      short, prefix-style `@` autocomplete. Choose one and match the RPC bodies to it.
- [ ] **RLS intent:**
      - `search_history`: `SELECT`/`DELETE` only where `searched_by = auth.uid()`; no direct
        client `INSERT` (writes go through `update_search_data`). Client currently does direct
        `queryRows`/`delete` filtered by `searched_by` — RLS must enforce that server-side, not
        trust the filter.
      - `tag`: `SELECT` for members who can see the post; no direct client writes — inserts via
        `insert_tags` only.
- [ ] **RPC / PL-pgSQL functions:**
      - `get_search_all_data(p_search_text, p_userid, p_communityid, p_type, p_category,
        p_sale_type, p_sort, p_distance)` → returns json object with the six arrays; filters by
        community + type; applies sale filters when type = `sale`/`all`. `SECURITY INVOKER`
        preferred (respects RLS); validate `auth.uid()`.
      - `get_search_data(p_userid, p_community, p_type, p_ids)` → same shape, restricted to a
        set of ids.
      - `tag_search(search_name)` → returns users `[{id, name}]` matching name; validate auth.
      - `update_search_data(p_community_id, p_search_text, p_userid)` → upsert history row for
        the caller (bump `last_updated_date` if term exists). Must set `searched_by`/community
        from validated auth, not blindly from `p_userid`.
      - `insert_tags(p_post_id, p_user_ids)` → bulk-insert `tag` rows; validate the caller owns
        the post; dedupe on `(post_id, user_id)`.
      - All `SECURITY DEFINER` variants must `SET search_path = public, pg_temp`, validate
        `auth.uid()`, `REVOKE ALL FROM PUBLIC`, `GRANT EXECUTE TO authenticated`.
- [ ] **Storage buckets:** none for this feature.
- [ ] **Edge functions:** none for this feature.
- [ ] **Triggers / cron:** optional — cap/trim `search_history` per user (e.g. keep last N)
      via trigger or cron if unbounded growth is a concern (not implemented in frontend).

## 8. Open questions & risks
1. **ilike vs full-text — unknown.** The frontend cannot show what `get_search_all_data` /
   `tag_search` do internally (substring `ILIKE`, `to_tsvector`, or trigram). Must be decided
   during rebuild; §7 recommends trigram/FTS. Confirm desired matching (substring vs prefix vs
   ranked) with product owner.
2. **`update_search_data` semantics.** Insert-always vs upsert/bump? The `last_updated_date`
   column and the "update" name imply dedupe-and-bump, but the exact behavior (and whether it
   caps history length) is not visible in the frontend. Confirm before writing the RPC.
3. **Return schemas of the search RPCs.** Only top-level keys (`posts`, `sales`, `events`,
   `groups`, `nearby_users`, `business_pages`) are known from `getJsonField` paths; the exact
   columns inside each array are defined by other feature Row classes, not here — cross-check
   against Posts/Sales/Events/Groups/Business/Users docs so the RPC output matches each list
   widget's expected fields.
4. **`get_search_data` `p_ids` origin.** Where the id list comes from (which filter action
   builds it) is not evident in the read portions of the huge widget; confirm the caller.
5. **Direct client access to `search_history`.** The client both `queryRows` and `delete`s
   directly (not via RPC). RLS MUST restrict rows to `auth.uid()`; do not rely on the client's
   `searched_by` filter. Per CLAUDE.md §6, consider moving these to RPCs, or at minimum lock
   down with strict owner-only RLS.
6. **`tag_search` privacy.** Should autocomplete return all users, only same-community users,
   or only followers/connections? Frontend sends just `search_name`; scope must be enforced
   server-side.
7. **Tag notification.** Whether tagging a user emits a push/notification is not handled in the
   search/tag frontend — confirm with the Notifications feature.
8. **`tag.post_id` nullable.** The Row class allows null `post_id`; clarify whether tags can
   exist detached from a post (e.g. draft) or if this should be NOT NULL in the rebuild.
9. **Old project ref.** All URLs point to `wgcqstmmkcdjnnpuvspr` (the legacy project). The
   rebuild must target Viora's own Supabase ref; the anon key/URL are config, never hardcoded.

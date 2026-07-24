# Viora / Flock — `if (false)` dead-branch inventory (65 branches)

Date: 2026-07-21
Status: **inventory only — nothing enabled or deleted.** Owner decides per area.
Method: read-only sweep of all 65 branches across `lib/`, classified `pure-UI` vs `needs-data`
with the specific backing field named for each. Two claims independently re-verified by the lead
(see §5).

Context: Viora's Supabase backend is being rebuilt from scratch, so a branch that renders fine
today may read a column that no longer exists. That is why every `needs-data` row names its
dependency rather than just saying "needs backend."

---

## 1. The two structural findings (these collapse most of the decisions)

**A. 8 of 65 are the same superseded widget.** A legacy plain-text post-body renderer with a
"Read More / Read Less" toggle. In *every* case it is immediately followed by
`custom_widgets.ShowContent(...)`, which renders the same `$.content` as rich text plus `$.tldr`.
These are not unfinished work — they are the old implementation left switched off next to the new
one. **Recommend: delete.**

| Location | Superseded by |
|---|---|
| `home_page_widget.dart:896` (896–1046) | `ShowContent` at :1055 |
| `group_details_widget.dart:2363` (2363–2509) | `ShowContent` at :2515 |
| `search_widget.dart:4730` (4730–4870) | `ShowContent` at :4913 |
| `search_widget.dart:6682` (6682–6828) | `ShowContent` at :6837 |
| `comments_page_widget.dart:791` (791–983) | `ShowContent` at :989 |
| `user_all_post_widget.dart:1972` (1972–2194) | `ShowContent` at :2200 |
| `user_profile_widget.dart:4621` (4621–4747) | `ShowContent` at :4757 |
| `other_profile_widget.dart:3157` (3157–3283) | `ShowContent` at :3293 |

**B. 18 of 65 live in two orphan mock pages.** `lib/pages/groups/groups_widget.dart` (9) and
`lib/pages/home/specific_user_groups/specific_user_groups_widget.dart` (9). Both are 100%
hardcoded — `'Michelle Dam Groups'`, `https://picsum.photos/seed/437/600`, `'23 members'` — with
zero Supabase queries. Each contains 3 identical group cards whose join pill has 4 states
(Join / Request / Requested / Joined); one state is `if (true)`, the other three are `if (false)`.
Someone was flipping booleans by hand to preview each state.

**Reachability (verified):** neither page is pushed from any widget. Both appear *only* in
`nav.dart` route registrations (`GroupsWidget` at :189–191, `SpecificUserGroupsWidget` at
:318–320). **Caveat the sub-agent missed:** because they are registered with a `routePath` and
Viora also ships on Web, they are reachable by direct URL even though no in-app control links to
them. Deleting the pages therefore requires removing the `nav.dart` entries too — otherwise the
router references a deleted class and the build breaks.

**Recommend: delete both pages + their `nav.dart` route entries.** Enabling any of their 18
branches only stacks overlapping pills on fake data.

---

## 2. Genuine quick wins (pure-UI, wired, no backend dependency)

| # | Location | What it gives back |
|---|---|---|
| 1 | `create_post_widget.dart:676` | **"✕" to remove an attached image.** Real functional gap — a user who picks the wrong photo currently has no way to drop it. `onTap` is fully implemented (clears `isDataUploading_uploadDataValue` + `uploadedLocalFiles_uploadDataValue`, recomputes `datapresent`). **Verified by lead.** Highest-value flip in the list. |
| 2 | `editpost_widget.dart:543` | Same "✕" over the already-saved image gallery. Complete handler, local model state only. |
| 3 | `editpost_widget.dart:815` | Same "✕" over newly-uploaded images. Flip 1–3 together for consistency. |
| 4 | `profile_widget.dart:657` (657–842) | "Post about safety" + "Create a group" quick-action cards. Assets exist, nav wired. **Repoint the first card away from `PostAboutSafetyDeletedWidget` before shipping.** |
| 5 | `comp_report_block_widget.dart:352` | "Reason is required" inline validation. Two-line fix: correct the typo (**"Reasone"**) and gate on empty-field instead of `false`. Turns a silently-failing form into a correct one. |
| — | `archived_chats_page_widget.dart:178` | Per-row selection checkbox. Only worth it if a bulk unarchive/delete action bar is also built; otherwise skip. |

---

## 3. Traps — look like quick wins, are not

**No `onTap` at all (enabling adds tappable-looking controls that do nothing):**
`search_widget.dart:3980`, `search_widget.dart:6034`, `sale_widget.dart:1469`,
`sale_details_widget.dart:2225` (the four bookmark/"save listing" icons — one feature, four
switches, needs a `saved_listings` table); `sale_details_widget.dart:1967` (⋮ overflow menu);
`comments_page_widget.dart:3042` (add-photo on comments, no upload wiring);
`neighbourhood_explore_widget.dart:202` (share button, empty `onPressed: () {}`);
`create_post_widget.dart:1064` and `editpost_widget.dart:1164` (second "＋" toolbar icons).

**Unconditional — would apply to every row (the chat indicators):**
`chat_widget.dart:871` marks **every** contact online; `chat_widget.dart:954` shows **every**
conversation as "Typing…" forever; `chat_widget.dart:1098` flags **every** row unread. These need
real presence / typing broadcast / unread-count data before they mean anything.

**Would duplicate content already on screen:**
`comments_page_widget.dart:1987` (raw `$.comment` under a comment `ShowContent` already renders);
`notification_widget.dart:1356` (raw `$.message` under a `RichText` that already composes the
sentence).

---

## 4. Highest-risk branches — do not enable

| Location | Size | Why |
|---|---|---|
| `user_all_post_widget.dart:146` | **1,283 lines** (146–1428) | An entire *second* implementation of the All Posts screen — its own `FutureBuilder<List<PostRow>>` doing `PostTable().queryRows(user_id, is_deleted, order created_at)`, avatar/name/city/badge rendering, a Follow button writing `follower_id`/`following_id`, and three-dot sheets. Superseded by the live list at :1430 which reads `FFAppState().AsPost`. **Delete.** |
| `comments_page_widget.dart:2663` | 183 lines (2663–2846) | Legacy comment composer that directly `insert`s into `post_comment` (`user_id, post_id, community_id, comment, likes_count, replies_count`) and calls `UpdateCommentCountCall` + `CountLikesCall`. Depends on 6 columns, `columnPostRow.communityId`, `FFAppState().CommentId`, and 2 API endpoints. Superseded by `CommentMentionTextFieldWidget` at :3030. **Delete.** |
| `account_settings_widget.dart:109` | 160 lines (109–269) | A multi-profile / household-accounts switcher, fully hardcoded (2 `picsum.photos` URLs, literal names, literal count "5"). Needs a profiles/household table that does not exist. Also the **only** navigation path to `SwitchProfileDeleted`. |
| `comp_comment_widget.dart:692` | 124 lines (692–816) | The entire like/reply engagement bar under a comment. Reads `post_comment.likes_count` / `replies_count`. Values fall back to `'0'` via `valueOrDefault`, so a missing *value* is safe — a missing **column** is not. Contains a nested branch at :709 (the un-liked heart state) that is unreachable unless :692 is on. |

---

## 5. Navigation (10) — decided: keep disabled

All 10 in `comp_navbar_widget.dart` (:154, :220, :344, :410, :535, :599, :722, :788, :917, :984)
are the 5 tab text labels, each appearing twice for active and inactive state. Tab names:
Home, Community, Post, Notifications, **For Sale & Free**.

**Owner decision 2026-07-21: keep disabled.** The nav stays icon-only at 54dp; screen-reader
support is being delivered via `Semantics` labels instead (see `ui-review-2026-07-21.md` §2.3).
Revisit only if user testing shows new-user confusion over the 5 glyphs.

---

## 6. Recommended disposition summary

| Action | Count | Branches |
|---|---|---|
| **Delete — superseded** | 8 | §1.A "Read More" renderers |
| **Delete — orphan pages** (+ `nav.dart` entries) | 18 | §1.B |
| **Delete — superseded, large** | 3 | `user_all_post:146`, `comments_page:2663`, `comments_page:1987` |
| **Delete — duplicate content** | 1 | `notification_widget:1356` |
| **Enable — quick wins** | 5 | §2 items 1–5 |
| **Keep disabled — decided** | 10 | §5 nav labels |
| **Leave — needs backend/feature work first** | 20 | §3 traps + §4 risk rows |

Deleting the recommended 30 branches removes roughly **2,000 lines** of dead code, which also
reduces several of the over-400-line files flagged in `ui-review-2026-07-21.md` §2.9 as a free
side effect — without any refactor.

---

## 7. Notes for other agents

- **frontend-dev:** the 5 quick wins in §2 are independent of each other and of Wave 2 component
  adoption. Item 1 is a real user-facing bug fix, not a polish item.
- **backend-dev:** §4 names the exact columns each risky branch depends on
  (`post_comment.likes_count`, `replies_count`, `post.is_deleted`, follow-table
  `follower_id`/`following_id`). Useful as a cross-check that the rebuild covers what the
  frontend still references.
- **doc-keeper:** the §5 nav decision belongs in `docs/decisions.md`.

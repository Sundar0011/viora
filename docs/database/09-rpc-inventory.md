# Database Design — RPC / Edge Function Inventory

> Part of `docs/database-design.md`. DESIGN ONLY — not applied. Pulled from each feature doc's §4
> (Backend calls) and §7 (Backend to build). All `SECURITY DEFINER` functions: validate
> `auth.uid()` inside, `SET search_path = public, pg_temp`, `REVOKE ALL FROM PUBLIC`, `GRANT
> EXECUTE TO authenticated` (narrower `anon` grant only where explicitly noted). Prefer `SECURITY
> INVOKER` unless RLS must be bypassed for a legitimate cross-user read/write (noted per row).
>
> **Decision: Remove Community Concept (RESOLVED, `10-open-decisions.md`).** Every RPC below that
> the locked frontend calls with a `p_communityid`/`community_id` argument **keeps that argument
> in its call signature** (so the app's existing call sites keep working unmodified), but the
> argument is **no longer used for any WHERE-clause scoping, filtering, or derivation** inside the
> function body. Rows marked "community scope"/"community membership" in earlier drafts have been
> corrected below to reflect app-wide (no community boundary) behavior. Where a function accepts
> the arg only for compat, it is noted inline as *(community_id: compat arg only, unused)*.

## 1. Auth & Registration
| RPC | Args | Returns | Mode | Validations |
|---|---|---|---|---|
| `update_user_location` | `lat text, lon text, place_name text, p_type text` | location row | DEFINER | `auth.uid()`; parse lat/lon → geography; upsert caller's row only |
| `upsert_user_device_fcm` | `p_device_id text, p_fcm_token text` | void/row | DEFINER | `auth.uid()`; upsert on `(user_id, device_id)` |
| `upsert_user_device` | `p_device_id text, p_player_id text` | void/row | DEFINER | `auth.uid()`; same upsert target, OneSignal `player_id` |
| `signup_finalize` (NEW, replaces client direct-insert of `user`/`user_roles`/`public_user_profile`) | profile fields + first location | new user id | DEFINER | `auth.uid()` = the just-created auth user; forces `user_roles.role='user'` regardless of client input; single transaction |
| **Edge:** `send-otp` | `{mobile_no_cc, email}` | `{error?}` | service-role | rate-limit via `user_login.no_of_times`/`last_requested_date` |
| **Edge:** `verify_otp` | `{otp, email, mobile_no_cc}` | success/`{error?}` | service-role | expiry check against `user_login.expiry_date` |
| **Edge:** `authenticate-user` | `{identifier, password}` | `{error?}` | service-role | pre-flight credential check |
| **Edge:** `check-user-exist` | `{email, mobile_number}` | `{email_exists, mobile_number_exists}` | service-role | — |
| **Edge:** `check-user` | `{email, mobile_number}` | `{exists}` | service-role | — |
| **Edge:** `reset-password` | `{phone, email, otp, new_password}` | success/error | service-role | OTP re-verify |
| **Edge:** `change-password` | Bearer JWT + `{old_password, new_password}` | success/error | service-role | verify old password first |
| **Edge:** `phone-signup` | Bearer anon + server secret (never client `x-secret-key`, see Open Decisions) + `{phone, password, confirmPassword}` | success/error | service-role | creates phone auth user |
| `custom_access_token_hook` | Auth Hook `event jsonb` | `jsonb` (claims) | DEFINER, Auth Hook | reads `user_roles.role`, injects `app_metadata.role` |

## 2. Home Feed & Posts
| RPC | Args | Returns | Mode | Validations |
|---|---|---|---|---|
| `get_visible_posts` | (none, JWT-scoped) | feed JSON | INVOKER | RLS does the filtering |
| `get_neighbourhood_post_data` | `p_userid, p_communityid` | posts + counts JSON | INVOKER | *(community_id: compat arg only, unused)* — app-wide feed, gated by `get_visible_posts` visibility rules, not community |
| `get_post_user_data` | `p_postid, p_userid` | post detail JSON | INVOKER | post visibility |
| `insert_post_image_rows` | `p_userid, p_communityid, p_postid, image_urls[], media_type` | void | DEFINER | `auth.uid()=p_userid`, caller owns `p_postid`; *(community_id: compat arg only, unused)* |
| `insert_tags` | `p_post_id, p_user_ids` | void | DEFINER | caller owns the post; dedupe `(post_id,user_id)` |
| `add_like` | `p_userid, p_postid, p_communityid` | toggled state | DEFINER | `auth.uid()=p_userid`; updates `likes_count`; *(community_id: compat arg only, unused)* |
| `count_likes` | `p_type, p_post_id, p_commentid` | count | DEFINER | recompute only |
| `get_post_likes` | `p_postid` | users[] | INVOKER | post visibility |
| `get_limited_post_likes` | `p_postid, p_screenwidth` | users[] (limited) | INVOKER | post visibility |
| `get_internal_share` | `p_userid` | shareable users[] | INVOKER | `auth.uid()=p_userid` |
| `update_post_share_count` | `p_postid, p_userid, p_communityid` | void | DEFINER | inserts `post_share`, bumps `share_count`; *(community_id: compat arg only, unused)* |
| `add_post_count` | `p_userid` | void | DEFINER | `auth.uid()=p_userid` |
| `update_user_profile_counts` | `p_option` | void | DEFINER | `auth.uid()`-scoped recompute |
| **Edge:** `update-user-post` | `user_id, post_id, see_post_access_id, comment_post_access_id, content, image_urls[]` | success | service-role/JWT | ownership check; sets `is_edited`, `last_modified_date` |
| **Edge:** `generate-tldr` | `comment_id, post_id, text` | writes `tldr` | JWT | AI provider key server-side only |

## 3. Comments
| RPC | Args | Returns | Mode | Validations |
|---|---|---|---|---|
| `get_post_comments_with_user` | `p_post_id` | `{comments[], replies[]}` | INVOKER | post visibility |
| `get_post_comments` | `p_commentid, p_userid` | single comment + replies | INVOKER | post visibility |
| `add_comment` (NEW, replaces client direct insert) | `p_post_id, p_comment, p_parent_comment_id?` | new row | DEFINER | `auth.uid()`; post exists; passes `comment_post_access` rule |
| `add_comment_like` | `p_userid, p_postid, p_communityid, p_commentid` | toggled state | DEFINER | `auth.uid()=p_userid`; *(p_communityid: compat arg only, unused)* |
| `count_comment` | `p_postid` | void | DEFINER | recompute `post.comment_count` |
| `count_likes` | `p_type, p_post_id, p_commentid` | void | DEFINER | shared with Posts |

## 4. Neighbors / Follows (formerly "Community & Neighborhoods" — no community concept)
| RPC | Args | Returns | Mode | Validations |
|---|---|---|---|---|
| `get_followers_nearby` | `p_userid, p_communityid` | `{following_users[], others[], counts}` | DEFINER | geo distance vs caller's own location only; never expose raw coords; *(community_id: compat arg only, unused)* |
| `get_neighbourhood_post_data` | shared with Posts | — | — | — |
| `user_follow` | `p_communityid, p_followerid, p_followingid` | toggle result | DEFINER | `p_followerid=auth.uid()`; block self-follow; respect `blocks`; maintain counters; *(community_id: compat arg only, unused)* |
| `update_user_location` | shared with Auth | — | — | — |
| `get_following_users_not_attending_event` | `p_event_id` | users[] | INVOKER | follow graph, event scope (no community scope) |

## 5. Groups
| RPC | Args | Returns | Mode | Validations |
|---|---|---|---|---|
| `get_groups_with_user_status` | (none, JWT) | groups + derived status | INVOKER | app-wide discovery (no community scope) |
| `get_specific_group_with_user_status` | `p_group_id` | group + status | INVOKER | — |
| `get_group_members_with_admin_status` | `p_group_id, p_search_text` | members[] | INVOKER | member/admin visibility |
| `get_available_users_to_invite` | `p_search_text, p_group_id, p_community_id` | invitable users[] | INVOKER | caller is group member; *(p_community_id: compat arg only, unused)* |
| `get_invited_users_for_group` | `p_community_id, p_group_id, p_search_text` | invited users[] | INVOKER | admin/inviter; *(p_community_id: compat arg only, unused)* |
| `get_user_following_groups_with_status` | `target_user_id` | groups[] | INVOKER | — |
| `create_group` / `update_group` / `delete_group` (NEW) | group fields / `p_group_id` | row / void | DEFINER | owner/admin only |
| `join_open_group` (NEW) | `p_group_id` | void | DEFINER | group is `open`, not already member |
| `request_join_group` (NEW) | `p_group_id` | void | DEFINER | group is `private` |
| `invite_user_to_group` (NEW) | `p_group_id, p_user_id` | void | DEFINER | caller is member |
| `accept_group_invite` (NEW) | `p_group_id` | void | DEFINER | caller has pending invite |
| `approve_join_request` (NEW) | `p_group_id, p_user_id` | void | DEFINER | caller is admin |
| `assign_group_admin` (NEW) | `p_group_id, p_user_id` | void | DEFINER | caller is admin |
| `delete_group_admin` | `p_group_id, p_user_id` | void | DEFINER | caller is admin or self-resign; block removing last admin |
| `leave_group` (NEW) | `p_group_id` | void | DEFINER | self only |
| `update_total_group_members` | `p_group_id` | void | DEFINER | recompute |
| `update_user_group_count` | (none, JWT) | void | DEFINER | `auth.uid()`-scoped |
| `check_group_member` | `p_userid, p_postid` | bool | INVOKER | — |

## 6. Events
| RPC | Args | Returns | Mode | Validations |
|---|---|---|---|---|
| `update_event_location` | `p_event_id, p_lat text, p_lon text` | void | DEFINER | caller = `admin_user` |
| `update_event_attendee_count` | `p_event_id` | void | DEFINER | recompute from `is_attending=true` |
| `invite_user_to_event` | `p_event_id, p_attending_id` | void | DEFINER | caller can invite |
| `create_event` / `update_event` / `delete_event` (NEW) | event fields / `p_event_id` | row / void | DEFINER | `auth.uid()=admin_user` |
| `rsvp_event` (NEW) | `p_event_id, p_attending bool` | void | DEFINER | self RSVP only |

## 7. Marketplace / Sale
| RPC | Args | Returns | Mode | Validations |
|---|---|---|---|---|
| `insert_sales_details` | `community_id, title, description, sale_category, e_price_type, price, location, e_sale_type, p_userid, lon, lat, city` | new row (`$.id`) | DEFINER | `auth.uid()=p_userid`; builds `location_point`; *(community_id: compat arg only, unused)* |
| `update_sale_without_image` | `city, description, e_price_type, lat, location, lon, price, sale_category, sale_id, title` | updated row | DEFINER | caller = `created_by` |
| `get_yours_sales_details` | `p_userid, p_filter` | listings[] | INVOKER | `auth.uid()=p_userid` |
| `get_sales_details` | `p_salesid, p_userid` | listing | INVOKER | sale visibility |
| `get_sales_homepage` | `p_userid, p_communityid, p_saleid` | listing | INVOKER | *(p_communityid: compat arg only, unused)* |
| `get_sales_home_data` | `p_userid, p_category, p_type, p_distance, p_sort, p_communityid` | feed[] w/ `distance_km` | INVOKER | app-wide (no community scope); geo distance; *(p_communityid: compat arg only, unused)* |
| `update_sale_count` | `p_userid` | void | DEFINER | `auth.uid()=p_userid` |
| `get_sale_images` | `p_saleid` | images[] | INVOKER | sale visibility |

## 8. Business Pages & Promotions
| RPC | Args | Returns | Mode | Validations |
|---|---|---|---|---|
| `get_my_business` | `p_userid, p_communityid` | pages + `promotion_status` | INVOKER | `auth.uid()=p_userid`; *(p_communityid: compat arg only, unused)* |
| `get_business_details` | `p_businessid, p_userid` | full profile | INVOKER | app-wide (no community scope) |
| `get_all_business` | `p_userid, p_communityid` | pages[] | INVOKER | app-wide (no community scope); *(p_communityid: compat arg only, unused)* |
| `get_specific_business` | `p_userid, p_communityid, p_businessid` | page | INVOKER | *(p_communityid: compat arg only, unused)* |
| `get_promotion_plan` | `p_businessid` | plan | INVOKER | — |
| `update_contacted` | `p_userid, p_businessid, p_contactedby, p_communityid` | void | DEFINER | `auth.uid()=p_userid`; upsert + append channel; *(p_communityid: compat arg only, unused)* |
| `get_contact_count` | `p_businessid` | count | INVOKER | — |
| `create_business` / `update_business` / `delete_business` / `restore_business` (NEW) | page fields / `p_business_id` | row/void | DEFINER | `auth.uid()=admin_user`; restore is owner-scoped |
| `submit_promotion` / `resubmit_promotion` (NEW) | plan id, receipt, reference | row | DEFINER | owner-only; client cannot set `status='live'`/dates |
| `moderate_promotion` (NEW, admin) | `promote_id, decision, start_date, end_date` | void | DEFINER | `is_admin()`; writes `audit_log` |
| `report_business` / `unreport_business` (NEW) | fields | id / void | DEFINER | see Moderation §13 |

## 9. Profile & Account
| RPC | Args | Returns | Mode | Validations |
|---|---|---|---|---|
| `user_follow` | shared with �4 (Neighbors/Follows) | — | — | — |
| `get_followers` | `search_query` | followers[] | INVOKER | `auth.uid()`-scoped |
| `get_following` | `search_query` | following[] | INVOKER | `auth.uid()`-scoped |
| `get_followers_nearby` | shared with �4 (Neighbors/Follows) | — | — | — |
| `get_user_following_groups_with_status` | shared with Groups | — | — | — |
| `update_user_profile_counts` | shared with Posts | — | — | — |
| `delete_account` (NEW, replaces client direct `UserTable().update`) | `p_reason` | void | DEFINER | `auth.uid()`; requires prior OTP verify; sets `is_deleted/reason/status`; writes `audit_log` |
| **Edge:** `change-password` | shared with Auth | — | — | — |

## 10. Chat & Messaging
| RPC | Args | Returns | Mode | Validations |
|---|---|---|---|---|
| `find_common_chat` | `user2` | `{chat_id, chat_found}` | INVOKER | `auth.uid()` = user1 |
| `add_chat_users` | `p_chat_id, p_community_id, p_user2` | void | DEFINER | adds both `auth.uid()` and `p_user2`; *(p_community_id: compat arg only, unused)* |
| `get_chat` | `search_query` | chat-list JSON | INVOKER | `auth.uid()`-scoped via `chat_users` |
| `soft_delete_chat_users` | `user_ids[]` | void | DEFINER | `auth.uid()`'s own membership only |
| `restore_chat_user` | `p_chat_id, p_user_id` | void | DEFINER | caller = `p_user_id` |
| `send_message` (NEW, recommended) | `p_chat_id, p_message, p_type, p_file_url?` | new row | DEFINER | `auth.uid()` is a member; updates `chat` preview + emits Broadcast |

## 11. Notifications
| RPC | Args | Returns | Mode | Validations |
|---|---|---|---|---|
| `get_notifications` | `p_userid` | grouped JSON | INVOKER preferred | must enforce `p_userid=auth.uid()`, never trust arg |
| `upsert_user_device_fcm` / `upsert_user_device` | shared with Auth | — | — | — |
| **Edge:** `send-push` | triggered by `notifications` INSERT / admin broadcast | — | service-role | OneSignal/FCM secrets server-side only |

## 12. Search & Tags
| RPC | Args | Returns | Mode | Validations |
|---|---|---|---|---|
| `get_search_all_data` | `p_search_text, p_userid, p_communityid, p_type, p_category, p_sale_type, p_sort, p_distance` | 6-array JSON | INVOKER | `auth.uid()`; *(p_communityid: compat arg only, unused)* |
| `get_search_data` | `p_userid, p_community, p_type, p_ids` | 6-array JSON + `eventData` | INVOKER | `auth.uid()`; *(p_community: compat arg only, unused)* |
| `tag_search` | `search_name` | users[] | INVOKER | scope TBD (Open Decisions) |
| `update_search_data` | `p_community_id, p_search_text, p_userid` | void | DEFINER | forces `searched_by` from validated `auth.uid()`; *(p_community_id: compat arg only, written as vestigial default, not used for scoping)* |
| `insert_tags` | shared with Posts | — | — | — |

## 13. Moderation — Reports, Blocks
| RPC | Args | Returns | Mode | Validations |
|---|---|---|---|---|
| `report_content` (NEW) | `report_type, target_id, reported_user, reason, community_id` | new id | DEFINER | forces `reported_by_user=auth.uid()`; coerces `''`→NULL; validates target FK matches `report_type`; *(community_id: compat arg only, unused)* |
| `block_user` (NEW) | `blocked_id` | void | DEFINER | `auth.uid()`; self-block guard; unique-safe |
| `unblock_user` (NEW) | `blocked_id` | void | DEFINER | `auth.uid()` = `blocker_id` |
| **Trigger/Edge:** on `reports` INSERT | — | — | DEFINER/edge | emails admin, sets `mail_sent=true` |

**Total RPC/Edge inventory: ~74 entries** (existing + `(NEW)` recommended replacements for the
direct-client-DML gaps CLAUDE.md §6 flags across nearly every feature doc). Every `(NEW)` one is a
**recommendation**, not yet decided — see `10-open-decisions.md` for the direct-DML-vs-RPC
decision that must be made per table before implementation.

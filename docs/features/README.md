# Viora — Feature Documentation

Detailed, per-feature specs derived from the **Flutter frontend** (the source of truth). Each
file records what the Supabase backend must provide for that feature to work: screens, data
model (tables + exact columns), backend calls, business rules, realtime, and a concrete
"backend to build" checklist for the rebuild.

> Doc-first rule (CLAUDE.md §3): these docs are updated **before** backend code is written.
> If a doc and the code disagree, the doc wins and the code is fixed.

## Index

| # | Feature | Doc | Core tables |
|---|---------|-----|-------------|
| 1 | Authentication & Registration | [01-auth-registration.md](01-auth-registration.md) | user, user_login, user_roles, user_devices, user_locations, public_user_profile |
| 2 | Home Feed & Posts | [02-home-feed-posts.md](02-home-feed-posts.md) | post, post_images, post_like, post_share, tag, see_post_access, comment_post_access |
| 3 | Comments | [03-comments.md](03-comments.md) | post_comment, post_comment_likes, comment_post_access |
| 4 | Community & Neighborhoods | [04-community-neighborhoods.md](04-community-neighborhoods.md) | community, follows, user_locations |
| 5 | Groups | [05-groups.md](05-groups.md) | group, group_admin, group_members, group_members_invite, group_user_status |
| 6 | Events | [06-events.md](06-events.md) | event_page, event_attending |
| 7 | Marketplace / Sale | [07-marketplace-sale.md](07-marketplace-sale.md) | sale, sale_category, sale_images |
| 8 | Business Pages & Promotions | [08-business-promotions.md](08-business-promotions.md) | business_page, business_promote, business_promote_plans, business_contacted |
| 9 | Profile & Account | [09-profile-account.md](09-profile-account.md) | user, public_user_profile, follows, blocks |
| 10 | Chat & Messaging | [10-chat-messaging.md](10-chat-messaging.md) | chat, chat_users, messages |
| 11 | Notifications & Push | [11-notifications.md](11-notifications.md) | notifications, admin_notification, user_devices |
| 12 | Search & Tags | [12-search-tags.md](12-search-tags.md) | search_history, tag |
| 13 | Moderation — Reports, Blocks, Mute | [13-moderation-reports-blocks.md](13-moderation-reports-blocks.md) | reports, blocks |

## Conventions
- **Column types** come from the FlutterFlow Row classes under
  `lib/backend/supabase/database/tables/`. Match them **exactly** in the rebuild.
- **Backend calls** are the `…Call` classes in `lib/backend/api_requests/api_calls.dart` plus
  any direct `.from()/.rpc()/.storage` usage in the page widgets.
- Each doc's **§7 "Backend to build"** is the actionable checklist that feeds
  `docs/roadmap.md` Phase 1.
- Security intent (RLS, admin-only writes, RPC-gated user writes) follows **CLAUDE.md §6**.

## Table → feature coverage (all 39 tables)
Every table in the schema is owned by at least one feature doc above. `_TEMPLATE.md` is the
shared structure each doc follows.

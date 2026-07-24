# Feature: Notifications

> Source of truth = the Flutter frontend. This doc records what the backend MUST provide
> for this feature to work. Derived from `lib/` — do not invent behavior the code doesn't show.

## 1. Overview
- **What it is:** The notification system covers three things: (1) an **in-app notification
  list** grouped into tabs (All / Post / Group / Event / Business / For sale or free) that a user
  can read, mark-as-read, and delete; (2) **admin/broadcast notifications** (`admin_notification`
  table) that admins compose and send to an audience; and (3) **push delivery** via OneSignal
  and Firebase Cloud Messaging (FCM), backed by per-user **device token registration**
  (`user_devices`).
- **Why it exists / user value:** Users get told when someone interacts with their posts,
  comments, events, groups, businesses, marketplace sales, and invites — both in-app and as OS
  push notifications — so they return to the app and stay engaged with their neighborhood.
- **Related features:** Posts/Comments, Events, Groups, Business pages, Marketplace (For sale or
  free), Chat/Messaging (messaging has its own unread badge, separate from this list), Auth
  (device token registration is triggered from login/verify/create-account flows).

## 2. Screens & widgets
| Screen / widget (path under `lib/`) | Purpose | Key actions |
|---|---|---|
| `pages/notification/notification_widget.dart` | Main notification list screen. Loads notifications via RPC on page load into `FFAppState().notifications`. Renders 6 filter tabs (`_model.opt` = `all` / `post` / `group` / `event` / `business` / `sale`), each a `ListView` over a JSON array. | On page load: `NotificationCall`. Tapping a row navigates by `type` to the target screen AND marks it read (direct `NotificationsTable().update {is_read:true}`), then re-fetches via `NotificationCall`. Row 3-dot opens `CompNotificationWidget`. |
| `components/comp_notification_widget.dart` | Bottom-sheet actions for a single notification. | **Delete**: `NotificationsTable().update {is_deleted:true}` matched on `receiver_id == currentUserUid AND id == notificationId`, then re-fetch via `NotificationCall`. **Mark as read** (only if `isread == false`): `NotificationsTable().update {is_read:true}` same match, then re-fetch. |
| `pages/notification/notification_model.dart` | Holds the many `ApiCallResponse?` fields for the repeated `NotificationCall` re-fetches. | — |
| `custom_code/actions/setup_notifications.dart` | FCM foreground/background wiring + local notification banners + deep-link routing. Called from `main.dart` and `loading_page`. | Initializes Firebase, sets background handler, requests permission, shows local banners on `onMessage`, routes `squadd://` deep links / URLs on tap. |
| `custom_code/actions/check_notification_and_store_f_c_m_token.dart` | Checks permission, gets FCM token + device id, upserts to backend. Called from `loading_page`. | Calls RPC `upsert_user_device_fcm`; wires `onTokenRefresh` to re-upsert. |
| `custom_code/actions/set_f_c_m_token_and_update_database.dart` | Same as above (requests permission, gets FCM token, upserts). Called from all auth entry points (login, email login, verify, create account). | Calls RPC `upsert_user_device_fcm`. |
| `custom_code/actions/one_signal_notification.dart` | Initializes OneSignal, requests permission, gets the OneSignal **player id**, upserts to backend. (Defined/exported; invocation not observed in the pages read — see §8.) | Calls RPC `upsert_user_device` with `p_player_id`. |
| `pages/loading_page/loading_page_widget.dart` | Post-login bootstrap: runs `setupNotifications()` then `checkNotificationAndStoreFCMToken(anonKey)`. | — |
| `pages/registration/*` (login, email_login, verify, create_account) | Register the device FCM token right after auth. | `setFCMTokenAndUpdateDatabase(AnonKey)`. |

> Note: `admin_notification` has a Row class and is registered in `database.dart`, but no admin
> compose/send screen was found under `lib/pages/` (Viora's admin UI appears to live outside this
> Flutter app — see the `Operture` admin working dirs). The table contract is documented in §3.

## 3. Data model (tables & columns)

### `notifications`
- **Purpose:** One row per in-app notification delivered to a receiver. Read by the RPC
  `get_notifications`; updated directly by the client for `is_read` / `is_deleted`.
- **Columns:** (types/nullability from `tables/notifications.dart`)
  | Column | Type | Null? | Notes (PK/FK/default/enum) |
  |---|---|---|---|
  | `id` | uuid (text in Dart) | NOT NULL | PK. Used in `.eq('id', ...)` matches. |
  | `created_at` | timestamptz | NOT NULL | default `now()`. Rendered via `getRelativeTime`. |
  | `sender_id` | uuid | NOT NULL | FK → users/profile (the actor). Drives `name` + `profile_image` in RPC output. |
  | `receiver_id` | uuid | **nullable** in Row | FK → users. The recipient. Client matches updates on `receiver_id == currentUserUid`. (Effectively required in practice; see §8.) |
  | `type` | text | nullable | Category/routing key. Observed values: `post`, `comment`, `event`, `business`, `sale`, `group`, `invite`, `group_invite`. Drives navigation + tab filtering. |
  | `notification_type` | text | nullable | Second type field, purpose unclear (see §8). |
  | `content` | text | NOT NULL | Main body text shown after the sender name. |
  | `title` | text | nullable | Optional title. |
  | `message` | text | nullable | Optional extra message appended to the row. |
  | `is_read` | bool | NOT NULL | default `false`. Toggled to `true` on tap / mark-as-read. Drives row background color. |
  | `is_deleted` | bool | NOT NULL | default `false`. Soft-delete flag set by client. RPC must exclude deleted rows. |
  | `post_id` | uuid | nullable | FK → posts. Present for `post` / `comment` type; used to open `CommentsPageWidget`. |
  | `comment_id` | uuid | nullable | FK → comments. |
  | `event_id` | uuid | nullable | FK → events. Used to open `EventDetailsWidget`. |
  | `business_id` | uuid | nullable | FK → business. Used to open `BusinessHomePageWidget`. |
  | `sale_id` | uuid | nullable | FK → marketplace sale. Used to open `SaleDetailsWidget`. |
  | `group_id` | uuid | nullable | FK → groups. Used to open `GroupDetailsWidget`. |
  | `message_id` | uuid | nullable | FK → chat message (present in schema; not used by the notification list UI). |
- **Foreign keys / relationships:** `sender_id` → user, `receiver_id` → user, and the optional
  entity FKs above (`post_id`, `comment_id`, `event_id`, `business_id`, `sale_id`, `group_id`,
  `message_id`) each to their respective tables. Use `on delete cascade` (or `set null`) so a
  deleted entity does not leave dangling notifications.
- **Indexes needed:** `receiver_id` (list + update match), composite `(receiver_id, is_deleted, is_read)`
  and `(receiver_id, created_at desc)` for the RPC ordering/filtering, `sender_id`, and every
  entity FK column.

### `user_devices`
- **Purpose:** Stores one row per (user, device) with its FCM push token. Written only via RPC.
- **Columns:** (from `tables/user_devices.dart`)
  | Column | Type | Null? | Notes (PK/FK/default/enum) |
  |---|---|---|---|
  | `id` | uuid | NOT NULL | PK. |
  | `created_at` | timestamptz | NOT NULL | default `now()`. |
  | `user_id` | uuid | NOT NULL | FK → users. |
  | `device_id` | text | NOT NULL | Per-device id: Android `androidInfo.id`, iOS `identifierForVendor`. |
  | `fcm_token` | text | NOT NULL | Firebase Cloud Messaging token. |
- **Foreign keys / relationships:** `user_id` → users, `on delete cascade`.
- **Indexes needed:** `user_id`; **unique `(user_id, device_id)`** to support upsert semantics
  (`upsert_user_device_fcm` re-inserts/updates per device on token refresh).
- **⚠ player_id gap:** The OneSignal path (`one_signal_notification.dart`) calls RPC
  `upsert_user_device` with `p_player_id`, but the `user_devices` Row class has **no**
  `player_id` column. Either `user_devices` needs a nullable `player_id text` column, or the
  OneSignal player id lives in a separate table. Must be resolved during rebuild — see §8.

### `admin_notification`
- **Purpose:** Admin-composed broadcast/announcement notifications targeting an audience.
- **Columns:** (from `tables/admin_notification.dart`)
  | Column | Type | Null? | Notes (PK/FK/default/enum) |
  |---|---|---|---|
  | `id` | int8 (bigint) | NOT NULL | PK (integer identity — differs from `notifications.id` which is uuid). |
  | `created_at` | timestamptz | NOT NULL | default `now()`. |
  | `title` | text | nullable | Notification title. |
  | `content` | text | nullable | Notification body. |
  | `sent_on` | timestamptz | nullable | When the broadcast was actually sent (null until sent → supports draft/scheduled). |
  | `status` | text | nullable | Lifecycle status (e.g. draft / scheduled / sent — enum values not defined in frontend). |
  | `audience_type` | text | nullable | Target audience selector (e.g. all users / segment — values not defined in frontend). |
- **Foreign keys / relationships:** none in the Row class. A sender/admin FK may be desirable.
- **Indexes needed:** `status`, `sent_on` (for scheduling/cron pickup), `audience_type`.

## 4. Backend calls (API / RPC / Edge)
| Call / query | Type | Inputs | Returns | Called from |
|---|---|---|---|---|
| `NotificationCall` → RPC `get_notifications` | RPC (REST POST to `/rest/v1/rpc/get_notifications`) | body `{ "p_userid": <uuid> }`; headers `apikey` (anon) + `Authorization: Bearer <jwt>` | JSON object with arrays keyed `all`, `post`, `group`, `event`, `business`, `sale`. Each item exposes: `id`, `type`, `is_read`, `created_at`, `name`, `profile_image`, `content`, `message`, and entity ids (`post_id`, `event_id`, `business_id`, `sale_id`, `group_id`). Stored in `FFAppState().notifications`. | `notification_widget` (page load + after every mark-read), `comp_notification_widget` (after delete/mark-read) |
| `NotificationsTable().update` | Direct DML (PostgREST PATCH) | `data {is_read:true}` or `{is_deleted:true}`; match `receiver_id == currentUserUid AND id == <id>` | updated row | `notification_widget` (row tap), `comp_notification_widget` (delete / mark-read) |
| RPC `upsert_user_device_fcm` | RPC (REST POST) | `{ "p_device_id": <text>, "p_fcm_token": <text> }`; JWT identifies the user | success / `{error}` | `check_notification_and_store_f_c_m_token.dart`, `set_f_c_m_token_and_update_database.dart`, token-refresh listener |
| RPC `upsert_user_device` | RPC (REST POST) | `{ "p_device_id": <text>, "p_player_id": <text> }`; JWT identifies the user | success | `one_signal_notification.dart` |

> There is **no client-side insert** into `notifications`. Notification rows must be created
> server-side (by triggers or RPCs owned by the originating features — like/comment/follow/invite/
> event/group/business/sale). This doc defines the read + state-change contract only; the
> creation triggers belong to each source feature but are listed as a build item in §7.

## 5. Business rules & flows

**Load list (page open):**
1. `notification_widget.initState` sets `opt = 'all'`, calls `NotificationCall(p_userid = currentUserUid)`.
2. Result JSON is stored in `FFAppState().notifications`; `showData = true` reveals the list.
3. Tabs filter client-side by reading `$.all` / `$.post` / `$.group` / `$.event` / `$.business` /
   `$.sale` from that same JSON blob — so the RPC must return all six groupings in one call.

**Tap a notification row:**
1. Branch on `item.type` and `context.pushNamed(...)` the matching screen with the matching id:
   - `post` → `CommentsPageWidget(postId)`
   - `comment` → `EventDetailsWidget(eventId)` *(note: the `comment` branch navigates to Event —
     appears to be a FlutterFlow copy/paste quirk; flagged in §8)*
   - `event` → `MyEventWidget(btnOption:'invitations')`
   - `business` → `BusinessHomePageWidget(businessId)`
   - `sale` → `SaleDetailsWidget(saleId)`
   - `group` → `GroupDetailsWidget(groupId)`
   - `invite` → `MyEventWidget(btnOption:'invitations')`
   - `group_invite` → `MyGroupWidget(initialButton:'invitations')`
2. If `is_read == 'false'`, immediately `NotificationsTable().update {is_read:true}` matched on
   `receiver_id == currentUserUid AND id`, then re-fetch via `NotificationCall` and refresh state.

**Mark as read / Delete (3-dot bottom sheet):**
- Delete → soft-delete `{is_deleted:true}` (never hard-deleted from the client). RPC output must
  exclude `is_deleted = true` rows.
- Mark as read shown only when `isread == false`.

**Ownership rule:** every client update is scoped `receiver_id == currentUserUid`. Backend RLS
must enforce that a user can only update (`is_read`/`is_deleted`) their **own received**
notifications — never someone else's.

**Read-state UI:** unread rows render with `greayL1` background; read rows render `white`. There
is no separate unread-count badge wired in the notification page header (the header bell/message
badge shown there is the **chat** unread indicator, not notifications) — see §8.

**Device registration flow:** on login / account creation / verify and on the loading page, the
app requests OS notification permission, obtains the FCM token + a stable `device_id`
(Android `androidInfo.id`, iOS `identifierForVendor`), and upserts `{device_id, fcm_token}` per
user. Token refreshes re-upsert automatically. The OneSignal path additionally captures a
`player_id`. Both Android and iOS are handled explicitly (per §2 of CLAUDE.md).

## 6. Realtime / notifications

**In-app list refresh (current behavior):** polling-by-refetch — the app re-calls
`get_notifications` after each state change. There is **no** realtime subscription in the code
(no `.channel(`, `.stream(`, or Postgres Changes usage found for notifications).

**Recommended realtime mode (for the rebuild):** Use **Broadcast** (private, authorized channel
per user, e.g. `notifications:<user_id>`) to push a lightweight "new notification / unread count
changed" event so the badge/list update live without re-polling. Per CLAUDE.md §6, Broadcast is
preferred for low-latency app events (notifications, live counts); it must be a **private channel
authorized via RLS on `realtime.messages`**. Only fall back to Postgres Changes if a raw row
change must directly drive the UI with a documented reason. The list content itself can still be
hydrated by the existing `get_notifications` RPC on the broadcast signal.

**Push delivery (OneSignal + FCM):**
- Client registers device tokens (FCM token via `upsert_user_device_fcm`; OneSignal player id via
  `upsert_user_device`). `setup_notifications.dart` handles foreground banners (via
  `flutter_local_notifications`), background handler, and deep-link routing for `squadd://…` URLs
  carried in the push `data.url`.
- **Server-side send:** when a `notifications` row is created (or an `admin_notification` is
  sent), the backend must look up the receiver's device tokens/player ids and call the push
  provider. This send **must** run in an **Edge Function** (or the Firebase function), never from
  the client. The **OneSignal REST API key / FCM server key are server-side secrets** — store in
  Edge Function env / Supabase config, NEVER in `assets/environment_values/` or `lib/`. (Only the
  OneSignal **App ID** and Supabase **anon key** are safe on the client; those already live in
  `environment_values`.) The push payload should include a `url` deep link
  (`squadd://…/loadingPage?…`) so `setup_notifications` can route the tap.
- `firebase/functions/index.js` currently contains only boilerplate (`admin.initializeApp()`),
  so no send logic exists yet — it must be built.

## 7. Backend to build (Supabase rebuild checklist)
- [ ] **Tables:**
  - [ ] `notifications` (uuid id, created_at, sender_id, receiver_id, type, notification_type,
        content, title, message, is_read default false, is_deleted default false, + entity FKs
        `post_id`/`comment_id`/`event_id`/`business_id`/`sale_id`/`group_id`/`message_id`).
  - [ ] `user_devices` (uuid id, created_at, user_id, device_id, fcm_token, **+ nullable
        `player_id`** to reconcile the OneSignal RPC — confirm in §8). Unique `(user_id, device_id)`.
  - [ ] `admin_notification` (bigint id, created_at, title, content, sent_on, status,
        audience_type).
- [ ] **FKs + indexes:** every FK indexed; `notifications(receiver_id, created_at desc)`,
      `notifications(receiver_id, is_deleted, is_read)`; `user_devices(user_id)` + unique
      `(user_id, device_id)`; `admin_notification(status, sent_on)`.
- [ ] **RLS intent:**
  - `notifications`: SELECT only rows where `receiver_id = auth.uid()` (RPC uses that too);
    UPDATE limited to own rows and only the `is_read` / `is_deleted` columns; INSERT/DELETE
    **not** allowed to normal users (created server-side). No hard delete from client.
  - `user_devices`: SELECT/own rows only; INSERT/UPDATE via the upsert RPCs only (no direct DML).
  - `admin_notification`: SELECT/INSERT/UPDATE **admin-only** (`is_admin()` predicate).
- [ ] **RPC / PL-pgSQL functions:**
  - [ ] `get_notifications(p_userid uuid)` — returns grouped JSON (`all`/`post`/`group`/`event`/
        `business`/`sale`), each item joined to sender for `name` + `profile_image`, excluding
        `is_deleted = true`, ordered `created_at desc`. **SECURITY** — must enforce
        `p_userid = auth.uid()` (do not trust the arg); prefer INVOKER + RLS, or DEFINER with an
        internal `auth.uid()` check + `SET search_path = public, pg_temp`.
  - [ ] `upsert_user_device_fcm(p_device_id text, p_fcm_token text)` — upsert on
        `(user_id = auth.uid(), device_id)`. SECURITY DEFINER, validate `auth.uid()`, revoke from
        public / grant to `authenticated`.
  - [ ] `upsert_user_device(p_device_id text, p_player_id text)` — same pattern for OneSignal
        player id (write to `user_devices.player_id` or the resolved location).
  - [ ] (Optional) admin RPC to compose/send an `admin_notification` and fan it out.
- [ ] **Triggers:** notification-row **creation** triggers/RPCs owned by each source feature
      (like, comment, follow/invite, event, group, business, marketplace sale) that insert into
      `notifications` with the right `type` + entity id. These are the producers the list consumes.
- [ ] **Edge functions (secrets, external APIs):**
  - [ ] `send-push` — on new `notifications` row (DB webhook/trigger) or admin broadcast: resolve
        the receiver's `user_devices` tokens/player ids and call **OneSignal REST API** (and/or
        FCM). **Secrets:** OneSignal REST API key + FCM server key stored server-side only.
        Payload carries a `squadd://` deep-link `url`.
- [ ] **Cron:** if `admin_notification.status`/`sent_on` supports scheduling, a cron job to pick
      up due broadcasts and invoke `send-push`.
- [ ] **Realtime:** private per-user Broadcast channel + RLS on `realtime.messages` for live
      badge/list updates.
- [ ] **Storage buckets:** none required for this feature.

## 8. Open questions & risks
1. **`notification_type` vs `type`:** two separate columns exist. Only `type` is used by the UI
   (routing + tabs). What is `notification_type` for? Confirm whether it is legacy/duplicate or
   carries a distinct meaning before rebuilding.
2. **OneSignal `player_id` storage:** `upsert_user_device` sends `p_player_id`, but `user_devices`
   (per the Row class) has no `player_id` column. Add a nullable `player_id` to `user_devices`, or
   is there a separate table? Must confirm — the OneSignal path is otherwise broken.
3. **Is OneSignal actually active?** `oneSignalNotification` is defined/exported but its
   invocation was not found in the pages read (only the FCM actions `setFCMTokenAndUpdateDatabase`
   / `checkNotificationAndStoreFCMToken` are called from auth + loading flows). Confirm whether
   push is delivered via OneSignal, FCM directly, or both — this decides which token table columns
   and which Edge Function integration to build.
4. **`comment` type routes to Event:** in `notification_widget`, `type == 'comment'` navigates to
   `EventDetailsWidget(eventId)`, which looks like a FlutterFlow copy/paste bug (a comment should
   open the post). Confirm intended target before relying on `type` semantics.
5. **`receiver_id` nullability:** the Row class marks `receiver_id` nullable, yet every query
   matches on it and it is the RLS ownership key. It should almost certainly be NOT NULL in the
   rebuilt schema — confirm.
6. **`get_notifications` exact shape:** the grouped keys and per-item fields (`name`,
   `profile_image`, etc.) are inferred from `getJsonField` paths in the UI. The full authoritative
   field list / join logic must be reverse-engineered from the live RPC (not visible in frontend)
   or redefined from scratch. Tab list = All/Post/Group/Event/Business/Sale — no dedicated
   like/follow tab, so those (if they exist) fold into `all`.
7. **`admin_notification` producer + `status`/`audience_type` enums:** no Flutter admin screen was
   found (admin UI appears to be the separate `Operture` app). The allowed `status` and
   `audience_type` values, and how a broadcast fans out to individual `notifications` rows / push,
   are undefined in this frontend and must be specified with the admin app's owner.
8. **No unread badge on the notification tab:** the badge in the notification header is chat
   unread, not notification unread. If a notifications unread count/badge is desired (e.g. on the
   bottom nav), it needs a new count source (RPC or realtime) — currently not built.
9. **Push secret exposure:** verify no OneSignal REST API key / FCM server key is bundled in
   `assets/environment_values/` (only App ID + anon key belong client-side). Ties into the
   CLAUDE.md §5 known-issue about a `sk_live_...` secret currently in `environment.json`.

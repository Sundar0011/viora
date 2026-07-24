# Feature: Events

> Source of truth = the Flutter frontend. This doc records what the backend MUST provide
> for this feature to work. Derived from `lib/` — do not invent behavior the code doesn't show.

## 1. Overview
- **What it is:** Community events. Users create/edit/delete events (online or offline), view
  event details, RSVP ("Attend"/"Attending"), invite neighbors, see attendee counts, browse
  events by list (latest / ending soon / all / my events), and report an event.
- **Why it exists / user value:** Lets neighbors organize and discover local gatherings within
  their community (`community_id`), with location, date/time, cover image, and an attendee list.
- **Related features:** Reports (`reports` table, shared with posts/sales), Notifications
  (OneSignal on invite — see §6), Neighborhood people/followers (invite list source),
  User profile counts (`UpdateUserProfileCounts` — separate feature).

## 2. Screens & widgets
| Screen / widget (path under `lib/`) | Purpose | Key actions |
|---|---|---|
| `pages/events/create_event/` | Create a new event | Insert `event_page`, upload cover to `event` bucket, set location via RPC, auto-attend creator |
| `pages/events/edit_event/` | Edit an existing event | Update `event_page` fields, replace cover image, re-set location via RPC |
| `pages/events/event_details/` | Full event view | Attend/unattend, invite users, view attendees, "more events" list (limit 4), open three-dot menu |
| `pages/events/latest_event/` | "Latest" events list | Query upcoming events ordered by `created_at` |
| `pages/events/ending_event/` | "Ending soon" events list | Query upcoming events ordered by `end_date_time` |
| `pages/events/all_events/` | All events list | Query upcoming events ordered by `created_at` |
| `pages/events/my_event/` | My events: invited + created | Query `event_attending` (invited) and `event_page` (created) |
| `pages/events/comp_event_attending_btn/` | RSVP toggle button | Insert/update `event_attending.is_attending` |
| `pages/events/comp_delete_event/` | Delete confirmation sheet | Soft-delete event + mark attendees group-deleted |
| `pages/events/comp_report_event/` | Report event sheet | Insert into `reports` (report_type='event') |
| `pages/events/comp_event_three_dot1/`, `comp_event_three_dot2/` | Owner/other three-dot menus | Route to edit / delete / report |
| `pages/events/comp_select_date_time/` | Date/time picker component | Sets `ChoosedStartEventDate` / `EventChoosedTime` app state |

## 3. Data model (tables & columns)

### `event_page`
- **Purpose:** One row per event. Types/nullability from `EventPageRow`
  (`lib/backend/supabase/database/tables/event_page.dart`).
- **Columns:**
  | Column | Type | Null? | Notes (PK/FK/default/enum) |
  |---|---|---|---|
  | `id` | uuid (String) | no | PK. FlutterFlow reads as String; used as storage folder name |
  | `created_at` | timestamptz | no | default `now()`; primary sort key for lists |
  | `community_id` | int8 | no | FK → community. Set from `FFAppState().communityId` |
  | `admin_user` | uuid (String) | no | FK → event owner/creator (`currentUserUid`) |
  | `name` | text | no | Event title |
  | `event_type` | text | no | 'Online' / 'Offline' (from radio button). Not a DB enum in frontend |
  | `cover_image` | text | no | Public URL from `event` storage bucket. Inserted as `''`, updated after upload |
  | `video_call_link` | text | yes | Meet/video link (validated for Online events) |
  | `location` | text | yes | Separate from `Address`; NOT written by insert/update DML — see §4 RPC `update_event_location` |
  | `start_date_time` | timestamptz | no | Event start (date + time combined via `returnTimeStamp`) |
  | `end_date_time` | timestamptz | yes | Event end. If no end chosen, set equal to start. Drives all list filtering |
  | `description` | text | no | Event description |
  | `is_deleted` | bool | yes | Soft-delete flag. Inserted `false`; set `true` on delete |
  | `attendee_count` | int4 (int) | no | Inserted `0`; maintained by RPC `update_event_attendee_count` |
  | `Address` | text | yes | **Note capital "A"** — human-readable address string |
  | `latitude` | float8 (double) | yes | Set on insert/edit |
  | `logitude` | float8 (double) | yes | **Note misspelling "logitude"** (not "longitude") — column name must match exactly |
  | `event_status` | text | no | Set to `Status.removed.name` = `'removed'` on delete. Enum values from `Status`: `active`, `removed`, `suspended` (see `lib/backend/schema/enums/enums.dart`). New events do not set it on insert (see §8) |
- **Foreign keys / relationships:** `community_id` → community; `admin_user` → user profile
  (`public_user_profile.id` / auth user). One-to-many with `event_attending` via `event_id`.
- **Indexes needed:** `community_id`, `admin_user`, `is_deleted`, `end_date_time`,
  `created_at`, `event_status`. Composite `(community_id, is_deleted, end_date_time)` supports the
  list queries; `(is_deleted, end_date_time, created_at)` supports latest/all ordering.

### `event_attending`
- **Purpose:** Join table for RSVP and invitations. One row per (event, user). Types from
  `EventAttendingRow` (`lib/backend/supabase/database/tables/event_attending.dart`).
- **Columns:**
  | Column | Type | Null? | Notes (PK/FK/default/enum) |
  |---|---|---|---|
  | `id` | uuid (String) | no | PK |
  | `created_at` | timestamptz | no | default `now()` |
  | `community_id` | int8 | no | FK → community |
  | `event_id` | uuid (String) | no | FK → `event_page.id` |
  | `attending_id` | uuid (String) | no | FK → the user attending/invited |
  | `is_invited` | bool | no | `true` if row created by an invite, `false` if self-RSVP |
  | `invited_by` | uuid (String) | yes | FK → user who sent the invite (`currentUserUid`) |
  | `is_attending` | bool | yes | RSVP state. `true` = attending, `false` = not attending/invited-only |
  | `end_date_time` | timestamptz | yes | Copied from the event on invite; used to filter "my invited events" |
  | `is_group_deleted` | bool | yes | Set `true` when the parent event is soft-deleted |
- **Foreign keys / relationships:** `event_id` → `event_page.id` (on delete cascade or set
  via soft-delete flag); `attending_id` → user; `invited_by` → user.
- **Indexes needed:** `event_id`, `attending_id`, `community_id`, `invited_by`, and composite
  `(attending_id, is_invited, is_attending, end_date_time, is_group_deleted)` for the my-events
  invited query; `(event_id, attending_id)` for per-user RSVP lookups (candidate unique constraint).

### `reports` (shared table — event uses it, not owned by this feature)
- **Purpose:** Report an event. Insert only, from `comp_report_event`.
- **Columns written:** `community_id` (int8), `reported_by_user` (uuid), `reason` (text),
  `report_type` (text = `'event'`), `event_id` (uuid → `event_page.id`), `reported_user` (uuid →
  the event owner). Returns `id` (used by thank-you sheet). Full schema owned by the Reports feature doc.

## 4. Backend calls (API / RPC / Edge)
| Call / query | Type | Inputs | Returns | Called from |
|---|---|---|---|---|
| `EventPageTable().insert({...})` | direct DML (PostgREST) | community_id, admin_user, name, event_type, description, is_deleted=false, attendee_count=0, video_call_link, cover_image='', Address, start_date_time, latitude, logitude | inserted `event_page` row (needs `id`) | create_event |
| `EventPageTable().update({end_date_time})` | direct DML | matches `id` | — | create_event (sets end = end or start) |
| `EventPageTable().update({cover_image})` | direct DML | matches `id` | — | create_event, edit_event (after upload) |
| `EventPageTable().update({name,event_type,video_call_link,start_date_time,description,Address,latitude,logitude})` | direct DML | matches `id` | — | edit_event |
| `EventPageTable().update({is_deleted:true, event_status:'removed'})` | direct DML | matches `id` | — | comp_delete_event |
| `EventPageTable().querySingleRow(id)` | direct DML select | `id` | one event | event_details |
| `EventPageTable().queryRows(is_deleted=false, end_date_time>now, [community_id], order)` | direct DML select | filters below | event list | latest/ending/all/my/event_details |
| `EventAttendingTable().insert({...})` | direct DML | community_id, event_id, attending_id, is_invited, is_attending, [invited_by], [end_date_time] | attending row | attend/create/invite flows |
| `EventAttendingTable().update({is_attending})` | direct DML | match event_id+attending_id | — | RSVP toggle |
| `EventAttendingTable().update({is_group_deleted:true})` | direct DML | match event_id | — | comp_delete_event |
| `EventAttendingTable().querySingleRow/queryRows(...)` | direct DML select | event_id, attending_id, is_attending, is_invited, end_date_time, is_group_deleted | attending state | attending button, my_event |
| `UpdateEventLocationCall` → RPC `update_event_location` | RPC (REST `/rpc/`) | `p_event_id`, `p_lat`, `p_lon` (all strings) | — | create_event, edit_event |
| `UpdateEventAttendeeCountCall` → RPC `update_event_attendee_count` | RPC (REST `/rpc/`) | `p_event_id` | — | event_details (after each RSVP change) |
| `InviteUserToEventCall` → RPC `invite_user_to_event` | RPC (REST `/rpc/`) | `p_event_id`, `p_attending_id` | — | event_details (invite when attending row already exists) |
| `uploadSupabaseStorageFiles(bucketName:'event')` | Storage | file bytes, folder = event `id` | public download URL | create_event, edit_event |
| `deleteSupabaseFileFromPublicUrl(coverImage)` | Storage | old cover URL | — | edit_event (before replacing image) |
| `ReportsTable().insert({...})` | direct DML | see §3 reports | inserted report `id` | comp_report_event |

**RPC contracts (frontend-observed inputs — implementation must be built):**
- `update_event_location(p_event_id text/uuid, p_lat text, p_lon text)` — writes a PostGIS/geo
  `location` value on `event_page` from lat/lon. Lat/lon passed as **strings** (must cast).
- `update_event_attendee_count(p_event_id uuid)` — recomputes `event_page.attendee_count` =
  count of `event_attending` rows for the event where `is_attending = true`. Called after every
  attend/unattend in event_details.
- `invite_user_to_event(p_event_id uuid, p_attending_id uuid)` — used when an `event_attending`
  row for that user already exists; marks/updates it as invited. When NO row exists yet, the
  frontend instead does a direct insert (is_invited=true, invited_by=currentUser, is_attending=false).

## 5. Business rules & flows

### Create event (create_event)
1. Validate: event name, event type, location (place chosen OR type == 'Online'), start date
   chosen, form valid, image uploaded, and (for Online) a valid meet link via `validateMeetLink`.
2. Insert `event_page` with `attendee_count=0`, `is_deleted=false`, `cover_image=''`,
   `start_date_time` from chosen date+time.
3. Update `end_date_time`: if an end date was chosen use it, else set end = start.
4. Upload cover image to storage bucket `event`, folder = new event `id`; update `cover_image`.
5. Call `update_event_location` RPC with lat/lon.
6. Insert creator into `event_attending` (`is_invited=false`, `is_attending=true`) — creator
   auto-attends. (Note: this insert does not bump `attendee_count`; see §8.)
7. `UpdateUserProfileCounts` (option 'event'); pop.

### Edit event (edit_event)
- Owner only (reached from owner three-dot menu). Updates name, type, video link, start/end
  date, description (kept from existing row), Address, lat/lon. If a new image chosen: delete old
  cover from storage, upload new, update `cover_image`. Re-calls `update_event_location`.

### Delete event (comp_delete_event) — soft delete
- Set `event_page.is_deleted=true` AND `event_status='removed'`.
- Set all `event_attending.is_group_deleted=true` for that `event_id`.
- `UpdateUserProfileCounts` (option 'event'); navigate to Community.
- No hard delete; lists exclude `is_deleted=true`.

### RSVP / Attend toggle (comp_event_attending_btn, event_details, list cards)
- State is `event_attending` row keyed by (`event_id`, `attending_id`=current user):
  - No row / not attending → **"Attend"**: insert row (`is_invited=false`, `is_attending=true`)
    OR update existing row `is_attending=true`.
  - `is_attending=true` → button shows **"Attending"**; pressing sets `is_attending=false`.
- In event_details, every RSVP change is followed by `update_event_attendee_count` RPC to keep
  `event_page.attendee_count` accurate. (List/button components toggle the row but do not all call
  the count RPC — see §8.)

### Invite users (event_details)
- Invite list sourced from friends/followers JSON. Per user:
  - If an `event_attending` row already exists (`containerEventAttendingRow.id` present) →
    `invite_user_to_event` RPC.
  - Else → direct insert (`is_invited=true`, `invited_by=currentUser`, `is_attending=false`,
    `end_date_time` copied from the event).
- If a row is invited (`is_invited=true`), UI shows a disabled "invited" state.

### Event lifecycle / list computation
- **"Upcoming" filter (used by every list):** `is_deleted = false` AND
  `end_date_time > now()` (`getCurrentTimestamp`). An event disappears from lists once its
  `end_date_time` passes ("ended").
- **Latest** (`latest_event`) and **All** (`all_events`): upcoming events (also `community_id =
  current community` for latest) ordered by `created_at` ascending.
- **Ending soon** (`ending_event`): upcoming events ordered by `end_date_time` ascending (soonest
  end first). Note: no `community_id` filter in the observed query.
- **My events** (`my_event`): two lists —
  - Invited: `event_attending` where `attending_id=me`, `is_invited=true`, `is_attending=false`,
    `end_date_time>now`, `is_group_deleted=false`.
  - Created: `event_page` where `is_deleted=false`, `end_date_time>now`, ordered by `created_at`
    (the observed query does **not** filter by `admin_user` — see §8).
- **More events** (event_details footer): upcoming events, exclude current `id`, order by
  `created_at`, `limit 4`.
- There is no explicit "ongoing" query; "ongoing" would be `start<=now<end` but the frontend
  only distinguishes upcoming (`end>now`) vs ended (`end<=now`).

### Report event (comp_report_event)
- Insert into `reports` with `report_type='event'`, `event_id`, `reported_user` (owner),
  `reported_by_user` (me), `reason` (chosen radio value, or free text if "Something else"),
  `community_id`. Show thank-you sheet.

## 6. Realtime / notifications
- **Realtime:** No Supabase Realtime channels observed in the events widgets. Lists use
  `FutureBuilder` + `Completer`/`waitForRequestCompleted` (manual refresh), not live subscriptions.
- **Notifications:** No direct OneSignal call in these widgets, but `invite_user_to_event` /
  invite inserts imply the invited user should receive a notification. Confirm whether the invite
  RPC (or a DB trigger) enqueues a OneSignal/`get_notifications` entry — see §8.

## 7. Backend to build (Supabase rebuild checklist)
- [ ] **Table `event_page`** with all columns in §3 (keep exact names incl. `Address` capital A
      and misspelled `logitude`). `id` uuid PK, `created_at`/`updated_at` timestamptz, FKs on
      `community_id` and `admin_user` with sensible `on delete`. Add a geo/`location` column
      written by the location RPC.
- [ ] **Table `event_attending`** per §3 with FKs `event_id`→`event_page.id`,
      `attending_id`→user, `invited_by`→user. Consider unique `(event_id, attending_id)`.
- [ ] **Indexes:** all FK columns + `is_deleted`, `end_date_time`, `created_at`, `event_status`
      on `event_page`; `event_id`, `attending_id`, `is_invited`, `is_attending`,
      `is_group_deleted`, `end_date_time` on `event_attending`.
- [ ] **RLS intent:**
      - `event_page` SELECT: members of the same `community_id` (and exclude `is_deleted`),
        INSERT/UPDATE/DELETE gated so only `admin_user` (owner) or admin can mutate. Per CLAUDE.md
        §6, user writes should go through RPC, not direct DML — the frontend currently does direct
        insert/update; the rebuild should wrap create/edit/delete in `SECURITY INVOKER` RPCs that
        validate `auth.uid() = admin_user`.
      - `event_attending` SELECT: the attendee, the inviter, or the event owner. INSERT/UPDATE:
        the acting user for their own RSVP; invites via `invite_user_to_event` RPC.
- [ ] **RPC functions to (re)build:**
      - `update_event_location(p_event_id, p_lat text, p_lon text)` — cast strings, set geo
        `location`; validate caller is event owner.
      - `update_event_attendee_count(p_event_id)` — set `attendee_count = count(*) where
        event_id=p AND is_attending=true`. `SECURITY DEFINER` acceptable (recompute only); validate.
      - `invite_user_to_event(p_event_id, p_attending_id)` — upsert `event_attending` invite;
        validate caller can invite; optionally enqueue notification.
      - Recommended new RPCs: `create_event`, `update_event`, `delete_event` (soft),
        `rsvp_event(p_event_id, p_attending bool)` to move client DML server-side per §6.
- [ ] **Storage:** bucket `event` (public read for cover images), path convention `<event_id>/…`.
      Policies: authenticated users may upload to their own event's folder; owner may delete.
- [ ] **Triggers / cron:** optional trigger to keep `attendee_count` in sync on
      `event_attending` insert/update instead of relying on the client calling the RPC; optional
      cron/trigger to flip `event_status` when `end_date_time` passes (frontend uses time-based
      filtering, not a status field, so this is optional).
- [ ] **Enum:** `event_status` values `active` / `removed` / `suspended` (frontend `Status` enum).

## 8. Open questions & risks
1. **`event_status` on create:** insert does NOT set `event_status`, but the column is
   non-nullable in the Row class and delete sets `'removed'`. Needs a DB default (likely
   `'active'`) or the create RPC must set it.
2. **`attendee_count` consistency:** creator auto-attend insert and the list/button RSVP toggles
   do NOT all call `update_event_attendee_count` — only event_details does after each toggle.
   Count can drift. Prefer a DB trigger on `event_attending` to maintain it authoritatively.
3. **`location` vs `Address` vs `latitude`/`logitude`:** three location representations. `location`
   is only written by `update_event_location` (geo type?). Confirm exact type (PostGIS geography
   vs text) and that `p_lat`/`p_lon` arrive as strings needing cast.
4. **My-created-events query has no `admin_user` filter** (my_event line ~636) — as written it
   returns all upcoming community events, not just the current user's. Confirm whether this is a
   frontend bug or whether an outer scope/`admin_user` filter exists that wasn't captured.
5. **Ending-soon list has no `community_id` filter** while latest does — confirm intended scope
   (all communities vs current).
6. **Invite duplication:** invite flow inserts a new `event_attending` row when none exists but
   RPC-updates when one exists; without a unique `(event_id, attending_id)` constraint, duplicate
   attendee rows are possible.
7. **Invite notifications:** no explicit OneSignal call in events widgets — confirm whether
   `invite_user_to_event` (or a trigger) must create a notification for the invitee.
8. **Direct client DML vs CLAUDE.md §6:** the frontend performs raw `.insert/.update` on
   `event_page`/`event_attending`. The rebuild should move these behind validated RPCs while
   keeping the same observable behavior, since the frontend is the locked contract.
9. **`event_type` is a plain text 'Online'/'Offline'** from a radio button, not a DB enum —
   decide whether to constrain with a CHECK/enum.

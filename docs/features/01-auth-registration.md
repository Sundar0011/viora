# Feature: Authentication & Registration

> Source of truth = the Flutter frontend. This doc records what the backend MUST provide
> for this feature to work. Derived from `lib/` — do not invent behavior the code doesn't show.

## 1. Overview
- **What it is:** Sign-up, sign-in, and account recovery for Viora. Supports **email/password**,
  **phone number + OTP**, and **Google Sign-In**. Includes email/phone OTP verification, forgot/reset
  password, change password, and an onboarding step that captures the user's neighbourhood location.
- **Why it exists / user value:** Creates the authenticated user identity every other feature depends
  on (community membership, marketplace, posts), and places the user in the correct neighbourhood.
- **Platforms:** Must work on **BOTH Android and iOS** (plus Web has a separate Google OAuth path).
  Google native flow uses platform-specific client IDs; FCM/device capture branches on `Platform.isAndroid`
  / `Platform.isIOS`.
- **Related features:** neighbourhood/community placement, push notifications (FCM/OneSignal device
  registration), public profile.

> **NOTE (Apple Sign-In):** CLAUDE.md §2 lists Apple Sign-In as a provider, and an `AppleSignInManager`
> mixin *is declared* in `lib/auth/auth_manager.dart`. However `SupabaseAuthManager`
> (`lib/auth/supabase_auth/supabase_auth_manager.dart`) mixes in **only** `EmailSignInManager` and
> `GoogleSignInManager`. **No Apple sign-in is actually wired into any registration/login screen.**
> See §8. The backend still must be Apple-ready per §2, but the frontend contract for Apple is absent today.

## 2. Screens & widgets
| Screen / widget (path under `lib/`) | Purpose | Key actions |
|---|---|---|
| `pages/registration/splash/` | App entry / splash | Routes to login/onboarding |
| `pages/registration/login_page/` | Main landing (login options) | Email login link, phone login (`VaildateUser` + `signInWithPhone`), **Google sign-in** (create user rows if new) |
| `pages/registration/email_login_page/` | Email + password login | `VaildateUser` → `signInWithEmail` |
| `pages/registration/create_account_page/` | Start account creation | **Google sign-in** (create user rows if new), routes to email/phone signup |
| `pages/registration/final_steps_mail_page/` | Collect email + password (email signup) | `CheckUserExist` (email), then `SendOtp` (email) → verify |
| `pages/registration/final_steps_phone_page/` | Collect phone + password (phone signup) | `CheckUserExist` (mobile), then `SendOtp` (mobile) → verify |
| `pages/registration/verify_page/` | OTP entry (email or mobile) | `VerifiOtp`; on success runs the full signup: `signUpWithEmail`/`PhoneSignup`+`signInWithPhone`, inserts `user`/`user_roles`/`public_user_profile`, `update_user_location`, FCM. Also resend via `SendOtp`. Handles `verifyType == 'ForgetPassword'` branch → reset password. |
| `pages/registration/forget_password/` | Start password recovery | `CheckUser` (must exist) → `SendOtp` (email or mobile) → verify |
| `pages/registration/comp_forget_password/` | Forgot-password component | recovery entry UI |
| `pages/registration/reset_password/` | Set a new password after OTP | `ResetPassword` (email or phone branch) |
| `pages/registration/location_page/` | Onboarding location (google/phone paths) | `userLocation()` action → `update_user_location` (`create`) → update `user` + `public_user_profile` |
| `pages/registration/comp_neighbour_location/` | Location search/confirm | `ShowSuggestions` + `GetPlaceDetails` (Google), `update_user_location`, updates `user` + `public_user_profile` |
| `components/comp_location_permission_widget.dart` | Location permission sheet | `userLocation()` → `update_user_location` (`update`) → update `public_user_profile`, fetch neighbours |
| `pages/registration/dummy/` | Isolated Google sign-in test | `authManager.signInWithGoogle` |
| `auth/supabase_auth/supabase_auth_manager.dart` | Auth manager | signIn/create email, Google, signOut, deleteUser, updateEmail, updatePassword, resetPassword |
| `auth/supabase_auth/email_auth.dart` | Email auth funcs | `signInWithPassword`, `signUp` |
| `auth/supabase_auth/google_auth.dart` | Google auth func | web `signInWithOAuth`; native `GoogleSignIn` → `signInWithIdToken` |
| `custom_code/actions/sign_in_with_email.dart` / `sign_in_with_phone.dart` / `sign_up_with_email.dart` | Direct Supabase auth calls | `signInWithPassword` / `signUp` |
| `custom_code/actions/update_google_profile_data.dart` | Populate name/avatar from Google metadata | reads `auth.currentUser.userMetadata` |
| `custom_code/actions/set_f_c_m_token_and_update_database.dart` | Register device for push | `upsert_user_device_fcm` RPC |
| `custom_code/actions/user_location.dart` | Device GPS + reverse geocode | Geolocator + geocoding → app state |

## 3. Data model (tables & columns)
Types + nullability taken from the FlutterFlow Row classes under
`lib/backend/supabase/database/tables/`.

### `user`
- **Purpose:** Core private user record (identity + home address + onboarding state). `id` equals the
  Supabase Auth user id (`auth.uid()` / `currentUserUid`).
- **Columns:**
  | Column | Type | Null? | Notes (PK/FK/default/enum) |
  |---|---|---|---|
  | `id` | uuid/text (String) | no | **PK**, = `auth.users.id` |
  | `created_at` | timestamptz | no | default `now()` |
  | `first_name` | text | yes | |
  | `last_name` | text | yes | |
  | `email` | text | yes | |
  | `mobile_number` | text | yes | national number (no CC) |
  | `mobile_number_cc` | text | yes | set to `"{countryCode}{mobile}"` on phone signup |
  | `address` | text | yes | |
  | `city` | text | yes | |
  | `flat` | text | yes | |
  | `postal_code` | text | yes | |
  | `blocked` | bool | yes | |
  | `onboarding_completed` | bool | yes | set `true` on email/phone signup insert |
  | `is_deleted` | bool | yes | soft-delete flag |
  | `reason` | text | yes | |
  | `IsOwner` | bool | yes | **column name is literally `IsOwner`** (PascalCase — not snake_case) |
  | `last_signin_at` | timestamptz | yes | |
  | `status` | text | yes | |
- **Foreign keys / relationships:** `id` → `auth.users.id` (on delete cascade). 1:1 with `public_user_profile`,
  `user_roles` (both keyed by same user id).
- **Indexes needed:** PK on `id`; consider indexes on `email`, `mobile_number_cc` (lookup/uniqueness).

### `user_roles`
- **Purpose:** The user's role within a community. Written at signup with `role='customer'`, `community_id=1`.
- **Columns:**
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid/text (String) | no | **PK**, inserted as `currentUserUid` → serves as the user id / FK to `user` |
  | `created_at` | timestamptz | no | default `now()` |
  | `role` | text | no | e.g. `'customer'` (hardcoded at signup) |
  | `community_id` | int (int4) | no | hardcoded `1` at signup |
- **Foreign keys:** `id` → `user.id`; `community_id` → community table (not in this feature's Row set).
- **Indexes needed:** PK on `id`; index `community_id`; index `role` if filtered. This is the table
  CLAUDE.md §6.7 references for the JWT role claim (custom access token hook reads role from here).

### `public_user_profile`
- **Purpose:** Public-facing profile (name, avatar, city, counters). Inserted at signup, updated on location step.
- **Columns:**
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid/text (String) | no | **PK**, = user id / FK to `user` |
  | `created_at` | timestamptz | no | default `now()` |
  | `name` | text | yes | set to `"{first} {last}"` |
  | `profile_picture` | text | yes | URL |
  | `city` | text | yes | |
  | `last_seen_date` | timestamptz | yes | |
  | `community_id` | int (int4) | no | hardcoded `1` at signup |
  | `country` | text | yes | |
  | `followers` | int (int4) | no | default `0` |
  | `following` | int (int4) | no | default `0` |
  | `logout_time` | time (PostgresTime) | yes | Postgres `time` type |
  | `cover_image` | text | yes | |
  | `bio` | text | yes | |
  | `gender` | text | yes | |
  | `pronouns` | text | yes | |
  | `post_count` | int (int4) | no | default `0` |
  | `group_count` | int (int4) | no | default `0` |
  | `event_count` | int (int4) | no | default `0` |
  | `sale_count` | int (int4) | no | default `0` |
- **Foreign keys:** `id` → `user.id`; `community_id` → community.
- **Indexes needed:** PK on `id`; index `community_id`, `city`.

### `user_login`
- **Purpose:** OTP store / rate-limit ledger for email & phone verification (backing table for the
  `send-otp` / `verify_otp` / `reset-password` edge functions). Not written directly by the client — the
  edge functions own it.
- **Columns:**
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid/text (String) | no | **PK** |
  | `created_at` | timestamptz | no | default `now()` |
  | `mobile_no_cc` | text | yes | phone (with CC) the OTP was sent to |
  | `email` | text | yes | email the OTP was sent to |
  | `otp` | text | no | the code |
  | `expiry_date` | timestamptz | no | OTP expiry |
  | `no_of_times` | double (float8/numeric) | no | resend/attempt counter (rate limit) |
  | `last_requested_date` | timestamptz | no | last send time (rate limit window) |
- **Foreign keys:** none evident (identifier-keyed by email/mobile).
- **Indexes needed:** PK on `id`; index `email`, `mobile_no_cc` (lookups by identifier).

### `user_devices`
- **Purpose:** Registered push devices per user (FCM token). Written via `upsert_user_device_fcm` RPC
  after signup / on token refresh.
- **Columns:**
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid/text (String) | no | **PK** |
  | `created_at` | timestamptz | no | default `now()` |
  | `user_id` | uuid/text (String) | no | **FK** → `user.id` (= `auth.uid()`) |
  | `device_id` | text | no | Android `androidInfo.id`; iOS `identifierForVendor` |
  | `fcm_token` | text | no | Firebase Messaging token |
- **Foreign keys:** `user_id` → `user.id`.
- **Indexes needed:** PK on `id`; index `user_id`; **unique (`user_id`, `device_id`)** to support the upsert.

### `user_locations`
- **Purpose:** Stores the user's neighbourhood point/geography. Written via the `update_user_location`
  RPC (not by the client `insert` directly in the main flow).
- **Columns:**
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid/text (String) | no | **PK** |
  | `created_at` | timestamptz | no | default `now()` |
  | `location` | text (serialized) | no | serialized geometry/geography (PostGIS) — RPC builds from lat/lon |
  | `place` | text | yes | |
  | `name` | text | yes | |
  | `latitude` | double (float8) | yes | |
  | `longitude` | double (float8) | yes | |
- **Foreign keys:** No `user_id` column is present in the Row class — the owning user is inferred inside
  the `update_user_location` RPC from `auth.uid()`. **Confirm the real table has a user FK** (see §8).
- **Indexes needed:** PK on `id`; spatial (GiST) index on `location`; FK index on the owner column.

## 4. Backend calls (API / RPC / Edge)
> All calls in the current code target Supabase project **`wgcqstmmkcdjnnpuvspr`** (the legacy FlutterFlow
> project). The rebuild targets Viora's OWN project — every URL/ref below must be re-pointed (§6, §8).
> `anonKey` = `FFDevEnvironmentValues().AnonKey`; `token` = `currentJwtToken` (user JWT).

### Edge functions (`/functions/v1/...`, header `Authorization: Bearer <anonKey>`)
| Call | Type | Endpoint | Inputs (body) | Returns | Called from |
|---|---|---|---|---|---|
| `SendOtpCall` | Edge POST | `/functions/v1/send-otp` | `{ mobile_no_cc, email }` | `{ error? }` | final_steps_mail/phone, forget_password, verify_page (resend) |
| `VerifiOtpCall` | Edge POST | `/functions/v1/verify_otp` | `{ otp, email, mobile_no_cc }` | `succeeded`; `{ error? }` | verify_page |
| `VaildateUserCall` | Edge POST | `/functions/v1/authenticate-user` | `{ identifier, password }` | `{ error? }` | email_login_page, login_page (pre-signIn validation) |
| `CheckUserExistCall` | Edge POST | `/functions/v1/check-user-exist` | `{ email, mobile_number }` | `{ email_exists: bool, mobile_number_exists: bool }` | final_steps_mail/phone (block duplicate signup) |
| `CheckUserCall` | Edge POST | `/functions/v1/check-user` | `{ email, mobile_number }` | `{ exists: bool }` | forget_password (must exist to recover) |
| `ResetPasswordCall` | Edge POST | `/functions/v1/reset-password` | `{ phone, email, otp, new_password }` | (success/error) | reset_password (email vs phone branch) |
| `ChangePasswordCall` | Edge POST | `/functions/v1/change-password` | header `Bearer <userJWT>`; `{ old_password, new_password }` | (success/error) | profile/change-password (outside this doc's screens; uses JWT) |
| `PhoneSignupCall` | Edge POST | `/functions/v1/phone-signup` | headers `Bearer <anonKey>` + **`x-secret-key: <secretKey>`**; `{ phone, password, confirmPassword }` | (success/error) | verify_page (phone signup) — creates the phone auth user |

### RPC (`/rest/v1/rpc/...`, headers `apikey: <anonKey>` + `Authorization: Bearer <token>`)
| Call | Endpoint | Inputs | Returns | Called from |
|---|---|---|---|---|
| `InsertUserLocationCall` | `/rest/v1/rpc/update_user_location` | `{ lat, lon, place_name, p_type }` where `p_type ∈ {'create','update'}` | (row/void) | verify_page, location_page, comp_neighbour_location, comp_location_permission |
| `upsert_user_device_fcm` (raw `http.post` in `setFCMTokenAndUpdateDatabase`) | `/rest/v1/rpc/upsert_user_device_fcm` | `{ p_device_id, p_fcm_token }` | `{ error? }` / row | after every signup + Google account creation |

### Direct REST / client DML (supabase_flutter)
| Call | Type | Target | Notes | Called from |
|---|---|---|---|---|
| `UserTable().insert({...})` | client insert | `user` | first_name,last_name,email/mobile,address,city,flat,postal_code,id,onboarding_completed | verify_page (email+phone), google (create) |
| `UserRolesTable().insert({...})` | client insert | `user_roles` | `{id, role:'customer', community_id:1}` | verify_page, google |
| `PublicUserProfileTable().insert({...})` | client insert | `public_user_profile` | name, profile_picture, city, community_id:1, country, cover_image | verify_page, google |
| `UserTable().update(...)` / `queryRows(...)` | client update/select | `user` | onboarding location update; existence check by `id` | location_page, comp_neighbour_location, google (queryRows) |
| `PublicUserProfileTable().update(...)` | client update | `public_user_profile` | city/country on location step | location_page, comp_neighbour_location, comp_location_permission |
| `AddUserLocationCall` | REST POST `/rest/v1/user_locations` | `user_locations` | body `{id, location}` — **appears unused** in the auth flows (RPC path is used instead) | (defined, not called in registration) |
| Supabase Auth `signUp(email,password)` | GoTrue | — | via `emailCreateAccountFunc` / `signUpWithEmail` action | email signup |
| Supabase Auth `signInWithPassword(email\|phone, password)` | GoTrue | — | `signInWithEmail` / `signInWithPhone` actions | login, post-phone-signup |
| Supabase Auth `signInWithIdToken(google, idToken, accessToken)` | GoTrue | — | native Google | login/create |
| Supabase Auth `signInWithOAuth(google)` | GoTrue | — | **Web** Google path | login/create (web) |
| Supabase Auth `resetPasswordForEmail`, `updatePassword`, `updateEmail`, `signOut`, `currentUser.delete()` | GoTrue | — | auth manager | account mgmt |

### External (Google Maps — not Supabase; header-less, `key` = Google Places API key)
| Call | Type | Endpoint | Inputs | Returns |
|---|---|---|---|---|
| `ShowSuggestionsCall` | GET | `maps/api/place/autocomplete/json` | `input`, `key` | `predictions[].description`, `predictions[].place_id` |
| `GetPlaceDetailsCall` | GET | `maps/api/place/details/json` | `place_id`, `key`, `fields=address_components,geometry` | `latitude`, `longitude`, `city` (locality), `country` |

## 5. Business rules & flows

### A. Email signup
1. `final_steps_mail_page`: user enters email + password + confirm. Client checks passwords match.
2. `CheckUserExist(email)` — if `email_exists == true`, block with "user exists" error.
3. Store `AsEmail`/`AsPassword` in app state → `SendOtp(email)` → navigate to `verify_page`
   (`verifiedByEmailOrMobile='email'`, `verifyType='signup'`).
4. `verify_page`: `VerifiOtp(email, otp)`. On success (`succeeded`):
   - `signUpWithEmail(email, password, confirmPassword)` (GoTrue `signUp`), wait ~3s for session.
   - Insert `user` (id=`currentUserUid`, onboarding_completed=true, name/address fields from app state).
   - Insert `user_roles` (role='customer', community_id=1).
   - Insert `public_user_profile` (name, avatar, city, community_id=1, country, cover_image).
   - `update_user_location(p_type='create')` with lat/lng/place from app state.
   - `setFCMTokenAndUpdateDatabase` → `upsert_user_device_fcm`.
   - Clear password from app state; go to Loading page.

### B. Phone signup
1. `final_steps_phone_page`: phone + password. `CheckUserExist(mobile_number)`; block if exists.
2. `SendOtp(mobile_no_cc)` → `verify_page` (`verifiedByEmailOrMobile != 'email'`).
3. `VerifiOtp(mobile_no_cc, otp)`. On success:
   - `PhoneSignup({phone, password, confirmPassword})` **(edge function, requires `x-secret-key`)** creates
     the phone auth user, wait ~1s.
   - `signInWithPhone(phone, password)` (GoTrue `signInWithPassword`), wait ~3s for session.
   - Insert `user` (includes `mobile_number`, `mobile_number_cc="{cc}{mobile}"`, onboarding_completed=true).
   - Insert `user_roles`, `public_user_profile` (no email).
   - `update_user_location(p_type='create')`, FCM upsert, go to Loading page.

### C. Google sign-in (create-or-continue) — `login_page`, `create_account_page`, `dummy`
1. `authManager.signInWithGoogle` (native: GoogleSignIn → `signInWithIdToken`; web: `signInWithOAuth`).
   Native uses platform client IDs: iOS `clientId` set, Android `clientId=null`, shared `serverClientId`.
2. `queryRows(user where id==currentUserUid)`. If none (new user):
   - `updateGoogleProfileData()` pulls given/family name + avatar from `auth.currentUser.userMetadata`.
   - Insert `user` (first_name,last_name,email=`currentUserEmail`,id) — **no onboarding_completed set here**.
   - Insert `user_roles` (customer, community 1), `public_user_profile`, FCM upsert.
   - Navigate to `LocationPageWidget` with `pageName='google'` (forces onboarding location).
3. If user row already exists → go straight to Loading page.

### D. Email / phone login
- `email_login_page`: `VaildateUser({identifier, password})` (edge) → if ok `signInWithEmail`.
- `login_page` (phone): `VaildateUser` → `signInWithPhone`.

### E. Forgot / reset password
1. `forget_password`: `CheckUser({email|mobile_number})` — must exist. Then `SendOtp` for that identifier.
2. `verify_page` with `verifyType='ForgetPassword'` → `VerifiOtp`. On success routes to `reset_password`
   passing `emailOrMobileNumber` + `isMobile`.
3. `reset_password`: new password must equal confirm. If `isMobile` → `ResetPassword({phone, otp, new_password})`
   else `ResetPassword({email, otp, new_password})`. Then go to login.

### F. Onboarding location (`location_page`, `comp_neighbour_location`, `comp_location_permission`)
- `userLocation()` requests OS location permission (Geolocator), gets GPS, reverse-geocodes to
  address/city/flat/postal/country into app state.
- `update_user_location(p_type='create')` (first time) or `'update'` (later); then `user`/`public_user_profile`
  updated with city/country/address.
- Manual search path: `ShowSuggestions` (autocomplete) → `GetPlaceDetails` (lat/lng/city/country) →
  `update_user_location`.
- OTP resend on `verify_page` re-calls `SendOtp` (email or mobile branch).

### Cross-cutting rules
- `checkInternetConnect()` gates most submit buttons (offline → blocked).
- `community_id` is hardcoded to **1** and `role` to **'customer'** at signup (single default community).
- `onboarding_completed=true` is set for email & phone signup at insert; Google users complete onboarding
  on the location step (their `user` insert does not set it — see §8).
- Signup relies on fixed `Future.delayed` waits (1–3s) for the auth session to settle before inserting rows.

## 6. Realtime / notifications
- **Push:** After every account creation, `setFCMTokenAndUpdateDatabase` requests notification permission
  (Firebase Messaging), reads the FCM token + device id (Android `androidInfo.id`, iOS `identifierForVendor`),
  and calls `upsert_user_device_fcm` to persist to `user_devices`. OneSignal is also used elsewhere but not
  in the auth insert path shown here.
- **Realtime:** No realtime channels are used by the auth/registration flow itself.

## 7. Backend to build (Supabase rebuild checklist)
Concrete, actionable — must comply with CLAUDE.md §6 (RLS mandatory, admin-only writes by default,
user writes via validated RPC, SECURITY DEFINER hardening, JWT role claim).

- [ ] **Tables:** `user`, `user_roles`, `public_user_profile`, `user_login`, `user_devices`,
      `user_locations` with columns/types/nullability exactly as §3. Add `updated_at` where the
      frontend updates rows (`user`, `public_user_profile`). Keep the odd `IsOwner` column name (frontend
      reads `getField<bool>('IsOwner')`) — do not rename without a frontend change.
- [ ] **FKs + indexes:** `user.id`→`auth.users.id` (cascade); `user_roles.id`,`public_user_profile.id`,
      `user_devices.user_id`→`user.id`; index every FK; unique(`user_devices.user_id`,`device_id`);
      GiST index on `user_locations.location`; index `user_login(email)`, `user_login(mobile_no_cc)`;
      index `public_user_profile(community_id)`.
- [ ] **RLS intent:**
      - `user`: SELECT own row (+ admin); INSERT/UPDATE own row **via RPC/edge only** (self-service signup);
        DELETE admin-only (soft-delete `is_deleted` via RPC).
      - `public_user_profile`: SELECT authenticated (public within community); writes own row via RPC/admin.
      - `user_roles`: SELECT own (+ admin); INSERT/UPDATE **admin/RPC only** — this drives the JWT role claim.
      - `user_login`: **no client access** — edge-function/service-role only (deny all to `anon`/`authenticated`).
      - `user_devices`: SELECT/UPSERT own rows via the `upsert_user_device_fcm` RPC only.
      - `user_locations`: SELECT own/neighbourhood; write own via `update_user_location` RPC only.
      > NOTE: the current code performs **direct client `insert`/`update`** on `user`, `user_roles`,
      > `public_user_profile`. Per §6.6 these must move behind RPCs, OR RLS must permit exactly the self-row
      > insert/update the client performs. Decide during RLS drafting (`docs/rls-policies-draft.md`).
- [ ] **RPC / PL-pgSQL:**
      - `update_user_location(lat, lon, place_name, p_type)` — SECURITY DEFINER, validate `auth.uid()`,
        build geography from lat/lon, insert (`create`) or update (`update`) the caller's location row,
        set `search_path`, revoke from public / grant to `authenticated`.
      - `upsert_user_device_fcm(p_device_id, p_fcm_token)` — SECURITY DEFINER, upsert on
        (`auth.uid()`, `device_id`).
      - Consider RPCs to replace direct client inserts for `user`/`user_roles`/`public_user_profile`.
      - `custom_access_token_hook` — inject `user_roles.role` into `app_metadata` (CLAUDE.md §6.7).
- [ ] **Edge functions (secrets server-side only):** `send-otp`, `verify_otp`, `authenticate-user`,
      `check-user-exist`, `check-user`, `reset-password`, `change-password`, `phone-signup`.
      - `send-otp`/`verify_otp`/`reset-password` read+write `user_login` (rate-limit via `no_of_times`,
        `last_requested_date`, `expiry_date`) and integrate the SMS/email OTP provider.
      - `phone-signup` and `change-password`/`authenticate-user` need the **service-role key**
        (create auth users / verify credentials) — keep it in edge env, never in client.
      - Replace the client `x-secret-key` scheme (see §8) with a server-side secret per CLAUDE.md §6.5.
- [ ] **Storage:** none required for auth itself (avatar/cover images referenced as URLs; bucket policies
      belong to the profile feature).
- [ ] **Triggers / cron:** optional cron to purge expired `user_login` OTP rows; trigger to maintain
      `updated_at`.
- [ ] **Auth providers:** enable Email, Phone (OTP/SMS provider), Google (with the app's client IDs), and
      **Apple** (required by §2 even though the frontend isn't wired yet).

## 8. Open questions & risks
1. **Wrong project ref:** all URLs point to `wgcqstmmkcdjnnpuvspr` (legacy FlutterFlow project). Viora's own
   project ref must replace it everywhere; confirm before any MCP write (CLAUDE.md §6).
2. **Apple Sign-In not implemented:** `AppleSignInManager` mixin exists but isn't mixed into
   `SupabaseAuthManager`, and no screen calls it. Is Apple in-scope for this rebuild's frontend, or backend-ready
   only? (Apple is App Store-required for iOS social login.)
3. **Client-side secret (`x-secret-key`) in `PhoneSignupCall`:** `FFDevEnvironmentValues().secretKey` is read
   on the client and sent as a header. This is a client-exposed secret (related to the `sk_live_...` issue in
   CLAUDE.md §5). Must be redesigned so the secret lives server-side only.
4. **Direct client writes vs §6.6:** signup inserts `user`/`user_roles`/`public_user_profile` directly from the
   client. Confirm whether to (a) move these into a single `signup_finalize` RPC, or (b) allow tightly-scoped
   self-row RLS. Recommend (a) for consistency + audit.
5. **`user_locations` has no `user_id` in the Row class.** The owning user must be resolved inside
   `update_user_location` from `auth.uid()`. Confirm the real table's owner column name and FK.
6. **`location` column type:** stored/read as `String` in the Row class but is almost certainly PostGIS
   geography/geometry serialized to text. Confirm exact type and SRID for the RPC.
7. **Google user `onboarding_completed`:** email/phone signups set it `true`; the Google `user` insert does not
   set it. Confirm the intended default and whether the location step should set it.
8. **Timing hacks:** flows rely on `Future.delayed(1–3s)` to wait for the auth session before inserting rows.
   A server-side RPC/edge finalize would remove this race; confirm acceptable.
9. **OTP contract details unknown:** exact response shapes, expiry window, and resend rate-limit thresholds live
   inside the edge functions (not in the frontend). Must be re-specified when rebuilding `send-otp`/`verify_otp`.
10. **`authenticate-user` (`VaildateUser`) purpose:** the client validates credentials via edge function *then*
    calls GoTrue `signInWithPassword` separately. Confirm why (pre-flight error messaging?) and whether the
    rebuild keeps this two-step pattern or folds it into a single sign-in.
11. **`user_roles.id` doubles as the user id** (insert uses `id: currentUserUid`). Confirm there is no separate
    `user_id`/PK split intended, and that a user has exactly one role row per community.
12. **`AddUserLocationCall`** (`POST /rest/v1/user_locations`, body `{id, location}`) is defined but not called
    in the registration flows — confirm it is dead code or used elsewhere before relying on the RPC path only.

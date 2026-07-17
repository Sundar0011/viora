# Viora — Project Rules & Context

## What this project is
Viora is a location-based neighborhood social network + local marketplace (Nextdoor-style)
mobile app. Flutter project name: `squa_d_d`, version 2.0.5. Runs on Android, iOS, and Web.
Built with FlutterFlow (code is FlutterFlow-generated: `_model.dart` + `_widget.dart` pairs).

## Current work
**Reworking the backend fully from scratch on Supabase.** The Flutter frontend is considered
DONE and correct — the backend must be built to match exactly what the frontend expects.
The source of truth for the schema is the frontend code under `lib/backend/supabase/`.

## Tech stack
- Frontend: Flutter (Dart SDK >=3.0), FlutterFlow-generated. **Do not restructure frontend.**
- Backend: **Supabase** (Postgres + Auth + Storage + Realtime + Edge Functions).
- Auth providers: Email/password, Google Sign-In, Apple Sign-In.
- Push notifications: OneSignal + Firebase Messaging.
- Cloud functions: Firebase Functions (Node.js) — under `firebase/functions/`.
- Maps/location: Google Maps + Geolocator.

## Backend rules (Supabase)
- **RLS is mandatory.** Every table must have Row Level Security enabled with explicit policies.
  Default to deny; grant the minimum each screen actually needs.
- **No secrets in the client.** Never put service-role keys or any `sk_*` / `sk_live_*` secret
  in `assets/`, `lib/`, or any bundled file. Only the Supabase **anon** key belongs in the client.
  Secrets go in Edge Functions / server environment only.
- Table & column names: **snake_case**.
- Every table has `id` (uuid or bigint PK), `created_at timestamptz default now()`, and
  `updated_at timestamptz` where the frontend expects it.
- Foreign keys must be real FK constraints with sensible `on delete` behavior.
- Add indexes on all foreign-key columns and on columns used for filtering/sorting.
- Keep changes as ordered SQL migration files so the whole backend can be rebuilt from zero.
- Match column names/types to the frontend Row classes EXACTLY — the app will break otherwise.

## Working style
- The frontend Row/table definitions are the contract. When unsure about a column, check
  the matching file in `lib/backend/supabase/database/tables/`.
- Explain changes in plain language; the maintainer prefers clear, practical guidance.
- Flag anything security-sensitive immediately.

## Known issues to fix
- `assets/environment_values/environment.json` currently contains a `sk_live_...` secret key
  bundled in the client. This must be removed and rotated; move any real secret server-side.

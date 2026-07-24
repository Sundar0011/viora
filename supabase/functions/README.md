# Viora Edge Functions — Auth & Utility (Batch: auth/registration)

Files-only authoring. The main thread reviews and deploys via Supabase MCP against Viora's own
project. Source of truth for every request/response contract is the Flutter frontend
(`lib/backend/api_requests/api_calls.dart` + the registration/profile widgets) and
`docs/features/01-auth-registration.md`.

Stakeholder direction (2026-07-19): **password-only auth for now** — no SMS, no email OTP,
skip TL;DR. The password path is built for real; every delivery/AI-dependent function is an
honest, clearly-documented deferred stub that never fake-succeeds a security step and never
leaks a code.

## Function summary

| # | Function | Folder / endpoint | Status | verify_jwt | Request | Success response |
|---|----------|-------------------|--------|-----------|---------|------------------|
| 1 | authenticate-user | `authenticate-user` → `/functions/v1/authenticate-user` | REAL | **false** | `{identifier, password}` | `200 {valid:true}` |
| 2 | check-user-exist | `check-user-exist` | REAL | **false** | `{email, mobile_number}` | `200 {email_exists, mobile_number_exists}` |
| 3 | check-user | `check-user` | REAL | **false** | `{email, mobile_number}` | `200 {exists}` |
| 4 | phone-signup | `phone-signup` | REAL (no OTP gate) | **false** | `{phone, password, confirmPassword}` | `200 {success:true, user_id}` |
| 5 | change-password | `change-password` | REAL | **true** | header `Bearer <userJWT>`; `{old_password, new_password}` | `200 {success:true}` |
| 6 | send-otp | `send-otp` | STUB (deferred) | false | `{mobile_no_cc, email}` | `503 {success:false, deferred:true, error}` |
| 7 | verify_otp | `verify_otp` (underscore!) | STUB (deferred) | false | `{otp, email, mobile_no_cc}` | `503 {success:false, deferred:true, error}` |
| 8 | reset-password | `reset-password` | STUB (deferred) | false | `{phone, email, otp, new_password}` | `503 {success:false, deferred:true, error}` |
| 9 | generate-tldr | `generate-tldr` | STUB (skipped) | false | `{comment_id, post_id, text}` | `200 {tldr:""}` |

Every non-2xx response from 1/4/5 carries a **non-null `error`** string, because the app
dereferences it with `!` (e.g. `VaildateUserCall.error(json)!`). Do not remove that field.

## Deploy notes (verify_jwt)

Supabase decides `verify_jwt` at deploy time (CLI `--no-verify-jwt` / `config.toml`). There is
no `config.toml` in this repo yet, so set it explicitly when deploying:

- Deploy with `--no-verify-jwt`: authenticate-user, check-user-exist, check-user, phone-signup,
  send-otp, verify_otp, reset-password, generate-tldr (all pre-auth or public no-ops).
- Deploy **without** `--no-verify-jwt` (platform validates the JWT): **change-password**
  (owner-only; the function also re-validates via `auth.getUser(token)` and derives the user id
  solely from the JWT — never from client input).

## Secrets / env

Auto-provided by Supabase to every function (NOT secrets you set):
`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`.

- **authenticate-user / change-password** use `SUPABASE_ANON_KEY` for the GoTrue password grant
  (credential verification) and `SUPABASE_SERVICE_ROLE_KEY` for admin ops.
- **check-user-exist / check-user / phone-signup** use `SUPABASE_SERVICE_ROLE_KEY`.
- The stubs need no secrets yet.

**No custom secrets are required for the current password-only build.**

### Secrets still needed for the deferred providers (NOT set today)

| Deferred capability | Function(s) | Secret to add later |
|---------------------|-------------|---------------------|
| SMS OTP delivery | send-otp, verify_otp, reset-password (phone) | e.g. `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_FROM` |
| Email OTP / recovery | send-otp, verify_otp, reset-password (email) | e.g. `RESEND_API_KEY` (or SMTP creds) |
| AI TL;DR | generate-tldr | e.g. `ANTHROPIC_API_KEY` / `OPENAI_API_KEY` |

## Known frontend/backend reconciliation items (flag to stakeholder)

1. **OTP-gated signup is blocked while OTP is deferred.** The frontend routes email signup,
   phone signup, and forgot-password through `send-otp` → `verify_page` → `verify_otp`, checking
   `.succeeded`. With those stubs returning 503, the user cannot complete those flows. Options:
   (a) enable a real provider, or (b) a frontend change to bypass the OTP step during the
   password-only phase. `phone-signup` itself works when called directly, but the current
   `verify_page` only reaches it after a successful `verify_otp`. **Password LOGIN and Google
   signup are fully functional.**
2. **Leaked `x-secret-key`** (docs §8.3): `phone-signup` deliberately ignores the client
   `x-secret-key` header. That secret must be rotated and the client must stop sending it.
3. **phone-signup creates the auth user with `phone_confirm: true` and no OTP gate** — intended
   for the password-only phase; restore the OTP gate when SMS is enabled.
4. **Existence checks query `public."user"`** (the app's identity table), not `auth.users`
   directly. Sufficient for the happy path; add a GoTrue admin lookup if strict auth-level
   de-duplication is required.

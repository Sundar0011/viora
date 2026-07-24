# Feature: <NAME>

> Source of truth = the Flutter frontend. This doc records what the backend MUST provide
> for this feature to work. Derived from `lib/` — do not invent behavior the code doesn't show.

## 1. Overview
- **What it is:** 1–3 sentences.
- **Why it exists / user value:**
- **Related features:** link to other `docs/features/*.md`.

## 2. Screens & widgets
| Screen / widget (path under `lib/`) | Purpose | Key actions |
|---|---|---|
| … | … | … |

## 3. Data model (tables & columns)
For every table this feature reads/writes. Column types + nullability come from the FlutterFlow
Row class (`lib/backend/supabase/database/tables/<t>.dart` — read the `getField`/`setField` types).

### `table_name`
- **Purpose:**
- **Columns:**
  | Column | Type | Null? | Notes (PK/FK/default/enum) |
  |---|---|---|---|
- **Foreign keys / relationships:**
- **Indexes needed:** (every FK + any filter/sort/join column)

## 4. Backend calls (API / RPC / Edge)
For each `…Call` class in `lib/backend/api_requests/api_calls.dart` used here, plus any
`.from(...)`, `.rpc(...)`, `.select/.insert/.update/.delete` in the pages.
| Call / query | Type (REST/RPC/Edge/direct) | Inputs | Returns | Called from |
|---|---|---|---|---|

## 5. Business rules & flows
Step-by-step user flows. Ownership checks, state machines, counters, soft-delete, limits, order.

## 6. Realtime / notifications
Live updates (channel + mode: Broadcast vs Postgres Changes), push (OneSignal), triggers.

## 7. Backend to build (Supabase rebuild checklist)
Concrete, actionable:
- [ ] Tables + columns + FKs + indexes
- [ ] RLS intent (who can SELECT/INSERT/UPDATE/DELETE) — admin-only writes by default, user
      writes via RPC
- [ ] RPC / PL-pgSQL functions (name, args, returns, SECURITY INVOKER/DEFINER, validation)
- [ ] Storage buckets + policies (images/receipts)
- [ ] Edge functions (secrets, external APIs)
- [ ] Triggers / cron

## 8. Open questions & risks
Anything ambiguous, any place the frontend implies backend behavior we must confirm.

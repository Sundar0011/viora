# CLAUDE.md — Viora Project Rules & Agent Protocol

This file is loaded into every Claude Code session for this project. It is the **rulebook**.

> Note: Viora is a **Flutter mobile app** (Android/iOS/Web), NOT a web app. Only backend,
> security, and workflow rules that apply to a Flutter + Supabase project are kept here.

---

## 1. What this project is
Viora is a location-based neighborhood social network + local marketplace (Nextdoor-style)
mobile app. Flutter project name: `squa_d_d`, version 2.0.5. Runs on Android, iOS, and Web.
Built with FlutterFlow (code is FlutterFlow-generated: `_model.dart` + `_widget.dart` pairs).

**Current work: reworking the backend fully from scratch on Supabase.** The Flutter frontend
is considered DONE and correct — the backend must be built to match what the frontend expects.
The source of truth for the schema is the frontend code under `lib/backend/supabase/`.

## 2. Tech stack (locked)
- **Target platforms: Android AND iOS.** Viora ships to both Android and iOS users — every
  feature, backend change, config, notification, auth flow, and deep link must work correctly
  on BOTH. Test/verify parity across Android and iOS; never implement something that only works
  on one platform.
- Frontend: **Flutter** (Dart SDK >=3.0), FlutterFlow-generated. **Do not restructure frontend.**
- Backend: **Supabase** (Postgres, Auth, RPC, Storage, Realtime, Edge Functions, Cron).
- Supabase changes go through **Supabase MCP** (once Viora's own project exists).
- Auth providers: Email/password, Google Sign-In, Apple Sign-In.
- Push notifications: OneSignal + Firebase Messaging.
- Firebase Functions (Node.js) under `firebase/functions/`.
- Do not introduce new libraries/dependencies without explicit approval.

---

## 3. Single source of truth (documentation-first)
- `docs/project.md` is the authoritative record of every feature, table, RPC, edge function,
  cron job, and RLS policy. (To be created as the backend is built.)
- **Doc-first rule:** the doc is updated **before** code is written. If doc and code disagree,
  the doc wins and the code is fixed.
- `docs/decisions.md` records every non-obvious decision (see §7).

## 4. Scope gate (run before ANY build)
Before writing code for a new feature, verify in order:
1. **Doc check** — is this feature in `docs/project.md`? If yes → update it; if no → add it first.
2. **Design check** — is the frontend/FlutterFlow screen already built for it? The existing
   Flutter widgets under `lib/pages/` and the Row classes under
   `lib/backend/supabase/database/tables/` define the contract. Match them exactly.
3. **Database check** — are required tables, columns, and RLS policies present? If missing →
   create them via Supabase MCP and record them in the doc.
4. **Implement** — only after 1, 2, 3 are green.

If anything is unclear, batch ALL questions and ask in one round before proceeding.
A symptom report ("this field doesn't save") is NOT authorization to build — confirm scope first.

---

## 5. Code standards
### Files & structure
- Files **under 400 lines**. Split when approaching the limit.
- Build reusable pieces first; assemble larger flows last.

### Comments (mandatory, simple)
- **Every file** starts with a short header: file name, purpose, brief description.
- **Every function** has a one-line comment explaining what it does. Keep them concise.

### Types
- Explicit types for API responses and Supabase rows. Avoid untyped `dynamic` where a real
  type is known; narrow instead.

### Environment & secrets (HARD RULE)
- **Never hardcode URLs, keys, or headers.** Never commit secrets.
- **Only the Supabase anon key** may live in the client (`assets/environment_values/`).
  Service-role keys and any `sk_*` / `sk_live_*` secret go server-side ONLY (Edge Functions /
  server env), never in `assets/` or `lib/`.
- **Known issue to fix:** `assets/environment_values/environment.json` currently contains a
  `sk_live_...` secret bundled in the client. It must be removed and rotated.

### Error handling
- Handle all Supabase errors in the data layer and return them in a consistent shape.
- Surface user-facing errors clearly. **Never silently swallow errors.**

### Testing
- Unit tests for utilities and helpers. Component/page tests only when explicitly requested
  or when a feature is critical.

### Flutter reference skills (MUST consult)
- For any Flutter/UI work, consult **`flutter-apply-architecture-best-practices`**,
  **`flutter-build-responsive-layout`**, and **`flutter-fix-layout-issues`**. Responsive layout
  applies to both Android and iOS per §2.

---

## 6. Supabase workflow & security model (HARD RULES)

### Target project
- Viora uses its **own dedicated Supabase project** (to be created — its ref goes here once it
  exists). Never target any project that is not Viora's own.
- Before any destructive op (`apply_migration`, `execute_sql`, `deploy_edge_function`, etc.),
  verify the project ref matches Viora's. If a tool result shows a different ref, STOP and surface it.
- All Supabase changes go through **Supabase MCP** — tables, RPC, edge functions, cron, RLS.

### Security model — applies to every table, RPC, and edge function
1. **RLS is mandatory on every `public.*` table.** Never disable it. Default to deny.
2. **Admin-only writes by default.** For important tables: `SELECT` gated by
   ownership / membership / admin; `INSERT`/`UPDATE`/`DELETE` **admin-only** via an
   `is_admin()`-style predicate. Non-admins cannot directly mutate rows.
3. **User-facing writes go through RPC functions, not direct DML.** When a normal user needs to
   insert/update/delete, expose a PL/pgSQL function that validates auth + business rules first.
4. **Prefer `SECURITY INVOKER`** (runs with caller privileges, respects their RLS). Use
   `SECURITY DEFINER` only when the function MUST bypass RLS, after in-function validation.
5. **Every `SECURITY DEFINER` function MUST:**
   - `SET search_path = public, pg_temp` (prevents search-path attacks).
   - Validate `auth.uid()` inside the function — never trust the caller.
   - Enforce business rules in PL/pgSQL (ownership, state checks, etc.).
   - For sensitive ops, require a server-side secret arg checked against
     `current_setting('app.<feature>_secret')` — secret lives in config, never in source.
   - `REVOKE ALL ... FROM PUBLIC` and `GRANT EXECUTE ... TO authenticated` (or `anon` only if
     truly intended).
   - Write to an `audit_log` if the action is auditable.
6. **No raw SQL writes from the client.** The app calls the data layer → Supabase → RPC.
   Direct `.from('table').insert(...)` from the client is forbidden for non-trivial tables.
7. **Role-based access uses JWT claims, not per-row DB lookups.** A Postgres Custom Access Token
   Hook (`public.custom_access_token_hook`) injects the user's role into `app_metadata`.
   Role predicates read from `auth.jwt() -> 'app_metadata' ->> 'role'`. (Viora's actual role set
   comes from its own `user_roles` table — define it during the rebuild.)
8. **Helper predicates live in `public.*`** with `SET search_path = public, pg_temp`, marked
   `STABLE` + `SECURITY INVOKER`. **Always wrap helper calls in RLS as `(SELECT helper())`** so
   the planner evaluates once per query, not per row (much faster).
9. **RLS policies are reviewed in a doc BEFORE being applied.** Write the policy set to
   `docs/rls-policies-draft.md`; user reviews; then apply via `apply_migration`.

### Schema & performance
- Every table: `id` PK, `created_at timestamptz default now()`, and `updated_at` where the
  frontend expects it. snake_case names. Real FK constraints with sensible `on delete`.
- **Index every foreign-key column**, and any column used for filtering / joining / ordering.
- Keep migrations short, ordered, and transactional so the backend can rebuild from zero.
- Match column names/types to the frontend Row classes EXACTLY — the app breaks otherwise.

### Reference skills (MUST consult)
- Before writing any non-trivial DDL, RLS policy, or RPC/edge function, consult
  **`supabase-postgres-best-practices`** and the **`supabase`** skill (security, RLS performance,
  privileges, FK indexes, constraints, composite indexes, short transactions).
- Key practice: wrap RLS helper calls as `(SELECT helper())`; index every FK; keep migrations
  short and transactional.

### Realtime
- Choose the mode deliberately and verify against official Supabase docs:
  - **Broadcast** for low-latency app events (notifications, live counts, chat activity).
  - **Postgres Changes** only when a DB row change must directly drive the UI, and there's a
    documented reason Broadcast isn't suitable.
- **All Broadcast channels must be private and authorized** with RLS on `realtime.messages`.
  Never expose privileged events to unauthorized clients.

> **Mental model:** RLS is the lockdown floor (deny all except admin). RPC functions are the
> keyed doors users walk through — each self-validates. SECURITY INVOKER is the default door;
> SECURITY DEFINER is the master-key door, reserved for narrow, validated cases.

---

## 7. Workflow rules
- **Do only what is asked.** No bonus features, refactors, or installs.
- **Ask all questions upfront** in a single batch — never one at a time.
- **Documentation-first**: doc → code, always. **No scope creep** — if a task seems incomplete,
  ask before expanding.
- **Decision logging (no silent decisions).** Any choice not already settled by scope/doc:
  1. **High-impact / hard-to-reverse / ambiguous** (scope, UX, data model, security) → **ASK first.**
  2. **Smaller implementation choice** → make it, then **record it in `docs/decisions.md`**
     (date, feature, decision, reason, alternatives, reversibility) and surface it in the summary.
  - When unsure which bucket, prefer to ask. The user must never be unaware of a decision that
    shaped the build.

---

## 8. Agent team (roster)
Work on Viora is done by a team of specialized agents (defined in `.claude/agents/`). The
main chat is the lead and orchestrates them.

| Agent | Role | Owns / edits |
|-------|------|--------------|
| **project-manager** | Plans features, runs the scope gate, routes work, verifies rules | plans, `docs/**` (via doc-keeper) |
| **backend-dev** | Supabase: tables, RLS, RPC, edge, cron, realtime, storage (via MCP) | `lib/backend/**`, `supabase/**`, MCP |
| **frontend-dev** | Flutter UI, widgets, state, navigation, wiring to backend | `lib/**` (frontend) |
| **ui-designer** | Design decisions: layout, color, type, spacing, motion, accessibility | design specs, `docs/**` |
| **doc-keeper** | Keeps `docs/project.md`, `docs/decisions.md`, RLS drafts accurate | `docs/**` only |
| **tester** | QA: unit tests, RPC/edge checks, RLS security checks, Android+iOS parity | `test/**`, reports |
| **security-reviewer** | Audits RLS, RPC/DEFINER functions, secrets, realtime auth before ship | reviews only (read-only) |
| **release-deployment** | Build/sign/publish to Google Play **and** Apple App Store | build config, CI, signing |

Slash commands (in `.claude/commands/`) drive the common flows: `/feature`, `/rls-audit`,
`/scope-check`, `/deploy`. Guardrail hooks (`.claude/settings.json` → `.claude/hooks/`) block
secret writes, block Supabase calls to non-Viora projects, auto-format Dart, and remind agents
to update their playbooks.

## 9. Skills per agent + continuous self-improvement (HARD RULE)
- **Common skills:** every agent follows all rules and skills referenced in this `CLAUDE.md`.
- **Own skill(s):** every agent additionally owns domain skill(s) — backend-dev →
  `supabase` + `supabase-postgres-best-practices`; frontend-dev → the three `flutter-*` skills;
  ui-designer → `ui-ux-pro-max`; others follow the common set.
- **Taste skills (added 2026-07-21, from `Leonxlnx/taste-skill`).** 13 skills are installed in
  `.claude/skills/`. **Most are web-oriented and Viora is Flutter mobile** — they are assigned
  selectively, not globally. Take their design judgement, never their HTML/CSS/GSAP output.
  - ui-designer → `imagegen-frontend-mobile` (primary), `brandkit`, `high-end-visual-design`,
    `redesign-existing-projects`, `design-taste-frontend`.
  - frontend-dev + backend-dev → `full-output-enforcement` (never truncate a generated file;
    an elided FlutterFlow widget or migration silently loses code).
  - Reference-only style packs, need approval before use: `minimalist-ui`,
    `industrial-brutalist-ui` (Flock's approved personality is *playful & social*).
  - **Not for this project:** `gpt-taste`, `imagegen-frontend-web`, `image-to-code`,
    `stitch-design-taste`, `design-taste-frontend-v1` — web/DOM-only.
- **Self-improving playbook:** every agent keeps a private playbook at
  `docs/agent-playbooks/<agent>.md`. The loop is mandatory on EVERY task:
  1. **START** — read your playbook + your skills + `CLAUDE.md`.
  2. **WORK** — follow them.
  3. **END** — append a **dated lesson**: what produced *good* output, what produced *bad*
     output, and the corrected approach. Supersede old lessons; never delete them.
  4. Over time the playbook becomes the agent's accumulated wisdom → outputs keep improving.
- **Do NOT edit the installed third-party skills** in `.claude/skills/` (they are upstream).
  Capture learnings in your playbook instead. When a lesson proves consistently better, the
  agent proposes promoting it into `CLAUDE.md` (via project-manager/doc-keeper) so the whole
  team benefits from it.

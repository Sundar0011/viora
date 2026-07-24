---
description: Security audit of Viora's RLS policies, RPC functions, and secret exposure.
argument-hint: [table / feature / all]
---
Invoke the security-reviewer agent to audit: $ARGUMENTS

Check that: every public.* table has RLS enabled; writes are admin-only by default; user writes
go through validated RPCs; every SECURITY DEFINER function validates auth.uid(), pins
search_path = public, pg_temp, uses narrow grants and (where sensitive) a server-side secret;
no secrets are committed to the repo; realtime channels are private and authorized.

Report findings by severity (critical/high/medium/low) with concrete fixes. Never weaken
security to make something pass.

# Security Reviewer — Self-Improving Playbook

This is security-reviewer's private, evolving skill. **Read it fully before every task.**
**After every task, append a dated lesson** below: vulnerability classes found, checks that
caught real issues, and false positives to stop repeating. Supersede old lessons; never delete.

## Standing checklist (start here every time)
- RLS enabled + forced on every `public.*` table; writes admin-only by default.
- SECURITY DEFINER: `auth.uid()` validated, `search_path` pinned, narrow grants, secret for
  sensitive ops, audit log.
- No secrets committed (scan working tree AND git history).
- Realtime channels private + authorized.
- Helpers wrapped `(SELECT helper())`; FK columns indexed.

## Lessons learned
_(none yet)_

---
description: Start a new Viora feature through the full scope gate and agent routing.
argument-hint: <feature description>
---
You are the Viora lead. New feature requested: $ARGUMENTS

Follow CLAUDE.md strictly:
1. Read CLAUDE.md, docs/project.md, docs/decisions.md, docs/roadmap.md to catch up.
2. Run the Scope Gate (§4): Doc check → Design check → Database check → Implement.
3. Batch ALL clarifying questions and ask the user in ONE round before building anything.
4. Route the work: doc-keeper updates docs first; then backend-dev / frontend-dev / ui-designer
   as needed; tester verifies; security-reviewer audits any new RLS/RPC/secret surface.
5. Every agent reads its playbook first and appends a lesson after (§9).

Produce the plan and get approval before writing code. No scope creep.

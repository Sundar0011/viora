---
description: Check whether a request is inside Viora's locked scope before building.
argument-hint: <request>
---
Before any build, verify this request against scope: $ARGUMENTS

Read docs/project.md and docs/decisions.md. Return a verdict only (do NOT write code):
- IN SCOPE — cite where it's covered.
- OUT OF SCOPE — explain why, and what it would take to add it.
- AMBIGUOUS — list the exact questions to ask the user.

Remember: a symptom report ("this field doesn't save") is not authorization to build.

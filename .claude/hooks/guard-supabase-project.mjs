#!/usr/bin/env node
// guard-supabase-project.mjs — PreToolUse guard.
// Ensures every Supabase MCP call targets Viora's OWN project only. Blocks known-unrelated
// projects always, and blocks any mismatch once Viora's ref is set in ../viora-project-ref.txt.
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

let raw = '';
try { raw = readFileSync(0, 'utf8'); } catch {}
let input = {};
try { input = JSON.parse(raw || '{}'); } catch {}

const toolName = input.tool_name || '';
if (!toolName.startsWith('mcp__supabase')) process.exit(0);

const ti = input.tool_input || {};
const projectId = ti.project_id || ti.project_ref || ti.ref || '';

// Refs we must NEVER touch (unrelated projects).
const DENY = new Set(['miajjjvmlgtdtunxsycv']);

// Viora's own ref (first non-comment line of viora-project-ref.txt), empty until set.
let allowed = '';
try {
  const here = dirname(fileURLToPath(import.meta.url));
  const file = readFileSync(join(here, '..', 'viora-project-ref.txt'), 'utf8');
  allowed = file.split(/\r?\n/).map((l) => l.trim()).find((l) => l && !l.startsWith('#')) || '';
} catch {}

if (projectId && DENY.has(projectId)) {
  console.error(`[supabase-guard] BLOCKED: project '${projectId}' is NOT Viora's project. Refusing (CLAUDE.md §6).`);
  process.exit(2);
}
if (allowed && projectId && projectId !== allowed) {
  console.error(`[supabase-guard] BLOCKED: call targets '${projectId}' but Viora's allowed project is '${allowed}' (CLAUDE.md §6).`);
  process.exit(2);
}
process.exit(0);

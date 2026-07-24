#!/usr/bin/env node
// block-secrets.mjs — PreToolUse guard.
// Refuses any Write/Edit whose NEW content introduces an obvious secret. Non-destructive:
// only inspects added content (never old_string), so removing a secret is always allowed.
import { readFileSync } from 'node:fs';

let raw = '';
try { raw = readFileSync(0, 'utf8'); } catch {}
let input = {};
try { input = JSON.parse(raw || '{}'); } catch {}

const ti = input.tool_input || {};
const text = [ti.content, ti.new_string].filter((x) => typeof x === 'string').join('\n');

const patterns = [
  { re: /sk_(?:live|test)_[A-Za-z0-9]{20,}/, name: 'secret key (sk_live/sk_test ...)' },
  { re: /-----BEGIN (?:RSA |EC |DSA |OPENSSH |)PRIVATE KEY-----/, name: 'PEM private key' },
  { re: /service_role[\s\S]{0,60}eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{10,}/, name: 'Supabase service_role JWT' },
];

for (const p of patterns) {
  if (p.re.test(text)) {
    console.error(`[secret-guard] BLOCKED: this write appears to contain a ${p.name}. Secrets must never live in project files — keep them in server-side / Edge Function config only (CLAUDE.md §5).`);
    process.exit(2); // exit 2 = block the tool call, reason shown to the agent
  }
}
process.exit(0);

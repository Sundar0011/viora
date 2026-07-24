#!/usr/bin/env node
// dart-format.mjs — PostToolUse. Auto-formats a Dart file after it is written/edited.
// Best-effort: never blocks, silently no-ops if dart isn't available or the file isn't Dart.
import { existsSync, readFileSync } from 'node:fs';
import { execSync } from 'node:child_process';

let raw = '';
try { raw = readFileSync(0, 'utf8'); } catch {}
let input = {};
try { input = JSON.parse(raw || '{}'); } catch {}

const fp = (input.tool_input && input.tool_input.file_path) || '';
if (fp.endsWith('.dart') && existsSync(fp)) {
  try { execSync(`dart format ${JSON.stringify(fp)}`, { stdio: 'ignore' }); } catch {}
}
process.exit(0);

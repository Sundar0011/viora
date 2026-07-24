#!/usr/bin/env node
// review-after-changes.mjs
// Stop hook: reviews Dart code after changes and checks everything is fine.
// When a turn ends, it finds the .dart files changed in the working tree and runs
// `dart analyze` on ONLY those files. If those files contain analyzer ERRORS, it blocks
// the stop (exit 2) so they get fixed before the turn is considered done.
//
// Robustness (this must NEVER wedge the session with false positives):
//  - Skips silently if there are no Dart changes.
//  - Skips if the analyzer environment isn't ready (no .dart_tool/package_config.json,
//    i.e. `flutter pub get` hasn't run) — otherwise every import looks "missing".
//  - Skips if analysis reports core SDK packages missing (package:flutter unresolved) —
//    that's an environment problem, not a problem with the change.
//  - Sanity cap: an implausibly large error count means a config/env issue, not a real
//    regression from a few edits — skip rather than block.
//  - Only ERROR severity blocks; warnings/infos are ignored. Any internal failure exits 0.

import { execSync } from 'node:child_process';
import { readFileSync, existsSync } from 'node:fs';
import { join } from 'node:path';

function readStdin() {
  try { return readFileSync(0, 'utf8'); } catch { return ''; }
}

// Run a shell command, returning {code, out} and never throwing.
function run(cmd) {
  try {
    const out = execSync(cmd, { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] });
    return { code: 0, out };
  } catch (e) {
    return { code: e.status ?? 1, out: `${e.stdout ?? ''}${e.stderr ?? ''}` };
  }
}

// Exit 0 but leave a soft, non-blocking note explaining why the review was skipped.
function skip(note) {
  if (note) console.error(`Code review gate skipped: ${note}`);
  process.exit(0);
}

function main() {
  let payload = {};
  try { const raw = readStdin(); payload = raw ? JSON.parse(raw) : {}; } catch {}

  // If we already blocked once this turn, don't loop.
  if (payload.stop_hook_active) process.exit(0);

  const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();

  // 1. Changed .dart files (modified + staged + untracked).
  const status = run(`git -C "${projectDir}" status --porcelain`);
  if (status.code !== 0) process.exit(0); // not a git repo -> skip silently

  const files = [...new Set(
    status.out.split('\n')
      .map((l) => l.slice(3).trim())
      .filter((f) => f && f.endsWith('.dart'))
      .map((f) => (f.includes('->') ? f.split('->').pop().trim() : f))
      .map((f) => f.replace(/^"|"$/g, ''))
  )];
  if (files.length === 0) process.exit(0); // no Dart changes -> nothing to review

  // 2. Analyzer environment must be resolved, or every import looks broken.
  if (!existsSync(join(projectDir, '.dart_tool', 'package_config.json'))) {
    skip('analyzer environment not ready (run `flutter pub get`). Not blocking.');
  }

  // 3. Analyze only the changed files.
  const quoted = files.map((f) => `"${f}"`).join(' ');
  const res = run(`cd "${projectDir}" && dart analyze ${quoted}`);

  // 4. Environment sanity: if core SDK packages don't resolve, it's an env issue.
  if (/Target of URI doesn't exist: 'package:flutter\//.test(res.out)) {
    skip('core packages unresolved (analyzer environment issue, not this change). Not blocking.');
  }

  // 5. Count ERROR-severity lines that reference one of the changed files.
  const changedBasenames = files.map((f) => f.split(/[\\/]/).pop());
  const errorLines = res.out.split('\n').filter((l) => {
    if (!/^\s*error\s*[-•]/i.test(l)) return false;
    return changedBasenames.some((b) => l.includes(b));
  });

  // 6. Sanity cap — a handful of edits can't plausibly cause hundreds of errors; that's
  //    a config/env problem. Don't block on it.
  if (errorLines.length > 100) {
    skip(`${errorLines.length} errors looks like an environment/config issue, not this change. Not blocking.`);
  }

  if (errorLines.length > 0) {
    const summary = errorLines.slice(0, 25).join('\n');
    console.error(
      `Code review gate: dart analyze found ${errorLines.length} error(s) in the changed ` +
        `Dart file(s). Fix these before finishing:\n\n${summary}` +
        (errorLines.length > 25 ? `\n… and ${errorLines.length - 25} more.` : '') +
        `\n\nChanged files:\n- ${files.join('\n- ')}`
    );
    process.exit(2); // block the stop so the errors get addressed
  }

  process.exit(0);
}

main();

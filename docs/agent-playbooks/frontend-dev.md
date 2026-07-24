# Frontend Dev — Self-Improving Playbook

This is frontend-dev's private, evolving skill. **Read it fully before every task.**
**After every task, append a dated lesson** below: which widget / layout / state / navigation
pattern worked or failed (note Android vs iOS), and the fix. Supersede old lessons; never delete.

## Lessons learned

**2026-07-20 — Flock rebrand Phase 1 (theme + hero screens).**
- *Worked well:* Splitting a large abstract theme class into `LightModeTheme` (main
  file) + `DarkModeTheme` (separate file, same directory, imports the abstract class
  back) keeps each file under/near the 400-line guideline without restructuring the
  public `FlutterFlowTheme.of(context)` API. Circular file imports within the same
  small theme module are fine in Dart (no build issue).
- *Worked well:* Wiring dark mode via `MediaQuery.platformBrightnessOf(context)`
  inside `FlutterFlowTheme.of()` is the cheapest way to make "follow system" dark
  mode work app-wide, since every FlutterFlow-generated screen already reads colors
  through `FlutterFlowTheme.of(context)` rather than `Theme.of(context)`. Still added
  a matching `darkTheme:` to `MaterialApp.router` for native widgets (dialogs,
  Cupertino) that read `Theme.of(context).brightness` directly.
- *Failed / fix:* When restructuring nested FlutterFlow widget trees (e.g. splitting
  a single `Expanded(child: Container(...))` into a sibling `Expanded` + `Container`
  to add a gradient scrim layer), it's very easy to leave one extra/missing closing
  `)`/`]` many lines later in these deeply-nested generated files, because the tail
  of the file was written assuming the old nesting depth. Fix/verify approach that
  worked: after any nesting-depth change, map every closing bracket in the tail back
  to the widget it closes (list opener→closer pairs by hand) rather than trusting
  the diff to "look right" — `dart analyze <single file>` immediately pinpoints the
  exact line if the count is off, which is much faster than guessing.
- *Failed / fix:* Don't build a "gradient stop derived via `.colors.last.withAlpha(0)`"
  just to reuse a gradient constant when the result is functionally identical to
  `Colors.transparent` — it reads as dead/confusing code. Prefer the simplest literal
  that achieves the visual effect.
- *Process note:* For a 5000+ line FlutterFlow-generated screen file (e.g.
  `community_widget.dart`), don't attempt a full manual read — `Grep` for the
  specific patterns named in the design spec (hardcoded `Color(0xFF...)` hex,
  `BorderRadius.circular(N)` literals, `FloatingActionButton`) first to find the
  actual touch points before editing; many "screen-level direction" spec items may
  not literally exist in the file the spec assumes them to be in (e.g. this app's
  "community feed" screen turned out to be a groups/events/business tab switcher,
  not an Instagram-style post-card feed) — flag the mismatch back to the owner/PM
  rather than inventing structure that isn't there.

**2026-07-20 — Home post feed restyle (`home_page_widget.dart`).**
- *Worked well:* For a deeply-nested FlutterFlow post-card loop, the safest UI-only
  edit pattern is: (1) find the single `Container(decoration: BoxDecoration(color:
  theme.white))` that wraps one post's `Column`, and only add `margin`,
  `clipBehavior: Clip.antiAlias`, `borderRadius`, and `boxShadow` to its existing
  `BoxDecoration` — never touch the `Column`/children below it. `clipBehavior:
  Clip.antiAlias` on the card container is enough to visually round the corners of a
  full-bleed post image inside without editing the image's own `ClipRRect(radius:
  0.0)`, so the design spec's "full-bleed image gets matching top corners" can be
  satisfied with zero risk to the image-rendering logic.
- *Worked well:* Reusing a Phase-1 custom widget (`GradientAvatarRing`) as a drop-in
  `child:` replacement for a plain `ClipRRect`/`Container(shape: circle)` avatar is a
  clean 1:1 swap — the ring widget owns its own `ClipOval`/sizing internally, so you
  just delete the old clip/decoration wrapper and pass the same `Image.network(...)`
  straight in as `child:`. Import it via the file's existing aliased
  `import '/custom_code/widgets/index.dart' as custom_widgets;` and call
  `custom_widgets.GradientAvatarRing(...)` — no new import needed if that alias
  import is already present (common in FlutterFlow screens that use any custom
  widget).
- *Caution noted:* Adding `margin` to a `Container` that sits as one child of a
  `Stack` (alongside a non-`Positioned` `Align` overlay used for a context-menu
  popup, e.g. "Report Post") slightly shifts the overlay's effective position, since
  `Stack` sizes to its largest child and margin is included in that child's reported
  size. This is a cosmetic-only shift (few px) for an already-approximate overlay
  offset — acceptable, but worth flagging in the report rather than silently
  absorbing; a true fix (wrap the whole `Stack` in `Padding` instead of margining the
  inner `Container`) is available if pixel-perfect positioning is required later.
- *Verify tip:* `git diff` on a file you only lightly edited can surface unrelated
  pre-existing dirty-tree changes (e.g. a hardcoded-hex-to-theme-token swap from an
  earlier phase) that were already in the working tree before your task started —
  don't assume every diff hunk is yours; cross-check against what you actually
  `Edit`-called before reporting "what changed."

**2026-07-20 — Dark-mode contrast sweep (decorative backgrounds + `.white` foreground fixes).**
- *Worked well:* For the "conditional `DecorationImage`" pattern, grep the whole app
  for the literal decorative asset filename (e.g. `image_(1).webp`) rather than just
  `DecorationImage` — the decorative dotted-map backdrop is reused verbatim across ~8
  registration screens with byte-identical surrounding `Container`/`BoxDecoration`
  code, so once the reference fix (`login_page_widget.dart`) is confirmed, the same
  three-line diff (`color: primaryBackground` + `MediaQuery.platformBrightnessOf ==
  Brightness.dark ? null : DecorationImage(...)`) can be applied verbatim everywhere
  that asset appears. Don't touch `DecorationImage` usages that are actually *content*
  (chat/comment avatar `NetworkImage`, onboarding hero photo with its own gradient
  scrim) — those are correctly theme-invariant already.
- *Worked well:* The reliable way to tell whether `FlutterFlowTheme.of(context).white`
  is a background (leave) or a mis-used foreground (fix to `Colors.white`) is to read
  20–30 lines of surrounding context: if `.white` is the value of a `Container`
  `decoration: BoxDecoration(color: ...)` or a `Scaffold.backgroundColor`, it's a
  surface fill — leave. If it's inside a `TextStyle`/`.override(color: ...)`,
  `Icon(color: ...)`, or `FFButtonOptions.iconColor`, check what fills the *element
  it sits on*: a sibling/parent `FFButtonOptions.color`, tab-selector `Container`
  `decoration.color`, or unread-badge fill that is `primary`/`redColor2`/
  `greenColor1`/`greenColor2` (a themed-but-fixed accent) means the text/icon is
  foreground-on-color and must become `Colors.white`. This repo has a very common
  FlutterFlow "segmented tab" idiom: `color: _model.opt == 'x' ? <accent> :
  theme.white` (background, correct to leave) paired with `color: _model.opt == 'x'
  ? theme.white : theme.greyL4` (foreground selected-tab text, must fix) — the two
  ternaries look almost identical but invert which branch is the risky one, so read
  both halves of every ternary rather than pattern-matching on `.white` alone.
- *Worked well:* Chat image-message "download icon + timestamp" overlays that sit
  inside a `Stack` on top of `Image.network(...)` (not on the message bubble's own
  white/dark frame `Container`) are content-overlay text, same rule as "text on a
  photo" — treat as foreground-on-arbitrary-content and hardcode `Colors.white`, even
  though the enclosing frame `Container`'s own `color: theme.white` is correctly left
  as a background fill. Two elements can be one on top of the other in the same
  widget tree with opposite fix/no-fix verdicts — always check the actual `Stack`
  z-order, not just decoration proximity in the source.
- *Caution / left ambiguous:* `BorderSide(color: ... : theme.white)` used as the
  outline stroke on a *selected* segmented-tab `Container` (the border becomes white
  when the fill becomes `primary`) was left unchanged — the task brief only calls out
  `TextStyle`/`Icon` foreground colors, not `BorderSide` strokes, and a white 1px ring
  on a primary fill is a much smaller contrast risk than solid text. Flagged rather
  than silently fixed or silently left, per the ambiguous-spot rule.
- *Efficiency tip:* For a single ~9700-line generated file (`search_widget.dart`) or
  a ~6300-line one (`community_widget.dart`) with 20–30 `.white` hits, don't Read the
  whole file — grep `\.white\b` for line numbers first, then batch `Read` 15–20 line
  windows around each hit (several in one tool-call batch) to classify
  background-vs-foreground before editing anything. A trailing multiline grep for
  `FlutterFlowTheme\.of\(context\)\s*\.white,\s*fontSize` after finishing is a cheap
  final check that no foreground `.white`-then-fontSize text-style pattern was missed.

**2026-07-20 — Dark-mode contrast sweep, second scope (`lib/pages/profile`,
`lib/pages/business`, `lib/pages/events`, `lib/pages/group`, `lib/pages/groups`,
`lib/pages/sale`, `lib/pages/terms_and_conditions`).**
- *Worked well:* A Node.js heuristic scanner (grep isn't installed as a raw shell
  binary in this sandbox — only the `Grep` tool and `rg` via it — and `python3`/
  `python` on PATH turned out to be Windows Store App-execution-alias stubs that
  error out; `node` was reliably present) that finds every `FlutterFlowTheme.of
  (context)` occurrence, checks a 3-line forward window for `.white`, then scans 30
  lines backward for the nearest of a foreground-keyword list (`TextStyle`,
  `.override(`, `Icon(`, `iconColor:`, `checkColor:`) vs a background-keyword list
  (`BoxDecoration(`, `backgroundColor:`, `fillColor:`, `Container(`) gives a fast
  first-pass FG/BG guess across ~100 hits, cutting manual review to spot-checking each
  flagged line's real context — but the heuristic is noisy in both directions (it
  flags unrelated nearby `.titleSmall.fontStyle` reads as FG, and it can't see that a
  `FFButtonOptions.color:` fill sits on the *inside* of a tab widget), so every single
  flagged line still needs a real `Read` of the surrounding 15–40 lines before editing
  — treat the scanner as a triage list, never as ground truth.
- *This repo's dominant real bug pattern:* a "New" button / segmented-tab selector
  Icon+Text whose color is `theme.white` while its parent `Container`'s
  `decoration.color` is `theme.primary` (or a ternary `_model.opt == 'x' ? primary :
  transparent`). This exact shape repeats near-verbatim across `neighborhoods_widget`,
  `switch_profile_deleted_widget`, `business_home_page_widget`,
  `comp_select_date_time_widget`, `my_event_widget`, `my_group_widget`, and
  `sale_widget` (5 separate tab rows) — once you've fixed one instance, grep the same
  file/sibling files for `? FlutterFlowTheme.of(context)\n....white` ternary shape to
  catch the rest fast.
- *Failed / fix:* I initially "fixed" a dropdown-filter arrow `Icon` whose color
  ternary read `_model.opt == 'categories' ? theme.white : theme.greyL4` by pattern-
  matching it against the tab-selector idiom above — but its enclosing `Container`
  decoration had **no `color:` at all** (only `borderRadius` + `Border.all`), so there
  was no colored fill to be "foreground on." Caught it by explicitly reading the
  enclosing `Container`'s `decoration:` for every ternary `.white` before editing, not
  just for the first one found in a file — reverted that single edit. Lesson: verify
  the *specific* enclosing fill for each occurrence, don't assume file-wide
  consistency even when 4 other nearly-identical-looking blocks in the same file do
  have a colored fill.
- *Also fixed:* small badge overlays drawn on top of a photo/thumbnail inside a
  `BackdropFilter`+`ClipRRect`, with a fixed (non-theme) `Color(0x19FFFFFF)` /
  `Color(0x1AFFFFFF)` translucent-white pill background (e.g. "Sold out" in
  `sale_widget.dart`, "Ending Soon" in `ending_event_widget.dart` /
  `latest_event_widget.dart`) — these badge texts used `theme.white`, which goes dark
  in dark mode and becomes invisible on the always-light translucent pill. Fixed to
  `Colors.white` since the pill's alpha-white fill is intentionally theme-invariant.
- *Scope-specific finding:* zero decorative `DecorationImage` full-screen backdrops
  existed in this scope's directories (only `lib/pages/registration/*`, outside
  scope, has the dotted-map pattern); the one `DecorationImage` hit in scope
  (`sale_details_widget.dart`, a "no photos" placeholder graphic shown in place of a
  real listing image) was left alone as a *content* fallback, not decorative noise —
  per the brief's own carve-out for listing/post images. Also zero hardcoded
  near-black `Color(0xFF000000)`-style text colors existed in this scope (all text
  already routes through theme tokens already fixed by the `extraBlack` inversion).

**2026-07-21 — Flock interaction/polish pass, `lib/pages/profile/**` (28
`*_widget.dart` files, per `docs/design/flock-interaction-spec.md`).**
- *Worked well — mass mechanical fix for pattern B:* Almost every FlutterFlow
  `InkWell` in this codebase ships with `splashColor: Colors.transparent,` (dead
  ripple, spec explicitly calls this out). Rather than hand-editing dozens of
  InkWells per file, a small Node script that walks every `*_widget.dart` under
  the scope directory and regex-replaces `splashColor:\s*Colors\s*\n?\s*\.\s*
  transparent,` (note: FlutterFlow often *wraps* `Colors.transparent` across two
  lines at ~80 col, so the naive single-line regex misses ~half of them — always
  make the regex tolerant of an optional newline+whitespace between `Colors` and
  `.transparent`) with `splashColor: FlutterFlowTheme.of(context).primary.
  withAlpha(0x14),` fixed 100 occurrences across 13 files in two passes, zero
  manual edits, zero risk of breaking `onTap` logic (the string is a pure leaf
  value, never touches control flow). Run `dart format` + `flutter analyze` on
  every touched file afterward to confirm 0 errors — safe every time in this run.
  Caveat: this is naive about context — an InkWell sitting on an *already-primary*
  filled `Container` (e.g. a "Change" pill button) gets a same-color ripple that's
  nearly invisible; those specific cases (found by reading, not the script) are
  better fixed by hand to `Colors.white.withAlpha(0x33)` since white-on-primary is
  the theme-correct "foreground on coloured fill" exception from spec section 1.
- *This repo's dominant `.secondary` (teal) bug, confirmed:* both literal
  `FlutterFlowTheme.of(context).secondary` hits in this scope were the exact same
  widget shape — an "Admin" role-badge `FFButtonWidget` fill inside a
  groups-in-common list, byte-identical in both `other_profile_widget.dart` and
  `user_profile_widget.dart` (FlutterFlow duplicated the whole nested list when
  generating the "your own profile" vs "someone else's profile" screens). Fixing
  both to `.primary` was a 1-line `color:` swap each; grep `\.secondary\b` across
  the whole scope up front to confirm there's no 3rd/4th copy before declaring done.
- *This repo's dominant "ghost/outline button" hardcoded-color bug:* FlutterFlow
  represents a transparent-fill outlined `FFButtonWidget` (e.g. "Request",
  "Join") as `color: Color(0x000B7A52)` — alpha byte `00` makes it fully
  transparent already, so visually it's a no-op, but it's still a literal
  `Color(0x...)` the spec forbids. This exact 8-hex-digit literal
  (`0x000B7A52`) repeats verbatim 10-16 times per large profile file
  (`other_profile_widget.dart`, `user_profile_widget.dart`) — a single
  find-all-replace to `Colors.transparent` (clearer intent than a magic
  zero-alpha hex) cleans every instance at once; no need to hand-visit each one
  since the surrounding `FFButtonOptions` (border/text colour) never varies.
- *Bare-`Icon` false positives to watch for:* `FFButtonWidget(icon: Icon(Icons.x,
  size: 15.0))` (no `color:` on the `Icon` itself) is **not** the "icon inherits
  wrong default" bug the brief warns about — `FFButtonWidget` reads
  `FFButtonOptions.iconColor` and applies it to the icon internally. Always check
  20-30 lines below the bare `Icon(...)` for a sibling `FFButtonOptions(iconColor:
  ...)` before "fixing" it; a bracket-depth-matching script (find `Icon(`, walk
  parens to the matching close, check only *that* block for `color:`) is more
  reliable than a fixed-line-window heuristic for catching real bare icons buried
  in deeply-nested (40+ level) FlutterFlow trees, and avoids false-fixing button
  icons that are correctly coloured one level up.
- *New theme tokens discovered and reused (do not invent new ones):*
  `FlutterFlowTheme.of(context).alternate` is the correct base-fill token for a
  skeleton-loader bar (was hardcoded `Color(0x170C0C0C)` in
  `shimmer_loader_followers_widget.dart`) — it's already a light-neutral/
  dark-neutral pair per theme. Also found `FlutterFlowTheme.of(context)
  .designToken.shadow.{sm,md,lg,xl}` (note the `.designToken` indirection — the
  `FFShadows` class is nested one level deeper than `FlutterFlowTheme.of(context)
  .shadow`, which does **not** compile) as the correct replacement for a literal
  `BoxShadow(color: Color(0x33000000), blurRadius: 6.0, offset: Offset(0,2))` —
  `.md` (blurRadius 6, offset (0,3)) was the closest existing preset; no new
  token needed.
- *Empty-state illustration swap requires leaving the shared component alone:*
  `CompNoDataFoundWidget` (in `lib/components/`, outside this agent's scope)
  already picks `assets/images/{followers,following,block}.webp` etc. by
  `pageName:` string internally — for screens that already call it (followers,
  following, comp_followers, comp_following, blocked_users) the correct polish is
  to leave the illustration choice alone and just wrap the *call site* in
  `.animate().fadeIn(...).scale(...)` (pattern D) since the component itself
  can't be edited from this scope. Only screens that build their *own* inline
  empty-state (no `CompNoDataFoundWidget` call — e.g. `neighborhoods_widget.dart`,
  `neighbourhood_explore_widget.dart`, both plain `Text`-only empty states with no
  illustration at all) get a hand-added `Image.asset('assets/images/
  empty_groups.png'|'empty_feed.png', ...)` inserted above the headline, since
  there's no shared widget dictating the asset there.
- *Efficiency for 28-file scope at low effort budget:* triage first with 4-5
  parallel `Grep` calls (`Color\(0x`, `\.secondary\b`, `shimmer|Shimmer`,
  `ListView\.builder|itemBuilder`) across the whole scope directory before
  opening any file — this immediately separates "needs full read" (has lists/
  shimmer/hardcoded colour) from "skim only" files, and a repeated structural
  clone (`followers_widget.dart` vs `following_widget.dart`,
  `comp_followers_widget.dart` vs `comp_following_widget.dart`) can be fixed with
  the *exact same* Edit sequence run twice rather than re-deriving the diff.

**2026-07-21 — Flock micro-interaction polish pass (`lib/pages/group/**`,
`lib/pages/groups/**`), following `docs/design/flock-interaction-spec.md`.**
- *Worked well:* Before hand-editing 25 files, ran a Node one-off script (not `grep`)
  to classify every `Icon(`/`icon: Icon(`/`IconButton(` occurrence as "has a `color:`/
  `iconColor:` within N lines" vs not. Turned out **every** `Icon`/`FaIcon` in this
  scope is passed via `FFButtonWidget`'s `icon:` param, and `FFButtonWidget` recolors
  it internally from `FFButtonOptions.iconColor` (see
  `lib/flutter_flow/flutter_flow_widgets.dart` line ~199-217,
  `iconColor: WidgetStateProperty.resolveWith(...) => widget.options.iconColor`) — so
  a bare `Icon(Icons.x, size: 15.0)` with no `color:` inside an `icon:` slot is NOT a
  bug, it's the correct FlutterFlow idiom. Don't pattern-match on "`Icon(` with no
  `color:`" alone; check whether it's wrapped by `FFButtonWidget.icon` first (grep for
  `iconColor:` in the same `FFButtonOptions(` block) before "fixing" it.
- *Worked well:* Found the real color offender named in the brief
  (`group_details_widget.dart` "Creator"/"Admin" badges using
  `FlutterFlowTheme.of(context).secondary`, a teal, as an `FFButtonOptions.color`
  fill) by grepping `\.secondary\b` across the whole scope — it was a copy-pasted
  "Admin badge" idiom repeated near-verbatim in `all_groups_widget.dart`,
  `about_group_widget.dart`, `nearest_groups_widget.dart`, and 5x inside
  `my_group_widget.dart` (one per duplicated tab). All 10 instances fixed to
  `.primary` with the same one-line swap once the shape was confirmed identical.
- *Worked well:* For adding `HapticFeedback.lightImpact()` to ~30 "Join / Request"
  `FFButtonWidget.onPressed` callbacks spread across 7 huge (1k-6k line) generated
  files, hand-editing each with the `Edit` tool was too slow for the budget. Instead:
  (1) grepped every `text: 'Join'` / `'Request'` / etc. line number, (2) wrote a small
  Node script that, for each target line, walks *backward* looking for the nearest
  `onPressed: () async {` (or the split `onPressed:` / `() async {` two-line form that
  appears at deep nesting), and splices in the haptic call as the first statement,
  (3) re-ran a second pass for the lines the first pass missed (the deeply-nested
  split form). This is safe because it only ever *inserts* a line at a positively
  identified location — it never deletes or restructures. Followed by `flutter
  analyze` per file to confirm 0 errors before moving on. This scripted-insertion
  approach is far more reliable than plain `Edit` `replace_all` when the surrounding
  text differs per occurrence (real Supabase insert/update calls, not boilerplate).
- *Worked well:* For pattern-A list stagger, wrapping the `return Visibility(...)`
  (or whatever widget) inside a `ListView.builder`/`.separated` `itemBuilder` in
  `.animate().fadeIn(...).slideY(...)` requires finding the *exact* closing `);` of
  that return statement, which can be 800+ lines below the `itemBuilder:` line in
  these deeply nested files. Reliable technique: grep for a line that is *only*
  `},` at the **same indentation as the `itemBuilder:` line itself** (the callback's
  own closing brace) — the line immediately above that `},` is the return statement's
  closing `);`. Confirmed correct every time by running `flutter analyze` on just that
  one file immediately after the edit; never had to hand-count nested parens.
- *Worked well:* `my_group_widget.dart` has 5 byte-for-byte-identical tab list
  builders (All/Joined/Requested/etc., each its own `Builder(builder: (context) {...
  ListView.builder(...itemBuilder: (context, gropsIndex) {... return Visibility(...);
  },);},)`), all closing with the exact same 7-line tail. A single `Edit`
  `replace_all: true` against that tail applied the stagger animation to all 5 tabs
  in one shot — confirmed first that all 5 `itemBuilder`s used the same loop-variable
  name (`gropsIndex`) before relying on `replace_all`, since the animation delay
  expression references that variable by name.
- *Also confirmed:* `my_group_widget.dart`'s main list already had the correct
  empty-state wiring (`if (grops.isEmpty) return CompNoGroupsAvailableWidget();`)
  pre-existing — only the empty-state *widget itself* needed the spec's copy/asset/
  entrance-animation polish (swapped `assets/images/Line.webp` + placeholder-key text
  `'NoGroups'` for `assets/images/empty_groups.png` + spec-compliant headline/body +
  `fadeIn().scale(curve: easeOutBack)` entrance), not any new branch/logic.
- *Not done, flagged rather than skipped silently:* pattern C (`AnimatedContainer` for
  setState-driven chip/tab color) had zero clear instances in this scope — no
  `Container` here toggles its own `decoration.color` off a local `_model`/`setState`
  boolean; the visual "state" (joined/requested/admin) is driven by different
  `FFButtonWidget`s conditionally rendered via `if (...)`, not one `Container`
  re-coloring itself. Left unapplied rather than inventing a toggle that isn't there.
  Full-page loading skeletons (spec §4) were also not converted: the only
  `CircularProgressIndicator`s in scope are per-thumbnail `Image.network` load
  spinners (correct as-is, not a full-page loading gate), and 2 files
  (`comp_review_invite_widget.dart`, `comp_invite_friends_widget.dart`) already use a
  proper `shimmerHighlight`-token skeleton loader pre-existing in the codebase.
- *Not done for time budget:* haptic + splash-ripple + stagger were applied to the
  primary discovery/list screens (`all_groups`, `nearest_groups`, `about_group`, the
  first tab-set in `my_group`) and to the explicitly-named `group_details` offender;
  the ~15 small action-sheet components (`comp_delete_group`, `comp_resign_admin`,
  `comp_revoke_admin`, `comp_unblock_user`, `comp_confirm_admin_role`,
  `comp_private_group_members`, `comp_group_members`) were only given the InkWell
  splash-color fix (mechanical, safe, done everywhere) — Confirm/Cancel buttons in
  those dialogs are plain `FFButtonWidget`s without an explicit "Join/Leave/Request"
  callout in the brief, so haptics were left for a follow-up pass rather than
  guessed at under time pressure.

**2026-07-21 — Flock interaction/polish pass, `lib/pages/home/`, `lib/pages/post/`,
`lib/pages/comments_page/` (staggered feed, empty states, ripple/haptic, tokens).**
- *Worked well:* When a spec calls for a repo-wide "recipe" (stagger/ripple/animated
  chips/empty-state entrance from `docs/design/flock-interaction-spec.md`), triage
  with cheap regex/grep passes *before* touching any widget: (1) `Color(0x` count per
  file, (2) a small Node script that finds every `Icon(` call and checks whether a
  `color:` key exists anywhere inside its matching paren-depth block (bare string/regex
  grep can't see this because `Icon(\n  Icons.x,\n  size: ...\n)` spans lines with no
  `color:` token on the same line) — this found zero missing-color icons in this scope,
  which was worth confirming before assuming the brief's claimed bug existed here. (3) a
  grep for `Colors.green|Colors.teal|Colors.blue|greenColor|tealColor|\.info\b` to check
  the "no green/teal/blue active state" rule — also zero hits in this scope. Don't skip
  this triage even when the brief asserts a bug pattern exists "everywhere" — verify per
  scope before mass-editing.
- *Worked well:* The `PostToolUse:Edit` hook in this repo auto-runs a Dart formatter
  after every `Edit` call and can reformat/wrap lines you haven't touched yet elsewhere
  in the file. This means `old_string` for a *subsequent* edit sometimes no longer
  matches verbatim (wrapping changed) even though you never read that region back — the
  fix is cheap: re-`Grep` the anchor text (e.g. `splashColor:`) right before the next
  edit rather than trusting line numbers/wrapping from an earlier `Read`.
- *Worked well:* For the "empty feed renders nothing" bug, the safe fix is a single
  `if (posts.isEmpty) { return <empty state>; }` guard inserted as the first statement
  inside the `Builder` callback that already computes `final posts = ...toList();` —
  this satisfies "adding a conditional empty-state branch to the build method is
  allowed" without touching the data-fetch/`RefreshIndicator`/`FFAppState` logic at all.
  Same pattern reused for the comments list (`FFAppState().AsComments == null`) using
  `assets/images/empty_chat.png` as the closest existing asset since no dedicated
  `empty_comments.png` exists — flagged the gap rather than inventing a new asset path.
- *Worked well:* For staggered list entry (pattern A) on a `List.generate` that
  `return`s a `Stack(...)` as a single expression, the least invasive edit is to leave
  the `Stack(` opener alone and change only the closing `);` immediately before the
  `.divide(...)`/`}).` call site to `)\n.animate().fadeIn(...).slideY(...)` — i.e.
  convert the bare `return Stack(...);` into `return Stack(...).animate()....;` by
  editing only the tail. No need to touch the 1000+ line body in between.
- *Worked well:* Both `flutter_flow_animations.dart`'s custom `AnimationInfo`/
  `ShimmerEffect` system (FlutterFlow's own, used inside `initState`/`animationsMap`,
  reads `FlutterFlowTheme.of(context)` fine even inside `initState` — this repo already
  does that 30+ times) and the `flutter_animate` package's `.animate()` / `.ms`
  extension (used for the *new* stagger/entrance patterns per spec) coexist in the same
  file without conflict — just import both (`flutter_flow_animations.dart` may already
  be imported; `package:flutter_animate/flutter_animate.dart` usually needs adding).
  Also needed `package:flutter/services.dart` for `HapticFeedback` in every file that
  didn't already use haptics.
- *Decision, recorded here per CLAUDE.md §7 (small/reversible):* for the "liked" heart
  icon (`Icons.favorite` filled state), this repo used `theme.redColor2` (a true red,
  `0xFFD8321F`) instead of `.primary` (a pink/rose, `0xFFC42D63`). Per the spec's icon
  rule ("Active/selected → `.primary`"), changed all liked-heart instances (home feed,
  comments post-level, comments comment-level — 4 sites total) to `.primary`. This is
  a brand-consistency call, not a bug fix — reversible by search/replace back to
  `redColor2` if the designer disagrees; flagged in the task summary rather than
  silently assumed correct.
- *Scope-specific finding:* only one real "chip/tab that changes color on setState"
  (pattern C candidate) existed in the entire three-directory scope:
  `thank_neighbor_deleted_widget.dart`'s two segmented buttons (`_model.option == '1'/
  '2'`). A Node script matching `Container(...decoration: BoxDecoration(...color:
  _model.<x> ? A : B` (bounded regex across ~400/300 char windows to survive
  multi-line) found it; `Container(` → `AnimatedContainer(duration: 180.ms, curve:
  Curves.easeOut, ...)` is a pure rename-and-add, zero risk, since `AnimatedContainer`
  accepts the exact same named parameters as `Container`.
- *Left unfixed, flagged not silently skipped:* several `BorderSide(color:
  Color(0x00000000))` (`= Colors.transparent`) hits inside `TextField`
  `enabledBorder`/`focusedBorder` (`create_post`, `editpost`, `create_poll_deleted`,
  `post_about_safety_deleted`, `thank_neighbor_deleted`) were left as literal
  `Color(0x00000000)` rather than swapped to `Colors.transparent` or a token — these are
  intentional "hide the border" values, not a design color, and touching a TextField's
  border config felt outside "visual polish" risk tolerance for a field this
  copy-pasted across 5 files. Worth a follow-up pass if the team wants zero
  `Color(0x...)` literals with no exceptions.

**2026-07-21 — Flock interaction-spec polish pass (`lib/pages/registration/**`,
`lib/pages/loading_page`, `lib/pages/terms_and_conditions`).**
- *Scope-specific finding:* this scope (auth/registration + a static ToS accordion +
  a full-screen loading gif) is almost entirely forms and static copy, not feeds —
  zero `Color(0x...)` literals and zero un-colored `Icon(...)`s existed already
  (an earlier phase had cleaned them up). The one real bug matching the brief's
  "green/teal active state" warning was a `theme.greenColor2`-tinted `Icons.phone`
  glyph on a *static* "sign in with phone" option row, sitting next to a sibling
  "sign in with email" row whose `Icons.mail` was already `theme.primary` — same
  bug shape repeated verbatim in 3 files (`email_login_page`, `final_steps_mail_page`,
  `forget_password`). Fixed all 3 to `.primary` to match the sibling icon rather than
  demoting to `.secondaryText`, since both rows are equally-weighted CTA options, not
  one active/one idle — consistency with the already-correct sibling was the deciding
  signal, not the letter of the "decorative vs active" icon rule.
- *Worked well — bulk `splashColor: Colors.transparent` fix:* every `InkWell` in this
  scope used the exact literal `splashColor: Colors.transparent,` (FlutterFlow's
  default, deadening every tap). Since the replacement value is identical everywhere
  and indentation doesn't matter for a plain `sed -i 's/.../.../'` (no anchoring on
  leading whitespace), a one-line `sed` loop across all 9 files was safe and fast —
  far faster than 24 individual `Edit` calls. Confirmed first via `Grep` that every
  hit was actually on an `InkWell` (not some unrelated transparent-splash use) before
  running it.
- *Worked well — bulk haptic-feedback insertion:* adding `HapticFeedback.lightImpact()`
  as the first statement of every `onTap: () async {` block that didn't already have
  one is *not* safely doable with `sed` (needs to skip blocks that already call it,
  and needs the correct per-block indentation). A small Node script that does a plain
  `indexOf('onTap: () async {')` scan, checks whether the very next source line already
  starts with `HapticFeedback.lightImpact()`, and if not inserts it using that next
  line's own leading-whitespace as the indent, handled 20 occurrences across 8 files
  correctly in one pass — cheaper and more reliable than 20 manual `Edit` calls, and
  avoids the stale-`old_string`-after-formatter-hook problem entirely since it reads
  the file fresh each time. Bash `-e` inline Node one-liners kept failing on nested
  quote escaping (regex containing both `'` and needing shell-escaped `\\` sequences)
  — writing the script to a real `.js` file in the scratchpad dir and running
  `node <file>` avoided all of that.
- *Real dynamic list found in an unlikely place:* `comp_neighbour_location_widget.dart`
  (an address-autocomplete dropdown, not obviously a "feed") builds its suggestion rows
  via `List.generate(shownPlaces.length, (i) { return InkWell(...); })` — this is the
  actual pattern-A (staggered entry) target in the whole scope; nothing else in
  registration/loading/terms-and-conditions has a real data-driven list. Wrapped the
  returned `InkWell` with `.animate().fadeIn(delay: (40 * (i % 8)).ms).slideY(...)`
  by inserting after its closing `)` and before the trailing `;` of the `return`
  statement — safer than trying to wrap the `return` keyword's expression from the
  front, since the tail-anchored insertion point (`),\n);\n})` before the `List.generate`
  callback closes) is unambiguous to locate via `Grep`/`Read` even in deep nesting.
- *Correctly skipped, not silently:* patterns A (list stagger) and D (empty/error art
  entrance) mostly don't apply to this scope — auth/ToS screens have no empty states
  and (with the one dropdown exception above) no dynamic lists. Also found zero
  `Container` whose `decoration.color`/`border` changes via a `_model.x ?` ternary
  inside a *single* `Container` (pattern C's actual target — chips/tabs); the closest
  look-alike (`forget_password`'s "Email ID"/"Phone Number" method picker) is two
  *separate* static option buttons swapped via `if (!_model.isEmail)`/`if (_model.isEmail)`,
  not one Container animating its own color — did not force an `AnimatedContainer`
  conversion onto a shape the spec doesn't actually describe. Report these
  not-applicable findings explicitly in the summary rather than leaving the reviewer
  to wonder whether they were missed.
- *Loading screen:* `loading_page_widget.dart` is a full-screen animated `.gif`
  (`Untitled_design.gif`), not a skeleton-able layout — spec's "skeletons not
  spinners" is for content with known shape; a single full-bleed loading graphic
  covering the whole screen while async setup runs already satisfies "never leave a
  screen fully blank while loading," so it was left untouched.

**2026-07-21 — Flock interaction-spec polish pass, `lib/pages/sale/**`,
`lib/pages/business/**` (33 widgets: marketplace listings, filter-sheet bottom
sheets, business page + confirmation/status dialogs).**
- *Triage first, edit second:* a full-scope Node scan for `Color(0x` hex literals
  found only 2 offending files (`sale_widget.dart`: green `Color(0x130B7A52)` used as
  an "active tab" tint, plus several `Color(0x00000000)`/`Color(0x19FFFFFF)`
  stand-ins for transparent/translucent; `business_home_page_widget.dart`: one
  `Color(0x00000000)` border). A second scan for `Icon(` with no `color:` anywhere in
  a following ~7-line window found **zero** — the brief's "many icons have no colour"
  claim did not hold for this scope; the one real bug found by *widening* the window
  to 20 lines (the FF formatter often puts `Icons.foo` and its ternary `.white`/
  `.primary` many lines apart, one call per line) was `sale_widget.dart`'s "Categories"
  dropdown arrow: `_model.opt == 'categories' ? theme.white : theme.greyL4` sitting
  inside a **border-only, unfilled** `Container` — white-on-nothing is invisible.
  Fixed to `.primary`. Note `_model.opt` is never actually set to `'categories'`
  anywhere in the file (dead branch today), so this bug is currently unreachable but
  was fixed anyway since the ternary is live code that could become reachable.
- *Worked well — literal `Colors.transparent` vs a theme token:* `Color(0x00000000)`
  literals used purely as "no border / no fill" (not an actual visible colour) were
  replaced with `Colors.transparent`, not a `FlutterFlowTheme` token — there is no
  sensible token for "nothing," and this repo already uses `Colors.transparent`
  pervasively for `splashColor`/`focusColor`/`hoverColor`. Reserve actual theme tokens
  for literals that render a visible colour.
- *Correctly left alone:* `Color(0x19FFFFFF)` translucent-white pill backgrounds
  behind "Sold out" badges (drawn over an arbitrary photo via `BackdropFilter`) are
  intentionally theme-invariant per the 2026-07-20 dark-mode-sweep lesson already in
  this file — did not touch them, only confirmed their paired text is `Colors.white`
  (already correct, previously fixed).
- *Mechanical `splashColor` sweep across all 24 affected files:* almost every
  `InkWell` in this scope used the single-line literal `splashColor:
  Colors.transparent,` — a per-file `replace_all` Edit swapped it to
  `FlutterFlowTheme.of(context).primary.withAlpha(0x14)` everywhere in one call per
  file (51 hits, 24 files). A handful (4 files) had it reformatted across two lines
  (`splashColor:\n    Colors.transparent,`) by the FF/dart-format style for longer
  enclosing contexts — a regex-based Node pass (`\s*\n?\s*Colors\.transparent,`)
  caught those the literal-string Edit missed. Always re-grep for the multi-line
  variant of a "simple" literal before declaring a sweep complete.
- *Worked well — stagger only where the state variable is actually visible:* for
  `ListView.builder(itemBuilder: (context, xIndex) { ... return InkWell(...); })`
  patterns, the safest insertion point for `.animate().fadeIn(delay: (40*(xIndex%8)).ms)
  .slideY(...)` is right after the last `)` that closes the returned widget and before
  its trailing `;` — found reliably by grepping for the *next* `^\s*\);\s*$` line after
  the `itemBuilder:` match at matching indentation depth, then reading a 20–30 line
  window to confirm it's the right closer (not a nested one). Applied this to two
  independent `ListView.builder`s in `sale_widget.dart` (marketplace "All"/"Yours"
  tabs each have their own list + own index variable name) and to
  `comp_category_filter_widget.dart` / `comp_kms_filter_widget.dart`'s bottom-sheet
  option lists.
- *Pattern C candidates were rarer than expected:* only `sale_widget.dart` had real
  `Container`→`AnimatedContainer` targets — the "Yours" tab's All/Selling/Sold chips
  (3×) and the "Free" toggle chip in the "All" tab, all driven by `_model.opt`/
  `FFAppState().SalesTypeFilter` inside the same widget's `setState`. The top-level
  "All/Yours" segmented tab was *already* `AnimatedContainer` (300ms, pre-existing) —
  left its duration as-is rather than forcing it to the spec's 180ms, since changing a
  working animation's timing for consistency alone isn't a bug fix. Business scope had
  **no** setState-driven chip/tab Containers at all (its only dynamic list — a
  "similar businesses" `ListView.separated` — is a plain navigation list, not a
  toggle), so pattern C was legitimately a no-op there; only added haptic to its tap.
- *Pattern D (empty/error art entrance) not applicable in this scope:* every empty
  state in `lib/pages/sale/**` already routes through a shared
  `CompNoDataFoundWidget` (`lib/components/comp_no_data_found_widget.dart`) with
  good spec-compliant copy ("No listings available" / "Items for sale or giveaway
  will appear here once users start posting.") — but that file lives **outside**
  this task's two-directory scope (`lib/pages/sale/`, `lib/pages/business/`), so it
  was left untouched and flagged rather than edited out-of-scope. None of the small
  business confirmation/status bottom sheets (`comp_under_review`,
  `comp_promotion_rejected/ended/is_live`, `comp_thankyou_report`,
  `comp_business_deleted`, `comp_mismatch`) contain any illustration/icon artwork to
  animate — they're pure text status cards with just a back-arrow icon — so pattern D
  had no real target there either; did not invent an icon/illustration to satisfy the
  letter of the spec.
- *Feature-flagged dead code, not fixed:* both `sale_widget.dart` and
  `sale_details_widget.dart` contain a `bookmark_border` "save/favourite" icon gated
  behind `if (false)` — the feature is fully disabled in this build, not just
  visually unstyled. The task brief's "save/favourite deserves a satisfying press
  response" has no live target to attach haptics/ripple to; flagged rather than
  wiring up a disabled feature (would be a logic change, out of scope).
- *Shimmer already compliant:* `sale_widget.dart`'s `ShimmerEffect` (used via
  `flutter_flow_animations.dart`'s `AnimationInfo`/`animateOnPageLoad`, not the
  `flutter_animate` package) already read `color: FlutterFlowTheme.of(context)
  .shimmerHighlight` for its 3 skeleton loaders — verified, no fix needed. No other
  file in this scope has its own shimmer/skeleton loader.
- *Verify tip:* `flutter analyze <dir>/ <dir>/` at the end surfaces `error -` lines
  distinctly from `warning -`/`info -` (mostly pre-existing `prefer_const_constructors`
  noise across the whole FlutterFlow codebase) — grep specifically for `error -` to
  get a fast pass/fail signal instead of eyeballing a 100+ line issues list.

**2026-07-21 — UI-review fix pass (`docs/design/ui-review-2026-07-21.md` §2.2/§2.6/§2.10),
scope `lib/pages/{home,post,comments_page,notification,sale}/**` + `lib/chat/**`.**
- *The single most important lesson from this pass — a census built from a single-line
  grep undercounts.* The brief said 27 `fontSize: 10.0` sites; the real number in the same
  folders was **32**. FlutterFlow's formatter wraps a long property across two lines at
  deep nesting (`fontSize:\n    10.0,`), and a plain `grep "fontSize: 10\.0"` cannot see
  those. This exactly repeats the 2026-07-21 `splashColor: Colors.transparent` lesson
  above, so promote it to a standing rule: **for ANY "replace literal X" sweep in this
  repo, always run the multiline-tolerant regex (`X:\s*\n?\s*value`) before AND after the
  sweep.** The `Grep` tool's `multiline: true` gives per-file counts in one call, which is
  the cheapest way to reconcile against a brief's stated census. Then filter false
  positives by reading 2 lines of context — `^\s*10\.0,$` alone also matches
  `EdgeInsetsDirectional.fromSTEB(40.0,\n  10.0,` padding args, which must NOT be touched.
- *Failed approach / fix:* `bash -c 'cat > "$TMPDIR/x.js" <<EOF'` silently wrote to `/x.js`
  and then `node` resolved the path against Git-Bash's install dir. On this Windows box
  `$TMPDIR` is empty inside the Bash tool. Always write helper scripts with the `Write`
  tool to the **absolute** scratchpad path and invoke `node "<abs path>"` — never rely on
  a shell temp var. (Also: `Write` refuses to overwrite a scratchpad file it hasn't read
  in this session, so `rm` it via Bash first if you need to rewrite it.)
- *Layout rule I derived and would reuse — the `Container(alignment:)` expansion trap.*
  Converting a fixed-size badge (`Container(width: 52, height: 18, child: Align(center,
  child: Text))`) to "min-size + padding so the text can grow" is NOT a straight swap of
  `width/height` for `constraints:`. `Container` wraps its child in `Align` when
  `alignment:` is set, and a factor-less `Align` **expands to fill bounded incoming
  constraints** — so removing the tight width/height while keeping the alignment makes the
  badge balloon to the size of its parent (here, the whole 120x80 listing thumbnail inside
  a `Stack`, which hands non-positioned children loose-but-bounded constraints). The
  correct shape is: **drop the `Align` entirely**, use `constraints: BoxConstraints(minWidth,
  minHeight)` + symmetric `padding:` + `textAlign: TextAlign.center` on the `Text`. Then the
  render chain is `ConstrainedBox → DecoratedBox → Padding → Text`, which shrink-wraps.
  Applied to the two "Sold out" pills in `sale_widget.dart` (at 12px bold Manrope the label
  measures ~56px and would have soft-wrapped to two lines inside the old 52px box, then
  clipped against the 18px height).
- *How to decide "does 12px still fit" without running the app:* with FlutterFlow's
  `lineHeight:` (→ `TextStyle.height`) the line box is exactly `fontSize * lineHeight`, so
  the arithmetic is reliable. Worked examples from this pass: chat's 22x22 unread badge →
  12 x 1.4 = 16.8 < 22 ✓; the marketplace card's right column is a hard `Container(height:
  80)` holding `Text(title, maxLines: 2, 16px/1.4 = 44.8)` + a metadata `Wrap` that lands
  on 2 rows (2 x 16.8 = 33.6) = 78.4 ≤ 80 ✓ but with only 1.6px of slack. Record those
  near-misses in the report — they are the ones that break first under Android's "Largest"
  font scale, and they are the owner's call, not mine.
- *Chat outcome (the brief expected some rows to be un-raisable):* all 9 chat 10px sites
  took 12px cleanly. The reason is structural and worth remembering — **every dense chat
  metadata element in this app is constrained on WIDTH, not height** (`Container(width:
  100)` around a timestamp, `BoxConstraints(minWidth: 100)` around a timestamp+read-receipt
  `Row`), and the two 22x22 unread badges have ~5px of vertical slack. The fixed
  `height: 76.0` chat list tile is the only real ceiling and none of the 10px text sits in
  its critical path. So: check whether the constraint is on the cross axis before assuming
  a "dense row" can't grow — in this codebase it usually can't grow *sideways*, which is a
  different (and often non-binding) problem.
- *`SafeArea(bottom:)` defaults to `true`.* All 18 `Scaffold`s in scope already wrapped
  `body:` in `SafeArea(top: true, …)` with `bottom` omitted, i.e. the iOS home-indicator
  inset was **already** correct everywhere including `message_page`'s message input. Adding
  the explicit `bottom: true` is a zero-behaviour-change, intent-documenting edit only —
  say so plainly in the report rather than claiming 18 bugs fixed. (Also note a `Scaffold`
  with a `bottomNavigationBar` consumes the bottom inset before the body sees it, so the
  flag is a no-op there either way.)
- *Deliberately left, with reasons (do not "fix" these next pass without a decision):*
  the two `Color(0x19FFFFFF)` translucent-white pills behind "Sold out" in
  `sale_widget.dart`. There is genuinely no theme token for a 10% white scrim — the
  closest, `accent4` (`0xCCFFFFFF`), is 80% opaque and inverts in dark mode, which would
  destroy a badge that is intentionally theme-invariant because it floats over an arbitrary
  user photo. Consistent with the 2026-07-20 dark-mode lesson above.
- *Superseded:* the 2026-07-21 sale/business lesson's caution about leaving `TextField`
  `enabledBorder`/`focusedBorder` `Color(0x00000000)` alone. This pass had explicit
  authorisation and converted all 20 zero-alpha literals in scope (`0x00000000` and
  `0x00FFFFFF`) to `Colors.transparent`. Zero analyzer errors; the borders are invisible
  either way. Treat "zero-alpha hex → `Colors.transparent`" as always-safe from now on.
- *Cheap end-of-pass verification that caught nothing but would have:* `dart format` the
  scope, then `dart analyze` it and grep for `error`. Only 1 of 92 files needed
  reformatting (the `GoogleFonts.inter(` → `.manrope(` rename lengthens the identifier by
  3 chars and can push a nested line past 80 cols) — and `git diff` on that one file
  surfaced pre-existing dirty-tree hunks from earlier passes (`splashColor`, `0xFFF7F9FC` →
  `.alternate`), so cross-check every diff hunk against what you actually edited before
  reporting.

**2026-07-21 — UI-review Sprint-1 mechanical pass, `lib/pages/group/**` +
`lib/pages/groups/**` (typography drift, 10px text, hardcoded colours, `print()`,
SafeArea), per `docs/design/ui-review-2026-07-21.md` §2.2/§2.4/§2.6/§2.10.**
- *CRITICAL — single-line `Grep` massively UNDERCOUNTS in this repo. Supersedes the
  "grep first" triage advice in the earlier lessons above.* The repo's dart formatter
  wraps almost every token pair across a newline at deep nesting, so the obvious
  patterns silently miss 40-60% of real sites. Measured on this scope:
  `GoogleFonts\.interTight\(` found **19**, but the newline-tolerant
  `GoogleFonts\s*\n?\s*\.\s*interTight\s*\(` found **75**. `fontSize: 10\.0` found
  **15**, `fontSize:\s*\n?\s*10\.0` found **28**. `Color\(0x` found **27**,
  `Color\(\s*0x[0-9A-Fa-f]{8}\s*\)` found **59**. Rule: for ANY census/sweep, write a
  Node scan with `\s*\n?\s*` between every token before trusting a count — including
  the counts quoted in a task brief (the brief's "19 fonts / 15 fontSize / 14 colors"
  were all single-line greps and all low). Report the corrected number back.
- *Worked well — one offset-based Node script for the whole mechanical sweep.* For
  6.5k- and 4.9k-line generated files, the safest edit engine is: collect every
  `{start, end, replacement}` byte range from the ORIGINAL file content, assert no two
  ranges overlap, sort descending by `start`, then splice. Descending order keeps every
  offset valid without recomputation, the overlap assert catches a bad regex before it
  corrupts anything, and nothing is ever re-emitted from the model — so
  `full-output-enforcement` truncation risk is structurally zero. 231 edits across 16
  files in one pass, `dart format` after, `flutter analyze` → 0 errors. Far safer than
  either a whole-file rewrite or dozens of `Edit` calls whose `old_string` goes stale
  after the format hook reflows the file.
- *Sequencing rule learned:* transforms that WRAP a region (e.g. `Text(...)` →
  `Expanded(child: Text(...))`) overlap with token-level transforms inside that same
  region (a `fontSize:` swap), so the overlap assert fires. Do wrapping transforms in a
  SECOND script run against the already-rewritten file, never in the same pass.
- *This scope's `Color(0x…)` reality:* only 3 distinct literals existed — `0x000B7A52`
  ×45, `0x00000000` ×13, `0x33000000` ×1. The first two are both **alpha `00`, i.e.
  already fully transparent** (`0x000B7A52` is a zero-alpha leftover of the pre-Flock
  green brand, used as `FFButtonOptions.color` on ghost/outline buttons; `0x00000000`
  is a TextField `enabledBorder` "no border" and a tab-pill unselected fill). Both →
  `Colors.transparent`: identical rendering, honest intent, and no theme token exists
  for "nothing." This supersedes the 2026-07-21 sale/business lesson that left
  `Color(0x00000000)` TextField borders alone — converting them is safe and was
  verified with `flutter analyze`. The single `0x33000000` was a real drop shadow →
  `FlutterFlowTheme.of(context).designToken.shadow.md` (note the `.designToken`
  indirection; `.shadow` directly on the theme does not compile).
- *`print()` in this scope was 100% safe to delete — but only because I checked.* All
  29 were `print('X pressed ...')` as the sole body of an `onPressed: () { … }` on a
  **status-badge `FFButtonWidget`** (Joined / Requested / Admin / Creator pills that
  FlutterFlow renders as buttons purely for styling). Deleting leaves
  `onPressed: () {}`, which keeps `FFButtonWidget` enabled (passing `null` would grey
  it out — do NOT "tidy" it to `null`). Zero were inside a `catch` block, so CLAUDE.md
  §5's silent-swallow rule was never engaged. Always dump ±4 lines around every hit
  and confirm the enclosing block before mass-deleting.
- *`fontSize: 10.0` → `12.0` needs a vertical-fit check, and this repo's group-list row
  is exactly the case that fails.* The idiom is
  `Container(width: double.infinity, height: 56.0, …) > Padding(20,8,20,8) > Row > [40px avatar, Expanded(Column[16px title, 10px meta])]`.
  Content height at 10px = 16×1.4 + 10×1.4 = 36.4 into 40 available; at 12px = 39.2 into
  40 — fits at 1.0 text scale and clips at anything above it. Fix that worked:
  `height: 56.0,` → `constraints: BoxConstraints(minHeight: 56.0),` (Container accepts
  `constraints` alongside `decoration`/`width`; the row now grows instead of clipping).
  Applied to 12 such rows. To find them reliably, don't eyeball — for each `fontSize`
  hit, walk backward to the nearest `height:\s*\n?\s*56\.0,` within ~260 lines and
  dedupe; that correctly separated the 12 list rows from the 6 identically-sized
  `height: 56.0` *header bars* in the same files, which must NOT be touched.
- *Real bug surfaced by the font-size bump, fixed by copying the sibling screen:*
  `my_group_widget.dart`'s "`<name>` invited you to join this group" `Text` sits as a
  bare non-flex child of a `Row` (unbounded width ⇒ overflow stripes), while the
  byte-identical block in `all_groups_widget.dart` and `nearest_groups_widget.dart`
  already wraps it in `Expanded(child: Text(...))`. Raising 10→12px would have made a
  latent overflow visible. Wrapped all 5 `my_group` copies in `Expanded` to match.
  Lesson: when a mechanical size bump touches a widget, check whether a *sibling screen
  in the same repo* already has the correct structure — copying the existing correct
  pattern is a zero-invention fix and needs no design call.
- *SafeArea in this scope was already compliant:* all 8 `Scaffold`s wrap `body:` in
  `SafeArea(top: true, child: …)`. `bottom` defaults to `true` in Flutter, so the home
  indicator was already respected — I only added the explicit `bottom: true,` for
  self-documentation (zero behaviour change). Do not "fix" a missing `bottom:` as if it
  were a bug; verify the default first. Worth flagging separately: these Scaffolds set
  `backgroundColor: theme.white` while the content `Container` inside `SafeArea` uses
  `theme.pageBack`, so the safe-area strip can show a different colour than the page —
  a design call, not a mechanical fix.
- *`if (false)` triage finding (report-only task):* `lib/pages/groups/groups_widget.dart`
  is not a live screen at all — it is an unwired FlutterFlow **design stub**
  (`Image.network('https://picsum.photos/seed/437/600')`, hardcoded
  `'Anxiety, Depression & Dementia Wellness Hub'` / `'23 members'` /
  `'Michelle Dam Groups'`), registered in `nav.dart` but never navigated to from
  anywhere in `lib/`. Its 9 `if (false)` branches are 3 tabs × 3 membership-state pills
  (Request / Requested / Joined) stacked in a `Stack` behind a hardcoded
  `if (true) 'join'` pill — i.e. a designer's state gallery, not a disabled feature.
  Before spending triage effort on `if (false)` counts, check whether the file is
  reachable (`grep -rn "<Widget>.routeName" lib/ | grep -v nav.dart`); an orphan stub's
  dead branches are a delete-the-file decision, not a feature decision.

**2026-07-21 — Bottom-nav accessibility (`lib/pages/components/comp_navbar/**`), the
app's first `Semantics(` usage anywhere in 469 files.**
- *The `Semantics` + `InkWell` composition that is correct here (memorise it):*
  `Flexible(child: Semantics(label:, button: true, selected:, child: InkWell(...)))`.
  Both `Semantics` widgets involved default to `container: false`, so the outer
  annotation (label/button/selected), `InkResponse`'s own internal
  `Semantics(onTap: _handleTap)`, and the descendant `Image`'s implicit `image: true`
  flag all **merge into one `SemanticsNode`** — TalkBack/VoiceOver announce
  "Home, button, selected" and the double-tap activation routes through the real
  `onTap`. Do **not** reach for `excludeSemantics: true` as a reflex: it drops the
  whole descendant subtree's semantics **including `InkWell`'s tap action**, leaving a
  node that announces as a button but has no clickable action for the screen reader to
  fire. Only use it when a descendant genuinely creates a *competing labelled* node
  (`Image` with a non-null `semanticLabel`, a nested `Text`, another `InkWell`). A bare
  `Image.asset(...)` with no `semanticLabel` builds `Semantics(container: false,
  image: true, label: '')` — it merges harmlessly, it does NOT duplicate the node.
- *`_model.nav == 'optN'` is NOT the active-tab state — read the `onTap` before trusting
  a brief that says it is.* In this FlutterFlow nav, `_model.nav` is a **transient press
  highlight**: `onTap` sets it, `await Future.delayed(300ms)`, then sets it back to
  `null`. Wiring `Semantics(selected:)` to it would announce "selected" for 300ms after
  a tap and never again. The real active state is the widget's own
  `widget.pagename == 'home'|'community'|'post'|'notification'|'sale'` prop (the same
  expression that already gates the 2dp active-indicator bar). Rule: for `selected:`,
  find whatever expression drives the *visible* active affordance and reuse that
  literally — never a variable that a timer resets.
- *Worked well — paren-matching codemod for "wrap N identical widgets in a new parent":*
  hand-`Edit`ing 5 wrappers into a 1000-line generated file needs a unique `old_string`
  for both the opener *and* the closer, and the closers here were byte-identical 5-line
  `),\n),\n),\n),` tails. A ~90-line Node script that (1) `indexOf`s every
  `child: InkWell(`, (2) walks forward counting parens while **skipping string literals
  and `//` comments** (this file has a prose comment containing `(light plus cut into a
  diamond)` that would otherwise desync a naive counter), (3) splices the wrapper in
  **back-to-front** so earlier offsets stay valid, was exact on the first run. Emit the
  wrapper with sloppy indentation and let `dart format` fix it — but note `dart format`
  does **not** re-indent `//` comment lines, so write multi-line comments already
  correctly indented or fix them with one `replace_all` afterwards.
- *Tap-rect analysis for a `Row` of `Flexible` cells (no measurement tooling needed):*
  the chain here is `Container(height: 54)` → `Column(max)` → `Expanded` → `Row` →
  `Flexible(fit: loose)` → `InkWell` → `AnimatedContainer` → `Stack(fit: loose)` →
  `Column(mainAxisSize: max)` → `Container(width: double.infinity)`. Two facts make the
  hit area full-cell: `width: double.infinity` under a loose parent resolves to
  `maxWidth` (= the flex share), and `Column(mainAxisSize: MainAxisSize.max)` under a
  bounded `maxHeight` fills it. So a *loose* `Flexible` still yields a full-size cell
  **provided a descendant asks for `double.infinity`** — `Flexible` vs `Expanded` is not
  the thing to check; the descendant's width request is. `InkWell` always sizes to its
  child, so the child's size IS the tap rect. Result: ~59×54dp on a 320dp device, ≥44×44
  on both platforms, no change needed. Check the *narrowest* target device, not a
  typical one, when dividing a bar into N cells.
- *`Color(0x19FFFFFF)` as a "press tint" is a light-mode no-op — treat it as a bug, not
  a style:* 10% white painted on `secondaryBackground` (`#FFFFFF` in light mode) is
  literally invisible; it only did anything in dark mode. Swapped all 5 to
  `FlutterFlowTheme.of(context).primary.withAlpha(0x14)` — the exact value the sibling
  `splashColor` already uses in the same `InkWell`, so the two feedback layers compose
  instead of fighting. When replacing a translucent-white/black literal, look for an
  alpha value already in use on the *same widget* before inventing one.
- *Untinted raster assets are the one thing a theme token cannot fix — flag, don't
  hack:* `post_blue.png` (the active "Post" tab) is still the **old pre-Flock blue**
  `#2B4CF0` diamond and renders blue while all four sibling active tabs render
  raspberry `.primary`. It is deliberately not passed a `color:` (an in-file comment
  from an earlier pass explains that a `srcIn` tint flattens the two-tone glyph and the
  plus disappears). Verify such claims cheaply by `Read`ing the `.png` directly — the
  image tool renders it and you can see the two tones. Correct action is a report to
  ui-designer for a re-exported asset, not a code workaround.
- *Cheap truthfulness check for a `selected:` flag:* grep every call site of the
  component for the prop it reads (`CompNavbarWidget(\s*pagename:\s*'…'`). Here only
  4 of the 5 values are ever passed — nothing passes `'post'`, because Create Post is a
  pushed route that doesn't render the navbar. So the Post tab is permanently
  `selected: false`, which is semantically right (it's an *action*, not a destination)
  — but confirm that by inspection rather than assuming the 5th value exists.

**2026-07-21 — SafeArea + typography fix pass, `lib/pages/registration/**`
(`docs/design/ui-review-2026-07-21.md` §2.1/§2.2, the onboarding-flow first impression).**
- *The real root cause behind "no `SafeArea` anywhere in registration":* every one of
  the 9 non-splash screens compensated for the status bar with a **hardcoded
  `].addToStart(SizedBox(height: 50.0))`** on a `Column`'s children list (two of them,
  `login_page` and `email_login_page`, also had `.addToEnd(SizedBox(height: 24.0))`
  for the home indicator). So "add a `SafeArea`" is *not* a pure additive one-liner —
  `SafeArea` reads `MediaQuery.padding`, which is **not consumed** by an ancestor that
  merely inserted a `SizedBox`, so naively wrapping leaves 50 + 47–59 ≈ **~105px of
  dead space** above the back button on a notched iPhone. Always grep the target files
  for `SizedBox(height: 5[0-9]\.0)` / `addToStart` / `addToEnd` *before* wrapping, and
  delete the fake inset in the same edit. Removing it is safe, not "restructuring" —
  it's a leaf value in a `.addToStart(...)` chain and never touches control flow.
- *How to tell whether removing the fake inset moves the background:* look at **which
  side of the background `Container` the `SizedBox` sits on.** In 7 of 9 files the
  `SizedBox(50)` was on the *outer* `Column` (a sibling *above* the
  `Expanded(child: Container(decoration: DecorationImage(dotted map)))`), so the dotted
  backdrop was inset 50px from the top and only the outer body `Container`'s flat
  `pageBack` fill showed above it. In `email_login_page`/`forget_password` the same
  `SizedBox(50)` was *inside* the `SingleChildScrollView`'s content column instead.
  Removing it in the first group makes the backdrop **truly** full-bleed (an
  improvement, and what the review asked for); in the second group it changes nothing
  about the backdrop. Confirmed zero visual color regression first by checking the
  theme: `pageBack` and `primaryBackground` are the **same** hex in both
  `flutter_flow_theme.dart` (`0xFFFFFBF9`) and `flutter_flow_theme_dark.dart`
  (`0xFF15111C`) — so the band that disappears was invisible anyway. Do this token
  comparison before assuming a background swap is cosmetically free.
- *Insertion point rule that keeps art full-bleed:* wrap the **`child:` of the
  background `Container`** (the `SingleChildScrollView`/`Column` holding the content),
  never the `Container` itself and never the `Stack`. Placing `SafeArea` one level
  *inside* the decorated `Container` means the `DecorationImage`/fill still paints
  edge-to-edge through the inset area while the content is pushed clear — which also
  avoids the "colored strip at the bottom" artifact you get when `SafeArea` sits
  *outside* the filled container and the inset region falls back to the parent's color.
- *`splash` is the one screen that must NOT get `top: true`:* its hero photo lives in
  `Expanded(child: Stack(fit: StackFit.expand, ...))` at the **top** of the body
  `Column`, with the copy/CTA block as a **sibling below it**. There is zero
  interactive or text content in the top region, so applying a top inset anywhere just
  inserts dead space between the photo and the "Flock" headline (or letterboxes the
  photo if applied higher up). Used `SafeArea(top: false, bottom: true)` around the
  bottom `Container`'s `child: Padding(...)` — bottom inset only, painted through by
  that `Container`'s own `primaryBackground` fill. Lesson: "wrap the body in
  `SafeArea(top: true, bottom: true)`" is a default, not a law — check whether anything
  in the top region can actually collide with the status bar first.
- *Worked well — Dart-aware paren matcher instead of hand-editing brackets:* wrapping a
  widget in these 350–1350-line generated trees means finding the `)` that closes it,
  which is 200–1200 lines below the opener. A ~40-line Node script that walks forward
  from the opening `(` with a depth counter and a small context stack for `'`/`"`
  strings, `${...}` interpolation, and `//`/`/* */` comments found the right closer in
  all 10 files first try. The string handling is **not optional** here: the dotted-map
  asset path is literally `'assets/images/image_(1).webp'` — a naive counter trips on
  the parens inside that string filename and closes one level too early. (Checked for
  `'''`/`"""` triple-quoted strings first — none in this scope — since those would
  break the simple stack.) Insert `SafeArea(top: X, bottom: Y, child: ` before the
  widget and `,)` after its closing paren, then let `dart format` fix indentation; the
  trailing comma before `)` is valid Dart and formats cleanly.
- *Cheap parse check that isn't a build:* `dart format <dir>` reporting
  "Formatted N files (M changed)" is itself proof every touched file **parses** — if a
  bracket were unbalanced, `format` fails loudly on that file. Pair it with
  `dart analyze <dir> | grep error` (lighter than `flutter analyze`, and safe to run
  while other agents work since it's read-only, unlike `flutter pub get`/`build`).
- *Pre-existing errors to not panic about / not "fix" out of scope:*
  `dart analyze` flagged 11 `undefined_setter`/`undefined_method`/`undefined_identifier`
  errors in `final_steps_mail_page_widget.dart` (`UserTable`, `UserRolesTable`,
  `PublicUserProfileTable`, `currentUserUid`, `currentJwtToken`) — the file references
  the Supabase data layer but never imports `/backend/supabase/supabase.dart` or
  `/auth/supabase_auth/auth_util.dart`. Confirmed not mine by `git show
  HEAD:<path> | grep -c UserTable()` returning 0 (the reference was added to the
  working tree by the in-flight backend rebuild, after the single initial commit).
  When the tree is this dirty, `git diff` is useless for attribution — a diff of a
  file you barely touched showed **1958 changed lines** because HEAD predates the whole
  rebrand. Use `git show HEAD:<file>` targeted greps for attribution, not `git diff`.
- *Scope finding — the review's counts were right for §2.1/§2.2 but §2.3's "replace
  hardcoded colors" had zero targets here:* `Color(0x` returned **0 hits** across all
  13 registration subfolders (an earlier phase already cleaned them, matching the
  2026-07-21 registration polish lesson above). Likewise, after the font sweep every
  single one of the 146 `GoogleFonts.*(` calls in scope is `manrope` — no `baloo2`
  overrides exist inline here at all (display styles come straight from the theme).
  Verify a review's per-scope counts with one grep before planning work around them.

**2026-07-21 — UI-review Sprint-1 mechanical pass, `lib/pages/profile/**` (58 files;
typography drift, 10px text, debug prints, hardcoded colours, SafeArea), per
`docs/design/ui-review-2026-07-21.md` §2.2/§2.6/§2.10.**
- *Worked well — Node script over `Edit` for pure leaf-token swaps on huge files:*
  `user_profile_widget.dart` (5,770 lines) and `other_profile_widget.dart` (4,459)
  cannot be `Read` in full within budget, and the `Edit` tool refuses to touch a file
  not read in-session. A ~30-line Node script that walks the scope dir and does
  `replace` on **leaf value tokens only** (`GoogleFonts.interTight(` →
  `GoogleFonts.manrope(`, `fontSize: 10.0,` → `fontSize: 12.0,`) is the correct tool:
  it never touches control flow, never changes nesting depth, and sidesteps both the
  read-before-edit rule and the stale-`old_string`-after-formatter-hook problem. 32
  font sites + 20 size sites + 13 prints across 6 files in three script runs, zero
  manual edits, `dart analyze` clean. **Order matters:** run every *content* regex
  before any *structural* one, because line-number-based follow-ups go stale — or,
  better, make every pass a content regex so line numbers never matter at all.
- *Regex ordering gotcha:* replace `GoogleFonts.interTight(` **before**
  `GoogleFonts.inter(`. Anchoring on the trailing `(` already makes them disjoint
  (`inter(` can't match inside `interTight(`), but doing interTight first means a
  mistake in the anchor degrades to a no-op rather than producing
  `GoogleFonts.manropeTight(`.
- *`print()` triage rule that held 13/13:* every `print(` in this scope was
  FlutterFlow's codegen stub `onPressed: () { print('Joined pressed ...'); }` on a
  disabled-looking `FFButtonWidget` — pure debug trace, **zero** inside a `catch`.
  Fast way to prove that before deleting anything: `grep -n -B4 "print("` on the
  whole scope and read the 4 lines above each hit in one output; if every one shows
  `onPressed:` / `() {` you're clear. Delete the statement but keep the empty closure
  (`onPressed: () {}`) — replacing it with `null` would make FFButtonWidget render as
  disabled, a behaviour change. Regex `/\n\s*print\(\s*'[^']*'\);/g` handles both the
  one-line and the FF-wrapped two-line (`print(\n    'x');`) forms because `\s*`
  spans newlines.
- *Worked well — finding which raised-font sites actually break a fixed height:* a
  naive "grep for `height:` near the `fontSize:` line" fails, because dart format
  splits `height:\n    56.0,` across two lines and puts it at *deeper* indentation
  than its own `Container(`. The reliable cheap technique is an **indent-decreasing
  ancestor walk**: from the `fontSize:` line, walk backwards keeping a running
  `minIndent` and record any line whose indent is strictly less — that sequence
  reversed *is* the widget ancestor chain (`ListView.separated( → itemBuilder → …
  → Container( → Padding( → Row( → Column( → Text(`). Then `sed` 8 lines from each
  ancestor `Container(` to read its real args. This found the only 4 genuine
  offenders out of 20 sites; the other 16 sat in intrinsic-height `Column`s inside
  `Row`s and needed no layout change at all.
- *The fix for a fixed-height list row:* `Container(width: double.infinity, height:
  56.0, …)` → `Container(width: double.infinity, constraints:
  BoxConstraints(minHeight: 56.0), …)`. Safe because `Container` folds `width` into
  the supplied constraints via `constraints.tighten(width: …)` and then `.enforce()`s
  the parent's — so min/maxWidth still resolve to the parent width, while maxHeight
  goes from 56 to unbounded and the row can grow. Only do this when the row already
  has vertical `Padding` inside (these had `fromSTEB(20, 8, 20, 8)`); otherwise add
  the padding in the same edit or the text touches the row edge once it grows.
  Row-height maths worth doing before deciding: 56 − 16 padding = 40dp content;
  name @16px × lineHeight 1.4 = 22.4 + city @12px × 1.4 = 16.8 → 39.2dp. It "fits"
  at scale 1.0 by 0.8dp, which is exactly the kind of margin that clips at Android
  "Largest" — treat any sub-2dp headroom as a fail, not a pass.
- *Scope finding — earlier passes already closed two of the five brief items:* zero
  `Color(0x…)` literals remained anywhere under `lib/pages/profile/**` (the
  2026-07-21 interaction pass swapped them all to `Colors.transparent`/theme tokens),
  and all 17 `Scaffold`s already had `body: SafeArea(top: true, …)`. Note `SafeArea`'s
  `bottom` parameter **defaults to `true`**, so a review finding of "no `bottom: true`"
  is not a real bug — don't churn 17 generated files adding a no-op argument; verify
  the default and report it instead. Re-run the brief's own triage greps before
  starting: two of five tasks here were already done, which is only discoverable by
  counting first.
- *Diff-reading caution (re-confirmed):* `git diff --stat` on this scope showed
  `profile_widget.dart` +756/−… even though this pass never opened it — pre-existing
  dirty-tree work from the parallel/earlier interaction pass. Always verify your own
  changes with a filtered diff (`git diff -U0 <file> | grep -E "^[-+].*<your token>"`)
  rather than reporting `--stat` numbers as your output.

**2026-07-21 — Shared component library, Wave 1 (`lib/components/app_*.dart`,
`empty_state.dart`, `async_state_view.dart`) per ui-review §2.3/§2.5/§2.7.**
- *Worked well — build the primitive first, then the components on top:* both
  `AppNetworkImage` (placeholder) and `AsyncStateView` (loading skeleton) need the
  same shimmer block, so a 5th tiny file `app_shimmer_box.dart` (`AppShimmerBox` +
  `AppShimmerLine`) was created and imported by both. Dependency graph stays acyclic
  (`app_network_image → app_shimmer_box`, `async_state_view → app_shimmer_box +
  empty_state`) and there is exactly one definition of "what a Flock skeleton looks
  like". Duplicating ~15 lines of gradient/colour code into two files would have
  guaranteed drift the first time the token changes.
- *Token gotcha — `shimmerColor` is translucent in BOTH themes* (`0x1A1C1424` light,
  `0x1AF6F1FA` dark), i.e. it is a *tint to composite over a surface*, not a fill. Using
  it directly as a `Container(color:)` gives an almost-invisible skeleton, and
  flutter_animate's `.shimmer()` defaults to `BlendMode.srcATop` which masks the sweep
  by the child's alpha — so a 0x1A-alpha child swallows the highlight too. Fix that
  worked: `Color.alphaBlend(theme.shimmerColor, theme.alternate)` produces one opaque
  skeleton fill that still reads as "shimmer tint over neutral surface" and keeps the
  sweep visible. Verify any new use of `shimmerColor` against this before assuming it
  is an opaque token.
- *Worked well — no new dependency needed for shimmer:* `flutter_animate: 4.5.0` is
  already in pubspec and ships `ShimmerEffect`; `.animate(onPlay: (c) => c.repeat())
  .shimmer(duration: 1400.ms, color: theme.shimmerHighlight, angle: 0.45)` is the whole
  implementation. Do **not** import `/flutter_flow/flutter_flow_animations.dart` in the
  same file — it declares its own `ShimmerEffect` class and the two names collide.
- *Semantics pattern that actually announces correctly:* wrapping an `InkWell` in
  `Semantics(button: true, label: …)` alone creates *two* nodes (label node + the
  InkWell's own tap-action node) and TalkBack/VoiceOver read them separately;
  `ExcludeSemantics` around the InkWell "fixes" the duplication but deletes the tap
  action, making the control unusable by a screen reader. The correct shape is
  `MergeSemantics(child: Semantics(button: true, enabled: …, label: …, child: InkWell(…)))`
  — one node, label + action + enabled state together. `ExcludeSemantics` is only safe
  around genuinely non-interactive subtrees (used it inside `AppNetworkImage`, where the
  child is a plain image).
- *≥44×44 tap target without growing the glyph:* `InkWell → ConstrainedBox(minWidth/
  minHeight: 44) → Center(widthFactor: 1, heightFactor: 1) → Icon(size: 20)`. The
  `ConstrainedBox` must be **inside** the `InkWell` (the ink hit area is its child's
  size), and the min is clamped in code (`minTapTarget < 44 ? 44 : minTapTarget`) so a
  call site cannot accidentally opt out of the platform minimum on either OS.
- *Press feedback inside the 80–150ms window:* Material's ink splash fade-in is ~600ms,
  which reads as laggy for small icon buttons. Pairing the ripple with an
  `AnimatedScale(0.90, 120ms)` + `AnimatedOpacity(0.7, 100ms)` driven by
  `onTapDown`/`onTapUp`/`onTapCancel` gives instant perceived response while the ripple
  finishes underneath. Same trick as `gradient_primary_button.dart`'s 150ms press scale.
- *Reduced motion:* `MediaQuery.maybeOf(context)?.disableAnimations ?? false` is the
  cross-platform switch (Android "Remove animations", iOS "Reduce Motion"). Gated the
  repeating shimmer and the `easeOutBack` entrance overshoot behind it — a repeating
  `Animate(onPlay: repeat)` is exactly the kind of thing that must stop for
  motion-sensitive users, and it also stops `pumpAndSettle` from hanging if the tester
  ever writes widget tests against these.
- *`AsyncStateView` API shape that fits this codebase:* FlutterFlow screens are full of
  `FutureBuilder`, so besides the plain `AsyncStateView<T>(isLoading:, error:, data:,
  builder:)` constructor there is a `static AsyncStateView<S> fromSnapshot<S>({…})`
  helper. A *static generic method* is the right tool here — a named constructor would
  have had to initialise all 20 fields in an initialiser list (unreadable, and pushes the
  file past the 400-line limit), whereas the static method just forwards. Note
  `isLoading` is derived as `connectionState == waiting && !snapshot.hasData` so a
  refreshing stream doesn't flash the skeleton over data it already has.
- *Error copy must never be `error.toString()`:* `AsyncStateView.describeError` maps
  `SocketException`/`TimeoutException`/permission strings to plain-English sentences and
  `debugPrint`s the raw object **only** under `kDebugMode`. That satisfies CLAUDE.md §5
  ("never silently swallow") without leaking stack/Postgres detail into the UI — and
  avoids adding to the 439 unguarded `print()` calls flagged in the review.
- *Not done / flagged:* these components are built but **not yet adopted** — zero
  existing screen files were touched (other agents were editing screens in parallel).
  The 149 `Image.network` call sites, the icon-only nav/post actions, and the 58 screens
  with divergent loading states still need the Wave-2 swap. Also skipped `flutter build`/
  `pub get` per instruction; validation was `dart analyze` on the five new files only
  (clean, 0 issues) — no on-device Android/iOS render check was possible in this pass.

**2026-07-21 — UI-review Sprint-1 mechanical pass, `lib/pages/events/**` +
`lib/pages/business/**` (typography drift, 10px text, debug prints, colour
literals, SafeArea), per `docs/design/ui-review-2026-07-21.md` §2.2/§2.6/§2.10.**
- *CRITICAL counting lesson — every census number in `ui-review-2026-07-21.md` is
  LINE-based and therefore undercounts.* The dart formatter wraps long FlutterFlow
  argument lists, so `GoogleFonts\n    .interTight(` and `fontSize:\n    10.0` are
  invisible to a single-line grep. In this two-folder scope the review said 38
  typography sites (found 52, +14 wrapped) and 21 undersized-text sites (found 39,
  +18 wrapped). **Always run the sweep twice: once with the naive literal regex,
  then again with a newline-tolerant one** (`GoogleFonts\s*\.\s*interTight\s*\(`,
  `fontSize:\s*10\.0`) and re-verify the remaining count is 0 before declaring done.
  Same applies to `Color\s*\(\s*0x…` — the review's "2 hardcoded colours in events"
  was really 12 (8 wrapped `Color(0x00000000)` in `my_event_widget.dart` alone).
- *`SafeArea(top: true)` is NOT a bug.* Flutter's `SafeArea` already defaults
  `bottom: true` (and left/right). All 12 pre-existing Scaffold bodies in this scope
  were therefore already bottom-safe; adding the explicit `bottom: true,` is a
  readability no-op, not a fix. The one genuinely missing wrapper was FlutterFlow's
  *loading-gate* Scaffold (`if (!snapshot.hasData) return Scaffold(body: Center(
  CircularProgressIndicator))` in `create_page_widget.dart`) — so enumerate `body:`
  once per `Scaffold(` occurrence, not per file: a single file can hold two
  Scaffolds and a file-level "contains SafeArea" count hides the gap entirely.
- *Sizing maths that decided the fixed-height fixes (reusable recipe):* a text row's
  height is `fontSize × lineHeight`, and this repo pins `lineHeight: 1.4` on nearly
  every `.override(...)`, so 10→12px costs **+2.8px per rendered line**. Sum the
  lines inside the fixed-height ancestor before deciding. Concretely:
  - The `Container(height: 188.0)` event card (byte-identical in `all_events`,
    `event_details`, `my_event`) had ~13px slack in its normal branch but already
    overflowed by ~1px in the `isInvited` branch; +12px of growth made overflow
    certain → raised to `208.0`.
  - The `Container(height: 320.0)` grid card (`ending_event`, `latest_event`) was
    **dead code**: `SliverGridDelegateWithFixedCrossAxisCount` hands each child
    `BoxConstraints.tight`, so the tile height (`itemWidth / childAspectRatio`)
    always wins and the `height:` is ignored. On a 360dp device the tile was only
    ~298px against ~320px of content — a pre-existing overflow. Converting
    `height:` → `constraints: BoxConstraints(minHeight:)` there would have been a
    **no-op**; the only real lever is `childAspectRatio` (0.52 → 0.48).
    **Always check the parent's constraint type before "fixing" a fixed height.**
- *Why `height:` → `minHeight:` is often unsafe in these generated trees:* the 188px
  card's subtree is `Row → Expanded(Column(`**`Expanded`**`(Column…), Stack(button)))`.
  Relaxing the ancestor to an unbounded max height makes that inner `Expanded` throw
  *"RenderFlex children have non-zero flex but incoming height constraints are
  unbounded"*. Removing the flex to compensate would un-pin the CTA from the card
  bottom (a visual change, and restructuring is banned). So the minimal-risk move for
  a **flex-bearing** subtree is to *raise* the fixed height, and reserve the
  min-height+padding conversion for **leaf** containers whose only child is a `Text`
  — e.g. the "Ending Soon" badge: `Container(width: 70, height: 18)` →
  `constraints: BoxConstraints(minWidth: 70, minHeight: 18)` +
  `padding: EdgeInsetsDirectional.fromSTEB(6,2,6,2)`, which is genuinely free and
  also buys Android "Largest" font-scale headroom. **Width matters as much as height
  on badges:** "Ending Soon" at 12px w600 Manrope measures ~72px against a 70px fixed
  width — it would have clipped horizontally even though the height still fit.
- *All 5 `print()` calls in this scope were FlutterFlow's placeholder
  `onPressed: () { print('Button pressed ...'); }`, none inside a `catch`.* The safe
  removal is `onPressed: () {}` — **not** `onPressed: null`, because `FFButtonWidget`
  renders a null callback as a *disabled* button, which would silently change the UI.
  One regex matching the whole callback
  (`/onPressed:\s*\(\)\s*\{\s*print\(\s*'[^']*'\s*\);\s*\}/g`) handles the wrapped and
  unwrapped forms in a single pass.
- *Zero-alpha literals:* `Color(0x00000000)` **and** `Color(0x00FFFFFF)` are both just
  "no fill / no border" → `Colors.transparent` (this repo already uses that idiom in
  the sibling branch of the very same ternary, which is the confirming signal). The
  translucent-white badge pills `Color(0x1AFFFFFF)` drawn over an arbitrary photo
  behind a `BackdropFilter` stay hardcoded — per the 2026-07-20 dark-mode lesson they
  are intentionally theme-invariant, and there is no token for them.
- *Tooling:* writing the playbook entry through `node -e "...template literal..."` in
  the Bash tool failed catastrophically (bash expanded the backticks/globs/`(`s inside
  the JS string, and `\0` sequences tripped "Octal escape sequences are not allowed in
  template strings"). Re-confirmed the 2026-07-21 registration-pass lesson: **write
  prose/scripts to a real file first (Write tool → scratchpad), then `node`/append it
  — never inline multi-line content with backticks into `bash -c`.**
- *Verify tip that keeps working:* `dart format <dirs>` then
  `dart analyze <dirs> | grep -cE '^\s*error'` → expect `0`. This scope reports ~1,646
  analyzer *issues*, all pre-existing `prefer_const_constructors`-class info/warnings;
  only the `error` count is a meaningful pass/fail signal. Also re-confirmed the
  2026-07-20 note: `git diff --stat` over the scope lists files you never touched
  (this tree has been dirty since earlier phases) — reconcile against your own script
  output, not the diff, when reporting what changed.

**2026-07-21 — UI-review Sprint-1 mechanical pass, `lib/pages/community/**` +
`lib/pages/search/**` (typography drift, 10px text, debug `print`, colour literals),
per `docs/design/ui-review-2026-07-21.md` §2.2 / §2.6 / §2.10.**
- *Grep undercounts both `GoogleFonts.*(` and `fontSize: 10.0` in these files.* The
  FlutterFlow/dart-format output wraps at ~80 col at deep nesting, so the same construct
  appears as `font: GoogleFonts\n    .interTight(` and `fontSize:\n    10.0,`. A
  single-line `grep -c "GoogleFonts.interTight("` reported 25 in `community_widget.dart`
  when the true count was 27, and `grep -n "fontSize: 10.0"` found 24 when there were 25
  (the 25th, a "N people contacted this business" label, was also missed by the review
  doc's own census). **Always use a whitespace-tolerant regex** —
  `/GoogleFonts(\s*)\.(\s*)(interTight|inter)\(/` and `/fontSize:\s*10\.0/` — and
  cross-check the two counts before declaring a mechanical sweep complete.
- *Indentation-based ancestor detection is unreliable in these files; use paren depth.*
  To decide whether raising a 10px label would clip, I needed each text's enclosing
  fixed-height `Container`. An indent-walk (“ancestors are lines at strictly decreasing
  indentation”) **silently misses** the very common wrapped-opener shape
  `child:\n    Container(\n  height: 188.0,` — the `Container(` line is *more* indented
  than both its own `child:` key and its own arguments, so it never enters the walk. That
  cost me a wrong "no fixed-height ancestor" verdict on 6 sites in `search_widget.dart`.
  The reliable tool is a small Node scanner that tracks **paren depth**, recording the
  identifier immediately before each `(` and the `height:` values declared at that call's
  own depth. It must handle Dart strings properly — `'...'`, `"..."`, `r'''...'''`,
  `'''...'''` **and** `${...}` interpolation (push a nested *code* mode on `${`, pop on the
  matching `}`); without interpolation handling the scanner desyncs on the first
  `'${getJsonField(...)}'` and silently produces zero results for the whole file. Also give
  the key-value lookahead slice ≥200 chars, not 40 — at 70+ spaces of indentation the value
  is past a 40-char window and wrapped `fontSize:` sites are silently skipped.
- *`height:` → `constraints: BoxConstraints(minHeight:)` is only safe when no descendant
  in that subtree uses `Expanded`.* Worked for the 56dp group/search list rows (their inner
  `Column` has no flex children). **Broke conceptually** for the 188dp event list-row cards:
  `Container(188) > Padding > Row > [Image, Expanded(Column([Expanded(Column), Stack(button)]))]`
  — removing the bounded height makes the inner `Expanded` throw "RenderFlex children have
  non-zero flex but incoming height constraints are unbounded" inside a vertical `ListView`.
  For those, the correct minimal fix is to **raise the fixed height** (188 → 200, derived from
  the measured worst case) rather than force a min-height. Check for `Expanded`/`Flexible`
  inside the subtree *before* converting any fixed height.
- *Measure before deciding "12px won't fit"; don't eyeball.* Reliable arithmetic for these
  FlutterFlow cards: FlutterFlow's `lineHeight: N` maps to `TextStyle.height`, so a line box
  is exactly `fontSize * N` (10→14.0, 12→16.8 at 1.4). An icon+label `Row` is
  `max(iconHeight, lineBox)`, so raising a 10px label sitting next to a 16px icon costs only
  +0.8px, while a `maxLines: 3` description costs +8.4px. `.divide(SizedBox(height: N))`
  adds `N × (children-1)`. That let me prove the 56dp rows had 0.8px of slack (fix needed),
  the 120dp marketplace card had ~18px (safe as-is) and the 316dp event *grid* cards were
  already overflowing at 10px on 360dp-wide Androids.
- *A `Container(height:)` inside a `GridView` cell is dead code — the real constraint is
  `childAspectRatio`.* `SliverGridDelegateWithFixedCrossAxisCount` hands children **tight**
  constraints, so `height: 316.0` on the event card never applies; effective cell height is
  `((screenWidth - horizontalPadding - crossAxisSpacing) / 2) / childAspectRatio`. At
  `childAspectRatio: 0.52` that is 298dp on a 360dp-wide phone, and the card's content
  needs 126.4dp at 10px against 122.1dp available — i.e. **the card clips today, before any
  font change**. Raising those 12 labels to 12px would have widened an existing overflow, and
  the only one-number fix (`0.52` → `~0.47`) is exactly the "let the row grow taller vs. drop
  an element" call the review doc lists as an **open owner decision** (§4.3). Left them at
  10.0 and reported the measurements + the recommended single-number change, rather than
  pre-empting the decision. *Lesson: when a fix requires choosing between two options the
  owner has explicitly reserved, stop and report with numbers — that is more useful than
  either guessing or a bare "skipped."*
- *Badge pills over photos: swap fixed `width`/`height` for `constraints` + `padding`.* The
  "Ending Soon" pill was `Container(width: 70, height: 18)` with an `alignment` and a
  `BackdropFilter` parent. `'Ending Soon'` at 12px w600 is ~71px, so the fixed 70px width
  would have forced a wrap to two lines and a vertical overflow. Replacing both with
  `constraints: BoxConstraints(minWidth: 70.0, minHeight: 18.0)` +
  `padding: fromSTEB(6,2,6,2)` keeps the original visual footprint as a floor while letting
  the pill hug larger text — the general recipe for any hug-content badge inside a `Stack`.
- *`print()` removal is safe here, but check the callback body first.* All 15 hits were
  FlutterFlow's placeholder `print('… pressed ...');` as the **only** statement of an
  `onPressed: () { … }` on a decorative status button ('Joined' / 'Requested' / 'Admin' /
  'Following' / 'Contact'). Deleting them leaves `onPressed: () {}`, which is *not*
  equivalent to `onPressed: null` — `FFButtonWidget` disables itself only on null — so the
  buttons stay visually enabled and unchanged. Zero of the 15 were the sole statement of a
  `catch` block (CLAUDE.md §5 would forbid deleting those); confirm that with a
  `grep -B8 "print("` context pass, not by assumption. A two-regex Node pass handles both
  the single-line and the `print(\n    '…');` wrapped form.
- *`Color(0x1AFFFFFF)` still has no theme token and should stay a literal.* Re-confirmed
  against `flutter_flow_theme.dart`: the nearest candidate is `accent4` (`0xCCFFFFFF`, 80%
  white) which is both far too opaque and theme-varying — it would invert in dark mode and
  destroy an intentionally theme-invariant translucent pill drawn over an arbitrary photo.
  Superseded nothing; reinforces the 2026-07-20/2026-07-21 lessons. Only `Color(0x00000000)`
  is safely mechanical → `Colors.transparent`.
- *Ordering that avoided all stale-`old_string` pain on 6k/10k-line files:* do every
  line-number-addressed change with Node scripts (which assert the expected line content and
  `process.exit(1)` on mismatch) **first**, in one batch, because the `PostToolUse:Edit`
  formatter hook does not run for Bash-driven writes and therefore never invalidates the
  line numbers mid-run. Only use the `Edit` tool for the last one or two context-addressed
  changes, then run `dart format` on the scope once and `flutter analyze <dirs> | grep -E
  "^\s+(error|warning) -"` (985 `info` issues are pre-existing noise; 0 errors/warnings is
  the real pass signal).

**2026-07-21 — UI-review Wave 2 (shared-component adoption), `lib/pages/notification/**`
+ `lib/pages/sale/**`, per ui-review §2.3 / §2.5 / §2.7.**
- *The single-line-grep undercount trap bit again, and the fix that works.* A plain
  `grep "Image.network"` found **14** sites in this scope; the newline-tolerant
  `Image\s*\n?\s*\.\s*network\s*\(` found **16** — `sale_details_widget.dart` and
  `listing_details_edit_widget.dart` both contain `child: Image\n    .network(`
  where dart format wrapped the receiver away from the member. Same class of miss as
  the `GoogleFonts\n  .interTight(` and `splashColor:\n  Colors.transparent` lessons
  above. Standing rule reconfirmed: **the `Grep` tool with `multiline: true` and
  `\s*\n?\s*` between every token is the only trustworthy census**, and re-run it at
  the END to prove 0 remaining (this pass ended at 0 of 16).
- *Best edit engine for 2.7k–3.8k-line generated files, refined:* a Node script of
  `sub(label, from, to, expectedCount)` calls that `split`/`join` on **exact literal
  blocks copied out of the file** and `process.exit(1)` on any count mismatch. Two
  properties make this better than either whole-file rewrite or a pile of `Edit`
  calls: (a) `full-output-enforcement` truncation risk is structurally zero because
  the model never re-emits the file, and (b) the count assertion catches "the
  formatter reflowed this since I read it" *before* anything is written, instead of
  producing a silent partial edit. Three scripts applied 16 + 12 + 9 replacements
  with zero rework. When a `sub` DOES fail (mine failed once, on a `semanticLabel:`
  block that `dart format` had re-wrapped after an earlier script ran), the fix is to
  `sed -n` the current text back out and paste it verbatim — never hand-guess the
  wrapping.
- *`Container(height: N)` → `constraints: BoxConstraints(minHeight: N)` — check the
  GRANDparent, not just the subtree.* The marketplace card's right column was
  `Expanded(child: Container(height: 80, child: Column(spaceBetween, …)))`, but that
  80 was NOT the binding constraint: the card itself was `Container(height: 120)` with
  20+19 padding, i.e. 81dp of content space. Relaxing only the inner 80 would have
  been a **no-op**. Both had to move together (120 → minHeight 120, 80 → minHeight 80).
  Generalises the earlier "a `height:` inside a `GridView` cell is dead code" lesson:
  before converting any fixed height, walk **up** until you find the widget that
  actually supplies the bounded constraint.
- *Why that conversion was safe here (and the test to run every time):* the vertical
  chain was `Column(mainAxisSize.max, children:[Padding, divider])` → `Row` →
  `Expanded/Flexible` → `Container` → `Column(mainAxisSize.max, spaceBetween,
  children:[Row, Row])`. Every `Expanded`/`Flexible` in that path is a child of a
  **Row** (horizontal flex), so unbounding the height cannot trigger "RenderFlex
  children have non-zero flex but incoming height constraints are unbounded". The
  check is not "does the subtree contain `Expanded`" — it is "does the subtree contain
  an `Expanded` whose parent is a **Column**". Also worth knowing: `Column(mainAxisSize
  .max)` under an unbounded maxHeight shrink-wraps (RenderFlex sets `idealSize =
  allocatedSize` when `canFlex` is false) and then `constraints.constrain()` re-applies
  the `minHeight`, so `spaceBetween` still distributes the min-height slack. Behaviour
  at normal text size is byte-identical; the box only grows.
- *TASK-0 scoping reality:* the "22×22 unread badge" the brief asked me to fix does
  **not exist** in `notification/` or `sale/` — grep for `width: 22.0` returns 0. Those
  badges live in `lib/chat/**`. What notification/sale have is a 10×10 grey dot with a
  5×5 primary dot inside and **no text at all**, so it cannot clip at any text scale.
  Verify a brief's geometry claim with a grep before designing a fix for it.
- *`AppIconButton` on a control that has a visible disc: pass the disc as `iconWidget`,
  not as a wrapper.* Wrapping `AppIconButton` in the existing `Container(34×34)` makes
  its internal `ConstrainedBox(minWidth/minHeight: 44)` overflow the 34dp box. The
  correct shape is `AppIconButton(iconWidget: Container(34×34, shape: circle, child:
  <Stack with icon + badge>))` — the disc renders unchanged and only the invisible hit
  area grows to 44. Cost to declare honestly in the report: the header `Row`'s height
  goes 38 → 44 (header +6dp) because the button is now the tallest child. Also convert
  the FlutterFlow `BorderRadius.only(4 × Radius.circular(100))` idiom to
  `shape: BoxShape.circle` in the same edit — same render, far less noise, and it keeps
  the bracket count balanced for a scripted splice.
- *`MergeSemantics` around a whole card is CORRECT only when the card has no nested
  interactive child.* The 3 marketplace listing cards took it cleanly (their only other
  control is an `if (false)` bookmark), and the right move there was to **delete the
  thumbnail's `semanticLabel`** at the same time — otherwise the merged node announces
  the listing title twice ("Photo of Chair, Chair, 2 hours ago…"). The 6 notification
  rows were deliberately **left unwrapped**: each contains its own "Notification
  options" `AppIconButton`, and `MergeSemantics` would fold that button's tap action
  into the row node and make it unreachable for TalkBack/VoiceOver. Non-merging
  `Semantics(button: true)` is not an alternative — it yields two nodes read
  separately. Rule: merge the card only when it is a leaf-interactive card.
- *A `RefreshIndicator` can sit above the scrollable, not on it.* Notification has six
  sibling tab bodies, only one mounted at a time, each its own `SingleChildScrollView`.
  One `RefreshIndicator` wrapped around the parent `Column` serves all six, because
  `RefreshIndicator` reacts to bubbling `ScrollNotification`s and only ignores
  `notification.depth != 0` (one scrollable per subtree here, so depth is always 0).
  Its `Stack` passes loosened-but-finite constraints down, so the `Expanded` tab bodies
  inside still work. That is 1 wrap instead of 6. The horizontal filter-chip
  `SingleChildScrollView` sits outside the wrap, so it can't fire it.
- *`physics: const AlwaysScrollableScrollPhysics()` is not optional*, and neither is
  auditing what `onRefresh` can throw. `getSaleHomePage` (a hand-written custom action)
  `throw`s on any non-200; an uncaught throw inside `onRefresh` leaves the spinner
  spinning forever. Every refresh callback added this pass is `try`/`catch`-wrapped and
  sets a `bool _loadFailed` on the State, which drives a real `EmptyState(icon:
  wifi_off, 'Try again', onAction: <same refresh method>)` branch. That same guard was
  also added to `sale_widget`'s `initState` fetch, which previously could throw and
  strand the page on its skeleton forever with no way back — a pre-existing bug found
  only by reading the action's source before wiring the button.
- *Don't re-do an empty state that already exists.* ui-review §2.7 asks for `EmptyState`
  on "no notifications / no listings", but every one of the 11 empty branches in this
  scope already routes through `CompNoDataFoundWidget` with illustration + spec-quality
  copy ("Nothing new yet", "You haven't listed anything yet"). Swapping those for the
  new `EmptyState` would have been a downgrade (glyph badge instead of a 160dp
  illustration) and pure churn. The real §2.7 gap in this scope was the **error** state,
  which did not exist at all — that is where `EmptyState` earned its place. Read the
  existing branch before adopting a component that "should" go there.
- *`AsyncStateView` was deliberately not adopted here, and why.* Both screens gate on a
  plain `bool` (`_model.showData` / `_model.show`) and their data lives in
  `FFAppState()` JSON, not a typed `T` — and the "data" branch is six/two mutually
  exclusive conditional `Expanded`s, not one builder. Forcing `AsyncStateView<T>` around
  that means restructuring the tab switch, which is banned. Taking only the *pieces* it
  would have rendered (existing shimmer skeleton, kept; error + retry, added) delivers
  the whole user-visible payoff with none of the restructuring risk.
- *Scratchpad is SHARED between parallel agents.* My `scan.js` silently became another
  agent's `scan.js` mid-run (same generic filename, same directory) and started
  printing nothing. Prefix every scratchpad file with the agent + task
  (`viora_fe_wave2_*.js`) when other agents may be running, and never leave a `.bak`
  there that you'd actually rely on.


**2026-07-21 — Wave 2 shared-component adoption + code-drawn nav glyph
(`lib/chat/**`, `lib/pages/components/comp_navbar/**`, `lib/components/**`).**
- *The single most useful technique this pass: decode the PNG and MEASURE it before
  hand-tuning a code-drawn replacement.* I was asked to replace the untintable
  `post_blue.png`/`post_grey.png` nav glyph with a `Transform.rotate`d rounded square.
  My first-guess constants (square side = `0.68 * size`, i.e. diamond diagonal = 96%
  of the box) were **25% too large** — the real assets put the diamond bbox at
  74/96 = **77.1%** of the canvas. A ~40-line Node PNG decoder (parse IHDR/IDAT,
  `zlib.inflateSync`, undo the 5 per-scanline filters — filter-type byte then
  Sub/Up/Average/Paeth) gives raw RGBA and lets you measure everything exactly:
  alpha bbox -> glyph span; run-lengths along the centre row/column -> plus extent and
  stroke thickness; chord width one pixel in from the vertex -> corner radius via
  `chord ~= 2*sqrt(2*r*d)` => `r = chord^2/(8d)`. Numbers recovered: diamond 0.771 of
  canvas, corner arc r = 8/96 (= 0.153 of the square's side), plus extent 27/96 =
  0.281 (identical in both PNGs), stroke 4/96 blue vs 6/96 grey. **Do this instead of
  eyeballing a thumbnail** — the `Read`-the-image preview is far too small to judge
  proportion, and every constant you guess wrong is a permanent visual regression.
- *Discovery that changes how you build the replacement:* `post_blue.png`'s plus is a
  **true alpha-0 knockout** (197 fully-transparent interior pixels), while
  `post_grey.png`'s plus is an **opaque lighter grey** (`#B2B2B2` on `#979797`) — the
  two assets were not even built the same way. A code-drawn knockout has to fake it
  by painting the plus in `secondaryBackground` (the bar surface). That is pixel-
  identical on the bar itself; the only divergence is under the tab's press tint
  (`primary.withAlpha(0x14)` `AnimatedContainer`), where a real knockout would show
  the tinted bar and ours shows the untinted one — an 8%-alpha difference, invisible.
  Say this out loud in the report rather than claiming a perfect match.
- *`Transform.rotate` does not change layout size, which is exactly what you want
  here.* `SizedBox(size) -> Center -> Transform.rotate(pi/4) -> Container(side, radius)`
  keeps the widget's layout box at the original `28.0` even though the painted
  diagonal is `side * sqrt(2)`, so a nav-bar swap is genuinely zero-layout-change.
  Build the plus from two rounded `Container` bars in a `Stack(alignment: center)`
  inside a `Transform.rotate(-pi/4)` rather than an `Icon(Icons.add)`: material's
  `add` glyph only fills 14/24 of its em box and its bar is pinned at 2/24 of the
  icon size, so you cannot independently control extent and stroke — with two
  Containers both are free parameters and match the measured ratios directly.
- *Don't stack two labelled `Semantics` on the same node.* `Semantics(container:
  false)` (the default) does not create its own node — it attaches its config to the
  nearest node-forming ancestor. So wrapping a conversation row in
  `Semantics(button: true, label: 'Open conversation with Asha')` AND giving the
  avatar inside it `AppNetworkImage(semanticLabel: "Asha's profile photo")` makes
  TalkBack/VoiceOver read **both, concatenated**. Rule: label the row OR the avatar,
  never both. I kept `semanticLabel` on avatars only where nothing else labels the
  subtree (`message_page` header, `comp_new_message` search rows, `comp_share`
  picker) and dropped it inside the already-labelled chat-list row.
- *`FlutterFlowIconButton` is already >=44dp but has no label.* It renders a Material
  `IconButton`, which carries the platform 48x48 minimum tap target by default, so
  converting back/close buttons to `AppIconButton` buys nothing on sizing — the only
  gap is the missing accessible name, and `FlutterFlowIconButton` exposes no
  `tooltip`/`semanticLabel` param (and `lib/flutter_flow/**` is off-limits). Correct
  minimal fix: wrap the call site in `Semantics(label: ..., button: true, child: ...)`.
  Reserve the full `AppIconButton` conversion for genuinely bare `InkWell`+`Icon`
  (24x24 hit area) and for buttons you also want haptics/press-scale on.
- *`AppIconButton(iconWidget:)` is the escape hatch for "small visual chip, big hit
  area".* The chat/message "options" control is a 34dp grey disc — passing it as
  `backgroundColor` would have inflated the visible disc to 44dp. Passing the whole
  existing `Container(34, 34, decoration...)` as `iconWidget` and leaving
  `backgroundColor` null keeps the 34dp visual, centres it in the 44dp
  `ConstrainedBox`, and puts the ripple on the full 44dp circle. Note
  `AppIconButton` applies `IconTheme.merge(size: iconSize)` around `iconWidget`, so
  pass `iconSize:` equal to the *inner* icon's size (16.0 here) or a nested
  size-less `Icon` will resize.
- *`async` closures fit a `VoidCallback`.* `AppIconButton.onTap` is `VoidCallback?`
  (`void Function()`), and `() async { ... }` returns `Future<void>`, which is
  assignable because `void` accepts any return type. So a FlutterFlow
  `onPressed: () async { 40 lines of Supabase calls }` moves across to `onTap:`
  verbatim — no signature change, no `unawaited` wrapper, no analyzer complaint.
  Remember to delete the call site's own `HapticFeedback.lightImpact()`:
  `AppIconButton` already fires one (`enableHaptic` defaults true) and you get a
  double tick otherwise.
- *Judgement call I made and would repeat — do NOT add pull-to-refresh to a message
  thread.* `message_page` loads the **whole** thread (`MessagesTable().queryRows`
  with `.order('created_at')` and no `limit`/`range`), already re-runs that query
  from a realtime `actions.subscribe('messages', ...)` callback, and that callback ends
  with `columnController.animateTo(maxScrollExtent)`. So (a) there is nothing a
  manual refresh would fetch that realtime hasn't already, and (b) any refresh path
  reachable from the *top* of the scroll view would snap the user back to the newest
  message — the exact opposite of the "load older" the gesture implies at the top of
  a bottom-anchored thread. Real load-older needs a paginated query that does not
  exist yet; that is a backend prerequisite, not a UI omission. Skipped and reported
  with the reasoning instead of adding a mechanically-correct but wrong affordance.
  Same call for `archived_chats_page`: it has **no query at all** (hardcoded
  'Jacob Jones' row), so a `RefreshIndicator` there would be a spinner attached to
  nothing.
- *Empty state on a screen with no data layer:* `archived_chats_page` can never be
  empty because its one row is hardcoded, so an `EmptyState` there has no live
  branch. Rather than invent a data structure or skip the task, I added a documented
  seam — `bool get _hasArchivedChats => true;` with a comment saying to swap it for
  the real query result — and gated `if (!_hasArchivedChats) EmptyState(...)` /
  `if (_hasArchivedChats) ListView(...)` on it. Worth knowing: the analyzer does
  **not** constant-fold through a getter, so this produces **zero** `dead_code`
  warnings (a bare `if (false)` or a `static const bool` would have). Wrapping in
  `if (...)` also adds no paren nesting, so the existing `ListView`'s closing brackets
  hundreds of lines below stay valid — only indentation changes, and `dart format`
  fixes that. That is a much safer shape than `? :` in a generated tree.
- *`EmptyState` already has `illustrationAsset:`* (not in the brief's quoted
  signature). For screens that already had a good illustration + copy (chat's
  `empty_chat.png` / "Start the conversation and break the silence.") the right move
  is to pass the existing asset through and add only the missing CTA — don't demote a
  designed illustration to the generic glyph badge just because the brief listed
  `icon:`. Read the component before assuming its API from the task description.
- *Small refactor that paid for itself:* the chat empty-state CTA and the FAB both
  need to open `CompNewMessageWidget`. Extracting one `Future<void>
  _openNewChatSheet()` on the State (and calling it from both) is ~20 lines shorter
  than duplicating the `showModalBottomSheet` + `GestureDetector` + `MediaQuery
  .viewInsetsOf` boilerplate, and it is additive — it does not restructure the
  generated widget tree, which is what CLAUDE.md section 5 actually forbids.
- *Bracket bookkeeping when adding a wrapper by hand:* every `Semantics(child: ...)`
  I inserted needed exactly one extra `),` added at the matching closer, hundreds of
  lines away. The cheap way to find it is to grep for a distinctive *tail* fragment
  (`).animate().fadeIn(duration: 260.ms`, `originalFilename: '');`) rather than
  counting parens, insert a bare `),` on its own line at sloppy indentation, and let
  the `PostToolUse` formatter hook re-indent. **The hook running at all is itself the
  parse check** — if the file were unbalanced, `dart format` would fail. Confirmed
  with `dart analyze <dirs> | grep -c "error -"` -> 0 after each file.
- *Counting note (re-confirms the standing rule):* the brief's floor of 6
  `Image.network` in `lib/chat/**` was exactly right this time, but only because I
  used `Grep(multiline: true)` with `Image\s*\n?\s*\.\s*network\s*\(` — several are
  wrapped as `child:\n  Image.network(` at 60+ spaces of indentation. The same
  newline-tolerant scan found **2 more** in `lib/components/`
  (`comp_pageview_widget.dart` post carousel, `comp_share_widget.dart` share-picker
  avatars) that the chat-scoped floor never mentioned; both are in scope and were
  converted. Always re-run the scan across the *whole* assigned scope, not just the
  folder the count was quoted for.

**2026-07-21 — UI-review Wave 2 component adoption, `lib/pages/community/**` +
`lib/pages/search/**` (AppNetworkImage / AppIconButton / AsyncStateView / EmptyState /
RefreshIndicator), per `docs/design/ui-review-2026-07-21.md` §2.5/§2.7/§2.3.**
- *The single biggest tooling lesson of this pass: a naive quote-skipper desyncs on Dart
  string interpolation and silently makes a whole-file scan return NOTHING.* My first
  "find every icon-only InkWell" audit reported zero hits across both files. The bug: the
  scanner treated `'${getJsonField(FFAppState().matchedUsers, r"""$[0].total_unread_message_count""").toString()}' != '0'`
  as a string ending at the first inner quote, so every subsequent paren depth was wrong.
  A correct Dart-source bracket matcher in this repo MUST handle, in one function:
  (a) `r` / `R` raw prefix (check `src[i-1]`), (b) triple quotes `'''`/`"""`, (c) `\`
  escapes only when NOT raw, and (d) `${ ... }` interpolation — push a nested *code* mode
  on `${`, recursing into `skipString` for quotes inside it, pop on the matching `}`.
  Also skip `//` line comments. With that fixed, the same audit found the 3 real sites.
  **A scan that returns zero on a 10k-line FlutterFlow file is a bug until proven
  otherwise — re-run it with the filter removed and confirm the raw match count first.**
- *Why the earlier (buggy) scripts still produced correct code, and the check that proves
  it:* `convert_images.js` ran with the broken skipper, but every replacement is
  `src.slice(start, end)` → if `end` had been wrong the emitted Dart would not parse.
  `dart format` **fails on unparseable Dart**, and `dart analyze | grep -cE '^ +(error|warning) '`
  → 0 is the second gate. Run both after every scripted splice; together they make a
  mis-computed offset impossible to ship silently. Also assert the site count against an
  independent `Grep(multiline: true)` census taken *before* the run (35 `Image.network`
  found = 35 converted).
- *Offset-based splice engine, re-confirmed and refined:* collect `{start,end,text}` from
  the ORIGINAL buffer, assert no two ranges overlap, sort descending, splice. New wrinkle
  learned here: **a nested pair (wrap the outer `Container`, add `physics:` to the
  `ListView` inside it) legitimately overlaps** and trips the assert. Fix is not to relax
  the assert — run the INNER edit as its own pass first, then re-read the file and run the
  outer pass. Line numbers for the outer site are unaffected because the inner insertion
  is below it. Same rule as the 2026-07-21 "wrapping transforms go in a second run" lesson.
- *`dart format` reflows enough to move line numbers by ~75 lines in a 10k-line file*, so
  every line-addressed config must be regenerated from a fresh `grep -n` immediately
  before the script runs, and the script must **assert** `src.slice(0,idx).split('\n').length === expectedLine`
  and `process.exit(1)` on mismatch. That assert caught a real off-by-two (I read
  `sed -n '179,192p'` output and assumed the first *interesting* line was 179 when
  `FlutterFlowIconButton(` was actually on 181).
- *`AppNetworkImage` adoption rule that avoids double-clipping:* every one of the 35 sites
  in this scope already sat inside either `ClipRRect(borderRadius: …)` or
  `Container(clipBehavior: Clip.antiAlias, decoration: BoxDecoration(shape: BoxShape.circle))`.
  So the correct swap is **keep the parent clip, pass neither `borderRadius:` nor
  `isAvatar:`** — and use `fallbackIcon: Icons.person_rounded` to still get the person
  glyph on an avatar. `isAvatar: true` would have added a second `ClipRRect(9999)` inside
  an already-circular parent. `AppNetworkImage(width: null, height: null)` is safe inside
  a tight parent (`SizedBox(null,null)` just forwards the constraints); it is also safe
  in an unbounded column because `Container` with a decoration, no child and a
  non-tight constraint collapses via `LimitedBox(0,0)` rather than throwing.
- *`GradientAvatarRing` already owns `ClipOval` + `SizedBox`*, so the own-avatar site is a
  1:1 `Image.network` → `AppNetworkImage(fit: cover, fallbackIcon: person)` swap with no
  size args at all. Don't add any.
- *Growing a tap target to 44 is only free when the ancestor has no fixed height.* The 11
  "see all" `arrow_forward` buttons sit in section-header `Row`s inside `Container`s with
  **no** `height:`, so `AppIconButton` (24px glyph, 44x44 hit area) costs ~+19dp of header
  height and cannot overflow — accepted. The controls I deliberately did NOT convert are
  the ones where enlarging would resize a *visible* chip: the Community messages button
  is a 34x34 `greyL2` circle (`AppIconButton(backgroundColor:)` paints the Material at the
  full 44 target, so the circle itself would grow), and the two post-card like buttons are
  ~32x34 next to comment/share siblings that would stay small. Those got
  `MergeSemantics(Semantics(button: true, label: …))` instead: full screen-reader fix,
  zero pixels moved. **Report the residual sub-44 targets as a designer decision rather
  than silently resizing one control in a row of four.**
- *`FlutterFlowIconButton` takes no semantic label*, so the only way to announce the
  back arrows is the same `MergeSemantics > Semantics(button:, label:)` wrapper. It is a
  pure wrap (no layout node with size), safe on both platforms.
- *All 4 `GestureDetector(` "hits" in these files were false positives* — every one is
  FlutterFlow's `showModalBottomSheet(builder: (context) => GestureDetector(onTap: unfocus, …))`
  keyboard-dismiss wrapper, not a button. Filter on "subtree contains `Icon(` and no
  `Text(`" before touching any `GestureDetector` in this codebase.
- *Pull-to-refresh: `RefreshIndicator`'s default `notificationPredicate` is
  `depth == 0`, so wrapping a non-scrolling ancestor works* as long as each conditional
  branch's own top-level scrollable is a direct depth-0 scroller. That let one
  `RefreshIndicator` around Search's `if (_model.showData) Expanded(child: Padding(…))`
  serve all seven filter tabs — I only had to add
  `physics: const AlwaysScrollableScrollPhysics()` to the seven branch scrollables
  (3 `SingleChildScrollView`, 4 `ListView.separated`). Horizontal chip strips nested
  inside those are depth >= 1 and don't interfere. Note `RefreshIndicator` returns its
  child **unwrapped** when idle (no `Stack`), so it is a genuine zero-layout-change add.
- *Making `onRefresh` actually refetch in FlutterFlow-generated screens:* the two real
  levers are (1) `await` the custom action that owns the data (`actions.fetchGroupsWithStatusRealtime()`
  performs a real `supabase.rpc(...)` and writes `FFAppState()`), and (2)
  `safeSetState(() => _model.<x>RequestCompleter = null)` — FlutterFlow's
  `future: (_model.c ??= Completer()..complete(query))!.future` idiom re-queries as soon
  as the completer is nulled, and the rebuild also re-issues any `future:` that is
  constructed inline in `build`. **Do NOT `await _model.waitForRequestCompletedN()` in a
  refresh handler:** its default `maxWait` is `double.infinity` and the completer is only
  recreated if that branch is currently mounted — on a different tab the spinner would
  hang forever. Awaiting the real network call is both honest and self-terminating.
- *Empty-state gating that avoids a "No results" flash:* Search sets `_model.showData = true`
  *before* awaiting `GetAllSearchCall`, so a naive `if (allSectionsNull) EmptyState()`
  renders "No results" for the whole request. Guarding on
  `FFAppState().SearchData == null → return false` fixes it, because the only code paths
  that null `SearchData` are page-load and the "All" chip (which then immediately
  refetches). Cheaper and far less invasive than threading a new `isSearching` bool
  through the eight separate call sites that trigger a search.
- *Upgrading a FlutterFlow loading gate without touching the 400-line builder body:*
  replace only the `if (!snapshot.hasData) { return Center(SizedBox(50,50,CircularProgressIndicator)); }`
  block with two blocks — a `snapshot.hasError` → `AsyncStateView<Object>(data: null,
  error: snapshot.error, onRetry: …)` and `!snapshot.hasData` → `AsyncStateView<Object>(
  data: null, isLoading: true)`, both with `builder: (context, data) => const SizedBox.shrink()`.
  Using `<Object>` sidesteps having to recover each FutureBuilder's generic type (they
  ranged over `ApiCallResponse`, `List<EventPageRow>`, `List<SearchHistoryRow>`), and the
  builder is provably never called because `data` is always null. This gives shimmer +
  error + Retry on 10 lists for a pure text substitution, with zero risk to the data path.
- *Which loading gates to convert, and how to tell them apart:* only convert gates whose
  post-gate line is `return Builder(` / `return ListView…` / `if (xList.isEmpty) return
  CompNoDataFound…`. **Skip** the ones followed by `final row = list.isNotEmpty ? …first`
  (per-row lookups) and any gate whose placeholder is `Container(width: 22, height: 22,
  child: CompLoadingWidget(name: 'like'))` — dropping a 5-row shrinkWrap shimmer list into
  a 22x22 box is a worse bug than the spinner. Print the first line after
  `snapshot.data!;` for every candidate and classify before editing; `lastIndexOf('FutureBuilder<')`
  is NOT a reliable way to find the enclosing builder in nested trees.
- *Import hygiene:* the component-import scripts insert at the first
  `import '/components/…'` anchor, which breaks FlutterFlow's alphabetical block. A
  10-line post-pass that finds the contiguous `^import '/components/` run and sorts it
  in place restores it; assert contiguity first or you will move unrelated lines.

**2026-07-21 — UI-review Wave 2 (shared-component adoption), `lib/pages/group/**`
(+ `lib/pages/groups/**` skipped): `AppNetworkImage`, `RefreshIndicator`,
`AppIconButton`/`Semantics`, `AsyncStateView`-family loading & empty states.**
- *The Dart bracket matcher you write for a codemod MUST understand `${...}`
  interpolation, or it silently desyncs on this repo's single most common idiom.*
  A matcher that treats `'` as "scan to the next `'`" works fine on
  `Image.network(getJsonField(x, r'''$.profile_picture'''))` but blows up on
  `visible: '${getJsonField(x, r'''$.profile_picture''')}' != '[]'` — the outer
  single-quoted string contains a *nested* raw triple-quoted string inside its
  interpolation, so the naive scanner ends the outer string on the first `'` of
  `r'''` and every bracket count after that is wrong (it threw "unterminated
  bracket" 4,000 lines later). The fix is a small state stack: `code` frames
  count brackets; `string` frames record their quote (`'`, `"`, `'''`, `"""`)
  and a `raw` flag (`src[i-1] === 'r'`); inside a non-raw string, `${` pushes a
  new `code` frame that pops on its matching `}`. ~35 lines, and it was exact on
  every one of the ~60 wrap/replace operations in this pass. Reuse it verbatim —
  do not re-derive a "simpler" one.
- *Codemod-then-`dart format` beats hand-`Edit` for wrapping widgets, and the
  safety property is the important part.* Every transform here was
  "collect {start, end, replacement} from the ORIGINAL text → assert no overlap →
  splice descending". Because the model never re-emits a file, `full-output-
  enforcement` truncation risk is structurally zero on a 6.5k-line widget. Cheap
  proof that nothing was lost: count structural tokens in the backup vs the result
  (`Text(`, `FFButtonWidget(`, `onTap:`, `onPressed:`, `pushNamed(`,
  `getJsonField(`, `Visibility(`, `ListView.`). All three big files matched
  exactly. Do this instead of reading `git diff --stat`, which in this tree is
  useless (it showed my_group at ±10,272 lines because HEAD predates the rebrand)
  — and note `my_group_widget.dart` *lost* 145 lines with zero content lost,
  purely because removing 10 wrapper widgets let the formatter repack the tree.
- *`Image.network` → `AppNetworkImage`: absorb the clip, don't stack a second
  one.* This scope had exactly 4 shapes, all FlutterFlow copy-paste, and the
  correct move for each was to replace the **wrapper**, not just the image:
  (a) `Container(width:W, height:H, clipBehavior: Clip.antiAlias, decoration:
  BoxDecoration(shape: BoxShape.circle), child: Image.network(url, fit: cover))`
  → `AppNetworkImage(url:, width: W, height: H, fit:, isAvatar: true)` — 19 sites;
  keeping the Container *and* passing `isAvatar` would clip twice.
  (b) `ClipRRect(circular(2.0), child: Image.network(url, 40, 40, cover))` →
  `borderRadius: BorderRadius.circular(2.0)` — 9 sites (group thumbnails, NOT
  avatars). (c) `ClipRRect(circular(0.0), …, height: 240)` → banner, radius
  omitted. (d) same but no `height` and `fit: contain` → post photo. Classify by
  normalising the wrapper region to a whitespace-free string and regex-matching
  *that* — `collapse()`-with-spaces still leaves `width: 32.0` and your regex will
  miss every site (it did, 31/31, on the first dry run).
- *Where the real refresh lives is a data-layer question, and "call the existing
  on-load action" was the wrong answer here.* `my_group`/`all_groups`/
  `nearest_groups` all render one shared `FFAppState().AsGroupList`, populated
  only by `actions.fetchGroupsWithStatusRealtime()` — which **also subscribes 5
  realtime channels**. `supabase.channel(topic)` does not dedupe, so wiring
  `onRefresh` to that action would add 5 channels per pull and multiply every
  subsequent refetch callback. Correct fix: a new in-scope module
  `lib/pages/group/group_list_refresh.dart` exposing fetch-only
  `refreshGroupList()` / `refreshGroupDetails(groupId)` (the same RPCs, no
  `.subscribe()`), plus `handleGroupListRefresh(context)` which rethrows→SnackBar
  so a failed pull isn't a silently-ending spinner (CLAUDE.md §5). One shared file
  beat duplicating 12 lines of RPC into three widgets. **Always read the on-load
  action before reusing it as a refresh handler — realtime subscription setup and
  data fetch are usually fused in FlutterFlow custom actions.**
- *`RefreshIndicator` needs a scrollable in EVERY branch, including the empty
  one.* `Visibility(visible: list != [])` renders `SizedBox.shrink()` when false,
  so the gesture dies exactly when the user most wants to retry. `Visibility` has
  a `replacement:` parameter — putting a `ListView(physics:
  AlwaysScrollableScrollPhysics, children: [EmptyState(...)])` there gives both
  the empty state and a working pull in one edit, no restructuring. Same trick for
  a shared empty-state component: `CompNoGroupsAvailableWidget` already had a
  `SingleChildScrollView`, and adding `physics: const
  AlwaysScrollableScrollPhysics()` to it (one line) made my_group's five empty
  tabs pullable.
- *`Semantics(button: true, label: …)` on a whole row is safe; `MergeSemantics` is
  not.* The group list rows contain their own `Join`/`Requested` `FFButtonWidget`s
  — merging the row into one node would swallow those inner actions. Plain
  `Semantics(button: true, label: 'Open group', child: InkWell(...))` adds the
  button flag + a label to the tap node while leaving the inner buttons and the
  row's own `Text` nodes addressable. (`MergeSemantics` stays correct only for
  leaf controls, e.g. inside `AppIconButton`.)
- *Bug I shipped and caught — "outermost InkWell containing routeName" is not the
  row.* My first card-Semantics pass wrapped `group_details`' **page-level**
  dismiss `InkWell` (the whole body) because a "similar groups" row 4,000 lines
  below contains `GroupDetailsWidget.routeName`. Guard added:
  require the `routeName` match to appear within the first ~1500 chars of the
  InkWell body, i.e. inside its *own* `onTap`, not somewhere in its subtree. Also
  re-confirmed the standing newline rule — `GroupDetailsWidget\.routeName` found 1
  site, `GroupDetailsWidget\s*\.\s*routeName` found 9 (dart format wraps
  `GroupDetailsWidget\n    .routeName` at depth).
- *`AppIconButton` conversion recipe that changes nothing visually:* pass the
  existing `child:` expression **verbatim** as `iconWidget:` and the existing
  `onTap: () async { … }` closure verbatim as `onTap:` (a `Future<void>
  Function()` is assignable to `VoidCallback`). The component supplies the >=44dp
  `ConstrainedBox`, the ripple, the 120ms press scale, the haptic and the
  `Semantics` node; the glyph, its padding and its background chip stay exactly as
  drawn. Only 3 of this scope's 52 `InkWell`s were genuinely icon-only (a Node
  triage that paren-matches each InkWell and counts `Text(` / `Icon(` /
  `AppNetworkImage(` inside proved it) — do that census before assuming a brief's
  "icon buttons everywhere".
- *The 21 `FlutterFlowIconButton`s in this scope are all `Icons.arrow_back` and
  all announce nothing.* `FlutterFlowIconButton` has no `tooltip`/label parameter
  and lives in `lib/flutter_flow/` (out of scope), so the fix is a call-site
  `Semantics(button: true, label: 'Back', child: …)` wrap — 21 identical
  paren-matched wraps in one script run. Its tap target is fine (it renders a
  Material `IconButton`, which pads to 48dp when `buttonSize` is null — it is null
  at all 21 sites), so only the label was missing. Check the underlying widget's
  default sizing before "fixing" a hit area you assume is small.
- *Blank-frame loading gate, fixed the low-risk way.* `group_details` gated its
  whole body on `if (!_model.loader)` with the else branch rendering a 50×50
  `custom_widgets.Loader` top-left inside a `Container(height: 100)` — visually a
  frozen blank screen. Rather than restructure a 4,700-line branch into
  `AsyncStateView` (the data is `dynamic` FFAppState, there is no error object to
  pass, and the risk/benefit was bad), I: (1) swapped the loader branch body for a
  content-shaped `AppShimmerBox`/`AppShimmerLine` skeleton (240dp banner + title +
  CTA + two body lines) wrapped in `Semantics(label: 'Loading', liveRegion:
  true)`; (2) tightened the content gate to `!loader && AsSpecificGroupDetails !=
  null`; (3) added a third branch rendering `EmptyState(... actionLabel: 'Retry',
  onAction: _reloadGroupDetails)`. Three small edits, same four-state behaviour as
  `AsyncStateView`, none of the structural risk. **When a page's load gate is a
  bare bool over global app state, reproduce AsyncStateView's four branches
  in-place instead of forcing the generic through a 4k-line subtree.**
- *Honest empty state on a client-filtered list:* `group_details` renders
  `FFAppState().AsPost` (all posts, app-wide) and hides the wrong ones with a
  per-item `Visibility(visible: widget.groupId == postsItem.group_id)`. So
  `posts.isEmpty` is the wrong emptiness test — it is false while this group shows
  zero posts. Filter with the *same* predicate (`posts.where(...)`) before
  deciding to show "No posts in this group yet".
- *Skipped, deliberately:* `lib/pages/groups/groups_widget.dart` (3 more
  `Image.network`) — confirmed again as the unwired design stub described in the
  2026-07-21 lesson above (hardcoded `picsum.photos`, no queries, pending a
  delete decision). Don't spend budget on it until the owner rules.

**2026-07-21 — Wave 2 component adoption + 3 approved `if (false)` fixes,
`lib/pages/{home,post,comments_page}/**` (23 `Image.network`, 26 `AppIconButton`,
2 `RefreshIndicator`, `AsyncStateView`/`EmptyState`).**
- *NEVER run `git stash` in this repo to "check" anything.* I ran it as a throwaway
  probe while counting analyzer warnings and it silently reverted ~10 files of
  finished work (the tree has been dirty since the single initial commit, so
  `stash` swallows the entire rebrand + every parallel agent's in-flight edits, not
  just mine). `git stash pop` recovered it fully this time, but with 6 other agents
  editing concurrently this could have destroyed their work too. Attribution
  questions get answered with `git show HEAD:<file> | grep`, never with
  stash/checkout/reset.
- *The reusable engine for this whole wave — a regex→offset codemod with an overlap
  assert.* Every one of the four tasks was done by: (1) match a Dart-aware regex
  against the ORIGINAL file text, (2) push `{start, end, replacement}` ranges,
  (3) assert no two ranges overlap, (4) splice descending by `start`. 49 structural
  edits across 10 files, zero manual `Edit` calls on the huge files, zero
  stale-`old_string` pain from the format hook, and `full-output-enforcement`
  truncation risk is structurally zero because the model never re-emits a file.
  This supersedes hand-editing for anything above ~1k lines.
- *The paren matcher MUST understand `${...}` interpolation, `'''…'''`, and `//`
  comments, or it desyncs on the first `'${getJsonField(...)}'`.* Confirmed again:
  `comments_page_widget.dart` has string-interpolated `getJsonField` calls inside
  `if ('${...}' == '1')` conditions; a naive depth counter closes levels early and
  the splice silently produces garbage that still *formats*. Write the matcher once,
  reuse it in every script of the pass (I copied the same 40-line function into 5
  scripts — worth promoting to a shared scratchpad module next time).
- *`Image.network` → `AppNetworkImage`: classify by the WRAPPER, not the image.*
  Three shapes covered all 23 sites and each maps to a different call:
  1. `Container(width:W, height:H, clipBehavior: antiAlias, decoration:
     BoxDecoration(shape: circle), child: Image.network(url, fit: cover))` — replace
     the WHOLE Container with `AppNetworkImage(..., isAvatar: true)`. The Container
     *is* the clip, so keeping it would double-clip.
  2. `ClipRRect(borderRadius: circular(R), child: Image.network(url, w, h, fit))` —
     replace the whole ClipRRect, pass `borderRadius:`. Auto-detect avatar with
     `R >= min(w,h)/2` (a 24.0 radius on a 40x40 box is a circle, not a rounded
     rect) — that correctly caught the 4 composer avatars incl. the two
     `BoxFit.fill` ones the review named, and correctly left the 2.0-radius group
     thumbnails as rounded rects.
  3. `GradientAvatarRing(child: Image.network(...))` — the ring already owns a
     `ClipOval` + `SizedBox(innerDiameter)`, so do **NOT** pass `isAvatar: true`
     (that adds a second `BorderRadius.circular(9999)` clip). Pass
     `fallbackIcon: Icons.person_rounded` instead to get the person glyph without
     the clip.
- *`AppNetworkImage` gives no CLS benefit when the original had no `height`.* Its
  shimmer placeholder is `AppShimmerBox(height: null)` → `Container` with no child
  under an unbounded-height parent → Flutter's `LimitedBox(maxHeight: 0)` path → a
  0-height placeholder. So the two post-photo sites that were `Image.network(url,
  width: double.infinity, fit: contain)` with no height still pop in. Caching and
  the error fallback are real wins there; the placeholder is not. Don't claim the
  layout-shift fix for a site whose height you weren't allowed to invent — flag it.
- *Semantic labels without string interpolation.* `'Profile photo of ' +
  getJsonField(x, r'''$.name''').toString()` is far easier to generate from a script
  than the `${...}` form — Dart `String + String` is valid, and it sidesteps every
  layer of `$`/quote escaping between JS, bash and Dart. Use concatenation in
  generated code.
- *The correct `AppIconButton` shape for a composite (icon + count) action button:*
  `AppIconButton(semanticLabel: <state+count>, minTapTarget: 44.0, enableHaptic:
  false, onTap: <original>, iconWidget: ExcludeSemantics(child: <original child>))`.
  Three non-obvious details: (a) `enableHaptic: false` because these FlutterFlow
  `onTap`s already open with `HapticFeedback.lightImpact()` and you'd get a double
  tick; (b) `ExcludeSemantics` around the original child is required or the count
  `Text` produces a second node and TalkBack reads "Like, 12 likes" then "12";
  (c) `onTap: () async {…}` assigns fine to `VoidCallback` — `Future<void>
  Function()` <: `void Function()` in Dart, so the async body needs no wrapper.
- *`Material` inside `AppIconButton` sets a `DefaultTextStyle`* (`widget.textStyle
  ?? Theme.of(context).textTheme.bodyMedium`). Harmless here only because every
  FlutterFlow `Text` passes an explicit fully-specified `style:` and the ambient
  default was already the same `bodyMedium`. Check this before wrapping any text
  whose style relies on inheritance.
- *Tap-target growth is horizontal too — measure the row's slack first.* The home
  action row is `Row(spaceBetween)` with like(32) + count(24) + comment(70) +
  share(70) = 196dp against ~332dp available, i.e. ~136dp of slack, so growing the
  two small ones to 44 is absorbed. But it does widen the heart→count gap from 4dp
  to ~20dp (both children get centred in their new 44dp boxes). That is a visible
  spacing change, not a break — report it rather than pretending "nothing changed
  visually". The comment-level row (like 25x25 + "Add reply" 65x20) grows from 25dp
  to 44dp tall, i.e. ~+19dp per comment on a long list — also report.
- *`InkWell` triage rule that held for all 51 in scope:* convert to `AppIconButton`
  only when the `child:` bottoms out in an `Icon`/`Image.asset`/count-composite.
  When it wraps a whole card, an author row, or anything containing its own `Text`
  label, use `MergeSemantics(child: Semantics(button: true, child: InkWell(…)))`
  with **no** `label:` — the descendant `Text`s then supply the label and you
  haven't invented copy. Only add an explicit `label:` when the control is
  genuinely unlabelled (e.g. the search bar). Verify first that the wrapped subtree
  contains no *other* interactive control (compare `startLine + spanLines` against
  the next control's line) or you'll merge two buttons into one node.
- *A `!= null` gate is not an empty gate — this was a real latent bug.*
  `comments_page` rendered its "No comments yet" art only when
  `FFAppState().AsComments == null`, but the API returns `$.comments` as an **empty
  list** for a post nobody has commented on, so the common case rendered a blank
  area. Fixed with one `bool get _hasNoComments => c == null || (c is List &&
  c.isEmpty)` used by both gates. Whenever a FlutterFlow screen gates a list on
  `dynamic != null`, check what the API actually returns for "none".
- *`AsyncStateView` adoption that fits a FlutterFlow feed without restructuring:*
  leave the existing `if (_model.showPost) … / if (!_model.showPost)
  ShimmerLoaderWidget()` sibling branches alone (that's already the one shimmer
  treatment) and wrap only the `return Column(...)` inside the posts `Builder`.
  `data: posts`, `error:` derived from the stored `ApiCallResponse?.succeeded`,
  `onRetry:` pointing at the same extracted `_reloadFeed()` the `RefreshIndicator`
  uses. That converts a silently-failing refresh into a real error + Retry — the
  app's first error state anywhere — for ~15 lines and no data-layer change.
  Use `emptyBuilder:` (not `emptyIcon`/`emptyTitle`) when the screen already has a
  bespoke illustration asset worth keeping; the flat `empty*` params only give the
  glyph badge.
- *Extract the refresh body into a method before wiring Retry.* Both `_reloadFeed`
  (home) and `_refreshComments` (comments) are literal copies of what `initState`/
  the old inline `onRefresh` already did, so `onRefresh:` and `onRetry:` provably do
  the same work. For comments, the correct way to re-drive a FlutterFlow
  `FutureBuilder` is `safeSetState(() => _model.requestCompleterN = null)` then
  `await _model.waitForRequestCompletedN()` — copy that idiom from the file's own
  realtime-subscribe callback rather than inventing a reload.
- *Pull-to-refresh needs `physics: const AlwaysScrollableScrollPhysics()` on the
  child scrollable*, else the gesture never fires on a short page. Confirmed both
  sites. Also pass `color: FlutterFlowTheme.of(context).primary` — the default
  indicator is Material blue and looks off-brand.
- *`if (false)` quick wins 1-3 (create_post ✕, editpost ✕ ×2) were exactly as the
  inventory described* — complete handlers, local `_model` state only. All three are
  `Align(alignment: (1.0, -1.0), child: <button>)` as the first child of a
  `Column(mainAxisSize: max)`; an `Align` with no factors under a Column's unbounded
  main axis shrink-wraps its child's height and fills the bounded width, so
  enabling adds exactly one right-aligned row and nothing reflows. Converted them to
  `AppIconButton` in the same edit (24dp icon → 44dp target) since they were bare
  `InkWell` + `Icon(Icons.close)`.
- *Scope note:* `specific_user_groups_widget.dart`'s 3 `Image.network` were
  converted anyway even though the file is the orphan mock page slated for deletion
  — the codemod is uniform and skipping would have needed a special case. Zero cost
  either way; the delete decision is unaffected.

**2026-07-21 — UI-review Wave 2 (component adoption), `lib/pages/events/**` +
`lib/pages/business/**` (`AppNetworkImage`, `AppIconButton`, `AsyncStateView`,
`EmptyState`, `RefreshIndicator`, `Semantics`), per ui-review §2.3/§2.5/§2.7.**
- *TASK-0 follow-through: the grid-card overflow maths, now closed.* The 2026-07-21
  Sprint-1 lesson above measured the event grid card at `childAspectRatio: 0.52`
  and left the fix as an owner decision; Wave 1 had already moved it to `0.48`.
  Confirmed geometry on a 360dp phone: grid padding `fromSTEB(20,8,20,0)` +
  `crossAxisSpacing: 10`, `crossAxisCount: 2` ⇒ cell width `(360-40-10)/2 = 155`.
  Cell height is `155 / ratio` (the `Container(height: 316/320)` is dead — grid
  children get `BoxConstraints.tight`). Fixed chrome inside the card is
  `8+8` padding + `120` image + `24` CTA + `2 × 8` outer `.divide` = `176`.
  So text space = `155/ratio − 176`: **0.52 → 122.1dp, 0.48 → 146.9dp,
  0.47 → 153.8dp.** Content at 12px/1.4 is `title 22.4 + 2 + desc 3×16.8 (50.4)`
  `+ 4 + 3 metadata rows max(16 icon, 16.8) (50.4) + 2×4` = **137.2dp**
  (invite branch: +16.8 for the inviter row, −16.8 because `maxLines` drops
  3→2, +4 gap = 141.2dp). Result: `0.47` clears both branches with **16.6dp /
  12.6dp** headroom; `0.48` only had 9.7dp, and the pre-Wave-1 `0.52` clipped by
  ~4dp *at 10px*. Reusable recipe: **cell text budget = cellWidth/ratio − (fixed
  chrome); line box = fontSize × lineHeight; `.divide(SizedBox(h))` costs
  h × (children−1)** — count the dividers, they were the 16dp I nearly missed.
- *Every census the brief quotes is a floor; verify with a newline-tolerant grep
  BEFORE planning, because two of five items may already be done.* This scope's
  `fontSize: 10.0` count was **0** (Wave 1 raised them all) and
  `childAspectRatio` was already `0.48`, not `0.52`. Meanwhile `Image.network`
  was **22**, not the stated 21 — `Grep` with `multiline: true` and the pattern
  `Image\s*\n?\s*\.\s*network\s*\(` gives per-file counts in one call and is the
  only reliable census tool in this repo.
- *A paren-matching codemod in this repo MUST skip `//` comments, not just
  strings.* FlutterFlow emits `// Customize what your widget looks like when
  it's loading.` inside almost every `builder:` — the apostrophe in "it's" opens
  a phantom string and the matcher runs to EOF and returns −1. My first run
  failed on all 5 targets for exactly this reason. Add `//` and `/* */` skipping
  to `matchParen` before anything else.
- *…and even then, a naive matcher cannot parse a raw triple-quoted string nested
  inside a Dart interpolation.* `'Photo of ${getJsonField(item, r'''$.name''').toString()}'`
  is valid Dart (analyzer is happy) but the scanner closes the outer `'` at the
  first quote of `r'''`, then opens a triple-string that never closes. This is
  code **I had just written** two steps earlier — so a codemod that worked at the
  start of a task can break mid-task because of your own edits. When a matcher
  fails on exactly one file, check whether that file now contains a nested-quote
  interpolation and hand-`Edit` that one instead of "fixing" the scanner.
- *`AppNetworkImage` swap rules that held for all 22 sites:* (a) the two source
  shapes are `ClipRRect(borderRadius: R, child: Image.network(...))` → drop the
  `ClipRRect`, pass `borderRadius: R`; and `Container(w,h, clipBehavior:
  antiAlias, decoration: BoxDecoration(shape: circle), child: Image.network(url,
  fit: cover))` → drop the whole `Container`, pass `width/height` + `isAvatar:
  true`. Never keep both clips. (b) `BorderRadius.circular(24)` on a 32×32 box is
  already a circle, so `isAvatar: true` is an exact visual match, not an
  approximation. (c) Dropping the FlutterFlow `!` from `row!.profilePicture!` is
  safe because `url` is `String?`, **but** removing the `!` also removes the
  flow-analysis promotion — grep every later use of that local first; here they
  were all `?.`, so it was fine. (d) a business `profile_picture` should get
  `fallbackIcon: Icons.storefront_rounded`, otherwise the avatar fallback draws a
  *person* glyph for a shop.
- *When is `onRefresh: safeSetState(() {})` an honest refresh, and when is it a
  no-op?* It depends entirely on where the `future:` is built. In `all_events` /
  `latest_event` the `FutureBuilder`'s `future:` is `EventPageTable().queryRows(...)`
  **constructed inline in `build`**, so a rebuild produces a *new* Future object,
  `FutureBuilder` resubscribes and the query really re-runs — a genuine refetch.
  In `my_pages` / `my_event` / `business_home_page` FlutterFlow instead caches via
  `(_model.apiRequestCompleter ??= Completer()..complete(call()))` and ships a
  generated `waitForApiRequestCompleted()` helper, so the correct refresh is
  `safeSetState(() => _model.xCompleter = null); await _model.waitForXCompleted();`
  — and that one also keeps the spinner up until the data lands. **Do not
  "upgrade" the inline-future screens to a Completer to get a nicer spinner:** on
  those pages the every-rebuild requery is load-bearing (tapping "Attend" calls
  `safeSetState` and relies on the list re-querying the new attendee count), so
  caching it would be a silent behaviour regression. Accept the instantly
  retracting indicator and say so in the report.
- *`RefreshIndicator` gotchas that bit / nearly bit:* (1) the child scrollable
  needs `physics: const AlwaysScrollableScrollPhysics()` or the gesture never
  fires on short content — true for `SingleChildScrollView`, `ListView.separated`
  and `GridView.builder` alike. (2) Wrapping a `FutureBuilder` means the loading
  and empty branches (`CompLoadingWidget` / `CompNoDataFoundWidget`) have **no
  scrollable descendant**, so pull-to-refresh is inert exactly when a user most
  wants it. Worth flagging; the real fix is to make the empty state itself
  scrollable, which is a bigger change than Wave 2 allowed.
- *Adding a wrapper widget to a 2–3k-line generated file: locate the closer by
  numbering the tail, not by counting brackets.* `awk 'NR>=N {printf "%d:%s\n",
  NR, $0}' file` on the last ~30 lines, then label each `),`/`],` with the widget
  it closes top-down from the opener you just added. Insert the single extra `),`
  in the right slot with sloppy indentation and let `dart format` fix it —
  `dart format` reporting "Formatted N files" is itself proof the file parses.
- *`AsyncStateView.fromSnapshot` adoption shape that worked:* replace the whole
  `if (!snapshot.hasData) { return CircularProgressIndicator...; } final x =
  snapshot.data!; return <body>;` prologue with
  `return AsyncStateView.fromSnapshot<T>(snapshot: snapshot, …, builder: (context, x)
  { return <body>; });` — the existing body is not touched at all, only the
  prologue and two closing tokens. For a FlutterFlow `ApiCallResponse` (whose
  `jsonBody` is `dynamic`) you must pass an explicit
  `isEmpty: (r) { final dynamic b = r.jsonBody; return b == null || (b is List && b.isEmpty); }`,
  because the default emptiness test only understands `Iterable`/`Map`/`String`.
  Note this only catches *thrown* failures — an HTTP error that FlutterFlow
  returns as a non-`succeeded` `ApiCallResponse` still lands in the data branch.
- *`EmptyState` is safe in an unbounded-height slot.* It ends in
  `Padding > Center(child: Column(mainAxisSize: min))`, and `RenderPositionedBox`
  shrink-wraps whenever `constraints.maxHeight == infinity`, so dropping it
  inside a `Column` in a `SingleChildScrollView` does **not** throw. I checked
  this before adopting rather than assuming.
- *Do not replace a working `CompNoDataFoundWidget` with `EmptyState`.* Three of
  the four empty states the brief asked for already existed with good copy and a
  real illustration (`all_events`, `latest_event`, `ending_event`); swapping them
  for the new icon-badge component would have been a lateral move at best. Only
  add `EmptyState` where a list can render **nothing at all** today.
- *`my_event`'s empty state is a z-order hack, not a branch — flagged, not
  "fixed".* `initState` sets `_model.showEmpty = true` unconditionally ~1s after
  load, and the artwork sits **underneath** the list inside a `Stack`; it only
  becomes visible because the rows paint opaque white over it. Per-tab
  ("attending" / "invitations" / "host") filtering happens inside the
  `itemBuilder` via `if (…) Visibility(…)`, so **no filtered count exists** at the
  list level and a real per-tab empty state cannot be added without restructuring
  the filter — which is banned. Report the mechanism rather than bolting a second
  empty state on top of it.
- *`AppIconButton` conversion caveat worth stating up front:* the component is
  `ConstrainedBox(min 44) > Center(widthFactor/heightFactor: 1)`, so the glyph
  **moves ~10dp right** (and the row grows ~20dp taller) versus a bare 24dp
  `InkWell > Icon`. That is invisible in a `Row` with the default
  `crossAxisAlignment: center` (6 of the 7 sheet headers here), but in
  `comp_mismatch`, which uses `CrossAxisAlignment.start` next to a two-line
  title, the arrow now centres ~9dp below the title's first line. Check each
  parent `Row`'s `crossAxisAlignment` before a bulk conversion and call out the
  `start`-aligned ones.
- *Two different `Semantics` shapes, two different jobs.* Icon-only controls get
  the full `AppIconButton` (it already does `MergeSemantics > Semantics(button,
  enabled, label)` internally). Card/row `InkWell`s that wrap real content get a
  plain `Semantics(button: true, label: …)` wrapper only — do **not** add
  `ExcludeSemantics`, or the descendant `Text`/`AppNetworkImage` labels and the
  `InkWell`'s own tap action disappear. Deriving the label automatically from the
  row's own single `Text('…')` literal worked for all 10 action-sheet rows; only
  `'Share'` needed a manual pass to become `'Share event'`.
- *Verification:* `dart format <dirs>` then `dart analyze <dirs>` → **0 errors,
  0 warnings**, 1015 pre-existing `info` (`prefer_const_constructors` class).
  Only the error/warning counts are meaningful signals in this codebase.
- *Left for a later wave (reported, not silently skipped):* 16
  `FlutterFlowIconButton`s in this scope still carry no `Semantics` label (they
  are not "bare `InkWell` + `Icon`", so outside this brief's letter, but they are
  the remaining icon-only a11y gap here); `community_widget.dart` still has two
  event grids at `childAspectRatio: 0.52` (other agent's folder — they need the
  same 0.47 fix); and the dead `Container(height: 316/320)` inside both grid
  cards was left in place with an explanatory comment on the `gridDelegate`
  rather than deleted.

**2026-07-21 — UI-review Wave 2 component adoption, `lib/pages/profile/**` (58 files;
`AppNetworkImage` / `AppIconButton` / `AsyncStateView` / `EmptyState` / `RefreshIndicator`).**
- *The counting lesson finally has a number attached to it.* Wave 1 reported "20/20 fixed,
  zero skipped" for this exact folder while 13 wrapped instances remained. The brief for this
  pass said "floor: 28 `Image.network` sites"; the newline-tolerant regex
  `/Image\s*\.\s*network\s*\(/g` found **34**. The wrapped forms `Image\n    .network(` and
  `child: Image\n  .network(` are invisible to any single-line grep. The same trap bit me again
  *inside this pass*: a plain `Grep` for `custom_widgets\.` in `user_profile_widget.dart`
  returned **1** hit, so I deleted the import as unused — the analyzer then flagged a second,
  wrapped `custom_widgets\n    .ShowContent(` usage. **Never delete an import on the strength
  of a single-line grep; use `dart analyze`'s own `unused_import` verdict instead** (that is
  what I switched to for the 21 `flutter_flow_icon_button.dart` imports, and it was exact).
- *The right engine for a call-site migration is an argument-level transform, not a regex.*
  For `Image.network(url, width:, height:, fit:)` -> `AppNetworkImage(url:, width:, height:,
  fit:, ...)` I wrote a ~200-line Node script with three parts: (1) a Dart-aware paren matcher,
  (2) a top-level comma splitter, (3) a per-site config table keyed by *file + occurrence
  index*. The script re-emits the call from parsed parts, aborts on any argument it does not
  recognise (`if (unknown.length) process.exit(1)`), and asserts `sites.length === cfg.length`
  per file before touching anything. 32 sites across 13 files, first run, zero analyzer errors.
  The occurrence-index key is what makes this reviewable: I could mark the two sites inside
  `user_all_post`'s dead `if (false)` block as `null` and the script counted them as explicit
  skips rather than silently missing them.
- *Two gotchas in that splitter, both real:* (a) do **not** track `<`/`>` for depth — Dart's
  fat arrow desyncs the counter instantly (`(e) => e.toString()` reads as one unmatched `>`),
  and generic type args in these files never contain a top-level comma anyway. (b) the string
  scanner must handle raw triple-quoted strings **and** `${...}` interpolation containing a
  nested string, because FlutterFlow emits a single-quoted string whose interpolation contains
  `getJsonField(item, <raw triple-quoted jsonpath>)` everywhere. That nesting is also the
  *answer* for `semanticLabel` — it is a proven-legal shape in this codebase, so interpolated
  per-row labels ("Asha profile photo") are safe to generate.
- *`AppNetworkImage` + an existing clip: pass `fallbackIcon`, not `isAvatar`.* Every avatar in
  this folder is already circular via its parent — either `Container(clipBehavior:
  Clip.antiAlias, decoration: BoxDecoration(shape: BoxShape.circle))` or
  `ClipRRect(BorderRadius.circular(100))`. Setting `isAvatar: true` would clip a second time
  and, worse, `isAvatar` is also what selects the person-glyph fallback. The clean split is:
  **keep the parent clip, omit `borderRadius`/`isAvatar`, and pass
  `fallbackIcon: Icons.person_rounded`** to get the avatar fallback without the double clip.
  Also worth doing: when the parent `Container` has a fixed `width`/`height` and the old
  `Image.network` had none, pass those same numbers to `AppNetworkImage` — constraints are
  already tight so nothing moves, but `_glyphSize()` then scales the fallback glyph to the box
  instead of defaulting to a 48px assumption. Note `ClipRRect(BorderRadius.circular(2.0))` on
  the 40x40 group thumbnails is **not** an avatar clip — leaving it and not setting `isAvatar`
  is what preserves the squircle.
- *`AsyncStateView<bool>` is the adapter for a FlutterFlow `_model.showData` gate.* These
  screens do not have a `T? data` to hand to `AsyncStateView<T>`; they have a boolean plus a
  pile of `_model.*` fields. The shape that works, and reads honestly:
  `AsyncStateView<bool>(data: _model.showData ? true : null, isLoading: !_model.showData &&
  _loadError == null, error: _loadError, onRetry: _retryLoad, isEmpty: (bool _) => false,
  builder: (context, _) => <the existing subtree>)`.
- *Adding an error state to a FlutterFlow page-load action is a 4-piece, low-risk refactor, and
  it is worth doing even where you do not adopt `AsyncStateView`.* Pattern used on 6 screens:
  (1) `Object? _loadError;` as a **State** field, not a model field (no model file to edit, no
  `createModel` churn); (2) move the `addPostFrameCallback` body verbatim into a named
  `Future<void> _loadX()` wrapped in `try/catch`; (3) a `_retryLoad()` that resets the gate and
  re-runs it; (4) in the build, insert `if (_loadError != null) Expanded(child: EmptyState(icon:
  Icons.error_outline_rounded, iconColor: theme.error, body:
  AsyncStateView.describeError(_loadError!), actionLabel: 'Retry', onAction: _retryLoad))` and
  change the sibling loader branch to `if (_loadError == null && !_model.show)`. The data
  branch (`if (_model.show)`) needs **no** change because `show` stays false on error.
  `AsyncStateView.describeError` is usable as a plain static helper without the widget — that is
  what keeps the error copy consistent across screens that could not adopt the full wrapper.
- *`RefreshIndicator.onRefresh` must be a real re-fetch, and this repo already contains the
  recipe — copy it, do not invent one.* `home_page_widget.dart` refreshes the shared feed with
  `GetPostCall.call(anonKey: FFDevEnvironmentValues().AnonKey, token: currentJwtToken)` then
  assigns `FFAppState().AsPost` from its `jsonBody`. All three profile feeds read
  `functions.returnLimitedPosts(FFAppState().AsPost, ...)`, so the identical call is the correct
  refresh for `user_profile`, `other_profile` and `user_all_post`. `ApiCallResponse` is
  re-exported by `/backend/api_requests/api_calls.dart`, so no extra import is needed.
- *Split the page-load action so refresh does not re-subscribe.* `user_profile`/`other_profile`
  page loads end with `actions.unsubscribe(x)` -> `Future.delayed(1000ms)` -> `actions.subscribe(x)`.
  Reusing the whole load as the refresh handler would put a **1-second dead delay inside every
  pull-to-refresh** and churn the realtime channel. Extract three methods instead —
  `_fetchProfileData()` (shared), `_subscribeToX()` (initial load only), `_fetchPosts()`
  (refresh only) — and compose them differently in `_initialLoad` vs `_refreshProfile`.
- *A latent crash found for free by replacing a loading branch.* `other_profile` had
  `if (!_model.showData) Expanded(child: Align(child: SimpleLoader))` as a child of a `Column`
  that is itself inside a `SingleChildScrollView` — `Expanded` under an unbounded main axis
  throws "RenderFlex children have non-zero flex but incoming height constraints are
  unbounded". Adopting `AsyncStateView` deleted that branch. Worth grepping for
  `SingleChildScrollView` -> `Column` -> `Expanded` elsewhere; it only shows up in the loading
  state, so it survives casual testing.
- *`Semantics` for a whole-row navigation `InkWell`: `MergeSemantics(child: Semantics(button:
  true, child: InkWell(...)))` with NO explicit `label`.* Adding a label here is actively wrong:
  `MergeSemantics` concatenates the parent label with every descendant label, so
  `Semantics(label: 'Account Settings')` over a row that already contains
  `Text('Account Settings')` announces **"Account Settings, Account Settings, button"**. Let the
  descendant `Text` supply the label and use the outer `Semantics` only for the `button: true`
  role. (Explicit labels stay correct for `AppIconButton`, where there is no descendant text at
  all.) Applied to 21 rows in `profile_widget` + `account_settings` with a paren-matching wrap
  script that splices back-to-front. This supersedes nothing in the 2026-07-21 bottom-nav
  lesson — that one covered icon-only cells with no descendant text, the opposite case.
- *`FlutterFlowIconButton` -> `AppIconButton` is a safe 1:1 swap, but gate it hard.* 22 of the 23
  in this scope were the identical plain back arrow (`borderRadius: 100.0` +
  `Icon(Icons.arrow_back, color:, size: 24.0)` + `onPressed:`). The script only converts when
  there is **no** `buttonSize`, `fillColor`, `borderColor`, `borderWidth` or
  `showLoadingIndicator` — the 23rd (a `buttonSize: 34.0` + `fillColor` share chip) was left
  alone because `AppIconButton` clamps `minTapTarget` to 44 and a filled background would
  visibly grow the chip from 34 to 44dp. Note `onPressed: () async {...}` assigns cleanly to
  `AppIconButton.onTap` (`VoidCallback`) — Dart accepts `Future<void> Function()` where
  `void Function()` is expected.
- *`AppIconButton` inside an `InputDecoration.suffixIcon` is safe.* `suffixIconConstraints`
  defaults to `minWidth/minHeight: 48`, so a 44x44 tap target fits without changing the field's
  height — the two password-visibility toggles went from a bare `InkWell + Icon` (a ~22dp
  target, plus a `FocusNode` allocated on every build) to a labelled 44dp button with a
  state-dependent label ('Show password' / 'Hide password') and no field-height change.
- *Do not duplicate an empty state that already exists.* The brief asked for `EmptyState` on
  empty followers / following / blocked-users; all five of those screens already route through
  `CompNoDataFoundWidget` with good copy and an illustration. The correct move was to keep it
  (passing it as `emptyBuilder:` when adopting `AsyncStateView.fromSnapshot`) and add only the
  genuinely missing **error** state. Verify a brief's "no current UI" claim with one grep before
  building a second empty state on top of the first.
- *Verify-tip that keeps working, plus one new failure mode:* `dart format <dir>` then
  `dart analyze <dir>` filtered to lines starting with `error` -> expect 0 (the 1739 total
  issues here are pre-existing `prefer_const_constructors`-class info). New failure mode
  observed this pass: after a Node script writes a file, a subsequent `sed`/`Bash` read can
  return **stale content** (I saw the pre-edit `initState` for a file the script had already
  rewritten, and a system-reminder showed a pre-edit snapshot of `change_password_widget.dart`).
  Re-verify with `grep -c <new identifier>` or the `Read` tool before concluding an edit was
  lost and redoing it — a blind re-run would have double-applied the transform.
- *The session scratchpad is NOT private when several agents run in parallel.* Halfway through
  this pass my `census.js` started printing results for `lib/pages/home/**` — another agent had
  overwritten it, and the directory also held `add_refresh.js`, `classify.js`, `ag.bak` that I
  never wrote. Give every helper script a scope-unique name
  (`task1_images.js`, `lesson_profile_wave2.md`) and re-run a census immediately before
  trusting its numbers.
- *Tooling, re-confirmed for the third time:* a `bash` heredoc containing prose with
  apostrophes and backticks fails with "unexpected EOF while looking for matching quote". Write
  the prose with the `Write` tool to the scratchpad, then append it with a small `node` script.
  Never inline multi-line prose into `bash -c`.
- *Follow-up the same day — how to pay for a 44dp tap target with zero density.* The
  coordinator pushed back on "+21dp per notification card" and hypothesised the row was
  already ≥44 so the target should fit for free. It was not: the card is 64dp but **24dp
  of that is `Padding(20, 8, 20, 16)`** — the Row's *content* is only 40dp (avatar-driven).
  Lesson: when someone quotes a row height, separate content height from padding before
  agreeing or disagreeing. Two different outcomes fell out of that split:
  (a) **Header — recovered to literally 0dp.** Children are ring 38 / search 36 / button
  34→44 inside `Padding(0, 12, 0, 12)`, `Row` cross-axis defaulting to `center`. Dropping
  the padding 12→9 gives `44 + 9 + 9 == 38 + 12 + 12 == 62`, and because every child is
  centre-aligned each one keeps its *exact* y (avatar 12..50 before and after, search
  13..49, disc 14..48). **When the growing child is the tallest in a centre-aligned Row,
  trade the parent's padding 1:1 for the growth and the layout is provably unchanged** —
  verify by computing each child's y offset both ways, not by eyeballing the total.
  (b) **List row — not recoverable without restructuring, so reported instead of forced.**
  The button is a *stacked child* of a trailing `Column([Text(timestamp), button])`, so
  16.8 + 20 → 16.8 + 44 simply adds. There is no free lunch: `Align(heightFactor:)` would
  shrink the layout box but `RenderBox.hitTest` rejects positions outside `size`, so the
  real target would silently drop back to ~22dp — i.e. defeating the clamp by trickery,
  which also defeats the point. The honest floor even *with* restructuring is +4dp
  (content 40 → 44). Costed the alternatives (accept +20.8 / compensate padding 8,16→2,2
  for +0.8 with a visibly tighter card / restructure for +4 / revert to a 20dp target)
  and let the owner choose rather than picking a visual change unilaterally.
- *Second follow-up — "check for a separator before you spend padding" caught a shape
  split the brief assumed away.* Asked to trade card padding 8/16 → 4/4 to buy back the
  density the 44dp tap target cost, the precondition check ("does anything separate
  adjacent cards?") revealed that `notification_widget.dart`'s six tab lists are **two
  different card designs**, not one: the default **All** tab is a floating card
  (`margin: fromSTEB(12,6,12,6)` → 12dp gutter, `borderRadius: 20`, `FFShadows.sm`,
  `secondaryBackground`/`primaryL1` on `pageBack`), while **Post/Group/Event/Business/
  Sale** are full-bleed rows with **no margin, no radius, no shadow**, separated only by
  `Border.all(greyL2, 1.0)`. The inner padding is therefore load-bearing in completely
  different ways: on the All tab it is decoration (the 12dp margin does the separating),
  on the other five it is the *only* internal breathing room against a hard 1dp line.
  Same literal `fromSTEB(20.0, 8.0, 20.0, 16.0)` ×6, two different meanings. Applied the
  change to the All tab and held the five, with the gap arithmetic (content-to-content
  between neighbours 26dp → 10dp on the full-bleed tabs) for the owner to rule on.
  **Lesson: a grep that shows N identical padding literals is not evidence of N identical
  layouts — read each occurrence's enclosing `decoration:` before treating a sweep as
  uniform.** This is the same failure mode as the 2026-07-20 ternary-`.white` lesson
  (file-wide consistency assumed, not verified), now confirmed for spacing as well as
  colour.
- *Useful framing that came out of this exchange:* when a control grows to meet a 44dp
  minimum, the extra height is not wasted — a 44dp box around a 20dp glyph carries 12dp
  of internal whitespace per side. So the honest move is to **take that whitespace out of
  the parent's padding rather than add it on top**, which is why 8/16 → 4/4 reads as
  roughly the same density (card 64.0 → 68.8, +7.5%) instead of the +33% the naive
  version cost. Report the timestamp's clearance to the card edge (4.0dp box, ~6.4dp to
  the visible glyph once the 16.8dp line box's half-leading is counted) so the reviewer
  can sanity-check the tightest element rather than just the total.
- *Closing numbers for the notification density thread, and one measurement subtlety
  worth reusing:* `Container(decoration: BoxDecoration(border: Border.all(width: 1)))`
  **insets its child by the border width on top of the explicit `padding:`** (Container
  folds `decoration.padding` — `EdgeInsets.all(borderWidth)` for a `Border` — into the
  padding it applies). So a full-bleed bordered row's outer box is
  `1 + top + content + bottom + 1`, not `top + content + bottom`, and between two abutting
  rows the two borders stack into a 2dp line. Forgetting this under-reports every bordered
  row by 2dp and every neighbour gap by 2dp. Final geometry after the owner picked 6/8 for
  the five bordered tabs and 4/4 for the one floating-card tab: floating card 64.0 → 68.8
  (+7.5%), bordered row 66.0 → 76.8 (+16.4%) against the naive +20.8dp, neighbour
  content-to-content gap 26 → 16dp. Two padding values for what greps as one literal,
  because the two designs pay for separation differently.
- *Two findings logged for the owner rather than fixed (both deliberately out of scope):*
  (1) the five full-bleed rows draw their divider with `FlutterFlowTheme.of(context).greyL2`
  where `alternate` is the semantic divider token — a token-consistency change that would
  alter the line colour on five screens, so it needs its own scope; (2) the six notification
  tabs render **one content type in two different card designs** (All = floating,
  shadowed, 20dp radius, 12dp gutter; the five filters = full-bleed, 1dp border, no
  radius/shadow/margin). That is a genuine design inconsistency and arguably the most
  interesting thing this pass surfaced, but unifying them is a design decision, not a
  padding fix. **Pattern to repeat: when a mechanical sweep uncovers a design-level
  inconsistency, finish the mechanical job on both variants and hand the inconsistency up
  with measurements — don't quietly unify it under cover of the small task.**

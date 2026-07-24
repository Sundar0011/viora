# UI Designer — Self-Improving Playbook

This is ui-designer's private, evolving skill. **Read it fully before every task.**
**After every task, append a dated lesson** below: which design decisions (layout, color, type,
spacing, motion, accessibility) tested well or poorly and why. Supersede old lessons; never delete.

## Lessons learned

### 2026-07-19 — Color palette rework (blue → green-forward), Viora
- **What worked well:** Extracting the EXISTING FlutterFlowTheme token names first (before
  touching the skill) meant every candidate palette could be delivered as a drop-in 1:1 mapping
  table — this is what makes a design spec actually usable by frontend-dev without a second
  clarifying round. Always extract-then-design, never design-then-map.
- **What worked well:** Querying the ui-ux-pro-max `color` domain with multiple phrasings
  (`"community social marketplace warm trustworthy local"`, then narrower `"hyperlocal services
  nearby"`, then `"green trust neighborhood local safety"`) surfaced the right product-type rows
  (Hyperlocal Services, Local Events & Discovery, Marketplace P2P, Membership/Community) instead
  of generic SaaS palettes. One broad query alone under-served the neighborhood-specific angle —
  worth 2-3 query passes with different keyword combinations before picking a direction.
  Also cross-checked the `product` domain (`products.csv`) for the "Hyperlocal Services" entry's
  explicit "Color Palette Focus: Location markers + Trust colors" note — this corroborated the
  green-forward choice with an independent signal, not just the color table alone.
  Cross-referencing `ux-guidelines.csv` confirmed the "don't convey info by color alone" rule,
  which directly shaped the usage guide (icon+text+color for success/warning/error, not color
  alone).
- **What worked well:** Computing WCAG contrast ratios with an actual relative-luminance formula
  (small Python script) instead of eyeballing hex values caught real failures — e.g. the
  database's own "Local Events & Discovery" white-on-primary-orange pairing and a first-pass
  green fell short of 4.5:1 for normal-size button text (landed at 4.36:1/3.01:1/4.03:1/3.30:1).
  Iterating the fill shade darker by ~10-15% luminance fixed all of them while keeping the same
  hue family. Lesson: never present a proposed palette's contrast ratios without actually
  computing them — several "looks fine" combinations from raw DB rows failed AA on inspection.
- **Corrected approach for next time:** When a product category has an obvious market-leading
  competitor with a well-known brand color (e.g. Nextdoor = green for neighborhood apps), name
  that precedent explicitly in the rationale and explain how the proposal differs (distinct
  shade, not a clone) — this makes the "why this hue" argument concrete instead of abstract
  color-psychology claims, and gives the stakeholder a mental anchor for the decision.
- **For future palette/theme tasks:** Always also produce a forward-looking dark-theme token set
  even if the codebase doesn't have a dark theme class yet (as here) — computing it now, with
  the same contrast rigor, avoids a second full design pass later and costs little extra time
  once the light palette's hue logic is settled.

### 2026-07-19 — Design audit of existing Viora screens (feed, post-create, profile, groups,
events, sale, chat, registration, nav, theme)
- **What worked well:** sampling via a mix of full reads (theme, nav, home feed, one detail
  screen per area) plus targeted `Grep` census (counting `SafeArea` usage, sub-44dp width/height
  literals, icon usage) across the whole `lib/` tree caught *systemic* patterns (touch targets,
  missing dark mode, repeated loading-gate boolean pattern) that a single-screen read would have
  missed or under-weighted. Recommend this "read 4-5 full screens + grep-census the rest" method
  for future audits — it's much cheaper than reading every screen and still finds real
  cross-cutting issues.
- **What worked well:** querying `ui-ux-pro-max --domain ux` for 2-3 targeted phrases
  ("empty state loading skeleton", "bottom navigation labels icon") after forming hypotheses
  from the code, not before, kept the search focused and gave concrete severity ratings to cite
  instead of asserting severity myself.
- **What to watch for next time:** FlutterFlow-generated code buries real issues inside very
  long single-`build()` files (1600+ lines) with `if (false)` dead branches (e.g. bottom-nav
  labels disabled, "Read more" logic disabled). Always grep for `if (false)` near `Text(` — it's
  a strong signal of a feature that was designed but never wired up, which is a very different
  (and easier) fix than "redesign this from scratch."
- **Corrected approach for next time:** when a project has both light-only theme code AND an
  in-progress companion palette doc, explicitly write "defer to palette doc" language into every
  color-specific finding rather than naming replacement hex values — avoids the audit and
  palette docs disagreeing later. (Confirmed useful in this same session: the palette task ran
  in parallel and produced its own hex proposals — the audit's deferral language meant zero
  conflict between the two docs.)

### 2026-07-20 — Flock brand artwork (app icon / onboarding hero / splash), hand-authored SVG
- **What worked well:** designing one reusable primitive first (a single stroke-based "gull-wing"
  bird path: `M -100,10 Q -55,-35 0,-5 Q 55,-35 100,10` with round linecap/join) and then
  composing every asset (icon, hero, splash badge) from `<use>` instances at different
  translate/rotate/scale meant all three deliverables stayed visually consistent for free, and the
  math for "does this still read at 20px" only had to be solved once. For any future mark/mascot
  work, build the smallest reusable glyph primitive before composing scenes — cheaper to verify
  correctness once than per-instance.
- **What worked well:** explicitly computing the OS icon safe zone as a circle (r≈325-335 centered
  at 512,512 in a 1024 canvas, i.e. Android adaptive-icon safe-zone / iOS corner-crop convention)
  and checking each bird's extreme point against that radius with the distance formula before
  finalizing coordinates caught a near-miss (a bird at ~352 distance vs. 350 radius) that "looks
  fine at a glance" would have missed. Always compute icon safe-zone math, don't eyeball it —
  same "compute, don't eyeball" principle as contrast ratios, now confirmed useful for geometry too.
- **What worked well:** for a "must look right on light AND dark backgrounds" hero/illustration
  requirement, giving the SVG its own full opaque background rect (not relying on the host page's
  background to show through) is the correct pattern — confirmed this explicitly in the file's own
  header comment so frontend-dev/future editors don't accidentally strip the bg rect thinking it's
  redundant.
- **What worked well:** when a brief asks for "both light and dark treatment" of a single
  deliverable file (the splash), stacking both compositions in one SVG canvas (top half light,
  bottom half dark) — rather than picking one or awkwardly toggling via CSS classes only usable in
  HTML — kept the deliverable genuinely a single self-contained vector file as asked, while still
  letting the preview HTML crop each half into its own phone frame via a second `viewBox` window
  onto literally the same markup (no duplicated/divergent source of truth between the two treatments).
- **Corrected approach for next time:** SVG `id` attributes collide across multiple inline copies
  in one HTML document (e.g. showing the same icon 5 times at different sizes) — browsers silently
  resolve `url(#id)`/`href="#id"` references to the *first* matching id in the DOM. Since gradient
  defs were identical in every instance this didn't visually break anything here, but it's fragile;
  going forward, always suffix every id per inline instance (`-a`, `-b`, `pl`/`pd`, etc.) from the
  start rather than relying on "the defs happen to be identical anyway."
- **Font substitution note (reusable across future Baloo 2 / display-font work):** portable
  hand-authored SVGs can't embed non-system fonts reliably across every rasterizer, so `<text>`
  wordmarks should ship with an explicit rounded-sans fallback stack
  (`'Baloo 2','Fredoka','Quicksand','Nunito','Poppins',sans-serif`) plus an explicit code-comment
  note to swap to the real font or convert to outlines at production/rasterization time — keeps the
  approval artifact editable (real `<text>`, not paths) while being honest about what's missing.

### 2026-07-20 — Full rebrand redesign (Viora green → "Flock" warm gradient), light+dark, HTML mockup
- **What worked well:** Treating the brief's own inspiration pair (Instagram/Threads +
  Airbnb/Meetup) as the design-read constraint, then explicitly cross-checking the
  `design-taste-frontend` skill's "LILA RULE" (no default AI-purple) and "premium-consumer
  beige/brass ban" before picking hues, produced a palette that isn't the generic reach (avoided
  purple even though "gradient accents" could have tempted it; avoided cream/beige even though
  "warm" could have tempted it). Landed on a raspberry→coral→amber "Sunrise" gradient instead —
  distinct, on-brief, and tied to the "Flock" name (birds at golden hour). Recommend re-reading
  the anti-default rules from the frontend taste skill before finalizing hues even on a *mobile
  app* task, not just web landing pages — color-calibration and shape-consistency-lock rules
  generalize past their web framing. Cross-referencing `colors.csv` (`Membership/Community`,
  `Social Media App`, `Pet Tech App` rows) gave concrete anchors to differentiate from.
- **What worked well:** computing actual WCAG relative-luminance contrast for the two
  interactive brand colors (primary raspberry, secondary teal) against white text before
  finalizing hexes caught that the first vibrant coral candidate (`#FF5C72`) only hit ~3:1 —
  reused the "compute, don't eyeball" lesson from 2026-07-19 and it paid off again. Kept a
  brighter "decorative-only" tint of the same hue for gradient/hero surfaces (never for small
  text) rather than discarding the vibrant color entirely — this two-tier pattern
  (vibrant-for-graphics vs. darkened-for-text/buttons) is reusable whenever a brief wants a
  "pops" primary color that must also carry button text.
- **What worked well:** auditing `flutter_flow_theme.dart` fully + 4 real `_widget.dart` files
  (splash, community, navbar, profile) *before* designing tokens meant the spec could map every
  new color onto the theme's actual field names (`primary`, `pageBack`, `accent1`...) AND flag a
  concrete hardcoded-hex example found in the navbar (`Color(0xFF0B7A52)` bypassing the theme) as
  a specific implementation risk, not a generic warning. Grepping `Color(0xFF` literals across
  `_widget.dart` files is now a standing recommendation for future Flutter re-theme tasks.
- **Corrected approach for next time:** the HTML mockup's phone-frame markup was duplicated by
  hand per screen (6 phones) rather than templated — fine at this scale but would not scale past
  ~8-10 frames in one static file. For a larger mockup, plan a smaller number of canonical
  reusable blocks copied more mechanically to reduce copy-paste drift risk.
- **For future rebrand tasks:** explicitly separating "theme-level (cheap, global)" vs.
  "per-screen work" in the spec's implementation note, and naming the specific file/line where a
  hardcoded color was found, measurably increases how directly frontend-dev can act on the spec
  without a clarifying round. Keep doing this for every redesign handoff.

### 2026-07-21 — Full-codebase UI review (census method, all 469 files)
- **What worked well:** running a *counting* census (`grep -c` per file, sorted) across the whole
  `lib/` tree instead of the previous "read 4-5 screens + spot-grep" method turned vague
  qualitative findings into ranked, defensible ones. Concrete example: the 2026-07-19 audit said
  the login page was "the single confirmed safe-area regression"; a `for f in $(grep -rl Scaffold)`
  loop checking each file for `SafeArea` proved **all 10 registration screens** lack it. Same
  method upgraded "icons are inconsistent" into "183 Inter/InterTight overrides concentrated in
  Community(27)/Search(24)/profiles(14+14)". Always convert a hypothesis into a count before
  writing it as a finding — the count also produces the fix priority for free.
- **What worked well:** checking `pubspec.yaml` for a dependency *before* recommending a fix.
  `cached_network_image: 3.4.1` was already installed but used exactly once against 149 raw
  `Image.network` calls. "The library you already pay for is unused" is a far stronger
  recommendation than "consider adding caching" — it removes the approval/dependency question
  entirely (CLAUDE.md §2 forbids new deps without approval, so already-present deps are the only
  frictionless path). Check the manifest before proposing any library-shaped fix.
- **What worked well:** opening with a "what already landed" section crediting the dark theme,
  Baloo 2 + Manrope wiring, and the per-theme `shimmerHighlight` token. It reframed the whole
  review as "the design system is fine, the screens don't consume it" — which is both true and a
  much more actionable framing than a flat defect list. Re-audit before assuming prior findings
  are still open: 3 of the previous audit's Top 10 were already fixed, and reporting them again
  would have destroyed trust in the rest of the document.
- **Corrected approach for next time:** zero-hit greps are findings, not empty results. `Semantics(`
  = 0 and `tooltip:` = 0 across 469 files was the most severe item in this review, and a search
  that returns nothing is easy to skim past as "no data." Deliberately probe for the *absence* of
  accessibility affordances, error states, and `errorBuilder`s — the null result IS the headline.
- **For future reviews:** rank findings by (user impact x cheapness), not by severity alone. It
  produced a Sprint 1 of five purely mechanical passes (SafeArea, font swap, 10px->12px, print
  stripping, color literals) that needs no design input and can start immediately — far more
  likely to actually ship than a list led by a component-library rewrite.

### 2026-07-21 (follow-up) — CENSUS METHODOLOGY BUG: single-line grep undercounts FlutterFlow code
- **What went wrong (the important lesson):** the full-codebase census in the same-day review was
  built entirely on single-line `grep -c`. **`dart format` wraps long argument lists at deep
  nesting**, so a large fraction of real occurrences span two lines and were silently invisible:
  `font: GoogleFonts\n    .interTight(` and `fontSize:\n    10.0,`. Implementation agents running
  newline-tolerant scans found 75 Inter sites in `lib/pages/group/**` where the census reported 19,
  59 colour literals where it reported 14, and 28 small-text sites where it reported 15. Two
  folders reported "0 undersized text" that actually had sites. The review's headline numbers were
  floors, not totals — off by 2-4x in the worst folders.
- **Why it nearly caused real damage:** those wrong counts were pasted into every implementation
  brief as explicit targets ("19 sites in this folder"). An agent that trusts a stated target and
  stops when it hits it leaves the wrapped instances behind — which is exactly what happened in
  `lib/pages/profile/**`, where the agent reported "20/20 fixed, zero skipped" and 13 wrapped
  instances remained. Caught only because the lead re-verified with a multiline scan instead of
  believing the completion report.
- **Corrected approach, now standing for this codebase:** census FlutterFlow-generated Dart ONLY
  with `Grep(multiline: true)` and `\s*\n\s*`-tolerant patterns —
  `GoogleFonts\s*\.\s*(inter|interTight)\s*\(`, `fontSize:\s*10(\.0)?\s*,`. Never `grep "X.Y("`.
- **Two derived rules that generalise beyond this bug:**
  1. **State counts as floors, not targets.** Brief agents as "find and fix ALL occurrences using a
     newline-tolerant scan; the number below is a known-low floor, not a target" — never as a bare
     number, which invites stopping early.
  2. **Verify completion claims against the artifact, not the report.** "20/20, zero skipped" was
     sincere and wrong, because the agent inherited the lead's flawed method. A sub-agent using
     your method cannot detect your method's blind spot — only an independent re-scan can.
- **What worked well anyway:** three separate agents independently caught and reported the
  undercount rather than silently fixing to the stated number. Briefs that say "report anything you
  skip and why" surface methodology bugs upward; briefs that only demand a count would have buried
  it.

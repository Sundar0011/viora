# Viora — UI/UX Design Audit

Date: 2026-07-19
Author: ui-designer (design review only — no UI code changed)
Scope: sampled screens across feed, post creation, profile, groups, events, marketplace
(sale), chat, registration, bottom nav, and the shared theme (`flutter_flow_theme.dart`).
Grounded in `ui-ux-pro-max` (`references/pro-rules.md`, `ux-guidelines.csv`) and the
`flutter-build-responsive-layout` / `flutter-fix-layout-issues` skills.

**Companion doc:** a new color palette is being drafted in parallel at
`docs/design/color-palette.md`. Any finding below that is purely about *which* color to use
(hex values, contrast pairs, semantic tokens) defers to that doc — this audit only flags
*where* color is causing a problem, not what the replacement value should be.

Screens read: `lib/pages/home/home_page/`, `lib/pages/post/create_post/`,
`lib/pages/profile/profile/`, `lib/pages/profile/other_profile/`,
`lib/pages/group/group_details/`, `lib/pages/events/event_details/`, `lib/pages/sale/sale/`,
`lib/pages/sale/sale_details/`, `lib/chat/message_page/`,
`lib/pages/registration/login_page/`, `lib/pages/registration/create_account_page/`,
`lib/pages/components/comp_navbar/`, `lib/flutter_flow/flutter_flow_theme.dart`.

---

## Top 10 — fix first

1. **Bottom nav has no visible/accessible labels** (`comp_navbar_widget.dart`) — every label
   `Text` is wrapped in `if (false)`, so the 5 tabs are icon-only with no text and no
   `Semantics`/`tooltip`. High severity, affects every screen with the nav.
2. **Login page body is not wrapped in `SafeArea`** (`login_page_widget.dart`) — the back
   button and heading can render under the status bar/notch on iOS and under Android cutouts.
3. **Systemic touch targets under 44×44** — search bar (36dp), message icon (34dp), avatars
   used as tap targets (32dp), like/follow/report affordances (padding 6 around 14–22dp icons)
   recur across home feed, group details, sale details. High severity, WCAG/Apple/Material
   violation, repeated hundreds of times (565 raw hits for sub-40dp interactive sizing).
4. **No dark mode** — `FlutterFlowTheme.of(context)` always returns `LightModeTheme()`
   regardless of system brightness; only one theme class exists. Any OS-level dark mode user
   gets a jarring, unreadable-in-low-light experience system settings promised them.
5. **No app-wide empty states** — feed, group posts, and similar list screens only branch on
   `showPost`/`loader` (loading vs. loaded); there is no rendered state for "0 items," so users
   land on a blank page with no explanation or call to action.
6. **Low-contrast secondary text token reused everywhere** — `greyL4` (`#979797`) on white is
   used for timestamps, city, follow/like/comment/share counts, "Following" label. Estimated
   contrast ~2.8:1 on white, well under the 4.5:1 body-text minimum. Defer exact fix color to
   `color-palette.md`, but flag: this token is used dozens of times per screen.
7. **Icon system is inconsistent** — Material icons (`Icons.favorite_border`,
   `Icons.message_rounded`), FontAwesome, and hand-picked raster PNG/WebP assets
   (`forum.png`, `share_windows.png`, `loyalty_blue.webp`) are mixed on the same screen and
   even in the same row, with no shared stroke width, filled/outline discipline, or sizing
   scale.
8. **Hardcoded, non-token colors sprinkled through widget code** — e.g.
   `Color(0xFFF7F9FC)`, `Color(0x19FFFFFF)`, `Color(0x14000000)`, `Color(0xFF264AFF)` inline in
   `home_page_widget.dart` and `comp_navbar_widget.dart` instead of `FlutterFlowTheme` tokens.
   Breaks single-source-of-truth theming and will fight the upcoming palette migration.
9. **Post overflow menu uses absolute pixel offsets** (`Padding(0, 36, 36, 0)` in
   `home_page_widget.dart`) instead of anchored/overlay positioning — on narrow phones (≤360dp)
   or with large system font, this menu can clip against the screen edge.
10. **`home_page_widget.dart` is 1,663 lines** — far over the 400-line project limit (CLAUDE.md
    §5). This is a maintainability issue more than a pure UX one, but it directly causes #6–#9:
    duplicated inline styling instead of shared components makes every inconsistency 10× more
    likely and harder to fix in one place.

---

## Per-area findings

### Theme (`lib/flutter_flow/flutter_flow_theme.dart`)

| Issue | Why it hurts UX | Severity | Fix |
|---|---|---|---|
| Only `LightModeTheme` exists; `FlutterFlowTheme.of()` ignores `MediaQuery.platformBrightnessOf` | Users who set their OS to dark mode get an app that never respects it — inconsistent with platform-level accessibility/comfort expectations (esp. OLED battery, light sensitivity, night use) | High | Design + build a `DarkModeTheme`, switch `of()` on `Theme.of(context).brightness` (or an app-level toggle), and audit every hardcoded `Color(0x...)` against it once `color-palette.md` lands |
| `FFSpacing`/`FFRadius`/`FFShadows` design tokens exist but are barely used in the screens sampled — most widgets hardcode raw pixel `EdgeInsetsDirectional.fromSTEB(...)` values instead | Spacing drifts screen to screen (e.g. 4/6/8/9/10/12/14/16/20 all appear as arbitrary paddings in one file) — no visible rhythm | Med | Adopt the existing `FFSpacing` (4/8/16/24/32) as the actual source for all new/edited paddings; see cross-cutting §"8pt spacing scale" below |
| Typography scale (Display/Headline/Title/Label/Body) is well-formed and consistently derived from theme getters | — | — | Keep; this is a strength, not a finding |
| No `dynamic type` / accessibility text-scale handling anywhere in the codebase — zero hits for `textScaler`/`textScaleFactor` overrides | Not necessarily wrong (default Flutter behavior does respect system font scale), but the audit found many fixed-height `Container`s wrapping `Text` (e.g. 34–56dp bars) which will clip or overflow once the OS text scale is increased | Med | Verify layouts at largest Dynamic Type / Android "Largest" font setting; replace fixed-height text containers with `IntrinsicHeight`/min-height + padding so text can grow |

### Bottom navigation (`lib/pages/components/comp_navbar/`)

| Issue | Why it hurts UX | Severity | Fix |
|---|---|---|---|
| All 5 tab labels wrapped in `if (false)` — icon-only nav, no text, no `Semantics(label:)` | Icon-only nav without labels fails the ui-ux-pro-max "ARIA/accessible name for icon-only controls" rule (High) and forces users to learn 5 custom icon glyphs (home/community/post/notifications/sale) with no textual anchor — worse for new users and screen-reader users (TalkBack/VoiceOver will read nothing meaningful) | High | Re-enable the label `Text` under each icon (the layout scaffolding for it already exists — just flip the `if (false)`), or at minimum add `Semantics(label: 'Home')` etc. around each `InkWell` |
| Tap targets are icon (28×28) + `Flexible` cell but the icon itself has no extra hit-slop padding beyond the cell's natural row division | Whether this passes 44×44 depends on final row height (54dp bar / 5 cells ≈ 68dp wide, 54dp tall) — width is fine, but effective vertical hit area for the icon graphic is tight against the 54dp bar; verify with the actual rendered rect | Low | Confirm each cell's effective touch rect ≥44×44; the `InkWell` already spans the full `Flexible`, so this is likely fine — re-check once labels are re-added since the icon must shrink to fit |
| Active-state indicator is a raw `Color(0xFF264AFF)` 2dp top bar, not sourced from `theme.primary` even though it's currently the same value | Ties the "active" affordance to a color that will silently diverge from the primary brand color once `color-palette.md` changes `primary` | Med | Replace `Color(0xFF264AFF)` literal with `FlutterFlowTheme.of(context).primary` |
| 5 items — within the ≤5 bottom-nav item limit | Good — no fix needed | — | Keep at 5 |
| No badge/dot on the "Post" or "Community" tabs, but a small unread dot exists elsewhere (message icon in the header, not the nav) — inconsistent placement of notification badges between header icons and nav icons | Users have two different places notifications can appear (header message bubble vs. nav "Notifications" icon) with two different visual treatments | Low | Standardize badge treatment/token once component library is unified |

### Feed / Home (`lib/pages/home/home_page/`)

| Issue | Why it hurts UX | Severity | Fix |
|---|---|---|---|
| Search entry point is a fake 36dp-tall button styled as a search field (not a real input) | Sets a false affordance (looks like you can type, but it's a nav trigger) and the tap target is under the 44dp minimum | Med | Increase to ≥44dp tall, and consider whether a real inline search-preview affordance is wanted, or keep it a button but make the affordance clearly "tap to search" (e.g. chevron) |
| Avatar (32dp) and message icon (34dp) in the header are both below the 44×44 touch minimum | Small mis-taps, especially for older/motor-impaired users this Nextdoor-style app's demographic skews toward | Med-High | Increase hit area via padding/`InkWell` bounds without growing the visual avatar size (44dp tap zone, 32dp visual is acceptable per Apple HIG "expand hit area, not visuals") |
| Post card actions (like, comment, share) use 6dp padding around 14–22dp icons ⇒ effective tap target 26–34dp | Same touch-target problem, repeated 3× per post, on the single highest-traffic screen in the app | High | Standardize a `min 44x44` `InkWell`/`GestureDetector` wrapper component for all icon actions |
| No empty state when `posts.length == 0` (only a shimmer-vs-list branch on `showPost`) | A new user in a quiet neighborhood sees a blank page with no explanation, defeating onboarding | Med | Add an empty state: illustration/icon + "No posts yet in your neighborhood" + primary CTA (e.g. "Create the first post") |
| Mixed icon families in one post-actions row (Material `Icons.favorite_border` next to raster `forum.png`/`share_windows.png`) | Breaks visual rhythm/consistency — stroke widths and pixel density won't match, especially at 2x/3x DPI | Med-High | Migrate all post-action icons to one vector icon set (Material or a single custom SVG set) at a shared 22dp size |
| Report-post menu positioned via hardcoded `Padding(0, 36, 36, 0)` instead of anchored positioning | Risk of clipping on narrow devices / large text; not verified against `flutter-build-responsive-layout` guidance (avoid hardcoded pixel offsets, prefer `LayoutBuilder`/anchor widgets) | Med | Replace with `showMenu`/`CompositedTransformFollower` anchored to the trigger button |
| `RefreshIndicator` present (good — supports pull-to-refresh) and shimmer loading state exists (good) | — | — | Keep |
| File is 1,663 lines, single build method nested ~15 levels deep for one post card | Not a direct user-facing issue, but every inconsistency above lives inside this one file because there's no shared `PostCard` widget being reused — makes future consistency fixes expensive | Med | Extract a `PostCardWidget` (frontend-dev), see cross-cutting recommendations |

### Post create (`lib/pages/post/create_post/`)

| Issue | Why it hurts UX | Severity | Fix |
|---|---|---|---|
| Header close button uses `FlutterFlowIconButton` (good — this component defaults to a real `buttonSize`, unlike ad hoc `InkWell`+`Icon`) | Positive pattern — this is the right way to build icon buttons | — | Prefer `FlutterFlowIconButton` everywhere instead of bare `InkWell`+`Icon` (see cross-cutting) |
| Avatar shown at 40×40 with `BoxFit.fill` (not `.cover`) | `BoxFit.fill` stretches non-square source images, distorting profile photos if the network image isn't already 1:1 | Low | Change to `BoxFit.cover` for any avatar image |
| `SafeArea(top: true)` used (bottom defaults to `true`) — correctly protects both status bar and gesture/home-indicator area | — | — | Keep |
| Visibility/audience picker triggered via `showModalBottomSheet` (good pattern, respects `MediaQuery.viewInsetsOf` for keyboard) | — | — | Keep this pattern; reuse it as the standard sheet pattern app-wide |

### Profile (`lib/pages/profile/profile/` and `other_profile/`)

| Issue | Why it hurts UX | Severity | Fix |
|---|---|---|---|
| Header bar height fixed at 56dp with a 24dp icon back button inside a `FlutterFlowIconButton` — target size depends on that widget's default `buttonSize` (not overridden here, so likely defaults to a safe size) | Needs verification once `FlutterFlowIconButton`'s default is confirmed ≥44dp; flagged as a spot-check, not a confirmed defect | Low | Confirm `FlutterFlowIconButton` default `buttonSize` ≥44 project-wide (single fix point since it's reused everywhere) |
| `SafeArea(top: true)` used correctly | — | — | Keep |
| Profile screen is a single long `SingleChildScrollView` mixing header, stats, actions, and lists — consistent with the rest of the app's "one big Column" pattern rather than modular sections | Harder to maintain, same root cause as the feed page's file-size issue | Med | Same fix as feed: extract reusable sections (stats row, action row, tab bar) |

### Groups (`lib/pages/group/group_details/`)

| Issue | Why it hurts UX | Severity | Fix |
|---|---|---|---|
| `_model.loader` boolean gates the whole body between "nothing rendered" and the real content — no loading skeleton/spinner was found in the sampled portion of this screen | A blank frame while `loader == true` reads as a frozen/broken app rather than "loading" | Med | Add a skeleton or `CircularProgressIndicator` for the loading branch, consistent with the shimmer pattern already used on the home feed |
| `SafeArea(top: true)` used correctly; `RefreshIndicator` present | — | — | Keep |
| Group actions (assign admin, invite, revoke, join requests) are each separate bottom-sheet components (`comp_assign_admin`, `comp_invite_friends`, etc.) — good modular decomposition compared to the feed page | — | — | This is the pattern the feed/profile pages should be refactored toward |

### Events (`lib/pages/events/event_details/`)

*(sampled via grep census; not fully read line-by-line given budget — flagged for a closer pass by frontend-dev during implementation)*

| Issue | Why it hurts UX | Severity | Fix |
|---|---|---|---|
| File shows the same `SafeArea(top: true)`-only + one big Column structure as other detail screens | Consistent with rest of app (neither better nor worse) | — | Apply the same "extract reusable sections" cross-cutting fix |
| Confirm attend/RSVP button and share/report actions follow the same icon-only, sub-44dp affordance pattern seen elsewhere (19 icon usages, several sub-30dp per the size grep) | Same touch-target risk class as the feed | Med | Apply the shared `min 44x44 InkWell` wrapper fix once built |

### Marketplace — Sale list & Sale details (`lib/pages/sale/sale/`, `lib/pages/sale/sale_details/`)

| Issue | Why it hurts UX | Severity | Fix |
|---|---|---|---|
| `showData` boolean load-gate pattern repeats (same as sale_details, group_details, home) — confirms this is a systemic pattern, not a one-off | Predictable to fix once, at the pattern level | Med | Create one shared `LoadingGate`/`AsyncStateView` widget (loading / empty / error / data) and use it everywhere instead of re-deriving the same three `if` branches per screen |
| Default message pre-filled as `'Hi, is this available?'` in the contact-seller text field | Good UX — reduces friction to start a conversation | — | Keep |
| 9 icon-sized (`~20-38dp`) elements found in `sale_details_widget.dart` per the size grep — consistent with the sub-44dp touch-target pattern | Same class of issue as feed/groups | Med-High | Same shared wrapper fix |
| Category and distance filters (`comp_kms_filter`, `comp_category_filter`) are separate small components — good decomposition, unlike the feed | — | — | Reuse this decomposition pattern elsewhere |

### Chat (`lib/chat/message_page/`)

| Issue | Why it hurts UX | Severity | Fix |
|---|---|---|---|
| `SafeArea(top: true)` used, with bottom defaulting to `true` — correctly protects the message input bar from the iOS home indicator / Android gesture bar | — | — | Keep — this is the one screen in the sample where keyboard-safe-area handling is clearly intentional |
| Real-time subscribe/unsubscribe/resubscribe on page load with a hardcoded `1000ms` delay before resubscribing | Not a visual UX issue per se, but a network hiccup during that window could show a stale conversation with no "reconnecting" indicator | Low | Note for tester/backend-dev: confirm no visible gap between disconnect and reconnect; add a subtle "connecting…" affordance if gaps are observed |
| Back button via `FlutterFlowIconButton` (consistent, good) | — | — | Keep |

### Registration — Login & Create Account (`lib/pages/registration/login_page/`, `create_account_page/`)

| Issue | Why it hurts UX | Severity | Fix |
|---|---|---|---|
| **Login page `body:` is NOT wrapped in `SafeArea`** — only a plain `Container` with a full-bleed background image, then content directly inside `Column`/`SingleChildScrollView` | Back button and "LOGIN TO YOUR ACCOUNT" heading can render under the iOS status bar / Android display cutout on notched devices — this is the single confirmed safe-area regression in the sample | High | Wrap `body:` content in `SafeArea` (top: true at minimum), matching every other screen in the sample |
| Create Account page does use `SafeArea` (1 hit in grep) | — | — | Confirm it wraps the full body, not just a sub-tree, during implementation |
| Back button (24dp icon, via `FlutterFlowIconButton`) floats over a background image with `Align`/`Padding`, not a solid header bar | On busy or light-colored background photos, a plain icon with no scrim/shadow can lose contrast against the image | Med | Add a subtle scrim gradient behind top controls, or a semi-opaque circular backing (`accent4`/`shadow.sm` tokens already exist for this) |
| Background image filename `image_(1).webp` — a default/unnamed export, not a semantic asset name | Not user-facing, but signals this may be a placeholder never finalized | Low | Confirm with product whether this is the intended final registration background |

---

## Cross-cutting recommendations

### 1. Design tokens & 8pt spacing scale
`FFSpacing` (4/8/16/24/32) and `FFRadius` (8/16/24/full) already exist in
`flutter_flow_theme.dart` but are not consistently used — most screens hardcode raw
`EdgeInsetsDirectional.fromSTEB(...)` pixel values (6, 9, 10, 12, 14, 20 all appear on a single
screen). Recommendation:
- Treat `FFSpacing`/`FFRadius`/`FFShadows` as the only legal source for new/edited spacing and
  radius values. Snap every padding/margin to `xs(4) / sm(8) / md(16) / lg(24) / xl(32)`.
- Add one more token, `xxs(2)`, only if a genuine sub-4dp hairline case is found (e.g. divider
  dots) — otherwise resist adding more tiers; five is already the right size for a mobile scale.
- Where a value like `6` or `9` currently sits between two tokens, round up to the nearest
  token rather than keep the bespoke value — spacing consistency reads as "polish" per
  `pro-rules.md` §Layout & Spacing.

### 2. Shared component patterns (biggest lever for consistency)
Nearly every inconsistency in this audit (icon mixing, touch-target size, missing empty states,
hardcoded colors) recurs because each screen re-implements the same UI pattern from scratch
inside one giant `build()` method instead of composing shared widgets. Recommend building
(frontend-dev, once scoped):
- `AppIconButton` — wraps an icon in a guaranteed ≥44×44 tap target, single icon family, single
  stroke width, replaces ad hoc `InkWell`+`Icon` and standardizes on top of the already-good
  `FlutterFlowIconButton` pattern seen in create-post/profile/chat.
- `PostActionButton` (like/comment/share) — one component, icon + count + tap target, used by
  feed, group posts, and anywhere else post actions repeat.
- `AsyncStateView` — loading / empty / error / data states as one wrapper, replacing the
  repeated `showData`/`loader`/`showPost` boolean-branch pattern found in home, group_details,
  and sale_details.
- `EmptyState` — icon/illustration + message + optional CTA, used by `AsyncStateView`'s empty
  branch and reused for search-no-results, empty group, empty sale list, etc.

### 3. Icon system
Pick one vector icon family as the single source (Material Symbols outline is already the
majority pattern via `Icons.*`) and retire the raster PNG/WebP icon assets
(`forum.png`, `share_windows.png`, `loyalty_blue.webp`, `home_blue.png`, etc.) in favor of
themed vector icons that can tint correctly for the future dark mode. This is the single
highest-leverage fix for "does this look professional" per `pro-rules.md` §Icons & Visual
Elements (no mixing filled/outline, no mixing raster/vector, consistent stroke width).

### 4. Motion
Current motion is minimal and appropriate: `AnimatedContainer` 300ms `easeOut` for nav
tap-state, default sheet-open transitions for modals, `fade` transitions between top-level
pages (0ms duration — effectively an instant swap, not a fade). Recommendations:
- Nav tap highlight at 300ms is slightly slow versus the pro-rules guidance of 150–300ms for
  micro-interactions — 300ms is within range but at the outer edge; no change required, note
  for tester.
- Page transitions declared as `PageTransitionType.fade` with `Duration(milliseconds: 0)` are
  not actually animating (0ms = instant cut) — either intentional (fast nav) or a leftover
  FlutterFlow default; confirm intent. If a fade is actually wanted, use 150–200ms.
- No `reduced motion` handling was found anywhere (`MediaQuery.disableAnimations` not
  referenced). Low severity today since motion is minimal, but note for the pre-delivery
  checklist once dark mode / new components add more animation.

### 5. Safe areas & responsive layout
Most screens correctly wrap `body:` in `SafeArea(top: true)` (bottom defaults to `true`), which
is the right pattern. The one confirmed miss is the login page (§Registration above). No screen
in the sample used `LayoutBuilder` or width breakpoints — everything assumes a single phone
width. Per `flutter-build-responsive-layout`, this is acceptable for a phone-only mobile app
today, but if/when tablet or foldable support is ever in scope, list/detail screens (feed,
sale list) should switch to `LayoutBuilder` + `ConstrainedBox(maxWidth: ~600)` centered content
rather than stretching a single-column feed to full tablet width.

### 6. Contrast & color (hand-off to `docs/design/color-palette.md`)
Do not duplicate specific hex values here. Flag for the palette doc: `greyL4` (secondary text
color, `#979797` today) is reused as the *only* secondary/caption text token across the app and
currently reads under 4.5:1 on white/near-white surfaces. The new palette must supply a
secondary-text color that (a) meets 4.5:1 on both `primaryBackground`/`secondaryBackground`
surfaces in light mode, and (b) has a defined dark-mode counterpart meeting 3:1+ once dark mode
is built (see §Theme above).

---

## Pre-delivery checklist status (for reference — not yet run against a finished build)
Per `references/pro-rules.md`, before any screen touched by this audit ships:
- [ ] Re-test at 375px width and in landscape
- [ ] Re-test with largest Dynamic Type / Android "Largest" font size
- [ ] Re-test with reduced motion enabled
- [ ] Verify dark mode independently once built (currently N/A — dark mode doesn't exist)
- [ ] Confirm every touch target ≥44×44 after the `AppIconButton`/`PostActionButton` fixes land
- [ ] Confirm no content sits under safe areas (login page fix must land first)

---

## Notes for other agents
- **frontend-dev**: the shared-component recommendations (§Cross-cutting #2) are the most
  efficient way to fix items 1, 3, 6, 7, 9 on the Top 10 list in one pass rather than
  screen-by-screen.
- **doc-keeper**: once `docs/design/color-palette.md` is finalized, cross-link it from this
  file's §6 and update the "greyL4 contrast" finding with the resolved token name.
- **security-reviewer/tester**: item #2 (login `SafeArea`) and item #5 (empty states) are the
  two items with the clearest "before/after" test — recommend prioritizing verification of
  those first once frontend-dev implements fixes.

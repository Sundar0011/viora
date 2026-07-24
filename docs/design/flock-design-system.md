# Flock — Design System Spec
### "Flock — find your people." — rebrand of Viora/SQUADD

Status: Direction proposal for owner review. UI-only. No logic/nav/backend changes implied.
Audited against: `lib/flutter_flow/flutter_flow_theme.dart`, `lib/pages/registration/splash/`,
`lib/pages/community/community/`, `lib/pages/components/comp_navbar/`, `lib/pages/profile/profile/`.

---

## 1. Design read

**Reading this as:** a mobile neighborhood social + marketplace app redesign (preserve structure,
overhaul surface), for a general consumer/family audience, with a "playful & social, but still a
place you trust your real address to" language, leaning toward an Instagram/Threads image-forward
feed system blended with Airbnb/Meetup's warm, rounded, human photography-led product language.

**Concept (2-3 sentences):** Flock replaces the flat, slightly institutional emerald-green Viora
look with a warm "golden-hour" identity — a raspberry-to-amber sunrise gradient that reads as
gathering, warmth, and togetherness (birds *flocking* home at dusk), paired with a fresh teal that
carries the "trustworthy local network" signal the old green used to carry alone. Big rounded
type, soft chunky buttons, generous card radii, and a signature gradient used deliberately (hero
moments, avatar rings, active states) — never smeared across every surface.

**Adjectives:** warm, rounded, sociable, grounded, expressive.

**Anti-slop check:** No AI-purple glow. No beige/brass "premium artisan" palette (this isn't that
brief). One signature gradient, used with intent, not decoration everywhere. Two-font pairing,
both real Google Fonts already resolvable via the `google_fonts` package the app already uses.

---

## 2. Color tokens

### 2.A The signature gradient — "Sunrise"
Used for: onboarding hero background, the primary gradient CTA button, active-tab indicator,
avatar rings for stories/highlights, empty-state illustration washes. **Not** for card
backgrounds, body text, or more than one element per screen.

| Stop | Hex | Role |
|---|---|---|
| 0% | `#C42D63` | Raspberry (anchor — matches Primary) |
| 55% | `#FF6F5E` | Coral |
| 100% | `#FFC145` | Amber |

Flutter: `LinearGradient(colors: [Color(0xFFC42D63), Color(0xFFFF6F5E), Color(0xFFFFC145)], begin: Alignment.topLeft, end: Alignment.bottomRight)`
Dark-mode variant (brighter, for a dark canvas): `#FF6F94 → #FF9142 → #FFD166`.

### 2.B Light theme — maps to `LightModeTheme` fields

| Token (FlutterFlowTheme field) | Hex | Notes |
|---|---|---|
| `primary` | `#C42D63` | Raspberry. Verified 5.4:1 white-text contrast (button fills). |
| `secondary` | `#0B7A70` | Fresh teal — trust/secondary actions, links, verified badge. 5.2:1 white-text contrast. |
| `tertiary` | `#FFC145` | Amber — chips, highlights, gradient's warm stop. Use with dark text. |
| `alternate` | `#F1E4E7` | Soft raspberry-tinted neutral for dividers/borders (replaces flat `#E3E7E2`). |
| `primaryText` | `#1C1424` | Warm near-black (plum-black, not the banned "espresso" brown family). |
| `secondaryText` | `#6B6478` | Muted warm grey-violet, for captions/timestamps/labels. |
| `primaryBackground` | `#FFFBF9` | App canvas — warm near-white, not stark, not cream/beige. |
| `secondaryBackground` | `#FFFFFF` | Cards, sheets, nav bar surface. |
| `accent1` | `0x4CC42D63` | Primary @30% — pressed/selected tint. |
| `accent2` | `0x4D0B7A70` | Secondary @30% — secondary pressed/selected tint. |
| `accent3` | `0x4DFFC145` | Amber @30% — highlight/tag chip fill. |
| `accent4` | `0xCCFFFFFF` | White @80% — overlay on imagery (unchanged role). |
| `success` | `#1B9E6B` | |
| `warning` | `#F2A93B` | |
| `error` | `#E4453B` | Deliberately distinct hue from `primary` so errors never look like a brand accent. |
| `info` | `#2F6FED` | |
| `pageBack` | `#FFFBF9` | = `primaryBackground` (keep parity, several screens use `pageBack` directly). |
| `white` | `#FFFFFF` | unchanged |
| `extraBlack` | `#150F1A` | unchanged role, warmed hue |
| `primaryD3` / `primaryD4` | `#8E1F49` / `#A02653` | Darker raspberry steps (pressed states, dark icons on tint). |
| `primaryL1` | `#FBE4EC` | Pale raspberry tint — selected-row backgrounds. |
| `tertiaryL1` | `#FFF3DC` | Pale amber tint — existing role (e.g. verified banner bg). |
| `greenColor1` / `greenColor2` | `#128F63` / `#17A673` | Keep as "positive/money" accents for marketplace price tags, sold badges. |
| `redColor2` | `#D8321F` | Destructive-action/delete accents (distinct step from `error`). |
| `secondaryNormal` | `#FF4C6A` | Notification dot / "new" badge — bright, on-brand pink-red. |
| `greyL2`…`greyL5`, `greyD1`, `greayL1` | unchanged greys, nudge 2-3% warmer if trivial | Low priority — cosmetic only. |
| `shimmerColor` | `0x1A1C1424` | Loading skeleton tint, matches new `primaryText`. |

### 2.C Dark theme (new `DarkModeTheme` class)

| Token | Hex | Notes |
|---|---|---|
| `primary` | `#FF6F94` | Brightened raspberry for dark-canvas legibility. |
| `secondary` | `#3FC7B8` | Brightened teal. |
| `tertiary` | `#FFCE6E` | Brightened amber. |
| `alternate` | `#332933` | Dividers/borders on dark. |
| `primaryText` | `#F6F1FA` | Warm off-white. |
| `secondaryText` | `#B3A8C2` | Muted warm lavender-grey. |
| `primaryBackground` | `#15111C` | Deep plum-black (not neutral slate — ties to brand hue). |
| `secondaryBackground` | `#221B2B` | Cards/sheets/nav bar on dark. |
| `accent1`–`accent4` | same hexes as light, applied over dark base | Opacity tokens are theme-agnostic. |
| `success` / `warning` / `error` / `info` | `#3FBE8C` / `#FFC15C` / `#FF6B60` / `#5C8DFF` | Brightened for AA on dark bg. |
| `pageBack` | `#15111C` | |
| `extraBlack` (dark) → repurpose as near-white for icon-on-dark parity, OR keep literal black for true-black elements (e.g. camera UI) — **decision needed, see Section 8.** |

**Contrast verification performed (relative-luminance formula, not eyeballed):**
- Light `primary` `#C42D63` + white text → **5.4:1** (passes AA body text).
- Light `secondary` `#0B7A70` + white text → **5.2:1** (passes AA body text).
- Light `primaryText` `#1C1424` on `primaryBackground` `#FFFBF9` → >15:1 (passes AAA).
- Dark `primaryText` `#F6F1FA` on `primaryBackground` `#15111C` → >14:1 (passes AAA).
- The brighter **decorative** gradient stop `#FF6F5E`/`#FFC145` is for large surfaces/graphics
  only — never render body-size text directly on the raw gradient without a scrim; use white
  text ≥ 24px bold, or add a `0x33000000` scrim behind text on photographic/gradient hero art.

---

## 3. Typography

**Pairing:** `Baloo 2` (display/headline — rounded, chunky, expressive; carries the "Flock"
wordmark and screen titles) + `Manrope` (body/label/title — already partially used in this
codebase, warm rounded humanist sans, excellent at small sizes). Both are real Google Fonts
resolvable via the existing `google_fonts` package — no new dependency.

Rationale: Baloo 2 alone at body sizes hurts legibility (it's a display face); Manrope alone
everywhere reads as generic-clean SaaS, not "playful." The pairing gives Flock a distinct
headline voice while keeping paragraphs, buttons, and list rows crisp on small screens.

| Typography field (theme) | Family | Weight | Size | Notes |
|---|---|---|---|---|
| `displayLarge` | Baloo 2 | 700 | 56 | Splash "Flock" wordmark only. |
| `displayMedium` | Baloo 2 | 700 | 40 | Onboarding headline ("find your people."). |
| `displaySmall` | Baloo 2 | 600 | 32 | Section hero headers (e.g. group/event hero). |
| `headlineLarge` | Baloo 2 | 600 | 28 | Page titles (Community, Profile name on own profile). |
| `headlineMedium` | Baloo 2 | 600 | 24 | Card/section headers. |
| `headlineSmall` | Baloo 2 | 600 | 20 | Sub-section headers, dialog titles. |
| `titleLarge`/`Medium`/`Small` | Manrope | 700 | 20/18/16 | List item titles, post author name, button labels. |
| `labelLarge`/`Medium`/`Small` | Manrope | 600 | 16/14/12 | Chips, tags, timestamps, nav labels. |
| `bodyLarge`/`Medium`/`Small` | Manrope | 400 | 16/14/12 | Post body, comments, form helper text. |

Line-height: 1.3 for display/headline, 1.45 for body (up from the current 1.4 flat value — small
bump improves feed-comment readability). Letter-spacing: 0 everywhere except `labelSmall`
uppercase tags, which get `+0.2`.

---

## 4. Spacing, radius, elevation, iconography, motion

**Spacing scale** (unchanged values, keep — already sane): `xs 4 / sm 8 / md 16 / lg 24 / xl 32`.

**Radius — the playful signature.** Current scale (`sm 8 / md 16 / lg 24 / full 9999`) stays, but
usage shifts warmer/rounder as the *default*, not the exception:
- Buttons: **`full`** (pill) for all primary/secondary/gradient buttons — matches the existing
  splash CTA (`borderRadius: circular(24)` on a 46px button is already almost-pill; make it fully
  pill).
- Cards/post tiles: **`lg` (24)**, up from typical `12-16` seen in feed cards today.
- Inputs/chips: **`md` (16)**.
- Avatars: circle (unchanged) but add an optional **gradient ring** (2-3px, "Sunrise" gradient)
  for own-profile avatar and story/highlight affordances — an Instagram-native cue, used sparingly.

**Elevation.** Keep the existing `FFShadows` scale but retint: shadows should be tinted toward
the raspberry hue at low opacity instead of pure black, per warm-shadow best practice —
`Color(0x1AC42D63)` instead of `Color(0x1A000000)` for card shadows; keep pure-black shadows only
for deep overlays (bottom sheets, modals).

**Iconography.** Keep current icon usage (Material + FontAwesome, per audit). Standardize stroke
weight where using outline-style icons; filled icons for active/selected nav state, outline for
inactive — reinforces the existing "active row lights up" navbar pattern already coded.

**Motion.** Personality = playful, so motion should feel spring-y, not linear:
- Standard transition: 200-250ms, `Curves.easeOutCubic` → replace with `Curves.easeOutBack` (very
  subtle overshoot, ~4-6% overshoot) for button press / tab switch / like-heart pop.
- Like/heart tap: scale 1.0 → 1.3 → 1.0 spring pop (150ms), matches Instagram's double-tap heart
  moment — the single "delight" animation this app should own.
- Page transitions: keep existing fade/push patterns (do not touch navigation-layer code) —
  motion changes here are widget-internal (button/like/tab), not route-level.
- Respect reduced-motion: gate the spring overshoot behind `MediaQuery.disableAnimations` check.

---

## 5. Component specs

**Primary button** — pill radius (`full`), solid fill `primary` (`#C42D63`), white `titleSmall`
Manrope 700 text, 46-52px height (existing splash CTA height of 46 is fine, matches ≥44px touch
target), `Curves.easeOutBack` press animation, `scale(0.97)` on `:active`.

**Gradient button** (new — reserved for the single highest-priority CTA per flow, e.g. onboarding
"Get Started", "Create post"): Sunrise gradient fill, pill radius, white text, subtle 4px soft
raspberry-tinted shadow. Only one gradient button visible on screen at a time.

**Secondary button** — pill radius, transparent fill, 1.5px `secondary` (teal) border, `secondary`
text color. Used for "Cancel", "Not now", filter toggles.

**Cards / post tiles** — `lg` (24px) radius, `secondaryBackground` fill, warm-tinted soft shadow
(`FFShadows.sm` retint per Section 4), 16px internal padding, avatar 40px circle + gradient ring
option for the post author if they're a "top neighbor"/verified, image media gets full-bleed with
matching 24px top corners only when image is edge-to-edge inside the card.

**Inputs** — `md` (16px) radius, `alternate`-colored 1.5px border at rest, `primary` border +
subtle `accent1` glow on focus, label above field (already the pattern in registration screens —
preserve), 48px min height for ≥44px touch target with padding.

**Bottom navbar** (`comp_navbar_widget.dart`) — keep the existing 54px height, 5-icon structure
and the coded active-row highlight mechanic (`_model.nav == 'optN'` → tinted background); change:
the thin 2px active-indicator bar currently hardcoded `Color(0xFF0B7A52)` → `primary` (`#C42D63`)
in light / `#FF6F94` in dark; active icon fills solid, inactive stays outline; background =
`secondaryBackground`, unchanged top shadow, retinted per Section 4.

**Chips/tags** (category filters, group tags) — pill radius, `tertiary`/amber fill at 20% opacity
w/ `primaryD3`-ish dark text when unselected, solid `primary` fill + white text when selected.

**Avatars** — circle, sizes already used in audit (32px navbar, 64px profile header) — keep sizes;
add the optional 2-3px Sunrise gradient ring for the signed-in user's own avatar and for
"featured/verified neighbor" badges elsewhere in feed.

**Badges** (verified, sold, new) — pill, small (`labelSmall`), colored per semantic token
(`success` for verified/sold, `secondaryNormal` for "new"), never color-only — pair with a small
icon (checkmark, tag) per the existing "don't convey info by color alone" rule already in this
project's own audit history.

---

## 6. Screen-level direction (mapped to real screens found in audit)

- **Onboarding/landing (`splash_widget.dart`)** — currently: hero image top + stacked headline
  text ("REAL PEOPLE. REAL PLACES. / REAL CONNECTIONS") + full-width pill CTA. New: Sunrise
  gradient wash behind/around the hero photo (not replacing photography — layered, e.g. gradient
  as a soft bottom-fade scrim behind the headline block), Baloo 2 wordmark "Flock" above the
  headline, headline copy becomes "find your people." in Baloo 2, gradient CTA button (the one
  gradient-button use-case for this whole app), same layout structure/order (image → headline →
  subcopy → CTA) preserved.
- **Community feed (`community_widget.dart`)** — currently: top bar with avatar + tab switch
  (community/business) + `pageBack`/white surfaces. New: `lg`-radius post cards with warm shadow,
  avatar gradient ring for own avatar in header, active tab uses `primary` underline/fill instead
  of flat green, unread/notification dots use `secondaryNormal`.
- **Profile (`profile_widget.dart`)** — currently: back-button header row, 64px avatar + name row,
  stat rows below. New: optional gradient ring around the 64px avatar, `headlineLarge` (Baloo 2)
  for the display name, stat numbers in `titleLarge` Manrope 700, `secondary` teal for
  "verified"/location chip, section cards get `lg` radius + warm shadow to match feed cards.
- **Bottom navbar (`comp_navbar_widget.dart`)** — see Component specs above; structure/interaction
  logic untouched, only color/fill/indicator retint.

---

## 7. Implementation note (for frontend-dev)

**Theme-level (cheap, global — do first):**
- All of Section 2 (color tokens) — a straight edit inside `LightModeTheme` in
  `lib/flutter_flow/flutter_flow_theme.dart`, plus adding a new `DarkModeTheme` class (does not
  exist today — currently `FlutterFlowTheme.of(context)` always returns `LightModeTheme()`;
  wiring an actual light/dark switch is a **decision needed**, see Section 8).
- All of Section 3 (typography) — edit `ThemeTypography` font family/weight getters in the same
  file. Because every screen reads fonts through `FlutterFlowTheme.of(context).displayLarge` etc.
  (confirmed in audit — splash/community/profile all consume theme typography), this single file
  change propagates everywhere with zero per-screen edits for text that doesn't use
  `.override(font: GoogleFonts.manrope(...))` inline.
- `FFShadows` retint (Section 4) — one file, global.
- `FFRadius` values — already generous; no change needed to the scale itself, only *usage*.

**Per-screen (`_widget.dart`) work — cannot be avoided by theme edits alone:**
- Several screens hardcode literal colors instead of theme tokens (confirmed in audit — e.g.
  `comp_navbar_widget.dart` line ~119 hardcodes `Color(0xFF0B7A52)` for the active-tab bar instead
  of referencing `theme.primary`). Every such hardcoded hex needs a manual find-and-replace pass
  per widget file — frontend-dev should grep for `Color(0xFF` and `Color(0x` literals across
  `lib/pages/**/*_widget.dart` before considering the redesign complete.
- Card/button radius bumps (`BorderRadius.circular(N)` literals) are per-widget, since FlutterFlow
  code sets radius inline on most components rather than through a shared card widget.
- The gradient button, gradient avatar ring, and heart-pop animation are **new** small
  components/widgets that don't exist yet and need to be built once, then reused.
- Dark mode: `FlutterFlowTheme.of(context)` must be wired to actually branch on
  `Theme.of(context).brightness` (or app-level setting) once `DarkModeTheme` exists — currently a
  no-op stub always returning light. This is a small but real logic touch-point outside pure
  "recolor," flagged for the owner/backend-adjacent review even though it's UI-layer.

---

## 8. Open decisions for the owner

1. **Dark mode toggle source**: system-driven (`MediaQuery.platformBrightness`) vs. an in-app
   settings toggle vs. both. Affects a small amount of state wiring beyond pure theming.
2. **Icon style**: keep the current Material + FontAwesome mixed icon set, or move to a single
   rounded icon family for stronger "playful" cohesion? (Design system above assumes "keep
   current set, just enforce fill/outline for active/inactive.")
3. **Gradient button scope**: confirmed as "onboarding CTA + create-post/create-listing CTA only,"
   or should it also apply to other primary actions (e.g. "Join group")? Spec above defaults to
   the narrowest scope (max 1 gradient CTA visible per screen) — confirm this is desired restraint
   vs. wanting it more prominent.
4. **App icon / splash asset**: rebrand replaces "SQUADD"/"Viora" wordmark text but the actual
   image assets (`assets/images/new_splash.png`, app icon, favicon) are out of this UI spec's
   scope — confirm who owns regenerating those bitmap/vector assets.

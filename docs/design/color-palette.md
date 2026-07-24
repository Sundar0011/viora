# Viora Color Palette — Design Spec

Status: PROPOSED (design spec only — no UI code changed by this document)
Author: ui-designer
Date: 2026-07-19
Source data: `.claude/skills/ui-ux-pro-max` (`colors.csv`, `products.csv`, `ux-guidelines.csv`) +
extraction from `lib/flutter_flow/flutter_flow_theme.dart`

---

## 0. How to use this doc

Every proposed token below maps 1:1 onto the existing `FlutterFlowTheme` field names (`primary`,
`secondary`, `tertiary`, `alternate`, `primaryText`, `secondaryText`, `primaryBackground`,
`secondaryBackground`, `accent1-4`, `success`, `warning`, `error`, `info`, plus the extended
FlutterFlow-generated tokens `greyL4`, `greyL2`, `extraBlack`, `primaryD3`, `pageBack`, `white`,
`greenColor1`, `greyL3`, `greyL5`, `greayL1`, `primaryD4`, `tertiaryL1`, `customColor1`,
`primaryL1`, `redColor2`, `greenColor2`, `greyD1`, `secondaryNormal`, `shimmerColor`). frontend-dev
can drop hex values straight into `LightModeTheme` (and a future `DarkModeTheme`, which does not
exist yet — `FlutterFlowTheme.of(context)` currently always returns `LightModeTheme()`) with no
restructuring. Dark values are provided as a forward-looking spec for when dark mode is built.

---

## 1. Current palette (extracted) and why blue underperforms

Extracted from `LightModeTheme` in `lib/flutter_flow/flutter_flow_theme.dart`:

| Token | Hex | Role |
|---|---|---|
| primary | `#264AFF` | Brand blue — buttons, app bar, active nav, links |
| secondary | `#39D2C0` | Teal accent |
| tertiary | `#EE8B60` | Soft orange accent (already warm — underused) |
| alternate | `#E0E3E7` | Neutral divider/chip background |
| primaryText | `#14181B` | Body/heading text |
| secondaryText | `#57636C` | Muted text |
| primaryBackground | `#F1F4F8` | Screen background (blue-tinted grey) |
| secondaryBackground | `#FFFFFF` | Card/surface |
| accent1 | `#4C4B39EF` (30% of a violet-blue, not even primary) | Tinted primary chip/badge |
| accent2 | `#4D39D2C0` (30% secondary) | Tinted secondary chip/badge |
| accent3 | `#4DEE8B60` (30% tertiary) | Tinted tertiary chip/badge |
| accent4 | `#CCFFFFFF` (80% white) | Overlay tint |
| success | `#249689` | Teal-green |
| warning | `#F9CF58` | Yellow |
| error | `#FF5963` | Red-pink |
| info | `#FFFFFF` | White (currently a no-op — flagged below) |
| primaryD3 / primaryD4 / primaryL1 | `#1B35B5` / `#2343E8` / `#E9EDFF` | Blue shade/tint ramp |
| tertiaryL1 | `#E9F9F8` | Teal tint (paired with secondary, not tertiary — naming mismatch, keep as-is for parity) |
| pageBack | `#F7F9FC` | Blue-tinted page background |
| greenColor1 / greenColor2 | `#0F8849` / `#00AF54` | Standalone greens (price/status use) |
| redColor2 / secondaryNormal | `#E03616` / `#FF4C4C` | Standalone reds (destructive/notification use) |
| customColor1 | `#B3B665` | Olive, decorative |
| greys / black / white | `greyL2-5`, `greyD1`, `extraBlack`, `white` | Neutral ramp, hue-agnostic — no change needed |

**Two implementation bugs worth flagging (not fixed here, just noted for backend/frontend-dev):**
`accent1` is tinted from a violet-blue (`#4B39EF`) that isn't actually the `primary` value
(`#264AFF`) — likely stale from a prior brand color. `info` is set to plain white, which is a
no-op token; it should carry a real "informational" hue.

### Why blue underperforms for Viora

Viora is a **neighborhood social network + local marketplace** — its job is to make a stranger
feel "these are my actual neighbors, this place is safe, and I can trust a transaction here."
Blue's psychology (calm, corporate, financial, generic "trustworthy tech") is correct for
banking/SaaS/logistics, but it works against Viora on three specific axes:

1. **Warmth/approachability** — Blue is the single most oversaturated hue in mobile software
   (every social/tech app defaults to it: Facebook, LinkedIn, Twitter/X-classic, Messenger).
   Viora's current `#264AFF` reads as "generic social app," not "your street." Community and
   neighborhood products need warmth to differentiate from cold corporate tools — see the
   ui-ux-pro-max `products.csv` entries for **Hyperlocal Services** and **Local Events &
   Discovery**, both of which pair a warm hue (green or orange) with blue only as a minor accent,
   never as the dominant brand color.
2. **Locality signaling** — Green is the strongest available cross-cultural signal for
   "neighborhood/local/growth/community" (parks, gardens, "go," "verified/safe") and is the
   proven brand color of the category-defining competitor (Nextdoor). Orange/coral is the
   strongest signal for "marketplace energy, human warmth, approachable social." Blue signals
   neither — it signals "utility app."
3. **Marketplace trust ≠ blue-only.** Trust in P2P marketplaces (the `ui-reasoning.csv`
   "Marketplace (P2P)" entry) is built with a grounded primary hue + a clear green
   accept/transact color, not by leaning on blue. Blue can still appear as a small `info` accent
   (e.g. map pins, links) without being the brand identity.

Blue is not "wrong" in an absolute sense — it is wrong as the *dominant* hue for this specific
product category, which is the stakeholder's exact concern.

---

## 2. Candidate palettes

All three below were pulled and cross-checked against the skill's `colors.csv` product-type
entries for **Hyperlocal Services**, **Local Events & Discovery**, **Membership/Community**, and
**Marketplace (P2P)** — not invented from scratch. Every text/background and text/fill pairing
below has a measured WCAG contrast ratio (formula-verified, not eyeballed).

### Candidate A — "Community Green" (RECOMMENDED)

**Rationale:** Green is the category's proven trust/locality color (same territory as the
market-leading neighborhood app), paired with a warm terracotta secondary and a golden tertiary
for marketplace energy (ratings, badges, "for sale" highlights). This is the smallest possible
change to existing UX patterns — the *shape* of the palette (primary/secondary/tertiary as three
distinct hues) doesn't change, only the hues do, and the existing `tertiary` orange is already
close to the new secondary, minimizing re-training of visual memory for anyone who has used the
app in testing.

**Light theme**

| Token | Hex | Notes |
|---|---|---|
| primary | `#0B7A52` | Community green — brand, primary buttons, app bar, bottom nav active |
| secondary | `#C74F29` | Warm terracotta — secondary CTA, "sell/list" actions, tags |
| tertiary | `#F2B134` | Golden amber — ratings, favorites/star, badges (pair with dark text only) |
| alternate | `#E3E7E2` | Neutral divider/chip bg (green-grey neutral) |
| primaryText | `#14181B` | Unchanged — already correct |
| secondaryText | `#55625B` | Warmed dark grey-green |
| primaryBackground | `#F5F8F5` | Light green-tinted grey screen bg |
| secondaryBackground | `#FFFFFF` | Unchanged |
| accent1 | `#4C0B7A52` | 30% primary tint (chip/badge bg) |
| accent2 | `#4DC74F29` | 30% secondary tint |
| accent3 | `#4DF2B134` | 30% tertiary tint |
| accent4 | `#CCFFFFFF` | Unchanged (white overlay) |
| success | `#0B7A42` | Distinct from primary via icon/label, never color-alone |
| warning | `#F5A623` | Amber, distinguishable from tertiary in context |
| error | `#C22A1E` | Warm red |
| info | `#2C6ECB` | The one remaining blue — map pins, links, "info" banners only |
| greenColor1 | `#0F8849` | Unchanged (already compatible) |
| greenColor2 | `#00AF54` | Unchanged |
| redColor2 | `#E03616` | Unchanged |
| secondaryNormal | `#FF4C4C` | Unchanged |
| customColor1 | `#B3B665` | Unchanged (olive, decorative) |
| primaryD3 | `#084F37` | Darkest primary — strong emphasis / pressed |
| primaryD4 | `#0B6E4C` | Mid-dark primary — hover/pressed state |
| primaryL1 | `#E3F4EC` | Very light primary tint (chip bg) |
| tertiaryL1 | `#FDF3E0` | Light tertiary/gold tint |
| pageBack | `#F7FAF8` | Light green-grey neutral |
| greyL2 / greyL3 / greyL4 / greyL5 / greyD1 / greayL1 / extraBlack / white / shimmerColor | unchanged | Hue-agnostic neutrals — no change needed |

**Dark theme (forward spec — no `DarkModeTheme` class exists yet)**

| Token | Hex | Notes |
|---|---|---|
| primary | `#34C38F` | Lightened for AA on dark bg (icon/link use) |
| secondary | `#F08A55` | Lightened terracotta |
| tertiary | `#F7C55C` | Lightened gold |
| alternate | `#2A322D` | Dark neutral divider |
| primaryText | `#F1F4F2` | Near-white |
| secondaryText | `#A9B4AE` | Light grey-green |
| primaryBackground | `#121714` | Dark green-tinted charcoal (not pure OLED black) |
| secondaryBackground | `#1B211D` | Dark surface, one step lighter (elevation) |
| accent1 | `#4C34C38F` | 30% primary tint |
| accent2 | `#4DF08A55` | 30% secondary tint |
| accent3 | `#4DF7C55C` | 30% tertiary tint |
| accent4 | `#331B211D` | Dark overlay tint |
| success | `#4ADE80` | Bright green, AA on dark bg |
| warning | `#FBBF24` | Bright amber |
| error | `#FF7A6E` | Lightened red |
| info | `#6FA8F0` | Lightened blue |

**Contrast ratios (measured, WCAG formula)**

| Pair | Ratio | Result |
|---|---|---|
| primaryText `#14181B` on primaryBackground `#F5F8F5` (light) | 16.69:1 | AA/AAA pass |
| secondaryText `#55625B` on primaryBackground `#F5F8F5` (light) | 5.98:1 | AA pass (body text) |
| secondaryText `#55625B` on secondaryBackground `#FFFFFF` (light) | 6.39:1 | AA pass |
| White text on primary `#0B7A52` (light, button fill) | 5.36:1 | AA pass |
| White text on secondary `#C74F29` (light, button fill) | 4.59:1 | AA pass |
| Dark text `#14181B` on tertiary `#F2B134` (light, badge fill) | 9.45:1 | AA/AAA pass — tertiary must pair with DARK text, never white |
| White text on error `#C22A1E` (light) | 5.76:1 | AA pass |
| Dark text on warning `#F5A623` (light) | 8.81:1 | AA/AAA pass |
| White text on info `#2C6ECB` (light) | 5.00:1 | AA pass |
| White text on success `#0B7A42` (light) | 5.42:1 | AA pass |
| primaryText `#F1F4F2` on primaryBackground `#121714` (dark) | 16.37:1 | AA/AAA pass |
| secondaryText `#A9B4AE` on primaryBackground `#121714` (dark) | 8.48:1 | AA pass |
| secondaryText `#A9B4AE` on secondaryBackground `#1B211D` (dark) | 7.67:1 | AA pass |
| Dark text on primary fill `#34C38F` (dark) | 7.65:1 | AA pass |
| Dark text on secondary fill `#F08A55` (dark) | 7.13:1 | AA pass |
| Dark text on tertiary fill `#F7C55C` (dark) | 11.31:1 | AA/AAA pass |
| Dark text on success fill `#4ADE80` (dark) | 8.56:1 | AA pass |
| Dark text on warning fill `#FBBF24` (dark) | 10.86:1 | AA/AAA pass |
| Dark text on info fill `#6FA8F0` (dark) | 7.01:1 | AA pass |

All pairs clear 4.5:1 (normal text minimum). Several clear 7:1 (AAA) with margin.

**Usage guide**
- Primary CTAs (Post, Send, Join, Buy Now): filled `primary`, white text.
- Secondary/marketplace CTAs (List an item, Sell, Contact seller): filled `secondary`
  (terracotta), white text.
- Tertiary (ratings stars, "New," "Featured" badges, favorite/save highlight): `tertiary` fill
  with **dark** text/icon only — never white on tertiary.
- Bottom nav: active icon/label = `primary`; inactive = `secondaryText`/`greyL4`.
- Like/heart icon: use `secondaryNormal` (`#FF4C4C`) filled state — keep red for the like heart
  (universal convention independent of brand hue); do not repurpose `secondary` terracotta for
  the heart, to avoid confusing it with "sell" actions.
- Chips/filters (category, neighborhood tags): `accent1`/`accent2`/`accent3` tinted backgrounds
  with corresponding solid-color text/border for the active state.
- Links/map pins/"info" banners: `info` blue — this is the one place blue is intentionally kept,
  since blue is the universal convention for links and map pins and doesn't compete with brand.
- Success/error/warning toasts and inline validation: always icon + color + text per the
  accessibility guideline "don't convey info by color alone" (confirmed from `ux-guidelines.csv`).
- Price/monetary highlights in marketplace listings: `greenColor1`/`greenColor2` (already
  compatible with the new green-forward brand, no change needed).

---

### Candidate B — "Community Coral"

**Rationale:** Leads with warm terracotta/coral as primary (matches the `colors.csv`
**Local Events & Discovery** entry) instead of green. Slightly more energetic/social and less
"map/utility," good if the stakeholder wants Viora to feel closer to a lifestyle/social feed than
a civic/neighborhood-watch tool. Blue is kept only as a minor map/info accent.

**Light theme**

| Token | Hex |
|---|---|
| primary | `#C74F29` |
| secondary | `#0B7A52` |
| tertiary | `#F2B134` |
| primaryBackground | `#FFF8F3` |
| secondaryBackground | `#FFFFFF` |
| primaryText | `#14181B` |
| secondaryText | `#57636C` |
| success | `#0B7A42` |
| warning | `#F5A623` |
| error | `#C22A1E` |
| info | `#2C6ECB` |

**Dark theme**

| Token | Hex |
|---|---|
| primary | `#F08A55` |
| secondary | `#34C38F` |
| tertiary | `#F7C55C` |
| primaryBackground | `#17120E` |
| secondaryBackground | `#221A14` |
| primaryText | `#F4EFEA` |
| secondaryText | `#B9ABA0` |

**Contrast (measured)**

| Pair | Ratio | Result |
|---|---|---|
| White on primary `#C74F29` | 4.59:1 | AA pass |
| Dark text on secondary/tertiary gold `#F2B134` | 9.45:1 | AA/AAA pass |
| secondaryText `#57636C` on bg `#FFF8F3` | 5.86:1 | AA pass |

**Usage guide:** Same structure as Candidate A but with primary/secondary swapped — coral drives
CTAs and brand chrome, green becomes the marketplace/transaction accent (list/sell buttons,
success states). Risk: coral-as-primary sits closer to several dating/lifestyle app palettes in
the skill's own database (`Dating App` and `Social Media App` entries both use rose/coral-red as
primary), which slightly dilutes the "trustworthy civic neighbor" read Viora needs for a
marketplace where users transact with strangers.

---

### Candidate C — "Trust Purple + Green" (marketplace-generic)

**Rationale:** Directly matches the skill's **Marketplace (P2P)** and **Membership/Community**
entries verbatim (`#7C3AED` trust purple + `#16A34A` transaction/join green). Purple reads as
premium/trustworthy/modern and is far less saturated in the social/local space than blue, orange,
or green, so it would visually differentiate Viora from every competitor mentioned above.

**Light theme**

| Token | Hex |
|---|---|
| primary | `#6D28D9` |
| secondary | `#A78BFA` |
| tertiary | `#15803D` |
| primaryBackground | `#FAF5FF` |
| secondaryBackground | `#FFFFFF` |
| primaryText | `#4C1D95` |
| secondaryText | `#57636C` |
| success | `#16A34A` |
| warning | `#F5A623` |
| error | `#DC2626` |
| info | `#2C6ECB` |

**Dark theme**

| Token | Hex |
|---|---|
| primary | `#A78BFA` |
| secondary | `#7C3AED` |
| tertiary | `#4ADE80` |
| primaryBackground | `#140F1E` |
| secondaryBackground | `#1E1730` |
| primaryText | `#F1EEFB` |
| secondaryText | `#B7AFC9` |

**Contrast (measured)**

| Pair | Ratio | Result |
|---|---|---|
| White on primary `#6D28D9` | 7.10:1 | AA/AAA pass |
| White on accent green `#15803D` | 5.02:1 | AA pass |
| secondaryText `#57636C` on bg `#FAF5FF` | 5.74:1 | AA pass |

**Usage guide:** Same structural pattern. Risk: purple has weaker "neighborhood/locality"
semantics than green or orange — it reads as "premium SaaS/membership club" (its dominant use
case in the skill's own database) rather than "your street, your neighbors." It solves the
"stop looking like every other blue social app" problem but doesn't lean into the specific
warmth/locality/safety psychology the product needs.

---

## 3. Recommendation

**Candidate A — "Community Green"** (primary `#0B7A52`, secondary `#C74F29`, tertiary `#F2B134`).

Reasoning, in priority order:
1. **Category fit** — Green is the strongest, most defensible signal for
   "neighborhood/local/community/safe" and matches the proven category leader's brand identity
   without copying it exactly (Viora's green is a distinct, more saturated emerald, not a clone).
2. **Warmth is still present** — The terracotta secondary and gold tertiary supply the
   approachability/marketplace-energy the product needs; Viora doesn't become a single-note
   "eco app."
3. **Smallest blast radius for frontend-dev** — Structurally identical token shape to the current
   theme (three-hue primary/secondary/tertiary system, same accent/neutral scaffolding). Only
   hues change, not the design system's architecture. The existing `tertiary` orange already
   sits close to the new secondary, so the "warm" half of the palette barely moves.
4. **Accessibility margin** — Every text pairing clears 4.5:1 with real margin (several clear
   7:1+), including in the forward-looking dark theme, with no compromises needed to hit AA.
5. **Blue is not eliminated, only demoted** — `info` keeps a blue for its universal
   map-pin/link convention, which is a UX plus, not a regression.

Candidate C (purple) is the strongest *runner-up* if the stakeholder's real objection is
"generic," not specifically "cold" — it differentiates hardest from competitors — but it trades
away locality psychology to do it. Candidate B (coral-first) is the strongest runner-up if the
product should feel more like a social feed than a neighborhood-safety tool.

---

## 4. Exact mapping table — FlutterFlow token → recommended hex (Candidate A)

| FlutterFlow token | Light hex | Dark hex (forward spec) |
|---|---|---|
| `primary` | `#0B7A52` | `#34C38F` |
| `secondary` | `#C74F29` | `#F08A55` |
| `tertiary` | `#F2B134` | `#F7C55C` |
| `alternate` | `#E3E7E2` | `#2A322D` |
| `primaryText` | `#14181B` | `#F1F4F2` |
| `secondaryText` | `#55625B` | `#A9B4AE` |
| `primaryBackground` | `#F5F8F5` | `#121714` |
| `secondaryBackground` | `#FFFFFF` | `#1B211D` |
| `accent1` | `#4C0B7A52` | `#4C34C38F` |
| `accent2` | `#4DC74F29` | `#4DF08A55` |
| `accent3` | `#4DF2B134` | `#4DF7C55C` |
| `accent4` | `#CCFFFFFF` | `#331B211D` |
| `success` | `#0B7A42` | `#4ADE80` |
| `warning` | `#F5A623` | `#FBBF24` |
| `error` | `#C22A1E` | `#FF7A6E` |
| `info` | `#2C6ECB` | `#6FA8F0` |
| `greyL4` | `#979797` (unchanged) | — |
| `greyL2` | `#E8E8E8` (unchanged) | — |
| `extraBlack` | `#0C0C0C` (unchanged) | — |
| `primaryD3` | `#084F37` | — |
| `pageBack` | `#F7FAF8` | — |
| `white` | `#FFFFFF` (unchanged) | — |
| `greenColor1` | `#0F8849` (unchanged) | — |
| `greyL3` | `#B9B9B9` (unchanged) | — |
| `greyL5` | `#676767` (unchanged) | — |
| `greayL1` | `#EDEEF1` (unchanged) | — |
| `primaryD4` | `#0B6E4C` | — |
| `tertiaryL1` | `#FDF3E0` | — |
| `customColor1` | `#B3B665` (unchanged) | — |
| `primaryL1` | `#E3F4EC` | — |
| `redColor2` | `#E03616` (unchanged) | — |
| `greenColor2` | `#00AF54` (unchanged) | — |
| `greyD1` | `#494949` (unchanged) | — |
| `secondaryNormal` | `#FF4C4C` (unchanged) | — |
| `shimmerColor` | `#170C0C0C` (unchanged) | — |

Tokens marked "unchanged" are hue-agnostic neutrals/semantics already compatible with the new
brand direction and require no edit.

---

## 5. Notes for frontend-dev / backend-dev handoff

- This document is a **design spec only**. No Dart files were edited.
- `LightModeTheme` field values in `lib/flutter_flow/flutter_flow_theme.dart` should be updated
  to the "Light hex" column above.
- Dark mode does not currently exist as a class (`FlutterFlowTheme.of(context)` always returns
  `LightModeTheme()`); the "Dark hex" column is provided so a future `DarkModeTheme` class can be
  added without a second design pass.
- Two pre-existing bugs are flagged in §1 (`accent1` tinted from a non-primary violet-blue,
  `info` set to plain white) — decide separately whether to fix them as part of this rebrand or
  file them separately; not fixing them silently would carry the same bugs into the new palette
  (accent1 would tint from the wrong source color, info would still be a no-op white).
- All touch targets, spacing, and 44×44 minimum sizes are unaffected by this change — this spec
  is colors only.

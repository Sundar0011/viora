# Flock — Interaction & Polish Spec

One shared recipe so every screen feels like the same app. Anyone doing a polish pass on a
screen implements exactly these patterns — do not invent new ones.

Personality: **playful & social**. Warm, quick, a little bouncy. Never corporate, never slow.

---

## 0. Hard constraints

- **No new dependencies.** `flutter_animate: 4.5.0` is already in `pubspec.yaml`. Use it.
- **No logic changes.** Do not touch `*_model.dart`, navigation, state, queries, or `lib/backend/**`.
  Visual and animation changes only.
- **Surgical edits only.** Use targeted edits; never rewrite a whole generated file. These are
  FlutterFlow files — a truncated rewrite silently deletes UI.
- **Never hardcode a colour.** Every colour comes from `FlutterFlowTheme.of(context)`.
  If a token is missing, add it to BOTH `flutter_flow_theme.dart` and
  `flutter_flow_theme_dark.dart` — never a bare `Color(0x...)` in a widget.
- Verify with `flutter analyze` before finishing. Zero errors, always.

---

## 1. Colour compliance

| Wrong | Right |
|---|---|
| `Color(0xFF...)` literal in a widget | `FlutterFlowTheme.of(context).<token>` |
| Green/teal for a selected or active state | `.primary` |
| Blue (`.info`) on anything not a hyperlink | `.primary` |
| Bare `Icon(...)` with no `color:` | always set an explicit token colour |
| `Colors.white` as text on a coloured fill | keep — that IS correct on gradient/primary |
| `.white` token as a text colour | wrong in dark mode — that token is a SURFACE |

**Icon rule:** every `Icon(...)` needs an explicit colour. Active/selected → `.primary`.
Idle/decorative → `.secondaryText`. Destructive → `.error`.

**Image-asset tint caution:** `Image.asset(color:)` uses `BlendMode.srcIn`, which flattens ALL
tones to one colour. Safe for single-tone glyphs; it DESTROYS two-tone artwork (e.g. a light plus
cut into a dark diamond). Check the asset before tinting, and screenshot after.

---

## 2. Micro-interactions

Four patterns. Apply them; don't improvise.

### A. List/card entry — staggered
Items cascade in. Never mount a whole list at once.

```dart
.animate().fadeIn(duration: 260.ms, delay: (40 * index).ms)
          .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic)
```
Cap the stagger so long lists don't crawl: `delay: (40 * (index % 8)).ms`.

### B. Press feedback
Every tappable surface must acknowledge the touch.
- Add `HapticFeedback.lightImpact()` in `onTap`/`onPressed` if missing.
- Give `InkWell` a real ripple: `splashColor: FlutterFlowTheme.of(context).primary.withAlpha(0x14)`.
  (FlutterFlow defaults these to `Colors.transparent` — that's why the app feels dead.)

### C. Animated state changes
When a `Container`'s colour/border changes on `setState` (filter chips, tabs, toggles), swap
`Container` → `AnimatedContainer` with:
```dart
duration: 180.ms, curve: Curves.easeOut
```
Colour then eases instead of snapping. Only where it is already a `Container`.

### D. Entrance for empty/error/success art
```dart
.animate().fadeIn(duration: 400.ms)
          .scale(begin: Offset(0.92, 0.92), end: Offset(1, 1), curve: Curves.easeOutBack)
```
`easeOutBack` gives the slight overshoot that reads as "playful".

**Budget:** 150–400ms. Anything slower feels broken on a phone.

---

## 3. Empty states

Every list that can be empty needs one. Structure, in order:

1. Illustration — `assets/images/empty_*.png`, 160–200px
2. Headline — sentence case, 3–5 words, no emoji, no exclamation mark
3. One line of body text saying what will appear here and why
4. An action button **only** when there's something useful to do

Copy rules (from the audit): no "Oops", no "Stay tuned!", no exclamation marks, no Title Case
headers, active voice. Say what happens, plainly.

| Bad | Good |
|---|---|
| `📭 No Notifications Yet` | `Nothing new yet` |
| `Stay tuned! We'll let you know...` | `When neighbours react, invite or message you, it shows up here.` |
| `No Data Found` | `No groups near you yet` |

---

## 4. Loading states

- **Skeletons, not spinners**, for anything with known layout. Match the real content's shape.
- Shimmer colour is always `FlutterFlowTheme.of(context).shimmerHighlight` — never a literal.
- Buttons that trigger network work show an in-button spinner and stay disabled while running.
- Never leave a screen fully blank while loading.

---

## 5. Touch targets & spacing

- Minimum 44×44 for anything tappable (CLAUDE.md §5). Pad the parent; don't scale the icon.
- Respect safe areas on both platforms — Android AND iOS (CLAUDE.md §2).
- Horizontal chip rows keep their trailing "peek" — a partly visible chip signals scrollability.
  That is intentional, not a bug. Do not add trailing padding to hide it.

---

## 6. Definition of done, per screen

- [ ] No hardcoded colours; every icon has an explicit token colour
- [ ] No green/teal or blue active states
- [ ] Lists stagger in (pattern A)
- [ ] Tappables give haptic + visible ripple (pattern B)
- [ ] Chips/tabs animate their state change (pattern C)
- [ ] Empty state present, on-spec, animated (pattern D)
- [ ] Loading = skeleton, shimmer via token
- [ ] `flutter analyze` → 0 errors

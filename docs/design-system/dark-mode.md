# Dark Mode

> Part of the [Alan Mobile Design System](README.md). Dark mode is a first-class theme, not an inversion. Every semantic token has a dark value in [`../../design-tokens/tokens.json`](../../design-tokens/tokens.json).

---

## 1. Principles

1. **Not pure black.** Base background is slate-950 `#020617`; primary surface is slate-900 `#0F172A`. Pure black causes smearing on OLED scroll and harsh halation with light text.
2. **Depth by lightness, not shadow.** Higher surfaces get *lighter*, not a bigger drop shadow. Shadows still exist for true overlays (dialogs, sheets) but are near-black at higher opacity.
3. **Desaturate and lighten brand/semantic colors.** Saturated light-mode colors vibrate on dark. Primary shifts green-600 → green-400; status colors shift to their -400 steps or translucent containers.
4. **Preserve meaning and hierarchy.** The same element reads with the same importance in both themes. Contrast ratios are re-verified, not assumed.
5. **Dim, don't glow.** Large bright surfaces are avoided; white images get a subtle scrim; elevation tint is gentle.
6. **User choice wins.** System / Light / Dark, switchable live, remembered.

---

## 2. Surface & elevation model

| Layer | Light | Dark | Elevation cue (dark) |
|---|---|---|---|
| Background (app) | slate-50 `#F8FAFC` | slate-950 `#020617` | — |
| Surface (cards, app bar, sheets base) | white `#FFFFFF` | slate-900 `#0F172A` | +0 |
| Surface variant (input fill, chips, skeleton) | slate-100 `#F1F5F9` | slate-800 `#1E293B` | +1 |
| Raised surface (menu, dropdown, popover) | white + `elevation3` | slate-800 `#1E293B` + subtle shadow | +1 |
| Overlay surface (dialog, bottom sheet) | white + `elevation4/5` | slate-800 `#1E293B` + strong near-black shadow | +2 |
| Scrim | `rgba(15,23,42,0.48)` | `rgba(2,6,23,0.64)` | — |

**Dark shadows** (overlays only):
```
elevation-1: 0 1px 2px   rgba(0,0,0,.40)
elevation-2: 0 2px 4px-1 rgba(0,0,0,.44), 0 1px 2px rgba(0,0,0,.32)
elevation-3: 0 4px 8px-2 rgba(0,0,0,.48), 0 2px 4px-1 rgba(0,0,0,.36)
elevation-4: 0 12px 20px-4 rgba(0,0,0,.52), 0 4px 8px-2 rgba(0,0,0,.40)
elevation-5: 0 24px 40px-8 rgba(0,0,0,.60), 0 8px 16px-4 rgba(0,0,0,.44)
```
Resting cards in dark mode use a 1px `border` (slate-700) + surface-variant fill for separation, not a shadow.

---

## 3. Color mapping (semantic aliases)

| Alias | Light | Dark | Dark contrast on surface `#0F172A` |
|---|---|---|---|
| `primary` | green-600 `#16A34A` | green-400 `#4ADE80` | 10.3:1 ✓ AAA |
| `primaryHover` | green-700 | green-300 `#86EFAC` | higher |
| `primaryPressed` | green-800 | green-200 `#BBF7D0` | higher |
| `onPrimary` | white | green-950 `#052E16` | on green-400: 9.1:1 ✓ |
| `primaryContainer` | green-100 | green-900 `#14532D` | — |
| `onPrimaryContainer` | green-900 | green-100 `#DCFCE7` | on green-900: ~11:1 ✓ |
| `secondary` | green-500 | green-500 `#22C55E` | 6.5:1 ✓ |
| `background` | slate-50 | slate-950 | text primary 18.6:1 |
| `surface` | white | slate-900 | — |
| `surfaceVariant` | slate-100 | slate-800 | — |
| `onSurface` / `textPrimary` | slate-900 | slate-50 `#F8FAFC` | 15.9:1 ✓ AAA |
| `textSecondary` | slate-500 | slate-400 `#94A3B8` | 6.4:1 ✓ AA+ |
| `textTertiary` | slate-400 | slate-500 `#64748B` | 3.5:1 — large/disabled only |
| `textDisabled` | slate-300 | slate-700 `#334155` | intentionally low |
| `textLink` | green-700 | green-400 `#4ADE80` | 10.3:1 ✓ |
| `border` | slate-200 | slate-700 `#334155` | 1.6:1 (decorative) |
| `borderStrong` | slate-300 | slate-600 `#475569` | 2.3:1 |
| `borderFocus` | green-600 | green-400 `#4ADE80` | 8.9:1 ✓ |
| `divider` | slate-200 | slate-800 `#1E293B` | — |
| `success` | green-600 | green-400 `#4ADE80` | 10.3:1 ✓ |
| `warning` | amber-600 `#D97706` | amber-400 `#FBBF24` | 10.4:1 ✓ |
| `danger` | red-600 `#DC2626` | red-400 `#F87171` | 6.1:1 ✓ |
| `info` | sky-600 `#0284C7` | sky-400 `#38BDF8` | 8.2:1 ✓ |
| `*Container` (status bg) | tint-50 solid | `rgba(hue-500, 0.16)` translucent | text uses `on*Container` = tint-100 |
| `skeletonBase` / `skeletonSheen` | slate-200 / slate-100 | slate-800 / slate-700 | — |
| `overlayScrim` | `rgba(15,23,42,.48)` | `rgba(2,6,23,.64)` | — |

**Status containers in dark** are semi-transparent over the surface (`rgba(<hue-500>, 0.16)`) so they sit naturally on any layer; the text/icon uses the -100 step of the hue for ≥ 7:1.

---

## 4. Component notes (dark-specific)

| Component | Dark treatment |
|---|---|
| **Button / Primary** | green-400 fill + green-950 (dark) label — dark text on bright fill reads best; pressed → green-300 |
| **Button / Secondary** | transparent, green-400 label + 1px green-400 border |
| **Text Field** | fill `surfaceVariant` slate-800, border slate-700, focus 2px green-400, error red-400; placeholder slate-500 |
| **Card** | `surface` slate-900 + 1px slate-700 border; interactive hover → slate-800; no shadow at rest |
| **App bar** | slate-900; on scroll-under → slate-800 + subtle shadow (not a lighter tint jump) |
| **Bottom nav** | slate-900 + 1px top border slate-800; active icon/label green-400; active pill green-900 |
| **Dialog / Sheet** | slate-800 surface + strong near-black shadow + scrim `rgba(2,6,23,.64)` |
| **Snackbar** | stays light-on-dark but uses slate-100 pill with slate-900 text (inverse), so it's distinct from surfaces |
| **Chart** | gridlines slate-800; axis text slate-400; series palette lightened (green-400, sky-400, amber-400, red-400, slate-400, green-300); tooltip slate-800 |
| **Skeleton** | base slate-800, sheen slate-700 |
| **Badge (danger/warning)** | -400 hue fill + slate-950 text, or translucent container + -100 text |
| **Switch** | off track slate-600, on track green-400, thumb slate-100 |
| **Images / avatars** | apply a 1px slate-700 ring; large photos get a `rgba(2,6,23,0.05)` scrim to reduce glare |
| **Illustrations** | maintain a dark-mode variant; never show a white-background illustration on dark |
| **Maps** | switch to a dark map style |
| **Elevation "tint"** | AMDS uses discrete surface steps (900 → 800), not Material's continuous primary-tinted overlay, for predictability |

---

## 5. Theme switching

- **Setting:** Settings → Appearance → Theme: `System (default)` · `Light` · `Dark` (Segmented control).
- **Live:** applies immediately without restart; animate the change with a 200ms crossfade of the root (respect reduced motion → instant).
- **Persistence:** store the choice; on `System`, follow OS changes in real time (including scheduled/auto dark).
- **First frame:** read the theme before first paint (splash honors it) — no white flash into dark.
- **Platform:**
  - Android: `DayNight` / `isSystemInDarkTheme()`; set status/nav bar icon contrast per theme; `values-night` resources only for legacy views.
  - iOS: `UITraitCollection.userInterfaceStyle`; `overrideUserInterfaceStyle` for the manual choice; asset catalog "Any/Dark".
  - Flutter: `MaterialApp(theme, darkTheme, themeMode)`; `AmdsTheme.light/dark` (tokens file).
  - React Native: `useColorScheme()` + a theme context; `amdsLight`/`amdsDark`.
- **System chrome:** status bar, navigation bar, and keyboard appearance match the active theme.

---

## 6. QA checklist (dark mode)

- [ ] Every screen has been viewed in dark; no light-on-light or dark-on-dark
- [ ] No pure-black backgrounds; no pure-white large surfaces
- [ ] All text pairs re-verified ≥ 4.5:1 (large/UI ≥ 3:1) on their actual dark surface
- [ ] Focus ring visible on dark (green-400, 3:1+)
- [ ] Status colors distinguishable and meaning-preserving (icon + label + color)
- [ ] Elevation/overlays read as raised (surface step + shadow), dialogs clearly float
- [ ] Images, avatars, logos, illustrations have dark-appropriate treatment (ring/scrim/variant)
- [ ] Charts legible: gridlines, axes, series palette, tooltips
- [ ] Skeletons and loading states use dark tokens
- [ ] Theme toggle applies live, persists, and `System` tracks the OS
- [ ] Splash and first frame honor the theme (no flash)
- [ ] Status bar / nav bar / keyboard match the theme
- [ ] Screenshots for the store include a dark set

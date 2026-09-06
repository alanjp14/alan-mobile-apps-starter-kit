# Theme Architecture

> Part of the [Alan Mobile Design System](README.md).
> How tokens are structured so `[COMPANY_NAME]`'s brand color (or a whole sub-brand) can be replaced later **without rewriting a single component**.

---

## 1. Three token tiers

```
┌─ PRIMITIVE ─────────────────────────────────────────────┐
│  raw, context-free values. NEVER used in product code.  │
│  color.brand.green.600 = #16A34A   space.4 = 16          │
└────────────────────┬───────────────────────────────────┘
                     │  aliased by
┌─ SEMANTIC ─────────▼───────────────────────────────────┐
│  intent-named, theme-aware. THIS is what components use.│
│  theme.light.primary → {color.brand.green.600}          │
│  theme.dark.primary  → {color.brand.green.400}          │
└────────────────────┬───────────────────────────────────┘
                     │  optionally scoped by
┌─ COMPONENT ────────▼───────────────────────────────────┐
│  one component's override when it needs one.            │
│  button.primary.background → {theme.primary}            │
└────────────────────────────────────────────────────────┘
```

**Product code consumes semantic and component tokens only.** A primitive in a component is a lint failure.

## 2. Semantic naming rules

- Name for **intent**, never for value: `primary`, `error`, `surfaceVariant`, `textSecondary` — not `green`, `blue600`, `card-shadow-2`.
- The same name resolves to different values per theme. `primary` = green-600 in light, green-400 in dark, and `[COMPANY_NAME]`-blue-600 in a future brand theme.
- Pairs are explicit: every `X` that can be a background has an `onX` for content on it (`primary` / `onPrimary`, `warningContainer` / `onWarningContainer`).
- Token names are a **stable contract**. Renaming one is a MINOR release (with an alias) → MAJOR (removal), per [governance.md](../governance.md).

## 3. Source of truth & build pipeline

```
design-tokens/tokens.json          ← W3C Design Tokens (DTCG) format — the ONE source
   (+ split views: colors.json, typography.json, spacing.json, radius.json, shadows.json)
        │  Style Dictionary build  (tool/build-tokens — see starter-template)
        ├─► design-tokens/platforms/variables.css        CSS custom properties (web preview / webviews)
        ├─► design-tokens/platforms/tailwind.config.js   Tailwind preset (preview / NativeWind)
        ├─► design-tokens/platforms/amds_theme.dart      Flutter ThemeData + ThemeExtension
        ├─► design-tokens/platforms/Theme.kt             Jetpack Compose theme + CompositionLocals
        ├─► design-tokens/platforms/theme.ts             React Native theme object
        └─► (add) Tokens.swift                           SwiftUI / UIKit
```

- Never hand-edit generated platform files — change `tokens.json` and rebuild.
- CI runs the build + a **contrast lint** on every token change; a failing pair blocks merge.
- The split JSON files (`colors.json` etc.) are convenience views for tools/designers; `tokens.json` is authoritative.

## 4. Themes

| Theme | Status | Mechanism |
|---|---|---|
| **Light** | default | the base semantic set in `tokens.json` |
| **Dark** | required | a `theme.dark.*` mode overriding only semantic values — see [dark-mode.md](dark-mode.md) |
| **Future brand themes** | supported by design | a new mode (`theme.acmeLight`, `theme.acmeDark`) **or** an overlay file `tokens.<brand>.json` that overrides only semantic + component tokens |
| **High-contrast** | optional | a semantic overlay bumping text/border contrast |

### Adding a brand theme (white-label)

1. Add a `BrandTheme` object at the app level: `{ primarySeed, logoAsset, fontFamily?, radiusScale?, featureFlags }`.
2. Recolor **semantic** tokens from the seed (a ramp generator). Primitives (the neutral slate ramp), the spacing scale, the type scale, and radii stay shared.
3. Regenerate platform theme files (or resolve at runtime).
4. **Components do not change** — they resolve the same semantic names.
5. CI re-runs the contrast lint for the new theme; a failing pair blocks the brand.

Most brands need: a new brand color ramp + a handful of semantic remaps + maybe a font swap. They do **not** need a new spacing/radius/type scale.

## 5. Runtime theme controller

A device-local `ThemeController` holds `{ mode: system|light|dark, textScale (clamped 0.85–2.0), density, boldText, highContrast, brandId? }`:

- Applied **live** (200ms root crossfade; instant under reduced-motion).
- `system` tracks the OS in real time (including scheduled dark).
- A `MediaQuery` / `Configuration` wrapper clamps text scale app-wide while still honoring the user.
- Persisted; never synced (it's device-scoped).

Implementation: [starter-template/state-management.md](../starter-template/state-management.md) · [starter-template/blueprint.md §4](../starter-template/blueprint.md).

## 6. Platform entry points

| | Jetpack Compose | Flutter | React Native | SwiftUI |
|---|---|---|---|---|
| Entry | `AmdsTheme(darkTheme, textScale) { }` — `MaterialTheme` + CompositionLocals | `MaterialApp(theme: AmdsTheme.light, darkTheme: AmdsTheme.dark, themeMode)` + `AmdsThemeExt` | `<ThemeProvider>` over `amdsLight`/`amdsDark` | asset-catalog `Color("amds/…")` (Any + Dark) + `.amds*` text styles |
| Access | `AmdsTheme.colors.primary`, `AmdsSpacing.md` | `context.amds.colors.primary`, `AmdsSpacing.md` | `useTheme().colors.primary` | `Color.amdsPrimary`, `AmdsSpacing.md` |
| Files | [`platforms/Theme.kt`](../../design-tokens/platforms/Theme.kt) | [`platforms/amds_theme.dart`](../../design-tokens/platforms/amds_theme.dart) | [`platforms/theme.ts`](../../design-tokens/platforms/theme.ts) | generate `Tokens.swift` |

## 7. Do / Don't

**Do** — put every design decision in `tokens.json`; consume semantic tokens; name for intent; re-run contrast lint per theme; keep primitives/spacing/type shared across brands.
**Don't** — hand-edit generated files; reference primitives or hex in components; name tokens for their value; ship a brand without a contrast pass; fork components for a brand.

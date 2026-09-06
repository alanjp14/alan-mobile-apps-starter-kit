# AMDS Design Tokens

Single source of truth: **[`tokens.json`](tokens.json)** — W3C Design Tokens Community Group (DTCG) format.
Everything else is derived. See [`../docs/design-system/theme-architecture.md`](../docs/design-system/theme-architecture.md) for the full pipeline.

## Files

| File | Role |
|---|---|
| **`tokens.json`** | **Authoritative source** — all tokens, DTCG format. Consumed by Style Dictionary / Tokens Studio (Figma). |
| `colors.json` | Convenience view of the color section — primitive ramps + semantic light/dark aliases |
| `typography.json` | Convenience view — font families, weights, the 16-role scale |
| `spacing.json` | Convenience view — spacing scale, grid, breakpoints, sizes, density |
| `radius.json` | Convenience view — the 7-step radius scale + usage |
| `shadows.json` | Convenience view — 5 elevation levels, light + dark |
| `platforms/variables.css` | CSS custom properties (web preview / Storybook / hybrid webviews) |
| `platforms/tailwind.config.js` | Tailwind preset (preview / NativeWind) |
| `platforms/amds_theme.dart` | Flutter `ThemeData` + `AmdsThemeExt` extension |
| `platforms/Theme.kt` | Jetpack Compose `AmdsTheme` + CompositionLocals |
| `platforms/theme.ts` | React Native theme object (`amdsLight` / `amdsDark`) |
| _(add)_ `platforms/Tokens.swift` | SwiftUI / UIKit — generate via Style Dictionary + an asset catalog |

> The split `*.json` files and the `platforms/*` files are **generated** from `tokens.json` (hand-authored for v1.0 so teams can start before the build is wired). Keep them in sync — never hand-edit them once the pipeline runs.

## Token tiers

1. **Primitive** — `color.brand.green.600`, `space.4`. Raw values. **Never** used directly in product code.
2. **Semantic** — `theme.light.primary`, `theme.dark.primary`, `theme.*.textSecondary`. Intent-named, theme-aware. **Use these.**
3. **Component** — scoped overrides when a component needs one (`button.primary.background`).

## Build

```bash
npm install --save-dev style-dictionary
node tool/build-tokens.mjs      # or: npm run tokens:build  -> tokens.json -> colors.json… + platforms/*
```

The Style Dictionary config is described in [`../docs/starter-template/developer-handoff.md`](../docs/starter-template/developer-handoff.md) §1. Until it is committed, the generated files here are the reference the build targets.

## Rules

- Change values in **`tokens.json` only**; regenerate the rest.
- Product code imports **semantic** tokens, never hex or primitives (lint-enforced).
- Token names are **stable contracts** — renames follow the [deprecation policy](../docs/governance.md#6-deprecation-policy).
- CI runs a **contrast lint** on every token change; a failing pair blocks merge (per theme, including brand themes).
- Keep `tokens.json` `meta.version` in lockstep with the Figma library version.

## Key values (quick reference)

| | Light | Dark |
|---|---|---|
| primary | `#16A34A` | `#4ADE80` |
| background | `#F8FAFC` | `#020617` |
| surface | `#FFFFFF` | `#0F172A` |
| text primary | `#0F172A` | `#F8FAFC` |
| text secondary | `#64748B` | `#94A3B8` |
| border | `#E2E8F0` | `#334155` |
| error / warning / info | `#DC2626` / `#D97706` / `#0284C7` | `#F87171` / `#FBBF24` / `#38BDF8` |

Spacing `4·8·12·16·20·24·32·40·48·64` · Radius `xs4 sm8 md12 lg16 xl24 2xl32 full` · Motion `100·150·200·250·300·400ms`

## Swapping the brand color

`[COMPANY_NAME]` replaces green without touching components — see [`../docs/design-system/theme-architecture.md`](../docs/design-system/theme-architecture.md) §4. In short: add a `theme.<brand>.*` mode (or a `tokens.<brand>.json` overlay) that overrides **semantic** aliases only; primitives (neutral ramp), spacing, type scale, and radii stay shared; re-run the contrast lint.

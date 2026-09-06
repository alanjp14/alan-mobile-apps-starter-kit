# Prompt · Mobile Design System (create / extend)

> Copy everything below into your AI agent. Fill in **Inputs** first.

---

## Role

You are a **Senior Staff Mobile Product Designer + Design System Architect**. You create and maintain the Alan Mobile Design System (AMDS) — a reusable, cross-platform (Android + iOS) UI/UX foundation for many future enterprise apps.

## Context

- Repository: `alan-mobileapps-master-template`. AMDS source of truth lives in `docs/design-system/` and `design-tokens/`.
- AMDS is **not** an application. It is a master template: foundations, tokens, components, screens, features, architecture, governance.
- Visual direction: **green + white**, clean, modern, premium, minimal, spacious, enterprise-ready. Avoid gradients, clutter, heavy shadows.
- Platform-aware: Material 3 on Android, Apple HIG on iOS, one unified language. Adaptable to phone / small tablet / large tablet.
- Everything is **token-driven** so the brand color can be swapped later without rewriting components.

## Inputs

```
TASK:            [ e.g. "add a high-contrast theme" | "revise the spacing scale" | "document motion" | "create the whole system from scratch" ]
SCOPE:           [ which foundation(s): color | typography | spacing | radius | elevation | iconography | motion | accessibility | dark-mode | theme-architecture ]
BRAND COLOR:     [ hex, default #16A34A green-600 ]
CONSTRAINTS:     [ anything specific, e.g. "must support 3 brand themes", "WCAG 2.2 AAA for text" ]
```

## Rules

1. **Inspect first.** Read every file in `docs/design-system/` and `design-tokens/`. Understand the three-tier token model (primitive → semantic → component). Preserve useful content; improve only where the task requires.
2. **Semantic tokens only in components.** Name tokens for **intent** (`primary`, `error`, `surfaceVariant`), never for value (`green`, `blue600`).
3. **Spacing** is the scale `4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48 · 64`. No arbitrary values.
4. **Typography** uses Inter by default; the 6 role families (Display / Heading / Title / Body / Label / Caption) with size, line-height (fixed px), weight, letter-spacing, usage.
5. **Radius:** xs 4 · sm 8 · md 12 · lg 16 · xl 24 · 2xl 32 · full.
6. **Elevation:** 5 levels; flat-by-default (1px border), shadows only on raise/overlay; dark mode lightens surfaces.
7. **Every color pair** must be verified against WCAG 2.2 (AA = 4.5:1 text / 3:1 large & UI). Include a contrast table.
8. **Light + dark** semantics for every color token. Support future brand themes via the mechanism in `theme-architecture.md`.
9. **Accessibility, responsive behavior, and reduced-motion** are addressed for anything you touch.
10. **Cross-platform:** where you add implementation notes, cover Jetpack Compose, Flutter, React Native (+ SwiftUI where useful) — do not favor one.
11. Update `design-tokens/tokens.json` (authoritative) and the split `*.json` views and (note that) the `platforms/*` files are regenerated.
12. Keep terminology consistent with the rest of the repo. Update every doc that references a value you change (search the repo).

## Expected output

- Modified / created files under `docs/design-system/` and `design-tokens/` only.
- Each foundation doc: overview · the scale/values (tables) · rules · **Do / Don't** · light + dark · responsive/accessibility notes · platform implementation mapping.
- `design-tokens/tokens.json` updated + the relevant split `*.json`.
- If a value changed: a `CHANGELOG.md` entry and a note of every other doc updated.
- A short summary: files created / modified / preserved, decisions, validation performed.

## Validation (the AI must run these before finishing)

- `node tool/validate.mjs` → **0 errors**.
- Every new/changed color pair has a computed contrast ratio and a verdict.
- No hard-coded hex in any component/example.
- Grep the repo for the old value/name — no stale references remain.
- JSON files parse.

## Acceptance criteria (you check)

- [ ] `tool/validate.mjs` passes with 0 errors
- [ ] Token names are intent-based; three tiers respected
- [ ] Spacing/radius/type/elevation stay on the defined scales
- [ ] Light + dark defined for every color token; contrast table included and correct
- [ ] Brand color is still swappable without touching components
- [ ] Accessibility + responsive + reduced-motion addressed
- [ ] Cross-platform mappings present (no single-platform bias)
- [ ] All cross-references updated; CHANGELOG entry added
- [ ] Consistent terminology with the existing repo

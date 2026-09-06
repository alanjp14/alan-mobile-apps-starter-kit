# Alan Mobile Design System (AMDS) v1.0 — Design System

> The shared visual + interaction language for every future `[COMPANY_NAME]` mobile application on **Android and iOS**, delivered natively (Jetpack Compose / SwiftUI), cross-platform (Flutter / React Native), or as embedded webviews.

This is the **design foundation** layer of the master template. See the [repository README](../../README.md) for the full map.

---

## 1. What AMDS provides

| Layer | Where |
|---|---|
| **Foundations** — color, typography, spacing, radius, elevation, iconography, motion | this folder |
| **Theme architecture** — token tiers, semantic naming, brand themes | [theme-architecture.md](theme-architecture.md) |
| **Accessibility** — WCAG 2.2 AA | [accessibility.md](accessibility.md) |
| **Dark mode** | [dark-mode.md](dark-mode.md) |
| **Navigation patterns** | [navigation-patterns.md](navigation-patterns.md) |
| **Components** | [`../component-library/`](../component-library/README.md) |
| **Screens** | [`../screen-library/`](../screen-library/README.md) |
| **Features + architecture** | [`../feature-library/`](../feature-library/README.md) · [`../starter-template/`](../starter-template/README.md) |
| **Design tokens (machine-readable)** | [`../../design-tokens/`](../../design-tokens/README.md) |
| **Figma structure** | [figma-structure.md](figma-structure.md) |
| **Governance & versioning** | [`../governance.md`](../governance.md) |

## 2. Design philosophy

AMDS should feel **fresh · clean · modern · premium · professional · enterprise-ready · smooth · minimal · spacious · easy to scan · touch-friendly · accessible · consistent**.

Visual direction: **green + white** — but the brand color is a **token**, not a hard-coded value, so `[COMPANY_NAME]` can swap it via [theme-architecture.md](theme-architecture.md) without touching components.

Avoid: excessive gradients · visual clutter · decorative elements · heavy shadows.
Prioritize: hierarchy · spacing · typography · readability · usability.

### Principles (applied)

| Principle | In practice | Anti-pattern it prevents |
|---|---|---|
| **Clarity over decoration** | One primary action per screen; typographic hierarchy does the work | Competing CTAs, gradient soup, decorative icons |
| **Consistency is a feature** | Reuse a documented component before inventing one | Five different "card" styles across four apps |
| **Accessible by default** | 4.5:1 text contrast, 44dp targets, labelled controls, visible focus | Grey-on-grey text, unlabelled icon buttons |
| **Fast and calm** | 200ms default, ≤400ms max, reduced-motion honored | 600ms hero animations, parallax everywhere |
| **Token-driven** | `color.primary`, never `#16A34A` in a component | Hard-coded hex that can't be themed |
| **Platform-aware, unified** | Material 3 on Android + Apple HIG on iOS, one design language | A UI that feels foreign on one platform |
| **Scalable** | Add variants, don't fork; deprecate over two minor versions | Breaking renames shipped without migration |

## 3. Platform principles

AMDS is **platform-aware** but presents **one cross-platform design language**:

- **Android** — Material 3 structure, motion, and component behavior.
- **iOS** — Apple Human Interface Guidelines for gestures, navigation feel, haptics, continuous corners.
- **Adaptable** to phone · small tablet · large tablet (see [spacing.md §4](spacing.md)).
- **Implementation mappings** provided for Jetpack Compose · Flutter · React Native · SwiftUI where useful — but this repo is primarily a **design + architecture master template**, not app code.

## 4. Foundations index

| Foundation | File | Scale / key values |
|---|---|---|
| Color | [color-system.md](color-system.md) | 11-step green + slate ramps; semantic aliases; verified contrast |
| Typography | [typography.md](typography.md) | Inter; Display / Heading / Title / Body / Label / Caption |
| Spacing / Grid / Layout | [spacing.md](spacing.md) | 4·8·12·16·20·24·32·40·48·64; 4/8/12-col grid |
| Border radius | [radius.md](radius.md) | xs 4 · sm 8 · md 12 · lg 16 · xl 24 · 2xl 32 · full |
| Elevation | [elevation.md](elevation.md) | 5 levels; flat-by-default |
| Iconography | [iconography.md](iconography.md) | Material Symbols + Lucide; 16–40 sizes |
| Motion | [motion.md](motion.md) | 100–400ms; standard/decelerate/accelerate/spring |
| Foundations overview | [foundations.md](foundations.md) | interaction principles · component states · responsive behavior |

## 5. Adoption model

| Stage | Definition |
|---|---|
| 1 · Tokens | App consumes AMDS tokens for color / type / spacing |
| 2 · Components | App uses AMDS components for ≥60% of UI |
| 3 · Patterns | App uses AMDS screen templates & navigation |
| 4 · Native | App contributes back; no local forks |

New apps start at **Stage 3** by scaffolding from this template. Existing apps migrate token-first.

## 6. Glossary

| Term | Meaning |
|---|---|
| Token | A named design decision (`color.primary`) resolvable to a value |
| Primitive | A raw, context-free token value |
| Semantic token | An intent-named alias that changes per theme |
| Component token | A token scoped to one component |
| Elevation | Perceived z-depth, expressed as a shadow set (1–5) |
| Surface | A container plane that holds content (cards, sheets, app bar) |
| Scrim | The dimming layer behind a modal or drawer |
| Density | Vertical rhythm setting: comfortable (default) vs compact |
| Safe area | Screen region free of notches, home indicators, camera cutouts |
| Dynamic Type | OS-level user font-size preference that UI must respect |
| Archetype | A reusable screen pattern (see [screen-library](../screen-library/README.md)) |

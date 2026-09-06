# Prompt · Component Library Generator

> Copy everything below into your AI agent. Fill in **Inputs** first.

---

## Role

You are a **Principal Product Designer + Design System Engineer + Accessibility Specialist**. You specify reusable UI components for the Alan Mobile Design System (AMDS) to enterprise, production standards.

## Context

- Repository: `alan-mobileapps-master-template`. Component specs live in `docs/component-library/`.
- Design specs: `docs/component-library/design-specs.md`. Engineering API + platform mappings: `docs/component-library/api-reference.md`. Data components: `docs/component-library/data-display.md`.
- Foundations (tokens): `docs/design-system/` + `design-tokens/`.
- Components are `Amds*`-prefixed, token-driven, accessible-by-default, and work on Android + iOS + tablet, light + dark.

## Inputs

```
COMPONENT(S):    [ e.g. "Segmented Control" | "Stepper" | "the whole Feedback group" ]
CATEGORY:        [ Actions | Inputs | Content | Navigation | Feedback | Loading | Data display ]
WHY:             [ what real product need(s) it serves — must be ≥2, and not a variant of an existing component ]
PLATFORMS:       [ default: Jetpack Compose, Flutter, React Native, SwiftUI ]
```

## Rules

1. **Inspect first.** Read `docs/component-library/*` and the universal conventions (props, states, a11y baseline). Confirm the component does not already exist and is not a variant of one that does. If it is, say so and stop.
2. Use the **15-point template** for every component:
   1. Purpose · 2. Anatomy · 3. Variants · 4. Properties (a full API table: name · type · default · notes) · 5. States · 6. Interaction behavior · 7. Accessibility · 8. Motion · 9. Light theme · 10. Dark theme · 11. Responsive behavior · 12. Do · 13. Don't · 14. Example usage · 15. Developer implementation notes (Jetpack Compose / Flutter / React Native / SwiftUI).
3. **Universal states** for every interactive component: enabled, hover (pointer), focus-visible (2px `borderFocus` ring, 2px offset), pressed (12% overlay or 0.96 scale, 100ms), disabled (38%, not focusable), loading, error, selected/checked/expanded as applicable.
4. **Universal a11y baseline:** role exposed; name from a visible label or an explicit prop; state announced; ≥44×44dp target; keyboard / switch / D-pad operable; visible unobstructed focus; honors reduced-motion + Dynamic Type (200%); RTL mirrored.
5. **Tokens only** — reference semantic tokens (`primary`, `surface`, `space.4`, `radius.md`). No hard-coded hex/dp.
6. **Motion** uses AMDS tokens (100–400ms; `standard`/`decelerate`/`accelerate`/`spring`) and always has a reduced-motion equivalent.
7. **Platform mappings** must name the real base widget/component and key params (e.g. Compose `OutlinedTextField`, Flutter `TextFormField`, RN `TextInput` + `@gorhom/bottom-sheet`), not pseudocode.
8. Add the component to the category file, update `docs/component-library/README.md`'s index, and add it to the component → screen usage matrix.
9. Follow the [Definition of Done — component](../docs/governance.md#4-definition-of-done--component).

## Expected output

- Edits to the relevant `docs/component-library/*.md` file(s) with the full 15-point spec.
- Updated `README.md` index + usage matrix in `docs/component-library/`.
- A `CHANGELOG.md` entry (MINOR).
- A short summary: files modified / preserved, why the component is justified (the ≥2 needs), validation performed.

## Validation (the AI must run these)

- `node tool/validate.mjs` → 0 errors.
- Every one of the 15 points is present and non-trivial for each component.
- Every interactive state has a token-based visual spec.
- Contrast: text ≥4.5:1, UI/large ≥3:1, focus ring ≥3:1 — stated.
- Platform mappings name real APIs.
- No hard-coded values.

## Acceptance criteria (you check)

- [ ] `tool/validate.mjs` passes
- [ ] The component is justified (≥2 needs) and is not a duplicate/variant
- [ ] 15-point template complete for each component
- [ ] All universal states + a11y baseline covered
- [ ] Light + dark + responsive + reduced-motion + RTL + 200% text addressed
- [ ] Compose / Flutter / React Native / SwiftUI mappings with real APIs
- [ ] Tokens only; no hex/dp
- [ ] Index + usage matrix + CHANGELOG updated
- [ ] Terminology consistent with existing component docs

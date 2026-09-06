# Governance, Versioning & Contribution

> How the Alan Mobile Design System (AMDS) stays consistent and healthy as it powers many apps over many years.
> Extends [starter-template/scalability.md](starter-template/scalability.md).

---

## 1. Roles

| Role | Owns |
|---|---|
| **Core team** (2–3) | Foundations, tokens, review, releases, this repository |
| **Contributors** | Product designers / engineers proposing components, patterns, or changes |
| **Consumers** | Everyone building a product app on AMDS |

## 2. Versioning — Semantic Versioning

`MAJOR.MINOR.PATCH` applied to the whole system and to each published package.

| Bump | When | Requires |
|---|---|---|
| **PATCH** | Value tweaks, docs, bug fixes | Changelog entry |
| **MINOR** | New components, variants, tokens, screens, features — **backwards compatible** | Changelog entry, docs updated in the same change |
| **MAJOR** | Breaking token rename/removal, removed component variant, restructured API | A migration guide + a codemod where feasible; heavy communication |

- Token names and component APIs are **stable contracts**.
- The Figma library version and `design-tokens/tokens.json` `meta.version` stay in lockstep.
- The root `CHANGELOG.md` records every release (Keep a Changelog format).

## 3. Contribution workflow

1. **Propose** — open a request: problem, prior art in existing apps, proposed API, accessibility notes, which apps need it.
2. **Triage** — core team labels weekly: `accepted` · `needs-spike` · `use-existing` · `declined`.
3. **Design** — spec in Figma against the published library; peer review against the [component DoD](#4-definition-of-done--component).
4. **Build** — implement on all supported platforms, or mark `platform-partial` explicitly with a plan.
5. **Review** — design + code + accessibility review. Automated gates: contrast lint, token lint, visual regression, a11y guideline tests.
6. **Document** — the entry in [component-library](component-library/README.md) / [screen-library](screen-library/README.md) / [feature-library](feature-library/README.md) is part of "done".
7. **Release** — versioned, changelog entry, announced.

**Guardrails:** a new component must (a) not be a variant of something that exists, and (b) serve ≥2 real product needs. The review's first question is always "why isn't this an existing component?"

## 4. Definition of Done — component

- [ ] Purpose, variants, sizes, states documented (the 15-point template — see [component-library/README.md](component-library/README.md))
- [ ] All interactive states: default, hover, focus-visible, pressed, disabled, loading, error, selected
- [ ] Light + dark tokens
- [ ] Contrast verified (text ≥4.5:1, UI/large ≥3:1, focus ring ≥3:1)
- [ ] Touch target ≥44dp; ≥8dp to neighbors
- [ ] Screen reader: role + name + state + value announced (verified on TalkBack **and** VoiceOver)
- [ ] Keyboard / switch / D-pad operable; visible, unobstructed focus
- [ ] Reduced-motion variant
- [ ] RTL mirrored
- [ ] Dynamic Type to 200% without clipping
- [ ] Implemented + snapshot-tested on each supported platform (or `platform-partial` noted)
- [ ] Figma component published with matching props
- [ ] Do / Don't and example usage written

## 5. Definition of Done — screen / feature

See [screen-library/00-framework.md §6.5](screen-library/00-framework.md) and [feature-library/00-framework.md §4](feature-library/00-framework.md).

## 6. Deprecation policy

- A token, variant, or component is marked `deprecated` with a named replacement and a removal version.
- It keeps working for **at least two minor releases**.
- Every changelog lists active deprecations until they're removed.
- Removal is a MAJOR release and ships with a codemod or a migration guide.
- Never more than a handful of active deprecations at once.

## 7. Release cadence

| Type | Cadence |
|---|---|
| PATCH | As needed, low ceremony |
| MINOR | Monthly train; batched new components/screens/features |
| MAJOR | Annual at most; heavily communicated with a migration window |

## 8. Governance at scale

| Portfolio | Model |
|---|---|
| 1–3 apps | One core team owns everything; weekly office hours |
| 4–8 apps | Core team + a **federated contributor** per app who lands reviewed PRs; a biweekly guild |
| 8+ apps | Core team owns foundations/tokens/tooling; specialist squads own domain sub-systems (Charts, Maps, Scanning) conforming to AMDS contracts; formal RFC process (`docs/rfcs/`) |

- **RFCs** for cross-cutting changes (a new token category, a breaking change, a new pattern): written proposal, comment period, a decision record kept in the repo.
- **Adoption dashboard** — track per-app token/component/screen/engine usage; publish it (visibility drives adoption).
- **Quarterly audit** — detached Figma instances, unused local styles, off-token values, components not in the library, active deprecations past their window.

## 9. Git workflow

- Trunk-based or short-lived branches. Branch naming: `feat/…`, `fix/…`, `docs/…`, `chore/…`.
- PRs required; **green CI required to merge**; no direct pushes to `main`.
- One concern per PR; keep diffs small (< ~400 lines where possible); self-review first.
- Conventional-commit style messages recommended (`feat(component): add segmented control`).
- Every merge to `main` is releasable; releases are cut from `main` and tagged.
- Do **not** commit generated platform token files without the matching `tokens.json` change.

## 10. Contribution guidelines (quick)

- Follow the [code style](starter-template/code-style-and-guidelines.md).
- No hard-coded colors / dimensions / user-facing strings in examples or templates — use tokens and placeholders (`[APP_NAME]`, `[MODULE_NAME]`, …).
- Update the relevant `README.md` and any cross-references in the **same** PR.
- Add / update the changelog entry.
- If you change a pattern, update every doc that describes it (search for the term).

## 11. AI-assisted development workflow

This repository is designed to be driven by AI coding/design agents. See [`../prompts/`](../prompts/README.md).

1. Pick the prompt for the task (`mobile-design-system`, `screen-library-generator`, `component-library-generator`, `feature-template-library`, `mobile-app-starter-template`, `ux-audit`).
2. Paste it into your agent (Claude, Gemini, Antigravity, …) along with the specific inputs it asks for.
3. The agent must **inspect existing files before modifying**, preserve useful content, and follow the AMDS conventions in this repo.
4. Review the diff against the acceptance criteria in the prompt and the DoD checklists here.
5. Run the repository validation ([`../tool/validate.mjs`](../tool/validate.mjs)) before committing.

## 12. Support

- **Docs:** this repository, `/docs`.
- **Figma:** `AMDS — Master Library` (see [design-system/figma-structure.md](design-system/figma-structure.md)).
- **Requests / bugs:** the design-system issue tracker.
- **Changelog:** `/CHANGELOG.md`.

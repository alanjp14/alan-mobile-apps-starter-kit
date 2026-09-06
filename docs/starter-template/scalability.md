# Future Scalability

> Part of the [starter template](README.md) and [governance](../governance.md). How AMDS stays healthy and useful for 5–10 years across a growing portfolio of apps, platforms, and teams.

---

## 1. Architectural bets that age well

| Bet | Why it lasts | What to avoid |
|---|---|---|
| **Token source of truth in W3C DTCG JSON** | Vendor-neutral, tool-agnostic, machine-readable; survives Figma/Style Dictionary churn | Tokens living only inside Figma or only inside one platform's code |
| **Three-tier tokens** (primitive → semantic → component) | Rebrand or theme changes touch one layer; components never reference raw values | Components importing primitives or hex |
| **Semantic naming by intent** (`primary`, `danger`, `surfaceVariant`) | Meaning is stable even when values change | Names like `green`, `blue600`, `card-shadow-2` |
| **Feature-first app architecture** | New domains slot in without touching others | Layer-first (`screens/`, `models/`) that grows into spaghetti |
| **Adaptive, not per-device, layouts** | New form factors (foldables, larger phones, car, XR) fit the breakpoint model | Hardcoded phone dimensions, pixel layouts |
| **Accessibility as a gate** | Regulation only tightens; retrofitting is 10× the cost | "A11y pass later" |
| **Additive change + deprecation windows** | Consumers upgrade on their schedule | Breaking renames shipped silently |

---

## 2. Extending the system

### 2.1 Adding a component

Follow [governance](../governance.md) §5.2 + the checklist in [component library](../component-library/README.md) §G. Guardrails:

- Prove it's not a variant of something that exists (the review's first question).
- It must work for ≥2 real product needs, not 1.
- Ship on all supported platforms or mark `platform-partial` explicitly with a plan.
- The doc page and Figma component are part of "done".

### 2.2 Adding a theme (new brand / white-label / sub-brand)

The system is built for this:

1. Add a new mode to the `theme` variable collection (e.g. `Light`, `Dark`, `AcmeLight`, `AcmeDark`), or a new token file `tokens.acme.json` that only overrides **semantic + component** tokens.
2. Regenerate platform themes; each app picks a brand at build time or runtime.
3. Components don't change — only the token values they resolve.
4. Verify contrast for every new theme (CI lint runs per theme).

Keep primitives shared where possible; a new brand usually needs a new brand ramp + a few semantic remaps, not a new spacing/radius/type scale.

### 2.3 Adding a platform target

- Add a Style Dictionary platform config → new generated theme file.
- Build the component library for that platform against the same API contract ([developer handoff](../starter-template/developer-handoff.md) §3).
- Same docs, same Figma; only the integration section ([developer handoff](../starter-template/developer-handoff.md) §2) grows.
- Candidates over the next decade: Compose Multiplatform (could collapse Android+iOS+desktop), Kotlin Multiplatform for shared logic, wearOS/watchOS companions, Android Auto/CarPlay, web components for admin surfaces.

### 2.4 Density & modularity

- Ship `comfortable` (default) and `compact` density as a token set + a runtime switch; heavy data apps (ERP, NOC) default to `compact`.
- Package the library so apps can tree-shake unused components (per-component imports, no giant barrel file).

---

## 3. Governance at scale

| Portfolio size | Model |
|---|---|
| 1–3 apps | One core team owns everything; weekly office hours |
| 4–8 apps | Core team + a **federated contributor** per app (they land component PRs with review); a design-system guild meeting biweekly |
| 8+ apps | Core team owns foundations/tokens/tooling; **domain sub-systems** (e.g. "Charts", "Maps", "Scanning") owned by specialist squads but conforming to AMDS contracts; formal RFC process |

- **RFCs** for anything cross-cutting (a new token category, a breaking change, a new pattern): written proposal, comment period, decision record kept in `docs/rfcs/`.
- **Contribution SLAs:** triage within 1 week, review within 2.
- **Adoption dashboard:** track per-app token/component adoption ([governance](../governance.md) §6) and publish it — visibility drives adoption.
- **Deprecation discipline:** never more than a handful of active deprecations; remove on schedule.

---

## 4. Tooling & automation roadmap

**Now (v1):**
- Style Dictionary build in CI
- Contrast lint on token pairs
- Visual regression snapshots per platform
- Automated a11y scanners in CI

**Next 12–24 months:**
- **Tokens Studio ↔ Git two-way sync** so designers commit token changes via a PR
- **Codemods** for every deprecation (auto-migrate consumer code on major bumps)
- **Component usage telemetry** (which components/variants are used where) feeding the adoption dashboard
- **Storybook / component explorer** per platform, deployed per PR (Chromatic-style review)
- **Lint rules** enforcing "no raw hex / no magic dp / must use AppIcons" in every repo
- **Design lint** in Figma (detached instances, off-token values) as a pre-publish check

**Longer term:**
- Contract tests that assert Figma component props == code component API
- Auto-generated first-pass screens from Figma frames (assistive, not authoritative)
- A single "AMDS CLI" to scaffold a new app, add a feature, or run the full compliance check

---

## 5. Performance & footprint over time

- **Budget per app:** cold start, first meaningful paint, scroll jank frames, APK/IPA size — tracked in CI, regressions block release.
- Keep the component library lean; audit dependencies yearly; drop anything unused.
- Icon strategy: prefer the variable font or an on-demand SVG set over shipping thousands of vectors.
- Illustrations/Lottie: lazy-load, cap file size, provide static fallbacks.
- Revisit min-SDK / min-iOS every year; drop versions below ~2% usage to unlock APIs and shed compat code.

---

## 6. Risk register

| Risk | Mitigation |
|---|---|
| **Figma lock-in** | Tokens in open DTCG JSON; docs in Markdown in Git; components re-buildable from specs |
| **Core team bus factor** | Everything documented in this repo; federated contributors; recorded decision log |
| **Fragmentation** (apps forking components) | Adoption dashboard + easy contribution path + "no local styles" lint + office hours |
| **Token sprawl** | Quarterly audit; every token must map to a documented purpose; kill unused |
| **Accessibility regression** | CI gates + per-release manual audit + a11y in definition-of-done |
| **Platform divergence** (a variant only on Android) | `platform-partial` label is visible; parity tracked; contracts enforced |
| **Breaking OS changes** (new Material version, iOS redesign) | Semantic tokens + wrapper components absorb the shock; plan a MAJOR with a migration guide |
| **Brand refresh** | Three-tier tokens make it a values change, not a rebuild; theme-mode mechanism already exists |
| **Team turnover / new hires** | This template is the onboarding path; `Starter` Figma + scaffold CLI get someone productive in a day |

---

## 7. 10-year north star

- **One system, many brands, every [COMPANY_NAME] platform** — a designer or engineer moves between HRIS, K3, and CRM apps and everything feels the same.
- **Change once, ship everywhere** — a token or component fix propagates to every app on their next dependency bump, with codemods for the breaking ones.
- **Accessible and localized by default** — no app ships without meeting the bar because the bar is built into the tools.
- **Contribution is normal** — product teams improve the system as a side effect of building features, and the core team's job is curation and tooling, not gatekeeping.
- **The documentation is the product** — this `/docs` folder stays current because updating it is part of every change's definition of done.

---

## 8. Immediate next steps (post v1.0)

1. Wire the Style Dictionary build + CI (contrast lint, token build artifact).
2. Stand up the Figma libraries per [Figma structure](../design-system/figma-structure.md); sync variables with `tokens.json` via Tokens Studio.
3. Build the component library for the two primary platforms first (pick based on the next app's stack).
4. Scaffold the next product app from this template at Stage 3 ([governance](../governance.md) §6).
5. Set up the adoption dashboard and the RFC folder.
6. Schedule the first quarterly audit for 3 months out.
7. Publish v1.0, announce, run the first office hours.

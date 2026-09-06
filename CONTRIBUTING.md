# Contributing to AMDS

Thanks for improving the Alan Mobile Design System. This file is the short version — the full process, roles, versioning, and Definition-of-Done checklists live in **[`docs/governance.md`](docs/governance.md)**.

## Before you start

1. Read the relevant `docs/` section for what you're changing.
2. Open a **Proposal** issue first for anything new (component, screen, pattern, feature). The first review question is always *"why isn't this an existing piece?"* — a new addition must serve **≥2 real product needs**.
3. AI-assisted? Use a prompt from [`prompts/`](prompts/README.md). The agent must **inspect existing files before modifying**, preserve useful content, and follow the conventions already in the repo.

## Rules (non-negotiable)

- **No hard-coded** colors, dimensions, or user-facing strings — semantic tokens + placeholders (`[APP_NAME]`, `[COMPANY_NAME]`, `[MODULE_NAME]`, `[FEATURE_NAME]`, `[ROLE_NAME]`, `[USER_NAME]`, `[DATA_NAME]`) only.
- **Reusable, never business-specific.** This is a template, not an app.
- **Light + dark + responsive + accessibility (WCAG 2.2 AA) + reduced-motion** are part of the same change, not follow-ups.
- **All states** where relevant: Loading · Empty · Success · Error · Offline · No-permission.
- **Cross-platform** notes: Jetpack Compose · Flutter · React Native (· SwiftUI where useful) — never one-platform bias.
- Update **every** cross-reference when you change a term (search the repo). Add a `CHANGELOG.md` entry.

## Workflow

```bash
git switch -c feat/short-description        # feat/ | fix/ | docs/ | chore/
# ...make the change...
npm run validate                            # must pass with 0 errors
git commit -m "feat(component): add segmented control"
git push -u origin feat/short-description
# open a PR against main — fill the checklist
```

- Green CI is required to merge. No direct pushes to `main`.
- Keep PRs small (< ~400 lines diff), one concern.
- Every merge to `main` is releasable; releases are tagged (`vMAJOR.MINOR.PATCH`) and recorded in `CHANGELOG.md`.

## Validation

```bash
npm run validate     # JSON syntax · broken relative links · empty files · duplicate names · stale refs · placeholder mistakes
```

## Versioning

SemVer. **MAJOR** = breaking token/API change (+ migration guide) · **MINOR** = new pieces, backwards-compatible · **PATCH** = tweaks/docs. See [`docs/governance.md §2`](docs/governance.md).

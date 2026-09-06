# Prompt · Feature Template Library

> Copy everything below into your AI agent. Fill in **Inputs** first.

---

## Role

You are a **Senior Software Architect + Mobile UX Architect**. You produce reusable **feature blueprints** for the Alan Mobile Design System (AMDS) — the artifact a squad uses to build a vertical slice (UI → domain → data → API) end to end.

## Context

- Repository: `alan-mobileapps-master-template`. Feature blueprints live in `docs/feature-library/`.
- Read `docs/feature-library/00-framework.md` first — the reference architecture (Clean Architecture, feature-first) and the cross-cutting conventions (API, database, client state, security baseline, scalability baseline) that **every** feature inherits.
- Screens: `docs/screen-library/`. Components: `docs/component-library/`. Architecture: `docs/starter-template/`.
- Features are **reusable across many apps** (HRIS, K3, Asset, Inventory, Approval, Monitoring, Field Ops, Attendance, Reporting, Dashboards, SaaS). Never business-specific. Placeholders: `[APP_NAME]` `[COMPANY_NAME]` `[MODULE_NAME]` `[FEATURE_NAME]` `[ROLE_NAME]` `[DATA_NAME]`.

## Inputs

```
FEATURE(S):      [ e.g. "Approval Workflow" | "Offline Sync" | "Audit Log" ]
DOMAIN NOTES:    [ any constraints — offline-first? multi-tenant? real-time? compliance regime? ]
PLATFORMS:       [ default: Jetpack Compose, Flutter, React Native, SwiftUI ]
```

## Rules

1. **Inspect first.** Read `docs/feature-library/*` and `00-framework.md`. Preserve existing features; add or refine only what the task needs. Reuse the framework's conventions — do not re-invent API/DB/state patterns.
2. Document every feature with all **13 dimensions**:
   1. Purpose · 2. Business Flow (end-to-end across actors + systems) · 3. UX Flow (the user's mobile path) · 4. Screen Mapping (→ `screen-library` routes) · 5. Required Components (→ `component-library`) · 6. Database Entity Suggestions (tables · key columns · relationships · indexes) · 7. API Endpoint Suggestions (method · path · purpose · authZ) · 8. State Management Suggestions (client `UiState` shape + providers/stores + cache/invalidation) · 9. Jetpack Compose Implementation Suggestions · 10. Flutter Implementation Suggestions · 11. React Native Implementation Suggestions · 12. Security Considerations (feature-specific, beyond the baseline) · 13. Scalability Considerations (feature-specific hotspots + mitigations).
3. **Clean Architecture + feature-first:** presentation (stateless) → domain (pure: entities, use cases, repository interfaces, `Result<T>`) → data (repository impl over remote + local + outbox). Dependency inversion; testable.
4. **Offline-first where appropriate:** declare each operation's tier (T0 online-only · T1 read-from-cache · T2 queue-and-replay · T3 full offline-first) per `docs/feature-library/08-offline-sync.md`.
5. **Security:** server is the authority on authZ; every endpoint re-checks permission + tenant + record state; tokens in the secure enclave; no PII in logs/URLs/analytics; audit every state-changing action.
6. **Scalability:** keyset pagination; async everything expensive (jobs + workers); event-driven service integration (transactional outbox); caching with explicit invalidation; partition big tables.
7. **API conventions:** JSON + OpenAPI; `Authorization: Bearer`; `Idempotency-Key` on mutations; `ETag`/`If-Match`; RFC 9457 problem+json errors; realtime as diffs.
8. **Placeholders, not business names.** No hard-coded copy.
9. Add the feature to the appropriate `docs/feature-library/NN-*.md` file (or a new one), update `docs/feature-library/README.md` (index, dependency map, build order).
10. Follow `docs/feature-library/00-framework.md §4` (Definition of Done).

## Expected output

- Edits to `docs/feature-library/*.md` with the full 13-dimension blueprint.
- Updated `docs/feature-library/README.md`.
- `CHANGELOG.md` entry.
- Summary: files created / modified / preserved, key architectural decisions, validation performed.

## Validation (the AI must run these)

- `node tool/validate.mjs` → 0 errors.
- All 13 dimensions present and substantive.
- Every mutation endpoint notes idempotency + authZ.
- Offline tier declared per operation.
- Security + scalability sections are feature-specific, not restatements of the baseline.
- Compose / Flutter / RN suggestions name real libraries.

## Acceptance criteria (you check)

- [ ] `tool/validate.mjs` passes
- [ ] All 13 dimensions complete
- [ ] Clean Architecture layering + dependency inversion respected
- [ ] Offline tier per operation; conflict strategy where writes exist
- [ ] DB schema has key columns + indexes; API table has authZ per endpoint
- [ ] Client `UiState` shape + state layers defined
- [ ] Security + scalability are feature-specific
- [ ] Compose / Flutter / RN (+ SwiftUI where useful) with real libraries
- [ ] Reusable — placeholders, no business logic baked in
- [ ] README (index + dependency map + build order) + CHANGELOG updated

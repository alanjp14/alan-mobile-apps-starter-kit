# Mobile Feature Template Library

> Foundation: **Alan Mobile Design System (AMDS) v1.0**
> Enterprise-grade, reusable **feature-level blueprints** — the artifact you hand a squad to build a vertical slice end-to-end.

Companion to:
- [screen library](../screen-library/README.md) — UI/UX per screen (8 archetypes, 40 templates)
- [component API reference](../component-library/api-reference.md) — 18 component groups with Compose/Flutter/RN mappings
- [Flutter starter kit spec](../specs/flutter-starter-kit.md) — the reference implementation architecture

## How to use

1. Read [`00-framework.md`](00-framework.md) — the reference architecture and the cross-cutting conventions (API, database, client state, security baseline, scalability baseline) that **every** feature inherits.
2. Open the feature you're building; it documents only its **deltas + specifics**.
3. Each feature provides all 13 dimensions:

| # | Dimension |
|---|---|
| 1 | Purpose |
| 2 | Business Flow |
| 3 | UX Flow |
| 4 | Screen Mapping (→ screen library) |
| 5 | Required Components (→ component API reference) |
| 6 | Database Entity Suggestions (tables, columns, indexes) |
| 7 | API Endpoint Suggestions (method · path · purpose · authZ) |
| 8 | State Management Suggestions (client `UiState` + providers/stores) |
| 9 | Jetpack Compose Implementation Suggestions |
| 10 | Flutter Implementation Suggestions |
| 11 | React Native Implementation Suggestions |
| 12 | Security Considerations |
| 13 | Scalability Considerations |

## Feature index

| File | Features | Notes |
|---|---|---|
| [`00-framework.md`](00-framework.md) | — | Architecture · API/DB/state/security/scalability conventions · blueprint template · DoD |
| [`01-identity.md`](01-identity.md) | **Authentication · User Management · Role Management** | sessions, MFA, RBAC/ABAC, provisioning, least-privilege |
| [`02-workflow.md`](02-workflow.md) | **Approval Workflow** | config-driven routing engine, SLA, delegation, decision audit |
| [`03-notifications.md`](03-notifications.md) | **Notification Center · Push Notifications** | in-app inbox + FCM/APNs, fan-out, tokens, deep-link routing |
| [`04-analytics.md`](04-analytics.md) | **Dashboard Analytics · Reports** | rollups, BFF assembly, warehouse, parameterized reports, exports, schedules |
| [`05-data-tools.md`](05-data-tools.md) | **Search & Filter · File Upload** | search index + ACL, saved views; direct-to-storage resumable uploads, scanning |
| [`06-account.md`](06-account.md) | **Settings · Profile** | local vs synced prefs, theme/consent, self-service identity |
| [`07-observability.md`](07-observability.md) | **Audit Logs · Activity Timeline** | tamper-evident hash-chained audit vs friendly per-entity feed |
| [`08-offline-sync.md`](08-offline-sync.md) | **Offline Sync** | capability tiers T0–T3, outbox, delta pull, conflict strategies, encryption |
| [`09-platform.md`](09-platform.md) | **Deep Linking · Session Management** | typed routes, App/Universal Links, back-stack synthesis; token lifecycle, app-lock, step-up, multi-device |

## Cross-feature dependency map

```
Authentication ──┬── every feature (session + permissions)
Role Management ──┘

Approval Workflow ──► Notification Center ──► Push Notifications
Dashboard Analytics ◄── (events from all domain features)
Reports ──► File Upload (export delivery) ──► Search & Filter (catalog)
Audit Logs ◄── every state-changing action (transactional outbox)
Activity Timeline ◄── same event stream (friendly projection)
Offline Sync ──► wraps every feature's read/write (each declares a tier)
Settings / Profile ──► Authentication (security actions), Notifications (prefs)
```

## Build order (greenfield)

1. **Authentication** + **Role Management** (nothing works without identity + authZ)
2. **Offline Sync** framework decisions (pick tiers; it shapes every repository)
3. **Audit Logs** (transactional outbop wiring — retrofitting is painful)
4. One domain vertical: **Data Management** screens + **Search & Filter** + **File Upload**
5. **Approval Workflow** (if the domain needs it)
6. **Notification Center** + **Push Notifications**
7. **Dashboard Analytics** + **Activity Timeline**
8. **Reports**
9. **Settings** + **Profile** polish

Each feature's **Definition of Done** is in [`00-framework.md`](00-framework.md) §4.

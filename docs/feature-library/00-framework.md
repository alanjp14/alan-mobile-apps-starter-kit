# Feature Template Library · 00 · Framework

> Foundation: **AMDS v1.0**. Companion to the [screen library](../screen-library/README.md) (UI/UX per screen) and the [component API reference](../component-library/api-reference.md) (widgets).
> This library provides **feature-level blueprints**: business flow, data model, API surface, client state, cross-platform implementation, security, and scalability — the artifact you hand to a squad to build a slice end-to-end.

Features covered (files `01`–`08`):

| File | Features |
|---|---|
| [`01-identity.md`](01-identity.md) | Authentication · User Management · Role Management |
| [`02-workflow.md`](02-workflow.md) | Approval Workflow |
| [`03-notifications.md`](03-notifications.md) | Notification Center · Push Notifications |
| [`04-analytics.md`](04-analytics.md) | Dashboard Analytics · Reports |
| [`05-data-tools.md`](05-data-tools.md) | Search & Filter · File Upload |
| [`06-account.md`](06-account.md) | Settings · Profile |
| [`07-observability.md`](07-observability.md) | Audit Logs · Activity Timeline |
| [`08-offline-sync.md`](08-offline-sync.md) | Offline Sync |

Each feature entry provides all 13 requested dimensions: **1** Purpose · **2** Business Flow · **3** UX Flow · **4** Screen Mapping · **5** Required Components · **6** Database Entity Suggestions · **7** API Endpoint Suggestions · **8** State Management Suggestions · **9** Jetpack Compose · **10** Flutter · **11** React Native · **12** Security Considerations · **13** Scalability Considerations. Shared conventions below are inherited; feature entries add deltas.

---

## 1. Reference architecture

```
┌────────────────────────── MOBILE CLIENT ──────────────────────────┐
│  Presentation   screens (stateless) ── controllers/VMs/hooks       │
│  Domain         use cases · entities · Result<T>/Failure           │
│  Data           repository (interface) ── { remote API · local DB · outbox } │
│  Platform       secure storage · push · connectivity · files · biometrics │
└───────────────────────────────┬───────────────────────────────────┘
                                │ HTTPS / JSON (OpenAPI) · WebSocket/SSE (realtime)
┌───────────────────────────────▼───────────────────────────────────┐
│  BFF / API gateway   authN (JWT) · authZ (RBAC/ABAC) · rate limit  │
│  Services            identity · workflow · notifications · reporting · files · audit │
│  Stores              Postgres (OLTP) · object storage (files) · search index · warehouse (analytics) · event bus │
└───────────────────────────────────────────────────────────────────┘
```

- **Feature-first** app modules (project-structure). Each feature = `presentation / domain / data` folders + its routes + its tests.
- **Repository pattern** everywhere; every method returns `Future<Result<T>>`; mock impls ship by default so the app runs before the backend.
- **BFF** aggregates and shapes for mobile (partial responses, screen-scoped payloads); never expose raw microservices to the client.
- **One identity, many features**: features never re-implement auth; they consume the session + permissions.

## 2. Cross-cutting conventions

### 2.1 API

- REST-ish + JSON; OpenAPI 3 as the contract; generated typed clients per platform.
- Auth: `Authorization: Bearer <access JWT>` (short-lived, 5–15 min) + refresh token (rotating, in secure storage). `401` → silent refresh → retry once → else re-auth.
- Errors: RFC 9457 `application/problem+json` — `{ type, title, status, detail, traceId, errors[] }`. `errors[]` for field validation. Client maps → `Failure` union.
- Idempotency: `Idempotency-Key: <uuid>` on all mutations (required for the offline outbox).
- Concurrency: `ETag` / `If-Match` on updates → `409` with the current resource on conflict.
- Pagination: **keyset/cursor** (`?limit=&cursor=`) returning `{ items, nextCursor }`. Offset only for admin tables that truly need "page 7".
- Filtering/sorting: `?filter[status]=open&filter[site]=EAST&sort=-updatedAt&q=pump`.
- Partial responses for mobile: `?fields=` or dedicated BFF endpoints (`GET /dashboard?period=&scope=`).
- Realtime: WebSocket or SSE channel per user; messages are **diffs/events**, not full snapshots; client reconciles keyed collections.
- Versioning: `/v1`; additive changes only within a version; deprecations announced with a sunset header.
- Rate limiting: per-user + per-IP; `429` + `Retry-After`; client backs off with jitter.

### 2.2 Database

- Postgres (OLTP). UUID v7 primary keys (`id`). `created_at`, `updated_at` (UTC), `created_by`, `updated_by` on every table.
- **Soft delete**: `deleted_at` (nullable) + a `WHERE deleted_at IS NULL` default; hard-purge via a retention job.
- Multi-tenancy: `tenant_id` (or `org_id`) on every tenant-scoped table + row-level security (RLS) policies keyed to the request's tenant.
- Optimistic concurrency: `version int` bumped on update (maps to `ETag`).
- Auditing: an append-only `audit_event` table (see [`07-observability.md`](07-observability.md)) written in the same transaction as the change (transactional outbox → event bus).
- Money as `numeric`/minor-units `bigint` + `currency_code`; never floats.
- Indexes: every foreign key; composite indexes matching the common `filter + sort` combos; partial indexes for `deleted_at IS NULL`.
- PII columns tagged; encrypted at rest (column-level for the sensitive ones); access logged.

### 2.3 Client state (all platforms)

| Concern | Pattern |
|---|---|
| Server cache | a query-cache layer (React Query / a repository with `staleTime` / Store) — `staleTime` 30–60s, `cacheTime` per feature; optimistic `onMutate` + rollback |
| Screen state | one controller/VM/hook per screen exposing an immutable `UiState` (`Loading \| Data(T, stale?) \| Empty(reason) \| Error(retryable, traceId)`) |
| Session | a global `SessionController` — `{ status, user, permissions[], tenantId }`; drives router guards |
| Feature flags | one `FeatureFlags` provider; flags `feature.<area>.<name>` |
| Connectivity | a `Connectivity` provider → drives the offline banner + outbox |
| Forms | the schema-driven form engine (docs/screen-library §4.E) |
| Navigation | typed routes per feature, aggregated centrally; deep links + synthesized back stacks (navigation-patterns §9) |

Platform choices: **Compose** = ViewModel + `StateFlow` + Hilt + a Store/Room cache. **Flutter** = Riverpod 2 (`@riverpod` AsyncNotifier) + dio + a repo cache. **React Native** = Zustand/Redux-Toolkit for client state + **React Query** for server state.

### 2.4 Security baseline (every feature)

- TLS 1.2+ only; **certificate pinning** for the API host (with a backup pin + a remote kill-switch).
- Tokens in the OS secure enclave (`flutter_secure_storage` / Keychain / EncryptedSharedPreferences); never in plain prefs, logs, or analytics.
- Biometric gate for app unlock + sensitive actions (step-up).
- **Server is the authority** on authZ — the client hides/disables UI for UX only; every endpoint re-checks permission + tenant + record state.
- Least-privilege: endpoints scoped to the caller's roles; field-level redaction for PII the caller shouldn't see.
- Input validation on both sides; output encoding; parameterized queries; no string-built SQL.
- No sensitive data in URLs, query strings, deep links, logs, crash reports, or analytics.
- `FLAG_SECURE` / screenshot-blur for sensitive screens; hide content in the app switcher.
- Rate-limit auth + OTP + export + search; lockout + backoff.
- Supply chain: pinned dependency versions, SCA scanning, SBOM.
- Privacy: data-minimization, explicit consent for diagnostics/analytics, regional data residency, right-to-erasure honored via soft-delete → purge.

### 2.5 Scalability baseline (every feature)

- Stateless services behind a load balancer; horizontal scale; sticky only for WebSocket (or use a shared pub/sub).
- Read/write split: primary for writes, replicas for reads; the BFF prefers replicas.
- Caching layers: CDN for static + report exports; Redis for hot reads (permissions, feature flags, dashboards) with short TTLs + explicit invalidation on write.
- Async everything expensive: reports, exports, notifications, audit fan-out → a job queue + workers; the client polls or gets pushed.
- Event-driven integration between services (outbox → Kafka/SNS) — no synchronous service-to-service chains on the request path.
- Pagination + projection everywhere; never return unbounded lists; cap `limit`.
- Partition/shard the big tables by `tenant_id` and/or time (audit, notifications, activity) once volume warrants; archive cold data.
- Mobile: keyset pagination, response compression (gzip/brotli), image/thumbnail variants, `ETag`/`If-None-Match` for cheap revalidation, batch endpoints for N+1 avoidance, a BFF to keep payloads small.
- Observability: structured logs with `traceId`, RED/USE metrics per endpoint, distributed tracing, SLOs + alerting.

### 2.6 Screen & component references

Screen Mapping cites [`../screen-library/`](../screen-library/README.md); Required Components cite [`../16-component-api-reference.md`](../component-library/api-reference.md) §N.

---

## 3. Feature blueprint template (for adding a new feature)

```
## Feature: <name>
1. Purpose            — one paragraph: what business capability, for whom
2. Business Flow      — the end-to-end process across actors & systems (numbered / diagram)
3. UX Flow            — the user's path on mobile (entry → steps → exits)
4. Screen Mapping     — which screen-library templates, with routes
5. Required Components — component-api-reference sections + any feature-specific composites
6. Database Entities  — tables, key columns, relationships, indexes
7. API Endpoints      — method · path · purpose · authZ · notes
8. State Management    — client UiState shape + providers/stores + cache/invalidations
9. Jetpack Compose     — modules, key composables, libs, gotchas
10. Flutter            — modules, key widgets, libs, gotchas
11. React Native       — modules, key components, libs, gotchas
12. Security           — feature-specific threats + controls (beyond §2.4)
13. Scalability        — feature-specific hotspots + mitigations (beyond §2.5)
```

---

## 4. Definition of done (per feature)

- [ ] All 13 dimensions documented; deltas from this framework are explicit
- [ ] OpenAPI contract published; typed clients generated for the target platform(s)
- [ ] Mock repository implemented → the feature runs end-to-end on mock data
- [ ] Screens built per the screen-library specs (all 5 states, light+dark, tablet, a11y, reduced-motion)
- [ ] AuthZ enforced server-side; client UI gating matches; tenant isolation tested
- [ ] Audit events emitted for every state-changing action
- [ ] Offline behavior defined (read cache / queue / block) and tested
- [ ] Idempotency keys on all mutations; 409 conflict handling implemented
- [ ] Analytics events defined and firing
- [ ] Load-tested to the target concurrency; p95 latency within SLO
- [ ] Security review passed (threat model, pen test for auth-adjacent features)
- [ ] Runbook + dashboards + alerts in place

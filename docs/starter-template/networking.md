# Networking & Repository Layer

> Part of the [starter template](README.md). Full platform table: [`blueprint.md §7, §8`](blueprint.md). API conventions: [`../feature-library/00-framework.md §2.1`](../feature-library/00-framework.md).

---

## 1. API layer (`core/network`)

```
core/network/
├── ApiClient                 base URL from AppConfig; JSON (kotlinx / freezed / zod); gzip
├── interceptors/
│   ├── AuthInterceptor        attach Bearer; on 401 -> single-flight refresh -> retry once -> else logout
│   ├── IdempotencyInterceptor add Idempotency-Key on POST/PATCH/DELETE (from the outbox op or a fresh uuid)
│   ├── EtagInterceptor        add If-Match from the entity's cached etag on writes
│   ├── LoggingInterceptor     structured, redacts Authorization/PII, includes traceId
│   ├── RetryInterceptor       5xx/timeout -> exp backoff + jitter, capped
│   └── ConnectivityInterceptor  fail fast when offline -> typed NetworkFailure
├── ErrorMapper               problem+json -> Failure union
├── CertPinning               pin the API host + a backup pin + a remote kill-switch
├── RealtimeClient            WebSocket/SSE -> Flow<DomainEvent> per channel; reconnect w/ backoff
└── generated/                typed clients from OpenAPI
```

### Conventions

- One **OpenAPI 3** contract; **generate** typed clients — no hand-written request builders.
- Auth: `Authorization: Bearer <access JWT>` (5–15 min) + a rotating refresh token in secure storage. `401` → silent refresh → retry once → else re-auth.
- Errors: **RFC 9457** `application/problem+json` → `{ type, title, status, detail, traceId, errors[] }` → mapped to the `Failure` union.
- Idempotency: `Idempotency-Key: <uuid>` on all mutations.
- Concurrency: `ETag` / `If-Match` on updates → `409` returns the current resource.
- Pagination: **keyset/cursor** (`?limit=&cursor=` → `{ items, nextCursor }`).
- Filtering/sorting: `?filter[status]=open&sort=-updatedAt&q=...`.
- Partial responses for mobile: dedicated BFF endpoints (`GET /dashboard?period=&scope=`) returning partial-tolerant payloads.
- Realtime: messages are **diffs/events**, not full snapshots; the client reconciles keyed collections; fall back to polling on disconnect.
- Every remote call returns `Result<T>` — never throws to the caller.

## 2. Repository layer

```
domain/[module]_repository (interface)         // presentation depends on THIS
data/[module]_repository_impl:
  read(id | query):
    1. emit from LocalDataSource (cache) immediately  -> UiState.Data(stale = isStale(cachedAt))
    2. if online & stale -> RemoteDataSource.fetch -> map DTO->entity -> LocalDataSource.upsert -> re-emit
    3. on remote error -> keep cache, surface a non-blocking error
  mutate(create | update | delete | action):
    1. validate locally
    2. LocalDataSource.upsert(optimistic, dirty = true)
    3. Outbox.enqueue(op{ entity, base_etag, idempotency_key, depends_on })
    4. return Result.Success(optimistic)
  (SyncEngine on reconnect: drain outbox -> reconcile cache -> pull deltas)
```

- The repository is the **only** place that knows remote vs local; use cases and presentation see one interface.
- **Mock implementations ship for every repository** → the app runs end-to-end offline on mock data from day one.
- Reads return reactive streams (`Flow` / `Stream` / a query hook) so the UI updates when the cache changes.
- Each feature declares its **offline tier** per operation (T0–T3) — see [local-storage.md](local-storage.md).

## 3. Platform

| Concern | Compose | Flutter | React Native | SwiftUI |
|---|---|---|---|---|
| Client | Retrofit + OkHttp + `kotlinx.serialization` | `dio` + `retrofit`/`chopper` | `axios` + `zod` at the boundary | `URLSession` + `Codable` |
| Codegen | `openapi-generator` (kotlin) | `openapi-generator` / `retrofit_generator` | `openapi-typescript` + `openapi-fetch` | `openapi-generator` (swift) |
| Interceptors | OkHttp `Interceptor` + `Authenticator` (Mutex for single-flight) | `dio` `Interceptor` + `Lock`/`Completer` | axios interceptors + a refresh queue | `URLProtocol` / a session delegate |
| Cert pinning | OkHttp `CertificatePinner` | `dio` cert callback / native plugin | `react-native-ssl-pinning` | `URLSessionDelegate` `didReceive challenge` |
| Realtime | OkHttp WebSocket / `okhttp-sse` | `web_socket_channel` / SSE | `reconnecting-websocket` / `react-native-sse` | `URLSessionWebSocketTask` |
| SSOT read | `NetworkBoundResource` + Room `Flow` | a `syncedQuery` helper + Drift | `useSyncedList` wrapping `useQuery` + local observe | a Combine publisher over Core Data |

## 4. Do / Don't

**Do** — generate clients from OpenAPI; return `Result`; keyset pagination; `Idempotency-Key` + `If-Match` on mutations; realtime as diffs; DTOs stay in `data/`.
**Don't** — hand-build requests; throw to callers; offset pagination for large sets; silent overwrite on 409; leak DTOs into domain/presentation; put secrets or base URLs in the repo.

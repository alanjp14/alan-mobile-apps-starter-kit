# Feature Library · 08 · Offline Sync

> Foundation: AMDS v1.0 · Inherits [`00-framework.md`](00-framework.md). Feature: **Offline Sync**.

> This is a **cross-cutting platform capability**, not a screen. It defines how the app behaves without connectivity: what's readable from cache, what mutations queue, how they replay, and how conflicts resolve. Every other feature declares its offline policy against this framework. Critical for field apps (Mining K3, Asset, Inventory).

---

## Feature: Offline Sync

### 1. Purpose
Let users keep working when connectivity is absent or intermittent — read recently-accessed data from a local cache, create/edit records and take actions that queue durably and replay automatically on reconnect, with clear pending/failed/conflict states and deterministic conflict resolution — so a field worker in a tunnel or a warehouse dead-zone loses no work.

### 2. Offline capability tiers (each feature picks one per operation)

| Tier | Meaning | Examples |
|---|---|---|
| **T0 · Online-only** | The action needs immediate server coordination; block offline with a clear message | Login, MFA, approval decisions, role changes, payments, account deletion, "sign out other devices" |
| **T1 · Read-from-cache** | Show the last-synced data with an "as of HH:MM" marker; no writes | Dashboards, reports, colleague profiles, help articles, audit logs |
| **T2 · Queue-and-replay** | Create/edit/simple-actions are captured locally and applied on reconnect; optimistic UI with a "Pending" marker | Create incident/work-order, edit a record, add a comment, mark notification read, upload a file, check an asset in/out, cycle-count entries |
| **T3 · Full offline-first** | The feature is designed to run entirely offline for extended periods with background bidirectional sync and rich conflict handling | Field inspection app, offline inventory counts, a downloaded work-order pack for a shift |

Most enterprise apps are **T1 + T2**. T3 is opt-in per feature and per app.

### 3. Business / sync flow
```
ONLINE (normal):
  read  → network-first (or cache-first with revalidate) → update local cache
  write → send → on 2xx apply server response to cache → done
GOING OFFLINE (detected by Connectivity + failed requests):
  read  → serve from local cache, stamp "as of <lastSync>"; show offline Banner
  write → validate locally → apply optimistically to cache → append an OutboxOp (durable) → show "Pending" marker
RECONNECT:
  1. drain the Outbox in order (respecting dependencies), each op:
       - attach Idempotency-Key
       - PUT/PATCH with If-Match (etag captured when the op was created)
       - on 2xx → reconcile cache with the server response, clear the "Pending" marker
       - on 409 (conflict) → run the resolution strategy (§6)
       - on 4xx (validation/permission) → mark the op "Failed", surface it for user review, don't block the queue
       - on 5xx/timeout → keep the op, retry with exponential backoff + jitter
  2. pull deltas for the user's "working set" (changed since lastSync) → merge into cache
  3. update lastSync; clear the offline Banner
```

### 4. UX Flow
```
Connectivity lost → a persistent app-level Banner: "You're offline — showing data from 9:04 AM"
Reads: every list/detail shows an "as of HH:MM" chip; pull-to-refresh → "Can't refresh while offline"
Writes:
  create/edit/comment → succeeds optimistically → the item shows a "Pending sync" chip (clock icon)
  a T0 action → its control is disabled with "You must be online to {do this}"
  file upload → "Queued" state on the attachment
A small "Sync" status affordance (in the app bar overflow or a status bar): "3 changes pending" → tap → a Pending Changes screen
Reconnect → Banner: "Back online — syncing…" → "Synced" → chips clear
Conflict → the affected item gets a "Needs review" chip → tap → Conflict Resolution screen (mine / theirs / merge)
Failed op → "Couldn't sync — review" → the Pending Changes screen shows the error + Retry / Discard
```

### 5. Screen Mapping
| Surface | Route | Template |
|---|---|---|
| Offline Banner | app-level | Banner ([16 §12 / component-lib D6](../component-library/api-reference.md)) |
| Pending Changes | `/sync/pending` | Archetype C (list of `OutboxOp` with state + Retry/Discard) |
| Conflict Resolution | `/sync/conflicts/:opId` | Archetype D + F (side-by-side "Yours" / "Server" / field-level merge) |
| "as of HH:MM" chips | on every List/Detail | Chip |
| Sync status | app bar overflow / a status pill | Badge + Bottom Sheet |
| Download-for-offline (T3) | `/sync/downloads` | Archetype C (packs to keep offline) |

### 6. Conflict resolution strategies (declared per entity)

| Strategy | When to use | Behavior |
|---|---|---|
| **Last-write-wins (LWW)** | Low-stakes, single-owner fields (a personal note, a draft) | On 409, resend with the server's new `etag` (overwrite). Log it. |
| **Server-wins** | The server is authoritative (status set by workflow, computed fields) | Drop the local change for that field, keep the server value, notify the user ("Your change to Status was overridden — it's now Approved"). |
| **Field-level merge (auto)** | Different fields changed by each side | Merge non-overlapping field changes automatically; only truly overlapping fields need the user. |
| **Manual (user chooses)** | Overlapping changes to meaningful fields, or T3 rich records | Conflict Resolution screen: per conflicting field show "Yours" vs "Server", let the user pick or edit; then submit a merged version with the latest `etag`. |
| **Append-only (no conflict)** | Comments, activity, journal entries, count events | Each is a new immutable row keyed by a client-generated id; replay is a pure insert; no conflict possible. Prefer this modeling wherever you can. |
| **Reject-and-review** | The op is no longer valid (record deleted, permission lost, workflow moved on) | Mark "Failed", explain ("This work order was closed while you were offline"), offer to re-create / discard. |

### 7. Database / storage suggestions

**Client (local DB — Room / Drift / SQLite / WatermelonDB):**
| Table | Contents |
|---|---|
| `cache_<entity>` | the synced rows: `id, payload (json), etag, cached_at, dirty (bool), pending_op_id?` |
| `outbox_op` | `id (client uuid), created_at, entity_type, entity_id (client or server), op (create/update/delete/action:<name>), payload (json), base_etag, idempotency_key, depends_on (op id), state (pending/inflight/failed/conflict/done), attempts, next_attempt_at, error, conflict_snapshot (json)` |
| `sync_state` | `entity_type, last_sync_cursor, last_sync_at` per collection in the working set |
| `attachment_queue` | queued files (see File Upload feature) |
| `id_map` | `client_id ↔ server_id` (resolve references created offline) |

**Server (supports sync):**
| Requirement | Detail |
|---|---|
| `updated_at` / `version` / `etag` on every syncable entity | for `If-Match` + delta pulls |
| **Delta endpoint** per collection | `GET /v1/{entity}?updatedSince=<cursor>&scope=…&cursor=` → `{ items, deletes[], nextCursor }` |
| **Idempotency store** | `idempotency_key → (response, status, created_at)`, TTL ≥ a few days, so a replayed op returns the original result |
| **Tombstones** | soft-delete rows returned in `deletes[]` so clients can purge |
| Optional: a **sync cursor / change-feed** per user (CDC / outbox) for efficient deltas | |

### 8. API endpoint suggestions
| Method · Path | Purpose | Notes |
|---|---|---|
| `GET /v1/{entity}?updatedSince=<cursor>&scope=…&cursor=` | pull deltas for the working set | returns upserts + `deletes[]` + `nextCursor`; server caps page size |
| `GET /v1/sync/bootstrap?scopes=…` | first-run / re-sync: the initial working set in one batched call | BFF-assembled |
| Standard `POST/PATCH/DELETE /v1/{entity}/{id}` with `Idempotency-Key` + `If-Match` | replay target for outbox ops | `409` returns the current server resource in the body |
| `POST /v1/sync/batch` | (optional) submit multiple outbox ops in one round trip → per-op results | reduces chattiness on reconnect |
| `GET /v1/sync/manifest?scopes=` | (T3) what's available to download for offline + sizes | |
| `POST /v1/attachments` … `/complete` | file queue replay (File Upload feature) | |

### 9. State management suggestions
- A `SyncEngine` (app-scoped singleton, platform service):
  - watches `Connectivity`; on `online` → `drainOutbox()` then `pullDeltas()`.
  - `drainOutbox()` processes `outbox_op` in `created_at` order, honoring `depends_on`; single-flight; backoff on 5xx; routes 409 → `ConflictResolver`.
  - exposes `SyncStatus { state: idle|syncing|offline, pendingCount, failedCount, conflictCount, lastSyncAt }` as a stream → drives the Banner, the sync pill, and per-item chips.
- **Repositories are offline-aware**: `read()` = cache-first (+ revalidate when online); `mutate()` = validate → write to `cache_<entity>` (dirty) → enqueue an `outbox_op` → return optimistically. UI never calls the network directly.
- **Optimistic references**: creating B that references not-yet-synced A → B's `outbox_op` `depends_on` A's; `id_map` rewrites the reference after A syncs.
- **Per-item UI state** derived from `cache_row.pending_op_id` + the op's `state` → `Pending` / `Failed` / `Needs review` chips.
- `PendingChangesController` (Archetype C) lists `outbox_op`s with Retry / Discard / Edit; `ConflictController` drives the resolution screen.
- **T0 gating**: a `requiresOnline` guard on those actions reads `SyncStatus.state`.

### 10. Jetpack Compose implementation suggestions
- **Local DB**: Room (with `@Transaction` DAOs); the outbox is a Room table.
- **Sync engine**: `WorkManager` — a `CoroutineWorker` for `drainOutbox` + `pullDeltas`, constrained to `NetworkType.CONNECTED`, `setBackoffCriteria(EXPONENTIAL)`, a unique name; `ExpeditedWorkRequest` on reconnect; also trigger from a `ConnectivityManager.NetworkCallback`.
- **Repositories** return `Flow` from Room (single source of truth); network writes go through the worker.
- **Idempotency-Key**: generated when the op is enqueued, stored on the row, reused across retries.
- **Conflict UI**: a `NavGraph` destination reading the op's `conflict_snapshot`.
- Consider **`androidx.paging` `RemoteMediator`** for cache+network lists.

### 11. Flutter implementation suggestions
- **Local DB**: `drift` (typed, reactive queries, transactions) or `isar`; the outbox is a Drift table.
- **Sync engine**: a `SyncEngine` class + `connectivity_plus` listener; background execution via `workmanager` (Android) / BGTaskScheduler through `workmanager` or `background_fetch` (iOS); foreground drain on app resume + on reconnect.
- **Repositories**: expose `Stream` from Drift `watch()`; `mutate()` writes locally + inserts an `outbox_op`; Riverpod `StreamProvider`s rebuild the UI.
- `dio` interceptor adds `Idempotency-Key` + `If-Match` from the op; a `retry` interceptor for 5xx.
- `SyncStatus` as a `StreamProvider` → the offline `AmdsBanner` + sync pill.
- Packages that help: `flutter_data`, `brick`, or `powersync` / `realm` if you want a batteries-included offline-first stack for T3.

### 12. React Native implementation suggestions
- **Local DB**: WatermelonDB (built for sync, lazy, reactive) for T3; or `op-sqlite`/`react-native-mmkv` + a hand-rolled outbox for T1/T2; `expo-sqlite` for Expo.
- **Server cache**: React Query with `persistQueryClient` (MMKV persister) for read-from-cache; `onlineManager` wired to `@react-native-community/netinfo`; `mutationCache` with a **paused-mutations** pattern — `useMutation` with `retry` + `queryClient.resumePausedMutations()` on reconnect gives you a basic outbox for T2.
- For a durable, ordered, dependency-aware outbox (T2+), keep it in SQLite/WatermelonDB rather than relying only on React Query's paused mutations.
- **Sync engine**: a JS `SyncEngine` singleton + `NetInfo` listener + `expo-task-manager`/`react-native-background-fetch` for periodic background sync; `AppState` resume trigger.
- Idempotency + `If-Match` via an `axios` request interceptor reading the op.
- Turn-key options: **PowerSync**, **RxDB** + a replication plugin, or **Realm Sync** for full offline-first.

### 13. Security considerations
- **Encrypt the local cache** — the DB holds business data offline: SQLCipher (Room/`drift`), Realm encryption, WatermelonDB with an encrypted adapter, or at minimum store the DB key in the secure enclave and gate app access behind biometrics.
- **Scope the working set** — only cache what the user is authorized to see *and* actually needs (their sites, recent records, assigned work); never bulk-download a tenant. Re-check permissions on sync; if access was revoked while offline, purge those rows and fail their pending ops with an explanation.
- **Wipe on sign-out / deactivation / device loss** — clearing the session clears the cache, outbox, queued files, and `id_map`; support remote wipe (MDM) and a "sign out this device" that invalidates the refresh token so a stolen device can't sync.
- **Pending ops carry no credentials** — they replay through the normal authenticated client; if the session is dead on reconnect, re-auth first, then drain.
- **Idempotency + replay safety** — every op has a key; the server dedupes; a replayed "approve" or "delete" can't double-apply. Ops that became invalid (record deleted, workflow advanced) are rejected and surfaced, never force-applied.
- **T0 actions must be truly blocked offline** — approvals, role changes, payments route real-world consequences and can't be safely queued; the UI disables them and the engine refuses to enqueue them.
- **Conflict data exposure** — the `conflict_snapshot` may contain fields the user shouldn't see if permissions changed; re-filter on display.
- **Tamper resistance** — a rooted/jailbroken device can read the local DB; for high-security tenants, minimize offline retention, shorten the cache TTL, require online for sensitive reads, and consider disabling T2/T3 entirely by policy.
- **Clock** — never trust the device clock for `occurred_at`/ordering that matters; the server stamps authoritative times on replay; the client's `created_at` is advisory (for local ordering only).

### 13b. Data-integrity guarantees to design for
- **No lost writes**: an op is durably persisted *before* the optimistic UI update returns; process death mid-sync resumes from the outbox.
- **No duplicate effects**: idempotency keys + server dedup.
- **Deterministic ordering**: ops replay in creation order per entity; `depends_on` enforces cross-entity order.
- **Convergence**: after a full sync cycle with no new offline activity, client and server agree (verified by comparing `etag`s / a checksum endpoint in tests).
- **Bounded staleness**: reads always show `lastSync`; the UI never implies data is live when it isn't.

### 13c. Scalability considerations
- **Delta sync, not full sync** — `updatedSince` cursors + tombstones keep reconnect payloads small; the server serves deltas from a change-feed/CDC or an `updated_at` index, not a full-table scan.
- **Working-set scoping** — cap what any device caches (by count, age, and scope); a field pack for a shift is explicitly downloaded and expires.
- **Batch on reconnect** — `POST /v1/sync/batch` and a single `bootstrap`/delta call reduce the reconnect storm when thousands of field devices come back online at shift end; stagger with jitter; the server rate-limits + queues.
- **Idempotency store** — TTL'd (Redis or a table partitioned by day); sized for the replay window, not forever.
- **Conflict rate** — model append-only wherever possible (comments, counts, journal, activity) so most "concurrent" work never conflicts; conflicts should be rare enough to handle with a screen, not a subsystem.
- **Server load shape** — offline sync converts a steady request stream into bursts; provision the sync endpoints + queue for the burst (shift boundaries), autoscale workers, and keep sync off the latency-critical interactive path.
- **Observability** — track per-device sync lag, outbox depth, failed-op rate, conflict rate, and reconnect-batch sizes; alert on rising failure/conflict rates (usually a schema or permission-model change).

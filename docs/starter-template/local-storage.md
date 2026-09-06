# Local Storage, Offline Sync & Caching

> Part of the [starter template](README.md). Full offline-sync feature (tiers, outbox, conflict strategies): [`../feature-library/08-offline-sync.md`](../feature-library/08-offline-sync.md). Platform table: [`blueprint.md §9`](blueprint.md).

---

## 1. Client database (`core/database`)

**Encrypted** (SQLCipher / Realm encryption / an encrypted adapter). The DB key is stored in the secure enclave; for high-security tenants, gate DB open behind biometrics.

| Table | Contents |
|---|---|
| `cache_[entity]` | the synced rows: `id, payload, etag, cached_at, dirty, pending_op_id?` |
| `outbox_op` | `id (client uuid), created_at, entity_type, entity_id, op, payload, base_etag, idempotency_key, depends_on, state (pending/inflight/failed/conflict/done), attempts, next_attempt_at, error, conflict_snapshot` |
| `sync_state` | `entity_type, last_sync_cursor, last_sync_at` per collection in the working set |
| `id_map` | `client_id ↔ server_id` (resolve references created offline) |
| `attachment_queue` | queued files (File Upload feature) |
| `kv` | small feature-scoped misc |
| `migrations/` | versioned, forward-only, **tested** up-migrations |

## 2. Storage tiers

| Data | Where |
|---|---|
| Auth tokens, DB key, biometric-bound secrets | **secure enclave** (`flutter_secure_storage` / Keychain / EncryptedSharedPreferences / `react-native-keychain`) |
| Theme, onboarding-seen, per-view prefs | key-value store (`shared_preferences` / DataStore / MMKV / `UserDefaults`) |
| Synced business data + the outbox | the encrypted DB above |
| Images, HTTP responses | an image/HTTP cache (evictable, not source of truth) |
| Queued upload files | the app's private sandbox, cleared after successful upload |

## 3. Offline capability tiers (each feature declares one per operation)

| Tier | Meaning | Examples |
|---|---|---|
| **T0 · Online-only** | needs immediate server coordination; block offline with a clear message | login, MFA, approval decisions, role changes, payments, account deletion |
| **T1 · Read-from-cache** | show last-synced data with an "as of HH:MM" marker; no writes | dashboards, reports, colleague profiles, help articles, audit logs |
| **T2 · Queue-and-replay** | create/edit/simple-actions captured locally, applied on reconnect; optimistic UI + "Pending" marker | create record, edit a record, add a comment, mark notification read, upload a file, check an asset in/out |
| **T3 · Full offline-first** | designed to run entirely offline for extended periods with bidirectional sync + rich conflict handling | field inspection app, offline inventory counts, a downloaded shift pack |

Most enterprise apps are **T1 + T2**. T3 is opt-in per feature and per app.

## 4. Sync flow

```
ONLINE:   read  -> cache-first + revalidate;  write -> send -> apply server response to cache
OFFLINE:  read  -> serve cache, stamp "as of <lastSync>", show offline banner
          write -> validate locally -> optimistic cache write -> append OutboxOp -> "Pending" marker
RECONNECT: 1. drain the Outbox in order (honoring depends_on), each op:
              - attach Idempotency-Key + If-Match (base_etag)
              - 2xx  -> reconcile cache, clear "Pending"
              - 409  -> run the conflict strategy (LWW / server-wins / field-merge / manual / append-only / reject)
              - 4xx  -> mark "Failed", surface for review, don't block the queue
              - 5xx  -> keep, retry with exponential backoff + jitter
           2. pull deltas for the working set (updatedSince cursor) -> merge
           3. update lastSync; clear the offline banner
```

## 5. Server support for sync

- `updated_at` / `version` / `etag` on every syncable entity.
- A **delta endpoint** per collection: `GET /v1/[entity]?updatedSince=<cursor>` → `{ items, deletes[], nextCursor }`.
- An **idempotency store** (`idempotency_key → response`, TTL ≥ a few days) so a replayed op returns the original result.
- **Tombstones** for deletes so clients can purge.

## 6. Caching rules

- Cache only the **authorized working set** (the user's sites, recent/assigned records) — never bulk-download a tenant; evict by count + age.
- Re-check permissions on sync; if access was revoked while offline, purge those rows and fail their pending ops with an explanation.
- **Wipe completely** on sign-out / account switch / deactivation / remote wipe.
- Migrations are versioned, forward-only, covered by a test (open an old DB, migrate, assert).

## 7. Platform

| | Compose | Flutter | React Native |
|---|---|---|---|
| DB | Room + SQLCipher | Drift + `sqlcipher_flutter_libs`, or Isar | WatermelonDB (sync-native) or `op-sqlite` + SQLCipher |
| Sync engine | `WorkManager` `CoroutineWorker` + `ConnectivityManager.NetworkCallback` | a `SyncEngine` + `connectivity_plus`; `workmanager` for background | a JS `SyncEngine` + `@react-native-community/netinfo` + `expo-task-manager` |
| Turnkey T3 | — | `powersync` / `realm` | PowerSync / RxDB / Realm Sync |
| Reactive reads | Room `Flow` | Drift `watch()` | WatermelonDB `observe()` / TanStack Query |

## 8. Do / Don't

**Do** — encrypt the cache; scope the working set; persist the outbox before the optimistic UI returns; idempotency keys + server dedup; deterministic replay order; always show `lastSync`; wipe on sign-out.
**Don't** — bulk-download a tenant; queue T0 actions offline; trust the device clock for ordering that matters; leave the cache unencrypted for sensitive features; skip migration tests.

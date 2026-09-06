# State Management

> Part of the [starter template](README.md). Full platform table: [`blueprint.md §6`](blueprint.md). Framework conventions: [`../feature-library/00-framework.md §2.3`](../feature-library/00-framework.md).

---

## 1. The `UiState` contract (every data screen)

```
sealed UiState<T> {
  Loading(previous: T?)          // show a skeleton, or keep previous + shimmer
  Data(value: T, stale: Bool)    // stale -> "as of HH:MM" marker
  Empty(reason: FirstRun | NoResults | NoPermission)
  Error(failure: Failure, retryable: Bool)
}
// Dashboards compose per-block: DashboardUiState { blocks: { kpis: BlockState<...>, ... } }
```

Screens are **stateless**: read one state object, call intent methods. No `setState` for anything non-trivial. No `BuildContext`/`Context` in controllers. Side effects (snackbars, nav on auth loss) go through a one-shot event channel, not state flags.

## 2. Layers of state

| Layer | Scope | Holder |
|---|---|---|
| **Server cache** | app | a query cache (TanStack Query) or a repository + reactive DB (single source of truth); `staleTime` 30–60s; optimistic `onMutate` + rollback |
| **Screen state** | one screen | a ViewModel / Notifier / hook → exposes one `UiState` + intent methods |
| **Session** | app | `SessionManager` → `{ status, user, permissions, tenantId, pendingDeepLink }` |
| **Theme** | app | `ThemeController` (device-local: `mode`, `textScale` 0.85–2.0, `density`, `boldText`, `highContrast`, `brandId?`) |
| **Sync** | app | `SyncEngine` → `SyncStatus { state, pendingCount, failedCount, conflictCount, lastSyncAt }` |
| **Feature flags / config** | app | `AppConfig` + `FeatureFlags` (`feature.<area>.<name>`) |
| **Connectivity** | app | `Connectivity` provider |
| **Ephemeral UI** | one widget | local (`remember` / `useState` / `setState`) — a toggle, an animation, an unsent draft only |

## 3. Caching

- **Reads** are cache-first: emit from the local cache immediately (`Data(stale=...)`), then revalidate over the network when online and stale, then re-emit.
- `staleTime` per feature (30–60s typical); a longer `cacheTime`.
- Invalidate on the matching mutation (targeted, not global): a `[resource]` mutation invalidates the `[resource]` list + that record.
- Cache the last successful dashboard/report result per filter combo (encrypted) for instant back-navigation and offline.
- Prefetch a detail from the list row's data for an instant header paint, then hydrate.

## 4. Mutations

- Always optimistic + rollback.
- Every mutation carries an `Idempotency-Key` (also needed by the offline outbox).
- On `409` → conflict resolution UI, never a silent overwrite.
- Offline → write locally + enqueue an outbox op; return the optimistic value; the `SyncEngine` drains on reconnect.

## 5. Platform

| | Compose | Flutter | React Native |
|---|---|---|---|
| Screen state | `ViewModel` + `StateFlow<UiState>` + `collectAsStateWithLifecycle()` | Riverpod `@riverpod` `AsyncNotifier` → `AsyncValue<UiState>` | a `useXxx` hook: Zustand slice + TanStack Query |
| Server cache | Repository + Room `Flow` (SSOT) | Repository + Drift `watch()` | **TanStack Query** (`useQuery`/`useMutation`, `persistQueryClient`) |
| DI | Hilt (`@HiltViewModel`) | Riverpod providers + `riverpod_generator` | Context providers + service locator |
| One-shot events | `Channel` → `receiveAsFlow()` | `ref.listen` + a `StreamController` | `useEffect` on a state field / event emitter |
| Lint | `detekt` + "no android imports in domain" | `custom_lint` + `riverpod_lint` | `eslint-plugin-boundaries` |

## 6. Do / Don't

**Do** — one controller per screen exposing one `UiState`; keep domain logic in use cases; optimistic + rollback; targeted cache invalidation; ephemeral state stays local.
**Don't** — business logic or network calls in widgets; `setState` for screen state; global cache invalidation; leak `BuildContext`/`Context` into controllers; store server data only in memory.

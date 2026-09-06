# Error Handling, Logging & Analytics

> Part of the [starter template](README.md). Full detail: [`blueprint.md §10, §11, §12`](blueprint.md).

---

## 1. Error handling

```
core/common/
├── Failure (sealed/union):
│   Network | Timeout | Unauthorized | Forbidden | NotFound | Conflict(currentResource)
│   | Validation(fieldErrors: Map<field, message>) | Server(traceId) | Offline | Unknown
├── AppException  (thrown only at true boundaries; caught and mapped to Failure)
└── Result<T> = Success(T) | Error(Failure)     // the currency between layers
```

### Flow

1. **Data layer** never throws to callers → returns `Result`. HTTP/DB exceptions are caught and mapped by `ErrorMapper`.
2. **Domain** propagates `Result`; may add domain-specific failures.
3. **Presentation** maps `Failure` → a `UiState.Error` (retryable?) or an inline field error (`Validation`) or a one-shot event (Snackbar for transient, Dialog for blocking).
4. **UI rendering** (per [`../design-system/foundations.md §3`](../design-system/foundations.md)):
   - `Validation` → inline under the field, focus the first error, announce.
   - `Network` / `Offline` → the standard offline banner + cache "as of HH:MM".
   - `Server` → error state / banner + **Retry** + a **copyable `traceId`** for support.
   - `Conflict` → the conflict-resolution UI, never a silent overwrite.
   - `Unauthorized` → silent refresh → else save drafts + route to Login.
   - `Forbidden` → a "no permission" state with who to contact.
5. **Global safety net:** a top-level uncaught handler (`runZonedGuarded` / `Thread.setDefaultUncaughtExceptionHandler` / a React error boundary) → log + crash-report + a graceful "Something went wrong — Restart" screen. **Never a white screen.**

> **Distinguish "your fault" (validation — phrased helpfully) from "our fault" (system — apologetic + trace id).** Never show raw stack traces or error codes to users.

## 2. Logging

```
core/logging/
├── AppLogger                 log.v/d/i/w/e(tag, message, throwable?, fields: Map)
├── RingBuffer                in-memory, last ~500 lines / N minutes -> Contact Support attaches this (scrubbed)
├── sinks/  ConsoleSink (debug only) · FileSink (internal builds only) · CrashSink (breadcrumbs -> crash reporter)
└── Redactor                  strips tokens, Authorization, emails, phone, ids flagged sensitive
```

- **Structured** logs (`event`, `traceId`, `feature`, `screen`, key fields) — not string soup.
- Levels: `v`/`d` compiled out or disabled in release; `i` for lifecycle/nav/sync milestones; `w` for handled degradations; `e` for unexpected (also → crash reporter as a non-fatal).
- **Never log** credentials, tokens, PII, full request/response bodies, or DB rows. The `Redactor` runs on every sink.
- `traceId` flows from the network layer into logs and is surfaced in error UIs.
- Prod devices don't write log files by default; "Share diagnostic logs" (Contact Support) pulls the **scrubbed** ring buffer with explicit consent.
- Crash + ANR + slow-frame reporting on in prod (consent-gated where required).

## 3. Analytics

```
core/analytics/
├── Analytics (interface)     track(event: AnalyticsEvent), setUserProps(...), screen(name)
├── AnalyticsEvent            typed events — a sealed class / registry, NOT free-form strings
├── adapters/  Firebase | Amplitude | Segment | NoOpAdapter
├── ConsentGate              routes to NoOpAdapter when analytics consent is off
└── ScreenTracker            hooks navigation -> screen_view events
```

- **One tracking module.** Events are typed and defined **alongside the feature** (`AnalyticsEvent.DashboardViewed(source, isColdLoad, ...)`), with a documented schema (name, properties, when it fires).
- Naming: `object_action` snake_case (`kpi_tapped`, `approval_decided`, `export_requested`).
- **No PII** in event names or properties; the user is an opaque id; respect the consent toggle (runtime gate, default per privacy stance + region).
- Screen views auto-tracked from the router; funnel/conversion events explicit.
- Validate events in CI against the schema.

## 4. Platform

| | Compose | Flutter | React Native |
|---|---|---|---|
| Logging | Timber + a `Tree` per sink | `logger` / `logging` + custom outputs | a thin `console` wrapper / `react-native-logs` |
| Crash | Firebase Crashlytics / Sentry | `firebase_crashlytics` / `sentry_flutter` | `@sentry/react-native` / Crashlytics |
| Analytics | Firebase Analytics / Amplitude Kotlin | `firebase_analytics` / `amplitude_flutter` | `@react-native-firebase/analytics` / `@amplitude/analytics-react-native` |
| Global handler | `runCatching` at VM edges + default uncaught handler + a Compose error wrapper | `runZonedGuarded` + `FlutterError.onError` + `PlatformDispatcher.onError` | `ErrorUtils.setGlobalHandler` + `ErrorBoundary` + `react-native-exception-handler` |

## 5. Do / Don't

**Do** — `Result`/`Failure` as the currency; map every failure to a UI state; global safety net with a graceful screen; structured + redacted logs; typed analytics events gated by consent; surface `traceId`.
**Don't** — throw across layers; show stack traces/error codes to users; log tokens/PII/bodies; free-form analytics strings; collect analytics without consent; a white screen on crash.

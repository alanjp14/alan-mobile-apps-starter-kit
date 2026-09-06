# Feature Library · 09 · Platform (Deep Linking · Session Management)

> Foundation: AMDS v1.0 · Inherits [`00-framework.md`](00-framework.md). Cross-cutting platform capabilities that every feature relies on.
> Related: [`01-identity.md`](01-identity.md) (Authentication), [`03-notifications.md`](03-notifications.md) (Push), [`08-offline-sync.md`](08-offline-sync.md), [`../starter-template/navigation.md`](../starter-template/navigation.md).

---

## Feature: Deep Linking

### 1. Purpose
A single, typed, testable system for opening the app at a specific screen with specific context — from a push notification, an email, a shared link, a QR code, another app, or a marketing campaign — with the correct auth/permission gating and a sensible back stack.

### 2. Business Flow
1. **Emit** — every list and detail screen has a canonical route; services that link to the app (notification service, email templates, share sheets, QR generators) build URLs from a shared route contract.
2. **Register** — the app registers a custom scheme (`[APP_NAME]://…`) and verified universal/App Links (`https://[app].[COMPANY_NAME].example/…`).
3. **Resolve** — on open, the link is parsed to a typed `AppRoute`; if the app was cold-started, the intent is queued until the router + session are ready.
4. **Gate** — unauthenticated → Login (store the pending link, resume after); no permission → the "No permission" screen; deleted/invalid target → "no longer exists".
5. **Synthesize** — the back stack is built (`Dashboard → [resource] list → [resource] [id]`) so Back is sensible even though the user teleported in.
6. **Attribute** — `?from=push|email|share|qr|campaign` is carried for analytics and to tailor the landing (e.g. highlight the relevant section).

### 3. UX Flow
```
external link tapped
  -> app opens (cold or warm)
  -> parse -> AppRoute
  -> session ready?  no -> Login (pendingDeepLink stored) -> success -> continue
  -> permission ok?  no -> "No permission" screen
  -> target exists?  no -> "This item no longer exists" + back to list
  -> yes -> build back stack -> navigate -> (optional) highlight / scroll to the linked element
```

### 4. Screen Mapping
No dedicated screen. Touch points: every route target, plus [`../screen-library/11-utility-states.md`](../screen-library/11-utility-states.md) (No Permission, Session Expired, Error), Login ([`../screen-library/01-authentication.md`](../screen-library/01-authentication.md)).

### 5. Required Components
None new — reuses the target screens' components + the utility-state screens.

### 6. Database / Store Suggestions
| Store | Contents |
|---|---|
| client `kv` | `pendingDeepLink` (the intent to resume after auth) |
| server (optional) | `deep_link_token` for one-time secure links (`token, target, expires_at, used_at`) — used when the target itself is sensitive and should not sit in a plain URL |
| analytics | link opens with `from`, `target`, `resolved` (success/gated/notfound) |

### 7. API Endpoint Suggestions
| Method · Path | Purpose | AuthZ |
|---|---|---|
| `GET /v1/links/{token}/resolve` | resolve a one-time secure link → `{ route, params }` | the token (single-use, short TTL) |
| `POST /v1/links` | mint a secure link for a sensitive target (share flows) | permission on the target |
| _(most links need no API — they are just routes)_ | | |

### 8. State Management Suggestions
- `DeepLinkRouter` (in `core/navigation`): `parse(uri) -> AppRoute?`; a `pendingDeepLink` slot in `SessionManager` consumed after auth; a queue for cold-start intents processed once the router mounts.
- Route contract shared with the notification service and email templates (a single source — generate both from it where possible).
- Back-stack synthesis logic lives with each route's definition (`backStack = [...]`).

### 9–11. Compose / Flutter / React Native / SwiftUI
| | Registration | Parse | Cold-start |
|---|---|---|---|
| **Compose** | `<intent-filter android:autoVerify="true">` + `navDeepLink { uriPattern }` | `NavController` deep-link matching or a manual parser → typed args | handle in `onNewIntent` / read `intent` in `onCreate` |
| **Flutter** | `AndroidManifest` + `apple-app-site-association` + `go_router` routes / `app_links` | `go_router` path + query, or `Uri` parse → `AppRoute` | `getInitialLink()` / `getInitialUri()` queued behind `sessionControllerProvider` |
| **React Native** | native link config + `linking: { prefixes, config }` | React Navigation `linking` or `Linking.parse` | `Linking.getInitialURL()` + queue until the navigator is ready |
| **SwiftUI** | Associated Domains + `onOpenURL` | `URLComponents` → `AppRoute` | handle in `onOpenURL` on the root scene |

### 12. Security Considerations
- **No tokens or sensitive ids in query strings.** Filters/tabs are fine; a payslip id or a medical record id is not — use a one-time `deep_link_token` for those.
- Every deep-linked target **re-checks permission + existence** on arrival — a stale link never leaks content.
- Verified App Links / Universal Links only (prevents other apps claiming your URLs).
- Unknown/forbidden params are ignored, not errored on.
- One-time secure links: single-use, short TTL, invalidated on use, permission-checked at resolve time.
- Don't log full deep-link URLs (they may carry query context); log the route + `from` only.

### 13. Scalability Considerations
- Deep links are just routes — **zero backend cost** for the common case.
- One-time secure links use a small TTL'd store (Redis / a table partitioned by day).
- The route contract is a compile-time artifact shared across services — no runtime coupling.
- Campaign attribution flows into the analytics pipeline, not a bespoke service.

---

## Feature: Session Management

### 1. Purpose
Own the lifecycle of an authenticated session on-device — token storage and rotation, silent refresh, inactivity app-lock, step-up re-auth, multi-device awareness, and clean teardown — so every other feature can assume a valid, current identity + permission set, and the user never loses work when a session ends.

### 2. Business Flow
1. **Establish** — on sign-in (or biometric unlock), an access token (short-lived) + a rotating refresh token are issued and stored in the secure enclave; `SessionManager` publishes `{ status: authenticated, user, permissions, tenantId }`.
2. **Maintain** — the auth interceptor refreshes the access token silently on `401` (single-flight); `permissions` are refreshed on a `permissions_changed` event or a periodic check.
3. **Lock** — after an inactivity timeout (configurable; `Immediately` / `1 min` / `5 min` / `On app switch`) the app moves to `locked` and requires biometric/PIN re-unlock — the session is still valid, just gated locally.
4. **Step-up** — sensitive actions (change password, manage MFA, revoke sessions, delete account, high-value approvals per policy) require a fresh re-auth regardless of session age.
5. **Multi-device** — the user can list active sessions and revoke any; revoking elsewhere (or an admin deactivation) invalidates this session — the next API call returns `401`/`403`.
6. **End** — sign-out revokes the refresh token server-side and wipes local state; account switch does the same before loading the next identity; a session-expiry mid-task saves drafts, stores the `pendingDeepLink`, and routes to Login for a one-tap resume.

### 3. UX Flow
```
Splash -> resolve: valid+unlocked -> Dashboard | valid+locked -> unlock screen | none -> Login
App backgrounded -> record time; foregrounded -> (now - bg > lockAfter) -> locked -> biometric/PIN
Sensitive action -> step-up prompt (biometric or password) -> proceed
Token refresh fails mid-use -> save drafts -> "Session expired" screen -> Sign in -> resume exact screen
Settings > Security -> active sessions list -> revoke a device
Sign out -> confirm -> wipe -> Login
```
Screens: unlock (Archetype A + biometric), step-up (Archetype F + biometric), [`../screen-library/11-utility-states.md`](../screen-library/11-utility-states.md) §11.6 Session Expired, [`../screen-library/09-settings.md`](../screen-library/09-settings.md) §9.4 Security.

### 4. Screen Mapping
| Screen | Route | Template |
|---|---|---|
| App-lock / unlock | modal / `/lock` | Archetype A + biometric |
| Step-up re-auth | modal | Archetype F + biometric |
| Session Expired | `/session-expired` (or an interrupt) | screen-library 11 §11.6 |
| Active sessions | `/settings/security` | screen-library 09 §9.4 |
| Change password | `/security/change-password` | screen-library 08 §8.3 |

### 5. Required Components
Password Field / OTP input · Buttons · Dialog (step-up) · Banner · biometric prompt (system) — all in [`../component-library/`](../component-library/README.md).

### 6. Database / Store Suggestions
| Store | Contents |
|---|---|
| secure enclave | access token, rotating refresh token (biometric-bound when app-lock via biometrics is on), the DB key |
| client `kv` | `lockAfter` setting, `lastBackgroundedAt`, `pendingDeepLink`, `mustChangePassword` flag |
| server `session` | `id, user_id, device_id, refresh_token_hash, issued_at, expires_at, last_seen_at, ip, user_agent, revoked_at` (one row per device) |
| server `device` | `id, user_id, platform, model, os_version, push_token, trusted` |

### 7. API Endpoint Suggestions
| Method · Path | Purpose | AuthZ |
|---|---|---|
| `POST /v1/auth/refresh` | rotate refresh → new token pair (reuse-detection: a replayed refresh revokes the family) | valid refresh token |
| `GET /v1/me` | current user + `permissions[]` + `tenantId` | session |
| `GET /v1/me/sessions` · `DELETE /v1/me/sessions/{id}` · `POST /v1/me/sessions/revoke-others` | list / revoke devices | session (step-up for revoke-others) |
| `POST /v1/auth/step-up` | verify a fresh factor → a short-lived step-up token | session |
| `POST /v1/auth/logout` | revoke this session | session |
| **Realtime**: `session.revoked`, `permissions_changed` on the user channel | force logout / refresh permissions | — |

### 8. State Management Suggestions
- **`SessionManager`** (global, `core/auth`): `SessionState { status: bootstrapping | authenticated | locked | unauthenticated, user, permissions: Set<String>, tenantId, pendingDeepLink }`. Exposes `login`, `logout`, `refresh`, `lock`, `unlock`, `stepUp`, `can(permission, scope?)`.
- **Auth interceptor** on the HTTP client: attach bearer; on `401` → single-flight refresh → retry once → else `SessionManager.logout(reason = expired)` (an app-level hook saves drafts first).
- **Router guard** reads `SessionState.status` → redirects to Login / unlock / step-up; stores the intended route.
- **App-lock timer:** a lifecycle observer records background time; on foreground, `if (now - bg > lockAfter) status = locked`.
- **Permission gating in UI:** a `PermissionGate` wrapper reading `SessionManager.permissions` — hide (don't disable, unless a reason is shown).

### 9–11. Compose / Flutter / React Native / SwiftUI
| | Session holder | Lifecycle | Biometric |
|---|---|---|---|
| **Compose** | a `SessionManager` singleton exposing `StateFlow<SessionState>`; `MainActivity` collects it and the `NavHost` picks the graph | `ProcessLifecycleOwner` / `DefaultLifecycleObserver` | `androidx.biometric` `BiometricPrompt` |
| **Flutter** | `sessionControllerProvider` (Riverpod `AsyncNotifier<SessionState>`) | `WidgetsBindingObserver.didChangeAppLifecycleState` | `local_auth` |
| **React Native** | `SessionProvider` + `useSessionStore` (Zustand); a root navigator switches `AuthStack`/`AppStack`/`LockStack` | `AppState` listener | `react-native-keychain` biometric access control |
| **SwiftUI** | an `@Observable` `SessionModel` in the environment | `scenePhase` | `LocalAuthentication` |

### 12. Security Considerations
- Access token 5–15 min; refresh token **rotating + single-use** with reuse-detection (a replayed refresh revokes the whole session family).
- Biometric app-lock stores **only the refresh token** behind the enclave; a biometric enrollment change invalidates it.
- **Session revocation is immediate** — the short access-token TTL bounds the window; a `sid` revocation check at the gateway for high-security tenants.
- Step-up tokens are short-lived (minutes) and single-purpose.
- Device binding: refresh tokens bound to `device_id` + platform attestation; reject a token presented from another device.
- Sign-out / account switch / deactivation / remote wipe **fully clear**: tokens, biometric-bound key material, caches, drafts, the outbox, `id_map`, and the push token registration.
- Never log tokens; never put a session id in a URL or analytics.
- Forced password change (`mustChangePassword`) is a session flag that a router guard enforces — the app is gated on that screen until cleared.

### 13. Scalability Considerations
- JWT verification is **local at the gateway** (JWKS cached, rotated) — no per-request DB hit for authentication.
- `permissions[]` resolved once at login (embedded in a claim or cached in Redis, short TTL, invalidated on role change) — never recomputed per request.
- Refresh + login spike at shift-start: `session` / `login_attempt` on a time-partitioned table; async the audit fan-out; rate-limit counters in Redis.
- Realtime `session.revoked` / `permissions_changed` via a per-user pub/sub topic; the client also re-checks on foreground as a fallback.
- The session store is small and hot — cache `session` validity + `user` in Redis, invalidate on revoke.

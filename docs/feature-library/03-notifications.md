# Feature Library · 03 · Notifications

> Foundation: AMDS v1.0 · Inherits [`00-framework.md`](00-framework.md). Features: **Notification Center · Push Notifications**.

---

## Feature: Notification Center

### 1. Purpose
The in-app, durable, categorized inbox of everything that concerns the user — workflow events, mentions, assignments, system announcements, digests — each linking to its source, with read-state synced across devices and per-category preferences. It is the source of truth; push is just one delivery channel.

### 2. Business Flow
1. **Emit** — any service, on a state change, publishes a domain event to the bus (`approval.assigned`, `comment.mention`, `task.assigned`, `system.maintenance`).
2. **Fan-out** — a Notification service consumes events, resolves recipients (a user, a role, "watchers of X"), applies each recipient's **preferences** (category on/off, channels, quiet hours, digest), and creates a `notification` row per recipient + queues deliveries per enabled channel.
3. **Deliver** — in-app (always, it's the record) + push + email + SMS as configured. Time-sensitive items may bypass digest/quiet-hours if `critical`.
4. **Consume** — the user opens the app / taps a push → Notification Center or a direct deep link → the item is marked read → read-state syncs to the server and to other devices → unread counts (bell badge, OS app-icon badge, bottom-nav badge) update.
5. **Act** — some notifications carry a safe quick action ("Approve", "View"); others just navigate.
6. **Housekeeping** — batching ("3 comments on INC-442"), digests (daily summary), retention (auto-archive after N days), "mark all read".

### 3. UX Flow
```
App-bar bell (badge) / bottom-nav → Notification List (grouped by day, tabs: All/Mentions/Approvals/System)
  → tap pointer-type item → deep-link to source (approval / record / comment), mark read
  → tap rich item (announcement/digest) → Notification Detail (content + acknowledge?)
  → quick action (Approve/View) → acts in place → Snackbar
  → swipe → mark read / dismiss (Undo)
  → "Mark all read" → dots clear, badges → 0
  → overflow → Notification Settings (→ Settings feature §06)
Push received (app background) → OS notification → tap → deep-link + mark read; list reconciles on next open
```
Screens: [`../screen-library/06-notifications.md`](../screen-library/06-notifications.md).

### 4. Screen Mapping
| Screen | Route | Template |
|---|---|---|
| Notification List | `/notifications?tab=` | 06 §6.1 (Archetype C) |
| Notification Detail | `/notifications/:id` | 06 §6.2 (D — rich/standalone only) |
| Notification Settings | `/settings/notifications` | 09 §9.3 (Archetype G) |

### 5. Required Components
List/ListTile + Avatar + Badge (unread dot / count) ([16 §9,14,15,18](../component-library/api-reference.md)) · Segmented/Chips (tabs) · Section headers (date buckets) · Inline Button (quick action) [16 §1](../component-library/api-reference.md) · Empty state · Pull-to-refresh · Snackbar (Undo) [16 §12](../component-library/api-reference.md) · Banner (offline). Feature composites: `NotificationRow`, `BellWithBadge`, `NotificationGroupHeader` ([16 §18](../component-library/api-reference.md)).

### 6. Database Entity Suggestions
| Entity | Key columns | Notes |
|---|---|---|
| `notification` | `id, tenant_id, user_id, category, type, title, body, actor_id?, entity_ref (deep-link target), group_key?, priority (normal/critical), created_at, read_at?, archived_at?, seen_at?` | **one row per recipient** |
| `notification_delivery` | `id, notification_id, channel (inapp/push/email/sms), status (queued/sent/delivered/failed/suppressed), provider_msg_id, attempts, sent_at, error` | per-channel tracking |
| `notification_preference` | `user_id, category, enabled, channels[], updated_at` | + a `user_notification_settings` singleton for master/quiet-hours/digest/sound |
| `notification_digest` | `id, user_id, period_start, period_end, item_ids[], sent_at` | |
| `push_token` | `id, user_id, device_id, platform, token, app_version, updated_at, invalid_at?` | (shared with Push Notifications) |
| `notification_read_cursor` | `user_id, last_read_at` | cheap "unread since" |

Indexes: `notification(user_id, created_at DESC) WHERE archived_at IS NULL`, `notification(user_id, read_at)` (unread count), `notification(user_id, group_key)`, `notification_delivery(status, created_at)`.

### 7. API Endpoint Suggestions
| Method · Path | Purpose | AuthZ |
|---|---|---|
| `GET /v1/notifications?tab=&filter[category]=&cursor=` | list (grouped) | self |
| `GET /v1/notifications/{id}` | rich detail | self (owner) |
| `POST /v1/notifications/{id}/read` / `/unread` | toggle read | self |
| `POST /v1/notifications/read-all` | mark all read (optional `?before=`) | self |
| `POST /v1/notifications/{id}/dismiss` | archive | self |
| `POST /v1/notifications/{id}/acknowledge` | compliance ack (idempotent) | self |
| `GET /v1/notifications/count` | `{ unread, byCategory }` — cheap, cache-friendly | self |
| `GET/PATCH /v1/me/notification-settings` | preferences matrix + quiet hours + digest | self |
| **Realtime**: `notification.created`, `notification.read` (multi-device sync) on the user channel | badge + list update | — |
| `POST /v1/internal/notifications/emit` | (internal) event → fan-out | service-to-service |

### 8. State Management Suggestions
- `notificationListController` — `RecordListConfig` over `/notifications`; keyset paging; groups by day client-side; subscribes to `notification.created`/`notification.read` → prepends new / syncs read.
- `unreadCountProvider` — from `GET /notifications/count` + realtime deltas; drives `BellWithBadge`, the bottom-nav "Approvals"/"Notifications" badge, and (via a platform bridge) the **OS app-icon badge**.
- Read-state is **optimistic** (tap → mark read locally → `POST /read`) and reconciled on realtime `notification.read` from other devices.
- `notificationSettingsController` — optimistic + revert (Archetype G).
- Offline: list serves cache "as of HH:MM"; read/dismiss queue; "mark all read" applies locally + syncs.

### 9. Jetpack Compose Implementation Suggestions
- `:feature:notifications`. Paging 3 + `LazyColumn` with `stickyHeader` for date buckets; `SwipeToDismissBox` for mark-read/dismiss.
- `unreadCountProvider` exposed as `StateFlow`; `MainActivity` sets `ShortcutBadger`/`NotificationManager` app-icon badge; a `NavigationBarItem` badge.
- Realtime via the shared WebSocket `Flow`; on `notification.created` → `pagingSource.invalidate()` or prepend to an in-memory head list.

### 10. Flutter Implementation Suggestions
- `feature_notifications`. `PagedListView` + manual date-bucket headers; `Dismissible`.
- `unreadCountProvider` (Riverpod) → `flutter_app_badger` for the OS icon badge; `NavigationDestination` badge.
- Realtime `StreamProvider` from `web_socket_channel`; `ref.listen` to invalidate the paging controller / bump the count.

### 11. React Native Implementation Suggestions
- `features/notifications`. `SectionList`/`FlashList` with date sections; `Swipeable`.
- `useUnreadCount()` (React Query + WS updates) → `@react-native-community/push-notification-ios` `setApplicationIconBadgeNumber` / `notifee.setBadgeCount` (Android) ; tab badge via navigator options.
- WS client dispatches `queryClient.setQueryData(['notifications','count'], …)` and invalidates the list.

### 12. Security Considerations
- **Per-recipient rows** — a user can only ever query their own notifications; no shared notification objects.
- **Payload minimization** — `title`/`body` must be safe to show on a lock screen; **no amounts, PII, or record contents** in the notification row's `body` for sensitive categories — carry a reference and load details in-app after auth.
- **Deep-link safety** — `entity_ref` is validated on tap (permission + existence); a revoked user tapping an old notification gets "no access", not the content.
- **Acknowledgement integrity** — `acknowledge` is idempotent and recorded with timestamp + user for compliance notices; can gate features elsewhere.
- **Preference enforcement** — the fan-out service is authoritative: a category+channel both-enabled check happens server-side before any delivery; quiet-hours evaluated in the user's timezone; `critical` bypass is a server decision, not a client hint.
- **Injection** — notification `title`/`body` are plain text (rich detail is sanitized markdown); never render as HTML in-app.
- **Rate / abuse** — cap notifications per user per source per hour (dedupe/batch via `group_key`); alert on fan-out storms.

### 13. Scalability Considerations
- **Fan-out is the scaling challenge**: one event → potentially thousands of `notification` rows + deliveries. Do it async in workers off the event bus; batch inserts; shard by `user_id`.
- `notification` table grows unbounded — **partition by month**, auto-archive/drop partitions past retention (e.g. 90 days), keep a compact `notification_read_cursor` for "unread since".
- **Unread count** must be O(1): maintain a per-user counter in Redis (INCR on create, DECR on read, reset on read-all) rather than `COUNT(*)` on every app open; `GET /notifications/count` reads Redis.
- Realtime: per-user pub/sub topic; the socket layer is stateless behind a shared broker; drop to polling `/count` (30–60s) on disconnect.
- Digests: a scheduled job aggregates per-user unsent low-priority items into one notification — reduces volume dramatically.
- Batching via `group_key` collapses "N comments on X" into one row that updates in place.
- Delivery providers (FCM/APNs/email/SMS) are called from a queue with retries, backoff, and dead-letter; token invalidation feedback loops remove dead `push_token`s.

---

## Feature: Push Notifications

### 1. Purpose
Deliver time-relevant notifications to the device when the app is backgrounded or closed, via FCM (Android) and APNs (iOS), including token lifecycle, permission handling, deep-link routing on tap, foreground presentation, silent data pushes for realtime sync, and delivery/interaction telemetry.

### 2. Business Flow
1. **Register** — on sign-in (and on token refresh), the app obtains a platform push token and registers it against the user + device (`push_token`).
2. **Permission** — the app requests notification permission at a contextually sensible moment (not on first launch); if denied, features degrade gracefully and Notification Settings shows a "blocked → open device settings" affordance.
3. **Send** — the Notification service (see Notification Center) hands a delivery to a **push dispatcher** → builds an FCM/APNs payload (title, body, `data` with `notificationId` + `entityRef` + `category`, collapse key, priority, badge count) → sends via the provider.
4. **Receive** — OS displays it (background) or hands it to the app (foreground → the app decides: show an in-app banner, update a badge, or suppress). **Silent/data pushes** wake the app briefly to sync (new approval, monitoring alert) without a visible notification.
5. **Interact** — tap → the app opens, routes to `entityRef`, marks the notification read, logs the interaction. Action buttons on the notification ("Approve", "Snooze") call the API directly where safe.
6. **Feedback** — provider responses mark tokens invalid → the token is removed; delivery receipts + open rates feed analytics.

### 3. UX Flow
```
Sign-in → (later, in context) permission prompt → granted → token registered
Notification arrives:
  app killed/bg → OS notification → tap → app cold/warm start → route to entityRef → mark read
  app foreground → intercepted → show AmdsBanner/Snackbar OR silently update badge/list (no duplicate OS banner)
  action button ("Approve") → API call (with the notification's context) → result toast
Permission denied → Notification Settings shows "Notifications blocked" + "Open settings" (deep link to OS)
Sign-out → token de-registered
```

### 4. Screen Mapping
No dedicated screen. Touch points: the **permission priming** sheet (Archetype F-ish, contextual), **Notification Settings** (`/settings/notifications`, 09 §9.3) for the blocked-state affordance, and every deep-link **target** screen (approvals, records, monitoring). A design-time `pushPreview` reference lives in [16 §18](../component-library/api-reference.md).

### 5. Required Components
Banner / Snackbar (foreground presentation) ([16 §12, component-lib D6](../component-library/api-reference.md)) · Bottom Sheet (permission priming) [16 §6](../component-library/api-reference.md) · Settings rows (blocked state) [16 §component G] · Badge (icon badge) [16 §14](../component-library/api-reference.md). Feature composites: `PushPermissionPrimer`, `ForegroundNotificationHandler`, `NotificationDeepLinkRouter`.

### 6. Database Entity Suggestions
| Entity | Key columns | Notes |
|---|---|---|
| `push_token` | `id, user_id, device_id, platform (android/ios), token, app_version, locale, timezone, created_at, updated_at, invalid_at?` | unique `(platform, token)`; one active per device |
| `push_dispatch` | `id, notification_id, push_token_id, provider (fcm/apns), payload_hash, priority, collapse_key, status (queued/sent/failed/invalid_token), provider_msg_id, sent_at, error` | per-send record |
| `push_interaction` | `id, notification_id, user_id, device_id, event (delivered/opened/action:<name>/dismissed), at` | telemetry |
| `push_provider_config` | `tenant_id?, fcm_project, apns_key_id, apns_team_id, bundle_id, …` | usually app-global, secrets in a vault |

### 7. API Endpoint Suggestions
| Method · Path | Purpose | AuthZ |
|---|---|---|
| `POST /v1/me/push-tokens` | register/refresh `{platform, token, deviceId, appVersion}` (upsert) | session |
| `DELETE /v1/me/push-tokens/{token}` | de-register (on sign-out / permission revoked) | session |
| `POST /v1/me/push-tokens/{token}/interactions` | log delivered/opened/action | session |
| `GET /v1/me/notification-permission-state` | (optional) server view of whether pushes are landing | session |
| `POST /v1/internal/push/dispatch` | (internal) Notification service → push dispatcher | service |
| Provider webhooks: FCM/APNs delivery + token-invalidation feedback | mark `push_token.invalid_at` | provider (verified) |

### 8. State Management Suggestions
- A `PushService` singleton (outside feature state): requests permission, gets the token, registers it, wires the message handlers, and de-registers on logout. Exposes `permissionStatus` to Notification Settings.
- **Foreground messages** → routed to an app-level `NotificationBus` that decides: show `AmdsBanner`/`Snackbar`, bump `unreadCountProvider`, prepend to the notification list, and/or trigger a data refresh — **never** a duplicate OS banner.
- **Silent/data pushes** → dispatch to the relevant feature's cache invalidation (e.g. `queryClient.invalidateQueries(['approvals'])`, or the offline-sync engine's "pull now").
- **Tap handling** → a `NotificationDeepLinkRouter` maps `data.entityRef` → a typed route; runs *after* the session/router is ready (queue the intent during cold start, like the auth `pendingDeepLink`).
- Badge count kept in sync from `unreadCountProvider` (push payloads also carry an authoritative `badge` to correct drift).

### 9. Jetpack Compose Implementation Suggestions
- `firebase-messaging`. A `FirebaseMessagingService` subclass: `onNewToken` → enqueue a `WorkManager` job to `POST /me/push-tokens`; `onMessageReceived` → for `data` messages build a notification with `NotificationCompat` (channels per category, importance mapped to `priority`), set `PendingIntent` with the deep link; for foreground, post to the `NotificationBus` instead.
- Permission: `POST_NOTIFICATIONS` runtime permission (Android 13+) via `ActivityResultContracts.RequestPermission`, primed with a rationale sheet.
- Notification channels created at startup, one per category, so users can tune them in system settings too.
- Deep link: `PendingIntent` → `MainActivity` with a `navDeepLink` URI; handle in `onNewIntent`.

### 10. Flutter Implementation Suggestions
- `firebase_messaging` + `flutter_local_notifications` (to render `data` pushes + foreground). `FirebaseMessaging.instance.onTokenRefresh` → register; `getInitialMessage()` for cold-start taps; `onMessage` (foreground) → `NotificationBus`; `onMessageOpenedApp` → router.
- A top-level `firebaseMessagingBackgroundHandler` for data-only sync.
- Permission: `FirebaseMessaging.requestPermission()` / `permission_handler`, primed contextually.
- Android channels via `flutter_local_notifications` `AndroidNotificationChannel` per category; iOS `DarwinNotificationDetails`.
- `flutter_app_badger` for the icon badge from the payload's `badge`.

### 11. React Native Implementation Suggestions
- `@react-native-firebase/messaging` (+ `notifee` for rich local display and channels). `messaging().onTokenRefresh` → register; `getInitialNotification()` + `onNotificationOpenedApp` for taps; `onMessage` (foreground) → `NotificationBus`; `setBackgroundMessageHandler` for data sync.
- Permission: `messaging().requestPermission()` (iOS) / `PermissionsAndroid.request(POST_NOTIFICATIONS)` (Android 13+), primed via a sheet.
- `notifee` channels per category; `notifee.setBadgeCount` from the payload.
- Deep link routing through the same `linking` config used for universal links.

### 12. Security Considerations
- **Payload sensitivity** — assume the notification is visible on a locked screen and in cloud provider logs: no PII, amounts, health/HR details, or record contents in `title`/`body`/`data`. `data` carries opaque ids only.
- **Token binding** — `push_token` is bound to `user_id` + `device_id`; on sign-out, account switch, or "sign out this device", the token is de-registered server-side so the previous user stops receiving.
- **Provider credentials** (APNs key, FCM service account) live in a secrets manager, rotated; never in the app or repo.
- **Tap authZ** — the deep-link target re-checks permission + existence; a stale notification never leaks content.
- **Silent-push abuse** — rate-limit data pushes; they can drain battery / be used for tracking — only send them for genuine sync triggers, and honor OS budget limits (iOS background push throttling).
- **Spoofing** — the app trusts only pushes it can correlate to a `notificationId` it can fetch via the authenticated API; don't act on unverified `data` alone for anything sensitive (fetch-then-act).
- **Webhook verification** — provider feedback webhooks are authenticated (FCM/APNs signatures / mTLS).
- **Consent** — respect the OS permission and the in-app category preferences; deregister on revocation; document data flows for privacy compliance.

### 13. Scalability Considerations
- **Dispatch throughput** — the push dispatcher is a horizontally-scaled queue consumer; batch to FCM (multicast / topic where applicable) and APNs (HTTP/2 multiplexing, connection pooling); respect provider QPS limits with token-bucket rate limiting.
- **Token hygiene** — process provider invalid-token feedback promptly to prune `push_token`; a periodic job removes tokens unused for > N months.
- **Collapse keys** — set per `group_key` so a burst of updates for one entity collapses to the latest on the device.
- **Priority mapping** — only `critical` items get high-priority/time-sensitive delivery; everything else normal priority to preserve device budget and avoid OS throttling.
- **Fan-out coupling** — push dispatch is downstream of the Notification fan-out (§Notification Center §13); the same partitioning/queue strategy applies.
- **Multi-region** — regional dispatchers; APNs/FCM are global but keep the queue + token store close to the user's region.
- **Observability** — track sent → delivered → opened funnels per category to detect deliverability regressions (e.g. a provider key expiry) fast.

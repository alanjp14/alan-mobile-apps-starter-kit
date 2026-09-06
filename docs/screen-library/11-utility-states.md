# Screen Library · 11 · Utility States

> Foundation: AMDS v1.0 · Archetype: mostly **F — Confirmation-adjacent** / full-screen state pages (framework §4). These are full screens, distinct from the per-section states in [`00-framework.md §6.1`](00-framework.md).

Screens: Loading · Empty · Error · Offline · No Permission · Session Expired · Maintenance

These are **reusable, app-agnostic** — every app ships all seven. Copy-paste starting points: [`../../templates/`](../../templates/).

---

## Shared layout

```
[ App bar: back/close if there is somewhere to go, else none ]
[ vertically centered, content max-width 360, 24 margin ]
   illustration / icon   (40–64, tinted per state)
   title                 headingSmall, centered
   body                  bodyMedium textSecondary, centered, ≤2 lines
   [ primary action ]    Large button, full-width — the way forward
   [ secondary link ]    optional
[ safe-area bottom ]
```

**Rules:** never a dead end — every state has at least one action. Icon + text together (never icon/color alone). Reduced-motion: static icon, no looping animation. Dark mode: illustrations use dark variants; icon tints use the -400 hue.

---

## 11.1 Loading (full screen)

1. **Purpose** — the app or a route is resolving and there is nothing meaningful to show yet (initial app load, a heavy route, session resolution).
2. **Layout** — centered logo + a subtle circular indeterminate indicator; app version `caption` at the bottom (optional). No text beyond an optional "Loading…".
3. **States** — this *is* a state. Hard cap ~3s → transition to a skeleton, content, or an error/retry screen regardless.
4. **Accessibility** — announce "Loading" once (polite); the spinner is `aria-hidden`; reduced-motion → slow opacity pulse.
5. **Animations** — spinner 360°/900ms linear; crossfade out 200ms.
6. **Dark mode** — honor the theme from the first frame (no white flash).
7. **Developer notes** — prefer the OS splash for frame 1; use this only while resolving session/first-data; **Compose** `installSplashScreen()` keep-condition · **Flutter** `flutter_native_splash` + an awaited splash page · **RN** `react-native-bootsplash`.
8. **UX** — <1.5s target; no taglines/carousels; fail to a retry screen, not a hang.

## 11.2 Empty state (full screen)

1. **Purpose** — a screen legitimately has no content. Distinguish **first-use** ("Nothing here yet — add the first one"), **no-results** ("Nothing matches your search/filters"), and **cleared** ("You're all caught up 🎉").
2. **Layout** — shared layout; icon 40–64; first-use → primary "Add [DATA_NAME]"; no-results → "Clear filters" + echo the query; cleared → a calm confirming visual, no CTA needed.
3. **Accessibility** — the title + body are announced; the CTA is clearly labelled; not a `role=alert` (it's expected, not an error).
4. **Animations** — fade in; icon may have a one-time gentle scale (reduced-motion: none).
5. **Dark mode** — muted illustration on `surface`.
6. **Developer notes** — the empty variant is driven by `UiState.Empty(reason)`; copy comes from config so each `[MODULE_NAME]` sets its own.
7. **UX** — specific copy per reason; never a bare "No data"; always the next action.

## 11.3 Error (full screen)

1. **Purpose** — a screen-level operation failed and there is nothing usable to show (initial load failed, no cache).
2. **Layout** — `error`/`cloud_off` icon (`danger` tint) · "Something went wrong" / "Couldn't load [DATA_NAME]" · a short cause hint · **"Try again"** primary · a copyable `traceId` in `caption` ("Ref: 8f3a…") for support · optional "Contact support".
3. **States** — retrying shows a spinner on the button; a repeated failure keeps the same screen (don't loop).
4. **Accessibility** — `role=alert` on appearance; the `traceId` is announced and copyable; focus moves to "Try again".
5. **Animations** — fade in; button → spinner on retry.
6. **Dark mode** — icon red-400; `dangerContainer` behind the icon optional.
7. **Developer notes** — from `UiState.Error(failure, retryable)`; `Server` failures carry the `traceId`; distinguish from `Validation` (inline) and `Offline` (§11.4).
8. **UX** — apologetic tone ("our fault"); one clear action; never show a stack trace or raw code.

## 11.4 Offline (full screen — when there is no cache)

1. **Purpose** — no connectivity **and** no cached content to fall back to. (When cache exists, show it + the [offline banner](../design-system/foundations.md#3-screen-level-state-model) instead — this full screen is the no-cache case.)
2. **Layout** — `wifi_off` icon · "You're offline" · "We'll load [DATA_NAME] as soon as you're back online." · "Try again" (retries on demand) · auto-retries on connectivity regained.
3. **States** — reconnecting → spinner; connectivity back → auto-transition to the real screen.
4. **Accessibility** — announced; "Try again" labelled; connectivity change announced.
5. **Animations** — fade; no looping.
6. **Dark mode** — icon `textSecondary`/-400.
7. **Developer notes** — driven by `Connectivity` + `UiState`; the bottom nav still lets the user reach cached sections; **never** an infinite spinner.
8. **UX** — reassure that nothing is lost; queued actions ([local-storage](../starter-template/local-storage.md)) still apply on reconnect.

## 11.5 No Permission

1. **Purpose** — the user is authenticated but lacks access to this resource/screen (deep link to a restricted record, a role change, a scoped permission).
2. **Layout** — `lock` icon (`warning` tint) · "You don't have access" · "Ask your administrator for access to [MODULE_NAME]." · primary "Request access" (opens a request flow or a mailto to the resource owner) · secondary "Back to [safe screen]".
3. **States** — request submitted → confirmation ("Request sent to [ROLE_NAME]").
4. **Accessibility** — `role=alert`; clearly explains the situation and who to contact; actions labelled.
5. **Animations** — fade.
6. **Dark mode** — icon amber-400.
7. **Developer notes** — from a router guard (`requires` on the route) or a `403` → `Failure.Forbidden`; **never** reveal the restricted content or even confirm its existence beyond "you don't have access".
8. **UX** — actionable (request access / contact), not a dead end; don't blame the user.

## 11.6 Session Expired

1. **Purpose** — the session ended (token expired and refresh failed, revoked elsewhere, deactivated, long inactivity) while the user was mid-task.
2. **Layout** — `schedule`/`logout` icon · "Your session has expired" · "Sign in again to continue." · primary "Sign in" (→ Login, preserving `pendingDeepLink` and any draft) · if a draft was saved: "Your unsaved changes are safe and will be restored."
3. **States** — signing in resumes the exact prior screen/flow.
4. **Accessibility** — `role=alertdialog` if shown as an interrupt over the current screen; focus to "Sign in"; announce that work is preserved.
5. **Animations** — scrim + fade (dialog) or fade (full screen).
6. **Dark mode** — standard.
7. **Developer notes** — triggered by `Failure.Unauthorized` after a failed silent refresh; **save drafts first** (an app-level hook), store `pendingDeepLink`, then route to Login; on success, replay.
8. **UX** — never lose the user's work; make it a one-tap recovery; explain why briefly.

## 11.7 Maintenance

1. **Purpose** — the backend is in planned maintenance or a forced-upgrade window; the app can't function.
2. **Layout** — `build`/`construction` icon (`info` tint) · "We'll be right back" / "[APP_NAME] is being updated" · an estimated end time if known · "Try again" · a status-page link · for a **forced app upgrade**: "Update required" + "Open [App Store / Play Store]".
3. **States** — "Try again" re-checks; auto-recovers when the backend is healthy.
4. **Accessibility** — `role=status`; the estimated time and actions are announced.
5. **Animations** — fade; no looping.
6. **Dark mode** — icon sky-400.
7. **Developer notes** — driven by a `503` + `Retry-After`, a maintenance flag in `GET /app/config`, or a min-supported-version check; block the whole app (a router redirect to `/maintenance`); the config is polled on resume.
8. **UX** — set an expectation (time / status page); distinguish "maintenance" (wait) from "update required" (act now).

---

## Cross-references

- Per-section (not full-screen) states: [`00-framework.md §6.1`](00-framework.md), [`../design-system/foundations.md §3`](../design-system/foundations.md).
- Error model + `Failure` union: [`../starter-template/error-handling-and-logging.md`](../starter-template/error-handling-and-logging.md).
- Offline behavior: [`../starter-template/local-storage.md`](../starter-template/local-storage.md), [`../feature-library/08-offline-sync.md`](../feature-library/08-offline-sync.md).
- Session handling: [`09-platform`](../feature-library/09-platform.md) is in the feature library; auth flows in [`01-authentication.md`](01-authentication.md).

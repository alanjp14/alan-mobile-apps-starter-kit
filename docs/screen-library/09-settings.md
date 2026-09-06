# Screen Library · 09 · Settings

> Foundation: AMDS v1.0 · Archetype: **G — Settings List** (§4.G) for all four.
> A **Settings hub** (`/settings`) lists the groups; each group below is its own screen. Toggles apply instantly — no global Save. Entries = deltas + the specific rows.

Screens: General Settings · Theme Settings · Notification Settings · Security Settings

Settings hub layout (`/settings`): grouped `AmdsListTileX` navigation rows → General · Appearance/Theme · Notifications · Privacy & Security · About (→ §10.3) · Help & Support (→ §10). App version + build (copyable) at the bottom.

```
Settings hub ─► General / Theme / Notifications / Security  (each a G screen)
                └─ value rows ─► picker (AmdsBottomSheet / Dialog)
                └─ toggle rows ─► apply instantly
Security ─► Change Password (§08.3) · Active sessions · Delete account (guarded flow)
```

---

## 9.1 General Settings

**Archetype:** G · **Route:** `/settings/general`

1. **Purpose** — app-wide preferences that don't belong to Theme, Notifications, or Security: language, region/formats, defaults, data, and diagnostics.
2. **User Goal** — "Set the app to my language / region / defaults and manage local data."
3. **Layout** — G's grouped list:
   - **Language & region:** App language (value row → sheet; "System default" option) · Region / date & number format (value row) · Time zone (value row; "Automatic" default) · First day of week (value row).
   - **Defaults:** Default landing screen (Dashboard / last visited) · Default list density (Comfortable / Compact — Segmented) · Default map/units (metric/imperial) — product-dependent.
   - **Data & storage:** "Offline data" size + "Clear cache" (action; non-destructive to user data) · "Download over Wi-Fi only" (toggle) · "Sync now" (action + last-sync time).
   - **Diagnostics:** "Share diagnostic logs" (action → §10.2 Contact Support with logs) · "Usage analytics" (toggle, with a link to what's collected) · "Crash reporting" (toggle).
   - **Advanced (rare):** environment indicator (dev/staging badge — never in prod), feature-flag overrides (internal builds only).
4. **Component Hierarchy** — G's + `AmdsSectionHeader × groups`, `AmdsSettingRow.value(language, region, timezone, firstDay, landing)`, `AmdsSettingRow.toggle(wifiOnly, analytics, crashReporting)`, `AmdsSettingRow.action(clearCache, syncNow, shareLogs)`, `AmdsSegmented(density)`.
5. **Information Architecture** — most-changed first (language/region), then defaults, then data, then diagnostics. Show current values inline and the effect ("Clear cache · 84 MB"). Analytics/crash toggles link to a plain-language description of what's collected.
6. **User Flow** — G's. `value row → sheet picker → choose → applied (some, like language, may need an app-content refresh — do it live, avoid a restart) `. `"Clear cache" → confirm ("This frees 84 MB. Your data isn't affected and will re-download when needed.") → cleared → size updates`. `toggle analytics off → applied immediately + a confirming Snackbar`.
7. **States** — G's. Deltas:
   - **Loading:** rows render instantly from local prefs; cache size + last-sync compute async (show a brief "…").
   - **Empty:** N/A.
   - **Success:** value/toggle reflects the change; Snackbar for non-visible effects.
   - **Error:** a server-backed default (e.g. default landing stored in the account) fails to save → revert the control + "Couldn't save — try again".
   - **Offline:** all local settings (language, format, density, Wi-Fi-only) work fully; "Sync now" disabled with "You're offline"; account-stored defaults queue.
8. **Accessibility** — G's. Value rows announce "label, current value" ("App language, English"). Toggle rows `role=switch` + state. "Clear cache" announces the reclaimable size and that user data is safe. Language change re-announces the screen in the new language. Segmented density = `radiogroup` with the current selection.
9. **Animations** — G's. Value picker sheet slide-up; toggle thumb slide; density change re-renders a small preview (if shown). Language change: root content crossfade after strings reload. Reduced-motion: instant.
10. **Dark Mode** — G's. Rows `#0F172A`, dividers `#1E293B`; environment badge (non-prod) uses `warning`.
11. **Tablet** — G's landscape two-pane (groups left, this list right as part of the Settings master-detail); portrait single list max-640.
12. **Developer Notes** — **all:** local prefs via `shared_preferences` / DataStore / `MMKV`; account-stored defaults via `PATCH /me/preferences` (optimistic + revert). Language: `flutter_localizations` `Locale` override + rebuild `MaterialApp`; RN `i18next.changeLanguage`; Compose `AppCompatDelegate.setApplicationLocales` / per-app language. Formats/timezone flow into the central `Formatters`. "Clear cache" clears image + HTTP + list caches, **never** secure storage or drafts. Analytics/crash toggles gate the SDKs' collection at runtime. **Compose/Flutter/RN:** one `AmdsSettingRow` widget, a `generalSettingsController`.
13. **UX Best Practices** — instant apply; show current values + effects; "Clear cache" reassures about data safety; analytics/crash toggles link to what's collected and default per your privacy stance + regional law; avoid requiring a restart (do language live); non-prod environment always visibly badged.

---

## 9.2 Theme Settings

**Archetype:** G · **Route:** `/settings/appearance`

1. **Purpose** — control the app's visual appearance: light/dark, text size, density, and (where offered) accent/brand and contrast.
2. **User Goal** — "Make the app comfortable to look at and read — dark mode, bigger text — and see the change immediately."
3. **Layout** — G's grouped list with a **live preview**:
   - **Preview card (top):** a small representative sample (app bar + a card + a button + body text) that re-renders live as settings change.
   - **Theme:** `System · Light · Dark` (Segmented control).
   - **Text size:** a slider or stepped Segmented (Small / Default / Large / Larger / Largest) mapping to the AMDS 0.85–2.0 scale — **or** a row that defers to the OS setting ("Text size follows your device settings" + "Open device settings"). Recommended: honor the OS `textScaler` and offer only a clamp/boost, not a full override.
   - **Density:** `Comfortable · Compact` (Segmented) — affects list row heights + paddings.
   - **Bold text / High contrast:** toggles (or "follows device").
   - **Accent colour** (only if the product supports theming): a small swatch picker from an approved set (each pre-validated for contrast) — most enterprise apps omit this and use the brand primary.
   - **Reduce motion:** a row that reflects/links to the OS setting ("Animations follow your device settings").
4. **Component Hierarchy** — G's + `ThemePreviewCard`, `AmdsSegmented(themeMode)`, `AmdsSegmented/Slider(textSize)`, `AmdsSegmented(density)`, `AmdsSwitchTile(boldText, highContrast)?`, `AccentSwatchPicker?`.
5. **Information Architecture** — the preview makes the abstract concrete. Order: theme → text size → density → contrast/motion. Where the OS already provides a setting (Dynamic Type, reduce motion, bold text, high contrast), **defer to it** and just surface/link it rather than duplicating — offer an in-app control only where it adds value (a clamp, a per-app override some users want).
6. **User Flow** — G's. `change Theme = Dark → root crossfades 200ms, preview + whole app update live, choice persisted `. `bump Text size → preview reflows immediately, applied app-wide `. `on System → follows the OS (including scheduled/auto dark) in real time`.
7. **States** — G's. Deltas:
   - **Loading:** none — all local, instant.
   - **Empty:** N/A.
   - **Success:** every control reflects the active value; preview matches; persisted.
   - **Error:** N/A (local-only).
   - **Offline:** fully functional (all local).
8. **Accessibility** — G's. This screen is itself an accessibility surface. Theme Segmented = `radiogroup`, current selection announced, and the theme change is announced ("Dark theme on"). Text-size control announces the new level and the preview updates. If deferring to the OS, the row clearly says so and the "Open device settings" action is labelled. High-contrast/bold-text toggles announce state. The preview card is `aria-hidden` decoration OR a labelled sample ("Preview: how the app looks"). Everything on this screen must itself remain legible at every setting it can produce.
9. **Animations** — theme change = root crossfade 200ms (**instant under reduce-motion**); preview components animate their token changes (color crossfade 150ms); text-size change reflows without animation (or a quick 150ms fade). No decorative motion here.
10. **Dark Mode** — this is where dark mode is chosen; the preview shows the dark palette accurately (dark-mode). Segmented selected state green-400 indicator; swatch picker swatches show a check on the chosen one with a `surface` ring.
11. **Tablet** — G's landscape two-pane: controls left, a **larger live preview** (a real mini-screen mock) right. Portrait: preview card on top, controls below.
12. **Developer Notes** — **all:** `themeControllerProvider { ThemeMode mode, double textScale, Density density, bool boldText, bool highContrast, String? accentId }` persisted locally; drives `MaterialApp` theme + a `MediaQuery` wrapper that clamps `textScaler` to 0.85–2.0. **Compose:** hoist to the Activity; `AppCompatDelegate` for locale; recompose on change. **Flutter:** `themeMode` + `builder:` wrapping `MediaQuery` with the clamped `textScaler`; `AmdsTheme.light/dark`. **RN:** a theme context + `useColorScheme` fallback; `Appearance` listener for System. Accent (if used): recolor **semantic** tokens only from an approved, contrast-validated set — never free-form color. Respect `MediaQuery.boldText` / `accessibilityIgnoresInvertColors` / reduce-motion from the OS.
13. **UX Best Practices** — live preview + live apply. Defer to the OS for Dynamic Type / reduce motion / bold text / high contrast; add an in-app control only where it helps. `System` must track the OS in real time. Keep this screen legible at every setting it can create. If you offer accent colours, they're a pre-validated set, not a colour wheel.

---

## 9.3 Notification Settings

**Archetype:** G · **Route:** `/settings/notifications`

1. **Purpose** — let the user control which notifications they receive, through which channels, and when.
2. **User Goal** — "Turn off the noise, keep the important stuff, and don't disturb me at night."
3. **Layout** — G's grouped list:
   - **Master:** "Allow notifications" — if the OS permission is denied, this row shows "Blocked in device settings" + "Open settings" instead of a toggle.
   - **Channels** (per delivery method the product uses): Push · Email · In-app · SMS — each a toggle (a channel off suppresses that method across all categories).
   - **Categories** (the meaningful part): for each notification category the product defines — Approvals · Mentions & comments · Assignments · Status changes · Announcements · System/maintenance · Digests — a row that expands to per-channel toggles, or a simple on/off with a channel summary ("Push, Email").
   - **Digest:** "Daily summary" toggle + time (value row); "Bundle low-priority notifications" toggle.
   - **Quiet hours:** toggle + start/end time (value rows) + "Allow critical alerts during quiet hours" toggle (for monitoring/K3 apps).
   - **Sound & vibration:** notification sound (value row), vibrate (toggle) — where the OS allows app-level control.
4. **Component Hierarchy** — G's + `AmdsSettingRow.toggle/master`, `PermissionBlockedRow` (conditional), `ChannelToggleList`, `CategoryRow (expandable → per-channel AmdsSwitchTile)`, `AmdsSettingRow.value(digestTime, quietStart, quietEnd, sound)`.
5. **Information Architecture** — master → channels (broad) → categories (specific) → timing (digest, quiet hours). A category off wins over a channel on. The user should be able to answer "will I get pinged for X?" from this screen. Critical/safety categories may be **non-disableable** (or require an extra confirm) in monitoring/K3 apps — say so.
6. **User Flow** — G's. `toggle a category off → applied immediately (server-synced) + optimistic + revert on failure `. `master off → all rows disabled with "Notifications are off" `. `OS permission denied → the master row deep-links to the app's OS notification settings `. `set quiet hours → time pickers → applied; "critical alerts" sub-toggle appears`.
7. **States** — G's. Deltas:
   - **Loading:** rows show current values from a cached settings payload immediately; a subtle sync indicator while confirming with the server.
   - **Empty:** N/A.
   - **Success:** toggles reflect state; a confirming Snackbar for bigger changes ("You'll no longer get push for status changes").
   - **Error:** a toggle that fails to persist → **revert** + "Couldn't update — try again". Never show a state that didn't save.
   - **Offline:** changes apply optimistically + **queue**; a "Changes will sync when you're back online" note; on reconnect, sync + reconcile (server wins on conflict, tell the user if their change was overridden).
8. **Accessibility** — G's. Each toggle `role=switch` + the category/channel name + state. The permission-blocked row clearly explains the situation and the "Open settings" action. Category rows that expand announce `aria-expanded` + reveal per-channel toggles. Quiet-hours times announced. Non-disableable safety categories explain why ("Safety alerts can't be turned off"). Changes announced.
9. **Animations** — G's. Category row expand (250ms height + fade, chevron rotate). Toggle thumb slide. Master-off: rows fade to disabled 150ms. Reduced-motion: instant expand.
10. **Dark Mode** — G's. Switch on-track green-400; permission-blocked row uses `warningContainer`; disabled (master-off) rows at reduced opacity but labels still ≥4.5:1.
11. **Tablet** — G's landscape two-pane (settings groups left, this list right); the category matrix (categories × channels) can render as a compact grid on tablet instead of expandable rows.
12. **Developer Notes** — **all:** settings model = `{ masterEnabled, channels{push,email,inApp,sms}, categories{ <cat>: { enabled, channels[] } }, digest{enabled,time}, quietHours{enabled,start,end,allowCritical}, sound }` via `GET/PATCH /me/notification-settings` (optimistic + revert). The **OS push permission** is separate — check it (`Permission.notification` / `UNUserNotificationCenter` / `messaging().requestPermission`) and, if denied, show the blocked row → `openAppSettings()`. Server enforces the matrix when dispatching (a category+channel both-on is required to send). Critical categories: a `mandatory: true` flag renders them locked. Quiet hours evaluated server-side in the user's timezone; critical alerts bypass when `allowCritical`. Register/refresh the push token on master-on. **Compose/Flutter/RN:** `AmdsSettingRow` + a `notificationSettingsController`; `permission_handler` / `react-native-permissions`.
13. **UX Best Practices** — let users kill noise per category, not just globally. Category-off beats channel-on. Make "will I get pinged for X?" answerable here. Handle OS-permission-denied explicitly with a deep link. Optimistic + revert, never a false state. Quiet hours in the user's timezone. Safety/critical categories locked (or extra-confirmed) in monitoring/K3 apps, with an explanation.

---

## 9.4 Security Settings

**Archetype:** G · **Route:** `/settings/security`

1. **Purpose** — manage account security: password, biometrics, two-factor, active sessions/devices, and (guarded) account deletion.
2. **User Goal** — "Lock the app down the way I want — biometrics, 2FA — and see/revoke where I'm signed in."
3. **Layout** — G's grouped list:
   - **Sign-in:** "Change password" (navigation → §08.3, shows "Last changed 3 months ago") · "Biometric unlock" (toggle — Face ID / fingerprint; requires a successful biometric check to enable) · "Require unlock" (value: Immediately / After 1 min / After 5 min / On app switch).
   - **Two-factor authentication:** status row ("On — Authenticator app" / "Off") → setup/manage flow (add authenticator, backup codes, add/remove phone). Enabling 2FA is its own guided flow; disabling requires re-auth.
   - **Active sessions:** a list of current sessions — device, location (approx), last active, "This device" tag — each with "Sign out" ; "Sign out all other devices" action.
   - **Recent security activity:** last logins, password changes, 2FA changes (link → a fuller audit / §05.3-style history).
   - **Advanced:** "App lock with device passcode" toggle · "Hide sensitive content in app switcher" toggle · "Screenshot warning / block" (per policy).
   - **Danger zone:** "Delete account" (navigation → a guarded multi-step flow; `danger`, last).
4. **Component Hierarchy** — G's + `AmdsSettingRow.navigation(changePassword, twoFactor, deleteAccount)`, `AmdsSwitchTile(biometric, appLock, hideInSwitcher)`, `AmdsSettingRow.value(requireUnlock)`, `SessionList(SessionRow + AmdsButton "Sign out")`, `SecurityActivityList`.
5. **Information Architecture** — most-impactful first (password, biometrics, 2FA), then visibility (sessions, activity), then advanced, then the danger zone (isolated, styled, last). Every security state is shown explicitly ("2FA: Off", "Biometric unlock: On", "5 active sessions").
6. **User Flow** — G's + re-auth gates:
   ```
   enable "Biometric unlock" → system biometric prompt → success → enabled (stores the refresh token behind biometrics)
   "Two-factor" → guided setup (QR + verify code + save backup codes) → status → On
   disable 2FA / delete account / change require-unlock → re-authenticate (password or biometric) first
   "Sign out" a session → confirm → that device's tokens revoked → row drops
   "Sign out all other devices" → confirm → all but this device revoked → Snackbar
   "Delete account" → multi-step guarded flow: explain consequences → type "DELETE" / your email → re-auth → final confirm → account scheduled for deletion (grace period) → signed out
   ```
7. **States** — G's. Deltas:
   - **Loading:** toggles from local/secure state instantly; sessions list + security activity load (skeleton rows); 2FA status from the server.
   - **Empty:** "No other active sessions" (just this device); "No recent security activity".
   - **Success:** each control reflects state; sensitive changes show a confirming Snackbar + write to security activity.
   - **Error:** biometric enable fails (hardware/lockout) → toggle stays off + message; 2FA verify code wrong → inline; session revoke fails → row stays + Retry; re-auth fails → the gated action is cancelled.
   - **Offline:** biometric toggle + require-unlock + app-lock work locally (they gate local access). 2FA changes, session management, account deletion, and "sign out other devices" are **online-only** — disabled with "Connect to manage this".
8. **Accessibility** — G's. Every security state announced ("Two-factor authentication, off", "Biometric unlock, on"). Biometric enable uses the system prompt (already accessible). Session rows = grouped stops ("iPhone 14, Jakarta, last active 2 hours ago, this device") with a labelled "Sign out {device}" action. Re-auth prompts are standard. The delete-account flow's typed confirmation field is labelled; each step's consequence is announced; the final action's default focus is Cancel. Danger-zone section clearly labelled.
9. **Animations** — G's. Toggle slides; session row revoke = collapse + fade; 2FA status crossfades on change; delete-account steps use shared-axis X. Reduced-motion respected.
10. **Dark Mode** — G's. "Sign out" / "Delete account" text `danger` -400; danger-zone section may sit on a faint `dangerContainer` tint; session "this device" tag uses `primaryContainer`; 2FA "On" chip green-400.
11. **Tablet** — G's landscape two-pane (groups left, security list right); the sessions list gets more width (add the IP/user-agent detail column). Delete-account flow stays a centered focused sequence.
12. **Developer Notes** — **all:** biometric = `local_auth` / `BiometricPrompt` / `react-native-keychain` (`accessControl`) — enabling stores the refresh token in the secure enclave gated by biometrics; the app-lock timer gates re-prompt. 2FA: TOTP (`otpauth://` QR) + server verify + one-time backup codes (shown once, downloadable/copyable); disabling requires step-up auth. Sessions: `GET /me/sessions`, `DELETE /me/sessions/:id`, `POST /me/sessions/revoke-others` — each maps to token revocation. Security activity: read model over the auth audit log. **Delete account:** never a single dialog — a dedicated route with consequence disclosure, typed confirmation, step-up re-auth, a **grace/undo period** server-side, then sign-out; often "deactivate + schedule purge" per data-retention law. "Hide in app switcher" = `FLAG_SECURE` (Android) / blur the snapshot (iOS `sceneDidEnterBackground`). **Compose/Flutter/RN:** `AmdsSettingRow` + a `securityController`; step-up auth wrapper for gated actions.
13. **UX Best Practices** — show every security state explicitly. Gate sensitive changes behind re-auth. Enabling biometrics/2FA is guided; backup codes shown once and saved. Sessions list is honest (device, location, last active) with easy revoke. Danger zone isolated, styled, last. Account deletion is a deliberate multi-step flow with a grace period, not a dialog. Online-only for anything that changes server-side auth state.

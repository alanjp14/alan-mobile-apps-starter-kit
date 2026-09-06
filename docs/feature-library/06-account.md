# Feature Library · 06 · Account

> Foundation: AMDS v1.0 · Inherits [`00-framework.md`](00-framework.md). Features: **Settings · Profile**.

---

## Feature: Settings

### 1. Purpose
Let a user configure app behavior — general (language, region, data), appearance (theme, text size, density), notifications (categories, channels, quiet hours), and security (password, biometrics, 2FA, sessions) — with changes applied immediately, some stored locally on the device and some synced to the account so they follow the user across devices.

### 2. Business Flow
1. **Read** — on launch the app loads device-local prefs (theme, text scale, density, language) instantly and, in the background, the account-synced settings (`GET /me/preferences`, `/me/notification-settings`) reconciling any conflicts (server-wins with a notice, or last-write-wins per field).
2. **Change (local)** — appearance and some general prefs are device-scoped: applied live, persisted locally, never leave the device.
3. **Change (synced)** — notification preferences, default landing screen, language (optionally), and privacy toggles are account-scoped: applied optimistically, PATCHed to the server, reverted on failure, and pushed to other devices via a realtime `settings.updated` event or reconciled on next launch.
4. **Security actions** — password change, biometric enable, 2FA setup, session revocation route into the Authentication feature's flows (with step-up re-auth).
5. **Danger zone** — sign out (clears local state), delete account (a guarded multi-step flow with a grace period).
6. **Compliance** — analytics/crash toggles gate SDK data collection at runtime; consent state is recorded.

### 3. UX Flow
```
Profile / Nav → Settings hub → group (General / Appearance / Notifications / Security / About / Help)
  toggle → applies instantly (async ones: inline spinner + revert on fail)
  value row → picker sheet/dialog → applied
  navigation row → sub-screen
  Appearance: System/Light/Dark segmented → root crossfade 200ms; text-size + density with live preview
  Notifications: master + channels + per-category + quiet hours (→ Notifications feature §03)
  Security: change password / biometrics / 2FA / sessions (→ Auth feature §01) — step-up gated
  Danger: Sign out (confirm) · Delete account (guarded flow)
```
Screens: [`../screen-library/09-settings.md`](../screen-library/09-settings.md).

### 4. Screen Mapping
| Screen | Route | Template |
|---|---|---|
| Settings hub | `/settings` | Archetype G (nav list) |
| General Settings | `/settings/general` | 09 §9.1 |
| Theme / Appearance | `/settings/appearance` | 09 §9.2 |
| Notification Settings | `/settings/notifications` | 09 §9.3 |
| Security Settings | `/settings/security` | 09 §9.4 |
| About | `/about` | 10 §10.3 |
| Delete account | `/settings/security/delete-account` | guarded flow (Archetype E + F + step-up) |

### 5. Required Components
Settings rows (`toggle` / `value` / `navigation` / `action`) — `AmdsSettingRow` [16 §component G] · Switch [component-lib B6] · Segmented (theme, density) · Bottom Sheet / Dialog (pickers) [16 §6,7](../component-library/api-reference.md) · Slider (text size) · Banner (permission blocked) · Theme preview card · Dialog (F, destructive). Feature composites: `AmdsSettingRow`, `ThemePreviewCard`, `PermissionBlockedRow`.

### 6. Database / Store Suggestions
| Store | Contents | Notes |
|---|---|---|
| **Device-local** (`shared_preferences` / DataStore / MMKV / UserDefaults) | `themeMode, textScale, density, boldText, highContrast, language?, wifiOnlyDownloads, lastRoute` | never synced |
| `user_preference` (OLTP) | `user_id, key, value (jsonb), updated_at` (or a typed `user_settings` row) — `defaultLandingScreen, language, timezone, region, analyticsConsent, crashConsent` | account-synced |
| `user_notification_settings` | (see [`03-notifications.md`](03-notifications.md)) — master, channels, categories, quietHours, digest, sound | account-synced |
| `consent_record` | `user_id, purpose (analytics/crash/marketing), granted, version, at, ip` | append-only, for compliance |
| `account_deletion_request` | `user_id, requested_at, scheduled_purge_at, status (pending/cancelled/purged), reason` | grace period |

### 7. API Endpoint Suggestions
| Method · Path | Purpose | AuthZ |
|---|---|---|
| `GET /v1/me/preferences` | account-synced settings | self |
| `PATCH /v1/me/preferences` | update changed keys (optimistic) | self |
| `GET/PATCH /v1/me/notification-settings` | (Notifications feature) | self |
| `POST /v1/me/consent` | record analytics/crash/marketing consent `{purpose, granted, version}` | self |
| `POST /v1/me/password` · `GET/POST/DELETE /v1/me/mfa` · `GET/DELETE /v1/me/sessions` | (Auth feature) | self (step-up) |
| `POST /v1/me/account-deletion` | request deletion (starts grace period) → signs out | self (step-up) |
| `DELETE /v1/me/account-deletion` | cancel within grace | self |
| `GET /v1/app/config` | remote config: min supported version, feature flags, legal doc versions | authenticated |
| `POST /v1/me/data-export` | GDPR "download my data" request → async → notification | self |
| **Realtime**: `settings.updated` (multi-device sync) | — | — |

### 8. State Management Suggestions
- `themeControllerProvider` — `{ mode, textScale (clamped 0.85–2.0), density, boldText, highContrast }`, backed by device-local storage, drives `MaterialApp`/root theme + a `MediaQuery` wrapper; changes apply synchronously.
- `preferencesController` — account-synced settings; **optimistic + revert**; subscribes to `settings.updated` to reconcile from other devices.
- `notificationSettingsController` — as [`03-notifications.md`](03-notifications.md).
- `consentController` — reads current consent, writes on change, toggles the analytics/crash SDKs at runtime.
- `appConfigProvider` — remote config (min version → a "please update" gate; feature flags; legal doc versions → an "accept updated terms" prompt).
- No global "Save" — every control commits on change.

### 9. Jetpack Compose Implementation Suggestions
- `:feature:settings`. `LazyColumn` of `AmdsSettingRow`s; `ModalBottomSheet` pickers. DataStore (Proto or Preferences) for local; a `SettingsRepository` for synced.
- Theme hoisted to the Activity: `AmdsTheme(darkTheme = mode.resolve(), textScale = ...)`; recompose on change; `AppCompatDelegate.setApplicationLocales(...)` for per-app language (Android 13+) or a `LocalConfiguration` override.
- Analytics gating: a thin `AnalyticsClient` interface with a no-op impl swapped when consent is off.
- Delete account: a dedicated nav graph with step-up (`BiometricPrompt`/password) + typed confirmation.

### 10. Flutter Implementation Suggestions
- `feature_settings`. `ListView` of `AmdsSettingRow`; `showModalBottomSheet`/`showDialog` pickers. `shared_preferences` (or `hive`) local; a `SettingsRepository` (dio) synced.
- `themeControllerProvider` (Riverpod) → `MaterialApp(themeMode:, builder: (ctx, child) => MediaQuery(data: mq.copyWith(textScaler: TextScaler.linear(scale.clamp(0.85, 2.0))), child: child!))`.
- Language: `flutter_localizations` `Locale` override in a provider; rebuild `MaterialApp`.
- Consent: `firebase_analytics`/`sentry` `setEnabled(false)` when off.
- `appConfigProvider` polled on resume; a blocking `UpdateRequiredScreen` when below min version.

### 11. React Native Implementation Suggestions
- `features/settings`. `SectionList` of rows; `@gorhom/bottom-sheet` pickers. MMKV/`AsyncStorage` local; a settings API + React Query synced.
- `ThemeProvider` reads a Zustand `useSettingsStore` (`mode`, `textScale`, `density`); wrap the app so a change re-renders; `Appearance` listener for `System`.
- Text scale: pass into the theme + optionally set `Text.defaultProps.maxFontSizeMultiplier`.
- Language: `i18next.changeLanguage`; `I18nManager.forceRTL` on RTL locales (requires reload — warn the user).
- Consent: guard analytics/`Sentry.init` on the stored consent flag; `react-native-device-info` + a remote-config check for min version.

### 12. Security Considerations
- **Local vs synced boundary** — never sync device-security-relevant local prefs; never store secrets in prefs. Synced preferences contain no sensitive data (they're behavioral).
- **Step-up for security changes** — password, MFA, session revocation, and account deletion all require fresh re-authentication (biometric or password), independent of the current session age.
- **Account deletion** — a request, not an instant action: a **grace period** (e.g. 14–30 days) during which the user can cancel by signing in; after that a purge job soft-then-hard deletes/anonymizes, honoring legal hold; audit rows keep a tombstoned actor id for integrity. Confirm with typed input + step-up.
- **Consent integrity** — `consent_record` is append-only with the policy version; changing a toggle immediately halts the corresponding SDK's collection; default states follow your privacy stance + regional law (opt-in in the EU).
- **Data export (GDPR)** — an authenticated, async, rate-limited request; the export is scoped to the requester's own data; delivered as a secure expiring link; the export itself is logged.
- **Remote config** — signed/authenticated; a compromised config channel could disable security features, so validate ranges and never let remote config *lower* security minimums.
- **Screenshot / app-switcher** — Security Settings screens set `FLAG_SECURE` / blur on background.

### 13. Scalability Considerations
- Device-local settings have **zero backend cost** — prefer local for anything that doesn't need to follow the user.
- `user_preference` is tiny and read-once-per-session — cache with the session; `PATCH` is low-volume.
- `settings.updated` realtime is optional; last-write-wins reconciliation on next launch is usually sufficient and cheaper.
- Remote `app/config` is served from a CDN/edge cache with a short TTL; one request per app launch/resume; ETag for cheap revalidation.
- Data-export and account-deletion are async jobs (potentially large) — queue + workers, per-user rate limits.
- Consent records append-only → partition by month if volume warrants; they're rarely queried except for audits.

---

## Feature: Profile

### 1. Purpose
The current user's own identity surface — view their details and account status, edit the attributes they're allowed to change (photo, personal contact info, pronouns, emergency contact), and reach account settings and sign-out. The self-service counterpart to admin User Management.

### 2. Business Flow
1. **View** — the app loads `GET /me` (identity + org placement + status + `editableFields`); HR-managed fields (name, title, department, employee id) are read-only and sourced from the system of record.
2. **Edit** — the user changes an editable field or their photo → validated → `PATCH /me` (only changed fields) → optimistic update + reconcile; photo goes through the File Upload feature.
3. **Directory presence** — the user's profile is what colleagues see in the directory, comments, activity, and approval chains (a subset, permission-filtered).
4. **Lifecycle reflection** — if HR deactivates or changes the user's role, Profile reflects it (status chip, permissions) on next load / realtime event.
5. **Offboarding** — on deactivation the profile becomes read-only; personal data is retained then purged per retention policy.

### 3. UX Flow
```
Bottom nav / app-bar avatar → My Profile (header: avatar, name, title, dept, status; contact rows with actions; quick stats; account links)
  → tap avatar → change photo (camera/library → crop → upload)
  → "Edit profile" → Edit Profile (editable fields + read-only HR fields with a note) → save → highlights
  → "Change password / Security" → Security Settings (§06 Settings / §01 Auth)
  → account links → Notification prefs / Appearance / Language / Help / About
  → "Sign out" → confirm → clears session → Login
```
Screens: [`../screen-library/08-profile.md`](../screen-library/08-profile.md).

### 4. Screen Mapping
| Screen | Route | Template |
|---|---|---|
| My Profile | `/profile` | 08 §8.1 (Archetype D, self variant) |
| Edit Profile | `/profile/edit` | 08 §8.2 (Archetype E) |
| Change Password | `/security/change-password` | 08 §8.3 (Archetype A + E) |
| Change photo | source sheet + crop modal | File Upload feature §05 |

### 5. Required Components
Profile Components (header / list-item / mini) [16 §16](../component-library/api-reference.md) · Avatar (+ status, editor) [16 §15](../component-library/api-reference.md) · List/ListTile (contact + nav rows) [16 §9](../component-library/api-reference.md) · Chip (status) [16 §14](../component-library/api-reference.md) · Form engine (edit) · Buttons · Bottom Sheet (photo source) · Dialog (sign out). Feature composites: `AmdsProfileHeader`, `ContactActionRow`, `AvatarEditor`.

### 6. Database Entity Suggestions
Reuses `user` (see [`01-identity.md`](01-identity.md) User Management §6) plus self-editable fields:

| Field / Entity | Notes |
|---|---|
| `user.display_name, pronouns, personal_phone_enc, personal_email, bio, avatar_attachment_id, timezone, language` | self-editable |
| `user_emergency_contact` | `user_id, name, relationship, phone_enc` (all-or-nothing) |
| `user.first_name, last_name, job_title, department_id, manager_id, employee_id, employment_type, start_date` | **read-only in-app**, `source = hris` |
| `user_field_history` | who-set-this-value (shared with User Management) |
| `avatar` | an `attachment` row (File Upload feature) with `parent_type = 'user_avatar'` |

### 7. API Endpoint Suggestions
| Method · Path | Purpose | AuthZ |
|---|---|---|
| `GET /v1/me` | identity + org + status + `permissions[]` + `editableFields[]` | self |
| `PATCH /v1/me` | update self-editable fields (`If-Match`); rejects HR-managed fields | self |
| `PUT /v1/me/avatar` | (via File Upload: `POST /attachments` → upload → `POST /me/avatar {attachmentId}`) → new URL | self |
| `DELETE /v1/me/avatar` | revert to initials | self |
| `GET /v1/me/emergency-contact` · `PUT …` | emergency contact (validated as a unit) | self |
| `GET /v1/me/activity?cursor=` | the user's own recent activity (for the profile) | self |
| `GET /v1/users/{id}` | a colleague's public profile (permission-filtered fields) | authenticated |
| `POST /v1/auth/logout` | sign out (Auth feature) | session |

### 8. State Management Suggestions
- `MyProfileController` — loads `GET /me` (shared with `SessionController.user` — one source; `SessionController` holds the canonical user, the profile screen observes it); holds `etag`.
- `EditProfileController` — the form engine over a `FormSchema` with `editable` flags derived from `/me` `editableFields`; async validation for phone/email format; emergency contact as a sub-group (all-or-nothing); draft autosave; PATCH changed fields; on success updates `SessionController.user`.
- `AvatarEditController` — integrates the `UploadManager` (File Upload feature); optimistic swap + revert; initials fallback from `display_name` + a deterministic color from `user.id`.
- Sign-out delegates to `SessionController.logout()`.
- Offline: profile serves from `SessionController.user` cache; edits queue (optimistic + "Pending sync"); photo upload queues.

### 9. Jetpack Compose Implementation Suggestions
- `:feature:profile`. Header = `AmdsProfileHeader`; contact rows use `url_launcher`-equivalent intents (`Intent.ACTION_DIAL`, `ACTION_SENDTO`, geo).
- Edit: the shared `FormEngine`; `bringIntoViewRequester` for first-error scroll.
- Avatar: `PickVisualMedia` / `TakePicture` → `image_cropper`-equivalent (`ucrop`) → `UploadManager` (WorkManager); `Coil` `AsyncImage` with an `InitialsPainter` fallback.
- `SessionManager.user` as `StateFlow` → the screen recomposes on any identity change.

### 10. Flutter Implementation Suggestions
- `feature_profile`. `AmdsProfileHeader` widget; contact actions via `url_launcher` (`tel:`, `mailto:`, `geo:`).
- Edit: `FormEngine(FormSchema)`; emergency contact `FormStep`/group; `Scrollable.ensureVisible` for errors.
- Avatar: `image_picker` + `image_cropper` → `uploadManagerProvider` → `PUT /me/avatar`; `CachedNetworkImage` with an initials `CircleAvatar` fallback.
- `sessionControllerProvider` exposes `user`; `MyProfile` is a `Consumer`.

### 11. React Native Implementation Suggestions
- `features/profile`. `<AmdsProfileHeader/>`; contact actions via `Linking.openURL('tel:…' | 'mailto:…' | maps)`.
- Edit: `react-hook-form` + `zod` from the schema; emergency contact group with a refine (all-or-nothing).
- Avatar: `react-native-image-picker` + a cropper → `UploadManager` → `POST /me/avatar`; `<FastImage/>` with an `<Initials/>` fallback (color from `user.id`).
- `useSessionStore(s => s.user)` for identity; profile re-renders on change.

### 12. Security Considerations
- **`editableFields` is advisory for UI; the server is authoritative** — `PATCH /me` rejects any attempt to change HR-managed fields regardless of the client (`source = hris` fields are immutable via the app).
- **PII minimization for colleague views** — `GET /users/{id}` returns a permission-filtered subset; personal phone/email/emergency contact are **never** exposed to other users (only work contact, and only if directory visibility allows).
- **Emergency contact / personal phone** — encrypted at rest (column-level), access-logged, excluded from search indexes and analytics; purged on account deletion.
- **Avatar uploads** go through the full File Upload pipeline (type sniffing, scan, EXIF strip, resize) — a profile photo is a common injection vector.
- **Self-service can't escalate** — Profile edits never touch roles, permissions, status, or org placement (those are User Management, admin-only).
- **Sign-out completeness** — clears secure storage (tokens), biometric-bound key material, all caches and drafts, deregisters the push token, and routes to Login; account switch does the same before loading the next identity.
- **Deactivated users** — the profile loads read-only; the app should already be signed out (deactivation revokes sessions), but if a stale session lingers, the next API call returns 401/403 → forced sign-out.

### 13. Scalability Considerations
- `GET /me` is called once per session (and on resume-after-a-while) — cache it with the session; it's small.
- Profile is a **read of `user`** which is already cached hot for permission checks (User Management §13) — no new hot path.
- Colleague profile views (`GET /users/{id}`) are cacheable per `(viewerRole, targetId)`; directory/org data changes rarely.
- Avatars served from CDN with long cache + content-hash URLs; thumbnail variants generated once.
- `user_field_history` grows with edits — partition by month with the rest of the audit data.
- No feature-specific scaling concern beyond User Management's — Profile is a thin self-scoped view over the same identity data.

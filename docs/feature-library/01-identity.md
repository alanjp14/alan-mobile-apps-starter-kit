# Feature Library · 01 · Identity & Access

> Foundation: AMDS v1.0 · Inherits [`00-framework.md`](00-framework.md). Features: **Authentication · User Management · Role Management**.

---

## Feature: Authentication

### 1. Purpose
Establish and maintain a trustworthy user session on a mobile device — sign-in (password + SSO + biometrics), MFA, session lifecycle (refresh, expiry, revocation), and account recovery — so every other feature can rely on a verified identity and a permission set.

### 2. Business Flow
1. **Provisioning** — an admin creates the user (User Management) → an invite email/SMS with a one-time link, or a temporary password with forced change.
2. **First sign-in** — user sets a password (meets policy), optionally enrolls MFA, optionally enables biometric unlock on the device.
3. **Daily sign-in** — biometric unlock (fast path) → or password → (if MFA) OTP/authenticator → session issued (access + refresh tokens) scoped to the user's tenant + roles.
4. **Session life** — access token auto-refreshes silently; the app locks after an inactivity timeout requiring biometric/password re-unlock; sensitive actions trigger step-up re-auth.
5. **Recovery** — forgot password → emailed reset link → set new password → optionally revoke other sessions.
6. **Termination** — user signs out, or an admin deactivates the account / revokes a device → all tokens invalidated; the device is signed out on next call.
7. **Compliance** — every auth event (login, failure, MFA, password change, lockout, revocation) is audited; anomalies (new device, impossible travel) raise alerts and may force step-up.

### 3. UX Flow
```
Splash → resolve session
  ├─ valid + unlocked → Dashboard
  ├─ valid + locked → Biometric/PIN unlock → Dashboard
  ├─ none, first run → Onboarding → Login
  └─ none → Login
Login → [email + password] or [biometric] or [SSO]
  → success ──────────────► (MFA on?) OTP Verification → Dashboard / pending deep link
  → "Forgot password?" → Forgot Password → (email) → Reset Password (deep link) → Login
  → "Register" (SaaS) → Register → OTP Verification → Dashboard
Session expiry mid-use → silent refresh → (fails) → save draft → Login → resume
Sensitive action → step-up (biometric/password/OTP) → proceed
```
Screen specs: [`../screen-library/01-authentication.md`](../screen-library/01-authentication.md).

### 4. Screen Mapping
| Screen | Route | Template |
|---|---|---|
| Splash | `/` | 01 §1.1 |
| Onboarding | `/onboarding` | 01 §1.2 |
| Login | `/login` | 01 §1.3 |
| Register | `/register` | 01 §1.4 |
| Forgot Password | `/forgot-password` | 01 §1.5 |
| Reset Password | `/reset-password?token=` | 01 §1.6 |
| OTP Verification | `/verify?channel=&context=` | 01 §1.7 |
| App-lock / unlock | modal | Archetype A |
| Step-up re-auth | modal (Archetype F + biometric) | 09 §9.4 |

### 5. Required Components
Inputs / Password Field / OTP input ([16 §3](../component-library/api-reference.md)) · Buttons ([16 §1](../component-library/api-reference.md)) · Banner (auth errors) · Dialog (step-up) · Snackbar · Loading indicators · Segmented (channel switch). Feature composites: `BiometricPromptLauncher`, `PasswordPolicyChecklist`, `OtpField`, `SsoButtonRow`, `SessionGuard` (router wrapper).

### 6. Database Entity Suggestions
| Entity | Key columns | Notes |
|---|---|---|
| `user` | `id, tenant_id, email (citext, unique per tenant), status (invited/active/deactivated/locked), email_verified_at, mfa_enabled, created_at…` | identity of record |
| `credential` | `id, user_id, type (password/webauthn), secret_hash (argon2id), algo, updated_at, must_change` | password history via `credential_history` (last N hashes) |
| `mfa_factor` | `id, user_id, type (totp/sms/email/backup_code), secret_enc, phone_enc, confirmed_at, last_used_at` | |
| `backup_code` | `id, user_id, code_hash, used_at` | one-time |
| `session` | `id, user_id, device_id, refresh_token_hash, issued_at, expires_at, last_seen_at, ip, user_agent, revoked_at` | one row per device |
| `device` | `id, user_id, platform, model, os_version, push_token, first_seen, trusted` | |
| `login_attempt` | `id, user_id?, email, ip, success, failure_reason, mfa_used, created_at` | drives lockout + anomaly detection |
| `password_reset_token` | `id, user_id, token_hash, expires_at, used_at` | single-use, 30–60 min |
| `invite` | `id, tenant_id, email, role_ids[], token_hash, expires_at, accepted_at, created_by` | |

Indexes: `user(tenant_id, email)`, `session(user_id, revoked_at)`, `login_attempt(email, created_at)`, `password_reset_token(token_hash)`.

### 7. API Endpoint Suggestions
| Method · Path | Purpose | AuthZ |
|---|---|---|
| `POST /v1/auth/login` | email+password → tokens or `mfa_required` | public, rate-limited |
| `POST /v1/auth/mfa/verify` | OTP/authenticator → tokens | short-lived `mfa_token` |
| `POST /v1/auth/refresh` | rotate refresh → new token pair | valid refresh token |
| `POST /v1/auth/logout` | revoke this session | session |
| `POST /v1/auth/logout-others` | revoke all other sessions | session (step-up) |
| `POST /v1/auth/forgot-password` | send reset link (always 200) | public, rate-limited |
| `POST /v1/auth/reset-password` | token + new password → optional session | reset token |
| `POST /v1/auth/register` | self-service signup (SaaS) | public, rate-limited |
| `POST /v1/auth/verify-email` / `/verify-phone` | confirm OTP | verify token |
| `POST /v1/auth/invite/accept` | invite token → set password | invite token |
| `POST /v1/me/password` | change password (verify current) | session (step-up) |
| `GET/POST/DELETE /v1/me/mfa` | manage MFA factors | session (step-up) |
| `GET /v1/me/sessions` · `DELETE /v1/me/sessions/{id}` | list / revoke devices | session |
| `POST /v1/auth/biometric/enable` | bind refresh token to device biometric | session + device attestation |
| `GET /v1/me` | current user + `permissions[]` + tenant | session |
| `POST /v1/auth/sso/{provider}/callback` | OIDC code exchange | provider |

### 8. State Management Suggestions
- **`SessionController`** (global): `{ status: bootstrapping|authenticated|locked|unauthenticated, user, permissions:Set<string>, tenantId, pendingDeepLink }`. Persists nothing but reads tokens from secure storage on boot; exposes `login`, `logout`, `refresh`, `lock`, `unlock`, `stepUp`.
- **Auth interceptor** on the HTTP client: attach bearer; on `401` → single-flight refresh → retry once → else `SessionController.logout(reason: expired)` (save drafts first via an app-level hook).
- **Router guard** reads `SessionController.status` → redirects to `/login` / `/verify` / unlock; stores the intended route.
- **App-lock timer**: a lifecycle observer; on background → record time; on foreground → if `now - bg > lockAfter` → `status = locked`.
- Login/OTP/reset screens each have a small form controller; no global state beyond `SessionController`.

### 9. Jetpack Compose Implementation Suggestions
- Module `:feature:auth` + `:core:session`. Hilt provides `AuthRepository`, `TokenStore` (EncryptedSharedPreferences), `SessionManager`.
- `SessionManager` exposes `StateFlow<SessionState>`; `MainActivity` collects it and `NavHost` picks the graph.
- Biometrics: `androidx.biometric:BiometricPrompt` (`BIOMETRIC_STRONG`); enabling stores the refresh token wrapped by a Keystore key that requires user auth.
- SSO/passkeys: `androidx.credentials` (`CredentialManager`) for password, passkey, and "Sign in with Google"; `AppAuth` for generic OIDC.
- OTP autofill: SMS Retriever API / `autofill` hints; a single `BasicTextField` with per-cell rendering.
- Auth interceptor: an OkHttp `Authenticator` + a `Mutex` for single-flight refresh.
- `FLAG_SECURE` on auth screens; `onStop` blur handled by Android's recents snapshot when `FLAG_SECURE`.

### 10. Flutter Implementation Suggestions
- Package `feature_auth` + `core_session`. `sessionControllerProvider` (Riverpod `AsyncNotifier<SessionState>`).
- `flutter_secure_storage` for tokens; `local_auth` for biometrics (`BiometricPrompt`/`FaceID`); enabling biometric unlock stores the refresh token behind `AndroidPromptInfo` / `IOSAuthMessages` gate.
- `dio` `InterceptorsWrapper` + `dio.lock()`/a `Completer` for single-flight refresh; `retry` on `401` once.
- OIDC SSO: `flutter_appauth`; passkeys via platform channels where needed.
- OTP: `pinput` + `smart_auth` (Android SMS) + `autofillHints: [AutofillHints.oneTimeCode]` (iOS).
- App-lock: `WidgetsBindingObserver` (`didChangeAppLifecycleState`) → timestamp → `SessionController.maybeLock()`.
- `go_router` `redirect` reads `sessionControllerProvider`; store `pendingDeepLink`.

### 11. React Native Implementation Suggestions
- Feature folder `features/auth` + a `SessionProvider` (Context) + Zustand `useSessionStore`.
- Tokens: `react-native-keychain` (`ACCESS_CONTROL.BIOMETRY_CURRENT_SET`, `ACCESSIBLE.WHEN_UNLOCKED`).
- Biometrics: `react-native-keychain` biometric access control (no separate prompt lib needed) or `react-native-biometrics` for a custom flow.
- SSO: `react-native-app-auth` (OIDC); Google/Apple native SDKs where required.
- HTTP: an `axios` instance with a request interceptor (bearer) + a response interceptor that queues 401s, runs one refresh, replays the queue.
- OTP: `react-native-otp-entry` / a hidden `TextInput` with `autoComplete="sms-otp"` (Android) + `textContentType="oneTimeCode"` (iOS).
- App-lock: `AppState` listener + a timestamp in memory/MMKV; `react-native-screens` + a `<PrivacyView/>` overlay on background for sensitive screens.
- Navigation guard: a root navigator that switches between `AuthStack` and `AppStack` on session status.

### 12. Security Considerations
- **Tokens**: access JWT 5–15 min, `aud`/`iss`/`tenant`/`sub`/`sid` claims, RS256; refresh tokens **rotating + single-use** with reuse-detection (a replayed refresh revokes the whole session family).
- **Password**: Argon2id, min length 12, block breached passwords (k-anonymity check), history (last 5), no forced periodic rotation unless policy demands.
- **MFA**: TOTP (RFC 6238), SMS as a fallback only (SIM-swap risk — flag it), 10 one-time backup codes shown once; require MFA for admin roles.
- **Brute force**: per-account + per-IP rate limits, exponential backoff, temporary lockout, CAPTCHA **only** as a last resort (and never asked of the AT flow — WCAG 3.3.8); generic error messages (no account-existence or which-field leak).
- **Biometric unlock** stores only the refresh token behind the enclave; a biometric change invalidates it (`ACCESS_CONTROL.BIOMETRY_CURRENT_SET`).
- **Device binding**: bind refresh tokens to a `device_id` + platform attestation (Play Integrity / DeviceCheck / App Attest); reject tokens presented from another device.
- **Reset links**: single-use, short TTL, invalidate on use, don't auto-login by default; same 200 response whether or not the account exists.
- **Session revocation** must be immediate — the access token's short TTL bounds the window; keep a revocation list / `sid` check in the gateway for high-security tenants.
- **Transport**: cert pinning + a remote pin-update channel; refuse to run on a rooted/jailbroken device for high-security tenants (configurable).
- **Client hygiene**: no tokens/PII in logs, crash reports, analytics, deep links; `FLAG_SECURE` + app-switcher blur on auth screens; clear everything on logout.
- **Audit**: every auth event with `traceId`, IP, device, geo; anomaly detection (new device, geo-velocity) → step-up or block + notify the user.

### 13. Scalability Considerations
- Auth service is stateless; JWT verification is local at the gateway (JWKS cached, rotated) → no per-request DB hit for authN.
- `permissions[]` resolved once at login and embedded (or cached in Redis, 60s TTL, invalidated on role change) — never recompute per request.
- Refresh + login are write-heavy spikes at shift-start: put `session`/`login_attempt` on a partitioned table (by month) + a write-optimized path; async the audit fan-out.
- SSO/OIDC: cache provider JWKS + discovery docs; circuit-break the provider.
- Rate-limit + lockout counters in Redis (atomic INCR + TTL), not the DB.
- SMS/email OTP via a queued provider with fallback vendors; cap sends per number/day.
- Multi-region: tokens verifiable in any region; session store replicated or region-pinned with a global revocation topic.
- Load target: model shift-start concurrency (e.g. thousands of logins in a 10-min window) and size accordingly.

---

## Feature: User Management

### 1. Purpose
Let administrators provision, view, edit, deactivate, and offboard user accounts and their organizational placement (department, manager, location, employment type) and access (role assignment) — the admin counterpart to Authentication.

### 2. Business Flow
1. **Create** — admin adds a user (identity + org + role) → invite sent OR temp password set → user appears as `invited`.
2. **Activate** — user accepts the invite / signs in → status `active`.
3. **Maintain** — admin edits attributes; some fields sync **from** an HRIS system of record (read-only in-app); role changes recompute effective permissions and may force token refresh.
4. **Lifecycle events** — leave of absence (`status = suspended`), role change (promotion/transfer), manager change.
5. **Offboard** — admin deactivates → immediate session revocation → data retained; a scheduled purge/anonymize runs per the retention policy (GDPR erasure).
6. **Bulk** — CSV import for onboarding cohorts; bulk role assignment; bulk resend-invite.
7. **Governance** — periodic access reviews (managers certify their reports' access); every change audited.

### 3. UX Flow
```
Dashboard/Nav "Users" → User List (search, filter by role/status/dept)
  → tap → User Detail (Overview / Activity / Permissions / Devices)
      → Edit → User Edit → save (role diff confirm) → Detail
      → Assign role → sheet (permission preview) → apply
      → overflow: Reset password · Resend invite · Deactivate · Manage devices · Delete (guarded)
  → FAB "Add user" → User Create → invite/temp-password → Detail (Invited)
  → selection mode → bulk: assign role · deactivate · resend invite · export
```
Screens: [`../screen-library/03-user-management.md`](../screen-library/03-user-management.md).

### 4. Screen Mapping
| Screen | Route | Template |
|---|---|---|
| User List | `/users` | 03 §3.1 (Archetype C) |
| User Detail | `/users/:id?tab=` | 03 §3.2 (D) |
| User Create | `/users/new` | 03 §3.3 (E) |
| User Edit | `/users/:id/edit` | 03 §3.4 (E) |
| Bulk import | `/users/import` | Archetype E (file + mapping + preview) |
| Deactivate / Delete | modal | Archetype F |

### 5. Required Components
List / ListTile ([16 §9 rows](../component-library/api-reference.md), Avatar [16 §15](../component-library/api-reference.md)) · Chips/Badges (status) [16 §14](../component-library/api-reference.md) · Search [16 §4](../component-library/api-reference.md) · Bottom Sheet (filters, role picker) [16 §6](../component-library/api-reference.md) · Form inputs / Dropdown / Entity picker [16 §3,5](../component-library/api-reference.md) · Dialog (F) [16 §7](../component-library/api-reference.md) · Timeline (activity/audit) [16 §17](../component-library/api-reference.md) · Table (permission matrix) [16 §9](../component-library/api-reference.md) · Profile Components [16 §16](../component-library/api-reference.md).

### 6. Database Entity Suggestions
| Entity | Key columns | Notes |
|---|---|---|
| `user` | (see Authentication) + `employee_id, first_name, last_name, display_name, job_title, department_id, manager_id, location_id, employment_type, start_date, source (local/hris), hris_synced_at` | |
| `user_role` | `user_id, role_id, scope (tenant/site:<id>/team:<id>), granted_by, granted_at, expires_at?` | scoped assignments |
| `department` / `location` | `id, tenant_id, name, parent_id` | org tree |
| `user_import_job` | `id, tenant_id, file_ref, status, total, processed, errors_ref, created_by` | bulk |
| `access_review` | `id, tenant_id, reviewer_id, subject_user_id, decision, comment, due_at, completed_at` | governance |
| `user_field_history` | `id, user_id, field, old_value, new_value, changed_by, changed_at` | who-set-this-value |

Indexes: `user(tenant_id, status)`, `user(tenant_id, department_id)`, `user_role(user_id)`, `user_role(role_id)`, trigram index on `display_name`, `email`.

### 7. API Endpoint Suggestions
| Method · Path | Purpose | AuthZ |
|---|---|---|
| `GET /v1/users?q=&filter[status]=&filter[role]=&filter[department]=&sort=&cursor=` | list | `users:read` |
| `GET /v1/users/{id}` | detail (+ `?expand=roles,devices,activity`) | `users:read` |
| `POST /v1/users` | create (`{identity, org, roleIds, invite:true}`) | `users:create` |
| `PATCH /v1/users/{id}` | update changed fields (`If-Match`) | `users:update` (field-level: HRIS fields rejected) |
| `POST /v1/users/{id}/deactivate` / `/reactivate` | lifecycle | `users:deactivate` |
| `DELETE /v1/users/{id}` | soft-delete → schedule purge | `users:delete` |
| `POST /v1/users/{id}/roles` · `DELETE /v1/users/{id}/roles/{roleId}` | assign/revoke (scoped) | `roles:assign` |
| `POST /v1/users/{id}/resend-invite` · `POST /v1/users/{id}/reset-password` | admin actions | `users:update` |
| `GET /v1/users/{id}/permissions` | effective permissions matrix | `users:read` |
| `GET /v1/users/{id}/devices` · `DELETE …/devices/{id}` | sessions | `users:manage-devices` |
| `POST /v1/users/import` (multipart) → `GET /v1/users/import/{jobId}` | bulk | `users:import` |
| `POST /v1/users/bulk` | `{op, userIds[], payload}` → per-item results | matching permission |

### 8. State Management Suggestions
- `UserListController` — `RecordListConfig` over `/users`; keyset paging; filter/sort in the query; selection set for bulk; invalidates on any user mutation.
- `UserDetailController` — loads `/users/{id}?expand=...`; holds `etag`; tab sub-states; optimistic updates for role assignment.
- `UserFormController` — the form engine (`FormSchema` with `editable` flags from `/users/{id}` `editableFields`); async email-uniqueness; draft autosave.
- A cached `rolesProvider` + `rolePermissionMapProvider` for the permission preview (computed client-side, authoritative server-side).
- Mutations use `Idempotency-Key`; on success, targeted cache invalidation (`users` list + that `user`); on 409 → conflict UI.

### 9. Jetpack Compose Implementation Suggestions
- `:feature:users`. Paging 3 + `LazyColumn` for the list; `SwipeToDismissBox` for row actions; a `SelectionState` in the VM.
- Detail: `HorizontalPager` tabs; the permission matrix as a `LazyColumn` of rows with a horizontally scrollable header.
- Forms: the shared `FormEngine`; `AutofillNode` not needed; `bringIntoViewRequester` for first-error scroll.
- Bulk import: `ActivityResultContracts.GetContent()` → parse with a background `WorkManager` job for large files (or server-side).

### 10. Flutter Implementation Suggestions
- `feature_users`. `PagedListView` + `RecordListConfig`; `Dismissible` swipe actions; `Riverpod` `NotifierProvider` for selection.
- Detail: `NestedScrollView` + `TabBar`/`TabBarView`; permission matrix via `DataTable2` (`data_table_2`).
- Forms: `FormEngine(FormSchema)`; `file_picker` for CSV import → preview table → confirm.
- Role assignment sheet: `showModalBottomSheet` + a `rolePermissionMapProvider` to render the live permission preview.

### 11. React Native Implementation Suggestions
- `features/users`. `FlashList` + React Query infinite; `Swipeable` (gesture-handler) row actions; selection in Zustand.
- Detail: `react-native-tab-view`; permission matrix as a horizontally-scrolling grid.
- Forms: `react-hook-form` + a `zod` schema generated from `FormSchema`.
- CSV import: `react-native-document-picker` → `papaparse` (or upload raw + server parse) → preview → confirm.

### 12. Security Considerations
- Every endpoint checks `tenant_id` match + the specific permission + (for scoped roles) that the actor may grant within that scope.
- **Privilege escalation guard**: a user cannot grant a role that exceeds their own permissions ("no self-elevation", "no granting admin unless admin").
- HRIS-sourced fields are server-rejected on PATCH regardless of the client.
- Deactivation triggers **immediate** session/token revocation for that user (revocation topic + short access-token TTL).
- PII (personal phone, emergency contact, salary if present) is field-level access-controlled and redacted in list/expand responses for callers without `pii:read`.
- Bulk operations are rate-limited and produce an audit event per affected user.
- Delete = soft-delete + a retention timer; hard purge anonymizes FKs (audit rows keep a tombstoned actor reference for legal integrity).
- CSV import: validate every row server-side; cap file size; scan for formula-injection on export; never trust client-parsed data.

### 13. Scalability Considerations
- The `user` table is read-hot (permission checks, pickers) — cache `user` + `user_role` in Redis keyed by `user_id`, invalidated on write; the gateway reads permissions from cache.
- Directory search: back it with a search index (OpenSearch/Elastic) synced via the outbox, not `ILIKE` on Postgres, once the directory exceeds ~50k.
- Bulk import/bulk ops run as queued jobs with progress; never inline on the request.
- Org-tree queries (all users under a department subtree) use a closure table or `ltree`, not recursive CTEs at request time for deep trees.
- Access reviews generate large fan-outs quarterly — schedule + batch + paginate the reviewer UI.
- Partition `user_field_history` / `audit_event` by month; archive > 24 months.

---

## Feature: Role Management

### 1. Purpose
Define the authorization model — roles, the permissions they grant, and how roles are assigned (globally or scoped to a site/team) — so access is consistent, least-privilege, reviewable, and changeable without code deploys.

### 2. Business Flow
1. **Model design** — a security owner defines **permissions** (fine-grained, `resource:action`, e.g. `work_order:approve`) as a fixed catalog shipped with each release, and **roles** (named bundles of permissions) which are tenant-configurable.
2. **Baseline roles** — every tenant starts with system roles (Admin, Manager, Member, Read-only, Auditor) that can be cloned but not deleted.
3. **Custom roles** — an admin creates a role, selects permissions (with a plain-language description + a "what this lets someone do" preview), saves.
4. **Assignment** — roles are assigned to users (User Management), optionally **scoped** ("Approver for Site EAST only") and optionally **time-bound** (temporary elevation with auto-expiry).
5. **Change management** — editing a role's permissions immediately affects every holder; the system shows the impact ("42 users affected") and requires confirmation; changes are audited and holders' sessions refresh their permission set.
6. **Review & attestation** — periodic reviews; unused roles/permissions flagged; separation-of-duties (SoD) rules prevent toxic combinations (e.g. "can create PO" + "can approve PO" for the same person).

### 3. UX Flow
```
Settings/Admin "Roles" → Role List (system + custom, holder counts)
  → tap → Role Detail: permissions grouped by resource (toggles), holder list, "what this allows" preview
      → Edit → toggle permissions → "42 users affected — apply?" → confirm → saved (audited)
      → clone → new custom role prefilled
  → FAB "New role" → Role Create (name, description, permission picker, SoD check) → save
Assign (from User Detail) → role picker + scope + expiry → permission preview → apply
```
Admin-only; reuses Archetypes C (list), D (detail), E (form), F (impact confirm).

### 4. Screen Mapping
| Screen | Route | Template |
|---|---|---|
| Role List | `/admin/roles` | Archetype C |
| Role Detail | `/admin/roles/:id` | Archetype D (Permissions tab = grouped toggle matrix; Holders tab = user list) |
| Role Create / Edit | `/admin/roles/new`, `/admin/roles/:id/edit` | Archetype E |
| Impact confirm | modal | Archetype F ("N users affected") |
| Assign role | bottom sheet (from User Detail) | 03 §3.2 |

### 5. Required Components
List/ListTile · Accordion (permission groups) [16 §Supplementary] · Checkbox/Switch [16 §3/component-library D4/D6] · Table/matrix [16 §9](../component-library/api-reference.md) · Dialog (F, impact) [16 §7](../component-library/api-reference.md) · Badge (holder count) [16 §14](../component-library/api-reference.md) · Banner (SoD violation) · Chips (scope) · Timeline (role change history) [16 §17](../component-library/api-reference.md).

### 6. Database Entity Suggestions
| Entity | Key columns | Notes |
|---|---|---|
| `permission` | `key (pk, e.g. work_order:approve), resource, action, description, category` | **code catalog**, seeded per release, not tenant-editable |
| `role` | `id, tenant_id (null = system), key, name, description, is_system, created_by, updated_at, version` | |
| `role_permission` | `role_id, permission_key` | the bundle |
| `user_role` | `user_id, role_id, scope, granted_by, granted_at, expires_at` | (also in User Mgmt) |
| `sod_rule` | `id, tenant_id, name, permission_a, permission_b, severity, action (warn/block)` | separation of duties |
| `role_change_event` | `id, role_id, actor_id, diff (jsonb), affected_user_count, created_at` | audit-linked |
| `permission_grant_cache` | materialized `user_id → permission_key[]` (or Redis) | resolution result |

### 7. API Endpoint Suggestions
| Method · Path | Purpose | AuthZ |
|---|---|---|
| `GET /v1/permissions` | the permission catalog (grouped) | `roles:read` |
| `GET /v1/roles?filter[type]=system\|custom&cursor=` | list + holder counts | `roles:read` |
| `GET /v1/roles/{id}` | detail (`?expand=permissions,holders`) | `roles:read` |
| `POST /v1/roles` | create custom role | `roles:create` |
| `PATCH /v1/roles/{id}` | update name/desc/permissions (`If-Match`) → returns `affectedUserCount` when `?dryRun=true` | `roles:update` |
| `POST /v1/roles/{id}/clone` | clone to a new custom role | `roles:create` |
| `DELETE /v1/roles/{id}` | delete custom role (blocked if holders > 0 unless `?reassignTo=`) | `roles:delete` |
| `GET /v1/roles/{id}/holders` | users with this role | `roles:read` |
| `GET /v1/sod-rules` · `POST /v1/sod/check` | list rules / validate a proposed assignment | `roles:read` |
| `GET /v1/users/{id}/effective-permissions` | resolved set + provenance (which role/scope) | `users:read` |

### 8. State Management Suggestions
- `roleListController` (Archetype C) + `roleDetailController` (D, holds `etag`).
- `roleEditController` — a permission-tree state (`Map<resource, Set<permissionKey>>`), a `dryRun` call on save intent → shows `affectedUserCount` + SoD warnings before the real `PATCH`.
- Global `permissionCatalogProvider` (cached long — changes only on app update) + `myPermissionsProvider` (from `SessionController`, refreshed on a `permissions_changed` push).
- **Permission checks in UI**: a `can(permission, scope?)` helper reading `SessionController.permissions`; gate widgets with it (hide, don't disable, unless a reason is shown).

### 9. Jetpack Compose Implementation Suggestions
- `:feature:admin-roles`. Permission matrix = `LazyColumn` of expandable `resource` sections (`AnimatedVisibility`) each with `Switch` rows; a sticky "N selected / N total" summary.
- `dryRun` result surfaced in an `AlertDialog` before commit.
- `can()` as a `@Composable` guard: `PermissionGate(permission = "roles:update") { EditButton() }`.

### 10. Flutter Implementation Suggestions
- `feature_admin_roles`. Matrix via `ExpansionPanelList` or a custom `AmdsAccordion` list with `SwitchListTile`s.
- `roleEditControllerProvider` computes the diff; a `dryRun` provider call powers the impact `AmdsDialog`.
- `PermissionGate` widget (`Consumer` reading `myPermissionsProvider`).

### 11. React Native Implementation Suggestions
- `features/adminRoles`. `SectionList` of resource groups with `Switch` rows; `useMemo` diff; React Query mutation with an `onMutate` that first calls `dryRun`.
- `usePermission('roles:update')` hook + a `<PermissionGate/>` component.

### 12. Security Considerations
- **Permissions are code, roles are config** — the client and server share the exact permission catalog per release; unknown permission keys are ignored (fail-closed).
- **Least privilege by default** — new roles start with zero permissions; system roles are immutable templates.
- **No privilege escalation** — an actor can only grant permissions they themselves hold; granting `roles:*` requires being an admin; scoped grants can't exceed the actor's scope.
- **Separation of Duties** — `sod_rule`s block (or warn on) toxic combinations at assignment time and in periodic scans; violations are alerted.
- **Immediate propagation** — a role edit publishes a `permissions_changed` event; holders' gateways drop cached permissions and the mobile app refreshes `myPermissions` (or forces a token refresh) so revoked access stops working within the access-token TTL.
- **Time-bound elevation** — temporary roles auto-expire server-side (a job), not just client-side.
- **Auditability** — every role create/edit/assign/revoke is an audit event with a full permission diff and the affected-user count; `effective-permissions` endpoint shows provenance for investigations.
- **Blast-radius control** — editing a widely-held role requires step-up auth + explicit confirmation of the affected count.

### 13. Scalability Considerations
- **Permission resolution** (`user → effective permissions`) is the hottest path: resolve at login into a compact claim or a Redis set (`perm:{userId}` , TTL 5–15 min), invalidate on `user_role` / `role_permission` change via the event bus. Never join `user_role → role_permission` per request.
- Cache the permission catalog on the client (immutable per app version) and at the edge.
- A role edit affecting 10k+ holders: don't rewrite 10k cache entries synchronously — publish one event, let gateways lazily re-resolve on next request (bounded by TTL) or bump a global `permissionsEpoch` that forces re-resolution.
- `role_change_event` / audit fan-out is async.
- SoD scans run as scheduled batch jobs over `user_role`, partitioned by tenant.
- For very large tenants, consider ABAC (attribute rules) alongside RBAC to avoid role explosion (a rule "site managers can approve WOs at their site" instead of one role per site).

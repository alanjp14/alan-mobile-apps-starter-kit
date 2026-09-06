# Security

> Part of the [starter template](README.md). Full platform library table: [`blueprint.md §14`](blueprint.md). Baseline + per-feature threats: [`../feature-library/00-framework.md §2.4`](../feature-library/00-framework.md) and each feature blueprint's §12.

---

## 1. Controls

| Area | Control |
|---|---|
| **Transport** | TLS 1.2+; **certificate pinning** (host + backup pin + a remote kill-switch); reject cleartext |
| **Tokens** | access JWT 5–15 min (RS256, `tenant`/`sub`/`sid` claims) + **rotating single-use refresh** with reuse-detection; stored in the secure enclave; never in prefs / logs / analytics / deep links |
| **At rest** | encrypted local DB (SQLCipher / Realm); secrets in Keystore / Keychain; `EncryptedSharedPreferences` / `flutter_secure_storage` / `react-native-keychain` |
| **App lock** | inactivity timeout → biometric / PIN re-unlock; **step-up re-auth** for sensitive actions (password, MFA, role changes, payments, delete) |
| **AuthZ** | **server is the authority** — the client `can(permission)` is UX only; every endpoint re-checks permission + tenant + record state; **no privilege escalation** (an actor can only grant what they hold) |
| **Device integrity** | Play Integrity / DeviceCheck / App Attest; bind refresh tokens to a `device_id`; optional root/jailbreak refusal for high-security tenants |
| **Screen privacy** | `FLAG_SECURE` + app-switcher blur on auth / PII screens; disable screenshots per policy |
| **Input / output** | validate both sides; parameterized queries; sanitize markdown; content-type sniffing on uploads (magic bytes); CSV-injection guard on exports |
| **Rate limiting** | auth, OTP, search, export, password reset — server-side + client backoff with jitter |
| **Deep links / URLs** | no tokens or sensitive ids in query strings; verified App Links / Universal Links only |
| **Dependencies** | pinned versions; SCA (Dependabot/Renovate + Snyk/OWASP); SBOM; no unmaintained libraries |
| **Secrets** | **none in the repo or app bundle**; injected at build (CI secrets) / fetched via authenticated remote config; repo scanned (gitleaks) in CI |
| **Privacy** | data minimization; explicit consent for analytics/crash/diagnostics; regional data residency; right-to-erasure via soft-delete → purge; documented data flows |
| **Offline** | encrypted cache; scoped working set; wipe on logout / deactivation / remote wipe; **T0 actions truly blocked offline** |
| **Monitoring** | audit every state-changing action ([`../feature-library/07-observability.md`](../feature-library/07-observability.md)); anomaly alerts (new device, geo-velocity, mass export) |
| **Accessible auth** | allow paste, password managers, biometrics; **no CAPTCHA / memory tests** in the auth path (WCAG 3.3.8) |

## 2. Authentication & session

- Sign-in: password + SSO (OIDC) + biometrics; MFA (TOTP; SMS as a flagged fallback; 10 one-time backup codes).
- Biometric unlock stores **only the refresh token** behind the enclave; a biometric change invalidates it (`BIOMETRY_CURRENT_SET`).
- Session revocation is **immediate** (short access-token TTL bounds the window; a `sid` revocation check at the gateway for high-security tenants).
- Reset links: single-use, short TTL, invalidate on use; the same 200 response whether or not the account exists.
- Generic errors — never leak account existence or which field was wrong.

Full flow: [`../feature-library/01-identity.md`](../feature-library/01-identity.md) (Authentication).

## 3. Platform

| | Compose | Flutter | React Native | SwiftUI |
|---|---|---|---|---|
| Biometric | `androidx.biometric` (`BIOMETRIC_STRONG`) | `local_auth` | `react-native-keychain` biometric access control | `LocalAuthentication` |
| Secure storage | `EncryptedSharedPreferences` + Keystore | `flutter_secure_storage` | `react-native-keychain` / `expo-secure-store` | Keychain Services |
| Cert pinning | OkHttp `CertificatePinner` | `dio` cert callback / native | `react-native-ssl-pinning` | `URLSessionDelegate` |
| Integrity | Play Integrity API + DeviceCheck (bridge) | `google_api_availability` + channels | `react-native-play-integrity` / `react-native-device-check` | `DCAppAttestService` |
| Screenshot block | `FLAG_SECURE` | `flutter_windowmanager` / `secure_application` | `react-native-screenshot-prevent` | `isSecureTextEntry` overlay / scene snapshot blur |
| Root/JB detect | `RootBeer` | `flutter_jailbreak_detection` | `jail-monkey` | a jailbreak-check library |

## 4. Do / Don't

**Do** — pin certs with a backup + kill-switch; short-lived access + rotating refresh with reuse-detection; step-up for sensitive actions; server-authoritative authZ; wipe on sign-out; audit everything; keep secrets out of the repo.
**Don't** — store tokens in plain prefs; trust the client's permission UI for authorization; queue T0 actions offline; put credentials/PII in logs/URLs/analytics; ship a CAPTCHA in the auth path; commit signing keys.

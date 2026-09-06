# Template · Authentication Flow — `[APP_NAME]`

> Archetype **A — Focused Task** ([framework](../../docs/screen-library/00-framework.md) §4.A). Full reference: [`../../docs/screen-library/01-authentication.md`](../../docs/screen-library/01-authentication.md). Feature: [`../../docs/feature-library/01-identity.md`](../../docs/feature-library/01-identity.md) + [`09-platform.md`](../../docs/feature-library/09-platform.md) (Session Management).
> Replace placeholders. No bottom nav on any auth screen. Implement all states per archetype A.

---

## Flow

```
Splash → resolve session
  ├─ valid + unlocked → Dashboard
  ├─ valid + locked  → Unlock (biometric/PIN) → Dashboard
  ├─ first run       → Onboarding → Login
  └─ none            → Login
Login → [email + password] | [biometric] | [SSO: "Continue with [provider]"]
  → success ─────────────────► (MFA on?) OTP Verification → Dashboard / pending deep link
  → "Forgot password?" → Forgot Password → (email) → Reset Password (deep link) → Login/Dashboard
  → "Register" ([COMPANY_NAME] SaaS only) → Register → OTP Verification → Dashboard
Session expiry mid-use → save drafts → "Session expired" → Sign in → resume exact screen
```

## Screens & routes

| Screen | Route | Key content |
|---|---|---|
| Splash | `/` | logo + subtle spinner; resolves + redirects; ≤3s hard cap; honors theme frame 1 |
| Onboarding | `/onboarding` | ≤4 pages from config; always Skip; "seen" per app version |
| Login | `/login` | `[tenant]` field? · email · password (reveal) · "Forgot password?" · "Sign in" (Large, full-width) · biometric button · "or" · SSO · "Register" |
| Register | `/register` | name · work email (async unique) · password + live checklist · consent checkbox (linked terms) · "Create account" |
| Forgot Password | `/forgot-password` | email · "Send reset link" → confirmation state (no account-existence leak) + resend cooldown |
| Reset Password | `/reset-password?token=` | validate token first · new password + checklist · "Set new password" → ✓ + "Continue" |
| OTP Verification | `/verify?channel=&context=` | masked destination + "Change" · 6-cell single-field input · auto-submit on 6th digit · "Resend" cooldown · "Try another way" |
| Unlock | `/lock` | biometric prompt / PIN; session still valid |

## Per-screen skeleton (Login shown)

```
[ App bar: none ]
[ centered, maxWidth 400, 16 margin ]
  [COMPANY_NAME] logo/wordmark
  ── fields (space.5 apart) ──
  AmdsTextField(email, keyboardType=email, autofill=username)
  AmdsPasswordField(autofill=current-password)  → TextLink "Forgot password?" (right-aligned)
  [ AmdsBanner(authError) ]   ← on failure
  AmdsButton(primary, Large, fullWidth, loading) "Sign in"
  AmdsButton(secondary) "Sign in with [Face ID / fingerprint]"   ← if enrolled
  Divider "or"
  AmdsButton(secondary) × SSO providers
  Row: "Don't have an account? " TextLink "Register"
```

## States
- **Loading:** button spinner on submit; biometric = system sheet.
- **Empty:** first field focused (or biometric offered first).
- **Success:** route forward (no success animation — it's a transition).
- **Error:** generic "Email or password is incorrect" (no field/account leak); lockout → wait-time; SSO fail → "Couldn't sign in with [provider]".
- **Offline:** banner "You're offline — connect to sign in"; submit disabled; biometric still works if the token is cached + valid.

## Accessibility
Single `heading` (title) per screen; fields visibly labelled + associated; `inputmode`/`autocomplete` set; errors announced; **never block paste / password managers / autofill / biometrics**; OTP field accepts a pasted full code + one-time-code autofill; reduced-motion → no shake, `dangerContainer` flash instead.

## Security (feature §12)
Access token 5–15min + rotating single-use refresh (reuse-detection); tokens in the secure enclave; biometric unlock stores only the refresh token; generic errors; rate-limit login/OTP/reset; reset link single-use + short TTL; `FLAG_SECURE` on auth screens; store `pendingDeepLink` and resume after auth.

## Developer notes
`SessionManager` owns `{ status, user, permissions, tenantId, pendingDeepLink }`; the router guard reads `status`. Auth interceptor: on 401 → single-flight refresh → retry once → else logout (save drafts first). **Compose:** `BiometricPrompt` + `androidx.credentials`. **Flutter:** `local_auth` + `flutter_appauth` + `AutofillGroup`. **RN:** `react-native-keychain` (biometric access control) + `react-native-app-auth`.

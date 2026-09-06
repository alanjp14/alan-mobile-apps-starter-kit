# Screen Library · 01 · Authentication

> Foundation: AMDS v1.0 · Archetype: **A — Focused Task** (framework §4.A) unless noted.
> Every screen inherits A's spec; entries below are **deltas + screen specifics**. Universal checklists: framework §6.

Screens: Splash · Onboarding · Login · Register · Forgot Password · Reset Password · OTP Verification

Flow map:
```
Splash ─► (first run) Onboarding ─► Login ◄──────────────┐
Splash ─► (has session) Dashboard                        │
Login ─► "Register" ─► Register ─► OTP Verification ─► Dashboard
Login ─► "Forgot password?" ─► Forgot Password ─► (email) ─► Reset Password (deep link) ─► Login/Dashboard
Login ─► (MFA on) ─► OTP Verification ─► Dashboard
```

---

## 1.1 Splash Screen

**Archetype:** A · **Route:** `/` (resolves and redirects)

1. **Purpose** — brand moment while the app boots, resolves session/auth, and prefetches the first screen's data. Not a screen the user waits at deliberately.
2. **User Goal** — "Open the app and land where I belong."
3. **Layout** — full-bleed `background`; centered logo (96–120) + optional wordmark; subtle circular indeterminate indicator lower third; app version `caption` at the very bottom (optional). No app bar, no interaction.
4. **Component Hierarchy** — `AmdsScaffold(bare)` → `Center(Column[Brand, AmdsSpinner])` → `Positioned(bottom, Text(version))`.
5. **Information Architecture** — zero content decisions; single responsibility: decide the next route.
6. **User Flow** — `native splash → Dart splash (only if session must resolve) → { valid session → Dashboard | first run → Onboarding | else → Login (with any pending deep link stored) }`. Hard cap ~3s → proceed to Login or Dashboard-skeleton regardless.
7. **States** — **Loading:** brand + spinner (the whole screen). **Empty/Success:** immediately routes. **Error:** boot fails with no network *and* no cache → route to a minimal retry screen ("Couldn't start — Try again"), never an infinite spinner. **Offline:** if a cached session exists → proceed to Dashboard (offline banner there); else retry screen.
8. **Accessibility** — announce "Loading {App name}" once (polite); the spinner is `aria-hidden` decoration; respect reduced-motion (spinner → slow opacity pulse); ensure the native splash → Dart splash handoff has no flash for screen-reader users either.
9. **Animations** — logo fade/scale-in 300ms `decelerate` on the Dart splash only; transition out = crossfade 200ms to the next route. Reduced-motion: instant.
10. **Dark Mode** — honor theme from the **first frame** (native splash has light/dark assets; Dart splash reads the stored theme before first paint). No white flash into a dark app.
11. **Tablet** — same, centered; logo may be slightly larger; no layout change.
12. **Developer Notes** — **Compose:** Android 12+ `SplashScreen` API + `installSplashScreen()`; keep the Activity's splash until the session check finishes (`setKeepOnScreenCondition`). **Flutter:** `flutter_native_splash` (gen light+dark) + an optional `SplashPage` that awaits `sessionController.restore()`. **RN:** `react-native-bootsplash`; hide after the navigation state resolves. All: do session restore + a lightweight prefetch of the landing route in parallel; store `pendingDeepLink` for post-auth resume.
13. **UX Best Practices** — <1.5s target. No taglines, carousels, or "tap to continue". Use the OS splash for frame 1. Fail to a retry screen, not a hang.

---

## 1.2 Onboarding

**Archetype:** A · **Route:** `/onboarding`

1. **Purpose** — orient first-time users to 3–4 core value props or required setup steps.
2. **User Goal** — "Quickly understand what this app does for me (or finish required setup) and get in."
3. **Layout** — horizontal pager; per page: illustration (top ~45%), title (`displaySmall`, centered), body (`bodyMedium` `textSecondary`, ≤2 lines, centered), page dots; footer: "Skip" (text, top-right) + "Next" / "Get started" (primary, bottom, full-width).
4. **Component Hierarchy** — `AmdsScaffold(bare)` → `Column[ Row(Skip), PageView(OnboardingPage × n), DotsIndicator, AmdsButton(primary) ]`. `OnboardingPage = Column[ ProgressiveImage, Text(title), Text(body) ]`.
5. **Information Architecture** — content from `app_config` (title/body/asset per page) so each product configures it; max 4 pages; last page's CTA enters the app or the first setup task.
6. **User Flow** — `swipe or Next advances → dots track → last page "Get started" → mark seen (per app version) → Login or Dashboard`. "Skip" any time → same destination, don't re-show after skip.
7. **States** — **Loading:** none (bundled assets) — if content is remote and unavailable, **skip straight to the app**. **Empty:** no pages configured → skip. **Success:** completes → app. **Error/Offline:** bundled assets always work; remote images fall back to a solid tinted placeholder.
8. **Accessibility** — each page is a labelled group; pager exposes "Page 2 of 4"; dots are decorative but the position is announced; **Skip** always reachable and clearly labelled; swipe has the Next button as the non-gesture equivalent; illustrations have concise `alt` or are decorative; reduced-motion → crossfade pages.
9. **Animations** — page slide follows the drag; parallax on the illustration (subtle, ≤8dp); dot scale on active. Reduced-motion: crossfade, no parallax.
10. **Dark Mode** — dark illustration variants (mandatory — no white-bg art); background `#020617`.
11. **Tablet** — landscape/large: **two-pane** — illustration left, text + controls right; portrait: same as phone with more vertical breathing room.
12. **Developer Notes** — **Compose:** `HorizontalPager` (foundation) + `PagerState`; persist "seen" in DataStore keyed by `versionCode`. **Flutter:** `PageView` + `SmoothPageIndicator`; `sharedPreferences` `onboarding_seen_v{n}`. **RN:** `react-native-pager-view` or a `FlatList` pager; `AsyncStorage`. Gate only if a step is truly required (permissions, workspace pick).
13. **UX Best Practices** — ≤4 pages; always skippable; don't gate the app unnecessarily; re-onboard only for major features via targeted coachmarks, not a full re-run.

---

## 1.3 Login

**Archetype:** A · **Route:** `/login`

1. **Purpose** — authenticate an existing user quickly and securely.
2. **User Goal** — "Get into my account with the least friction (ideally biometrics)."
3. **Layout** — logo/wordmark (top) · optional workspace/tenant field · Email/username field · Password field (reveal) · "Forgot password?" (text link, right-aligned under password) · primary "Sign in" (full-width) · biometric button (if enrolled) · divider "or" · SSO buttons (e.g. "Continue with Microsoft") · footer "Don't have an account? Register".
4. **Component Hierarchy** — A's hierarchy + `AmdsTextField(email)`, `AmdsPasswordField`, `TextLink(Forgot)`, `AmdsButton(primary "Sign in", loading)`, `AmdsButton(secondary, biometric)?`, `Divider("or")`, `AmdsButton(secondary) × SSO`, `Row(footer link)`, `AmdsBanner(authError)?`.
5. **Information Architecture** — identity + credential only; MFA is a **separate** next step (OTP screen). Tenant field only for multi-tenant products (remembered). Never combine with Register.
6. **User Flow** — `autofocus email (or offer biometrics first if enrolled) → fill → "Sign in" → validate → submit (button loading) → { success → resume pendingDeepLink or Dashboard | MFA required → OTP Verification | invalid → generic Banner + keep email | locked out → wait-time message | offline → Banner, disable submit }`. "Forgot password?" → Forgot Password. Footer → Register.
7. **States** — **Loading:** button spinner on submit; biometric prompt is a system sheet. **Empty:** first field focused. **Success:** route forward (no success animation — it's a transition). **Error:** generic "Email or password is incorrect" (no account-existence leak) in an inline Banner; lockout → "Try again in 5 minutes"; SSO failure → "Couldn't sign in with {provider}". **Offline:** Banner "You're offline — connect to sign in"; submit disabled; biometrics still work if the token is cached and valid.
8. **Accessibility** — A's baseline + `autocomplete="username"` / `"current-password"`; biometric button labelled ("Sign in with fingerprint/Face ID"); error Banner announced assertively on submit failure; "Stay signed in" checkbox (per policy) labelled; don't move focus away from the form on a failed attempt beyond the error.
9. **Animations** — A's set. Failed submit: shake (reduced-motion: `dangerContainer` flash). Biometric success → immediate crossfade to Dashboard.
10. **Dark Mode** — A's palette; SSO provider logos need dark-safe variants; biometric icon `#4ADE80` accent.
11. **Tablet** — A's two-pane in landscape (brand/value left, form right, max 420).
12. **Developer Notes** — **Compose:** `AutofillNode` + `Modifier.semantics { }`; `BiometricPrompt`; store tokens in `EncryptedSharedPreferences`/Keystore; `androidx.credentials` for passkeys/SSO where available. **Flutter:** `AutofillGroup` + `autofillHints: [username, password]`; `local_auth`; `flutter_secure_storage`; `flutter_appauth` for OIDC SSO. **RN:** `textContentType`/`autoComplete`; `react-native-keychain` (`accessControl: BIOMETRY_ANY`); `react-native-app-auth`. All: never log credentials; short-lived access token + refresh token; biometric unlocks the refresh token.
13. **UX Best Practices** — offer biometrics prominently once enrolled; never block paste; preserve email on error; generic auth errors; support deep-link continuation; rate-limit + say so; "Sign in" not "Login" (verb).

---

## 1.4 Register

**Archetype:** A · **Route:** `/register`

1. **Purpose** — create a new account (SaaS / self-service; many enterprise apps provision accounts and hide this).
2. **User Goal** — "Sign up fast with only what's essential and start using the app."
3. **Layout** — optional Stepper (multi-step) · Full name · Work email · Password (with **live requirements checklist**) · optional Company / invite code · consent checkbox with linked Terms & Privacy · primary "Create account" · footer "Already have an account? Sign in".
4. **Component Hierarchy** — A's + `AmdsTextField(name, email)`, `AmdsPasswordField` + `RequirementChecklist`, `AmdsTextField(inviteCode)?`, `AmdsCheckbox(consent, links)`, `AmdsButton(primary "Create account", loading)`, `AmdsStepper?`.
5. **Information Architecture** — minimize fields; defer anything not needed to start. Email uniqueness checked async. Consent is explicit, unchecked by default, real links.
6. **User Flow** — `fill → email format on blur, uniqueness async (helper spinner) → password checklist ticks live → consent → "Create account" → { success → OTP Verification (email/phone) or verification-pending screen or guided empty state | email taken → inline error + "Sign in instead?" | validation → focus first error } `. Footer → Login.
7. **States** — **Loading:** button spinner; async email check → helper spinner "Checking…". **Empty:** name field focused; checklist all-unmet (neutral, not error). **Success:** → OTP / verification-pending. **Error:** field-level (email taken, weak password); system error → Banner + Retry, keep input. **Offline:** Banner; submit disabled (registration needs the server).
8. **Accessibility** — A's baseline + password requirements as a **live checklist announced on change** (not a wall of errors); `autocomplete="new-password"`; consent checkbox required state announced; Terms/Privacy are real links opening readable views; stepper announces "Step 1 of 2".
9. **Animations** — checklist items tick with a 150ms check-draw; A's enter/error set; step advance = shared-axis X.
10. **Dark Mode** — A's palette; checklist met = `#4ADE80` check, unmet = `#64748B`.
11. **Tablet** — A's two-pane; multi-step can become steps-left / form-right inline.
12. **Developer Notes** — **all:** debounce email-uniqueness 500ms, cancel superseded; password rules shared with Reset Password (one validator). **Compose:** `derivedStateOf` for checklist. **Flutter:** a `PasswordPolicy` value object → checklist + strength. **RN:** `zod` schema drives both checklist and submit validation. Send verification token; don't sign the user in until verified (per policy).
13. **UX Best Practices** — fewest fields; requirements up front as a live checklist; never block paste; max length ≥64; keep valid input on failure; clear path to Login.

---

## 1.5 Forgot Password

**Archetype:** A · **Route:** `/forgot-password`

1. **Purpose** — let a user request a password reset via email (or SMS).
2. **User Goal** — "Start the reset and know a link is coming."
3. **Layout** — back to Login · brief instruction (`bodyMedium`) · Email field · primary "Send reset link" · after submit → **confirmation state**: ✓ icon, "Check your email", the address echoed, "Resend" (with cooldown timer), "Back to sign in".
4. **Component Hierarchy** — A's + `AmdsTextField(email)`, `AmdsButton(primary "Send reset link")` → then `Column[ SuccessIcon, Text, Text(email), AmdsButton(tertiary "Resend", countdown), TextLink("Back to sign in") ]`.
5. **Information Architecture** — one field, one action, then a terminal confirmation. **No account-existence leak** — same confirmation always.
6. **User Flow** — `enter email → "Send reset link" → (always) confirmation state → "Resend" disabled with visible countdown (e.g. 30s) → user opens the email → Reset Password deep link`. Rate-limited server-side; if hit, still show the confirmation but the resend cooldown is longer.
7. **States** — **Loading:** button spinner. **Empty:** email field focused. **Success:** confirmation state (regardless of whether the email exists). **Error:** only for malformed email (inline) or a hard system error (Banner + Retry) — never "no such account". **Offline:** Banner; submit disabled.
8. **Accessibility** — A's baseline; the confirmation state moves focus to its heading and is announced; "Resend" announces the remaining cooldown; the echoed email is readable; the whole confirmation is reachable by screen reader in order.
9. **Animations** — form → confirmation: crossfade + the ✓ draws in (250ms `spring`); A's field/error set otherwise. Reduced-motion: instant swap, static check.
10. **Dark Mode** — A's palette; success icon `#4ADE80`.
11. **Tablet** — A's centered column (max 420); no two-pane needed (too little content) but acceptable.
12. **Developer Notes** — **all:** the reset link is `https://…/reset-password?token=…` (App Link / Universal Link) opening screen 1.6; token is opaque, single-use, short-lived (e.g. 30–60 min). Resend cooldown enforced client (UX) **and** server (security). Don't include the email in analytics. **Compose/Flutter/RN:** a simple two-state screen (`RequestForm` | `Confirmation`) in one route.
13. **UX Best Practices** — identical confirmation always; visible resend countdown; expired/used link handled on the reset screen ("Request a new link"); plain language.

---

## 1.6 Reset Password

**Archetype:** A · **Route:** `/reset-password?token=…`

1. **Purpose** — set a new password from a valid reset link.
2. **User Goal** — "Choose a new password and get back in."
3. **Layout** — brief text · New password field (reveal) + **live requirements checklist** · (optional) Confirm password · primary "Set new password" · after success → ✓ "Password updated" + "Continue" (→ auto sign-in to Dashboard, or → Login).
4. **Component Hierarchy** — A's + `AmdsPasswordField(new)` + `RequirementChecklist`, `AmdsPasswordField(confirm)?`, `AmdsButton(primary)`, success `Column[✓, Text, AmdsButton("Continue")]`.
5. **Information Architecture** — the token (from the URL) is validated on screen entry; the form only appears if the token is valid. Password rules identical to Register.
6. **User Flow** — `open deep link → validate token → { valid → show form | expired/used/invalid → error state "This link has expired" + "Request a new link" → Forgot Password }`. `fill → checklist ticks → "Set new password" → success state → "Continue" → auto sign-in (revoke other sessions per policy) or Login`.
7. **States** — **Loading:** token validation spinner (brief, full-screen-ish). **Empty:** new-password field focused, checklist unmet (neutral). **Success:** "Password updated" + Continue; all other sessions optionally signed out with a note. **Error:** invalid/expired token → dedicated error state with "Request a new link"; weak password → inline; system error → Banner + Retry. **Offline:** Banner; submit disabled; token validation deferred until online.
8. **Accessibility** — A's baseline; token-error state has a clear heading + a single obvious action; checklist announced on change; `autocomplete="new-password"`; success announced; focus moves to "Continue".
9. **Animations** — token check → form: crossfade. Success: check-draw 250ms `spring`. A's error set. Reduced-motion: instant.
10. **Dark Mode** — A's palette; token-error uses `dangerContainer` icon + `bodyMedium`.
11. **Tablet** — A's centered column; token-error state centered.
12. **Developer Notes** — **all:** parse `token` from the deep link (`go_router` query param / `navDeepLink` / RN `linking`); validate server-side before rendering the form; on success the server invalidates the token and (per policy) other refresh tokens; then either return a session (auto sign-in) or route to Login. Handle the app-not-installed case (web fallback page). Reuse the `PasswordPolicy` validator.
13. **UX Best Practices** — validate the token before showing the form; expired-link path is first-class, not a generic error; identical rules to Register; auto sign-in is a nicety, Login is the safe default; tell the user if other sessions were ended.

---

## 1.7 OTP Verification

**Archetype:** A · **Route:** `/verify?channel=email|sms&context=register|mfa|action`

1. **Purpose** — verify possession of an email/phone (registration) or a second factor (login MFA, or a sensitive action step-up).
2. **User Goal** — "Enter the code I just received and continue."
3. **Layout** — title "Enter the code" · subtitle with the **masked destination** ("Sent to •••• 4821" / "j•••@acme.com") + "Change" link (context-dependent) · **6-cell OTP input** (single logical field) · inline error slot · "Resend code" with cooldown countdown · primary "Verify" (or auto-submit on the 6th digit) · optional "Try another way" (email ↔ SMS ↔ authenticator).
4. **Component Hierarchy** — A's + `Text(subtitle + Change link)`, `AmdsOtpInput(length: 6)`, `ErrorText?`, `AmdsButton(tertiary "Resend code", countdown)`, `AmdsButton(primary "Verify", loading)`, `TextLink("Try another way")?`.
5. **Information Architecture** — one code, one purpose. The destination is masked. Resend and channel-switch are secondary. The code length and TTL are shown or implied ("expires in 10 min").
6. **User Flow** — `arrive (from Login MFA / Register / step-up) → keyboard opens, first cell focused → type/paste code → auto-submit on last digit (or tap Verify) → { correct → continue to the original destination/action | wrong → clear cells, inline error "Incorrect code", shake, focus first cell | expired → "Code expired — resend" | too many attempts → lockout with wait time } `. "Resend" → new code, cooldown restarts, cells clear. "Change"/"Try another way" → back a step or a channel picker.
7. **States** — **Loading:** "Verify" spinner; auto-submit shows the spinner over the input. **Empty:** cells empty, first focused, Verify disabled until 6 digits. **Success:** brief ✓ then route forward. **Error:** "Incorrect code" (inline, cells clear, shake); "Code expired"; "Too many attempts — try again in N min". **Offline:** Banner; Verify + Resend disabled; code entry allowed (verified on reconnect).
8. **Accessibility** — the 6 cells are **one** logical field with an accessible name "Verification code" and current value announced ("3 of 6 digits entered"); supports **one-time-code autofill** and **pasting the full code**; `inputmode=numeric` / `oneTimeCode`; error announced assertively; "Resend" announces the countdown; auto-advance between cells must not trap or confuse screen-reader users (provide the single-field semantics); reduced-motion: no shake → `dangerContainer` flash + cells clear.
9. **Animations** — cell fill: digit scale-in 100ms; on error: row shake ±6dp ×3 / 300ms + cells clear (reduced-motion: flash). Success: ✓ 200ms then crossfade forward. Resend: cells wipe left→right 150ms.
10. **Dark Mode** — cell fill `#1E293B`, filled-cell border `#4ADE80`, empty-cell border `#334155`, error border red-400; caret `#4ADE80`.
11. **Tablet** — A's centered column; OTP cells sized comfortably (48–56 each) with `space.2` gaps; no two-pane.
12. **Developer Notes** — **Compose:** a custom `OtpTextField` backed by a single `TextFieldState`, `KeyboardOptions(keyboardType = NumberPassword, ...)`; SMS Retriever API / Autofill for auto-fill. **Flutter:** `pinput` or a custom widget over one `TextEditingController`; `smart_auth` / SMS autofill; `autofillHints: [oneTimeCode]`. **RN:** a single hidden `TextInput` with `textContentType="oneTimeCode"` / `autoComplete="sms-otp"` rendering 6 cell views. All: 6 digits, TTL ~10 min, max ~5 attempts, resend cooldown 30–60s (client + server), rotate the code on resend, never log it, verify the `context` so a code issued for MFA can't complete registration.
13. **UX Best Practices** — auto-submit on the last digit; support paste + OTP autofill (don't make users type what the OS can fill); mask the destination; visible resend countdown; offer a channel switch; clear, non-alarming errors; short TTL communicated.

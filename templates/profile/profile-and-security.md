# Template · Profile & Security — `[APP_NAME]`

> Archetypes **D — Detail** (self) · **E — Form** (edit) · **A — Focused Task** (change password). Full reference: [`../../docs/screen-library/08-profile.md`](../../docs/screen-library/08-profile.md), [`../../docs/screen-library/09-settings.md`](../../docs/screen-library/09-settings.md) §9.4. Feature: [`../../docs/feature-library/06-account.md`](../../docs/feature-library/06-account.md).

---

## Routes
`/profile` · `/profile/edit` · `/settings/security` · `/security/change-password`

## 1. My Profile

```
[ App bar: "Profile" / [USER_NAME] · Edit · overflow(Share card, Sign out) ]
[ Header: AmdsAvatar(xl, tap→change photo) · name (headingLarge) · [job title] · [department] · status chip ]
[ Contact rows: work email(→mail) · phone(→call) · location(→map) · manager(→profile) ]
[ Quick stats: [e.g. leave balance / assigned [DATA_NAME] count] → relevant list ]
[ Account links: Edit profile · Notification preferences · Security · Appearance · Language · Help · About · Sign out (danger, last) ]
[ App version · build (copyable) ]
```

HR-managed fields (name, title, department, employee id) are **read-only** with a "Managed by HR" note.

## 2. Edit Profile (`FormSchema`)

```
[ Top bar: X (dirty guard) · "Edit profile" · Save (dirty+valid) ]
[ Photo: preview + Change / Remove ]
[ Editable: preferred name · pronouns · personal phone · personal email · emergency contact (name+relationship+phone, all-or-nothing) · bio · language · timezone ]
[ Read-only (shown, disabled + reason): legal name · job title · department · employee ID · work email · manager ]
```

## 3. Security Settings

```
[ Sign-in: "Change password" (nav, "Last changed [date]") · "Biometric unlock" (toggle, requires a biometric check to enable) · "Require unlock" (value: Immediately / 1 min / 5 min / On app switch) ]
[ Two-factor: status → setup/manage flow (authenticator + backup codes) ]
[ Active sessions: device · location · last active · "This device" tag · "Sign out" per device · "Sign out all other devices" ]
[ Recent security activity → history ]
[ Advanced: "App lock with device passcode" · "Hide sensitive content in app switcher" ]
[ Danger zone (last): "Delete account" → guarded multi-step flow ]
```

Sensitive changes (disable 2FA, delete account, require-unlock) → **step-up re-auth** first.

## 4. Change Password

```
[ App bar: back · "Change password" ]
[ Banner: forced reason ]   ← if expiry / admin reset
[ Current password (reveal) → TextLink "Forgot your current password?" ]
[ New password (reveal) + live requirements checklist (length, classes, not-a-recent-reuse, not-your-name) ]
[ "Sign out other devices" toggle (default on for forced) ]
[ AmdsButton(primary, Large) "Update password" ]
→ ✓ "Password updated" (+ "signed out on N other devices") + "Done"
```

## States
Loading (field skeletons) · Empty (self: "Add phone number" affordances, not "—") · Success (→ My Profile, changed fields highlight, Snackbar) · Error (field-level; wrong current password → generic message on that field; 409 rare) · Offline (edits queue + "Pending sync"; **password change / 2FA / sessions / delete = online-only**).

## Accessibility
Name = `heading 1`. Avatar = labelled button "Change profile photo". Contact rows: "`[label]`, `[value]`" + separately labelled action. Read-only fields announced "read only, managed by HR". Every security state announced ("Two-factor authentication, off"). Delete-account typed-confirm field labelled; each step's consequence announced; final action default-focuses Cancel.

## Security
`editableFields` from `/me` is advisory — **the server rejects edits to HR-managed fields**. Sign-out fully clears tokens + biometric key material + caches + drafts + outbox + push registration. Account deletion = a request with a grace period + typed confirm + step-up, not an instant action. Personal phone / emergency contact encrypted at rest, access-logged, excluded from search + analytics.

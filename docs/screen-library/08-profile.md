# Screen Library · 08 · Profile

> Foundation: AMDS v1.0 · Archetypes: **D — Detail** (§4.D), **E — Form** (§4.E), **A — Focused Task** (§4.A).
> The current user's own identity, personal info, and account entry points. Distinct from **User Detail** (§03.2 — an admin viewing *someone else*).

Screens: My Profile · Edit Profile · Change Password

Flow map:
```
Bottom nav / App bar avatar ─► My Profile ─► "Edit profile" ─► Edit Profile ─► (save) My Profile
My Profile ─► "Security" / Settings ─► Change Password
My Profile ─► links: Notification preferences · Security · Help · Sign out (confirm)
```

---

## 8.1 My Profile

**Archetype:** D (self, editable) · **Route:** `/profile`

1. **Purpose** — show the signed-in user their own identity and personal info, reflect account status, and provide entry points to edit, to account settings, and to sign out.
2. **User Goal** — "Check my details are right, update my photo/contact info, or get to my settings / sign out."
3. **Layout** — D's skeleton (self variant):
   - App bar: "Profile" (or the user's name) · trailing "Edit" · overflow (Share contact card, Sign out).
   - **Header:** `AmdsAvatar(xl)` (tap → change-photo sheet) · name `headingLarge` · job title · department · **status chip** (Active / On leave / etc.) · "Employee since 2019".
   - **Contact rows** (label + value + action icon): work email (→ mail), phone (→ call), office/location (→ map), manager (→ their profile), team (→ team list). Personal contact info is editable but only shown to the user themselves.
   - **Sections / quick stats** (product-dependent): leave balance (HRIS), assigned assets count (Asset), open tasks (Ops) — each a card linking to the relevant list.
   - **Account links list:** Edit profile · Notification preferences · **Change password / Security** · Appearance/Theme · Language · Help & support · About · **Sign out** (`danger`, last).
   - App version `caption` at the bottom.
4. **Component Hierarchy** — D's + `AmdsProfileCard(header variant)`, `ContactRow × n (AmdsListTileX with trailing action)`, `StatCard × n?`, `SettingsLinkList (AmdsListTileX chevron rows + AmdsListTileX.action("Sign out", danger))`, `AmdsDialog.confirm(sign out)`.
5. **Information Architecture** — identity first (photo + name + role + status). Then the human facts (contact). Then account controls. HR-managed fields (name, title, department, employee id) are **read-only with a "Managed by HR" note**; the user can edit photo, personal phone, emergency contact, pronouns, bio, notification prefs, security, appearance.
6. **User Flow** — `open → review → { tap avatar → change photo (camera / library) → crop → upload | "Edit" → Edit Profile | "Change password / Security" → Change Password / Security Settings | "Sign out" → confirm dialog → clears session + biometric + caches → Login } `. Contact row actions launch the OS (mail/dialer/maps).
7. **States** — D's. Deltas:
   - **Loading:** `AmdsSkeletonDetail` — avatar circle + name/role bars + contact-row skeletons.
   - **Empty:** optional fields the user hasn't set → "Add phone number" / "Add a bio" affordances (not "—" for self, since they can fill them).
   - **Success:** full profile; edit affordances present; stats loaded.
   - **Error:** "Couldn't load your profile" + Retry; a failed stat card shows its own inline error.
   - **Offline:** cached profile shown fully "as of last sync"; "Edit" allowed (changes queue + sync, per §8.2); photo upload queues; contact-row OS actions still work.
8. **Accessibility** — D's. Name = `heading 1`. Avatar is a labelled **button** ("Change profile photo"). Contact rows announce "label, value" and the trailing action is separately labelled ("Call, +62…", "Email work address"). Status announced ("Status: On leave until 12 March"). "Sign out" is clearly labelled and its dialog default-focuses Cancel. Read-only fields announced as such with the reason. Account links = a navigable list with chevrons announced.
9. **Animations** — D's. Enter: fade. Avatar change: new image crossfades in after upload; a subtle ring pulse while uploading. Sign-out dialog per Archetype F. Reduced-motion: crossfades only.
10. **Dark Mode** — D's. Header may use a subtle tinted band (not a bright gradient); avatar gets a 1px `#334155` ring; status chip translucent + -100 text; "Sign out" row text `danger` -400; stat cards `#0F172A` + `#1E293B` border.
11. **Tablet** — Landscape: **two-pane** — profile summary + avatar left, the account-links list / selected settings pane right (this becomes the Settings master-detail entry). Portrait: max-640, contact rows two-column where labels are short.
12. **Developer Notes** — **all:** `GET /me` (or `/users/me`) → the same user model as User Detail but with `editableFields` scoped for self. Photo: pick (camera/library) → crop (square) → upload to the avatar service → optimistic local update + revert on failure; keep an initials fallback. Sign out: revoke the refresh token server-side, clear `flutter_secure_storage` / Keychain / EncryptedSharedPreferences, clear caches + drafts, cancel push registration, route to `/login`. Contact actions: `url_launcher` (`mailto:` / `tel:` / geo) / `Intent` / `Linking`. **Compose:** `AsyncImage` (Coil) + `BiometricPrompt` not needed here. **Flutter:** `image_picker` + `image_cropper`. **RN:** `react-native-image-picker` + a cropper.
13. **UX Best Practices** — identity first. For *self*, offer to fill empty optional fields rather than showing "—". HR-managed fields visibly read-only + why. Photo change is forgiving (crop, revert on fail, initials fallback). Sign out confirms and fully clears state. Don't bury Security/Change Password. Contact actions use the OS.

---

## 8.2 Edit Profile

**Archetype:** E · **Route:** `/profile/edit`

1. **Purpose** — let the user update the personal attributes they're allowed to change.
2. **User Goal** — "Fix my phone number / add a photo / update my emergency contact and save."
3. **Layout** — E's skeleton (full-screen modal), title "Edit profile":
   - Top bar: `X` (dirty-guard) · "Edit profile" · "Save" (trailing, primary, enabled when dirty + valid).
   - **Photo:** avatar preview + "Change photo" / "Remove photo".
   - **Editable sections:**
     - **Personal:** preferred name / pronouns · personal phone · personal email · emergency contact (name + relationship + phone) · bio / about.
     - **Preferences that belong to identity:** display language, time zone (may also live in Settings — pick one home and link).
   - **Read-only (shown, disabled, with a note):** legal name, job title, department, employee ID, work email, manager — "Managed by HR. Contact HR to change."
4. **Component Hierarchy** — E's + `AvatarEditor(preview, Change, Remove)`, `AmdsTextField × personal`, `AmdsDropdown(pronouns, language, timezone)`, `EmergencyContactGroup(name, relationship, phone)`, `AmdsReadOnlyField × HR-managed`, `AmdsButton("Save")`, discard `AmdsDialog.confirm`.
5. **Information Architecture** — clearly separate "what you can change" from "what HR controls". Group emergency contact as a labelled sub-group. Keep it short — this is not a giant form.
6. **User Flow** — E's. `open (populated) → change fields / photo → dirty → "Save" → validate (phone format, email format, emergency contact completeness) → PATCH changed fields → { success → My Profile, changed fields highlight, Snackbar "Profile updated" | validation → focus first error | 409 (rare) → resolution } `. Cancel on dirty → "Discard changes?". Photo changes can save immediately (optimistic) or with the form — pick one; recommended: photo saves on selection, other fields on "Save".
7. **States** — E's. Deltas:
   - **Loading:** field skeletons while `/me` + option lists load.
   - **Empty:** optional fields empty with helpful placeholders.
   - **Success:** → My Profile with highlights + Snackbar.
   - **Error:** field-level (invalid phone/email, incomplete emergency contact); photo upload failure → inline retry, doesn't block the form; system error → keep form + Retry.
   - **Offline:** Banner "changes will sync when you reconnect"; **queue the PATCH**; My Profile shows the new values optimistically with a subtle "Pending sync" indicator; photo upload queues.
8. **Accessibility** — E's. "Change photo" / "Remove photo" clearly labelled buttons; the avatar editor announces the current state. Read-only fields announced "read only, managed by HR". Emergency contact sub-group has a legend. Phone/email `inputmode` set. Errors anchored + announced; first-error focus on save. Dirty state announced when Save enables.
9. **Animations** — E's. Photo: crop sheet slides up; on confirm the avatar crossfades. Error slide-down. Save → pop + Snackbar. Reduced-motion: no shake → border + text + flash.
10. **Dark Mode** — E's form palette; avatar editor preview with `#334155` ring; read-only fields `textTertiary` + lock icon; emergency contact group card `surfaceVariant`.
11. **Tablet** — E's single column max-640 centered; landscape can show the avatar + preview on the left and the fields on the right.
12. **Developer Notes** — **all:** `PATCH /me { changedFields }`; `editableFields` from `/me` gates which inputs are enabled — **don't trust the client**, the server rejects edits to HR-managed fields. Photo: separate `PUT /me/avatar` (multipart) → returns the new URL; optimistic swap + revert. Emergency contact validated as a unit (all-or-nothing). Timezone/language changes may need an app-wide refresh (apply live where possible). Offline queue with an idempotency key; conflict check on sync. **Compose/Flutter/RN:** framework §5.2 E; `image_picker`/`react-native-image-picker`/Coil+crop.
13. **UX Best Practices** — short form, only editable fields prominent. HR-managed fields visibly read-only + how to change them. Photo editing forgiving. Save only when dirty + valid. Highlight changes on return. Offline: optimistic + queued + "Pending sync". Emergency contact is all-or-nothing.

---

## 8.3 Change Password

**Archetype:** A — Focused Task (with E-style validation) · **Route:** `/security/change-password` (reached from My Profile or Security Settings)

1. **Purpose** — let a signed-in user change their password, verifying their current one.
2. **User Goal** — "Set a new password (because it's expiring / I want to / I was told to) and stay signed in."
3. **Layout** — A's focused task:
   - App bar: back · "Change password".
   - Brief instruction; if forced (expiry / admin reset / policy) a `warning` Banner explains why and that it's required now.
   - **Current password** field (reveal) — with a "Forgot your current password?" link → sign out + Forgot Password flow.
   - **New password** field (reveal) + **live requirements checklist** (length, character classes, not-a-previous-password, not-your-name/email).
   - **Confirm new password** field (only if reveal isn't sufficient for the audience — otherwise omit).
   - Optional: "Sign out other devices" toggle (default on for forced changes).
   - Primary "Update password" (full-width).
   - On success → ✓ "Password updated" + "Done" (→ back to where they came from, or Dashboard if forced).
4. **Component Hierarchy** — A's + `AmdsBanner(forcedReason)?`, `AmdsPasswordField(current)` + `TextLink(forgot current)`, `AmdsPasswordField(new)` + `RequirementChecklist`, `AmdsPasswordField(confirm)?`, `AmdsSwitchTile(signOutOthers)?`, `AmdsButton("Update password", loading)`, success `Column[✓, Text, AmdsButton("Done")]`.
5. **Information Architecture** — verify identity (current password) → set new (with visible rules) → optional session hygiene. Rules identical to Register / Reset Password (one `PasswordPolicy`). Forced changes explain themselves.
6. **User Flow** — A's. `open → (forced? Banner) → enter current → enter new (checklist ticks live; "new must differ from current" enforced) → "Update password" → { success → other sessions signed out (if toggled) → ✓ state → "Done" | wrong current password → inline error on that field (generic: "Current password is incorrect") | new fails policy → inline / checklist | reused password → "You can't reuse a recent password" } `. "Forgot your current password?" → confirm → sign out → Forgot Password.
7. **States** —
   - **Loading:** "Update password" spinner; inputs locked.
   - **Empty:** current-password field focused; checklist neutral (unmet, not error).
   - **Success:** ✓ "Password updated"; note if other sessions were ended ("You've been signed out on 2 other devices"); "Done".
   - **Error:** wrong current password (that field, generic message, keep the new-password input); policy failure (checklist / inline); reuse rejected; rate-limited ("Too many attempts — try again in N min"); system error → Banner + Retry, inputs preserved.
   - **Offline:** Banner; "Update password" disabled ("Connect to change your password"); a **forced** change offline → the app stays gated on this screen until online (or per policy allows a grace window).
8. **Accessibility** — A's. Three password fields each labelled distinctly ("Current password", "New password", "Confirm new password"); reveal toggles labelled; `autocomplete="current-password"` / `"new-password"`. Requirements checklist announced on change; "new must differ from current" stated. Wrong-current-password error announced on that field. Forced-change Banner `role=alert` on entry. Success announced + focus to "Done". Never expose password values to the a11y tree when hidden.
9. **Animations** — A's. Checklist items tick (150ms check-draw). Wrong-password: field shake (reduced-motion: `dangerContainer` flash). Success: check-draw 250ms `spring`. Reduced-motion: instant.
10. **Dark Mode** — A's field palette; checklist met = `#4ADE80`, unmet = `#64748B`; forced Banner `warningContainer`; success icon `#4ADE80`.
11. **Tablet** — A's centered column (max 420–480); forced-change Banner full-width above.
12. **Developer Notes** — **all:** `POST /me/password { currentPassword, newPassword, signOutOthers }` → server verifies current, checks history (last N), checks policy, rotates; on `signOutOthers` (or always, per policy) revoke other refresh tokens and **keep the current session** (issue a fresh token pair to this device). Wrong-current-password returns a generic error + counts toward rate limiting. Reuse `PasswordPolicy` (shared with Register / Reset). Forced change: a flag on the session (`mustChangePassword`) that a router guard redirects to this screen and blocks everything else until cleared. Never log passwords. **Compose:** `derivedStateOf` checklist. **Flutter:** `PasswordPolicy` value object. **RN:** `zod` schema.
13. **UX Best Practices** — verify with the current password. Rules visible as a live checklist, identical to Register/Reset. New must differ from current + not a recent reuse — say so. Keep this session signed in; offer (default-on for forced) to sign out others. Forced changes explain why. Generic error for a wrong current password. Rate-limit and say so. "Forgot current password" routes to the reset flow.

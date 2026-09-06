# Screen Library · 03 · User Management

> Foundation: AMDS v1.0 · Archetypes: **C — List** (§4.C), **D — Detail** (§4.D), **E — Form** (§4.E).
> Admin surface for managing people: directory, profiles, provisioning, role/permission assignment, activation. Entries = deltas + specifics. Universal checklists: framework §6.

Screens: User List · User Detail · User Create · User Edit

Flow map:
```
User List ─► User Detail ─► User Edit ─► (save) User Detail
User List ─► FAB "Add user" ─► User Create ─► (save) User Detail (highlighted in list on back)
User Detail ─► overflow: Deactivate / Reset password / Resend invite / Delete (confirm)
```

Permission gate: this whole module requires an admin/HR-manager role. Non-privileged users get "You don't have access to user management".

---

## 3.1 User List

**Archetype:** C · **Route:** `/users?q=&role=&status=&dept=&sort=`

1. **Purpose** — browse, search, and filter the organization's people; entry point to every user record and to provisioning.
2. **User Goal** — "Find a specific person (or a set — e.g. all deactivated contractors) and open or act on them."
3. **Layout** — C's skeleton. App bar "Users" + search + filter + overflow (Export, Bulk import). Search field (persistent). Filter chips: Role, Status (Active/Invited/Deactivated), Department, Location, Employment type. Sort: Name A–Z (default) · Recently added · Last active · Role. **Row:** `AmdsAvatar(sm)` · **Name** (`titleMedium`) + role · **subtitle** = department · email · trailing = **status chip** (Active `success` / Invited `info` / Deactivated `textTertiary`) + chevron. FAB "Add user".
4. **Component Hierarchy** — C's + `UserListRow(AmdsAvatar, name, roleChip, dept, AmdsChip status, chevron)`; selection mode → bulk bar (Assign role · Deactivate · Resend invite · Export selected); Filter → `AmdsBottomSheet` grouped.
5. **Information Architecture** — identity-first row (avatar + name + role). Status is the key at-a-glance signal. Count + active filters always visible ("Showing 48 of 312"). Sensitive fields (personal phone, salary) **never** in the list. Deep-linkable filter state.
6. **User Flow** — C's. `search by name/email/employee-id (debounced) → tap row → User Detail`. `filter Status = Invited → bulk select → "Resend invite" → confirm count → progress → result summary`. `FAB → User Create`. Swipe row: leading = (context) none or "Message"; trailing = "Deactivate" (confirm). Long-press → selection mode.
7. **States** — C's. Deltas:
   - **Empty (no users):** only on a brand-new tenant → "No users yet" + "Add your first user" + "Bulk import".
   - **Empty (no results):** "No people match" + echo query + "Clear filters".
   - **Success:** rows; invited users visually lighter with an "Invited" chip; deactivated users muted.
   - **Error:** "Couldn't load users" + Retry.
   - **Offline:** cached directory + "as of HH:MM"; provisioning actions (add/deactivate/invite) disabled offline with "Reconnect to manage users".
8. **Accessibility** — C's. Row announces "Name, Role, Department, Status" as one stop ("Priya Nair, Supervisor, Operations, Active"). Status conveyed by chip **text**, not color. Bulk-select checkbox labelled "Select Priya Nair". Result-count changes announced. Avatar `aria-hidden` (name present).
9. **Animations** — C's. Status change after a bulk action animates the chip crossfade; deactivated rows fade to muted.
10. **Dark Mode** — C's. Status chips: Active green-400 dot + label, Invited sky-400, Deactivated `#64748B`; muted rows at reduced opacity but still ≥4.5:1 for the name.
11. **Tablet** — C's list-detail: **users list left, User Detail right** on landscape; portrait = single list max-640. Bulk actions in a toolbar above the list on tablet.
12. **Developer Notes** — **all:** `RecordListConfig` instance; server-side search across `name | email | employeeId`; filters map to query params; keyset pagination; page 25/50. Bulk endpoints idempotent + return per-item results. Guard the route with the admin permission (`redirect` → `/denied`). **Compose:** Paging 3 + `LazyColumn`. **Flutter:** `PagedListView` + `RecordListConfig`. **RN:** `FlashList` + React Query infinite. Export → §07 Export Screen pattern.
13. **UX Best Practices** — identity-first rows; status as the primary signal; count + filters visible; no PII in the list; provisioning actions clearly gated offline; bulk operations show exact counts + result summaries; distinct empty states.

---

## 3.2 User Detail

**Archetype:** D · **Route:** `/users/:id?tab=overview|activity|permissions|devices`

1. **Purpose** — the complete record for one person: identity, employment, roles/permissions, access status, activity, and admin actions.
2. **User Goal** — "Understand this person's access and status, and manage it (edit, assign role, deactivate, reset password)."
3. **Layout** — D's skeleton.
   - **Header:** `AmdsAvatar(xl)` · name `headingLarge` · job title · department · **status chip** (Active / Invited / Deactivated / Locked) · "Last active 2h ago".
   - **Primary actions:** Edit (primary) · Assign role · overflow (Reset password · Resend invite · Deactivate/Reactivate · Manage devices · **Delete** — guarded).
   - **Tabs:** **Overview** (contact rows — work email, phone, employee ID, manager, start date, location; each with an action) · **Activity** (audit trail: logins, permission changes, records touched) · **Permissions** (roles list + effective permissions, read-only unless "Assign role") · **Devices/Sessions** (active sessions with "Revoke").
4. **Component Hierarchy** — D's + `UserHeader`, `Row(AmdsButton Edit, AmdsButton AssignRole, AmdsIconButton overflow)`, `AmdsTabBar`, per tab: `AmdsCard > List(field rows)`, `AuditTimeline (AmdsStepper vertical)`, `RoleList + PermissionMatrix`, `SessionList(AmdsListTileX + Revoke)`.
5. **Information Architecture** — header answers "who + what access + are they active". Overview = the human facts; Permissions = the access facts; Activity = the accountability trail. Org-managed fields (title, department from the HRIS) are **read-only** with a "Managed by HR" note. Personal contact details gated + access-logged.
6. **User Flow** — D's. `open → confirm identity + status → Edit → User Edit → save → back, changed fields highlight`. `Assign role → bottom sheet (role picker + effective-permission preview) → apply → Permissions tab updates + audit entry`. `overflow → Deactivate → confirm dialog ("Deactivate Priya Nair? They lose access immediately. Data is retained.") → status → Deactivated`. `Devices tab → Revoke a session → confirm → session drops`.
7. **States** — D's. Deltas:
   - **Loading:** header skeleton + tab-content skeleton.
   - **Empty:** Activity "No activity recorded"; Devices "No active sessions"; Permissions "No roles assigned — this user has base access only".
   - **Success:** full record; actions reflect status (Deactivate ↔ Reactivate; Resend invite only for Invited).
   - **Error:** "Couldn't load this user" + Retry; deleted user → "This user no longer exists" + "Back to users".
   - **Offline:** cached record "as of HH:MM"; all admin actions disabled with "Reconnect to manage this user"; edits not permitted offline (or queued per policy with a Pending banner).
8. **Accessibility** — D's. Status announced with consequence context on actions ("Deactivate Priya Nair, this removes access immediately"). Permission matrix = a real table (roles × permissions) with headers. Audit entries = grouped stops ("3 March, permissions changed by admin S. Lee: added Approver role"). "Revoke session" labelled with device + location. Destructive dialog default focus = Cancel; Delete requires typing the user's name.
9. **Animations** — D's. Status chip crossfades on change; a revoked session row collapses out; assign-role preview expands.
10. **Dark Mode** — D's. Header band subtle `surfaceVariant`; status chips translucent + -100 text; permission matrix uses dark table tokens; audit timeline line `#334155`, nodes by event type.
11. **Tablet** — D's. Landscape: users list stays left, this detail fills the right pane; tabs remain; the permission matrix gets more width. Portrait: max-640, two-column contact rows.
12. **Developer Notes** — **all:** `RecordDetailConfig` with permission-predicated actions; capture `etag`/version for optimistic concurrency. Deactivate = immediate token/session revocation server-side + audit. Delete = soft-delete/anonymize per data-retention policy (GDPR) — often "deactivate + schedule purge", never a hard delete from the UI. Session revoke calls the auth service. Route: `/users/:id?tab=`. **Compose/Flutter/RN:** tabbed detail per framework §5.2 D.
13. **UX Best Practices** — identity + access status above the fold. Read-only for HR-managed fields (explain why). Preview the effect of a role change before applying. Every admin action is logged and visible in Activity. Confirm destructive actions with consequences spelled out. Keep back → users list.

---

## 3.3 User Create

**Archetype:** E · **Route:** `/users/new`

1. **Purpose** — provision a new user account and set their initial access.
2. **User Goal** — "Add this person with the right role and either invite them or set them up directly, without errors."
3. **Layout** — E's skeleton (full-screen modal). Top bar: `X` · "Add user" · "Send invite" / "Create" (trailing, primary). Sections:
   - **Identity:** First name · Last name · Work email (uniqueness checked async) · Employee ID (optional/auto) · Phone (optional).
   - **Organization:** Department (dropdown) · Job title · Manager (entity picker) · Location · Start date · Employment type (radio: Full-time / Part-time / Contractor).
   - **Access:** Role(s) (multi-select with effective-permission preview) · optionally "Copy access from an existing user" (entity picker).
   - **Onboarding:** toggle "Send email invitation now" (default on) — if off, "Set a temporary password" appears (with force-change-on-first-login).
4. **Component Hierarchy** — E's + `AmdsTextField × identity`, `AmdsDropdown(department, type)`, `AmdsEntityPicker(manager, copyFrom)`, `AmdsDatePickerField(startDate)`, `AmdsRadioGroup(employmentType)`, `AmdsMultiSelect(roles) + PermissionPreview`, `AmdsSwitchTile(sendInvite)`, conditional `AmdsPasswordField(tempPassword)`.
5. **Information Architecture** — identity → org placement → access → activation. Only name + email + role are truly required; everything else is deferrable. Uniqueness on email is the critical validation. Access has a visible consequence (permission preview).
6. **User Flow** — E's. `fill identity → email uniqueness async (helper spinner) → org fields → pick role(s) → preview permissions → choose invite vs temp password → "Send invite" → { success → User Detail (status Invited) + Snackbar "Invitation sent to …" | email exists → inline error + "View existing user" | validation → focus first error }`. Autosave draft (admin may be interrupted).
7. **States** — E's. Deltas:
   - **Loading:** dropdown option lists load (skeleton rows); email check spinner.
   - **Empty:** first name focused; sensible defaults (start date = today, type = Full-time, send invite = on).
   - **Success:** → User Detail; the new user appears highlighted in the list on back.
   - **Error:** email taken (field), invalid domain (field, "Use a company email address"), role conflict; system error → Banner + Retry, keep input.
   - **Offline:** Banner; submit disabled (provisioning needs the server); draft saved locally.
8. **Accessibility** — E's. Email-uniqueness result announced ("Email is available" / "This email is already in use"). Role multi-select announces the count and the permission preview updates announce politely. `sendInvite` toggle explains the branch ("On: we email an invitation. Off: you set a temporary password."). Required fields (Name, Email, Role) marked in the label.
9. **Animations** — E's. Permission preview expands/updates with a 200ms height + fade. Temp-password field slides in when the invite toggle is off. Checklist ticks on password rules.
10. **Dark Mode** — E's form palette; permission-preview card uses `surfaceVariant`; "available/taken" helper uses `success`/`danger` -400.
11. **Tablet** — E's single column max-640; landscape can show the permission preview as a right-hand panel that updates live as roles are toggled.
12. **Developer Notes** — **all:** `FormSchema` with `visibleWhen` (temp password shown when `!sendInvite`); email validator = format + company-domain rule + async uniqueness (debounce 500ms); role → permission preview computed client-side from a cached role→permission map. Create endpoint returns the new user + (if invited) triggers the invite email server-side. Temp password: generated or typed, always `force_password_change`. Audit the creation. **Compose:** `rememberSaveable` draft. **Flutter:** debounced draft provider. **RN:** `react-hook-form` + zod.
13. **UX Best Practices** — minimal required set; smart defaults; async uniqueness with clear result; preview access consequences; explain the invite/temp-password branch; autosave; never block paste; land on the created record.

---

## 3.4 User Edit

**Archetype:** E · **Route:** `/users/:id/edit`

1. **Purpose** — change an existing user's editable attributes and access.
2. **User Goal** — "Update this person's details or access and save, without clobbering someone else's change or breaking their access."
3. **Layout** — E's skeleton, **pre-populated**, title "Edit user". Same sections as Create **minus** the onboarding/invite block. **Read-only** (shown but disabled, with a "Managed by HR" note): fields synced from the system of record (often name, department, title, employee ID). **Editable:** phone, location, manager (if not HR-managed), roles/access, and (admin-only) email — with a warning.
4. **Component Hierarchy** — E's, mirroring Create; read-only fields render as `AmdsReadOnlyField`; a dirty indicator on the app bar; "Save" enabled only when dirty **and** valid.
5. **Information Architecture** — separate "profile data" from "access data" clearly. Changing email or roles has security consequences — surface them. Show a compact "what will change" summary before save for role changes.
6. **User Flow** — E's. `open (populated) → change fields → dirty → "Save" → validate → { if roles changed → confirm dialog with permission diff ("Adds: Approver. Removes: none.") → apply | if email changed → confirm ("The user must verify the new email; they'll be signed out.") } → save → { success → User Detail, changed fields highlight | 409 conflict → "This user was updated by {name} — Review / Overwrite / Cancel" | validation → focus first error }`.
7. **States** — E's. Deltas:
   - **Loading:** field skeletons while the record + option lists load.
   - **Empty:** N/A (editing).
   - **Success:** → User Detail with changed fields highlighted for ~2s; audit entry written.
   - **Error:** field-level; **409 conflict** → resolution UI (form-design-system §4.3), never silent overwrite; system error → keep form, Retry.
   - **Offline:** editing disabled offline for provisioning-critical fields; or (per policy) queue with a "Pending sync" banner and a conflict check on reconnect. Draft always saved locally.
8. **Accessibility** — E's. Read-only fields announced as "read only, managed by HR". The role-change diff dialog reads the additions/removals as text. Conflict resolution options clearly labelled. Dirty state announced when Save becomes enabled.
9. **Animations** — E's. Changed-field highlight on return (`primaryContainer` 400ms fade). Role diff dialog per Archetype F. Conflict banner slides in.
10. **Dark Mode** — E's; read-only fields at `textTertiary` with a lock icon; diff dialog per F dark.
11. **Tablet** — E's single column max-640; landscape optional section anchor-nav; the role/permission editor can be a right panel.
12. **Developer Notes** — **all:** `FormSchema` reused from Create with `editable: false` on synced fields and the onboarding section omitted; PATCH only the changed fields; send the `etag`/version → 409 handling mandatory; role change → server re-computes effective permissions + revokes/refreshes the user's session tokens as needed; email change → triggers re-verification + sign-out. Audit every change with before/after. **Compose/Flutter/RN:** per framework §5.2 E; add an optimistic-concurrency interceptor.
13. **UX Best Practices** — Save only when dirty + valid; preview role/permission diffs; warn on security-affecting changes (email, roles); never silently overwrite a concurrent edit; highlight what changed on return; keep HR-managed fields visibly read-only with a reason; autosave drafts.

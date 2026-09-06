# Screen Library · 04 · Data Management (generic CRUD)

> Foundation: AMDS v1.0 · Archetypes: **C — List** (§4.C), **D — Detail** (§4.D), **E — Form** (§4.E), **F — Confirmation** (§4.F).
> These are the **generic, config-driven** CRUD screens that every domain entity reuses: assets, incidents, work orders, purchase requests, contacts, stock items, inspections, devices… Configure, don't rebuild.

Screens: Data List · Data Detail · Create Form · Edit Form · Delete Confirmation

The engine (Flutter starter kit §8.1):
- `RecordListConfig` → **Data List**
- `RecordDetailConfig` → **Data Detail**
- `FormSchema` / `FormEngine` → **Create Form** + **Edit Form**
- `AmdsDialog.destructive` → **Delete Confirmation**

Flow map:
```
Data List ─► Data Detail ─► Edit Form ─► (save) Data Detail
Data List ─► FAB "New {entity}" ─► Create Form ─► (submit) Data Detail (+ list row highlighted on back)
Data Detail ─► overflow "Delete" ─► Delete Confirmation ─► (confirm) Data List (row removed + Undo)
Data List ─► selection mode ─► bulk "Delete" ─► Delete Confirmation (count) ─► result summary
```

---

## 4.1 Data List

**Archetype:** C · **Route:** `/{entityType}?q=&filter=&sort=&view=`

1. **Purpose** — browse / search / filter / sort a collection of one entity type and act on records individually or in bulk.
2. **User Goal** — "Find the record(s) I need and open or act on them; or triage what's new/overdue."
3. **Layout** — C's skeleton, driven by `RecordListConfig`:
   - App bar: `{Entity} plural` · search · filter · sort · overflow (Export, Column settings, Saved views).
   - Search field (scoped to this entity).
   - Active filter chips + count + sort control.
   - **Row** (config `rowBuilder`): leading (icon by type / status color / thumbnail / checkbox) · **primary column** (`titleMedium`) · 2–3 metadata (`caption`, `•`-separated) · trailing (primary numeric / status chip / chevron / quick action).
   - Grouping (config): by status, date bucket, or A–Z.
   - FAB "New {entity}" (if creatable).
   - Row swipe actions (config): leading = positive (Approve / Complete / Assign), trailing = destructive/secondary (Archive / Delete).
4. **Component Hierarchy** — C's + `RecordListConfig{ query, rowBuilder, filterDefs, sortOptions, groupBy, swipeActions, selectionActions, fab, emptyCopy }` → `PagedListView` / `LazyColumn` / `FlashList`.
5. **Information Architecture** — one entity per screen. Row shows the identifier + the 2–3 fields that matter for scanning *this* entity (config-declared); the rest is in Detail. Total + filtered count visible. Default sort = config (`Updated ▼` or a domain priority). Saved views for recurring needs. Deep-linkable state.
6. **User Flow** — C's exactly. Config supplies: what search matches, which filters exist, which sorts, what a swipe does, what bulk actions do, where the FAB goes.
7. **States** — C's exactly. Config supplies the empty copy ("No {entity} yet" + "Add {entity}"; "Nothing matches"). Offline: cached list + queued row actions with "Pending" chips.
8. **Accessibility** — C's. Row name = the config's `semanticSummary(record)` ("{title}, {status}, updated {relativeTime}, {primaryValue}"). Swipe actions as custom actions + row overflow. Column-settings changes announced.
9. **Animations** — C's exactly (stagger on first paint, swipe/remove, selection-mode crossfade, new-item tint).
10. **Dark Mode** — C's. Status colors from the entity's status→token map (config); selected row `primaryContainer` + 2px `primary` bar.
11. **Tablet** — C's list-detail two-pane on landscape; a **"Table view" toggle** (per data-display §3.3) for comparison-heavy entities (assets, stock) → horizontally-scrolling grid with frozen identifier column, sort headers, density toggle.
12. **Developer Notes** — **all:** one `DataListScreen(config)` widget; server-side `q/filter/sort/page` (keyset); page 25/50; `infinite_scroll_pagination` / Paging 3 / React Query infinite; `keepAlive` for state; optimistic row mutations + Undo; debounce search 250–300ms. Column settings + saved views persist per user. **Table view** shares the same data source, different renderer.
13. **UX Best Practices** — whole row is the target unless it has a trailing control; swipe actions also in overflow; show why zero results + "Clear filters"; persist filters/sort/scroll per session; Undo over pre-confirm; skeleton matches row height.

---

## 4.2 Data Detail

**Archetype:** D · **Route:** `/{entityType}/{id}?tab=`

1. **Purpose** — everything about one record + its permitted, state-aware actions + related data + audit trail.
2. **User Goal** — "Confirm this is the right record, understand its state, and act on it or navigate its related data."
3. **Layout** — D's skeleton, driven by `RecordDetailConfig`:
   - **Header:** title = record name/ID · status chip · 1–2 key attributes · optional media (photo / map / QR).
   - **Primary actions** (config, permission- + state-predicated): e.g. asset → "Check out" / "Report issue"; incident → "Escalate" / "Close"; request → handled by Approval module.
   - **Tabs / sections** (config): Overview (field groups) · Related (linked records — sub-lists) · Documents/Attachments · Activity/Audit · Comments.
   - **Destructive:** "Delete" / "Archive" at the bottom or in overflow → Delete Confirmation.
4. **Component Hierarchy** — D's + `RecordDetailConfig{ header, actions[], sections[], relatedLists[], destructiveAction }`; field rows from `sections[].fields` (label + value + optional inline action); `AuditTimeline`; `CommentsThread`.
5. **Information Architecture** — header confirms identity in 1s. Field groups logical + config-ordered; empty values → consistent "—"; irrelevant fields hidden. Actions reflect record state + permission (disable with reason, or hide). Deep-linkable per tab.
6. **User Flow** — D's exactly. Config supplies actions and their effects, section layout, related lists, and the destructive action.
7. **States** — D's exactly. `AmdsSkeletonDetail`; per-tab empties from config; deleted/invalid id → "This {entity} no longer exists" + "Back to {entities}"; offline → cached "as of HH:MM", mutations queue, conflict-on-reconnect resolution.
8. **Accessibility** — D's. Field row = one stop ("{label}, {value}"); status announced with meaning; action buttons name the record when ambiguous; tabs = `tab`/`tabpanel` with position/count; copyable IDs; sensitive fields gated + access-logged + masked-with-reveal.
9. **Animations** — D's. Enter shared-axis (or shared-element on title/media); header collapse on scroll; tab indicator slide + panel crossfade; post-edit field highlight 400ms.
10. **Dark Mode** — D's. Header band subtle; status chips translucent + -100 text; field cards `#0F172A` + `#1E293B`; timeline line `#334155`.
11. **Tablet** — D's two/three-pane on landscape (list · detail · comments); portrait max-640, two-column field groups.
12. **Developer Notes** — **all:** one `DataDetailScreen(config)`; capture `etag` on load for optimistic concurrency; prefetch header from the list row for instant paint; field-level history for audited entities; route `/{type}/{id}?tab=`; synthesize back stack on deep link. **Compose/Flutter/RN:** framework §5.2 D.
13. **UX Best Practices** — identity confirmable instantly; consistent empty treatment; actions match state + permission (explain disabled); back → list preserved; show who changed what, when; edits via the form engine; confirm + prefer soft-delete.

---

## 4.3 Create Form

**Archetype:** E · **Route:** `/{entityType}/new`

1. **Purpose** — create a new record of one entity type, correctly and quickly, without losing work.
2. **User Goal** — "Enter this new {entity} with the right data and submit with confidence — or save a draft and finish later."
3. **Layout** — E's skeleton (full-screen modal), driven by `FormSchema`:
   - Top bar: `X` (cancel, dirty-guard) · "New {entity}" · "Submit" / "Save" (trailing, primary).
   - Sections (`FormSchema` groups) with `overline` headers.
   - Fields rendered by type: text / number / currency / dropdown / entity-picker / date / time / date-range / radio / checkbox group / switch / attachments / location / signature / barcode-scan.
   - Attachments block.
   - Sticky footer on long forms: "Save draft" (secondary) · "Submit" (primary).
   - Multi-step (`List<FormStep>`): Stepper + per-step validation + a **Review** step.
4. **Component Hierarchy** — E's + `FormEngine(schema)` → maps each `FormFieldSpec` to the right `Amds*` input with helper/error slots; `AmdsStepper?`; `AmdsBanner(errorSummary)?`.
5. **Information Architecture** — one column; ≤7 fields per section; most-known/important first; dependent fields after their trigger (`visibleWhen`); destructive last. Labels always visible; requirements in helper text before errors. Prefill from context (reporter = me, date = now, site = my site, linked-record from the entry point).
6. **User Flow** — E's exactly. `open (prefilled) → fill → blur validation → attach → autosave draft (debounce 2–3s + on background) → Submit → validate all + cross-field + server → { success → Data Detail (or list, row highlighted) + Snackbar; draft cleared | validation → focus first error + summary Banner | system error → keep form + Retry | significant submit (→ approval) → success screen with next steps }`. Cancel on dirty → "Discard changes?".
7. **States** — E's exactly. Loading: dropdown/entity-picker option lists (skeleton); async field checks (helper spinner); submit (button spinner, inputs locked). Empty: helpful defaults + placeholders + optional "Load from template". Offline: Banner, queue submit, record shows "Pending", draft local.
8. **Accessibility** — E's. Each `FormFieldSpec` carries its `label`, `helper`, `required`, `keyboardType`, and validators → the engine wires visible labels, `inputmode`, `aria-describedby`, required-in-label, error announcements, and first-error focus automatically. Group fields (radio/checkbox) get a legend. Submit reachable without dismissing the keyboard.
9. **Animations** — E's. Error message slide-down+fade; conditional field (`visibleWhen`) slides in/out (200ms height + fade); step advance shared-axis X; success pop + Snackbar. Reduced-motion: no shake → border + text + `dangerContainer` flash.
10. **Dark Mode** — E's form palette; date/time pickers dark; attachment thumbnails get a `#334155` ring.
11. **Tablet** — E's single column max-640 centered; landscape optional left section anchor-nav; modal create → centered dialog ≤720; multi-step → steps-left / form-right inline.
12. **Developer Notes** — **all:** `FormEngine(FormSchema)` — `FormFieldSpec{ key, type, label, helper, validators, visibleWhen(values), options|optionsLoader, asyncValidator }`. Validation timing per form-design-system §6 (live only for strength/availability/counter/mask; blur for the field; submit for all + server). Autosave: encrypted local (`flutter_secure_storage`/EncryptedSharedPreferences/Keychain) + server sync; "Resume draft?" on return; expire per policy. Attachments: per-file progress + retry, don't fail the form; type/size limits stated up front. **Compose:** a `FormState` holder + `bringIntoViewRequester` for first-error scroll. **Flutter:** `FormEngine` widget + debounced draft provider. **RN:** `react-hook-form` + `zod` resolver generated from the schema.
13. **UX Best Practices** — ask only what's needed now; smart defaults + prefill; requirements as a live checklist; validate on blur; preserve input on every failure; confirm discard on dirty; `X` = cancel / trailing = commit (never swap); autosave; success is never a dead end.

---

## 4.4 Edit Form

**Archetype:** E · **Route:** `/{entityType}/{id}/edit`

1. **Purpose** — change an existing record's editable fields, safely (no concurrent-edit clobber), without losing work.
2. **User Goal** — "Update this {entity} and save, confident I didn't overwrite someone else's change."
3. **Layout** — E's skeleton, **pre-populated**, title "Edit {entity}". Same `FormSchema` as Create; `editable: false` fields render as `AmdsReadOnlyField` (with a reason where relevant — "Set at creation", "Managed by {system}"). App bar dirty indicator; "Save" enabled only when dirty **and** valid. Optional "What changed" summary before save.
4. **Component Hierarchy** — E's + `FormEngine(schema, initialValues: record, mode: edit)`; `DirtyIndicator`; conflict `AmdsBanner`.
5. **Information Architecture** — same structure as Create; emphasize *what's changing*. Fields with security/workflow consequences (status, owner, amount) get a confirm-on-save.
6. **User Flow** — E's. `open (populated, etag captured) → change fields → dirty → Save → validate → (consequential change? confirm dialog with the diff) → PATCH changed fields + etag → { success → Data Detail, changed fields highlight ~2s, audit entry | 409 conflict → "Updated by {name} — Review / Overwrite / Cancel" | validation → focus first error }`. Cancel on dirty → "Discard changes?".
7. **States** — E's. Loading: field skeletons while record + options load. Empty: N/A. Success: → Detail, highlight changes. Error: field-level; **409 conflict → resolution UI (form-design-system §4.3), never silent overwrite**; system error → keep form + Retry. Offline: queue with "Pending sync" + conflict check on reconnect; draft local.
8. **Accessibility** — E's. Read-only fields announced "read only" + reason. Dirty state announced when Save enables. The change-diff dialog reads additions/removals/changes as text. Conflict options clearly labelled with what each does.
9. **Animations** — E's. Changed-field highlight on return; diff dialog per Archetype F; conflict Banner slides in. Reduced-motion respected.
10. **Dark Mode** — E's; read-only fields `textTertiary` + lock icon; conflict Banner `warningContainer`.
11. **Tablet** — E's single column max-640; landscape section anchor-nav.
12. **Developer Notes** — **all:** reuse the Create `FormSchema` with `editable` flags + `initialValues`; PATCH-only-changed; **always send `etag`/version → 409 handling is mandatory**; consequential fields declare `confirmOnChange`. Audit before/after. **Compose/Flutter/RN:** framework §5.2 E + an optimistic-concurrency interceptor in the repo.
13. **UX Best Practices** — Save only when dirty + valid; show what's changing for consequential edits; never silently overwrite; highlight changes on return; read-only fields visibly so, with a reason; autosave; same discard-guard as Create.

---

## 4.5 Delete Confirmation

**Archetype:** F · **Presentation:** `AmdsDialog.destructive` (modal, not a route) · triggered from Data Detail overflow, list-row swipe, or bulk selection bar.

1. **Purpose** — force a deliberate decision before removing a record (or many), and communicate reversibility and side effects.
2. **User Goal** — "Understand exactly what will be deleted and what it affects, then confirm safely — or back out."
3. **Layout** — F's dialog: optional `delete`/`warning` hero icon (`danger` tint) · **title** = "Delete {entity name/ID}?" (bulk: "Delete {N} {entities}?") · **body** = consequence + reversibility + side effects ("This can't be undone. 3 linked tasks will be unassigned and 2 attachments deleted.") · for **high-value** records: an `AmdsTextField` "Type {name} to confirm" · actions: **"Cancel"** (text, default focus) · **"Delete"** (`danger` filled, disabled until typed-confirm matches).
4. **Component Hierarchy** — `showAmdsDialog(DialogHeroIcon(danger), Text(title), Text(body), AmdsTextField(typeToConfirm)?, actions:[AmdsButton.text("Cancel"), AmdsButton.filled("Delete", danger, loading)])`. Bulk variant adds a progress + result summary phase.
5. **Information Architecture** — title names the object + the outcome. Body states: is it reversible? what else is affected? is there a retention window? Buttons are verbs ("Delete" / "Keep"). Max 2 actions. Bulk: state the **exact count** and the combined side effects.
6. **User Flow** — F's:
   ```
   trigger → dialog opens, Cancel focused, focus trapped
     → Cancel / scrim (non-destructive path only) / back / Esc → dismiss, focus returns to trigger
     → (high-value) type the name → Delete enables
     → Delete → button loading, actions disabled
         ├─ soft-delete supported → record archived → dialog dismisses → list row collapses out → Snackbar "Deleted · Undo" (5–7s)
         ├─ hard-delete → record removed → dismiss → navigate to list → Snackbar "Deleted" (no undo; say so in the body)
         ├─ blocked (dependencies) → dialog shows "Can't delete — 2 open work orders reference this asset" + "View dependencies" (no Delete)
         ├─ conflict (already deleted) → "This {entity} was already deleted" → dismiss, refresh list
         └─ error → keep dialog, inline error + "Try again", trace id
   bulk → confirm count → progress bar ("Deleting 6 of 8…") → result summary ("6 deleted, 2 failed — Retry failed")
   ```
7. **States** —
   - **Loading:** Delete button spinner; bulk → determinate progress ("Deleting 4 of 8…").
   - **Empty:** N/A.
   - **Success:** soft → dismiss + Undo Snackbar; hard → dismiss + navigate + Snackbar; list/detail updates, counts decrement.
   - **Error:** keep dialog, inline error + Retry; **dependency-blocked** → informational variant with a "View dependencies" action and no Delete; bulk partial → per-item result list + "Retry failed".
   - **Offline:** soft-delete/archive → queue with "Pending" chip + "Will delete when you're back online"; **hard/irreversible delete blocked offline** with "You must be online to permanently delete".
8. **Accessibility** — F's: `role=alertdialog`, focus moves in (Cancel), **trapped**, Esc/back = Cancel, scrim tap = Cancel (non-destructive only), focus returns on close. Body fully announced (including side effects). Typed-confirm field labelled ("Type the asset name to confirm"); Delete's disabled state announced with the reason. Bulk progress + result announced politely. Never stack on another dialog.
9. **Animations** — F's: scrim fade 150ms → container fade + scale 0.95→1 200ms `decelerate`; exit `accelerate` 150ms. Delete loading: label→spinner. On success: dialog exits, then the row collapse-out (200ms `accelerate`) + Snackbar slide-up. Bulk: progress bar animates; result summary crossfades in. Reduced-motion: fade + 8dp translate only.
10. **Dark Mode** — F's: dialog surface `#1E293B` + strong shadow + scrim `rgba(2,6,23,0.64)`; hero icon red-400; Delete button red-400 fill + slate-950 label; typed-confirm field dark.
11. **Tablet** — centered dialog ≤560, over the two-pane layout; never full-screen. Bulk progress/result stays in the dialog.
12. **Developer Notes** — **all:** `AmdsDialog.destructive(title, body, confirmLabel:"Delete", danger:true, requireTypedConfirm: record.isHighValue, undoable: entity.supportsSoftDelete)`. **Prefer soft-delete/archive + Undo Snackbar**; reserve hard-delete for entities that truly need it and say "can't be undone" in the body. Check dependencies **before** enabling Delete (server pre-check or a `dependencies` field on the record) → show the blocked variant. Bulk: idempotent per-item DELETE, atomic where supported else ordered with a result map; idempotency keys for the offline queue. Re-check permission + state server-side (403/409). Undo window 5–7s (extend / require-manual-dismiss under screen reader / switch access). Audit the deletion (who, when, what). **Compose:** `AlertDialog` + `LaunchedEffect` focus. **Flutter:** `showDialog` + `PopScope`. **RN:** themed `Modal` + back handler + `setAccessibilityFocus`.
13. **UX Best Practices** — never one-tap destructive; title = object + outcome; state reversibility + side effects + retention window; verb buttons; Cancel is the safe default and default focus; typed-confirm for high-value; prefer Undo to friction; block (don't just warn) when dependencies exist; confirm bulk with the exact count + result summary; block irreversible deletes offline.

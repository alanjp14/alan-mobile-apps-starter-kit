# Screen Library · Form Design System

> Standards for Create · Read · Update · Delete, plus Approval Workflow, Validation, Error Handling, and Success Handling. Referenced by [`04-data-management.md`](04-data-management.md) and [`05-approval-workflow.md`](05-approval-workflow.md).

---

## 1. Form principles

1. **One column, one idea per field.** No side-by-side inputs on phones (except naturally paired: city/postcode, start/end where short).
2. **Labels are always visible** — above the field, `label` type, `textSecondary`. Never placeholder-only.
3. **Ask only what you need now.** Defer optional data; use smart defaults; pre-fill from context.
4. **Forgiving input** — accept messy formats and normalize (phone, dates, currency, IDs with/without prefix). Never punish a paste.
5. **Progress is never lost** — autosave drafts, preserve on error, confirm before discard.
6. **Tell users the rules before they break them** — helper text and inline requirements, not surprise errors.

---

## 2. Layout & structure

```
[ Top bar:  X (cancel) · "New work order" · Save (primary, trailing) ]
[ optional Stepper (multi-step) ]
[ scroll:
    ── Section: Details ──────────  (overline header + optional helper)
    [ Field ]  label / input / helper|error
    [ Field ]
    ── Section: Assignment ───────
    [ Field ]
    [ Attachments ]
]
[ sticky footer (long forms): Secondary "Save draft" · Primary "Submit" ]
```

- **Sections** group ≤7 related fields, with an `overline` header and optional one-line description. Use Cards or full-width dividers, consistently.
- **Field spacing:** `space.5` (20) between fields, `space.8` (32) between sections.
- **Primary action:** trailing in the top bar for short forms; sticky footer for long/scrolling forms; full-width `Large` button for single-purpose task forms.
- **Field order:** most important / most known first; dependent fields after their trigger; destructive last.
- **Tablet:** single column, max width 640, centered; multi-section forms may use a left section-nav (anchor list) on landscape.

---

## 3. Field types → component mapping

| Data | Component | Notes |
|---|---|---|
| Short text | Text Field | set `inputmode`, `autocomplete`, `maxLength` (generous) |
| Long text / notes | Textarea | auto-grow to 5 lines, then scroll; show counter if limited |
| Number / quantity | Text Field `inputmode=decimal` + stepper affix for small ranges | unit as suffix; tabular figures |
| Currency | Text Field with currency prefix, decimal keypad | format on blur; store minor units |
| Email / phone / URL | Text Field with matching keyboard + validation | |
| Password | Password Field | requirements checklist, reveal |
| Single choice (2–4) | Radio or Segmented | Segmented if instant + short labels |
| Single choice (5–25) | Dropdown | searchable if >12 |
| Single choice (25+) | Autocomplete / entity picker (Search) | async, paginated |
| Multi choice | Checkbox group (≤6) or multi-select Dropdown / Chips | show count when collapsed |
| Boolean setting (instant) | Switch | not in Save-gated forms |
| Boolean attribute (part of record) | Checkbox | |
| Date | Date Picker | typed fallback, locale format |
| Time | Time Picker | Input variant available |
| Date + time | Combined "Date & time" control | one row, not two disconnected fields |
| Date range | Date Picker (range) | auto-swap if end < start |
| File / photo | Attachment control | camera/library/file; thumbnails; per-file progress & remove; type/size limits stated up front |
| Relationship (assign user, link asset) | Entity picker (Search + result rows with avatar/meta) | recent + search; shows chosen as a chip/row with clear |
| Location | Map picker / "Use current location" + address field | permission-aware |
| Signature | Signature pad | clear/redo; stored as image + metadata |
| Barcode / QR | Scan action → fills the field | manual entry fallback always |

---

## 4. CRUD standards

### 4.1 CREATE

- Launch as a **full-screen modal** (phone) or centered modal / inline panel (tablet).
- Top bar: `X` = cancel (dirty guard), title "New <entity>", trailing "Save"/"Submit".
- Pre-fill everything derivable (reporter = current user, date = now, site = user's site).
- Offer **Save as draft** for anything long or field-collected (incidents, requests).
- On success: close → land on the **new record's detail**, or return to the list with the new row highlighted + Snackbar "Created · View".
- Multi-step create: Stepper, per-step validation, a **Review** step before submit, back never loses data.

### 4.2 READ (detail / view)

- See [screen library](../screen-library/README.md) §9. Field rows: `label` (`textSecondary`) + value (`bodyMedium`, `textPrimary`), grouped.
- Empty values: consistent "—" (not blank, not "N/A" sometimes). Hide truly irrelevant fields.
- Sensitive fields (salary, PII) gated by permission, masked with reveal where allowed, access logged.
- Copyable values (IDs, emails, phone) — long-press or a copy affordance.
- "Edit" enters Update; per-field inline edit only for lightweight, low-risk fields (status, assignee) with immediate save + Undo.

### 4.3 UPDATE

- Same layout as Create, pre-populated, title "Edit <entity>".
- Show only what changed matters: a dirty indicator; "Save" enabled only when dirty and valid.
- **Optimistic concurrency:** if the record changed server-side since load → on save, show a conflict resolution ("This record was updated by <name>. Review changes / Overwrite / Cancel"). Never silently clobber.
- Field-level history available (who set this value, when) for audited entities.
- On success: return to detail, Snackbar "Saved", highlight changed fields briefly.

### 4.4 DELETE

- Never a one-tap action. Flow: trigger (overflow or bottom of detail, `danger`) → **confirmation Dialog**:
  - Title states the object: "Delete work order WO-1043?"
  - Body states the consequence and reversibility: "This can't be undone. 3 linked tasks will be unassigned."
  - Actions: "Cancel" (text, **default focus**) · "Delete" (`danger` filled).
  - For high-value objects: require typing the name/ID to confirm.
- Prefer **soft delete / archive** with an Undo Snackbar (5–7s) over hard delete where the domain allows.
- Bulk delete: contextual app bar → confirm with the exact count → progress → result summary ("8 deleted, 1 failed — retry?").
- On success: remove from list with collapse animation, Snackbar with Undo (if soft), return focus sensibly.

---

## 5. Approval workflow (form perspective)

See [screen library](../screen-library/README.md) §11 for the screen. Form/validation specifics:

- **Decision actions:** Approve (primary) · Return for changes (secondary) · Reject (`danger`).
- **Reject & Return require a comment** — the comment Text Field becomes required and focused when that action is chosen; the confirm Dialog embeds it.
- **Approve** may require: confirmation for amounts over a threshold, selecting a budget line, or acknowledging a checklist ("I have verified the attached PO").
- **Delegation / reassign:** Bottom Sheet — pick a delegate, optional note, date range for OOO.
- **Chain visibility:** vertical Stepper/timeline — completed steps (who/when/decision/comment), current (you), upcoming approvers.
- **Race conditions:** poll/refresh on screen focus; if already actioned, recalled, or expired → replace the action bar with a status Banner explaining what happened and a link back to the queue.
- **Audit:** every action writes actor, timestamp, decision, comment, and the record state hash.
- **Bulk approve:** only for low-risk, same-type items; show the combined impact (total amount, count); no bulk reject.

---

## 6. Validation

### 6.1 When to validate

| Trigger | What |
|---|---|
| On input (live) | Only: password strength, availability checks (username/email), character counters, format masking, inline calculations |
| On blur | Format and simple rules for the field just left (email shape, required-if-touched, min/max) |
| On submit | Everything, including cross-field and server rules |
| Async | Uniqueness, permission, business rules — debounce 400–600ms, show spinner in helper, don't block typing |

- **Never** show an error for a field the user hasn't reached yet.
- **Do** re-validate an errored field on the next change and clear the error as soon as it's valid (positive feedback).

### 6.2 Rule types

- **Required** — marked in the label ("Site (required)"), not by asterisk/color alone. On submit, first missing required field is focused and announced.
- **Format** — email, phone (E.164-tolerant), dates, numeric ranges, patterns (asset tag). Explain the format in helper text *first*.
- **Range / length** — min/max with clear messaging ("Between 1 and 999").
- **Cross-field** — end date ≥ start date; total = sum of lines; "at least one contact method".
- **Business / server** — budget available, no duplicate, within approval limit — returned as field-anchored errors where possible, otherwise a form-level summary.

### 6.3 Error message rules

- **Specific, human, actionable.** ✅ "Enter a date on or after today." ❌ "Invalid input." ❌ "Error 422."
- Name the fix, not just the problem.
- Present tense, no blame ("This field is required" not "You failed to…").
- Anchored to the field (below it) + summarized at the top on submit for long forms (with in-page links to each errored field).
- Announced to screen readers (`aria-describedby` + polite live region on blur; assertive summary on failed submit).

---

## 7. Error handling (system & network)

| Situation | Handling |
|---|---|
| Field validation | Inline, per §6 |
| Failed submit (validation) | Scroll to + focus first error; top summary Banner; keep all input |
| Network offline | Banner "You're offline — changes will be saved when you reconnect"; queue the submit; show pending state on the record |
| Server 5xx / timeout | Non-destructive: keep the form, Banner "Couldn't save — try again", "Retry" button, preserve input; log with a trace id shown to the user for support |
| Permission denied (403) | "You don't have permission to do this" + who to contact; don't lose their work |
| Conflict (409) | Conflict resolution UI (§4.3) |
| Session expired (401) | Silent re-auth if possible; else save draft, prompt sign-in, resume |
| Partial success (bulk) | Result summary with per-item status and a retry for failures |
| Attachment upload failed | Per-file error + retry, don't fail the whole form; allow submit without it if optional |

Principles: **the user's input is sacred** — never clear a form on error. Every error state has a way forward. Distinguish *your fault* (validation) from *our fault* (system) in tone.

---

## 8. Success handling

- **Confirm the outcome** proportionally:
  - Lightweight (toggle, inline edit) → subtle inline check + Snackbar, no interruption.
  - Standard (create/update) → close the form, Snackbar "Saved"/"Created" with a "View"/"Undo" action, land on the result, briefly highlight what changed.
  - Significant (submitted for approval, completed a workflow) → a success screen or prominent success Banner with next steps ("Submitted to <approver>. You'll be notified.") and clear exits ("View request", "Back to list", "New request").
- **Never a dead end** — always offer the obvious next actions.
- **Update the source of truth** — the list/detail the user came from reflects the change immediately (optimistic, reconciled).
- **Draft cleanup** — clear the autosaved draft on success.
- Success animation per [motion](../design-system/motion.md) §4.7 — short, non-looping, reduced-motion aware; no confetti in enterprise contexts.

---

## 9. Autosave & drafts

- Applies to: incident reports, ERP/CRM records, any form >1 screen or >2 min to complete, and anything filled in the field.
- Save locally (encrypted) on every meaningful pause (debounce 2–3s) and on background/exit.
- Sync the draft server-side when online so it survives device loss.
- On return: "You have an unsaved draft from <time>" → Resume / Discard.
- Show a subtle "Draft saved" indicator; never a blocking spinner.
- Drafts expire per policy (e.g. 30 days) with warning.

---

## 10. Accessibility checklist for forms

- [ ] Every input has a visible, programmatically associated label
- [ ] Required status in the label text, not color/asterisk alone
- [ ] Correct keyboard/`inputmode` per field
- [ ] Errors: anchored, specific, announced, and clear-on-fix
- [ ] Focus moves to the first error on failed submit; summary is navigable
- [ ] Field groups (radio/checkbox) have a group label/legend
- [ ] Touch targets ≥44dp; ≥8dp between adjacent controls
- [ ] Contrast: labels ≥4.5:1, focus ring ≥3:1, error text ≥4.5:1
- [ ] Works at 200% text scale — no clipping, no horizontal scroll
- [ ] Reduced motion honored (no shake; use border + text + subtle flash)
- [ ] Submit is reachable without dismissing the keyboard (sticky footer or "Done" affordance)
- [ ] Autofill / password managers not blocked
- [ ] Screen-reader walkthrough completes the form without confusion (test on TalkBack + VoiceOver)

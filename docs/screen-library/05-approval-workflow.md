# Screen Library · 05 · Approval Workflow

> Foundation: AMDS v1.0 · Archetypes: **C — List** (§4.C), **D — Detail** (§4.D) + **F — Confirmation** (§4.F), **H — Content/Timeline** (§4.H).
> Deeper references: screen-library §11, form-design-system §5. Entries = deltas + specifics.

Screens: Approval Queue · Approval Detail · Approval History

Shared model:
- **Actions:** Approve (primary) · Return for changes (secondary) · Reject (`danger`). **Reject & Return require a comment.**
- **Chain:** a vertical `AmdsStepper` — completed steps (actor / when / decision / comment), current step (you), upcoming approvers.
- **Race conditions** (already actioned by a peer, recalled by requester, expired, delegated) are first-class states, not errors.
- Every action is audited: actor, timestamp, decision, comment, record state.

Flow map:
```
Dashboard "Pending your approval" ─► Approval Queue ─► Approval Detail ─► [Approve|Return|Reject] ─► back to Queue (row expires)
Push / email deep link ─────────────────────────────► Approval Detail
Approval Detail ─► "History" ─► Approval History (this request's full trail)
Approval Queue ─► overflow "History" ─► Approval History (everything I've actioned)
Approval Detail ─► overflow "Delegate" ─► delegate bottom sheet
```

---

## 5.1 Approval Queue

**Archetype:** C · **Route:** `/approvals?tab=pending|delegated|all&type=&sort=`

1. **Purpose** — the prioritized list of requests awaiting the current user's decision, with just enough context to triage and (for low-risk items) act inline.
2. **User Goal** — "See what's waiting on me, in priority order, and clear it — fast for the easy ones, with detail for the rest."
3. **Layout** — C's skeleton.
   - App bar "Approvals" + filter (type: Purchase / Leave / Expense / Access…) + sort + overflow (History, Notification settings).
   - **Tabs / segmented:** Pending (default) · Delegated to me · All.
   - Optional summary strip: "3 breach SLA in 4h" (`warning` Banner) — tap → sorts SLA-risk to top.
   - **Row:** requester `AmdsAvatar(sm)` · **title + amount/type** (`titleMedium`) · requester name · department · **age** ("2d") · **SLA/priority chip** (`danger` overdue / `warning` due soon / neutral) · trailing inline **"Approve"** button (tonal, `size=sm`) for low-risk types only; others show a chevron.
   - Swipe: leading = **Approve** (`success`, low-risk only), trailing = **Open**.
   - Selection mode → **bulk Approve** (low-risk, same-type only; shows combined amount + count). **No bulk reject.**
   - Pull-to-refresh.
4. **Component Hierarchy** — C's + `AmdsSegmented(tabs)`, `AmdsBanner(slaSummary)?`, `ApprovalRow(AmdsAvatar, title, amount, requester, age, AmdsChip sla, inline AmdsButton.approve?)`, bulk bar (`Approve N` + combined total).
5. **Information Architecture** — sort by **priority then age** (SLA-risk first) by default. Row carries only what's needed to decide *whether to fast-approve or open*: what, how much, who, how old, how urgent. Amount is always visible for financial requests. Delegated items are visually tagged ("On behalf of {name}").
6. **User Flow** — C's. `open → skeleton → rows (priority order) → { low-risk: tap inline Approve → confirm (if over threshold) → button loading → row collapses out + Snackbar "Approved · Undo" (5–7s) + queue count decrements | else: tap row → Approval Detail } `. `bulk: select several low-risk same-type → "Approve 5 · Rp 12.4M" → confirm the combined impact → progress → result summary`. Filter/sort via sheet. Overflow → Approval History.
7. **States** — C's. Deltas:
   - **Loading:** `AmdsSkeletonList` (avatar + 2 text bars + chip per row).
   - **Empty:** "Nothing needs your approval 🎉" (Pending); "No delegated items" (Delegated); friendly, not a blank card.
   - **Success:** rows; SLA chips; inline actions for low-risk types; new items since last visit get a brief `primaryContainer` tint.
   - **Error:** "Couldn't load your approvals" + Retry; keep any loaded rows.
   - **Offline:** cached queue "as of HH:MM"; inline/bulk Approve → **queued** with a "Pending" chip + "Will approve when you're back online"; the row stays until synced. Reject/Return are **not** available offline (they need a comment + immediate routing) — the row opens read-only with a note.
8. **Accessibility** — C's. Row = one grouped stop: "Purchase request, 4.2 million rupiah, from S. Adeyemi, Procurement, 2 days old, due in 4 hours." SLA conveyed by chip **text** ("Due soon" / "Overdue"), not color. Inline "Approve" button labelled with the request id ("Approve PR-88120"). Bulk "Approve 5" announces the combined amount before the confirm. Result-count changes announced politely. Tabs = `tab` with position + count.
9. **Animations** — C's. Inline approve: button label → spinner → **row collapse (height→0) + fade + slide toward trailing edge**, 200ms `accelerate`; list closes the gap 200ms `standard`; Snackbar slides up. Undo → row re-expands. New item insert: expand + fade + 2s tint. Reduced-motion: row disappears with a 150ms fade, no slide.
10. **Dark Mode** — C's. SLA chips: Overdue red-400, Due soon amber-400, on-track neutral; inline Approve = `primaryContainer` (`#14532D`) + `#DCFCE7` label; selected-for-bulk row `primaryContainer` tint + `primary` left bar.
11. **Tablet** — C's list-detail: **queue left, Approval Detail right** on landscape — action the request in the right pane and the row expires from the left list in place. Portrait = single list max-640; bulk bar as a top toolbar.
12. **Developer Notes** — **all:** `RecordListConfig` scoped to `status = pending AND currentApprover = me` (+ `delegatedTo = me`); server sorts by SLA/priority; keyset pagination. Inline/bulk Approve = optimistic remove + Undo timer + rollback on failure; **idempotency key** per request (a peer may approve concurrently → 409 → row shows "Already approved by {name}", fades). Threshold check client-side (from a cached policy) triggers the confirm; server re-validates. Bulk endpoint returns per-item results. Offline queue: only Approve; store with idempotency keys; replay on reconnect; re-check state. **Compose:** `LazyColumn` + `animateItemPlacement`. **Flutter:** `PagedListView` + `RecordListConfig`. **RN:** `FlashList` + React Query mutation with `onMutate`.
13. **UX Best Practices** — priority order (SLA first). Show the amount. Fast path for low-risk, detail path for the rest. Never allow Approve without a way to see the full impact. No bulk reject. Undo over pre-confirm. Handle "already actioned by a peer" gracefully. Delegated items clearly tagged.

---

## 5.2 Approval Detail

**Archetype:** D (record) + **F** (decision bar / confirm) · **Route:** `/approvals/:id`

1. **Purpose** — give the approver everything needed to decide — summary, line items, attachments, policy context, and the approval chain — and capture the decision with an audit trail.
2. **User Goal** — "Understand exactly what I'm approving and its impact, then Approve / Return / Reject with a reason where required."
3. **Layout** — D's skeleton, decision-focused:
   - **Header:** request title · ID · **status chip** (Pending / Approved / Rejected / Returned / Recalled / Expired) · requester (avatar + name + department) · submitted date · **SLA countdown** ("Due in 4h" `warning`).
   - **Decision summary (above the fold):** the key values — **amount** (large, `displaySmall`), category, dates, budget line, cost centre — so the decision is possible without scrolling.
   - **Line items / breakdown:** a compact table (data-display) — description · qty · unit · total; footer total.
   - **Attachments:** thumbnails + open.
   - **Policy / context:** budget remaining, prior approvals in the chain, any policy flags ("Exceeds your limit — will route to Finance after you").
   - **Approval chain:** vertical `AmdsStepper` — completed (actor / decision / comment / time), **you = current**, upcoming approvers.
   - **Comments thread.**
   - **Sticky decision bar (bottom):** **Reject** (`danger` outline) · **Return for changes** (secondary) · **Approve** (primary). Reject/Return → a sheet/dialog with a **required comment**.
4. **Component Hierarchy** — D's + `RequestHeader(status chip, SLA countdown)`, `DecisionSummary(amount, key fields)`, `LineItemsTable`, `AttachmentStrip`, `PolicyContextCard`, `ApprovalChainStepper`, `CommentsThread`, `AmdsDecisionBar(onApprove, onReturn, onReject)` → `AmdsDialog` with `AmdsTextField(comment, required for reject/return)`.
5. **Information Architecture** — **decision-first:** what am I approving, how much, what's the impact, where does this sit in the chain — all above or near the fold. Supporting detail (line items, attachments, comments) below. The chain makes it clear this isn't the final approval (or that it is). Policy flags are prominent.
6. **User Flow** — D's + F's:
   ```
   enter (queue row / push / email deep link — back stack: Dashboard → Approvals → this)
     → scan header + decision summary → (optional) expand line items / attachments / policy
     → tap Approve → { over threshold or policy flag → confirm dialog (amount + "routes to Finance next" + optional required checklist ack) } → button loading
         → success → status → Approved (or "Pending Finance") → return to Queue, row expires, Snackbar "Approved" (+ Undo if policy allows a window)
     → tap Return for changes → sheet: required comment ("What needs to change?") → Submit → status → Returned → back to Queue
     → tap Reject → dialog: required comment ("Reason for rejection") + confirm → status → Rejected → back to Queue
     → race: request recalled/expired/actioned-by-peer while open → decision bar replaced by a status Banner ("Recalled by requester" / "Already approved by S. Lee" / "This request expired") + "Back to queue"
     → overflow: Delegate (sheet: pick delegate + note + date range) · View history · Contact requester
   ```
7. **States** — D's + F's:
   - **Loading:** header + decision-summary skeleton; line items + chain load after.
   - **Empty:** no attachments → "No attachments"; no comments → "No comments yet" + add.
   - **Success:** full context; decision bar enabled; after a decision → status Banner + the bar is gone.
   - **Error:** "Couldn't load this request" + Retry; invalid id → "This request no longer exists". Decision submit failure → keep the screen, inline error on the dialog + Retry, request unchanged.
   - **Offline:** cached request shown read-only; decision bar disabled with "You must be online to approve, return, or reject" (a decision routes work + notifies people — never queue silently). SLA countdown keeps running from server time.
8. **Accessibility** — D's + F's. The decision summary is a labelled region; **amount announced clearly** with currency. Line-items table = real `table` with headers + a footer total row. Approval chain steps = grouped stops ("Step 2 of 3. S. Lee approved on 2 March, comment: verified PO. You: pending."). Decision-bar buttons: "Approve request PR-88120", "Reject request PR-88120", "Return PR-88120 for changes". The required-comment field is labelled, its required state announced, errors announced. Confirm dialogs read the amount + routing consequence. Race Banners `role=alert`.
9. **Animations** — D's. Header collapse on scroll. Decision bar: stays pinned; on decision → button loading → the bar slides down + a status Banner slides in from the top (250ms). Chain: the current step pulses subtly once on load (reduced-motion: static). Line-items table expand. Reduced-motion: crossfades only.
10. **Dark Mode** — D's. Status chips translucent + -100 text; SLA countdown `warning`/`danger` -400; decision bar surface `#1E293B` + top shadow; Reject button red-400 outline; amount in `textPrimary` `#F8FAFC`; chain line `#334155`, node fills by decision (approved green-400, rejected red-400, current `primary`).
11. **Tablet** — D's. Landscape: **queue left, this detail right**; the decision bar spans the detail pane; line items + comments can be a third pane or tabs. Portrait: max-640; decision summary two-column.
12. **Developer Notes** — **all:** poll / refresh on screen focus + subscribe (if realtime) so recalled/expired/peer-actioned states surface promptly. Decision endpoints: `POST /approvals/:id/{approve|return|reject}` with `{ comment?, ack? }` + idempotency key; server returns the new status + next approver + audit id. Threshold + policy flags come from a request-scoped `policy` object (don't recompute business rules client-side — display them). Reject/Return **must** send a comment (client-enforced + server-enforced). Delegation writes an OOO/delegate record. **Never** allow a decision without the full amount being visible. Deep link `/approvals/:id` synthesizes `[dashboard, approvals, detail]`. **Compose/Flutter/RN:** framework §5.2 D + a pinned bottom bar; the confirm dialog embeds the comment field.
13. **UX Best Practices** — decision + impact above the fold. Never Approve blind to the amount. Reject/Return always capture a reason (goes to the requester). Show the full chain and where this sits. Handle races with a clear state, not an error. After a decision: return to the queue, expire the row, Snackbar. Support delegation + OOO. Everything audited. Online-only for decisions.

---

## 5.3 Approval History

**Archetype:** H (timeline) / C (filterable log) · **Route:** `/approvals/history?scope=mine|request:<id>&decision=&type=&range=`

1. **Purpose** — an auditable, filterable record of approval decisions — either for **one request** (its full lifecycle) or for **the current user** (everything they've actioned), for accountability, dispute resolution, and reporting.
2. **User Goal** — "See what happened to this request (or what I decided and when), with the reasons, and jump to any of it."
3. **Layout** — two modes:
   - **Request history** (from Approval Detail → "History"): a full-width **vertical timeline** (`AmdsStepper`) — Submitted → each approval step → final outcome. Each entry: actor `AmdsAvatar(xs)` · action ("Approved" / "Returned" / "Rejected" / "Recalled" / "Delegated to …" / "Commented") · timestamp (absolute + relative) · comment/reason (`bodyMedium`) · optional "what changed" (for resubmissions). Header shows the request title + current status.
   - **My history** (from Queue overflow): a **C-style list** — filter chips (Decision: Approved/Rejected/Returned · Type · Date range) + count; **row** = request title + amount · requester · **my decision chip** · date actioned; tap → that request's Approval Detail (read-only if closed) or its Request history.
4. **Component Hierarchy** — Request mode: `H` → `AmdsStepper(vertical, readOnly)` with `HistoryEntry` nodes. My mode: `C` → `AmdsSearchField?` + `FilterChipRow` + `ListView(HistoryRow)`. Both: `AmdsEmptyState`, export in overflow.
5. **Information Architecture** — chronological (request mode: submission → outcome; my mode: most recent first). Every entry has **actor + action + time + reason**. Immutable — this is an audit log; no edit/delete. Resubmission cycles are visually grouped ("Returned → Resubmitted v2 → Approved"). Amounts and the decision are always shown in my-history rows.
6. **User Flow** — `Request mode: scroll the timeline → tap an entry → the related artifact (the version submitted, the comment thread, the resubmission diff)`. `My mode: filter (e.g. Decision = Rejected, last quarter) → row → Approval Detail (read-only) → back preserves the filter`. Overflow → Export (→ §07 Export pattern; a CSV/PDF of the filtered log with actor, decision, reason, timestamp).
7. **States** —
   - **Loading:** Request mode → 3–4 timeline-node skeletons. My mode → `AmdsSkeletonList`.
   - **Empty:** Request mode → "Only the submission so far" (shows just the first node). My mode → "You haven't actioned any approvals yet" / "Nothing matches these filters" + "Clear filters".
   - **Success:** full timeline / filtered list + count.
   - **Error:** "Couldn't load history" + Retry.
   - **Offline:** cached history shown "as of HH:MM" (history is append-only so cache is safe); export disabled offline.
8. **Accessibility** — timeline entries = grouped stops in order ("2 March, 9:12 AM. S. Lee approved. Comment: verified the PO against the contract."). The timeline is an ordered list; `aria-current` on the final/outcome node. My-history rows announce "request, amount, my decision, date". Decision conveyed by chip **text**. Filter count changes announced. Export confirms format + that it's a download.
9. **Animations** — Request mode: entries fade+riseY staggered 30ms on first paint (≤8). My mode: C's list stagger. Tapping an entry → shared-axis to the artifact. Reduced-motion: no stagger, fade only.
10. **Dark Mode** — timeline line `#334155`; node fills by decision (Approved green-400, Rejected red-400, Returned amber-400, Commented/neutral `#64748B`); my-decision chips translucent + -100 text; resubmission-group divider subtle.
11. **Tablet** — Request mode: wider timeline, the comment/"what changed" column expanded; landscape can pair it beside the Approval Detail as a third pane. My mode: C's list-detail (log left, read-only Approval Detail right).
12. **Developer Notes** — **all:** history is a **read model over the audit/event store** — never derived from the current record state; each event is immutable with `{ actor, action, timestamp (server), comment, fromState, toState, requestVersion, correlationId }`. Request mode: `GET /approvals/:id/history`. My mode: `GET /approvals/history?actor=me&decision=&type=&range=` with keyset pagination. Group resubmission cycles by `requestVersion`. Export = server-generated report of the filtered set, delivered per §07. Timestamps in the user's timezone, consistent format, with the raw ISO available on long-press for disputes. **Compose:** `LazyColumn` timeline with a leading connector `Canvas`. **Flutter:** a custom `TimelineTile` list / `AmdsStepper(vertical)`. **RN:** `FlashList` with a connector view.
13. **UX Best Practices** — immutable, complete, chronological. Every entry shows who + what + when + why. Group resubmission cycles. Link entries to their artifacts. Make it exportable for audits. Show reasons prominently (that's the point of the log). Preserve filters on back. Keep timestamps unambiguous (timezone + raw on demand).

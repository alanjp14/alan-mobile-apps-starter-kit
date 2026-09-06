# Template · Approval Workflow — `[MODULE_NAME]`

> Archetypes **C — List** (inbox) · **D — Detail** + **F — Confirmation** (decision) · **H — Timeline** (history). Full reference: [`../../docs/screen-library/05-approval-workflow.md`](../../docs/screen-library/05-approval-workflow.md). Feature: [`../../docs/feature-library/02-workflow.md`](../../docs/feature-library/02-workflow.md).

---

## Shared model
- Actions: **Approve** (primary) · **Return for changes** (secondary) · **Reject** (`danger`). Reject & Return **require a comment**.
- Chain: vertical `AmdsStepper` — completed steps (actor / when / decision / comment), current (you), upcoming approvers.
- Races (peer-actioned, recalled, expired, delegated) are first-class states, not errors.
- Every action audited: actor, timestamp, decision, comment, record state. **Decisions are online-only.**

## Routes
`/approvals?tab=pending|delegated|all` · `/approvals/{id}` · `/approvals/history?scope=mine|request:<id>`

## 1. Approval Inbox

```
[ App bar: "Approvals" · filter(type) · sort · overflow(History) ]
[ Segmented: Pending · Delegated to me · All ]
[ Banner: "N breach SLA in Xh" ]  ← when applicable
[ list: rows sorted priority → age ]
   requester avatar · [request title] + [amount/type] · requester · age · SLA chip · [inline Approve for low-risk types]
swipe: leading Approve (low-risk)  trailing Open
selection → bulk Approve (low-risk, same-type; shows combined total). No bulk reject.
```

## 2. Approval Detail

```
[ App bar: back · title + ID · status chip · overflow(Delegate, History, Contact requester) ]
[ Header: requester · submitted date · SLA countdown ]
[ DECISION SUMMARY (above the fold): amount (displaySmall) · category · dates · budget line ]
[ Line items table ] [ Attachments ] [ Policy/context card ]
[ Approval chain (AmdsStepper vertical) ]
[ Comments thread ]
[ Sticky DecisionBar: Reject (danger outline) · Return (secondary) · Approve (primary) ]
```

Reject/Return → dialog with a **required comment**. Approve over threshold/policy → confirm dialog (amount + "routes to `[next approver]` next" + optional checklist ack).

## 3. Approval History
Request mode: vertical timeline (Submitted → each step → outcome), each entry = actor · action · timestamp · comment. My mode: filterable list (Decision · Type · Date range) → row → read-only Approval Detail. Immutable; exportable.

## States
- **Loading:** inbox → skeleton rows; detail → header + decision-summary skeleton.
- **Empty:** "Nothing needs your approval 🎉".
- **Success:** rows/detail; after a decision → status Banner, decision bar gone.
- **Error:** "Couldn't load your approvals" + Retry; invalid id → "This request no longer exists". Decision submit fail → keep screen, inline error + Retry, request unchanged.
- **Offline:** inbox cached; inline/bulk Approve **queues** with a Pending chip; **Reject/Return unavailable offline** (need a comment + immediate routing) — row opens read-only with a note. Decision bar disabled on the detail with "You must be online to approve, return, or reject."
- **No-permission / race:** decision bar replaced by a Banner ("Recalled by requester" / "Already approved by `[name]`" / "This request expired") + "Back to queue".

## Accessibility
Inbox row = grouped stop ("Purchase request, `[amount]`, from `[requester]`, `[dept]`, `[age]` old, due in `[time]`"). SLA by chip **text**. Inline "Approve" button labelled with the request id. Decision-bar buttons name the request. Line-items = real `table` + footer total. Chain steps = grouped stops. Race Banners `role=alert`.

## Developer notes
`RecordListConfig` scoped to `status=pending AND currentApprover=me`. Decision endpoints `POST /v1/approvals/{id}/{approve|return|reject}` with `{comment?, ack?}` + `Idempotency-Key` → returns new status + next approver + audit id. "any 1 of N" steps use a DB transaction/row-lock → the loser gets 409. Refresh on screen focus + subscribe to `approval.*` events. **Never** allow a decision without the full amount visible. Deep link `/approvals/:id` synthesizes `[dashboard, approvals, detail]`.

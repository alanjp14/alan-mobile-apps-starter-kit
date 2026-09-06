# Feature Library · 02 · Approval Workflow

> Foundation: AMDS v1.0 · Inherits [`00-framework.md`](00-framework.md). Feature: **Approval Workflow**.

---

## Feature: Approval Workflow

### 1. Purpose
A reusable engine that routes a business object (purchase request, leave, expense, access request, document, change) through a configurable chain of approvers, captures decisions with reasons and an audit trail, enforces SLAs and delegation, and notifies the right people — so any "someone must approve this" process is built by configuration, not new code.

### 2. Business Flow
1. **Submit** — a requester creates the object (Data Management / a domain form) and submits it. The workflow engine evaluates a **routing policy** (rules on amount, category, cost centre, org unit) → produces an ordered **approval chain** of one or more steps (each step = a rule for *who* can approve: a named user, a role, the requester's manager, a group with "any 1 of N" or "all of N").
2. **Notify** — step 1's approver(s) are notified (push + in-app + email); the item appears in their **Approval Queue**; an SLA timer starts.
3. **Decide** — an approver **Approves** (→ next step, or final approval), **Rejects** (→ terminal, back to requester with a reason), or **Returns for changes** (→ requester edits and resubmits, optionally restarting the chain or resuming). Reject/Return require a comment.
4. **Escalate / delegate** — if a step breaches its SLA → escalate to a backup approver / the approver's manager, and re-notify. Approvers can delegate (OOO) to a colleague for a date range.
5. **Complete** — final approval → the object's status becomes `approved`; downstream automation fires (e.g. PO issued, leave booked, access granted) via an event.
6. **Exceptions** — the requester can **recall** a pending item; an admin can **reassign** or **force-close**; concurrent approval by a peer in an "any 1 of N" step short-circuits the others.
7. **Audit & report** — every transition is recorded; cycle-time and approval-rate metrics feed Dashboard Analytics.

### 3. UX Flow
```
Requester: Create form → Submit → "Submitted to {approver}. You'll be notified." → track on the object's Detail (chain stepper)
Approver:  Push / Dashboard "Needs you" / Bottom-nav badge → Approval Queue (priority order, SLA chips)
   → inline Approve (low-risk)  → confirm if over threshold → row expires + Undo
   → tap → Approval Detail (amount, line items, attachments, policy context, chain) 
        → Approve  → (threshold/policy? confirm) → next step or done
        → Return for changes → required comment → back to requester
        → Reject → required comment → terminal
        → overflow: Delegate · View history · Contact requester
   → race (recalled / expired / peer-approved) → status Banner, back to queue
History: Approval Detail "History" / Queue overflow "History" → Approval History (timeline / filterable log) → Export
```
Screens: [`../screen-library/05-approval-workflow.md`](../screen-library/05-approval-workflow.md).

### 4. Screen Mapping
| Screen | Route | Template |
|---|---|---|
| Approval Queue | `/approvals?tab=pending\|delegated\|all` | 05 §5.1 (Archetype C) |
| Approval Detail | `/approvals/:id` | 05 §5.2 (D + F decision bar) |
| Approval History | `/approvals/history?scope=mine\|request:<id>` | 05 §5.3 (H timeline / C log) |
| Delegate / OOO | bottom sheet | 05 §5.2 |
| Reassign / Force-close (admin) | dialog | Archetype F |
| Object Detail (chain view) | `/{type}/:id?tab=approvals` | screen-library 04 §4.2 |

### 5. Required Components
List/ListTile + Avatar + Badge/Chip (SLA, status) ([16 §9,14,15](../component-library/api-reference.md)) · Segmented (tabs) · Banner (SLA summary, race states) · Timeline / Stepper (approval chain) [16 §17](../component-library/api-reference.md) · Table (line items) [16 §9](../component-library/api-reference.md) · Dialog + required comment field (decision) [16 §7,3](../component-library/api-reference.md) · Bottom Sheet (delegate) [16 §6](../component-library/api-reference.md) · Snackbar (Undo) [16 §12](../component-library/api-reference.md) · KPI cards (cycle-time on the object). Feature composites: `ApprovalChainStepper`, `DecisionBar`, `SlaCountdown`, `PolicyContextCard`.

### 6. Database Entity Suggestions
| Entity | Key columns | Notes |
|---|---|---|
| `workflow_definition` | `id, tenant_id, key (e.g. purchase_request), name, version, active` | one per approvable type |
| `routing_rule` | `id, definition_id, order, condition (jsonb: amount/category/orgUnit predicates), step_template (jsonb: approverType, quorum, sla)` | evaluated in order → builds the chain |
| `approval_request` | `id, tenant_id, definition_id, subject_type, subject_id, requester_id, status (pending/approved/rejected/returned/recalled/expired/cancelled), amount, currency, current_step_no, submitted_at, completed_at, sla_due_at, version` | the workflow instance |
| `approval_step` | `id, request_id, step_no, name, approver_type (user/role/manager/group), approver_ref, quorum (any1/allN), status, sla_due_at, started_at, completed_at` | |
| `approval_assignment` | `id, step_id, assignee_id, state (pending/actioned/skipped/delegated), delegated_from?, delegated_to?` | who specifically must act |
| `approval_action` | `id, request_id, step_id, actor_id, decision (approve/reject/return/comment/recall/reassign/delegate), comment, from_state, to_state, request_version, created_at` | **append-only** audit spine |
| `delegation` | `id, tenant_id, delegator_id, delegate_id, definition_key?, starts_at, ends_at, reason` | OOO |
| `approval_line_item` | `id, request_id, description, qty, unit_price, total` | (or store on the subject) |

Indexes: `approval_assignment(assignee_id, state)` (the queue query), `approval_request(tenant_id, status, sla_due_at)` (SLA sweeps), `approval_action(request_id, created_at)` (history), `approval_step(request_id, step_no)`.

### 7. API Endpoint Suggestions
| Method · Path | Purpose | AuthZ |
|---|---|---|
| `POST /v1/approvals` | submit a subject into a workflow (`{definitionKey, subjectId, payload}`) → builds the chain | `<subject>:submit` |
| `GET /v1/approvals?assignee=me&tab=pending\|delegated&filter[type]=&sort=slaDueAt&cursor=` | the queue | authenticated (server scopes to assignee) |
| `GET /v1/approvals/{id}` | detail (`?expand=steps,lineItems,attachments,policy,history`) | must be a participant or have `approvals:read` |
| `POST /v1/approvals/{id}/approve` | `{comment?, ack?}` + `Idempotency-Key` | must be a pending assignee on the current step |
| `POST /v1/approvals/{id}/return` / `/reject` | `{comment}` (required) | same |
| `POST /v1/approvals/{id}/recall` | requester withdraws | requester only, while `pending` |
| `POST /v1/approvals/{id}/reassign` / `/force-close` | admin overrides `{toUserId \| reason}` | `approvals:admin` |
| `POST /v1/approvals/{id}/delegate` | delegate this item | current assignee |
| `GET /v1/approvals/{id}/history` | full transition log | participant / `approvals:read` |
| `GET /v1/approvals/history?actor=me&decision=&type=&range=&cursor=` | "my decisions" log | authenticated |
| `POST /v1/approvals/bulk-approve` | `{ids[]}` low-risk same-type → per-item results | assignee on each |
| `GET/POST/DELETE /v1/me/delegations` | OOO management | self |
| `GET /v1/workflow-definitions` · `PUT …/{id}/rules` | admin config | `workflow:admin` |
| **Realtime**: `approval.assigned`, `approval.decided`, `approval.recalled`, `approval.escalated` events on the user channel | queue updates in place | — |

### 8. State Management Suggestions
- `ApprovalQueueController` — `RecordListConfig` over `/approvals?assignee=me`; server-sorted by SLA/priority; optimistic inline-approve (remove + Undo timer + rollback); an `Idempotency-Key` per request id; subscribes to `approval.*` events to update counts/rows in place.
- `ApprovalDetailController` — loads `?expand=...`; on screen focus **refreshes** (catch recalled/expired/peer-actioned); the decision action is a mutation that returns the new status + next assignee.
- The dashboard "Needs you" block + the bottom-nav "Approvals" badge read a shared `pendingApprovalCountProvider` (from the queue query or a lightweight `GET /approvals/count`).
- Decisions are **online-only** (they route work + notify) — the controller disables the decision bar offline and shows a read-only banner.
- Delegations cached in a `myDelegationsProvider`.

### 9. Jetpack Compose Implementation Suggestions
- `:feature:approvals`. Queue: Paging 3 + `LazyColumn` with `animateItemPlacement()`; inline `AmdsButton` in the row; `SwipeToDismissBox` for swipe-approve.
- Detail: `Scaffold(bottomBar = { DecisionBar(...) })`; `ApprovalChainStepper` as a `Column` with a `Canvas` connector; line items in a scrollable `DataTable`-like composable.
- Realtime: a `WorkflowEventsRepository` exposing a `Flow<ApprovalEvent>` (OkHttp WebSocket) collected in the VM to invalidate/patch state.
- Confirm dialogs embed the required comment `OutlinedTextField`.

### 10. Flutter Implementation Suggestions
- `feature_approvals`. Queue: `PagedListView` + `RecordListConfig`; `Dismissible` swipe-approve; Riverpod `AsyncNotifier`.
- Detail: `Scaffold(bottomNavigationBar: DecisionBar(...))` or a `Positioned` sticky bar; `ApprovalChainStepper` via `timeline_tile` or custom `CustomPaint`.
- Realtime: `web_socket_channel` → a `StreamProvider<ApprovalEvent>` → `ref.listen` to invalidate `approvalQueueProvider` / patch `approvalDetailProvider`.
- `AmdsDialog` for decisions with a `TextFormField` (validator: required for reject/return).

### 11. React Native Implementation Suggestions
- `features/approvals`. Queue: `FlashList` + React Query infinite; `Swipeable`; `useMutation` with `onMutate` optimistic removal.
- Detail: a sticky `<DecisionBar/>` (absolute, safe-area aware); `<ApprovalChainStepper/>` with `react-native-svg` connectors.
- Realtime: a WebSocket client (`reconnecting-websocket`) → dispatches to React Query cache updates (`queryClient.setQueryData` / `invalidateQueries`).
- Decision modal: `<AmdsDialog/>` + `react-hook-form` (comment required for reject/return).

### 12. Security Considerations
- **Every decision endpoint re-verifies**: the actor is a *pending assignee on the current step* of *this* request in *this* tenant — never trust the client's "I can approve" UI.
- **Amount visibility** — an approver must always be shown the full amount/impact; the server includes it in the detail payload and logs that it was served before the decision.
- **Reject/Return comments are mandatory** server-side (not just client validation) and are returned to the requester.
- **Idempotency + concurrency** — `Idempotency-Key` dedupes double-taps and offline replays; an "any 1 of N" step uses a DB transaction/row-lock so a peer's concurrent approval cleanly short-circuits (the loser gets a 409 → "already approved by …").
- **Recall race** — recall and approve on the same request serialize on the request row; whichever commits first wins, the other gets a clear conflict state.
- **Delegation abuse** — a delegate inherits only the delegator's authority for the specified definitions/date range; delegation itself is audited; self-approval via delegation loops is blocked.
- **Routing tampering** — the chain is computed server-side from `routing_rule`s; the client cannot specify approvers. Admin overrides (`reassign`, `force-close`) require `approvals:admin` + step-up + a reason and are prominently audited.
- **Notification content** — push/email payloads carry only a title + a deep link, never the amount or sensitive details (fetched after auth in-app).
- **SoD** — the engine refuses to route to an approver who is the requester or who has a conflicting permission (e.g. created the PO).

### 13. Scalability Considerations
- **The queue query** (`approval_assignment WHERE assignee_id = ? AND state = 'pending'`) is the hot read — a covering index + Redis cache of the count per user (invalidated on assign/decide events).
- **SLA sweeps** — a scheduled job scanning `approval_request WHERE status='pending' AND sla_due_at < now()` for escalation: index it, run per-tenant in batches, drive escalation via events not inline.
- **Chain building** — evaluate routing rules in a bounded, cached rules engine; cap chain length; precompute "manager of X" via the org tree cache.
- **Fan-out on submit** — notifications + assignment creation happen async off a `approval.submitted` event; the submit response returns as soon as the request row + first step exist.
- **History/analytics** — `approval_action` is append-only and grows fast: partition by month; project cycle-time metrics into the analytics warehouse via the outbox rather than aggregating the OLTP table.
- **Realtime** — one pub/sub topic per user; the WebSocket layer scales horizontally with a shared broker (Redis/NATS); fall back to polling the queue every 30–60s if the socket drops.
- **Bulk approve** — process items in a queued job with per-item idempotent calls; return a job id and stream progress.
- Config-driven design means new approvable types add rows to `workflow_definition`/`routing_rule`, not new services — the engine scales once for all.

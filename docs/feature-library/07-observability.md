# Feature Library · 07 · Observability (Audit & Activity)

> Foundation: AMDS v1.0 · Inherits [`00-framework.md`](00-framework.md). Features: **Audit Logs · Activity Timeline**.

> These are two views over the same underlying event stream. **Audit Logs** = the tamper-evident, compliance-grade record (admin/security/auditor audience, "who did what to what, when, from where"). **Activity Timeline** = the friendly, contextual, per-entity or per-user feed (end-user audience, "what's been happening here").

---

## Feature: Audit Logs

### 1. Purpose
An append-only, tamper-evident, queryable record of every security- and data-significant action across the system — for compliance (SOC 2, ISO 27001, GDPR Art. 30), incident investigation, dispute resolution, and access reviews — retained per policy and exportable for auditors.

### 2. Business Flow
1. **Emit** — every service, in the **same transaction** as a state change, writes an audit event (transactional outbox pattern) capturing: actor, action, target resource, tenant, before/after (or a diff), source (IP, device, app version, `traceId`), and result.
2. **Collect** — an audit consumer reads the outbox/bus, validates the event shape, and appends it to the **audit store** (write-once). Events are hash-chained (each record includes the hash of the previous) so any deletion/alteration is detectable.
3. **Query** — auditors/admins search the log by actor, target, action type, date range, tenant, IP, or `traceId`; results are paginated and exportable.
4. **Alert** — high-risk events (permission grants, exports of PII, failed-then-successful logins, admin overrides, bulk deletes) trigger real-time alerts to security.
5. **Retain & archive** — hot storage for N months (fast query), cold archive (object storage, immutable/WORM) for the full retention period (often 7 years); legal hold overrides expiry.
6. **Review** — periodic access-certification campaigns and anomaly reports are built on the audit data.

### 3. UX Flow
```
Admin/Security area → Audit Logs
  → filter bar: actor · action type · resource type · date range · tenant · IP · outcome
  → results list: [icon] actor "performed" action "on" target — timestamp — outcome chip
  → tap → Audit Event Detail: full context, before/after diff, source (device/IP/geo/traceId), related events (same traceId), link to the affected record
  → "Export" → CSV/PDF of the filtered set (for the auditor) → async → secure link
Investigation: paste a traceId → all correlated events across services in order
Entity-scoped: from any record's Detail → "Audit" tab → that record's audit events only
```
Screens: an admin **Audit Log List** (Archetype C) + **Audit Event Detail** (Archetype D) + a record-scoped **Audit tab** (in Data Detail).

### 4. Screen Mapping
| Screen | Route | Template |
|---|---|---|
| Audit Log List | `/admin/audit?actor=&action=&resource=&range=&cursor=` | Archetype C (filter-heavy) |
| Audit Event Detail | `/admin/audit/:eventId` | Archetype D + H (diff + context) |
| Record Audit tab | `/{type}/:id?tab=audit` | Data Detail (04 §4.2), Timeline component read-only |
| Trace view | `/admin/audit?traceId=` | Archetype C grouped by service/time |
| Audit export | `/export?source=audit&…` | 07 §7.3 Export Screen |

### 5. Required Components
List/ListTile + Avatar + Badge/Chip (outcome, action type) [16 §9,14,15](../component-library/api-reference.md) · Search + Filter sheet (Search & Filter feature §05) · Date range picker [16 §3](../component-library/api-reference.md) · Timeline (record-scoped / trace view) [16 §17](../component-library/api-reference.md) · Table / key-value diff (before/after) [16 §9](../component-library/api-reference.md) · Code/mono block (raw payload, `traceId`) · Export sheet. Feature composites: `AuditEventRow`, `BeforeAfterDiff`, `TraceGroup`.

### 6. Database / Store Suggestions
| Store | Contents | Notes |
|---|---|---|
| `audit_event` (append-only) | `id (uuid v7), tenant_id, occurred_at, actor_id, actor_type (user/service/system), action (verb.noun e.g. role.grant), resource_type, resource_id, outcome (success/denied/error), source_ip, source_geo, device_id, user_agent, app_version, trace_id, correlation_id, diff (jsonb: {field:{old,new}}), context (jsonb), prev_hash, hash` | **no updates, no deletes**; `hash = H(prev_hash ‖ canonical(event))` |
| `audit_event` storage | partitioned by month; primary in Postgres (recent) + streamed to a columnar store / SIEM for query at scale; archived to **WORM object storage** (S3 Object Lock) for the retention window | |
| `audit_alert_rule` | `id, name, match (jsonb: action patterns, thresholds), severity, channel` | high-risk detection |
| `legal_hold` | `id, scope (tenant/user/resource), reason, placed_by, placed_at, released_at?` | overrides retention |
| `audit_export` | an `export_job` (Reports feature) with `source = audit` + the filter params | |

Indexes: `audit_event(tenant_id, occurred_at DESC)`, `(actor_id, occurred_at)`, `(resource_type, resource_id, occurred_at)`, `(trace_id)`, `(action, occurred_at)`.

### 7. API Endpoint Suggestions
| Method · Path | Purpose | AuthZ |
|---|---|---|
| `GET /v1/audit?actor=&action=&resourceType=&resourceId=&outcome=&from=&to=&traceId=&cursor=` | query the log | `audit:read` (auditor/security/admin) |
| `GET /v1/audit/{eventId}` | full event + hash-chain verification result + related-by-trace | `audit:read` |
| `GET /v1/{resourceType}/{id}/audit?cursor=` | record-scoped events | the record's read permission + `audit:read-scoped` |
| `POST /v1/audit/export` | async export of a filtered set (CSV/PDF/JSON) | `audit:export` |
| `GET /v1/audit/verify?from=&to=` | verify the hash chain over a range (integrity check) | `audit:read` |
| `GET/POST /v1/audit/alert-rules` | manage detection rules | `security:admin` |
| `POST /v1/internal/audit` | (internal only) ingest an audit event | service mTLS |
| **No** create/update/delete for end users — audit is written by services, never by the client | | |

### 8. State Management Suggestions
- `AuditLogController` (Archetype C) — heavy filters via the Search & Filter `SearchFilterController`; keyset pagination; results are **read-only** (no mutations, no optimistic anything).
- `AuditEventDetailController` — loads the event + `verifyChain` result + `relatedByTrace`; renders `BeforeAfterDiff` from the `diff` jsonb.
- `RecordAuditTabController` — a scoped query `GET /{type}/{id}/audit`; a read-only `AmdsTimeline`.
- Export uses the Reports/Export feature's `ExportController`.
- Client caching is fine (audit is immutable) — cache pages by filter tuple; no invalidation needed except "new events since".

### 9. Jetpack Compose Implementation Suggestions
- `:feature:audit` (admin module, often a separate build flavor / permission-gated entry). Paging 3 + `LazyColumn`; the filter bar reuses `:core:search`.
- `BeforeAfterDiff` = a `LazyColumn` of rows `field | old (strikethrough) → new`; JSON via `kotlinx.serialization` + a pretty-printer for the raw payload.
- Trace view: group the paged list by `resource_type`/service with sticky headers, ordered by `occurred_at`.
- Chain verification result shown as a `Banner` (✓ intact / ✗ tampered at event X).

### 10. Flutter Implementation Suggestions
- `feature_audit`. `PagedListView` + a `FilterSheet(FilterSchema)`; `data_table_2` for the diff or a custom key-value list.
- `AmdsTimeline(variant: feed)` for record-scoped and trace views.
- Raw payload in a `SelectableText` mono block; `flutter_syntax_view` optional.
- Verify-chain result in an `AmdsBanner`.

### 11. React Native Implementation Suggestions
- `features/audit`. `FlashList` + React Query infinite; the Search & Filter hooks for the filter bar.
- `<BeforeAfterDiff/>` from the `diff` object; raw JSON in a `<CodeBlock/>` (monospace, selectable).
- Trace view: `SectionList` grouped by service.
- Chain verification badge/banner.

### 12. Security Considerations
- **Immutability** — `audit_event` is append-only at the DB level (revoke UPDATE/DELETE for the app role; use a dedicated write-only service account); archive to WORM/Object-Lock storage; the hash chain (`prev_hash`/`hash`) makes any tampering detectable and a `verify` endpoint proves integrity to auditors.
- **Write path integrity** — audit events are written **in the same transaction** as the change (transactional outbox) so you can't have a state change without its audit record; a failed audit write fails the operation for high-assurance actions.
- **Separation of duties** — those who can *read* audit (`audit:read`) are distinct from those who administer the system; no one can edit or delete audit; even super-admins' actions are audited (and reading audit is itself an audited action).
- **Least exposure** — audit contains sensitive context (IPs, diffs with PII); `audit:read` is a rare, reviewed permission; record-scoped audit (`?tab=audit`) shows a redacted subset appropriate to the record's readers; PII in diffs is masked for non-privileged viewers.
- **No client writes** — the mobile app never POSTs audit events; it only reads. Client-side "activity" it wants recorded is achieved by the server auditing the API calls it makes.
- **Retention & erasure tension** — GDPR erasure vs audit retention: keep the audit record but tombstone/pseudonymize the subject's PII after erasure while preserving the actor/action/timestamp for integrity; legal hold suspends erasure.
- **Alerting** — high-risk patterns (mass export, permission escalation, off-hours admin actions, repeated `denied` then `success`) alert security in real time via `audit_alert_rule`.
- **Time integrity** — servers use NTP-synced UTC; store `occurred_at` server-side, never trust a client clock.

### 13. Scalability Considerations
- **Write volume is high and spiky** — buffer through the event bus; the audit consumer batches inserts; partition `audit_event` by month (drop/archive old partitions); the hot Postgres table holds only recent months.
- **Query at scale** — stream events to a purpose-built store (OpenSearch / ClickHouse / a SIEM like Splunk/Elastic) for auditor queries; Postgres serves recent + record-scoped lookups via indexes.
- **Archival** — lifecycle rules move partitions to compressed WORM object storage; a query facade can rehydrate on demand for investigations.
- **Hash chain** — chaining per-tenant (or per-partition) rather than globally avoids a single serialization bottleneck; verification runs as a batch job + on-demand for a range.
- **Fan-out isolation** — audit ingestion is decoupled; a spike in audit volume must never slow the primary transaction path (async consumer, bounded queue, backpressure to a dead-letter, alert on lag).
- **Cost** — audit is write-heavy, read-light: cheap columnar/append storage; compress aggressively; sample nothing (audit must be complete) but keep event payloads lean (diffs, not full snapshots; reference large blobs).

---

## Feature: Activity Timeline

### 1. Purpose
A human-readable, contextual feed of recent activity — scoped to a record ("what's happened to this work order"), a user ("what I've been doing" / "what my team did"), or a workspace ("recent activity" on the dashboard) — so users have situational awareness without needing the raw audit log. Built from the same events, presented for end users.

### 2. Business Flow
1. **Derive** — a projection consumer reads the same domain events the audit log consumes and produces **activity items**: a friendly sentence template (`{actor} {verb} {object} {qualifier}`), an icon, a category, the target's deep link, and visibility rules (who should see this item).
2. **Scope & filter** — items are indexed by their subjects (`record:<id>`, `user:<id>`, `team:<id>`, `workspace`) and by visibility (a comment on a private record isn't in a colleague's feed).
3. **Aggregate** — noisy sequences collapse ("edited 4 fields", "3 comments"); consecutive same-actor same-object edits within a window merge.
4. **Consume** — feeds appear on the Dashboard ("Recent activity"), on record Detail ("Activity" tab), on Profile ("My activity"), and on team views; each item links to its source.
5. **Realtime** — new items append live (with a brief highlight) where a feed is on screen.
6. **Retention** — activity items have a shorter retention than audit (e.g. 90–365 days) and can be regenerated from events if needed.

### 3. UX Flow
```
Dashboard "Recent activity" (≤5 + "View all") → Activity feed (grouped by day)
Record Detail → "Activity" tab → that record's timeline (vertical, actor + action + time + note)
Profile → "My activity" → the user's own recent actions
Team lead → "Team activity" → filterable by member / type / date
  → tap an item → the related record / comment / version
  new item arrives while viewing → inserts at top with a 2s tint
```
Screens: Dashboard block ([`../specs/dashboard.md`](../specs/dashboard.md)), Data Detail Activity tab ([`../screen-library/04-data-management.md`](../screen-library/04-data-management.md) §4.2), Profile ([`../screen-library/08-profile.md`](../screen-library/08-profile.md) §8.1), Approval History ([`../screen-library/05-approval-workflow.md`](../screen-library/05-approval-workflow.md) §5.3).

### 4. Screen Mapping
| Surface | Route | Template |
|---|---|---|
| Dashboard "Recent activity" | `/dashboard` block | specs/dashboard.md |
| Full activity feed | `/activity?scope=workspace\|team:<id>&filter=` | Archetype C (H timeline) |
| Record Activity tab | `/{type}/:id?tab=activity` | 04 §4.2 + Timeline component |
| My activity | `/profile` (section) or `/activity?scope=user:me` | 08 §8.1 |

### 5. Required Components
Timeline Components (feed / stepper) [16 §17](../component-library/api-reference.md) · List/ListTile + Avatar (actor) + mini Profile [16 §9,15,16](../component-library/api-reference.md) · Section headers (date buckets) · Chips (activity category filter) · Empty state ("No activity yet") · Pull-to-refresh · Skeleton (timeline). Feature composites: `ActivityItem`, `ActivityFeed(scope)`, `DateBucketHeader`.

### 6. Database / Store Suggestions
| Store | Contents | Notes |
|---|---|---|
| `activity_item` | `id, tenant_id, occurred_at, actor_id, category, verb, object_type, object_id, object_label, qualifier, template_key, deep_link, visibility (jsonb: audience rules or a denormalized `visible_to` set), group_key, source_event_id` | the projection |
| `activity_subject` | `activity_id, subject_key (record:<id> \| user:<id> \| team:<id> \| workspace)` | fan-out index for scoped feeds |
| `activity_read_state` (optional) | `user_id, feed_scope, last_seen_at` | "new since" highlighting |
| Store choice | Postgres (partitioned by month) for moderate volume; a feed store (Cassandra/DynamoDB with a per-subject partition key) for very high volume | |

Indexes: `activity_subject(subject_key, activity_id)` joined to `activity_item(occurred_at DESC)`; `activity_item(actor_id, occurred_at)`.

### 7. API Endpoint Suggestions
| Method · Path | Purpose | AuthZ |
|---|---|---|
| `GET /v1/activity?scope=workspace\|team:<id>\|user:<id>\|record:<type>:<id>&filter[category]=&cursor=` | a scoped, paginated feed | must have read access to the scope; server applies per-item visibility |
| `GET /v1/{type}/{id}/activity?cursor=` | convenience alias for a record feed | the record's read permission |
| `GET /v1/activity/summary?scope=` | counts / "N new since last visit" | as feed |
| **Realtime**: `activity.created` events on subject channels the client subscribes to (the record it's viewing, its dashboard scope) | live prepend | — |

### 8. State Management Suggestions
- `ActivityFeedController(scope)` — a `RecordListConfig`-style paged query; groups by day client-side; subscribes to `activity.created` for the current scope → prepend with a 2s highlight (respect reduced-motion).
- The Dashboard "Recent activity" block is a capped (`limit=5`) instance of the same controller + a "View all" route.
- Record Detail's Activity tab is a scoped instance kept alive per tab.
- Items are immutable → cache freely by `(scope, filter, cursor)`; only "new since" matters for invalidation.
- `activityReadStateProvider` tracks `last_seen_at` per scope for the "new" highlight and the dashboard's "N new" affordance.

### 9. Jetpack Compose Implementation Suggestions
- `:feature:activity` (+ reused in dashboard/detail/profile modules). `LazyColumn` + `stickyHeader` date buckets; `AmdsTimeline(variant = Feed)` renders the gutter (`Canvas` line + node) and body.
- Realtime: subscribe the current scope on the shared WS `Flow`; on `activity.created` prepend to an in-memory head list and `animateItemPlacement()`; cap the head, then `pagingSource.invalidate()`.
- Templating: render `template_key` + params into an `AnnotatedString` (actor + object as clickable spans).

### 10. Flutter Implementation Suggestions
- `feature_activity`. `PagedListView` with manual day-bucket headers; `AmdsTimeline` / `timeline_tile`.
- Realtime `StreamProvider` filtered to the on-screen scope; `ref.listen` prepends + triggers a brief `AnimatedContainer` tint.
- Templating: a `ActivityText` widget that builds a `RichText` from `template_key` + params (tap spans → `context.push(deepLink)`).

### 11. React Native Implementation Suggestions
- `features/activity`. `SectionList`/`FlashList` with date sections; `<ActivityItem/>` renders gutter (`react-native-svg`) + templated `<Text>` with pressable actor/object spans.
- Realtime: subscribe to the scope's channel; `queryClient.setQueryData` prepend; `LayoutAnimation` + a `Reanimated` tint that fades over 2s.
- `useActivityReadState(scope)` for the "new" markers.

### 12. Security Considerations
- **Per-item visibility** — the projection computes who may see each item (e.g. a comment on a confidential incident is visible only to that incident's readers); the feed query enforces `visible_to` / re-checks scope access on read. A user must never see activity about a record they can't access.
- **Actor privacy** — some categories may show "Someone" instead of a name for cross-team feeds, per policy; system/automated actors are labelled as such.
- **PII in templates** — activity sentences avoid sensitive values ("changed the amount" not "changed the amount to Rp 4.2M" in a broad feed; the detail is on the record for those with access).
- **Not a substitute for audit** — activity items are user-facing, aggregated, retention-limited, and mutable-by-regeneration; **never** rely on them for compliance or investigation — that's the Audit Log. Keep the two clearly separate in code and docs.
- **Deep-link checks** — tapping an item validates access to the target (like Notifications); stale items don't leak content.
- **Realtime scoping** — clients only subscribe to subject channels they have access to; the server authorizes each subscription; no tenant cross-talk.
- **Erasure** — on user deletion, pseudonymize the actor in activity items (or drop them, since they're regenerable and non-authoritative).

### 13. Scalability Considerations
- **Fan-out on write** — one event → one `activity_item` + N `activity_subject` rows (record, actor, each relevant team, workspace). Do it async in the projection consumer; batch inserts.
- **Feed reads** — per-subject partitioning (`subject_key` as the partition key in a wide-column store) makes "the feed for record X / team Y" an O(page) read; avoid cross-partition scatter.
- **Aggregation** — collapse noisy sequences at projection time (merge consecutive same-actor/same-object edits within a window; `group_key`) so feeds stay readable and small.
- **Retention** — shorter than audit (90–365 days); drop old partitions; regenerate from events if a longer view is ever needed.
- **Realtime** — subject-channel pub/sub; a client viewing a record subscribes to just that record's channel; dashboards subscribe to a scoped channel; drop to a periodic `summary` poll on disconnect.
- **Hot entities** — a very active record/team feed is naturally bounded by pagination; cache the first page per subject with a short TTL + realtime prepend.
- **Cost** — it's a derived, disposable read model — use cheap storage, aggressive TTLs, and rebuild rather than over-engineer durability.

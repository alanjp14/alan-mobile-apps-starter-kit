# Template · CRUD Module — `[DATA_NAME]`

> Archetypes **C — List · D — Detail · E — Form · F — Confirmation** ([framework](../../docs/screen-library/00-framework.md) §4). Full reference: [`../../docs/screen-library/04-data-management.md`](../../docs/screen-library/04-data-management.md). Feature engine: [`../../docs/specs/flutter-starter-kit.md`](../../docs/specs/flutter-starter-kit.md) §8.1.
> One `[MODULE_NAME]` feature = List + Detail + Create + Edit + Delete for `[DATA_NAME]`, all config-driven.

---

## Routes
`/[DATA_NAME]` · `/[DATA_NAME]/{id}` · `/[DATA_NAME]/new` · `/[DATA_NAME]/{id}/edit`

## 1. Data List (`RecordListConfig`)

```
[ App bar: "[DATA_NAME] plural" · search · filter · sort · overflow(Export, Columns, Saved views) ]
[ Search field (scoped) ]
[ Active filter chips + count + sort control ]
[ list: rows via rowBuilder ]
   leading (status color / icon / thumbnail / checkbox) · [primary column] · 2–3 meta (• separated) · trailing (value / status chip / chevron)
[ FAB "New [DATA_NAME]" ]
swipe: leading = [positive action]  trailing = Archive/Delete
long-press → selection mode → bulk [actions]
```

**Config to fill:**
| Field | Value |
|---|---|
| `query` | `GET /v1/[DATA_NAME]?q=&filter[…]=&sort=&cursor=` |
| `keyColumns` (phone row-transformation) | `[col1, col2, col3, col4]` |
| `filterDefs` | `[status, [dimension], date range, owner]` |
| `sortOptions` | `[Updated ▼ (default), Name, [domain priority]]` |
| `swipeActions` | leading `[action]`, trailing `Delete` |
| `selectionActions` | `[bulk actions]` (no bulk reject) |
| `emptyCopy` | first-use: "No [DATA_NAME] yet" + "Add [DATA_NAME]"; no-results: "Nothing matches" + "Clear filters" |

## 2. Data Detail (`RecordDetailConfig`)

```
[ App bar: back · title = record name/ID · Edit · overflow ]
[ Header: title · status chip · 1–2 key attributes · media? ]
[ Primary actions: [action A] · [action B]  (permission- + state-predicated) ]
[ Tabs/sections: Overview (field groups) · Related · Documents · Activity/Audit · Comments ]
[ Delete/Archive → Delete Confirmation ]
```

Field groups → `sections[].fields` (label + value + optional inline action). Empty values → consistent "—". Capture `etag` on load. Prefetch header from the list row.

## 3. Create / Edit Form (`FormSchema`)

```
[ Top bar: X (dirty guard) · "New/Edit [DATA_NAME]" · Save (trailing, primary, enabled when dirty+valid) ]
[ sections (overline headers), fields via FormEngine ]
[ Attachments ]
[ sticky footer on long forms: "Save draft" · "Submit" ]
```

**`FormSchema` fields to define:** `[{ key, type, label, helper, validators, visibleWhen, options, editable }]`.
Validation timing: live only for strength/availability/counter/mask; blur for the field; submit for all + server. Autosave draft (encrypted local + server). Edit: PATCH changed fields + `If-Match` → **409 → conflict resolution UI, never silent overwrite**.

## 4. Delete Confirmation (`AmdsDialog.destructive`)

```
title:  "Delete [record name]?"   (bulk: "Delete N [DATA_NAME]?")
body:   consequence + reversibility + side effects
        ("This can't be undone. N linked [things] will be unassigned.")
[ Type [name] to confirm ]   ← high-value records only
actions: Cancel (default focus) · Delete (danger, disabled until typed-confirm matches)
```

Prefer **soft-delete / archive + Undo snackbar (5–7s)**. Block (don't just warn) when dependencies exist. Block irreversible hard-delete offline.

## States (all screens — see archetypes)
Loading (skeleton matching layout) · Empty (distinct first-use / no-results / no-permission) · Success · Error (specific + Retry + trace id) · Offline (cache "as of HH:MM" + queued mutations with Pending chip).

## Accessibility
Row = one grouped stop = `config.semanticSummary(record)`. Field row = "`[label]`, `[value]`". Form: visible labels, required in label text, errors anchored + announced + first-error focus. Delete dialog = `alertdialog`, focus trapped, Cancel default focus.

## Developer notes
One `DataListScreen(config)` / `DataDetailScreen(config)` / `FormEngine(schema)` per `[DATA_NAME]` — configure, don't rebuild. Server-side `q/filter/sort/page` (keyset). Optimistic row mutations + Undo + `Idempotency-Key`. Offline tier: reads T1, writes T2 (see [`../../docs/starter-template/local-storage.md`](../../docs/starter-template/local-storage.md)).

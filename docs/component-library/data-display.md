# Component Library · Data Display

> Part of the [Component Library](README.md). Covers the **data-display** category: Data List · Data Table · Chart Container · Statistic · Filter Bar · Sort Control · Pagination · Export.
> Responsive data tables for mobile are hard — AMDS defines when to use a real table, when to use cards/rows, and how pagination, search, filter, sort, and export behave. Component APIs (props / Compose / Flutter / RN) for these are also in [api-reference.md §9–10, §18](api-reference.md).

---

## 1. Decide: table vs list

| Use a **table** when | Use **list rows / cards** when |
|---|---|
| Users compare values *across* rows (numbers aligned in columns) | Each record is consumed individually |
| Many quantitative columns matter simultaneously | 1 title + 2–3 metadata points per record is enough |
| It mirrors a known spreadsheet/report workflow | The screen is a browse/triage flow |
| Tablet / landscape / large screen | Small phone, one-handed use |

**Default on phones = the "list row" transformation of a table** (see §3). A true horizontally-scrolling grid is a deliberate choice for comparison-heavy, tablet-first, or power-user screens.

---

## 2. Table anatomy (true table)

```
[ Toolbar: title · result count · Search · Filter · Sort · Export · (Column settings) ]
[ Active filter chips row ]
┌───────────────────────────────────────────────── horizontal scroll ─────┐
│ ▣  Name ▲          │ Status    │ Owner      │ Updated     │ Amount   │ ⋮ │  ← sticky header
├───────────────────────────────────────────────────────────────────────────┤
│ ▣  Compressor A-12 │ ● Active  │ P. Nair    │ 2h ago      │  12,400  │ ⋮ │
│ ▣  Pump Station 3  │ ● Warning │ S. Adeyemi │ Yesterday   │   3,120  │ ⋮ │
│ …                                                                        │
└───────────────────────────────────────────────────────────────────────────┘
[ Pagination / "Load more" / infinite ]
```

**Spec**

| Element | Value |
|---|---|
| Row height | Comfortable 52 · Compact 40 · Large/multiline 64+ |
| Header | sticky top; `overline`/`labelSmall`; `surfaceVariant` bg; sort caret on sortable cols |
| First column | optionally **frozen** (pinned) on horizontal scroll — the identifier column |
| Selection column | 44dp checkbox, frozen with the first column |
| Cell text | `bodySmall`; numeric = tabular figures, right-aligned; text left-aligned (RTL: mirrored) |
| Column min width | 88 (text) / 72 (numeric) / 120 (status+label) |
| Row divider | 1px `divider` |
| Zebra striping | off by default; optional `surfaceVariant` at 50% for very wide tables |
| Row states | hover (`surfaceVariant`), pressed, selected (`primaryContainer` tint + left 2px `primary` bar), disabled |
| Trailing `⋮` | per-row actions menu, frozen right |
| Horizontal scroll affordance | subtle edge fade + the next column peeks; scrollbar fades in on scroll |

---

## 3. Responsive behavior

### 3.1 Phone (< 600) — "row transformation"

Each table row becomes a **List item / Card**:

```
┌─────────────────────────────────────────┐
│ Compressor A-12                 12,400   │   ← primary column + primary numeric
│ ● Active · P. Nair · Updated 2h ago      │   ← 2–3 secondary columns, • separated
└─────────────────────────────────────────┘   tap → Detail View
```

- Choose 1 **title** column, 1 **trailing value** column, 2–3 **metadata** columns; the rest live in the Detail View.
- Column settings let power users pick which fields show in the collapsed row.
- Sort/filter/search operate on the full dataset, not just visible fields.
- Selection: long-press → contextual app bar with count + bulk actions.
- Optional "Table view" toggle to switch to the horizontally-scrolling grid for comparison tasks.

### 3.2 Tablet portrait (≥ 600)

- True table with 4–6 visible columns; frozen identifier column; comfortable row height.
- Two-pane: table left, selected-row Detail right.

### 3.3 Tablet landscape (≥ 905)

- True table, 8+ columns, compact density available, frozen first column + selection.
- Inline row expansion for sub-rows / line items.
- Column resize and reorder (persisted per user).

---

## 4. Density

| Mode | Row height | Cell padding | Text | Use |
|---|---|---|---|---|
| Comfortable (default) | 52 | 12×16 | `bodySmall` | General use |
| Compact | 40 | 8×12 | `bodySmall` | Power users, large datasets, landscape |
| Multiline | auto (min 64) | 12×16 | `bodySmall` | Rows with wrapping text / two-line cells |

Density is a user setting (Settings → Appearance) and/or a per-table toggle; persist it.

---

## 5. Sorting

- Tap a sortable header → cycles: none → ascending → descending → none (or none → asc → desc, no reset — pick one and be consistent).
- Active sort: filled caret + header text `primary`; only **one** active sort column at a time on mobile (multi-sort is a landscape/power feature via the Sort sheet).
- **Sort sheet** (phone): a Bottom Sheet listing sortable fields + direction — the primary sort UI on phones (headers may not be visible in row-transformation mode).
- Default sort stated and sensible (usually "Updated ▼" or a domain priority).
- Sorting is server-side for paginated data; show a brief loading state; keep scroll at top after re-sort.
- Announce to screen readers: "Sorted by Amount, descending."

---

## 6. Filtering

- **Filter entry:** `filter_list` icon in the toolbar → Bottom Sheet (phone) / popover (tablet) with grouped filters: chips (status), ranges (date, amount), pickers (owner, site), toggles (my items only).
- **Active filters** show as **removable chips** below the toolbar + a result count; "Clear all" when >1.
- **Applied** on "Apply" (batch) for multi-filter sheets; instant for single quick-filter chips.
- Filter state is part of the deep link (`?status=active&owner=me`) and persists within a session.
- Empty result → specific empty state: "No assets match these filters" + "Clear filters".
- Saved filter sets ("views") for recurring needs — name, save, set default.
- Screen readers: announce count change ("Showing 24 of 210").

---

## 7. Search

- Toolbar `search` → search field scoped to the current table.
- Debounce 250–300ms; server-side for large data.
- Searches across the identifier + key text fields (document which); show what matched (highlight the term in the row).
- Combine with filters (AND); the query is a chip too ("\"pump\" ✕").
- Recent searches on focus; clear button; result count announced.
- No results → echo the query + suggest clearing filters or checking spelling.

---

## 8. Pagination

| Pattern | When | Behavior |
|---|---|---|
| **Infinite scroll** (default for browse) | Feeds, triage lists, exploratory browsing | Load next page at ~80% scroll; footer spinner; "You've reached the end"; a "Back to top" FAB appears after 2 screens |
| **"Load more" button** | When users need a stopping point / to avoid runaway data | Explicit button; shows "Showing 40 of 210" |
| **Numbered pages** | Report-style, tablet, when "page 7" is meaningful | Compact control: ‹ 1 2 … 7 › + "Rows per page" (25/50/100) + "41–60 of 210"; landscape/tablet mainly |
| **Cursor/keyset** (implementation) | Large or frequently-changing datasets | Prefer over offset pagination for stability; UI can still show "Load more" |

Rules: page size 25 default (mobile), 50 on tablet. Preserve position on back-navigation. Never lose selection across pages silently — either scope selection to the page (and say so) or support "select all N matching". Show total count when cheap to compute; otherwise "200+".

---

## 9. Row & bulk actions

- **Per-row:** trailing `⋮` menu (frozen), or swipe actions on phone (leading = primary positive, trailing = destructive/secondary), always with a menu equivalent for a11y.
- **Bulk:** selection mode → contextual app bar: "12 selected" · action icons (assign, export, archive, delete) · "Select all matching (210)" option · close `X` clears.
- Destructive bulk actions confirm with the exact count and show a progress + result summary (successes/failures, retry failures).
- Optimistic updates with Undo for reversible actions.

---

## 10. Export

- **Trigger:** toolbar `download` / overflow → "Export".
- **Sheet:** format (CSV · XLSX · PDF), scope (Current view with filters · All columns · Selected rows), and a note of the row count and that it's a download/share.
- **Permission:** downloading is an explicit user action — confirm; respect data-governance rules (some fields may be excluded from export, say so).
- **Async for large exports:** "We'll notify you when your export is ready" → notification with a secure, expiring link; don't freeze the UI.
- **PDF export** = a formatted report (title, filters applied, timestamp, page numbers), not a screenshot of the grid.
- Never put sensitive data in a URL; deliver via the app's secure file handling / share sheet.
- Localize numbers, dates, and encoding (UTF-8 BOM for CSV opened in Excel).

---

## 11. States

| State | Treatment |
|---|---|
| Loading (initial) | Table skeleton: header + 6–8 shimmer rows at the real row height |
| Loading (next page) | Footer spinner; existing rows stay interactive |
| Refreshing | Pull-to-refresh spinner; subtle top progress line |
| Empty (no data yet) | Empty state: icon + "No <entity> yet" + primary "Add <entity>" |
| Empty (no results) | "Nothing matches your search/filters" + "Clear filters" |
| Error | "Couldn't load <entity>" + "Retry"; keep any already-loaded rows |
| Offline | Banner + show last cached data with an "as of <time>" note; queue actions |
| Stale/partial | "Some data may be out of date" warning chip |

---

## 12. Accessibility

- Real table semantics on the grid: `table`/`grid` with `columnheader`, `rowheader` (the identifier cell), row/column indices.
- Row-transformation cards: each is one `button`/`link` whose name summarizes the key fields ("Compressor A-12, Active, updated 2 hours ago, 12,400").
- Sort state, filter count, and pagination position announced via polite live regions.
- Horizontal scroll must not trap keyboard/switch focus; column navigation works with arrow keys on supported platforms.
- Checkbox column: each checkbox labeled with its row's identifier ("Select Compressor A-12").
- Frozen columns must not overlap focus outlines or obscure focused cells.
- Sufficient contrast for zebra striping, selection tint, and status dots (color + icon/label).
- Works at 200% text scale — cells wrap or the row height grows; never clip.

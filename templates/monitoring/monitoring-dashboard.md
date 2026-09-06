# Template · Monitoring Dashboard — `[APP_NAME]`

> Archetype **B — Dashboard** (real-time / status-first). Full reference: [`../../docs/screen-library/02-dashboard.md`](../../docs/screen-library/02-dashboard.md) §2.3. Feature: [`../../docs/feature-library/04-analytics.md`](../../docs/feature-library/04-analytics.md) (Dashboard Analytics).
> For a NOC / ops-centre / on-call view. **Tablet/landscape-first** in practice.

---

## Objective
Let an on-call `[ROLE_NAME]` glance-check overall health, see active incidents in priority order, and act (acknowledge / resolve) without hunting.

## Route
`[APP_NAME]://[app]/dashboard/monitoring`

## Layout (landscape-first)

```
┌─────────────────────────────────────────────────────────────────┐
│ HEALTH BAR: [Operational|Degraded|Outage] · 🔴 N · 🟠 N · 🟢 N · "updated Xs ago" (live pulse) │
├──────────────────────────────┬──────────────────────────────────┤
│ ACTIVE INCIDENTS (severity → age)  │ STATUS GRID / heatmap        │
│  [sev chip] [title] [component]     │  [tiles colored by state:    │
│  [duration] [assignee] [Ack][Resolve]│   success/warning/danger/    │
│  …                                  │   grey=unknown]              │
├──────────────────────────────┤  KEY METRICS (2–4 live mini-charts)│
│ ALERT FEED (reverse-chron)          │  latency · error rate ·      │
│  filters: severity · service · ack  │  throughput · availability   │
└──────────────────────────────┴──────────────────────────────────┘
Quick actions: Acknowledge all · Create incident · Open runbook · Page on-call
```

Phone: stack vertically — health bar → active incidents → status grid → mini-charts → alert feed.

## Severity encoding (colorblind-safe)
**color + icon + text + position**. 🔴 red = active user-impacting · 🟠 amber = degraded/at-risk · 🟢 green = healthy · ⚪ grey = **unknown/no data (never "fine")**. Most severe pinned top.

## States
- **Loading:** health bar skeleton + 3 incident-row skeletons + tile-grid shimmer; charts last.
- **Empty:** "All systems operational" (green) — a calm confirming state, not a blank.
- **Success:** live data; auto-refresh 15–60s **in place** (diff, flash only what changed); "updated Xs ago" ticks.
- **Error:** a source fails → that tile/chart shows unknown (grey) + "no data" — **not hidden, not green**. Whole-feed failure → "Monitoring data unavailable" + last-known state dimmed + Retry.
- **Offline / stale:** feed past its interval → "Data stale — Ns" in `warning` at the health bar; don't render stale as current. Offline → "Reconnecting…" with the last snapshot dimmed.

## Accessibility
Health bar announces the summary + counts on change (**polite, throttled**). Severity in text always. Active-incident rows = grouped stops (severity, duration, assignee). Ack/Resolve labelled with the incident id. New-critical-alert announcement is polite and **does not move focus or open a modal**. Reduced-motion: no live pulse → a static "live" dot + timestamp; no flash on change → a brief outline.

## Animations
New incident row: expand + fade + slideY, 250ms; sorts to top. Changed value on refresh: 150ms crossfade + 400ms outline fade. Health-bar count change: digit up-fade. Live pulse 1.5s opacity loop (reduced-motion: off). **No modal, no focus steal, ever.**

## Developer notes
Prefer a **WebSocket / SSE** stream; fall back to polling (15–60s). Apply updates as **diffs** to a keyed list — never replace the whole list (preserves scroll + selection). Debounce UI updates (~1/sec). A heartbeat watchdog → "stale" state. Ack ≠ Resolve (separate; ack stops paging, resolve closes). One consistent timezone (UTC or the NOC's) with local on tap. Sound alert = a short asset, gated by a setting + DND awareness, with a visible + haptic equivalent + a mute control. Left open for hours → pause off-screen animation, dim on idle, keep-awake toggle. **Compose:** `LazyColumn` + stable keys + `animateItemPlacement()`. **Flutter:** `SliverAnimatedList` keyed diffs. **RN:** `FlashList` + `LayoutAnimation`.

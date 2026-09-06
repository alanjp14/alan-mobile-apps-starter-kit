# Screen Library · 06 · Notifications

> Foundation: AMDS v1.0 · Archetypes: **C — List** (§4.C), **D — Detail** (§4.D).
> The durable, in-app record of system and workflow events. Push is the transient delivery; this is the source of truth.

Screens: Notification List · Notification Detail

Flow map:
```
App bar bell (badge) / Bottom nav ─► Notification List ─► tap item ─► { deep-link to source (approval / record / comment) | Notification Detail (rich/standalone items) }
Notification List ─► overflow: Mark all read · Notification settings
Push tapped (app closed) ─► deep-link to source, item marked read; List reflects it on next open
```

Settings for notifications live in §09 (Notification Settings). This module = viewing.

---

## 6.1 Notification List

**Archetype:** C · **Route:** `/notifications?tab=all|mentions|approvals|system`

1. **Purpose** — a chronological, categorized inbox of everything that happened that concerns the user, each item linking to its origin.
2. **User Goal** — "See what I missed, deal with what matters, and get to the thing each notification is about."
3. **Layout** — C's skeleton, tuned:
   - App bar "Notifications" + "Mark all read" (text action) + overflow (Notification settings).
   - **Filter tabs / chips:** All · Mentions · Approvals · System (product-configurable set).
   - **Grouped list:** section headers "Today" / "Yesterday" / "Earlier" (or "This week").
   - **Row:** leading = category icon in a tinted circle **or** actor `AmdsAvatar(sm)` · **title** (bold `titleMedium` when unread) + body snippet (`bodyMedium` `textSecondary`, 1–2 lines) · timestamp (`caption`, trailing) · **unread dot** (`primary`, leading or trailing) · optional trailing **quick action** for safe, high-value items ("Approve", "View").
   - Swipe: leading = "Mark read/unread", trailing = "Dismiss".
   - Pull-to-refresh. No FAB.
4. **Component Hierarchy** — C's + `AmdsSegmented/ChipRow(tabs)`, `SectionHeader(date bucket)`, `NotificationRow(leading icon|avatar, title, snippet, time, unreadDot, AmdsButton.sm quickAction?)`, `AmdsEmptyState("You're all caught up")`.
5. **Information Architecture** — reverse-chronological, grouped by day. **Unread is visually distinct by weight + dot**, not background color alone. Category is signalled by the leading icon + (optionally) a small type label. Batched events collapse ("3 comments on INC-442"). Time-sensitive items (approval nearing SLA) can be pinned/highlighted at the top.
6. **User Flow** — C's. `open → list (unread first-glance obvious) → tap a row → { deep-link to the source (approval detail / record / comment thread), item marked read | open Notification Detail for standalone/rich items } `. `quick action (e.g. "Approve") → confirm if needed → acts in place → row updates + Snackbar`. `"Mark all read" → all dots clear, bell badge → 0, Snackbar "Marked N as read · Undo"`. Swipe dismiss → row collapses + Snackbar Undo. Filter tab → filtered list, count per tab.
7. **States** — C's. Deltas:
   - **Loading:** `AmdsSkeletonList` — leading circle + 2 text bars + time per row, grouped headers shown.
   - **Empty:** "You're all caught up" + a calm illustration (All); per-tab: "No mentions" / "No approvals waiting". First-run: "Notifications will appear here."
   - **Success:** grouped rows; unread emphasized; new arrivals (while open) insert at top with a `primaryContainer` tint fade.
   - **Error:** "Couldn't load notifications" + Retry; keep loaded rows.
   - **Offline:** cached list + "as of HH:MM"; new pushes still arrive at the OS level and appear on next sync; quick actions queue with "Pending"; "Mark all read" works locally and syncs later.
8. **Accessibility** — C's. Row = one grouped stop: "Unread. Purchase request PR-88120 needs your approval. From S. Adeyemi. 20 minutes ago." Unread state announced ("Unread"). Quick-action button separately labelled with context ("Approve PR-88120"). "Mark all read" announces the count changed. Bell badge value is part of the tab's accessible name ("Notifications, 5 unread"). New-item announcements are **polite** and don't move focus. Date-bucket headers are headings.
9. **Animations** — C's. Row → read: the dot fades + title de-emphasizes (weight crossfade) 150ms. New item: expand + fade + 2s `primaryContainer` tint. Dismiss: collapse + fade + slide, 200ms `accelerate`. "Mark all read": dots fade in a quick left-to-right cascade (reduced-motion: all at once). Badge count: digit up-fade.
10. **Dark Mode** — C's. Unread dot `#4ADE80`; category icon circles use translucent semantic containers + -100 glyphs; unread row title `#F8FAFC` vs read `#94A3B8`; new-item tint `rgba(34,197,94,0.16)`.
11. **Tablet** — C's list-detail: **notification list left, Notification Detail (or the deep-linked source) right** on landscape. Portrait: single list max-640. On tablet, tapping a notification that deep-links to an approval can open the Approval Detail in the right pane without leaving the list.
12. **Developer Notes** — **all:** the list is a paginated read model of a notifications service (`GET /notifications?filter=&cursor=`); each notification = `{ id, type, category, title, body, actorId?, entityRef (deep link target), createdAt, readAt?, actions[] }`. **Read state** syncs both ways (reading on another device clears it here). Push (FCM / APNs) carries the same `entityRef` → tapping a push deep-links and marks read; the list reconciles on next fetch or via a silent data push. Batching/grouping done server-side by `groupKey`. Quick actions call the same endpoints as the source screen (idempotent). "Mark all read" is a single call + optimistic local clear. Bell badge = unread count from the same service (also drives the OS app-icon badge). **Compose:** Paging 3 + `LazyColumn` sticky headers. **Flutter:** `PagedListView` + `GroupedListView` or manual buckets. **RN:** `SectionList` / `FlashList` with section headers.
13. **UX Best Practices** — tapping a notification goes to the exact thing and marks it read. Unread by weight + dot, not background. Group and let users filter by type. Batch similar events. Pin time-sensitive items. Respect per-category settings. Never require the app to have been open — this is the durable record. Don't lose scroll position on return.

---

## 6.2 Notification Detail

**Archetype:** D (record) — used for **standalone / rich** notifications that aren't just a pointer to another screen (announcements, system messages, digests, rich alerts with their own content).

**Route:** `/notifications/:id`

> Most notifications deep-link straight to their source (an approval, a record, a comment) and never render this screen. Notification Detail is for items whose content **is** the notification: a company announcement, a maintenance-window notice, a policy update, a weekly digest, a broadcast alert.

1. **Purpose** — present the full content of a self-contained notification, with any acknowledgement or follow-up action it requires.
2. **User Goal** — "Read the whole message and do whatever it asks (acknowledge, read more, dismiss)."
3. **Layout** — D's skeleton, simplified:
   - App bar: back · title = notification subject · overflow (Mark unread, Share if allowed).
   - **Header block:** category chip (Announcement / System / Alert / Digest) · sender ("IT Operations" / "HR") · timestamp · severity for alerts.
   - **Body:** rich content — headings, paragraphs, lists, a callout, an optional image or attached document (`bodyLarge`, 60–70 char lines).
   - **Related links:** "View the full policy" / "Open the affected service" (deep links).
   - **Action bar (if the notification requires it):** "Acknowledge" (primary) — records that the user has seen a mandatory notice; or "Mark as done".
   - **Digest variant:** a list of summarized items, each a row linking to its source.
4. **Component Hierarchy** — D's + `NotificationHeader(categoryChip, sender, time, severity?)`, rich-text `Body` (markdown-rendered with AMDS styles), `RelatedLinkList`, `AmdsButton(primary "Acknowledge")?` or `DigestItemList`.
5. **Information Architecture** — the content is the point — lead with it. Metadata (who sent it, when, category, severity) frames it. Mandatory acknowledgement is prominent and its state is clear ("Acknowledged on 3 March" once done). Digests are just a container of pointers.
6. **User Flow** — `open (from the list, or a push for a rich item) → item marked read → read the body → { tap a related link → deep-link to that target | tap "Acknowledge" → confirmation micro-interaction → state → "Acknowledged", action bar collapses, syncs → back }`. Overflow → "Mark unread" (re-adds the dot in the list). Back → Notification List (position preserved).
7. **States** —
   - **Loading:** header + body text-line skeletons.
   - **Empty:** N/A (a notification always has content); a broken/removed notification → "This notification is no longer available" + "Back to notifications".
   - **Success:** full content; if it required acknowledgement and the user has done so → an "Acknowledged {date}" confirmation replaces the button.
   - **Error:** "Couldn't load this notification" + Retry. Acknowledge failure → button returns, Snackbar "Couldn't acknowledge — try again".
   - **Offline:** if the body was in the list payload / cached → show it fully with "Offline"; otherwise "Connect to read this notification". **Acknowledge is queued** offline with a "Pending" indicator and syncs on reconnect (acknowledgement is a record, not an irreversible external action, so queuing is acceptable — state that it will sync).
8. **Accessibility** — D's. Title = `heading 1`. Body headings marked so users can navigate by heading. Reading order logical. Severity stated in text for alerts. "Acknowledge" button clearly labelled; its resulting state announced ("Acknowledged on 3 March"). Related links are descriptive. Digest items = grouped stops linking to sources. Respects Dynamic Type (this is a reading screen — line height + length matter).
9. **Animations** — D's. Enter: fade. Acknowledge: button → brief check micro-interaction (200ms `spring`) → action bar collapses (200ms). Digest items fade+riseY staggered on first paint. Reduced-motion: instant, static check.
10. **Dark Mode** — D's. Reading surface `#0F172A`; callouts = translucent semantic containers + -100 text; alert severity header uses the -400 hue + `dangerContainer`/`warningContainer` band; images get a subtle scrim; digest divider `#1E293B`.
11. **Tablet** — reading column ≤640–720 (don't run lines edge to edge). Landscape: opens in the right pane beside the Notification List. About/announcement content centered.
12. **Developer Notes** — **all:** only render this route when `notification.type` is a self-contained kind (`announcement | system | alert | digest | policy`); everything else redirects to `entityRef`. Body content: sanitized markdown/HTML from the notifications service, cached with the list payload where small, fetched on open where large. `POST /notifications/:id/acknowledge` (idempotent) → records `acknowledgedAt` + `acknowledgedBy` for compliance reporting; queue offline with an idempotency key. Digest: `notification.items[]` each with its own `entityRef`. Mandatory-acknowledgement notices may also block a gate elsewhere (e.g. can't proceed until acknowledged) — that's enforced by the gating feature, this screen just captures it. **Compose:** markdown via a renderer + `AnnotatedString`. **Flutter:** `flutter_markdown` + AMDS `MarkdownStyleSheet`. **RN:** a markdown component + theme.
13. **UX Best Practices** — content first, metadata frames it. Make mandatory acknowledgement obvious and show its completed state. Digests are pointers — keep them scannable. Related links deep-link precisely. Reading typography (line length, height, size, Dynamic Type). Offline: show cached content; queue acknowledgement transparently. Redirect pointer-type notifications straight to their source — don't force a detour through this screen.

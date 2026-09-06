# Screen Library · 10 · Help Center

> Foundation: AMDS v1.0 · Archetypes: **H — Content/Article** (§4.H), **A — Focused Task** (§4.A) + **E — Form** (§4.E) for Contact Support.
> Self-service support and app information. Reached from Settings, Profile, or an in-context "?" affordance.

Screens: FAQ · Contact Support · About Application

Help hub layout (`/help`): Search bar (prominent) → topic categories (grid/list) → "Still need help?" card → Contact Support → footer links (Status page, About). Entries = deltas + specifics.

```
"?" / Settings ─► Help hub ─► FAQ (search / browse / article) ─► "Was this helpful?" ─► Contact Support
Help hub ─► Contact Support ─► (send) confirmation ─► ticket reference
Settings ─► About Application ─► legal / licenses / version
```

---

## 10.1 FAQ

**Archetype:** H · **Route:** `/help/faq?q=&topic=` · article: `/help/articles/:slug`

1. **Purpose** — let users answer their own question fast by searching or browsing help content, before contacting support.
2. **User Goal** — "Find the answer to my specific question without waiting for a human."
3. **Layout** — H's skeleton:
   - App bar "Help" · back · (Contact support action in overflow).
   - **Search field** (prominent, "Search help") — the primary entry.
   - **Topic categories** (when not searching): tiles/rows with an icon — Getting started · Account & sign-in · {core feature} · Approvals · Notifications · Troubleshooting · Billing (SaaS).
   - **Popular questions:** a short list of the most-viewed articles.
   - **Accordion list** within a topic: question (`titleMedium`) → expand → answer (`bodyLarge`, 60–70 char lines, with steps/lists/images/callouts) + "Was this helpful? 👍 👎" + related articles.
   - **Article view** (deep content): full-screen readable page with a title, body blocks, a "Was this helpful?" row, and a "Still need help? → Contact support" card at the end.
   - Persistent "Still need help?" card / FAB-style button.
4. **Component Hierarchy** — H's + `AmdsSearchField`, `TopicTileGrid`, `PopularList (AmdsListTileX)`, `AmdsAccordion × n`, `ArticleBody (markdown)`, `HelpfulRow(👍/👎)`, `AmdsCard("Still need help?" → Contact)`.
5. **Information Architecture** — search first, browse second. Articles are single-topic, scannable (headings, short paragraphs, ordered steps). Troubleshooting articles lead with the fix. Every article ends with an escape hatch to Contact Support. Search matches title + body + tags.
6. **User Flow** — H's. `open → type a query (debounced 250–300ms) → results list (term highlighted, snippet) → tap → article → read → 👍 (done) / 👎 (optional "what was missing?" one-liner → feeds content backlog) → if unresolved → "Contact support" (carries the article + query as context) `. Browse: `topic tile → article list → accordion expand`.
7. **States** — H's. Deltas:
   - **Loading:** search → skeleton result rows; article → text-line skeleton.
   - **Empty:** no search results → "No articles match '{query}'" + spelling hint + **"Contact support"** (prominent — a zero-result search is a strong signal the user needs help). First load with no content configured → hide FAQ, show only Contact Support.
   - **Success:** results / article rendered; expanded-accordion state kept for the session; term highlighted.
   - **Error:** "Couldn't load help content" + Retry; article failed → "Couldn't open this article" + back.
   - **Offline:** show **cached** top articles + "Offline — showing saved help"; search runs against the local cache only (note "searching saved articles"); "Contact support" queues the message.
8. **Accessibility** — H's. Headings in articles marked so users navigate by heading. Accordions = `button` + `aria-expanded`; the answer region is associated and announced on expand. Search result count announced ("6 articles"). "Was this helpful?" buttons labelled with context ("Yes, this article helped" / "No, this didn't help"). Links are descriptive. Article body respects Dynamic Type; adequate line length + height. Images have alt text or are decorative.
9. **Animations** — H's. Accordion expand 250ms `standard` + chevron rotate 180°. Article enter: fade. Search results: list crossfade on new query. "Helpful" tap: subtle check. Reduced-motion: instant expand, no crossfade.
10. **Dark Mode** — H's. Reading surface `#0F172A`; code blocks `#1E293B`; callouts translucent semantic containers + -100 text; topic tile icons in translucent circles; search field `surfaceVariant`.
11. **Tablet** — H's landscape **two-pane**: search + topic/article list left (≤360), the article right. Portrait: single column, reading width ≤640.
12. **Developer Notes** — **all:** content from a help CMS / markdown store; **cache aggressively for offline** (bundle a "top 20" set with the app, sync the rest). Render via a sanitized markdown widget with AMDS `MarkdownStyleSheet` / equivalent. Search: server-side full-text when online (`GET /help/search?q=`), local index (e.g. a bundled JSON + client fuzzy match) offline. "Was this helpful?" → `POST /help/feedback { articleId, helpful, comment? }` (queue offline). Deep link `/help/articles/:slug` (shareable). Article → "Contact support" passes `?articleId=&query=` so the ticket has context. **Compose:** markdown renderer + `AnimatedVisibility` accordions. **Flutter:** `flutter_markdown` + custom `AmdsAccordion`. **RN:** `react-native-render-html` / markdown lib + `LayoutAnimation`.
13. **UX Best Practices** — search-first. Single-topic, scannable articles; troubleshooting leads with the fix. Every article has an escape hatch to a human. Zero-result search → prominent Contact Support. "Was this helpful?" feeds the content backlog. Offline: bundled top articles. Highlight the search term in results.

---

## 10.2 Contact Support

**Archetype:** A — Focused Task + **E** form · **Route:** `/help/contact?articleId=&query=&source=`

1. **Purpose** — let the user send a support request with enough context (and optional diagnostics) for support to act, and give them a reference to track it.
2. **User Goal** — "Describe my problem, attach what's relevant, send it, and know it was received and when I'll hear back."
3. **Layout** — A's focused task with an E-style form:
   - App bar: `X` / back · "Contact support".
   - **Expected response time** note ("We usually reply within 1 business day") + support hours / status link.
   - **Category** (`AmdsDropdown`): Account & sign-in · Bug / something broken · Feature request · Data question · Billing · Other — pre-selected if arriving from an article.
   - **Subject** (short text).
   - **Message** (textarea, auto-grow, min 4 lines) — pre-filled with a light template for bug reports ("What happened / What you expected / Steps").
   - **Attachments:** screenshots / files (camera / library / file); per-file progress + remove; size/type limits stated.
   - **Diagnostics toggle:** "Include diagnostic info" (default **on**) — with a clear, expandable list of exactly what's sent: app version + build, device model, OS version, locale, connectivity, current screen, user id/email, and (only if a **separate, off-by-default** "Include recent logs" toggle is on) the last N minutes of app logs. "What's included?" opens the full list.
   - **Contact preference:** reply by email (pre-filled, editable) / in-app.
   - **Primary button:** "Send" (full-width, `Large`).
   - After send → confirmation state: ✓ "Message sent", a **ticket reference** (copyable), "We'll email {address}", "View my requests" (if a ticket list exists), "Back to help".
4. **Component Hierarchy** — A's + `ResponseTimeNote`, `AmdsDropdown(category)`, `AmdsTextField(subject)`, `AmdsTextField(message, multiline)`, `AmdsAttachmentField`, `AmdsSwitchTile(diagnostics)` + `DiagnosticsDisclosure`, `AmdsSwitchTile(includeLogs)` (nested, off), `AmdsTextField(replyEmail)`, `AmdsButton("Send", loading)` → confirmation `Column[✓, Text, TicketRefChip(copy), AmdsButton("View my requests"), TextLink("Back to help")]`.
5. **Information Architecture** — the user provides intent (category + subject + message); the app provides context (diagnostics, transparently). The response-time expectation is set up front. The confirmation gives a trackable reference. Sensitive diagnostic data (logs) is opt-in and disclosed.
6. **User Flow** — A/E's. `open (category pre-set from context) → write subject + message → attach → review diagnostics (expand "What's included?" if curious) → "Send" → { success → confirmation + ticket ref + Snackbar | validation (empty subject/message) → inline + focus | send failure → keep the draft, Banner + Retry, trace id | offline → "We'll send this when you're back online" + the message is queued } `. Confirmation → "View my requests" (ticket list, if present) or "Back to help".
7. **States** —
   - **Loading:** "Send" spinner; attachment uploads show per-file progress.
   - **Empty:** category pre-selected or focused; message pre-templated for bugs.
   - **Success:** confirmation state with a copyable ticket reference + reply channel + next step; draft cleared.
   - **Error:** validation (subject/message required) inline; attachment upload failure → per-file retry, doesn't block send (send without it, or wait); send failure → **keep the whole draft**, Banner + Retry + trace id.
   - **Offline:** Banner "You're offline — your message will be sent when you reconnect"; "Send" becomes "Queue message"; the message + attachments are stored locally and sent on reconnect; the user gets the ticket reference once it actually sends (notification).
8. **Accessibility** — A/E's. Category/subject/message labelled + associated; message textarea announces it's multi-line and any character limit. The **diagnostics disclosure is fully readable** by screen reader — the user must be able to know exactly what they're sending; the "Include recent logs" sub-toggle explains the privacy implication. Attachment controls labelled. "Send" announces the action. The confirmation state moves focus to its heading, announces the ticket reference, and the reference is copyable + announced. Errors anchored + announced; first-error focus on send.
9. **Animations** — A's. Diagnostics disclosure expand (200ms height + fade). Attachment thumbnails fade in. "Send" → spinner. Form → confirmation: crossfade + ✓ draw 250ms `spring`. Reduced-motion: instant, static check.
10. **Dark Mode** — A/E's form palette; diagnostics disclosure card `surfaceVariant`; the "Include recent logs" nested toggle area subtly inset; success icon `#4ADE80`; ticket-ref chip `primaryContainer`.
11. **Tablet** — presented as a **centered dialog / focused panel (≤560–640)**; on landscape it can open in the right pane beside the Help hub. Confirmation stays in the same surface.
12. **Developer Notes** — **all:** `POST /support/tickets { category, subject, message, replyChannel, replyEmail, context }` (multipart with attachments, or upload attachments first → attach refs). **Context object** assembled client-side: `{ appVersion, build, platform, osVersion, deviceModel, locale, timezone, connectivity, currentRoute, userId, articleId?, query?, source? }`; **logs** only appended when the separate toggle is on — pull the last N minutes from the in-app ring-buffer logger, **scrub tokens/PII** before sending, and cap the size. Response returns a ticket id/reference. Offline: enqueue the ticket + attachments (encrypted), send on reconnect via a background task, then notify with the reference. Integrate with the helpdesk (Zendesk/Freshdesk/Jira Service Management) via that endpoint server-side. **Compose:** `ring-buffer` Timber tree. **Flutter:** a `logger` with a memory sink. **RN:** a custom log buffer.
13. **UX Best Practices** — set the response-time expectation up front. Pre-fill category + a message template from context. Diagnostics on by default **but** fully disclosed and expandable; logs are a separate, off-by-default, explained toggle — scrub PII server-adjacent. Never lose the draft on a failed send. Give a copyable ticket reference. Offline → queue transparently and confirm once actually sent. Attachments never block the send.

---

## 10.3 About Application

**Archetype:** H · **Route:** `/about` (also reachable as Settings → About)

1. **Purpose** — app identity, version, legal documents, third-party licenses, and credits.
2. **User Goal** — "Check which version I'm on (support asked), read the terms/privacy policy, or see what's new."
3. **Layout** — H's skeleton, centered:
   - App bar "About" · back.
   - **Identity block (centered):** app icon · app name · **version + build** (e.g. "2.4.1 (2410)") — **tap/long-press to copy** · environment badge (non-prod only) · tenant/workspace name (if multi-tenant).
   - **What's new:** link → changelog / release notes (in-app readable view).
   - **Legal:** Terms of Service · Privacy Policy · (region) Data Processing Addendum · Cookie/Tracking policy — each opens a readable in-app view (or the browser, consistently).
   - **Open-source licenses:** → a list screen of every bundled dependency with its license text (`showLicensePage` / platform equivalent).
   - **Acknowledgements / credits** (optional).
   - **Company:** legal entity name · website link · support email · copyright line ("© [year] [COMPANY_NAME]").
   - **Actions (optional):** "Check for updates" · "Rate the app" (store link) · "Share the app".
4. **Component Hierarchy** — H's + `AppIdentityBlock(icon, name, versionRow(copyable), envBadge?)`, `AmdsListTileX × (What's new, Terms, Privacy, DPA, Licenses, Acknowledgements)`, `CompanyFooter`, optional `AmdsButton × (Check updates, Rate, Share)`.
5. **Information Architecture** — identity + version first (that's why most people open this screen). Legal links grouped and consistent. Licenses is a self-contained sub-screen. No marketing copy. Everything factual.
6. **User Flow** — H's. `open → read version → (long-press to copy for a support call) → tap "Privacy Policy" → readable view → back `. `"Licenses" → dependency list → tap one → its full license text `. `"What's new" → release notes `. `"Check for updates" → queries the store / update service → "You're up to date" or "Update available → Open store"`.
7. **States** — H's. Deltas:
   - **Loading:** identity block is instant (bundled); "Check for updates" shows a spinner while querying; legal docs show a text skeleton if fetched remotely.
   - **Empty:** N/A.
   - **Success:** all info shown; version copyable.
   - **Error:** a remote legal doc fails → "Couldn't load — Retry" or "Open in browser"; "Check for updates" fails → "Couldn't check right now".
   - **Offline:** identity/version/licenses (bundled) work fully; remote legal docs show a **cached** copy with "Last updated {date}" or "Connect to view the latest"; "Check for updates" disabled.
8. **Accessibility** — H's. App name = `heading 1`. The version row is a labelled, copyable element ("Version 2.4.1 build 2410, double-tap to copy") and the copy action is announced ("Copied"). Legal links are descriptive ("Open Privacy Policy"). The licenses list is navigable; each license opens as readable text. Environment badge announced for non-prod. Everything respects Dynamic Type.
9. **Animations** — H's. Enter: fade. Copy version: a brief tooltip/Snackbar "Copied". List rows: subtle stagger on first paint. Reduced-motion: instant.
10. **Dark Mode** — H's. Centered identity block on `background`; app icon unchanged; env badge `warning`; legal reading views use the dark reading surface; license text `#1E293B` code-style block.
11. **Tablet** — centered card (≤560); licenses as a two-pane list-detail on landscape (dependency list left, license text right). Legal docs in a reading column ≤720.
12. **Developer Notes** — **all:** version/build from `package_info_plus` / `PackageInfo` / `expo-application` / `BuildConfig` / `Bundle`. Licenses: Flutter `showLicensePage()` (auto-collects from `pubspec`), Android `OSS Licenses Gradle plugin` / `LibrariesLibraries` (AboutLibraries), iOS a bundled `Settings.bundle` acknowledgements or a generated list, RN `react-native-oss-license` / a build-time generated JSON. Legal docs: prefer bundled markdown that ships with the app (always available, versioned) + a "view latest online" link; if fetched, cache with a timestamp. "Check for updates": `in_app_update` (Android) / `App Store` version check / your MDM/update service. "Rate": `in_app_review` / `StoreKit` / `react-native-rate`. Copy: `Clipboard`. **Never** put marketing or dynamic promotional content here.
13. **UX Best Practices** — version + build first and **copyable** (support always asks). Legal links grouped, consistent open behavior, and available offline (bundle them). Licenses complete and self-contained. Non-prod builds visibly badged. Factual only — no marketing. "What's new" links to real release notes, not a splash.

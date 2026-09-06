# Feature Library · 05 · Data Tools

> Foundation: AMDS v1.0 · Inherits [`00-framework.md`](00-framework.md). Features: **Search & Filter · File Upload**.

---

## Feature: Search & Filter

### 1. Purpose
A consistent, reusable capability for finding records — scoped in-list search, global cross-entity search, structured filters, sorting, saved views, and recent searches — fast, typo-tolerant, permission-aware, and deep-linkable.

### 2. Business Flow
1. **Index** — domain services emit create/update/delete events; an indexer projects searchable documents (id, type, title, key fields, tenant, ACL tags, `updated_at`) into a **search index** (OpenSearch/Elastic/Typesense) via the outbox — near-real-time.
2. **Query** — the client issues a search (scoped or global) with filters/sort/pagination; the search service applies the user's tenant + ACL filter, ranks results, returns a page + facet counts + highlights.
3. **Refine** — the user adds structured filters (status, date range, owner, site); filters and the query combine (AND); active filters show as removable chips; result count updates.
4. **Reuse** — recent searches are remembered per user; frequently-used filter combinations are saved as named **views** (with an optional default).
5. **Navigate** — tapping a result deep-links to its detail; the query/filters/scroll are preserved on back.
6. **Govern** — search never returns rows the user can't see; sensitive fields are excluded from indexed documents or redacted in results.

### 3. UX Flow
```
List View → search icon → scoped search field (debounce 275ms) → results (term highlighted, count) / no-results (echo + "Clear filters")
   → filter icon → Bottom Sheet (grouped filters: chips, ranges, pickers, toggles) → Apply → chips + count + deep link updated
   → sort → sheet/menu → re-query, scroll top
   → save as view → name → appears in "Saved views"
Global search (app bar / dedicated) → type → grouped results by entity type ("Assets", "People", "Requests") → tap → that detail
Recent searches shown on focus before typing
```
Screens: [`../screen-library/04-data-management.md`](../screen-library/04-data-management.md) §4.1 (list search/filter), the table system [`../09-table-system.md`](../component-library/data-display.md) §5–7, and a global-search view (Archetype C variant).

### 4. Screen Mapping
| Screen | Route | Template |
|---|---|---|
| In-list search + filter | `/{entityType}?q=&filter[…]=&sort=` | 04 §4.1 (Archetype C) |
| Filter sheet | bottom sheet | data-display §6 |
| Sort sheet | bottom sheet | data-display §5 |
| Global search | `/search?q=&type=` | Archetype C (grouped) |
| Saved views | `/{entityType}/views` or a menu | list of `saved_view` |

### 5. Required Components
Search Bar ([16 §4](../component-library/api-reference.md)) · Chips (active filters, scope) [16 §14](../component-library/api-reference.md) · Bottom Sheet (filters/sort) [16 §6](../component-library/api-reference.md) · Segmented (scope/sort) · Date range picker / Dropdown / Entity picker (filter inputs) [16 §3,5](../component-library/api-reference.md) · List/ListTile (results) [16 §9](../component-library/api-reference.md) · Empty state (no results) · Table (grid results on tablet) [16 §9](../component-library/api-reference.md). Feature composites: `FilterSheet(FilterSchema)`, `ActiveFilterChips`, `RecentSearches`, `SavedViewsMenu`.

### 6. Database / Store Suggestions
| Store | Contents | Notes |
|---|---|---|
| **Search index** (OpenSearch/Elastic/Typesense) | `search_doc { id, type, tenant_id, acl_tags[], title, subtitle, body, keywords, status, owner_id, site_id, updated_at, numeric/date fields for range filters }` | one index or per-type; analyzers for typo tolerance (fuzzy, n-grams) |
| `saved_view` | `id, user_id, screen/entity_type, params (jsonb: q, filters, sort), name, is_default, created_at` | |
| `recent_search` | `user_id, entity_type, query, filters_hash, last_used_at` (cap N per user/type) | or client-only in local storage |
| `filter_schema` (config) | per entity type: filter definitions (key, label, type, options source, default) | drives `FilterSheet` |
| OLTP tables | the source of truth; indexer keeps `search_doc` in sync via events | fallback to `ILIKE`/`tsvector` for small tenants |

Index sync: transactional outbox → indexer consumer → upsert/delete `search_doc`; a nightly reconciliation job repairs drift.

### 7. API Endpoint Suggestions
| Method · Path | Purpose | AuthZ |
|---|---|---|
| `GET /v1/{entityType}?q=&filter[status]=&filter[site]=&sort=-updatedAt&cursor=&limit=25` | scoped list+search (the primary list endpoint already does this) | list permission; server appends ACL filter |
| `GET /v1/search?q=&type=asset,user,request&cursor=` | global cross-entity search, grouped | authenticated; per-type ACL |
| `GET /v1/{entityType}/facets?q=&filter[…]=` | facet counts for the filter sheet ("Status: Open (42)") | as list |
| `GET /v1/{entityType}/filter-schema` | the filter definitions (or bundle client-side) | as list |
| `GET/POST/PATCH/DELETE /v1/me/saved-views?entityType=` | manage saved views | self |
| `GET /v1/me/recent-searches?entityType=` · `DELETE …` | recents | self |
| `GET /v1/search/suggest?q=` | type-ahead suggestions (titles, entities) | authenticated |

Conventions: keyset pagination (`cursor`/`nextCursor`); `q` optional; filters are `filter[key]=value` (repeatable for multi); `sort` is `field` / `-field`; response `{ items, nextCursor, facets?, total? }` (`total` only when cheap).

### 8. State Management Suggestions
- A reusable `SearchFilterController<T>` bound to a `RecordListConfig`:
  - `query` (debounced 275 ms, cancels superseded requests), `filters: Map<key, value>`, `sort`, `page/cursor`.
  - Derives the query string; **serializes to / restores from the route** (`?q=&filter[…]=&sort=`) so state survives navigation + deep links.
  - `activeFilterChips` (removable), `clearAll`, `resultCount` (announced politely).
  - `recentSearches` (local + server), `savedViews` (server); applying a view sets query+filters+sort atomically.
- `FilterSheetController` — holds a **draft** of filters; "Apply" commits to `SearchFilterController` (batch); single quick-filter chips apply instantly.
- Results use the query cache; identical `(q, filters, sort)` reuse the cached page; scroll position kept via a keep-alive provider.
- Global search: a `GlobalSearchController` fanning out per selected `type`, each a separate paged query, results grouped.

### 9. Jetpack Compose Implementation Suggestions
- `:core:search` (reusable) + per-feature usage. `SearchFilterViewModel` exposes `StateFlow<SearchUiState>`; `query` via `snapshotFlow { text }.debounce(275).distinctUntilChanged()`.
- `M3 SearchBar` / `DockedSearchBar` for global search with a suggestions `LazyColumn`.
- `FilterSheet` = `ModalBottomSheet` + a `FilterSchema`-driven list of chip groups / range sliders / pickers; a sticky "Apply (N)" button.
- Route state via `SavedStateHandle` / nav args; deep links `navDeepLink { uriPattern = ".../{entityType}?q={q}" }`.
- Paging 3 `Pager` keyed by the full filter tuple → auto-refetch on change.

### 10. Flutter Implementation Suggestions
- `core_search` package. `searchFilterControllerProvider.family<T>` (Riverpod) holding the tuple; `ref.listen` writes to `GoRouterState` query params; restore on build.
- `Debouncer` util (275 ms) + `CancelToken` on the `dio` request.
- `FilterSheet` via `showModalBottomSheet(isScrollControlled: true)` driven by a `FilterSchema`; returns the draft on Apply.
- `infinite_scroll_pagination` `PagingController` re-created (or `.refresh()`) when the tuple changes.
- `SearchAnchor`/`SearchBar` (Material 3) for global search.

### 11. React Native Implementation Suggestions
- `features/search` hooks: `useSearchFilter<T>(entityType)` returns `{ query, setQuery, filters, setFilter, sort, chips, clearAll, results }`.
- `query` debounced with `useDeferredValue` / a `useDebounce` hook; React Query `useInfiniteQuery` keyed by `[entityType, q, filters, sort]` (auto-refetch on key change); `AbortController` via React Query.
- Route sync with `useSearchParams` (React Navigation `linking`).
- `FilterSheet` via `@gorhom/bottom-sheet` + a schema-driven form; `<ActiveFilterChips/>` row.
- Global search: `useInfiniteQuery` per type, render grouped `SectionList`.

### 12. Security Considerations
- **ACL at query time** — the search service **always** appends `tenant_id = <caller>` + an ACL filter (`acl_tags` ∩ the caller's grants) to every query; a user must never be able to disable or widen this. Index documents carry `acl_tags` computed from the source record's ownership/visibility.
- **Field-level exclusion** — sensitive fields (PII, salary, medical) are either not indexed or stored in a separate restricted field that's only returned/searched for callers with the right permission.
- **Injection** — treat `q` and `filter[…]` as data: use the search client's structured query builder, never string-concatenate a query DSL; validate filter keys against the `filter_schema` (reject unknown keys); cap `limit`, `q` length, and the number of filters.
- **Enumeration** — rate-limit search; don't reveal counts/existence of restricted items via facet totals (apply the same ACL filter to facets; suppress small cohorts).
- **Deep links** — `?q=` and `?filter=` are fine in the URL (not secrets); never put a record id that is itself sensitive, or any token, in the query string.
- **Stale ACLs** — when a record's visibility changes, the indexer must re-project it promptly; the reconciliation job bounds drift; high-security tenants can force a source-of-truth permission re-check on result render.
- **PII in recents** — `recent_search` may capture names the user typed; treat it as user data, purge on account deletion, don't sync to analytics.

### 13. Scalability Considerations
- **Don't `ILIKE` at scale** — once an entity exceeds ~50k rows or needs typo tolerance/relevance, move to a dedicated search index; keep Postgres FTS (`tsvector` + GIN) as the small-tenant / offline fallback.
- **Index sync** via the event bus (outbox) with a bounded consumer; batch upserts; a nightly full reconciliation; monitor indexer lag (search freshness SLO).
- **Facets are expensive** — compute only the facets the sheet shows, cache them per `(entityType, filter-tuple, user-scope)` for a short TTL, and lazy-load them when the sheet opens (not with the list).
- **Keyset pagination** everywhere; never deep-offset a search index.
- **Query cost caps** — max clauses, max `q` terms, timeouts; degrade gracefully ("showing partial results").
- **Global search** fans out to N type-indices in parallel with per-type timeouts; return what's ready.
- **Hot queries** (empty-query "recent items", common filters) served from a cache.
- **Multi-region** — regional read replicas of the index; writes go through the primary indexer.

---

## Feature: File Upload

### 1. Purpose
A reusable capability to attach files (photos, documents, signatures, scanned barcodes-as-images) to any record — capture/pick, client-side processing (compress, strip EXIF, thumbnail), resumable direct-to-storage upload, virus scanning, per-file progress and retry, offline queueing, and permissioned retrieval — used by incident reports, work orders, expenses, profiles, support tickets, and more.

### 2. Business Flow
1. **Select** — user takes a photo, records a video, picks from the library, or picks a document; the client validates type/size against the feature's policy.
2. **Prepare** — client compresses images (target long-edge + quality), strips or normalizes EXIF (keep orientation, drop GPS unless the feature needs it), generates a thumbnail, computes a checksum.
3. **Request** — client asks the API for a **direct-upload URL** (pre-signed) for object storage, passing filename, size, content-type, checksum → gets a URL + an `attachment` id in `pending` state.
4. **Upload** — client uploads **directly to object storage** (resumable/multipart for large files), reporting progress; retries with backoff on failure; on completion notifies the API (`POST …/complete`).
5. **Scan & finalize** — the API/storage triggers a **malware scan** + type sniffing (magic bytes, not the extension); on pass → `ready`, thumbnail generated server-side if needed; on fail → `quarantined`, the user is told.
6. **Attach** — the `attachment` id is linked to the parent record on save (or immediately, per feature); it appears in the record's Documents/Attachments section.
7. **Retrieve** — viewing an attachment fetches a short-lived signed download/preview URL after a permission check.
8. **Lifecycle** — orphaned `pending` uploads are garbage-collected; deleting the parent soft-deletes attachments; retention/legal-hold rules apply.

### 3. UX Flow
```
Form / Detail "Add attachment" → source sheet (Camera / Photo library / Files / Scan)
  → capture/pick → (image) inline crop/rotate → thumbnail appears with a progress ring
  → upload runs in background; per-file: progress %, Cancel, Retry-on-fail
  → done → thumbnail solid + tap to preview; long-press → Remove
  → offline → file queued with a "Pending upload" chip; uploads on reconnect; form can still be saved (attachment links when ready)
  → scan fail → the file shows "Couldn't be attached (failed security scan)" + Remove
Preview → full-screen viewer (pinch-zoom images, PDF pager, download/share)
```
Touch points across [`../screen-library/04-data-management.md`](../screen-library/04-data-management.md) (Create/Edit Form, Detail Documents tab), [`08-profile.md`](../screen-library/08-profile.md) (avatar), [`10-help-center.md`](../screen-library/10-help-center.md) (Contact Support).

### 4. Screen Mapping
| Surface | Where | Template |
|---|---|---|
| Attachment field | inside Create/Edit Form | screen-library 04 §4.3, form engine field type `attachment` |
| Source picker | bottom sheet | Archetype (bottom sheet) |
| Image crop/rotate | modal | Archetype A/E |
| Documents/Attachments tab | Data Detail | 04 §4.2 |
| File viewer | full-screen modal | Archetype D/media viewer |

### 5. Required Components
Bottom Sheet (source picker) [16 §6](../component-library/api-reference.md) · Buttons / Icon Buttons [16 §1,2](../component-library/api-reference.md) · Progress (per-file ring / bar) [16 component-lib E1] · Card/thumbnail grid · Dialog (remove confirm) [16 §7](../component-library/api-reference.md) · Snackbar (upload failed / queued) [16 §12](../component-library/api-reference.md) · Banner (offline queue) · Progressive image [16 component-lib F]. Feature composites: `AttachmentField`, `AttachmentThumbnail(progress,state)`, `FileViewer`, `UploadQueueIndicator`.

### 6. Database / Store Suggestions
| Entity | Key columns | Notes |
|---|---|---|
| `attachment` | `id, tenant_id, owner_id, parent_type, parent_id?, filename, content_type, size_bytes, checksum_sha256, storage_key, thumb_key?, state (pending/uploading/scanning/ready/quarantined/failed), width/height/duration?, exif_stripped, created_by, created_at, deleted_at?` | `parent_id` null until linked |
| `attachment_scan` | `id, attachment_id, engine, verdict, details, scanned_at` | |
| `upload_session` | `id, attachment_id, method (put/multipart), parts?, expires_at, completed_at` | resumable state |
| Object storage | `s3://bucket/tenant/<yyyy>/<mm>/<attachmentId>/<filename>` + a `thumbnails/` prefix | private bucket, SSE, versioning, lifecycle rules |
| `attachment_access_log` | `attachment_id, user_id, action (view/download), at` | for sensitive docs |

Indexes: `attachment(parent_type, parent_id) WHERE deleted_at IS NULL`, `attachment(state, created_at)` (GC of stale `pending`), `attachment(owner_id)`.

### 7. API Endpoint Suggestions
| Method · Path | Purpose | AuthZ |
|---|---|---|
| `POST /v1/attachments` | `{filename, contentType, size, checksum, parentType, parentId?}` → `{attachmentId, uploadUrl \| multipartUrls, headers, expiresAt}` | permission to attach to that parent type; size/type policy check |
| `PUT <uploadUrl>` (direct to storage) | the bytes (single or per-part) | pre-signed (time + size + content-type bound) |
| `POST /v1/attachments/{id}/complete` | `{parts?}` → triggers scan → `state: scanning` | owner |
| `GET /v1/attachments/{id}` | metadata + `state` | permission on the parent |
| `GET /v1/attachments/{id}/content?disposition=inline\|attachment` | 302 → short-lived signed URL (or streams) | permission + logs access |
| `GET /v1/attachments/{id}/thumbnail` | signed thumb URL | permission |
| `DELETE /v1/attachments/{id}` | soft-delete / unlink | owner or parent-editor |
| `GET /v1/{parentType}/{parentId}/attachments` | list for a record | parent read permission |
| `POST /v1/attachments/{id}/link` | attach a `pending`→`ready` file to a parent on form save | parent editor |

### 8. State Management Suggestions
- An `UploadManager` service (app-scoped, survives screen navigation): a queue of `UploadTask { localUri, attachmentId?, progress, state, retries }`; runs 2–3 concurrent; exposes a `Stream/Flow<List<UploadTask>>`.
- The `AttachmentField` (form engine) holds a list of `{attachmentId | localTask}`; on form submit it waits for `ready` ids or submits with `pending` ids the server links on scan completion (per feature policy).
- **Offline**: tasks persist (local DB + the file copied to app storage); the `UploadManager` drains the queue when `Connectivity` returns; the field shows "Pending upload" chips; the parent form can be saved and reconciles later.
- Progress is per-task; failures surface an inline Retry; scan-fail moves the task to a terminal `quarantined` with a message.
- Previews fetch a signed URL on demand (short cache); the viewer caches decoded images.

### 9. Jetpack Compose Implementation Suggestions
- `:core:files`. Capture/pick: `ActivityResultContracts.TakePicture`, `PickVisualMedia`, `GetContent`, ML Kit / `mlkit-barcode` for scan.
- Image prep: `BitmapFactory` + `inSampleSize` downscale, `ExifInterface` (preserve `ORIENTATION`, remove `GPS*`), a WebP/JPEG re-encode; generate a 96–256px thumbnail.
- Upload: **`WorkManager`** with a foreground service for large files + a unique work name per task (survives process death); OkHttp with a `RequestBody` that reports progress; multipart to S3 for > ~10 MB, resumable.
- Persist the queue in Room; observe via `Flow`.
- Viewer: `Coil` for images (pinch-zoom via `Modifier.transformable`), a PDF renderer (`PdfRenderer`) for documents.

### 10. Flutter Implementation Suggestions
- `core_files` package. Pick/capture: `image_picker`, `file_picker`, `camera`, `mobile_scanner` (barcode); crop via `image_cropper`.
- Image prep: `flutter_image_compress` (quality + `keepExif: false`), or `image` package for EXIF control; thumbnail via a second compress pass.
- Upload: `dio` with `onSendProgress`; for resumability + background, use `background_downloader` (supports uploads) or `flutter_uploader`; copy the file into the app dir first so it survives.
- Queue persisted in `drift`/`hive`; a `uploadManagerProvider` (Riverpod) exposes the task list; drains on `connectivityProvider` changes.
- Viewer: `photo_view` (images), `pdfx`/`syncfusion_flutter_pdfviewer` (PDF), `video_player`.

### 11. React Native Implementation Suggestions
- `features/files`. Pick/capture: `react-native-image-picker` / `expo-image-picker`, `react-native-document-picker`, `vision-camera` + a barcode plugin.
- Image prep: `react-native-compressor` (image/video) or `@bam.tech/react-native-image-resizer`; EXIF via `react-native-exif` (strip GPS); thumbnail = a small resize.
- Upload: `react-native-blob-util` (`fetch` with progress) or `rn-fetch-blob`; for background + resumable use `react-native-background-upload`; TUS (`tus-js-client` + a TUS-capable endpoint) is a good resumable option.
- Queue in MMKV/SQLite; an `UploadManager` singleton with a Zustand store of tasks; drain on `NetInfo` reconnect.
- Viewer: `react-native-image-zoom-viewer` / `react-native-pdf` / `react-native-video`.

### 12. Security Considerations
- **Direct-to-storage with pre-signed URLs** — the API never proxies bytes; the pre-signed URL is bound to the exact key, content-type, max size, and a short expiry; the bucket is **private** (no public ACLs, block-public-access on).
- **Type validation by content, not extension** — sniff magic bytes server-side; reject mismatches and dangerous types (executables, HTML, SVG-with-scripts unless sanitized); re-encode images server-side to drop embedded payloads.
- **Malware scanning** — every upload is scanned before `ready`; unscanned/`pending` files are never served to other users; `quarantined` files are isolated and reported.
- **EXIF / metadata** — strip GPS and personal metadata from images by default (client + server); keep only orientation; document any feature that intentionally keeps location (e.g. field inspection photos) and get consent.
- **Access control on retrieval** — every `GET content/thumbnail` re-checks permission on the parent record and issues a **short-lived** signed URL (minutes); log access for sensitive document types; support watermarking for confidential PDFs.
- **Size / quota / abuse** — per-file and per-record size caps, per-user upload quotas, rate limits; reject zip bombs (decompression ratio checks if you expand archives).
- **Orphan & retention** — GC `pending` uploads older than N hours; deleting a parent soft-deletes attachments; honor legal hold; hard-purge on retention expiry (and wipe from storage + backups per policy).
- **No sensitive data in filenames or storage keys** (they can appear in logs/URLs); generate opaque keys.
- **Client storage** — queued files in the app's private sandbox, cleared after successful upload; encrypt at rest for sensitive features.

### 13. Scalability Considerations
- **Offload bytes to object storage + CDN** — the API only handles small JSON (init/complete/metadata); bandwidth scales with the storage/CDN, not your servers.
- **Resumable/multipart uploads** for large or flaky-network files (field workers on cellular) — parts retried independently; TUS or S3 multipart.
- **Async post-processing** — scanning, server-side thumbnailing, transcoding, OCR run as queued jobs off an `attachment.uploaded` event; the record can reference a `scanning` attachment and update when `ready`.
- **Thumbnails / variants** — generate a small set of sizes once; serve via CDN with long cache; use an on-the-fly image resizing service for arbitrary sizes.
- **Storage lifecycle** — tiered storage (hot → infrequent-access → archive) by age; lifecycle rules auto-delete expired exports/orphans.
- **Hot downloads** — signed URLs + CDN edge caching (careful with per-user auth — use short-lived signed CDN URLs, not shared cache keys for private content).
- **Indexing** — attachment metadata is small and lives in OLTP; the objects don't; list endpoints paginate and return thumb URLs, not bytes.
- **Multi-region** — buckets per region with replication for DR; upload to the nearest region; the metadata DB records the region.

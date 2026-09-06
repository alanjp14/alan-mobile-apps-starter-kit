# Figma File Structure

> Part of the [Alan Mobile Design System](README.md). How AMDS is organized in Figma so designers can find, use, and contribute without breaking things.

---

## 1. Team & project layout

```
Figma Org
└── Team: [COMPANY_NAME] Design
    ├── Project: AMDS — Design System        ← the system itself (restricted edit)
    │   ├── 🎨 AMDS · Foundations            (library)
    │   ├── 🧩 AMDS · Components             (library)
    │   ├── 🧱 AMDS · Patterns & Templates   (library)
    │   ├── 🌗 AMDS · Theme Preview          (working file)
    │   └── 📦 AMDS · Icons                  (library)
    ├── Project: Product — HRIS
    │   ├── HRIS · Product Design            (consumes AMDS libraries)
    │   └── HRIS · Explorations
    ├── Project: Product — K3 Mining
    ├── Project: Product — Asset Mgmt
    └── Project: _Sandbox                    (anyone, throwaway)
```

- **Libraries** (`AMDS · *`) are published; product files **enable** them, never edit them.
- Edit access to `AMDS — Design System` project: core team + reviewers. Everyone else: view + suggest, contribute via the `_Sandbox` + a proposal.
- Branching (Figma) used for all system changes; merged only after review.

---

## 2. `AMDS · Foundations` (library file)

Pages:

| Page | Contents |
|---|---|
| `▸ Cover` | Version, changelog link, owners, "how to use this library" |
| `01 Color` | Primitive ramps (green, slate, amber, red, sky) as **color styles** `amds/green/600` etc.; semantic aliases `amds/light/primary`, `amds/dark/primary` as **variables** in a `theme` collection with `Light`/`Dark` modes; contrast annotations |
| `02 Typography` | **Text styles** `amds/display/large` … `amds/overline`; Inter specimen; scaling notes |
| `03 Spacing & Grid` | Spacing variables `amds/space/4`; layout grids (4-col/8-col/12-col); redline stickers |
| `04 Radius & Borders` | Radius variables; corner examples |
| `05 Elevation` | Effect styles `amds/elevation/1..5` (light) + `amds/elevation/dark/1..5` |
| `06 Iconography` | Usage rules, sizing, the standard concept→glyph map (mirrors [design foundations](../design-system/README.md) §6.4) |
| `07 Motion` | Duration/easing reference, principle cards (documentation, not animatable) |

**Variable collections**

- `primitives` — one mode. Raw values.
- `theme` — modes: `Light`, `Dark`. Semantic aliases → primitives.
- `scale` — one mode. Spacing, radius, size, z-index.
- Product files switch the `theme` mode to preview dark.

---

## 3. `AMDS · Components` (library file)

- **One page per component group** (`Actions`, `Inputs`, `Selection`, `Containment`, `Feedback`, `Navigation`, `Progress`, `Data`).
- Each component is a **component set** with props matching the code API ([developer handoff](../starter-template/developer-handoff.md) §3): `Variant`, `Size`, `State`, `Leading icon` (bool), `Trailing icon` (bool), `Full width` (bool).
- **Naming:** `Button`, `Button / Icon`, `Text Field`, `Card / KPI`. Slash = hierarchy. No versions or colors in names.
- Every component page has: anatomy frame, variants matrix, states matrix (incl. dark via a mode swap), do/don't examples, a link to its [component library](../component-library/README.md) section, and a redline sticker sheet.
- **Slots** via component properties (`instance swap`, `text`) so product designers configure, not detach.
- Interactive states use Figma variant switching; motion is described in text (see Motion page) — prototypes for demo live in `Theme Preview`, not the library.

---

## 4. `AMDS · Patterns & Templates` (library file)

Pages:

| Page | Contents |
|---|---|
| `Navigation` | Bottom nav, app bar variants, drawer, tabs, breadcrumb — as components + usage |
| `Screen Templates` | The 15 templates ([screen library](../screen-library/README.md)) as **frames** at 375 + 905, each with layout annotations; provided as **template components** or a duplicatable "Starter" frame set |
| `Dashboard Kit` | The 4 dashboard archetypes ([dashboard system](../screen-library/dashboard-system.md)) + the block kit |
| `Forms` | CRUD layouts, validation states, approval workflow ([form design system](../screen-library/form-design-system.md)) |
| `Tables` | Table + row-transformation + filter/sort sheets ([data display](../component-library/data-display.md)) |
| `Empty / Loading / Error` | The standard states, ready to drop in |
| `Starter` | A blank product-file structure to duplicate (see §6) |

---

## 5. `AMDS · Theme Preview` (working file, not published)

- Live gallery of every component in Light + Dark (mode switch), at 100% and 200% text.
- Prototype flows demonstrating motion patterns ([motion](../design-system/motion.md)) for reference.
- Where the core team stress-tests changes on a branch before publishing.

---

## 6. Product file structure (what each app duplicates from `Starter`)

```
<Product> · Product Design
├── ▸ Cover              app name, links, status
├── 🗺️ Flows            userflow diagrams / FigJam links
├── 📐 Foundations (local) only genuine app-specific additions; must be proposed upstream if reusable
├── 📱 <Feature A>
│   ├── Frames: 375 primary, 905 tablet
│   ├── States: empty / loading / error / RTL / 200%
│   └── Prototype
├── 📱 <Feature B>
├── 🧪 Explorations      messy, dated, not linked from flows
└── 🗄️ Archive           shipped/abandoned, dated
```

Rules:

- Enable the three AMDS libraries. Use their components and styles/variables.
- **No local color/text styles** except genuinely app-unique needs — and those get a proposal to add upstream.
- Frame naming: `A1 · Dashboard`, `A2 · Asset list`, `A2.1 · Filter sheet` — matches deep-link routes where possible.
- Mark `Ready for dev` per section; keep Dev Mode clean.

---

## 7. Naming conventions

| Item | Pattern | Example |
|---|---|---|
| Color style (primitive) | `amds/<ramp>/<step>` | `amds/green/600` |
| Color variable (semantic) | `<group>/<role>` in `theme` collection | `text/primary`, `surface/variant` |
| Text style | `amds/<role>/<size>` | `amds/heading/medium` |
| Effect style | `amds/elevation/<n>` | `amds/elevation/3` |
| Spacing variable | `space/<token>` | `space/4` |
| Component | `<Name>` or `<Group> / <Name>` | `Card / KPI` |
| Variant prop values | lowercase, match code | `variant=primary`, `size=md`, `state=disabled` |
| Frame (product) | `<code> · <Screen name>` | `A2 · Asset list` |
| Branch | `type/short-description` | `feat/segmented-control`, `fix/switch-contrast` |

---

## 8. Contribution flow in Figma

1. Duplicate the relevant component into `_Sandbox` or start a **branch** of the Components file.
2. Build against the checklist ([component library](../component-library/README.md) §G): all variants, sizes, states, dark, redlines, do/don'ts.
3. Open a proposal (link the branch/frame) in the design-system tracker.
4. Design review (core team) → address feedback on the branch.
5. Core team merges the branch, bumps the version, updates the [component library](../component-library/README.md) page, publishes the library.
6. Announce; product files get the update on next library sync.

---

## 9. Housekeeping

- **Publish** library changes with a clear changelog message per component.
- **Deprecate** in Figma: rename to `⚠️ Deprecated / <Name>`, description points to the replacement, keep for 2 minor versions.
- Quarterly audit: detached instances in product files (Figma "Detached" report), unused local styles, components not in the library.
- Keep the Figma version and the `tokens.json` version in lockstep (state both on every cover).
- One source of truth for tokens is `tokens.json`; Tokens Studio syncs Figma variables ↔ that file — resolve conflicts in favor of the repo.

# Project Structure

> Part of the [starter template](README.md). Reference repository layouts for consuming AMDS on each platform (Compose · Flutter · React Native), plus the shared design-system repo. Feature-first, token-driven, testable.

---

## 1. The design-system repo (this template's evolution)

```
alan-mobile-design-system/
├── README.md
├── CHANGELOG.md
├── docs/                          ← the documentation (this deliverable)
│   └── 01..15 *.md
├── tokens/
│   ├── tokens.json                ← source of truth (W3C DTCG)
│   ├── tokens.dark.json           ← (optional split; or modes inside tokens.json)
│   ├── build/
│   │   └── style-dictionary.config.js
│   └── dist/                      ← generated, git-ignored or committed per policy
│       ├── variables.css
│       ├── tailwind.config.js
│       ├── amds_theme.dart
│       ├── Theme.kt
│       ├── theme.ts
│       └── Tokens.swift
├── packages/                      ← published component libraries (if monorepo)
│   ├── amds-compose/              (Android, Maven)
│   ├── amds-swiftui/              (iOS, SPM)
│   ├── amds-flutter/              (pub)
│   └── amds-react-native/         (npm)
├── figma/
│   └── tokens-studio-sync.json    ← Tokens Studio config
├── assets/
│   ├── fonts/inter/
│   ├── icons/                     (Lucide subset, custom glyphs)
│   └── illustrations/             (light + dark)
├── .github/workflows/             (tokens build, contrast lint, visual regression, publish)
└── scripts/
```

Publish each platform library to its ecosystem registry; version = AMDS version.

---

## 2. Android (Jetpack Compose) — feature-first

```
app/
├── build.gradle.kts
└── src/main/java/com/alan/<app>/
    ├── AlanApp.kt                       Application, DI setup
    ├── MainActivity.kt                  enableEdgeToEdge, setContent { AmdsTheme { … } }
    ├── di/                              Hilt modules
    ├── core/
    │   ├── designsystem/                ← AMDS integration
    │   │   ├── theme/                   Theme.kt, Color.kt, Type.kt, Shape.kt, Spacing.kt  (from tokens/)
    │   │   ├── component/               thin wrappers/extensions over amds-compose if needed
    │   │   └── icon/                    AppIcons.kt (concept → ImageVector)
    │   ├── data/                        network, db, datastore (shared)
    │   ├── domain/                      models, use cases (shared)
    │   ├── common/                      Result, dispatchers, formatters (date/number/currency)
    │   └── navigation/                  AppNavHost.kt, routes, deep-link graph ([navigation patterns](../design-system/navigation-patterns.md) §9)
    ├── feature/
    │   ├── dashboard/
    │   │   ├── DashboardScreen.kt       @Composable, stateless
    │   │   ├── DashboardViewModel.kt
    │   │   ├── DashboardUiState.kt
    │   │   ├── component/               screen-local composables
    │   │   └── navigation/              DashboardNav.kt (route + arguments + deep links)
    │   ├── assets/  (list, detail, form under one feature)
    │   ├── approvals/
    │   ├── notifications/
    │   ├── profile/
    │   ├── settings/
    │   └── auth/                        login, register, forgot
    └── res/                             strings (localized), fonts (inter), launch, adaptive icon
src/test/            unit (ViewModels, use cases)
src/androidTest/     Compose UI + a11y (AccessibilityChecks) + Roborazzi snapshots
```

Rules: screens are stateless composables fed a `UiState`; ViewModels expose `StateFlow`; navigation per feature module; all colors/dimens from `AmdsTheme`; strings in `res/values*/strings.xml`.

Optionally split into Gradle modules: `:core:*`, `:feature:*`, `:app` for build speed and boundaries.

---

## 3. iOS (SwiftUI) — feature-first

```
<App>/
├── App/
│   ├── <App>App.swift                  @main, WindowGroup, .environment(theme)
│   └── AppDelegate.swift               (if needed)
├── DesignSystem/                       ← AMDS integration (or SPM dependency amds-swiftui)
│   ├── Tokens.swift                    Color/Font/Spacing/Radius (generated)
│   ├── Assets.xcassets/               amds/* colors (Any + Dark)
│   ├── Typography.swift                .amdsTitleMedium … (Dynamic Type)
│   └── Components/                     Button, TextField, Card, Sheet wrappers
├── Core/
│   ├── Networking/
│   ├── Persistence/
│   ├── Models/
│   ├── Formatters/                     date, number, currency
│   └── Navigation/
│       ├── AppRoute.swift              enum, Codable, deep-link parsing
│       └── Router.swift                NavigationStack path management
├── Features/
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   ├── DashboardModel.swift        @Observable / ObservableObject
│   │   ├── DashboardState.swift
│   │   └── Components/
│   ├── Assets/
│   ├── Approvals/
│   ├── Notifications/
│   ├── Profile/
│   ├── Settings/
│   └── Auth/
├── Resources/
│   ├── Fonts/Inter/
│   ├── Localizable.xcstrings
│   └── Illustrations/
└── Tests/
    ├── UnitTests/
    └── UITests/                        XCUITest + performAccessibilityAudit + snapshot
```

Rules: views are thin; state in `@Observable` models; navigation via a typed `AppRoute` + `NavigationStack`; colors via asset catalog (auto dark); text via `.amds*` styles with `relativeTo:` for Dynamic Type.

---

## 4. Flutter — feature-first

```
lib/
├── main.dart                           runApp; MaterialApp(theme, darkTheme, themeMode)
├── app/
│   ├── app.dart
│   └── router.dart                     GoRouter; routes + deep links ([navigation patterns](../design-system/navigation-patterns.md) §9)
├── design_system/                      ← AMDS (or package amds_flutter)
│   ├── amds_theme.dart                 (from tokens/)
│   ├── icons.dart                      AppIcons
│   └── components/                     buttons, fields, cards, sheets, states
├── core/
│   ├── network/
│   ├── storage/
│   ├── error/                          Failure, Result
│   ├── formatters/
│   └── extensions/
├── features/
│   ├── dashboard/
│   │   ├── presentation/
│   │   │   ├── dashboard_page.dart
│   │   │   ├── dashboard_controller.dart   (Riverpod/BLoC)
│   │   │   ├── dashboard_state.dart
│   │   │   └── widgets/
│   │   ├── domain/                     entities, usecases, repository interface
│   │   └── data/                       models, datasources, repository impl
│   ├── assets/
│   ├── approvals/
│   ├── notifications/
│   ├── profile/
│   ├── settings/
│   └── auth/
├── l10n/                               arb files
└── shared/                             widgets used across features
test/                                   unit + widget + golden (light & dark)
integration_test/                       flows + meetsGuideline a11y checks
assets/
├── fonts/inter/
└── illustrations/
```

Rules: clean-ish layers per feature (presentation / domain / data); theme only via `Theme.of(context)` + `AmdsTokens` extension; `flutter gen-l10n` for strings; golden tests for both themes.

---

## 5. React Native — feature-first

```
src/
├── App.tsx                             ThemeProvider + NavigationContainer (linking config)
├── theme/                              ← AMDS (or package @alan/amds-react-native)
│   ├── theme.ts                        amdsLight / amdsDark (from tokens/)
│   ├── ThemeProvider.tsx               context + useTheme()
│   └── components/                     Button, TextField, Card, BottomSheet, states
├── navigation/
│   ├── RootNavigator.tsx
│   ├── linking.ts                      deep-link config ([navigation patterns](../design-system/navigation-patterns.md) §9)
│   └── types.ts
├── core/
│   ├── api/                            client, endpoints, react-query
│   ├── storage/                        MMKV / secure store
│   ├── format/                         date, number, currency (Intl)
│   └── hooks/
├── features/
│   ├── dashboard/
│   │   ├── DashboardScreen.tsx
│   │   ├── useDashboard.ts             data hook (react-query)
│   │   ├── dashboard.types.ts
│   │   └── components/
│   ├── assets/
│   ├── approvals/
│   ├── notifications/
│   ├── profile/
│   ├── settings/
│   └── auth/
├── components/                         truly shared, non-DS app components
├── i18n/                               locales, i18next
└── assets/
    ├── fonts/Inter/
    └── illustrations/
tests/                                  jest + RNTL + a11y lint; e2e/ (Detox)
```

Rules: one data hook per feature (react-query); screens consume `useTheme()`; no inline hex/spacing; strings via i18n; `linking` config keeps routes addressable.

---

## 6. Cross-cutting conventions (all platforms)

| Concern | Convention |
|---|---|
| **Naming** | Features are domain nouns (`assets`, `approvals`), not layout (`screens`, `pages`) |
| **Screen = state + view** | View is dumb and stateless; a ViewModel/Model/Controller/hook owns state and effects |
| **Design tokens** | Imported from the generated theme only; lint forbids raw hex, raw dp, `#`, magic numbers in UI |
| **Icons** | One `AppIcons` map (concept → asset); components never reference raw icon names |
| **Strings** | 100% externalized and localizable from day one; no string concatenation |
| **Formatting** | Central date/number/currency formatters that respect locale + timezone |
| **Navigation** | Routes defined per feature, aggregated centrally; every list/detail is deep-linkable |
| **Errors** | A `Result`/`Either` type; UI maps failures to the standard error states ([form design system](../screen-library/form-design-system.md) §7) |
| **Feature flags** | A single flag service; flags named `feature.<area>.<name>` |
| **Analytics** | One tracking module; events defined alongside the feature, not scattered |
| **Tests** | Unit (state/logic) + snapshot (component × variant × state × theme) + a11y + e2e for top flows |
| **Env config** | `dev` / `staging` / `prod` via build config; no secrets in the repo |
| **Accessibility** | a11y IDs/labels are part of the component contract, not an afterthought |

---

## 7. Monorepo vs per-app

- **Design system:** its own repo, published as versioned packages. ✅
- **Apps:** separate repos per product (independent release cadence, permissions, teams). Share code via the DS packages + a small `@alan/core-mobile` utility package (formatters, networking base, auth) if duplication becomes real.
- Avoid a giant mobile monorepo unless one team owns all apps and tooling maturity is high.

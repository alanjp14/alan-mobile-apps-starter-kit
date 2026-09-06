# Navigation (routing architecture)

> Part of the [starter template](README.md). **Design** patterns for nav components are in [`../design-system/navigation-patterns.md`](../design-system/navigation-patterns.md). This file is the **routing architecture**. Full platform table: [`blueprint.md §3`](blueprint.md).

---

## 1. Route model

- **Typed routes**, defined per feature, aggregated in `core/navigation`. No stringly-typed navigation.
- Two graphs:
  - **`AuthGraph`** — splash, onboarding, login, register, forgot/reset, verify. **No** bottom nav.
  - **`AppGraph`** — a `ShellRoute` hosting the adaptive nav + all feature routes.
- **Adaptive shell:** bottom navigation (phone) → navigation rail (small tablet) → persistent drawer (large tablet), by window size class.
- **Guards / redirects:** unauthenticated → `/login` (store `pendingDeepLink`); missing permission → `/denied`; forced password change → `/security/change-password`; unknown → `/not-found`.
- **Back** is temporal (reverses the last navigation). Switching primary destinations is not "back". Modals `close`, they don't go back. Dirty-form guard on dismiss.
- **State preservation:** list filters / sort / scroll and the selected tab are preserved per session.

## 2. Deep links

Scheme: `[APP_NAME]://[app]/[section]/[resource]/[id]?[params]` + verified `https://` App Links / Universal Links.

- **Back-stack synthesis:** entering at `/[resource]/[id]` builds `[Dashboard, [resource] list, [resource] [id]]` so Back is sensible.
- **Auth gate:** an unauthenticated deep link → Login, then continue to the target.
- **Permission gate:** no access → a clear "You don't have access" screen, not a generic error.
- **Not found / stale:** deleted id → "This item no longer exists" + a link to the list.
- **No secrets in URLs** — filters and tabs yes; tokens or sensitive ids never.
- Every list and detail screen is addressable; new features define their routes at design time.

Canonical route table: [`../design-system/navigation-patterns.md §9`](../design-system/navigation-patterns.md).

## 3. Route registry (concept)

```
routes = [
  Route("/",                 SplashScreen),
  Route("/login",            LoginScreen,            graph = Auth),
  Route("/dashboard",        DashboardScreen,        graph = App, tab = Home),
  Route("/[resource]",       DataListScreen,         graph = App, deepLink = true),
  Route("/[resource]/{id}",  DataDetailScreen,       graph = App, deepLink = true,
                                                     backStack = ["/dashboard","/[resource]"]),
  Route("/[resource]/new",   CreateFormScreen,       graph = App, requires = "[resource]:create"),
  Route("/[resource]/{id}/edit", EditFormScreen,     graph = App, requires = "[resource]:update"),
  Route("/approvals",        ApprovalQueueScreen,    graph = App, tab = Approvals, badge = pendingApprovals),
  Route("/approvals/{id}",   ApprovalDetailScreen,   graph = App, deepLink = true),
  Route("/notifications",    NotificationListScreen, graph = App),
  Route("/profile",          ProfileScreen,          graph = App, tab = More),
  Route("/settings/**", "/help/**", …,               graph = App),
  Route("/sync/pending",     PendingChangesScreen,   graph = App),
  Route("/denied", "/not-found", ErrorScreens),
]
```

## 4. Platform

| | Compose | Flutter | React Native | SwiftUI |
|---|---|---|---|---|
| Library | `androidx.navigation:navigation-compose` (type-safe routes) | `go_router` | `@react-navigation/native` + `native-stack` | `NavigationStack` + typed `AppRoute` |
| Adaptive shell | `NavigationSuiteScaffold` + `WindowSizeClass` | `ShellRoute` + `LayoutBuilder` | `useWindowDimensions` → conditional navigator | `NavigationSplitView` / `TabView` |
| Guards | start-destination decider observing `SessionState` | `GoRouter(redirect:)` | root navigator switching `AuthStack`/`AppStack` | `@Environment` session + `.navigationDestination` |
| Deep links | `navDeepLink { uriPattern }` + verified `<intent-filter>` | `GoRouter` paths + `apple-app-site-association` / manifest | `linking: { prefixes, config }` | `onOpenURL` + `AppRoute` parse |
| Back-stack synth | build the stack in the deep-link handler before `navigate` | `redirect` returning a stack, or `.go()` with `extra` | `navigation.reset({ routes: [...] })` | set the `path` array |

## 5. Do / Don't

**Do** — typed routes per feature; guard reads the session; synthesize the back stack on deep-link entry; preserve list/tab state per session; adapt the shell by breakpoint.
**Don't** — stringly-typed navigation; put actions in the bottom nav; make "back" mean "up the hierarchy" except on deep-link entry; put tokens/sensitive ids in query strings.

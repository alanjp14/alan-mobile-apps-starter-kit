# Motion Implementation — Buttery-Smooth Transitions

> Part of the [starter template](README.md). Turns the [motion design tokens](../design-system/motion.md) into **60/120 fps, jank-free** transitions on Android and iOS.
> Rule of thumb: if a transition drops a frame on a 3-year-old mid-range Android, it is a bug — not "good enough".

---

## 1. The performance budget

| Target | Value |
|---|---|
| Frame budget | 16.6 ms (60 Hz) · 8.3 ms (120 Hz ProMotion / high-refresh Android) |
| Jank frames during any transition | **0** on the min-spec device |
| Cold-start → first frame | < 1 s (native splash) |
| Screen A → Screen B transition | 250 ms (`moderate`), no dropped frames |
| Input → visual feedback | ≤ 100 ms (a tap must acknowledge within `instant`) |
| Scroll | locked to display refresh, no stutter under a list of 10k items (virtualized) |

Measure it, don't guess — §7.

## 2. The five rules that make motion smooth

1. **Animate only `transform` (translate / scale / rotate) and `opacity`.** These run on the compositor / GPU and never trigger layout or paint. **Never** animate `width`, `height`, `padding`, `top/left`, `elevation` on a per-frame basis, or a list's item heights.
2. **Do work off the animation.** Never start a heavy task (network, JSON parse, image decode, DB query, chart data prep) in the same frame a transition begins. Kick it off *before* or *after*; show a skeleton in between.
3. **Pre-warm the destination.** Build/measure the next screen's first frame while the current screen is still visible (prefetch its data, pre-inflate its layout, pre-decode its hero image) so the transition has nothing to compute.
4. **Interruptible + velocity-aware.** A gesture-driven transition (edge-swipe back, sheet drag) must follow the finger 1:1 and, on release, continue with the fling velocity — not snap to a fixed duration. Use **springs**, not tweens, for anything the user can grab.
5. **Respect the tokens and reduced-motion.** Durations 100–400 ms, the 4 named easings ([motion.md](../design-system/motion.md)); every animation has a ≤150 ms crossfade fallback when the OS "reduce motion" flag is on.

## 3. Easing / spring reference (from the tokens)

| Token | Curve | Use |
|---|---|---|
| `standard` | `cubic-bezier(0.2, 0, 0, 1)` | most moves within a screen |
| `decelerate` | `cubic-bezier(0, 0, 0, 1)` | elements entering the screen |
| `accelerate` | `cubic-bezier(0.3, 0, 1, 1)` | elements leaving permanently |
| `spring` | `cubic-bezier(0.34, 1.56, 0.64, 1)` (or a real spring) | anything grabbable, "pop" affordances |

**Native spring tuning** (preferred over bezier where the platform has real springs): `dampingRatio ≈ 0.82`, `stiffness ≈ 380` for the `spring` feel; critically damped (`1.0`, stiffness `520`) for `standard`-like moves.

## 4. Per-platform implementation

### 4.1 Jetpack Compose (Android)

- **Screen transitions:** `androidx.navigation:navigation-compose` + `androidx.compose.animation` — shared-axis via `AnimatedContent` / the `material-motion-compose` helpers. Prefer `slideInHorizontally { it/3 } + fadeIn()` / `slideOutHorizontally { -it/4 } + fadeOut()` (parallax).
- **Springs:** `animateFloatAsState(target, spring(dampingRatio = 0.82f, stiffness = 380f))`; `Modifier.graphicsLayer { translationX = …; scaleX = …; alpha = … }` — this is a **draw-layer** change, no recomposition, no relayout.
- **Predictive back (Android 14+):** opt in (`android:enableOnBackInvokedCallback="true"`) + `PredictiveBackHandler` → drive a `translationX` + `scaleX` from the gesture progress.
- **Lists:** `LazyColumn` with **stable `key`s** + `Modifier.animateItemPlacement(spring())` for reorder/insert/remove — never animate item height manually.
- **Shared element:** `androidx.compose.animation` shared-element transitions (`SharedTransitionLayout` / `Modifier.sharedElement`) for list→detail hero.
- **Keep recomposition out of the frame:** hoist animation state, use `derivedStateOf`, `remember` lambdas, `@Stable`/`@Immutable` models; run `./gradlew … -Pandroidx.enableComposeCompilerReports=true` and fix unstable params.
- **Enable high-refresh:** nothing to do — Compose respects the display; just don't cap it.

### 4.2 Flutter

- **Screen transitions:** `go_router` + `CustomTransitionPage` using the `animations` package (`SharedAxisTransition`, `FadeThroughTransition`, `OpenContainer` for container-transform). iOS route → `CupertinoPage` (native interactive edge-swipe for free).
- **Springs:** `AnimatedScale` / `AnimatedSlide` / `AnimatedOpacity` with `curve: Curves.easeOutBack` (≈ `spring`), or a real `SpringSimulation` via an `AnimationController` for grabbable things. `flutter_animate` for declarative one-liners.
- **The golden rule:** wrap the animated subtree so only it rebuilds — `AnimatedBuilder(animation, builder:)` with the expensive child passed as `child:` (built once). Animate via `Transform` / `Opacity` / `FractionalTranslation`, not `Padding`/`SizedBox`.
- **Lists:** `SliverAnimatedList` / `AnimatedList` with keyed items; `flutter_staggered_animations` for the first-paint stagger (cap at 8). Never `AnimatedContainer` on row height in a scrolling list.
- **Hero:** `Hero` widget for list→detail; keep the flight shape simple.
- **Jank hunting:** run `flutter run --profile`, open DevTools → Performance, turn on "Track Widget Builds" + the raster/UI thread timeline. Watch for shader jank on first run → `flutter build … --bundle-sksl-shaders` (SkSL warm-up) or ship Impeller (default on iOS; enable on Android).
- **Impeller** (Flutter's new renderer) removes first-run shader jank — verify it's on for your Flutter version.

### 4.3 React Native

- **Everything on the UI thread:** use **`react-native-reanimated` v3** (worklets) + **`react-native-gesture-handler`** — never `Animated` with `useNativeDriver:false`, never `setState` in a gesture.
- **Screen transitions:** `@react-navigation/native-stack` (native screen transitions via `react-native-screens`, backed by `UINavigationController` / `FragmentTransaction` — natively smooth + interactive back for free). For custom transitions use `react-native-reanimated`'s shared-element (`react-native-shared-element` or Reanimated 3 shared transitions).
- **Springs:** `withSpring(target, { damping: 18, stiffness: 220, mass: 1 })`; animate `useAnimatedStyle` returning `transform`/`opacity` only.
- **Lists:** **`@shopify/flash-list`** (recycling, far less jank than `FlatList`); `itemLayoutAnimation` / `LinearTransition` from Reanimated for insert/remove; `entering={FadeInDown.delay(i*30)}` for the stagger (respect reduce-motion).
- **Frames:** enable the **Hermes** engine + the **New Architecture (Fabric)**; profile with the Reanimated "frame drops" overlay and Flipper / `react-native-performance`.
- **120 Hz:** iOS needs `CADisableMinimumFrameDurationOnPhone = YES` in `Info.plist`; Android high-refresh works out of the box with `react-native-screens`.

### 4.4 SwiftUI (iOS native)

- **Screen transitions:** `NavigationStack` (native push/pop + interactive edge-swipe). Custom: `.transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))` inside `withAnimation(.spring(response: 0.35, dampingFraction: 0.82))`.
- **Springs:** `withAnimation(.snappy)` / `.smooth` / `.bouncy` (iOS 17+) or `.spring(response:, dampingFraction:)`. `.matchedGeometryEffect(id:in:)` for hero transitions.
- **Sheets:** `.presentationDetents([.medium, .large])` + `.presentationDragIndicator(.visible)` — native, buttery, interactive.
- **Keep the body cheap:** small views, `@Observable` (not giant `ObservableObject`), `.drawingGroup()` for complex static layers, `EquatableView` where helpful. Profile with Instruments → SwiftUI + Animation Hitches template.
- **ProMotion:** free on capable devices; don't fight it.

## 5. Pattern → implementation cheat sheet

| AMDS pattern ([motion.md](../design-system/motion.md)) | Compose | Flutter | React Native | SwiftUI |
|---|---|---|---|---|
| Page push/pop (shared-axis X) | `AnimatedContent` + slide/fade | `animations` `SharedAxisTransition` | native-stack | `NavigationStack` |
| Modal / full-screen sheet | `ModalBottomSheet` / full route slide-up | `showModalBottomSheet` / route | `@gorhom/bottom-sheet` | `.sheet` + detents |
| Bottom sheet drag+detents | `anchoredDraggable` + `ModalBottomSheet` | `DraggableScrollableSheet(snap:true)` | `@gorhom/bottom-sheet` snap points | `.presentationDetents` |
| Button press (0.96 scale) | `graphicsLayer` + `animateFloatAsState(spring)` | `AnimatedScale` | `withSpring` on `useAnimatedStyle` | `.scaleEffect` + `.snappy` |
| Card list first-paint stagger | `AnimatedVisibility` + `LazyColumn` delay | `flutter_staggered_animations` | `FadeInDown.delay(i*30)` | `.transition` + `.animation(_:value:)` |
| List item insert/remove | `animateItemPlacement()` | `SliverAnimatedList` | Reanimated `LinearTransition` | `withAnimation` on the array |
| Hero (list → detail) | `SharedTransitionLayout` | `Hero` | shared-element | `.matchedGeometryEffect` |
| Skeleton shimmer | `Brush` gradient + `rememberInfiniteTransition` | `shimmer` pkg / `flutter_animate` | Reanimated repeat | `LinearGradient` + `TimelineView` |
| Interactive back | Predictive back → `translationX` | `CupertinoPage` (auto) | native-stack (auto) | `NavigationStack` (auto) |
| Count-up (KPI, first load) | `animateIntAsState` | `TweenAnimationBuilder<int>` | `withTiming` + `runOnJS` text | `.contentTransition(.numericText())` |
| Success checkmark draw | `Canvas` path + `animateFloatAsState` | `CustomPaint` + controller | `react-native-svg` + Reanimated `strokeDashoffset` | `Shape` + `.trim(from:to:)` |

## 6. Anti-patterns (these cause the jank you're trying to avoid)

- Animating `Padding`, `SizedBox` height, `elevation`, `Container` color-per-frame, or list-item heights.
- Starting a network call / JSON decode / image decode in the same frame as the transition.
- `FlatList` for long or complex lists (use FlashList); `ListView` without keys; `setState` inside a scroll or gesture handler (RN).
- Recomposition storms (Compose) — unstable lambdas/params passed to animated composables.
- Rebuilding the whole subtree in `AnimatedBuilder` instead of passing `child:` (Flutter).
- 600 ms hero animations, parallax on every screen, confetti — "modern" is *restraint* + smoothness, not more motion.
- Ignoring the OS reduce-motion flag.
- Capping the frame rate or leaving ProMotion/high-refresh disabled.

## 7. How to verify (do this every release)

| Platform | Tool | What to watch |
|---|---|---|
| Compose | Android Studio Profiler + `JankStats` + Macrobenchmark (`FrameTimingMetric`) | frame durations during scroll + each transition; 0 janky frames on min-spec |
| Flutter | `flutter run --profile` + DevTools Performance + `flutter test --profile` timeline | UI + raster thread ≤ frame budget; shader jank on first run |
| React Native | Reanimated FPS overlay + `react-native-performance` + Flipper | JS + UI thread FPS; frame drops during gestures |
| SwiftUI | Instruments → "Animation Hitches" + "SwiftUI" | hitch time per transition; long view `body` evaluations |
| All | Record slow-motion video (240 fps) of the transition on the **lowest-tier supported device** | visually confirm no stutter, no pop-in, no layout shift |

Put a `FrameTimingMetric` / timeline check in CI on the 3 core e2e flows ([testing.md](testing.md)) — a regression that adds jank should fail the build.

## 8. "Modern & premium" checklist (visual, not just fast)

- [ ] One focal point per transition; the tapped element leads the move (origin-anchored or shared-element)
- [ ] Enter uses `decelerate`, exit uses `accelerate` and is faster than the enter
- [ ] Everything grabbable uses a spring and carries fling velocity on release
- [ ] Interactive back on both platforms (iOS edge-swipe, Android predictive back)
- [ ] Skeletons match the final layout exactly — content swaps with a 150 ms crossfade, **zero layout shift**
- [ ] No transition exceeds 400 ms (except ambient loaders)
- [ ] Reduced-motion path verified (crossfades ≤150 ms, no parallax, no stagger)
- [ ] Haptics are additive confirmation only (light tick on toggle/commit, success/error notification), respect the system setting
- [ ] 120 Hz / high-refresh enabled and verified on capable hardware
- [ ] Dark-mode transitions crossfade the root in 200 ms (instant under reduce-motion)

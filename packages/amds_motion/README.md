# amds_motion

The AMDS motion system — one shared, modern animation toolkit for every AMDS
app and refactor. Depends only on `amds_tokens` (durations + curves).

**Principles**

- **Reduced-motion aware.** Every widget checks the OS "reduce motion" setting
  *and* an app-level override, and always renders a correct final frame.
- **Transform / opacity only.** No animated layout → no jank at 60 / 120 fps.
- **Token-tuned.** Durations (`AmdsMotion.fast … slower`) and curves
  (`standard`, `decelerate`, `accelerate`, `spring`) come from the design tokens.

## Setup

Wrap the app once so motion can be scaled or disabled globally:

```dart
AmdsMotionScope(
  settings: const AmdsMotionSettings(speed: 1.0), // 0.5 = 2× faster
  child: MyApp(),
)
```

Then anywhere: `context.reduceMotion`, `context.motion.speed`,
`amdsDuration(context, AmdsMotion.base)`.

## What's in the box

| Group | API | Use for |
| --- | --- | --- |
| **Route transitions** | `AmdsPageRoute`, `AmdsPageTransitions.{fadeThrough,sharedAxisX,sharedAxisY,sharedAxisZ,fade}`, `AmdsPageTransitionsBuilder` | Navigator pushes, `go_router` `CustomTransitionPage`, `ThemeData.pageTransitionsTheme` |
| **Entrances** | `AmdsFadeSlideIn`, `AmdsScaleIn`, `AmdsStagger` | First paint of a screen or list; cascade a column of cards |
| **Micro-interactions** | `AmdsPressable`, `AmdsAnimatedCount`, `AmdsShake`, `AmdsPulse` | Tap feedback on cards/rows, KPI count-ups, invalid-field shake, "live" dots |
| **Content swaps** | `AmdsSwitcher`, `AmdsCrossFade` | loading → data, value → new value, expand / collapse |
| **Config** | `AmdsMotionScope`, `AmdsMotionSettings`, `context.motion`, `context.reduceMotion` | Global speed / disable, accessibility, demos, golden tests |

## Examples

```dart
// go_router
GoRoute(
  path: '/items/:id',
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: ItemDetailScreen(id: state.pathParameters['id']!),
    transitionsBuilder: AmdsPageTransitions.sharedAxisX,
  ),
);

// every platform route, no call-site changes
ThemeData(
  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    TargetPlatform.android: AmdsPageTransitionsBuilder(),
    TargetPlatform.iOS: AmdsPageTransitionsBuilder(),
  }),
);

// staggered list
AmdsStagger(spacing: 12, children: [for (final t in tiles) TileCard(t)]);

// KPI
AmdsAnimatedCount(openItems, style: context.text.displaySmall);

// tappable card with spring-back + tint
AmdsPressable(onTap: open, borderRadius: AmdsRadius.brLg, child: card);
```

See `docs/design-system/motion.md` for the spec and
`docs/starter-template/motion-implementation.md` for platform notes.

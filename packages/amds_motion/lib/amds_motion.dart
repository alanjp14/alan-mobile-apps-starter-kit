/// AMDS v1.0 motion system.
///
/// A small, modern toolkit that every AMDS app (and refactor) can share:
///
/// * **Route transitions** — [AmdsPageRoute], [AmdsPageTransitions],
///   [AmdsPageTransitionsBuilder] (Material 3 shared-axis / fade-through).
/// * **Entrances** — [AmdsFadeSlideIn], [AmdsScaleIn], [AmdsStagger].
/// * **Micro-interactions** — [AmdsPressable], [AmdsAnimatedCount],
///   [AmdsShake], [AmdsPulse].
/// * **Content swaps** — [AmdsSwitcher], [AmdsCrossFade].
/// * **Config** — [AmdsMotionScope] / [AmdsMotionSettings], `context.motion`,
///   `context.reduceMotion`.
///
/// Everything honors the OS "reduce motion" setting and an app-level override,
/// and animates transform/opacity only (never layout) for 60/120 fps.
///
/// See `docs/design-system/motion.md` and
/// `docs/starter-template/motion-implementation.md`.
library;

export 'src/entrances.dart';
export 'src/micro_interactions.dart';
export 'src/motion_config.dart';
export 'src/route_transitions.dart';
export 'src/switchers.dart';

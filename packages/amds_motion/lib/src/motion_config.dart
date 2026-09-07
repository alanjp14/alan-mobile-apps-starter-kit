// AMDS motion configuration. One place to (a) read the OS "reduce motion"
// setting and (b) globally scale or disable animation for demos, tests, and
// low-power modes. Everything in amds_motion routes through here.

import 'package:flutter/widgets.dart';

/// App-wide motion settings. Wrap the app once:
///
/// ```dart
/// AmdsMotionScope(
///   settings: const AmdsMotionSettings(speed: 1.0),
///   child: MyApp(),
/// )
/// ```
@immutable
class AmdsMotionSettings {
  const AmdsMotionSettings({
    this.speed = 1.0,
    this.forceReduceMotion = false,
    this.respectSystemReduceMotion = true,
  }) : assert(speed > 0, 'speed must be > 0');

  /// Multiplies every duration. `0.5` = twice as fast, `2.0` = half speed.
  final double speed;

  /// Force the reduced-motion code path regardless of the OS setting — handy
  /// for golden tests and "disable animations" preferences.
  final bool forceReduceMotion;

  /// When false, ignore the OS reduce-motion setting (rarely what you want).
  final bool respectSystemReduceMotion;

  AmdsMotionSettings copyWith({
    double? speed,
    bool? forceReduceMotion,
    bool? respectSystemReduceMotion,
  }) =>
      AmdsMotionSettings(
        speed: speed ?? this.speed,
        forceReduceMotion: forceReduceMotion ?? this.forceReduceMotion,
        respectSystemReduceMotion:
            respectSystemReduceMotion ?? this.respectSystemReduceMotion,
      );
}

class AmdsMotionScope extends InheritedWidget {
  const AmdsMotionScope({
    required this.settings,
    required super.child,
    super.key,
  });

  final AmdsMotionSettings settings;

  static AmdsMotionSettings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AmdsMotionScope>();
    return scope?.settings ?? const AmdsMotionSettings();
  }

  @override
  bool updateShouldNotify(AmdsMotionScope oldWidget) =>
      settings.speed != oldWidget.settings.speed ||
      settings.forceReduceMotion != oldWidget.settings.forceReduceMotion ||
      settings.respectSystemReduceMotion !=
          oldWidget.settings.respectSystemReduceMotion;
}

/// True when animation should be suppressed (OS setting or app override).
/// Widgets that read this must still render a correct final frame.
bool amdsReduceMotion(BuildContext context) {
  final s = AmdsMotionScope.of(context);
  if (s.forceReduceMotion) return true;
  if (!s.respectSystemReduceMotion) return false;
  return MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}

/// Scales [d] by the app-wide speed multiplier. Returns [Duration.zero] under
/// reduced motion so callers can pass it straight to an [AnimationController].
Duration amdsDuration(BuildContext context, Duration d) {
  if (amdsReduceMotion(context)) return Duration.zero;
  final speed = AmdsMotionScope.of(context).speed;
  if (speed == 1.0) return d;
  return Duration(microseconds: (d.inMicroseconds * speed).round());
}

extension AmdsMotionX on BuildContext {
  /// `context.motion.speed`, `context.motion.forceReduceMotion`.
  AmdsMotionSettings get motion => AmdsMotionScope.of(this);

  /// `context.reduceMotion` — OS setting or app override.
  bool get reduceMotion => amdsReduceMotion(this);
}

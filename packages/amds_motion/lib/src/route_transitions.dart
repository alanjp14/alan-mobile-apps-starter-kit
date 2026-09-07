// AMDS route transitions — Material 3 "shared axis" / "fade through" family,
// tuned to AMDS motion tokens. Works with Navigator (via [AmdsPageRoute]),
// go_router (pass a builder to `CustomTransitionPage`), and ThemeData (via
// [AmdsPageTransitionsBuilder]).

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

import 'motion_config.dart';

/// Which motion pattern a route uses.
enum AmdsTransition {
  /// Cross-fade with a subtle scale — for switching between peers (tabs).
  fadeThrough,

  /// Horizontal slide + fade — forward/back navigation (default).
  sharedAxisX,

  /// Vertical slide + fade — for routes that "come up" (pickers, details).
  sharedAxisY,

  /// Z-axis scale + fade — drilling into a hierarchy.
  sharedAxisZ,

  /// Plain cross-fade — the reduced-motion fallback, usable on its own.
  fade,
}

/// Static [RouteTransitionsBuilder]s. Each honors reduced motion (→ a quick
/// fade) and animates transform/opacity only.
abstract final class AmdsPageTransitions {
  static const _distance = 28.0;

  static Widget fade(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: AmdsMotion.standard),
        child: child,
      );

  static Widget fadeThrough(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (amdsReduceMotion(context)) {
      return fade(context, animation, secondaryAnimation, child);
    }
    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.35, 1, curve: AmdsMotion.decelerate),
    );
    final scaleIn = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: animation, curve: AmdsMotion.standard),
    );
    final fadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: secondaryAnimation,
        curve: const Interval(0, 0.35, curve: AmdsMotion.accelerate),
      ),
    );
    return FadeTransition(
      opacity: fadeOut,
      child: FadeTransition(
        opacity: fadeIn,
        child: ScaleTransition(scale: scaleIn, child: child),
      ),
    );
  }

  static Widget sharedAxisX(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      _slide(context, animation, secondaryAnimation, child, Axis.horizontal);

  static Widget sharedAxisY(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      _slide(context, animation, secondaryAnimation, child, Axis.vertical);

  static Widget sharedAxisZ(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (amdsReduceMotion(context)) {
      return fade(context, animation, secondaryAnimation, child);
    }
    final enterScale = Tween<double>(begin: 0.80, end: 1).animate(
      CurvedAnimation(parent: animation, curve: AmdsMotion.standard),
    );
    final exitScale = Tween<double>(begin: 1, end: 1.10).animate(
      CurvedAnimation(parent: secondaryAnimation, curve: AmdsMotion.standard),
    );
    return ScaleTransition(
      scale: exitScale,
      child: ScaleTransition(
        scale: enterScale,
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: const Interval(0.3, 1),
          ),
          child: child,
        ),
      ),
    );
  }

  static Widget _slide(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    Axis axis,
  ) {
    if (amdsReduceMotion(context)) {
      return fade(context, animation, secondaryAnimation, child);
    }
    Offset off(double d) =>
        axis == Axis.horizontal ? Offset(d, 0) : Offset(0, d);

    final enter = Tween<Offset>(begin: off(_distance), end: Offset.zero)
        .chain(CurveTween(curve: AmdsMotion.decelerate))
        .animate(animation);
    final exit = Tween<Offset>(begin: Offset.zero, end: off(-_distance * 0.6))
        .chain(CurveTween(curve: AmdsMotion.accelerate))
        .animate(secondaryAnimation);

    return _PxSlide(
      offset: exit,
      child: _PxSlide(
        offset: enter,
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: const Interval(0.2, 1, curve: AmdsMotion.standard),
          ),
          child: child,
        ),
      ),
    );
  }

  /// Resolve a [RouteTransitionsBuilder] for an [AmdsTransition] value.
  static RouteTransitionsBuilder resolve(AmdsTransition t) => switch (t) {
        AmdsTransition.fadeThrough => fadeThrough,
        AmdsTransition.sharedAxisX => sharedAxisX,
        AmdsTransition.sharedAxisY => sharedAxisY,
        AmdsTransition.sharedAxisZ => sharedAxisZ,
        AmdsTransition.fade => fade,
      };
}

/// Slides by a pixel [offset] (Animation in logical px), unlike [SlideTransition]
/// which is fractional. Keeps the shift constant across screen sizes.
class _PxSlide extends AnimatedWidget {
  const _PxSlide({required Animation<Offset> offset, required this.child})
      : super(listenable: offset);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final offset = (listenable as Animation<Offset>).value;
    return Transform.translate(offset: offset, child: child);
  }
}

/// A [PageRoute] that applies an [AmdsTransition]. Drop-in for `Navigator.push`.
///
/// ```dart
/// Navigator.of(context).push(
///   AmdsPageRoute(builder: (_) => const DetailScreen()),
/// );
/// ```
class AmdsPageRoute<T> extends PageRoute<T> {
  AmdsPageRoute({
    required this.builder,
    this.transition = AmdsTransition.sharedAxisX,
    Duration? duration,
    Duration? reverseDuration,
    this.maintainState = true,
    super.fullscreenDialog,
    super.settings,
  })  : _duration = duration ?? AmdsMotion.moderate,
        _reverseDuration = reverseDuration ?? AmdsMotion.base;

  final WidgetBuilder builder;
  final AmdsTransition transition;
  final Duration _duration;
  final Duration _reverseDuration;

  @override
  final bool maintainState;

  @override
  Duration get transitionDuration => _duration;

  @override
  Duration get reverseTransitionDuration => _reverseDuration;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get opaque => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: builder(context),
      );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      AmdsPageTransitions.resolve(transition)(
        context,
        animation,
        secondaryAnimation,
        child,
      );
}

/// Plug into `ThemeData(pageTransitionsTheme:)` so every platform route uses
/// the AMDS motion without touching call sites.
///
/// ```dart
/// pageTransitionsTheme: const PageTransitionsTheme(builders: {
///   TargetPlatform.android: AmdsPageTransitionsBuilder(),
///   TargetPlatform.iOS: AmdsPageTransitionsBuilder(),
/// }),
/// ```
class AmdsPageTransitionsBuilder extends PageTransitionsBuilder {
  const AmdsPageTransitionsBuilder(
      {this.transition = AmdsTransition.sharedAxisX});

  final AmdsTransition transition;

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      AmdsPageTransitions.resolve(transition)(
        context,
        animation,
        secondaryAnimation,
        child,
      );
}

/// Back-compat shim for the Phase 1 helper. Prefer [AmdsPageTransitions.sharedAxisX].
Widget amdsSharedAxisTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) =>
    AmdsPageTransitions.sharedAxisX(
        context, animation, secondaryAnimation, child);

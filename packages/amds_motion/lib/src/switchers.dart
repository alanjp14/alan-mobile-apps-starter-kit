// Content-swap animations — when a widget is replaced by another in place
// (loading → data, value → new value, icon state changes).

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/widgets.dart';

import 'motion_config.dart';

/// [AnimatedSwitcher] with the AMDS fade-through (fade + slight scale). Give
/// each child a `key` so the switcher knows when to animate.
class AmdsSwitcher extends StatelessWidget {
  const AmdsSwitcher({
    required this.child,
    this.duration = AmdsMotion.base,
    this.alignment = Alignment.center,
    super.key,
  });

  final Widget child;
  final Duration duration;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final reduce = amdsReduceMotion(context);
    return AnimatedSwitcher(
      duration: reduce ? Duration.zero : duration,
      switchInCurve: AmdsMotion.standard,
      switchOutCurve: AmdsMotion.accelerate,
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: alignment,
        children: [
          ...previousChildren,
          if (currentChild != null) currentChild,
        ],
      ),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: reduce
            ? child
            : ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
                child: child,
              ),
      ),
      child: child,
    );
  }
}

/// Cross-fades between two children by a boolean, keeping both mounted so state
/// is preserved (unlike [AmdsSwitcher]). Use for expand/collapse, reveal.
class AmdsCrossFade extends StatelessWidget {
  const AmdsCrossFade({
    required this.showFirst,
    required this.first,
    required this.second,
    this.duration = AmdsMotion.base,
    this.alignment = Alignment.topCenter,
    super.key,
  });

  final bool showFirst;
  final Widget first;
  final Widget second;
  final Duration duration;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) => AnimatedCrossFade(
        firstChild: first,
        secondChild: second,
        crossFadeState:
            showFirst ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        duration: amdsReduceMotion(context) ? Duration.zero : duration,
        sizeCurve: AmdsMotion.standard,
        firstCurve: AmdsMotion.accelerate,
        secondCurve: AmdsMotion.decelerate,
        alignment: alignment,
      );
}

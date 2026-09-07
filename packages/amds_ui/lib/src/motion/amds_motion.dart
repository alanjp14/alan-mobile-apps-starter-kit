// AMDS v1.0 · motion primitives. Everything here honors the OS "reduce motion"
// setting (MediaQuery.disableAnimations) and animates transform/opacity only.
// See docs/design-system/motion.md + docs/starter-template/motion-implementation.md.

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

bool _reduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Wraps a tappable child with a 0.96 press-scale + subtle overlay, spring-back
/// on release. Use for cards, tiles, list rows, quick actions.
class AmdsPressable extends StatefulWidget {
  const AmdsPressable({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.97,
    this.enableOverlay = true,
    this.borderRadius,
    this.semanticButton = true,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final bool enableOverlay;
  final BorderRadius? borderRadius;
  final bool semanticButton;

  @override
  State<AmdsPressable> createState() => _AmdsPressableState();
}

class _AmdsPressableState extends State<AmdsPressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPress != null;
    final reduce = _reduceMotion(context);
    final scale = (_down && enabled && !reduce) ? widget.pressedScale : 1.0;

    Widget child = widget.child;
    if (widget.enableOverlay && _down && enabled) {
      child = Stack(
        children: [
          child,
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.amds.colors.onSurface
                    .withValues(alpha: AmdsOpacity.pressed),
                borderRadius: widget.borderRadius,
              ),
            ),
          ),
        ],
      );
    }

    return Semantics(
      button: widget.semanticButton && enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedScale(
          scale: scale,
          duration: _down ? AmdsMotion.instant : AmdsMotion.fast,
          curve: _down ? AmdsMotion.standard : AmdsMotion.spring,
          child: child,
        ),
      ),
    );
  }
}

/// Fade + slide-up entrance. Give list items an increasing [index] for a
/// staggered first paint (the stagger is capped at 8 × 30 ms). Dependency-free.
class AmdsFadeSlideIn extends StatefulWidget {
  const AmdsFadeSlideIn({
    required this.child,
    this.index = 0,
    this.offsetY = 8,
    this.duration = AmdsMotion.base,
    super.key,
  });

  final Widget child;
  final int index;
  final double offsetY;
  final Duration duration;

  @override
  State<AmdsFadeSlideIn> createState() => _AmdsFadeSlideInState();
}

class _AmdsFadeSlideInState extends State<AmdsFadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _t =
      CurvedAnimation(parent: _c, curve: AmdsMotion.decelerate);

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: widget.index.clamp(0, 8) * 30);
    Future<void>.delayed(delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_reduceMotion(context)) return widget.child;
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _t.value,
        child: Transform.translate(
            offset: Offset(0, widget.offsetY * (1 - _t.value)), child: child),
      ),
    );
  }
}

/// Counts from a previous value up to [value] on first build. Snaps under
/// reduce-motion. Use for KPI values on first load only.
class AmdsAnimatedCount extends StatelessWidget {
  const AmdsAnimatedCount(this.value, {this.style, this.formatter, super.key});

  final num value;
  final TextStyle? style;
  final String Function(num)? formatter;

  @override
  Widget build(BuildContext context) {
    final fmt = formatter ?? (n) => n.round().toString();
    if (_reduceMotion(context)) return Text(fmt(value), style: style);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: AmdsMotion.slow,
      curve: AmdsMotion.standard,
      builder: (context, v, _) => Text(fmt(v), style: style),
    );
  }
}

/// Shared-axis-X page transition, reduced-motion → fade. Use in a router.
Widget amdsSharedAxisTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  if (_reduceMotion(context)) {
    return FadeTransition(opacity: animation, child: child);
  }
  const enter = Offset(0.06, 0);
  const exit = Offset(-0.04, 0);
  final inPos = Tween(begin: enter, end: Offset.zero)
      .chain(CurveTween(curve: AmdsMotion.decelerate))
      .animate(animation);
  final outPos = Tween(begin: Offset.zero, end: exit)
      .chain(CurveTween(curve: AmdsMotion.accelerate))
      .animate(secondaryAnimation);
  return SlideTransition(
    position: outPos,
    child: SlideTransition(
      position: inPos,
      child: FadeTransition(opacity: animation, child: child),
    ),
  );
}

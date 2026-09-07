// Micro-interactions — the small, tactile responses to touch and state change.
// Reduced-motion aware; transform/opacity only.

import 'dart:math' as math;

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/widgets.dart';

import 'motion_config.dart';

/// Press-scale + optional tint overlay, spring-back on release. Use on cards,
/// list rows, tiles, and quick actions — anything tappable that isn't a
/// first-class button.
class AmdsPressable extends StatefulWidget {
  const AmdsPressable({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.97,
    this.overlayColor,
    this.borderRadius,
    this.semanticButton = true,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;

  /// Tint painted while pressed. Null → no overlay (scale only).
  final Color? overlayColor;
  final BorderRadius? borderRadius;
  final bool semanticButton;

  @override
  State<AmdsPressable> createState() => _AmdsPressableState();
}

class _AmdsPressableState extends State<AmdsPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AmdsMotion.fast,
    reverseDuration: AmdsMotion.base,
    value: 0,
  );

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  void _setPressed(bool pressed) {
    if (amdsReduceMotion(context)) return;
    if (pressed) {
      _c.animateTo(1, curve: AmdsMotion.standard);
    } else {
      _c.animateBack(0, curve: AmdsMotion.spring);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.semanticButton && _enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _enabled ? (_) => _setPressed(true) : null,
        onTapUp: _enabled ? (_) => _setPressed(false) : null,
        onTapCancel: _enabled ? () => _setPressed(false) : null,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedBuilder(
          animation: _c,
          child: widget.child,
          builder: (context, child) {
            final t = _c.value;
            Widget result = Transform.scale(
              scale: 1 - (1 - widget.pressedScale) * t,
              child: child,
            );
            if (widget.overlayColor != null && t > 0) {
              result = Stack(
                children: [
                  result,
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.overlayColor!
                              .withValues(alpha: widget.overlayColor!.a * t),
                          borderRadius: widget.borderRadius,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return result;
          },
        ),
      ),
    );
  }
}

/// Tweens from the previous value to [value] whenever it changes. Snaps under
/// reduced motion. Use for KPI figures, counters, running totals.
class AmdsAnimatedCount extends StatelessWidget {
  const AmdsAnimatedCount(
    this.value, {
    this.style,
    this.formatter,
    this.duration = AmdsMotion.slow,
    this.curve = AmdsMotion.standard,
    this.textAlign,
    super.key,
  });

  final num value;
  final TextStyle? style;
  final String Function(num)? formatter;
  final Duration duration;
  final Curve curve;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final fmt = formatter ?? (n) => n.round().toString();
    if (amdsReduceMotion(context)) {
      return Text(fmt(value), style: style, textAlign: textAlign);
    }
    return TweenAnimationBuilder<double>(
      // begin at 0 on first mount; on later value changes TweenAnimationBuilder
      // animates from the previous value automatically.
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, v, _) =>
          Text(fmt(v), style: style, textAlign: textAlign),
    );
  }
}

/// Horizontal shake — call `AmdsShake.of(context)` isn't a thing; instead
/// bump [trigger] (e.g. an error counter) to replay. For invalid form fields,
/// failed auth, rejected actions.
class AmdsShake extends StatefulWidget {
  const AmdsShake({
    required this.child,
    required this.trigger,
    this.amplitude = 8,
    this.duration = AmdsMotion.slow,
    super.key,
  });

  final Widget child;

  /// Any value; when it changes, the shake plays once.
  final Object? trigger;
  final double amplitude;
  final Duration duration;

  @override
  State<AmdsShake> createState() => _AmdsShakeState();
}

class _AmdsShakeState extends State<AmdsShake>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);

  @override
  void didUpdateWidget(AmdsShake old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger && !amdsReduceMotion(context)) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        // three oscillations, amplitude decaying to zero
        final dx = widget.amplitude *
            (1 - _c.value) *
            math.sin(_c.value * 3 * math.pi * 2);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
    );
  }
}

/// Gentle breathing scale/opacity — for "live"/recording dots, sync badges,
/// anything that should read as active. Stops under reduced motion.
class AmdsPulse extends StatefulWidget {
  const AmdsPulse({
    required this.child,
    this.minScale = 0.92,
    this.period = const Duration(milliseconds: 1400),
    this.pulseOpacity = true,
    super.key,
  });

  final Widget child;
  final double minScale;
  final Duration period;
  final bool pulseOpacity;

  @override
  State<AmdsPulse> createState() => _AmdsPulseState();
}

class _AmdsPulseState extends State<AmdsPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.period);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (amdsReduceMotion(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (amdsReduceMotion(context)) return widget.child;
    final curved = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
    return AnimatedBuilder(
      animation: curved,
      child: widget.child,
      builder: (context, child) {
        final scale = widget.minScale + (1 - widget.minScale) * curved.value;
        final opacity = widget.pulseOpacity ? 0.55 + 0.45 * curved.value : 1.0;
        return Opacity(
          opacity: opacity,
          child: Transform.scale(scale: scale, child: child),
        );
      },
    );
  }
}

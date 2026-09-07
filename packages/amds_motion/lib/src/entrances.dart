// Entrance animations — the first paint of a screen or a list. All are
// dependency-free, reduced-motion aware (→ render final frame immediately),
// and animate transform/opacity only.

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/widgets.dart';

import 'motion_config.dart';

/// Fade + slide-up on mount. In a list, pass an increasing [index] for a
/// staggered cascade (capped so long lists don't feel slow).
class AmdsFadeSlideIn extends StatefulWidget {
  const AmdsFadeSlideIn({
    required this.child,
    this.index = 0,
    this.offset = const Offset(0, 8),
    this.duration = AmdsMotion.base,
    this.stagger = const Duration(milliseconds: 30),
    this.maxStagger = 8,
    this.curve = AmdsMotion.decelerate,
    super.key,
  });

  final Widget child;
  final int index;
  final Offset offset;
  final Duration duration;
  final Duration stagger;
  final int maxStagger;
  final Curve curve;

  @override
  State<AmdsFadeSlideIn> createState() => _AmdsFadeSlideInState();
}

class _AmdsFadeSlideInState extends State<AmdsFadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _t =
      CurvedAnimation(parent: _c, curve: widget.curve);
  bool _started = false;

  void _start() {
    if (_started || !mounted) return;
    _started = true;
    if (amdsReduceMotion(context)) {
      _c.value = 1;
      return;
    }
    final steps = widget.index.clamp(0, widget.maxStagger);
    final delay = widget.stagger * steps;
    if (delay == Duration.zero) {
      _c.forward();
    } else {
      Future<void>.delayed(delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _start();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _t.value.clamp(0, 1),
        child: Transform.translate(
          offset: widget.offset * (1 - _t.value),
          child: child,
        ),
      ),
    );
  }
}

/// Scale + fade in from [from] (0.0–1.0). Good for dialogs, FABs, badges,
/// anything that should "pop" into place.
class AmdsScaleIn extends StatefulWidget {
  const AmdsScaleIn({
    required this.child,
    this.from = 0.85,
    this.duration = AmdsMotion.base,
    this.curve = AmdsMotion.spring,
    this.alignment = Alignment.center,
    super.key,
  });

  final Widget child;
  final double from;
  final Duration duration;
  final Curve curve;
  final Alignment alignment;

  @override
  State<AmdsScaleIn> createState() => _AmdsScaleInState();
}

class _AmdsScaleInState extends State<AmdsScaleIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (amdsReduceMotion(context)) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _c, curve: widget.curve);
    return AnimatedBuilder(
      animation: curved,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _c.value.clamp(0, 1),
        child: Transform.scale(
          scale: widget.from + (1 - widget.from) * curved.value,
          alignment: widget.alignment,
          child: child,
        ),
      ),
    );
  }
}

/// Wraps a set of children and auto-assigns each an increasing stagger index,
/// so you don't thread `index:` by hand.
///
/// ```dart
/// AmdsStagger(children: [for (final t in tiles) TileCard(t)])
/// ```
class AmdsStagger extends StatelessWidget {
  const AmdsStagger({
    required this.children,
    this.direction = Axis.vertical,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.spacing = 0,
    this.offset = const Offset(0, 10),
    this.stagger = const Duration(milliseconds: 40),
    super.key,
  });

  final List<Widget> children;
  final Axis direction;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final Offset offset;
  final Duration stagger;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0 && spacing > 0)
          SizedBox(
            width: direction == Axis.horizontal ? spacing : null,
            height: direction == Axis.vertical ? spacing : null,
          ),
        AmdsFadeSlideIn(
          index: i,
          offset: offset,
          stagger: stagger,
          child: children[i],
        ),
      ],
    ];
    return direction == Axis.vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: crossAxisAlignment,
            children: items,
          )
        : Row(mainAxisSize: MainAxisSize.min, children: items);
  }
}

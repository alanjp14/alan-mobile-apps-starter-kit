// AMDS v1.0 · skeleton loader with a shimmer sweep. Reduced-motion → static.
// See docs/component-library/design-specs.md E2.

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

/// A single shimmering block. Compose these into list/card skeletons that match
/// the real layout exactly (zero layout shift on swap).
class AmdsSkeleton extends StatefulWidget {
  const AmdsSkeleton({this.width, this.height = 16, this.borderRadius = AmdsRadius.brXs, super.key});

  const AmdsSkeleton.circle(double size, {super.key})
      : width = size,
        height = size,
        borderRadius = AmdsRadius.brFull;

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<AmdsSkeleton> createState() => _AmdsSkeletonState();
}

class _AmdsSkeletonState extends State<AmdsSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.amds.colors;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final base = DecoratedBox(
      decoration: BoxDecoration(color: colors.skeletonBase, borderRadius: widget.borderRadius),
      child: SizedBox(width: widget.width, height: widget.height),
    );
    if (reduce) return base;

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final dx = (_c.value * 2) - 1; // -1 → 1
        return ClipRRect(
          borderRadius: widget.borderRadius,
          child: ShaderMask(
            shaderCallback: (rect) => LinearGradient(
              begin: Alignment(dx - 0.3, 0),
              end: Alignment(dx + 0.3, 0),
              colors: [colors.skeletonBase, colors.skeletonSheen, colors.skeletonBase],
            ).createShader(rect),
            blendMode: BlendMode.srcATop,
            child: base,
          ),
        );
      },
    );
  }
}

/// A vertical list of shimmer rows for list-screen loading.
class AmdsSkeletonList extends StatelessWidget {
  const AmdsSkeletonList({this.rows = 6, this.rowHeight = 72, super.key});

  final int rows;
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        rows,
        (_) => Padding(
          padding: const EdgeInsets.symmetric(vertical: AmdsSpacing.xs),
          child: SizedBox(
            height: rowHeight,
            child: Row(
              children: [
                const AmdsSkeleton.circle(40),
                const SizedBox(width: AmdsSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      AmdsSkeleton(width: 180, height: 14),
                      SizedBox(height: 8),
                      AmdsSkeleton(width: 120, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

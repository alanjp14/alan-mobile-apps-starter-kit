// AMDS v1.0 · Progressive Image — skeleton while loading, graceful error, and
// a fade-in on first paint (no pop). See docs/component-library/design-specs.md.

import 'package:amds_motion/amds_motion.dart';
import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

class AmdsImage extends StatelessWidget {
  const AmdsImage({
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = AmdsRadius.brMd,
    this.semanticLabel,
    super.key,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: semanticLabel,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, wasSyncLoaded) {
          if (wasSyncLoaded || context.reduceMotion) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: AmdsMotion.moderate,
            curve: AmdsMotion.decelerate,
            child: child,
          );
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: c.skeletonBase,
          );
        },
        errorBuilder: (context, error, stack) => Container(
          width: width,
          height: height,
          color: c.surfaceVariant,
          alignment: Alignment.center,
          child: Icon(Icons.broken_image_outlined, color: c.textTertiary),
        ),
      ),
    );
  }
}

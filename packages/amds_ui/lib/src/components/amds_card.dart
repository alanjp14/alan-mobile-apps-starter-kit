// AMDS v1.0 · Card. See docs/component-library/design-specs.md C1.

import 'package:amds_motion/amds_motion.dart';
import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

enum AmdsCardVariant { outlined, elevated, filled }

class AmdsCard extends StatelessWidget {
  const AmdsCard({
    required this.child,
    this.variant = AmdsCardVariant.outlined,
    this.padding = const EdgeInsets.all(AmdsSpacing.md),
    this.onTap,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final AmdsCardVariant variant;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Required when [onTap] is set — one sentence summarizing the card's content.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color: variant == AmdsCardVariant.filled ? c.surfaceVariant : c.surface,
        borderRadius: AmdsRadius.brLg,
        border: variant == AmdsCardVariant.outlined
            ? Border.all(color: c.border)
            : null,
        boxShadow: variant == AmdsCardVariant.elevated
            ? context.amds.elevation(1)
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return surface;

    assert(semanticLabel != null, 'AmdsCard with onTap needs a semanticLabel');
    return AmdsPressable(
      onTap: onTap,
      borderRadius: AmdsRadius.brLg,
      pressedScale: 0.985,
      overlayColor: c.onSurface.withValues(alpha: AmdsOpacity.pressed),
      child: Semantics(button: true, label: semanticLabel, child: surface),
    );
  }
}

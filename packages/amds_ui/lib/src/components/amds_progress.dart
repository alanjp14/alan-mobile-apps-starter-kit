// AMDS v1.0 · Progress — linear / circular indicators + a blocking overlay.
// See docs/component-library/design-specs.md (Loading).

import 'package:amds_motion/amds_motion.dart';
import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

/// Linear progress. [value] null → indeterminate. Announces as a busy/progress
/// region to assistive tech.
class AmdsProgressBar extends StatelessWidget {
  const AmdsProgressBar({this.value, this.label, super.key});

  final double? value;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    return Semantics(
      label: label,
      value: value == null ? null : '${(value! * 100).round()}%',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(label!,
                style:
                    AmdsTextStyles.labelSmall.copyWith(color: c.textSecondary)),
            const SizedBox(height: AmdsSpacing.xs),
          ],
          ClipRRect(
            borderRadius: AmdsRadius.brFull,
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: c.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(c.primary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular progress at an AMDS size. [value] null → indeterminate.
class AmdsCircularProgress extends StatelessWidget {
  const AmdsCircularProgress(
      {this.value, this.size = AmdsSize.iconLg, super.key});

  final double? value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: size < AmdsSize.iconLg ? 2.5 : 3.5,
        backgroundColor: c.surfaceVariant,
        valueColor: AlwaysStoppedAnimation<Color>(c.primary),
      ),
    );
  }
}

/// Dims the screen and blocks input while [busy]. Wrap a screen body.
class AmdsLoadingOverlay extends StatelessWidget {
  const AmdsLoadingOverlay({
    required this.busy,
    required this.child,
    this.message,
    super.key,
  });

  final bool busy;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    final reduce = context.reduceMotion;
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !busy,
            child: AnimatedOpacity(
              opacity: busy ? 1 : 0,
              duration: reduce ? Duration.zero : AmdsMotion.base,
              curve: AmdsMotion.standard,
              child: ColoredBox(
                color: c.overlayScrim,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AmdsCircularProgress(),
                      if (message != null) ...[
                        const SizedBox(height: AmdsSpacing.md),
                        Text(message!,
                            style: context.text.bodyMedium
                                ?.copyWith(color: c.textOnColor)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

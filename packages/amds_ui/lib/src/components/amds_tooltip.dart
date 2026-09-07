// AMDS v1.0 · Tooltip — a rich (title + body) hint, and an info dot that
// carries one. On touch devices it opens on tap/long-press, not hover.
// See docs/component-library/design-specs.md (Feedback › Tooltip).

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

/// Wraps [child] with a themed tooltip. [richMessage] takes precedence over
/// [message] when you need a title + body.
class AmdsTooltip extends StatelessWidget {
  const AmdsTooltip({
    required this.child,
    this.message,
    this.title,
    this.body,
    super.key,
  }) : assert(
            message != null || body != null, 'Provide either message or body');

  final Widget child;
  final String? message;
  final String? title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    final onDark = c.textOnColor;

    return Tooltip(
      message: body == null ? message : null,
      richMessage: body == null
          ? null
          : TextSpan(
              children: [
                if (title != null)
                  TextSpan(
                    text: '$title\n',
                    style: AmdsTextStyles.labelSmall.copyWith(
                      color: onDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                TextSpan(
                  text: body,
                  style: AmdsTextStyles.bodySmall.copyWith(color: onDark),
                ),
              ],
            ),
      textStyle: AmdsTextStyles.bodySmall.copyWith(color: onDark),
      padding: const EdgeInsets.symmetric(
          horizontal: AmdsSpacing.sm, vertical: AmdsSpacing.xs),
      margin: const EdgeInsets.all(AmdsSpacing.sm),
      decoration: BoxDecoration(
        color: c.onSurface.withValues(alpha: 0.92),
        borderRadius: AmdsRadius.brSm,
      ),
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 4),
      child: child,
    );
  }
}

/// A small "ⓘ" affordance that reveals an [AmdsTooltip]. Use next to field
/// labels, KPI titles, jargon.
class AmdsInfoDot extends StatelessWidget {
  const AmdsInfoDot({
    required this.body,
    this.title,
    this.size = AmdsSize.iconSm,
    super.key,
  });

  final String body;
  final String? title;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    return AmdsTooltip(
      title: title,
      body: body,
      child: Semantics(
        button: true,
        label: title == null ? 'More information' : 'About $title',
        child: Icon(Icons.info_outline, size: size, color: c.textTertiary),
      ),
    );
  }
}

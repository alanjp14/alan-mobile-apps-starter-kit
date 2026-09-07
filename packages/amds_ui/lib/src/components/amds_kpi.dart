// AMDS v1.0 · KPI Card + Statistic + Delta — the building blocks of dashboards.
// See docs/screen-library/dashboard-system.md + docs/component-library/data-display.md.

import 'package:amds_motion/amds_motion.dart';
import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

import 'amds_card.dart';

/// Direction of a change, independent of whether it's "good".
enum AmdsTrend { up, down, flat }

/// A small "+12.4%" pill coloured by whether the movement is positive.
class AmdsDeltaChip extends StatelessWidget {
  const AmdsDeltaChip({
    required this.label,
    required this.trend,
    this.goodWhenUp = true,
    super.key,
  });

  final String label;
  final AmdsTrend trend;

  /// Most metrics are good when they go up; set false for things like error rate.
  final bool goodWhenUp;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    final good = switch (trend) {
      AmdsTrend.up => goodWhenUp,
      AmdsTrend.down => !goodWhenUp,
      AmdsTrend.flat => true,
    };
    final fg = switch (trend) {
      AmdsTrend.flat => c.textSecondary,
      _ => good ? c.success : c.danger,
    };
    final icon = switch (trend) {
      AmdsTrend.up => Icons.arrow_upward,
      AmdsTrend.down => Icons.arrow_downward,
      AmdsTrend.flat => Icons.remove,
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: fg),
        const SizedBox(width: 2),
        Text(label,
            style: AmdsTextStyles.labelSmall
                .copyWith(color: fg, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/// A labelled figure. Use inside cards, rows, or a [Wrap] on dashboards.
class AmdsStat extends StatelessWidget {
  const AmdsStat({
    required this.label,
    required this.value,
    this.delta,
    this.trend,
    this.animate = true,
    super.key,
  });

  final String label;

  /// Pass a pre-formatted string, or a [num] to get an animated count-up.
  final Object value;
  final String? delta;
  final AmdsTrend? trend;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    final valueWidget = switch (value) {
      final num n when animate =>
        AmdsAnimatedCount(n, style: context.text.headlineSmall),
      final num n => Text('$n', style: context.text.headlineSmall),
      _ => Text('$value', style: context.text.headlineSmall),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.toUpperCase(),
            style: AmdsTextStyles.overline.copyWith(color: c.textTertiary)),
        const SizedBox(height: AmdsSpacing.xs),
        valueWidget,
        if (delta != null && trend != null) ...[
          const SizedBox(height: AmdsSpacing.xs),
          AmdsDeltaChip(label: delta!, trend: trend!),
        ],
      ],
    );
  }
}

/// A full KPI card: title, big value, delta, optional footnote and tap target
/// (drill-in). The canonical dashboard tile.
class AmdsKpiCard extends StatelessWidget {
  const AmdsKpiCard({
    required this.label,
    required this.value,
    this.delta,
    this.trend,
    this.footnote,
    this.icon,
    this.onTap,
    super.key,
  });

  final String label;
  final Object value;
  final String? delta;
  final AmdsTrend? trend;
  final String? footnote;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    return AmdsCard(
      onTap: onTap,
      semanticLabel: onTap == null ? null : '$label, $value',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label.toUpperCase(),
                    style: AmdsTextStyles.overline
                        .copyWith(color: c.textSecondary)),
              ),
              if (icon != null) Icon(icon, size: 18, color: c.textTertiary),
            ],
          ),
          const SizedBox(height: AmdsSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              switch (value) {
                final num n =>
                  AmdsAnimatedCount(n, style: context.text.displaySmall),
                _ => Text('$value', style: context.text.displaySmall),
              },
              if (delta != null && trend != null) ...[
                const SizedBox(width: AmdsSpacing.sm),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: AmdsDeltaChip(label: delta!, trend: trend!),
                ),
              ],
            ],
          ),
          if (footnote != null) ...[
            const SizedBox(height: AmdsSpacing.xs),
            Text(footnote!,
                style: AmdsTextStyles.caption.copyWith(color: c.textTertiary)),
          ],
        ],
      ),
    );
  }
}

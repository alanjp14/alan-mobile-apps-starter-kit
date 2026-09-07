// AMDS v1.0 · Chart Container + Legend + Sparkline. AMDS does not ship a
// charting engine — [AmdsChartContainer] is the frame (title, actions, legend,
// aspect ratio, loading/empty/error) around whatever renderer you use
// (fl_chart, syncfusion, a CustomPainter…). [AmdsSparkline] is a tiny,
// dependency-free trend line for inline use in cards and rows.
// See docs/component-library/data-display.md + docs/screen-library/dashboard-system.md.

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

import '../state/amds_states.dart';
import 'amds_card.dart';

enum AmdsChartStatus { ready, loading, empty, error }

class AmdsChartContainer extends StatelessWidget {
  const AmdsChartContainer({
    required this.title,
    required this.child,
    this.subtitle,
    this.actions,
    this.legend,
    this.aspectRatio = 16 / 9,
    this.status = AmdsChartStatus.ready,
    this.onRetry,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? legend;
  final Widget child;
  final double aspectRatio;
  final AmdsChartStatus status;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    return AmdsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.text.titleMedium),
                    if (subtitle != null)
                      Text(subtitle!,
                          style: AmdsTextStyles.bodySmall
                              .copyWith(color: c.textSecondary)),
                  ],
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
          const SizedBox(height: AmdsSpacing.md),
          AspectRatio(
            aspectRatio: aspectRatio,
            child: switch (status) {
              AmdsChartStatus.ready => child,
              AmdsChartStatus.loading =>
                const Center(child: AmdsLoadingState(label: 'Loading chart')),
              AmdsChartStatus.empty => const AmdsEmptyState(
                  title: 'No data for this range',
                  icon: Icons.show_chart,
                ),
              AmdsChartStatus.error => AmdsErrorState(
                  title: "Couldn't load chart",
                  onRetry: onRetry,
                ),
            },
          ),
          if (legend != null) ...[
            const SizedBox(height: AmdsSpacing.md),
            legend!,
          ],
        ],
      ),
    );
  }
}

class AmdsLegendItem {
  const AmdsLegendItem({required this.label, required this.color});
  final String label;
  final Color color;
}

class AmdsLegend extends StatelessWidget {
  const AmdsLegend({required this.items, super.key});

  final List<AmdsLegendItem> items;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    return Wrap(
      spacing: AmdsSpacing.md,
      runSpacing: AmdsSpacing.xs,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: AmdsRadius.brXs,
                ),
              ),
              const SizedBox(width: AmdsSpacing.xs),
              Text(item.label,
                  style: AmdsTextStyles.labelSmall
                      .copyWith(color: c.textSecondary)),
            ],
          ),
      ],
    );
  }
}

/// A minimal trend line. Give it 2+ values; it normalises and draws. Optional
/// [fill] shades the area. No axes, no labels — for cards and table cells.
class AmdsSparkline extends StatelessWidget {
  const AmdsSparkline({
    required this.values,
    this.color,
    this.fill = true,
    this.strokeWidth = 2,
    this.height = 32,
    super.key,
  });

  final List<double> values;
  final Color? color;
  final bool fill;
  final double strokeWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final line = color ?? context.amds.colors.primary;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(
          values: values,
          line: line,
          fill: fill,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.line,
    required this.fill,
    required this.strokeWidth,
  });

  final List<double> values;
  final Color line;
  final bool fill;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final span = (max - min).abs() < 1e-9 ? 1.0 : max - min;
    final dx = size.width / (values.length - 1);

    Offset pointAt(int i) => Offset(
          i * dx,
          size.height - ((values[i] - min) / span) * size.height,
        );

    final path = Path()..moveTo(0, pointAt(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(pointAt(i).dx, pointAt(i).dy);
    }

    if (fill) {
      final area = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        area,
        Paint()..color = line.withValues(alpha: 0.12),
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.values != values ||
      old.line != line ||
      old.fill != fill ||
      old.strokeWidth != strokeWidth;
}

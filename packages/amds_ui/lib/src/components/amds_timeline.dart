// AMDS v1.0 · Timeline — an ordered sequence of events with a connector rail.
// Approvals, audit trails, shipment tracking, activity feeds.
// See docs/component-library/design-specs.md (Content › Timeline).

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

import 'amds_misc.dart' show AmdsStatusTone, AmdsStatusToneX;

class AmdsTimelineTile {
  const AmdsTimelineTile({
    required this.title,
    this.subtitle,
    this.timestamp,
    this.tone = AmdsStatusTone.neutral,
    this.icon,
    this.current = false,
  });

  final String title;
  final String? subtitle;
  final String? timestamp;
  final AmdsStatusTone tone;
  final IconData? icon;

  /// Emphasises this node as the "you are here" step.
  final bool current;
}

class AmdsTimeline extends StatelessWidget {
  const AmdsTimeline({required this.tiles, super.key});

  final List<AmdsTimelineTile> tiles;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < tiles.length; i++)
          _Row(
            tile: tiles[i],
            isFirst: i == 0,
            isLast: i == tiles.length - 1,
            railColor: c.border,
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.tile,
    required this.isFirst,
    required this.isLast,
    required this.railColor,
  });

  final AmdsTimelineTile tile;
  final bool isFirst;
  final bool isLast;
  final Color railColor;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    final toneColors = tile.tone.resolve(c);
    final nodeColor =
        tile.tone == AmdsStatusTone.neutral ? c.borderStrong : toneColors.fg;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AmdsSize.iconLg,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: AmdsBorderWidth.thin,
                    color: isFirst ? Colors.transparent : railColor,
                  ),
                ),
                Container(
                  width: tile.current ? 16 : 12,
                  height: tile.current ? 16 : 12,
                  decoration: BoxDecoration(
                    color: tile.current ? c.surface : nodeColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: nodeColor,
                      width: tile.current ? 3 : AmdsBorderWidth.thin,
                    ),
                  ),
                  child: tile.icon == null
                      ? null
                      : Icon(tile.icon, size: 8, color: c.surface),
                ),
                Expanded(
                  child: Container(
                    width: AmdsBorderWidth.thin,
                    color: isLast ? Colors.transparent : railColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AmdsSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: AmdsSpacing.xs, bottom: AmdsSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tile.title,
                          style: context.text.bodyMedium?.copyWith(
                            color: c.textPrimary,
                            fontWeight: tile.current ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                      if (tile.timestamp != null)
                        Text(tile.timestamp!,
                            style: AmdsTextStyles.caption
                                .copyWith(color: c.textTertiary)),
                    ],
                  ),
                  if (tile.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(tile.subtitle!,
                        style: AmdsTextStyles.bodySmall
                            .copyWith(color: c.textSecondary)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// AMDS v1.0 · Breadcrumb — hierarchy trail for deep navigation (folders,
// org units, catalog categories). Collapses the middle on overflow.
// See docs/design-system/navigation-patterns.md.

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

class AmdsCrumb {
  const AmdsCrumb(this.label, {this.onTap});
  final String label;

  /// Null for the current (last) crumb.
  final VoidCallback? onTap;
}

class AmdsBreadcrumb extends StatelessWidget {
  const AmdsBreadcrumb({
    required this.crumbs,
    this.maxVisible = 3,
    super.key,
  });

  final List<AmdsCrumb> crumbs;

  /// When there are more than this, the middle collapses to a "…" menu.
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    final sep = Padding(
      padding: const EdgeInsets.symmetric(horizontal: AmdsSpacing.xs),
      child: Icon(Icons.chevron_right, size: 16, color: c.textTertiary),
    );

    Widget crumbText(AmdsCrumb crumb, {required bool current}) {
      final style = AmdsTextStyles.labelSmall.copyWith(
        color: current ? c.textPrimary : c.textLink,
        fontWeight: current ? FontWeight.w600 : FontWeight.w500,
      );
      if (current || crumb.onTap == null) {
        return Text(crumb.label, style: style);
      }
      return InkWell(
        onTap: crumb.onTap,
        borderRadius: AmdsRadius.brXs,
        child: Text(crumb.label, style: style),
      );
    }

    final List<Widget> children;
    if (crumbs.length <= maxVisible) {
      children = [
        for (var i = 0; i < crumbs.length; i++) ...[
          if (i > 0) sep,
          crumbText(crumbs[i], current: i == crumbs.length - 1),
        ],
      ];
    } else {
      final hidden = crumbs.sublist(1, crumbs.length - 1);
      children = [
        crumbText(crumbs.first, current: false),
        sep,
        PopupMenuButton<int>(
          tooltip: 'Show path',
          padding: EdgeInsets.zero,
          child: Icon(Icons.more_horiz, size: 18, color: c.textSecondary),
          itemBuilder: (context) => [
            for (var i = 0; i < hidden.length; i++)
              PopupMenuItem<int>(value: i, child: Text(hidden[i].label)),
          ],
          onSelected: (i) => hidden[i].onTap?.call(),
        ),
        sep,
        crumbText(crumbs.last, current: true),
      ];
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

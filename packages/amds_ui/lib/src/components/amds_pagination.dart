// AMDS v1.0 · Pagination — numbered pages (report / tablet) and a "Load more"
// footer (browse). Infinite scroll is a screen behaviour, not a component.
// See docs/component-library/data-display.md §8.

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

import 'amds_button.dart';

/// Compact numbered pager: ‹ 1 2 … 7 › with an "N–M of T" summary.
class AmdsPagination extends StatelessWidget {
  const AmdsPagination({
    required this.page,
    required this.pageCount,
    required this.onPageChanged,
    this.totalItems,
    this.pageSize,
    super.key,
  });

  /// 1-based current page.
  final int page;
  final int pageCount;
  final ValueChanged<int> onPageChanged;
  final int? totalItems;
  final int? pageSize;

  List<int?> get _windows {
    if (pageCount <= 7) {
      return [for (var i = 1; i <= pageCount; i++) i];
    }
    final pages = <int>{1, pageCount, page, page - 1, page + 1}
        .where((p) => p >= 1 && p <= pageCount)
        .toList()
      ..sort();
    final out = <int?>[];
    for (var i = 0; i < pages.length; i++) {
      if (i > 0 && pages[i] - pages[i - 1] > 1) out.add(null); // ellipsis
      out.add(pages[i]);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;

    Widget numberButton(int p) {
      final active = p == page;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: active ? c.primary : Colors.transparent,
          borderRadius: AmdsRadius.brSm,
          child: InkWell(
            borderRadius: AmdsRadius.brSm,
            onTap: active ? null : () => onPageChanged(p),
            child: Container(
              constraints: const BoxConstraints(
                  minWidth: AmdsSize.touchTarget,
                  minHeight: AmdsSize.touchTarget),
              alignment: Alignment.center,
              child: Text(
                '$p',
                style: AmdsTextStyles.label.copyWith(
                  color: active ? c.onPrimary : c.textPrimary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: page > 1 ? () => onPageChanged(page - 1) : null,
              tooltip: 'Previous page',
            ),
            for (final p in _windows)
              if (p == null)
                Text('…', style: TextStyle(color: c.textTertiary))
              else
                numberButton(p),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed:
                  page < pageCount ? () => onPageChanged(page + 1) : null,
              tooltip: 'Next page',
            ),
          ],
        ),
        if (totalItems != null && pageSize != null)
          Text(
            _rangeLabel(),
            style: AmdsTextStyles.caption.copyWith(color: c.textSecondary),
          ),
      ],
    );
  }

  String _rangeLabel() {
    final start = (page - 1) * pageSize! + 1;
    final end = (page * pageSize!).clamp(0, totalItems!);
    return '$start–$end of $totalItems';
  }
}

/// "Load more" footer with a running count. Show a spinner while [loading].
class AmdsLoadMoreFooter extends StatelessWidget {
  const AmdsLoadMoreFooter({
    required this.loaded,
    required this.total,
    required this.onLoadMore,
    this.loading = false,
    super.key,
  });

  final int loaded;
  final int total;
  final VoidCallback onLoadMore;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    final done = loaded >= total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AmdsSpacing.md),
      child: Column(
        children: [
          if (done)
            Text("You've reached the end",
                style: AmdsTextStyles.bodySmall.copyWith(color: c.textTertiary))
          else
            AmdsButton(
              label: 'Load more',
              variant: AmdsButtonVariant.secondary,
              loading: loading,
              onPressed: loading ? null : onLoadMore,
            ),
          const SizedBox(height: AmdsSpacing.xs),
          Text('Showing $loaded of $total',
              style: AmdsTextStyles.caption.copyWith(color: c.textSecondary)),
        ],
      ),
    );
  }
}

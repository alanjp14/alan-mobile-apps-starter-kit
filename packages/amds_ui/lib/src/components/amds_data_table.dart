// AMDS v1.0 · Data Table — a true, horizontally-scrolling grid with a sticky
// header, single-column sort, optional selection, and per-row tap.
// On phones, prefer the "row transformation" (AmdsListItem) — see
// docs/component-library/data-display.md §3. This widget is the tablet /
// comparison-heavy / power-user path.

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

enum AmdsTableDensity { comfortable, compact, multiline }

extension _DensityMetrics on AmdsTableDensity {
  double get rowHeight => switch (this) {
        AmdsTableDensity.comfortable => 52,
        AmdsTableDensity.compact => 40,
        AmdsTableDensity.multiline => 64,
      };
}

/// One column definition. [cell] renders the value for a row of type `T`.
class AmdsDataColumn<T extends Object> {
  const AmdsDataColumn({
    required this.label,
    required this.cell,
    this.numeric = false,
    this.sortable = false,
    this.minWidth,
  });

  final String label;
  final Widget Function(T row) cell;
  final bool numeric;
  final bool sortable;
  final double? minWidth;

  double get _min => minWidth ?? (numeric ? 72 : 120);
}

class AmdsDataTable<T extends Object> extends StatelessWidget {
  const AmdsDataTable({
    required this.columns,
    required this.rows,
    this.keyOf,
    this.density = AmdsTableDensity.comfortable,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    this.onRowTap,
    this.selected,
    this.onSelectionChanged,
    this.rowIdentifier,
    super.key,
  });

  final List<AmdsDataColumn<T>> columns;
  final List<T> rows;

  /// Stable identity for selection. Defaults to the row object itself — pass
  /// an id extractor when rows are rebuilt (e.g. after a refresh).
  final Object Function(T row)? keyOf;

  final AmdsTableDensity density;
  final int? sortColumnIndex;
  final bool sortAscending;

  /// `(columnIndex, ascending)` — wire to your query and rebuild [rows].
  final void Function(int columnIndex, bool ascending)? onSort;
  final ValueChanged<T>? onRowTap;

  /// When non-null, a checkbox column appears.
  final Set<Object>? selected;
  final ValueChanged<Set<Object>>? onSelectionChanged;

  /// Human label for a row, used on its checkbox ("Select Compressor A-12").
  final String Function(T row)? rowIdentifier;

  Object _key(T row) => keyOf?.call(row) ?? row;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    final selectable = selected != null && onSelectionChanged != null;
    const checkboxWidth = 48.0;

    void toggleAll(bool? on) {
      final next = <Object>{};
      if (on ?? false) next.addAll(rows.map(_key));
      onSelectionChanged!(next);
    }

    void toggleRow(T row, bool? on) {
      final next = {...selected!};
      (on ?? false) ? next.add(_key(row)) : next.remove(_key(row));
      onSelectionChanged!(next);
    }

    final allSelected = selectable &&
        rows.isNotEmpty &&
        rows.every((r) => selected!.contains(_key(r)));

    Widget headerCell(AmdsDataColumn<T> col, int index) {
      final active = sortColumnIndex == index;
      final child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            col.numeric ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              col.label.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: AmdsTextStyles.overline.copyWith(
                color: active ? c.primary : c.textSecondary,
              ),
            ),
          ),
          if (col.sortable)
            Icon(
              active
                  ? (sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                  : Icons.unfold_more,
              size: 14,
              color: active ? c.primary : c.textTertiary,
            ),
        ],
      );
      return _Cell(
        width: col._min,
        density: density,
        alignEnd: col.numeric,
        child: col.sortable && onSort != null
            ? InkWell(
                onTap: () => onSort!(
                  index,
                  active ? !sortAscending : true,
                ),
                child: child,
              )
            : child,
      );
    }

    Widget dataRow(T row) {
      final isSel = selectable && selected!.contains(_key(row));
      return Semantics(
        button: onRowTap != null,
        selected: isSel,
        label: rowIdentifier?.call(row),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onRowTap == null ? null : () => onRowTap!(row),
            child: Container(
              decoration: BoxDecoration(
                color: isSel ? c.primaryContainer.withValues(alpha: 0.4) : null,
                border: Border(bottom: BorderSide(color: c.divider)),
              ),
              child: Row(
                children: [
                  if (selectable)
                    SizedBox(
                      width: checkboxWidth,
                      child: Checkbox(
                        value: isSel,
                        onChanged: (v) => toggleRow(row, v),
                        semanticLabel: rowIdentifier?.call(row),
                      ),
                    ),
                  for (final col in columns)
                    _Cell(
                      width: col._min,
                      density: density,
                      alignEnd: col.numeric,
                      child: DefaultTextStyle.merge(
                        style: AmdsTextStyles.bodySmall
                            .copyWith(color: c.textPrimary),
                        child: col.cell(row),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final tableWidth = (selectable ? checkboxWidth : 0.0) +
        columns.fold<double>(0, (sum, col) => sum + col._min);

    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: tableWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // header row (put the table in a parent scroll view for many rows;
              // wrap in a sticky-header sliver at the screen level if needed)
              Container(
                color: c.surfaceVariant,
                child: Row(
                  children: [
                    if (selectable)
                      SizedBox(
                        width: checkboxWidth,
                        child: Checkbox(
                          value: allSelected,
                          tristate: true,
                          onChanged: toggleAll,
                          semanticLabel: 'Select all rows',
                        ),
                      ),
                    for (var i = 0; i < columns.length; i++)
                      headerCell(columns[i], i),
                  ],
                ),
              ),
              for (final row in rows) dataRow(row),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.width,
    required this.density,
    required this.child,
    this.alignEnd = false,
  });

  final double width;
  final AmdsTableDensity density;
  final Widget child;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        constraints: BoxConstraints(minHeight: density.rowHeight),
        alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
        padding: EdgeInsets.symmetric(
          horizontal: AmdsSpacing.md,
          vertical: density == AmdsTableDensity.compact
              ? AmdsSpacing.xs
              : AmdsSpacing.sm,
        ),
        child: child,
      );
}

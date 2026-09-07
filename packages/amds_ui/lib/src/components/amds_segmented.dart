// AMDS v1.0 · Segmented Control + Tabs — mutually-exclusive view switches.
// Segmented = 2–4 short options in a track; Tabs = top-of-content sections.
// See docs/design-system/navigation-patterns.md.

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

/// iOS-style segmented control. Keep to 2–4 options with short labels.
class AmdsSegmentedControl<T> extends StatelessWidget {
  const AmdsSegmentedControl({
    required this.segments,
    required this.value,
    required this.onChanged,
    this.labelOf,
    super.key,
  });

  /// Ordered options. Provide [labelOf] unless `T` is an enum-like with a
  /// readable `toString`.
  final List<T> segments;
  final T value;
  final ValueChanged<T> onChanged;
  final String Function(T)? labelOf;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    final label = labelOf ?? (v) => '$v';

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.surfaceVariant,
        borderRadius: AmdsRadius.brMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final s in segments)
            Expanded(
              child: Semantics(
                button: true,
                selected: s == value,
                label: label(s),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(s),
                  child: AnimatedContainer(
                    duration: AmdsMotion.fast,
                    curve: AmdsMotion.standard,
                    constraints:
                        const BoxConstraints(minHeight: AmdsSize.iconLg),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: s == value ? c.surface : Colors.transparent,
                      borderRadius: AmdsRadius.brSm,
                      boxShadow: s == value ? context.amds.elevation(1) : null,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AmdsSpacing.sm, vertical: AmdsSpacing.xs),
                    child: Text(
                      label(s),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AmdsTextStyles.label.copyWith(
                        color: s == value ? c.textPrimary : c.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Underline tab bar + optional paged body. Provide [controllerLength] via
/// [tabs]; drive content yourself with [onChanged] or pass [views].
class AmdsTabs extends StatefulWidget {
  const AmdsTabs({
    required this.tabs,
    this.views,
    this.initialIndex = 0,
    this.onChanged,
    this.scrollable = false,
    super.key,
  });

  final List<String> tabs;
  final List<Widget>? views;
  final int initialIndex;
  final ValueChanged<int>? onChanged;
  final bool scrollable;

  @override
  State<AmdsTabs> createState() => _AmdsTabsState();
}

class _AmdsTabsState extends State<AmdsTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(
    length: widget.tabs.length,
    initialIndex: widget.initialIndex,
    vsync: this,
  )..addListener(() {
      if (!_tab.indexIsChanging) widget.onChanged?.call(_tab.index);
    });

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    final bar = TabBar(
      controller: _tab,
      isScrollable: widget.scrollable,
      tabAlignment: widget.scrollable ? TabAlignment.start : TabAlignment.fill,
      labelColor: c.primary,
      unselectedLabelColor: c.textSecondary,
      labelStyle: AmdsTextStyles.label,
      indicatorColor: c.primary,
      indicatorWeight: AmdsBorderWidth.thick,
      dividerColor: c.divider,
      overlayColor: WidgetStateProperty.all(
        c.primary.withValues(alpha: AmdsOpacity.hover),
      ),
      tabs: [for (final t in widget.tabs) Tab(text: t)],
    );

    if (widget.views == null) return bar;
    return Column(
      children: [
        bar,
        Expanded(
          child: TabBarView(controller: _tab, children: widget.views!),
        ),
      ],
    );
  }
}

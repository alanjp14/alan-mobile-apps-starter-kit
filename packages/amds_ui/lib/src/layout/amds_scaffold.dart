// AMDS v1.0 · Scaffold + adaptive navigation. See
// docs/design-system/navigation-patterns.md + spacing.md §4.

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

/// Thin wrapper that applies AMDS content margins and safe areas.
class AmdsScaffold extends StatelessWidget {
  const AmdsScaffold({
    required this.body,
    this.appBar,
    this.title,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.banner,
    this.applyContentMargin = true,
    this.scrollable = true,
    super.key,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? banner;
  final bool applyContentMargin;
  final bool scrollable;

  double _margin(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= AmdsBreakpoints.tabletLandscape) return AmdsSpacing.xl;
    if (w >= AmdsBreakpoints.tabletPortrait) return AmdsSpacing.lg;
    return AmdsSpacing.md;
  }

  @override
  Widget build(BuildContext context) {
    final margin = applyContentMargin ? EdgeInsets.symmetric(horizontal: _margin(context)) : EdgeInsets.zero;

    Widget content = Padding(padding: margin, child: body);
    if (scrollable) {
      content = SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AmdsSpacing.xl),
        child: content,
      );
    }
    if (banner != null) {
      content = Column(children: [
        Padding(padding: EdgeInsets.fromLTRB(margin.horizontal / 2, AmdsSpacing.sm, margin.horizontal / 2, 0), child: banner),
        Expanded(child: content),
      ]);
    }

    return Scaffold(
      appBar: appBar ??
          (title == null
              ? null
              : AppBar(
                  title: Text(title!),
                  leading: leading,
                  actions: actions,
                )),
      body: SafeArea(child: content),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class AmdsNavDestination {
  const AmdsNavDestination({required this.label, required this.icon, required this.selectedIcon, this.badgeCount});
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final int? badgeCount;
}

/// Bottom nav (phone) → rail (small tablet) → permanent drawer (large tablet).
class AmdsAdaptiveNavigation extends StatelessWidget {
  const AmdsAdaptiveNavigation({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.fab,
    super.key,
  });

  final List<AmdsNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final Widget? fab;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    if (w >= AmdsBreakpoints.tabletLandscape) {
      return Scaffold(
        body: SafeArea(
          child: Row(children: [
            NavigationDrawer(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              children: [
                const SizedBox(height: AmdsSpacing.md),
                for (final d in destinations)
                  NavigationDrawerDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon), label: Text(d.label)),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ]),
        ),
        floatingActionButton: fab,
      );
    }

    if (w >= AmdsBreakpoints.tabletPortrait) {
      return Scaffold(
        body: SafeArea(
          child: Row(children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              leading: fab,
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(icon: _icon(d, false), selectedIcon: _icon(d, true), label: Text(d.label)),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ]),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(child: body),
      floatingActionButton: fab,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: [
          for (final d in destinations)
            NavigationDestination(icon: _icon(d, false), selectedIcon: _icon(d, true), label: d.label),
        ],
      ),
    );
  }

  Widget _icon(AmdsNavDestination d, bool selected) {
    final icon = Icon(selected ? d.selectedIcon : d.icon);
    if (d.badgeCount == null || d.badgeCount == 0) return icon;
    return Badge(label: Text('${d.badgeCount! > 99 ? '99+' : d.badgeCount}'), child: icon);
  }
}

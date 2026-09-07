// AMDS v1.0 · Bottom Sheet — modal surface anchored to the bottom edge.
// See docs/component-library/design-specs.md (Feedback › Bottom Sheet).

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

abstract final class AmdsBottomSheet {
  /// Shows a modal bottom sheet with the AMDS surface, grab handle, optional
  /// title, and safe-area padding. Returns whatever the sheet pops with.
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    String? title,
    bool showHandle = true,
    bool isScrollControlled = true,
    bool dismissible = true,
  }) {
    final c = context.amds.colors;
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: dismissible,
      enableDrag: dismissible,
      useSafeArea: true,
      backgroundColor: c.surface,
      barrierColor: c.overlayScrim,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AmdsRadius.xl)),
      ),
      builder: (sheetContext) {
        final media = MediaQuery.of(sheetContext);
        return Padding(
          padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showHandle)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: AmdsSpacing.sm),
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: c.borderStrong,
                      borderRadius: AmdsRadius.brFull,
                    ),
                  ),
                ),
              if (title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(AmdsSpacing.md,
                      AmdsSpacing.md, AmdsSpacing.md, AmdsSpacing.xs),
                  child: Text(title,
                      style: Theme.of(sheetContext).textTheme.titleLarge),
                ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AmdsSpacing.md,
                      AmdsSpacing.sm, AmdsSpacing.md, AmdsSpacing.lg),
                  child: builder(sheetContext),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// A simple action-list sheet. Pops the chosen [AmdsSheetAction.value].
  static Future<T?> actions<T>(
    BuildContext context, {
    required List<AmdsSheetAction<T>> actions,
    String? title,
  }) {
    return show<T>(
      context,
      title: title,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final a in actions)
            ListTile(
              leading: a.icon == null ? null : Icon(a.icon),
              title: Text(a.label),
              textColor: a.destructive ? context.amds.colors.danger : null,
              iconColor: a.destructive ? context.amds.colors.danger : null,
              onTap: () => Navigator.of(context).pop(a.value),
            ),
        ],
      ),
    );
  }
}

class AmdsSheetAction<T> {
  const AmdsSheetAction({
    required this.label,
    required this.value,
    this.icon,
    this.destructive = false,
  });

  final String label;
  final T value;
  final IconData? icon;
  final bool destructive;
}

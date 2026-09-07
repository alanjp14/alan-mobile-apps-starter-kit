// AMDS v1.0 · Snackbar + Dialog helpers. See design-specs.md D1/D4.

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

import 'amds_button.dart';
import 'amds_misc.dart';

abstract final class AmdsSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    AmdsStatusTone tone = AmdsStatusTone.neutral,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (tone != AmdsStatusTone.neutral) ...[
              Icon(tone.icon,
                  size: AmdsSize.iconSm,
                  color: Theme.of(context).colorScheme.onInverseSurface),
              const SizedBox(width: AmdsSpacing.sm),
            ],
            Expanded(child: Text(message)),
          ],
        ),
        duration: duration ??
            (tone == AmdsStatusTone.danger || onAction != null
                ? const Duration(seconds: 6)
                : const Duration(seconds: 4)),
        action: (actionLabel != null && onAction != null)
            ? SnackBarAction(label: actionLabel, onPressed: onAction)
            : null,
      ),
    );
  }
}

abstract final class AmdsDialogs {
  /// Returns `true` if confirmed. For destructive actions, Cancel is default-focused.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String body,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool danger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: danger
            ? Icon(Icons.warning_amber_rounded,
                color: context.amds.colors.danger)
            : null,
        title: Text(title),
        content: Text(body),
        actions: [
          AmdsButton(
            label: cancelLabel,
            variant: AmdsButtonVariant.tertiary,
            autofocus:
                danger, // destructive dialogs default-focus the safe choice
            onPressed: () => Navigator.of(context).pop(false),
          ),
          AmdsButton(
            label: confirmLabel,
            variant: danger
                ? AmdsButtonVariant.destructive
                : AmdsButtonVariant.primary,
            autofocus: !danger,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

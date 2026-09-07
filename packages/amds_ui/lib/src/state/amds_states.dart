// AMDS v1.0 · standard state widgets — Loading / Empty / Error / Offline.
// See docs/design-system/foundations.md §3 + screen-library/11-utility-states.md.

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

import '../components/amds_button.dart';
import '../components/amds_misc.dart';

class _CenteredState extends StatelessWidget {
  const _CenteredState(
      {required this.icon,
      required this.title,
      this.body,
      this.action,
      this.iconColor});

  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(AmdsSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: AmdsSize.iconXl, color: iconColor ?? c.textTertiary),
              const SizedBox(height: AmdsSpacing.md),
              Text(title,
                  style: context.text.headlineSmall,
                  textAlign: TextAlign.center),
              if (body != null) ...[
                const SizedBox(height: AmdsSpacing.xs),
                Text(body!,
                    style: AmdsTextStyles.bodyMedium
                        .copyWith(color: c.textSecondary),
                    textAlign: TextAlign.center),
              ],
              if (action != null) ...[
                const SizedBox(height: AmdsSpacing.lg),
                action!
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AmdsLoadingState extends StatelessWidget {
  const AmdsLoadingState({this.label = 'Loading', super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Semantics(
        label: label,
        liveRegion: true,
        child: const Center(child: CircularProgressIndicator()),
      );
}

class AmdsEmptyState extends StatelessWidget {
  const AmdsEmptyState({
    required this.title,
    this.body,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? body;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => _CenteredState(
        icon: icon,
        title: title,
        body: body,
        action: (actionLabel != null && onAction != null)
            ? AmdsButton(
                label: actionLabel!,
                onPressed: onAction,
                size: AmdsButtonSize.lg)
            : null,
      );
}

class AmdsErrorState extends StatelessWidget {
  const AmdsErrorState({
    this.title = 'Something went wrong',
    this.body,
    this.traceId,
    this.onRetry,
    super.key,
  });

  final String title;
  final String? body;
  final String? traceId;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    return _CenteredState(
      icon: Icons.error_outline,
      iconColor: c.danger,
      title: title,
      body: body,
      action: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onRetry != null)
            AmdsButton(
                label: 'Try again',
                onPressed: onRetry,
                size: AmdsButtonSize.lg),
          if (traceId != null) ...[
            const SizedBox(height: AmdsSpacing.sm),
            SelectableText('Ref: $traceId',
                style: AmdsTextStyles.caption.copyWith(color: c.textTertiary)),
          ],
        ],
      ),
    );
  }
}

/// Persistent banner for the offline condition. Pair with cached content.
class AmdsOfflineBanner extends StatelessWidget {
  const AmdsOfflineBanner({this.asOf, this.onRetry, super.key});

  final String? asOf;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => AmdsBanner(
        tone: AmdsStatusTone.warning,
        message: asOf == null
            ? "You're offline."
            : "You're offline — showing data from $asOf.",
        action: onRetry == null ? null : 'Retry',
        onActionPressed: onRetry,
      );
}

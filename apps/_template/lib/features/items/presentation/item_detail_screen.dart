import 'package:amds_core/amds_core.dart';
import 'package:amds_ui/amds_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../domain/item.dart';
import 'items_controller.dart';

class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({required this.id, super.key});

  final String id;

  ({String label, AmdsStatusTone tone}) _status(ItemStatus s) => switch (s) {
        ItemStatus.pending => (label: 'Pending', tone: AmdsStatusTone.warning),
        ItemStatus.approved => (
            label: 'Approved',
            tone: AmdsStatusTone.success
          ),
        ItemStatus.archived => (
            label: 'Archived',
            tone: AmdsStatusTone.neutral
          ),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(itemByIdProvider(id));
    final c = context.amds.colors;
    final fmt = AmdsFormatters();
    final controller = ref.read(itemsControllerProvider.notifier);

    return AmdsScaffold(
      scrollable: false,
      appBar: AppBar(
        title: const Text('[FEATURE_NAME]'),
        actions: [
          if (item.valueOrNull != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: () => context.push(Routes.itemEdit(id)),
            ),
        ],
      ),
      body: switch (item) {
        AsyncData(:final value) => ListView(
            children: [
              const SizedBox(height: AmdsSpacing.md),
              Row(
                children: [
                  AmdsAvatar(name: value.title, size: AmdsSize.avatarLg),
                  const SizedBox(width: AmdsSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(value.title, style: context.text.headlineSmall),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            AmdsStatusChip(_status(value.status).label,
                                tone: _status(value.status).tone),
                            const SizedBox(width: AmdsSpacing.sm),
                            Text('Updated ${fmt.relative(value.updatedAt)}',
                                style: AmdsTextStyles.caption
                                    .copyWith(color: c.textTertiary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AmdsSpacing.lg),
              const AmdsSectionHeader('Details'),
              AmdsCard(
                child: Column(
                  children: [
                    _Row(label: 'ID', value: value.id),
                    const Divider(height: AmdsSpacing.lg),
                    _Row(label: 'Owner', value: value.subtitle),
                  ],
                ),
              ),
              const SizedBox(height: AmdsSpacing.xl),
              if (value.status == ItemStatus.pending)
                AmdsButton(
                  label: 'Approve',
                  fullWidth: true,
                  size: AmdsButtonSize.lg,
                  leadingIcon: Icons.check,
                  onPressed: () async {
                    final err = await controller.approve(value.id);
                    if (!context.mounted) return;
                    AmdsSnackbar.show(context,
                        message: err ?? 'Approved',
                        tone: err == null
                            ? AmdsStatusTone.success
                            : AmdsStatusTone.danger);
                  },
                ),
              const SizedBox(height: AmdsSpacing.sm),
              AmdsButton(
                label: 'Archive',
                variant: AmdsButtonVariant.destructiveText,
                fullWidth: true,
                leadingIcon: Icons.archive_outlined,
                onPressed: () async {
                  final ok = await AmdsDialogs.confirm(
                    context,
                    title: 'Archive this [DATA_NAME]?',
                    body: 'It will be removed from the list.',
                    danger: true,
                  );
                  if (!ok || !context.mounted) return;
                  await controller.archive(value.id);
                  if (context.mounted) context.pop();
                },
              ),
            ],
          ),
        AsyncError(:final error) => AmdsErrorState(
            title: 'Could not load [DATA_NAME]',
            body: error is FailureException ? error.failure.message : '$error',
            onRetry: () => ref.invalidate(itemByIdProvider(id)),
          ),
        _ => const AmdsLoadingState(),
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(label,
              style: AmdsTextStyles.label.copyWith(color: c.textSecondary)),
        ),
        Expanded(child: Text(value, style: context.text.bodyMedium)),
      ],
    );
  }
}

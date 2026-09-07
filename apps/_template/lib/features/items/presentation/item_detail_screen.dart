import 'package:amds_core/amds_core.dart';
import 'package:amds_ui/amds_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'items_controller.dart';

class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(itemByIdProvider(id));
    final c = context.amds.colors;
    final fmt = AmdsFormatters();

    return AmdsScaffold(
      appBar: AppBar(title: const Text('[FEATURE_NAME]')),
      body: switch (item) {
        AsyncData(:final value) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(height: 2),
                        Text('Updated ${fmt.relative(value.updatedAt)}',
                            style: AmdsTextStyles.bodySmall
                                .copyWith(color: c.textSecondary)),
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
                    const Divider(height: AmdsSpacing.lg),
                    _Row(
                      label: 'Status',
                      value: value.archived ? 'Archived' : 'Active',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AmdsSpacing.xl),
              AmdsButton(
                label: 'Archive',
                variant: AmdsButtonVariant.destructive,
                fullWidth: true,
                leadingIcon: Icons.archive_outlined,
                onPressed: () async {
                  final ok = await AmdsDialogs.confirm(
                    context,
                    title: 'Archive this [DATA_NAME]?',
                    body: 'You can restore it later from the archive.',
                    danger: true,
                  );
                  if (!ok || !context.mounted) return;
                  await ref
                      .read(itemsControllerProvider.notifier)
                      .archive(value.id);
                  if (context.mounted) Navigator.of(context).pop();
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

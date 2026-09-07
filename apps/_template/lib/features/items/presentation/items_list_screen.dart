import 'package:amds_core/amds_core.dart';
import 'package:amds_ui/amds_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme_controller.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/item.dart';
import 'items_controller.dart';

class ItemsListScreen extends ConsumerWidget {
  const ItemsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itemsControllerProvider);
    final fmt = AmdsFormatters();

    return Scaffold(
      appBar: AppBar(
        title: const Text('[MODULE_NAME]'),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(context.amds.isDark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.itemNew),
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AmdsSpacing.md),
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(itemsControllerProvider.notifier).refresh(),
            child: switch (items) {
              AsyncData(:final value) when value.isEmpty => const _Empty(),
              AsyncData(:final value) => _List(items: value, fmt: fmt),
              AsyncError(:final error) => _Error(
                  failure: error is FailureException ? error.failure : null,
                  onRetry: () =>
                      ref.read(itemsControllerProvider.notifier).refresh(),
                ),
              _ => const Padding(
                  padding: EdgeInsets.only(top: AmdsSpacing.md),
                  child: AmdsSkeletonList(rows: 6),
                ),
            },
          ),
        ),
      ),
    );
  }
}

({String label, AmdsStatusTone tone}) _statusChip(ItemStatus s) => switch (s) {
      ItemStatus.pending => (label: 'Pending', tone: AmdsStatusTone.warning),
      ItemStatus.approved => (label: 'Approved', tone: AmdsStatusTone.success),
      ItemStatus.archived => (label: 'Archived', tone: AmdsStatusTone.neutral),
    };

class _List extends StatelessWidget {
  const _List({required this.items, required this.fmt});

  final List<Item> items;
  final AmdsFormatters fmt;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: AmdsSpacing.md),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AmdsSpacing.sm),
      itemBuilder: (context, i) {
        final item = items[i];
        final chip = _statusChip(item.status);
        return AmdsFadeSlideIn(
          index: i,
          child: AmdsCard(
            onTap: () => context.push(Routes.itemDetail(item.id)),
            semanticLabel:
                '${item.title}, ${chip.label}, updated ${fmt.relative(item.updatedAt)}',
            child: Row(
              children: [
                AmdsAvatar(name: item.title),
                const SizedBox(width: AmdsSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: context.text.titleMedium),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          AmdsStatusChip(chip.label, tone: chip.tone),
                          const SizedBox(width: AmdsSpacing.sm),
                          Flexible(
                            child: Text(
                              item.subtitle,
                              style: AmdsTextStyles.bodySmall
                                  .copyWith(color: c.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) => ListView(
        children: const [
          SizedBox(height: 120),
          AmdsEmptyState(
            title: 'No [DATA_NAME] yet',
            body: 'Tap “New” to create your first one.',
            icon: Icons.inbox_outlined,
          ),
        ],
      );
}

class _Error extends StatelessWidget {
  const _Error({required this.onRetry, this.failure});

  final Failure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final offline = failure is OfflineFailure || failure is NetworkFailure;
    return ListView(
      children: [
        const SizedBox(height: 96),
        AmdsErrorState(
          title: offline ? "You're offline" : 'Could not load [DATA_NAME]',
          body: failure?.message,
          traceId: failure?.traceId,
          onRetry: onRetry,
        ),
      ],
    );
  }
}

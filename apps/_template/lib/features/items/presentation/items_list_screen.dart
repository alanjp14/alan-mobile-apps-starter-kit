import 'package:amds_core/amds_core.dart';
import 'package:amds_ui/amds_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme_controller.dart';
import '../domain/item.dart';
import 'items_controller.dart';

class ItemsListScreen extends ConsumerWidget {
  const ItemsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itemsControllerProvider);
    final fmt = AmdsFormatters();

    return AmdsScaffold(
      scrollable: false,
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
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(itemsControllerProvider.notifier).refresh(),
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
    );
  }
}

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
        return AmdsFadeSlideIn(
          index: i,
          child: AmdsCard(
            onTap: () => context.push(Routes.itemDetail(item.id)),
            semanticLabel:
                '${item.title}, updated ${fmt.relative(item.updatedAt)}',
            child: Row(
              children: [
                AmdsAvatar(name: item.title),
                const SizedBox(width: AmdsSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: context.text.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: AmdsTextStyles.bodySmall
                            .copyWith(color: c.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AmdsSpacing.sm),
                Text(fmt.relative(item.updatedAt),
                    style:
                        AmdsTextStyles.caption.copyWith(color: c.textTertiary)),
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
            body: 'Items you create will show up here.',
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

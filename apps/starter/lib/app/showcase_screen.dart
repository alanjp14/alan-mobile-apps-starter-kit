import 'package:amds_core/amds_core.dart';
import 'package:amds_ui/amds_ui.dart';
import 'package:flutter/material.dart';

import '../main.dart' show themeMode;
import 'detail_screen.dart';

/// A single-screen tour of the AMDS Flutter starter set. Demonstrates the theme,
/// the core components, the state widgets, and a smooth page transition.
class ShowcaseScreen extends StatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  final _field = TextEditingController();
  bool _loading = false;
  final _fmt = AmdsFormatters();

  void _fakeSubmit() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);
    AmdsSnackbar.show(context,
        message: 'Saved',
        tone: AmdsStatusTone.success,
        actionLabel: 'Undo',
        onAction: () {});
  }

  void _openDetail() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: AmdsMotion.moderate,
        reverseTransitionDuration: AmdsMotion.base,
        pageBuilder: (_, __, ___) => const DetailScreen(),
        transitionsBuilder: amdsSharedAxisTransition,
      ),
    );
  }

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;

    return AmdsScaffold(
      appBar: AppBar(
        title: const Text('AMDS Starter'),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(context.amds.isDark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
            onPressed: () => themeMode.value =
                context.amds.isDark ? ThemeMode.light : ThemeMode.dark,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AmdsSpacing.md),

          // KPI-ish card with an animated count + status chip
          AmdsFadeSlideIn(
            index: 0,
            child: AmdsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OPEN ITEMS',
                      style: AmdsTextStyles.overline
                          .copyWith(color: c.textSecondary)),
                  const SizedBox(height: AmdsSpacing.xs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AmdsAnimatedCount(1284, style: context.text.displaySmall),
                      const SizedBox(width: AmdsSpacing.sm),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: AmdsStatusChip('▲ 12%',
                            tone: AmdsStatusTone.success, showIcon: false),
                      ),
                    ],
                  ),
                  const SizedBox(height: AmdsSpacing.xs),
                  Text(
                    'updated ${_fmt.relative(DateTime.now().subtract(const Duration(minutes: 2)))}',
                    style:
                        AmdsTextStyles.caption.copyWith(color: c.textTertiary),
                  ),
                ],
              ),
            ),
          ),

          const AmdsSectionHeader('Buttons'),
          AmdsFadeSlideIn(
            index: 1,
            child: Wrap(
              spacing: AmdsSpacing.sm,
              runSpacing: AmdsSpacing.sm,
              children: [
                AmdsButton(label: 'Primary', onPressed: () {}),
                const AmdsButton(
                    label: 'Secondary',
                    onPressed: null,
                    variant: AmdsButtonVariant.secondary),
                AmdsButton(
                    label: 'Tonal',
                    onPressed: () {},
                    variant: AmdsButtonVariant.tonal),
                AmdsButton(
                    label: 'Delete',
                    onPressed: () {},
                    variant: AmdsButtonVariant.destructive,
                    leadingIcon: Icons.delete_outline),
              ],
            ),
          ),

          const AmdsSectionHeader('Input'),
          AmdsFadeSlideIn(
            index: 2,
            child: AmdsTextField(
              label: 'Full name',
              required: true,
              controller: _field,
              hint: 'e.g. Priya Nair',
              prefixIcon: Icons.person_outline,
            ),
          ),
          const SizedBox(height: AmdsSpacing.md),
          AmdsButton(
              label: 'Save',
              onPressed: _fakeSubmit,
              loading: _loading,
              fullWidth: true,
              size: AmdsButtonSize.lg),

          const AmdsSectionHeader('Loading'),
          const AmdsFadeSlideIn(
            index: 3,
            child: AmdsSkeletonList(rows: 2),
          ),

          const AmdsSectionHeader('States'),
          AmdsFadeSlideIn(
            index: 4,
            child: SizedBox(
              height: 300,
              child: AmdsEmptyState(
                title: 'Nothing here yet',
                body: 'Add your first item to get started.',
                icon: Icons.inventory_2_outlined,
                actionLabel: 'Add item',
                onAction: () => AmdsDialogs.confirm(
                  context,
                  title: 'Add a demo item?',
                  body: 'This is just the confirm dialog pattern.',
                ),
              ),
            ),
          ),

          const SizedBox(height: AmdsSpacing.xl),
          AmdsButton(
            label: 'Open detail (shared-axis transition)',
            onPressed: _openDetail,
            variant: AmdsButtonVariant.secondary,
            fullWidth: true,
            trailingIcon: Icons.arrow_forward,
          ),
          const SizedBox(height: AmdsSpacing.xl),
        ],
      ),
    );
  }
}

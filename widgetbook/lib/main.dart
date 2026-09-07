// AMDS component gallery. Dependency-free (no widgetbook package) so it runs with
// just `flutter run`. Swap in the real `widgetbook` package later if you want
// knobs + a hosted catalog.

import 'package:amds_ui/amds_ui.dart';
import 'package:flutter/material.dart';

void main() => runApp(const GalleryApp());

class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});
  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  Brightness _b = Brightness.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AmdsTheme.light(),
      darkTheme: AmdsTheme.dark(),
      themeMode: _b == Brightness.light ? ThemeMode.light : ThemeMode.dark,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AMDS Gallery'),
          actions: [
            IconButton(
              icon: Icon(_b == Brightness.light
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined),
              onPressed: () => setState(() => _b =
                  _b == Brightness.light ? Brightness.dark : Brightness.light),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(AmdsSpacing.md),
          children: [
            _entry(
              'Button · variants',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final v in AmdsButtonVariant.values)
                    AmdsButton(label: v.name, onPressed: () {}, variant: v),
                ],
              ),
            ),
            _entry(
              'Button · sizes + states',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AmdsButton(
                      label: 'sm', onPressed: () {}, size: AmdsButtonSize.sm),
                  AmdsButton(label: 'md', onPressed: () {}),
                  AmdsButton(
                      label: 'lg', onPressed: () {}, size: AmdsButtonSize.lg),
                  const AmdsButton(label: 'disabled', onPressed: null),
                  const AmdsButton(
                      label: 'loading', onPressed: null, loading: true),
                ],
              ),
            ),
            _entry(
              'Status chips',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in AmdsStatusTone.values)
                    AmdsStatusChip(t.name, tone: t),
                ],
              ),
            ),
            _entry(
              'Avatar',
              const Row(
                children: [
                  AmdsAvatar(name: 'Priya Nair'),
                  SizedBox(width: 12),
                  AmdsAvatar(name: 'Sam Lee', size: AmdsSize.avatarLg),
                ],
              ),
            ),
            _entry(
                'Text field',
                const AmdsTextField(
                    label: 'Email',
                    required: true,
                    hint: 'you@company.example')),
            _entry('Password field',
                const AmdsPasswordField(label: 'Password', required: true)),
            _entry(
              'Card (interactive)',
              AmdsCard(
                onTap: () {},
                semanticLabel: 'Demo card',
                child: const Text('Tap me — 0.985 press-scale'),
              ),
            ),
            _entry(
                'Banner',
                const AmdsBanner(
                    message: 'Heads up — this is a banner.',
                    tone: AmdsStatusTone.warning)),
            _entry('Skeleton list',
                const SizedBox(height: 160, child: AmdsSkeletonList(rows: 2))),
            _entry(
                'Empty state',
                const SizedBox(
                    height: 220,
                    child: AmdsEmptyState(
                        title: 'No results', body: 'Try clearing filters.'))),
            _entry(
                'Error state',
                const SizedBox(
                    height: 240, child: AmdsErrorState(traceId: '8f3a-2b1c'))),
            _entry(
                'Animated count',
                AmdsAnimatedCount(9421,
                    style: Theme.of(context).textTheme.displaySmall)),
          ],
        ),
      ),
    );
  }

  Widget _entry(String title, Widget child) => Padding(
        padding: const EdgeInsets.only(bottom: AmdsSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AmdsSectionHeader(title),
            child,
          ],
        ),
      );
}

// Golden tests — every key component in light + dark. Text is blocked (Ahem)
// so goldens are platform-agnostic; see flutter_test_config.dart.
//
//   melos run test:golden      # regenerate baselines
//   flutter test test/golden_test.dart

import 'package:alchemist/alchemist.dart';
import 'package:amds_ui/amds_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps a component with the AMDS theme + a static-motion scope + a themed
/// background, for both brightnesses.
List<GoldenTestScenario> _bothThemes(
  String name,
  Widget child, {
  double width = 320,
}) =>
    [
      for (final b in Brightness.values)
        GoldenTestScenario(
          name: '$name · ${b.name}',
          child: _Frame(brightness: b, width: width, child: child),
        ),
    ];

class _Frame extends StatelessWidget {
  const _Frame({
    required this.brightness,
    required this.child,
    this.width = 320,
  });

  final Brightness brightness;
  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data:
          brightness == Brightness.light ? AmdsTheme.light() : AmdsTheme.dark(),
      child: AmdsMotionScope(
        settings: const AmdsMotionSettings(forceReduceMotion: true),
        child: Builder(
          builder: (context) => Container(
            width: width,
            color: context.amds.colors.background,
            padding: const EdgeInsets.all(AmdsSpacing.md),
            child: Material(
              type: MaterialType.transparency,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  group('Actions', () {
    goldenTest(
      'buttons',
      fileName: 'buttons',
      builder: () => GoldenTestGroup(
        columns: 2,
        children: _bothThemes(
          'variants',
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final v in AmdsButtonVariant.values)
                AmdsButton(label: v.name, onPressed: () {}, variant: v),
              const AmdsButton(label: 'disabled', onPressed: null),
            ],
          ),
        ),
      ),
    );
  });

  group('Inputs', () {
    goldenTest(
      'text fields',
      fileName: 'text_fields',
      builder: () => GoldenTestGroup(
        columns: 2,
        children: [
          ..._bothThemes(
            'default',
            const AmdsTextField(
                label: 'Email', required: true, hint: 'you@company.example'),
          ),
          ..._bothThemes(
            'error',
            const AmdsTextField(label: 'Email', error: 'Enter a valid email.'),
          ),
          ..._bothThemes(
            'password',
            const AmdsPasswordField(label: 'Password', required: true),
          ),
        ],
      ),
    );

    goldenTest(
      'selection controls',
      fileName: 'selection',
      builder: () => GoldenTestGroup(
        columns: 2,
        children: [
          ..._bothThemes(
            'checkbox tile',
            AmdsCheckboxTile(
                label: 'Email me updates', value: true, onChanged: (_) {}),
          ),
          ..._bothThemes(
            'radio group',
            AmdsRadioGroup<String>(
              groupValue: 'a',
              onChanged: (_) {},
              children: const [
                AmdsRadioTile(value: 'a', label: 'Standard'),
                AmdsRadioTile(value: 'b', label: 'Priority'),
              ],
            ),
          ),
          ..._bothThemes(
            'switch tile',
            AmdsSwitchTile(
                label: 'Offline mode', value: true, onChanged: (_) {}),
          ),
        ],
      ),
    );
  });

  group('Content', () {
    goldenTest(
      'status chips',
      fileName: 'status_chips',
      builder: () => GoldenTestGroup(
        columns: 2,
        children: _bothThemes(
          'tones',
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in AmdsStatusTone.values)
                AmdsStatusChip(t.name, tone: t),
            ],
          ),
        ),
      ),
    );

    goldenTest(
      'card + list item',
      fileName: 'containment',
      builder: () => GoldenTestGroup(
        columns: 2,
        children: [
          ..._bothThemes(
            'card',
            const AmdsCard(child: Text('A plain outlined card.')),
          ),
          ..._bothThemes(
            'list group',
            const AmdsListGroup(
              header: 'Preferences',
              children: [
                AmdsListItem(
                    title: 'Notifications',
                    leading: Icon(Icons.notifications_outlined),
                    trailing: Icon(Icons.chevron_right)),
                AmdsListItem(
                    title: 'Privacy',
                    leading: Icon(Icons.lock_outline),
                    trailing: Icon(Icons.chevron_right)),
              ],
            ),
          ),
          ..._bothThemes(
            'kpi card',
            const AmdsKpiCard(
              label: 'Open items',
              value: 1284,
              delta: '12%',
              trend: AmdsTrend.up,
              footnote: 'updated 2m ago',
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'timeline',
      fileName: 'timeline',
      builder: () => GoldenTestGroup(
        columns: 2,
        children: _bothThemes(
          'approval',
          const AmdsTimeline(tiles: [
            AmdsTimelineTile(title: 'Submitted', tone: AmdsStatusTone.success),
            AmdsTimelineTile(title: 'In review', current: true),
            AmdsTimelineTile(title: 'Disbursed'),
          ]),
        ),
      ),
    );
  });

  group('Feedback + states', () {
    goldenTest(
      'banner',
      fileName: 'banner',
      builder: () => GoldenTestGroup(
        columns: 2,
        children: _bothThemes(
          'warning',
          const AmdsBanner(
              message: 'Heads up — this is a banner.',
              tone: AmdsStatusTone.warning),
        ),
      ),
    );

    goldenTest(
      'empty + error',
      fileName: 'states',
      builder: () => GoldenTestGroup(
        columns: 2,
        children: [
          ..._bothThemes(
            'empty',
            const SizedBox(
              height: 260,
              child: AmdsEmptyState(
                  title: 'No results', body: 'Try clearing filters.'),
            ),
          ),
          ..._bothThemes(
            'error',
            const SizedBox(
              height: 280,
              child: AmdsErrorState(traceId: '8f3a-2b1c'),
            ),
          ),
        ],
      ),
    );
  });

  group('Data', () {
    goldenTest(
      'data table',
      fileName: 'data_table',
      builder: () => GoldenTestGroup(
        columns: 1,
        children: _bothThemes(
          'sortable + selectable',
          width: 520,
          AmdsDataTable<({String name, int amount})>(
            rows: const [
              (name: 'Compressor A-12', amount: 12400),
              (name: 'Pump Station 3', amount: 3120),
            ],
            keyOf: (r) => r.name,
            sortColumnIndex: 1,
            sortAscending: false,
            selected: const {'Compressor A-12'},
            onSelectionChanged: (_) {},
            onSort: (_, __) {},
            columns: [
              AmdsDataColumn(
                  label: 'Name', sortable: true, cell: (r) => Text(r.name)),
              AmdsDataColumn(
                  label: 'Amount',
                  numeric: true,
                  sortable: true,
                  cell: (r) => Text('${r.amount}')),
            ],
          ),
        ),
      ),
    );

    goldenTest(
      'sparkline',
      fileName: 'sparkline',
      builder: () => GoldenTestGroup(
        columns: 2,
        children: _bothThemes(
          'trend',
          const SizedBox(
            width: 160,
            height: 40,
            child: AmdsSparkline(values: [3, 5, 4, 7, 6, 9, 8, 12, 10, 14]),
          ),
        ),
      ),
    );
  });
}

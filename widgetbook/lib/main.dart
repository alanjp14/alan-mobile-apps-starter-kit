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
    return AmdsMotionScope(
      settings: const AmdsMotionSettings(),
      child: MaterialApp(
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
                onPressed: () => setState(() => _b = _b == Brightness.light
                    ? Brightness.dark
                    : Brightness.light),
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
              _entry(
                  'Skeleton list',
                  const SizedBox(
                      height: 160, child: AmdsSkeletonList(rows: 2))),
              _entry(
                  'Empty state',
                  const SizedBox(
                      height: 220,
                      child: AmdsEmptyState(
                          title: 'No results', body: 'Try clearing filters.'))),
              _entry(
                  'Error state',
                  const SizedBox(
                      height: 240,
                      child: AmdsErrorState(traceId: '8f3a-2b1c'))),
              _entry(
                  'Animated count',
                  AmdsAnimatedCount(9421,
                      style: Theme.of(context).textTheme.displaySmall)),
              _entry(
                'KPI card',
                const AmdsKpiCard(
                  label: 'Open items',
                  value: 1284,
                  delta: '12%',
                  trend: AmdsTrend.up,
                  footnote: 'updated 2m ago',
                  icon: Icons.inventory_2_outlined,
                ),
              ),
              _entry(
                'Stat row',
                const Row(
                  children: [
                    Expanded(
                        child: AmdsStat(
                            label: 'Approved',
                            value: 92,
                            delta: '4%',
                            trend: AmdsTrend.up)),
                    Expanded(
                        child: AmdsStat(
                            label: 'Rejected',
                            value: 7,
                            delta: '2%',
                            trend: AmdsTrend.down)),
                  ],
                ),
              ),
              _entry(
                'List group',
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
              const _SelectionDemo(),
              const _ChipsDemo(),
              const _SegmentedDemo(),
              const _SearchDemo(),
              _entry(
                'Accordion',
                const AmdsAccordion(
                  title: 'Shipping details',
                  subtitle: 'Tap to expand',
                  child:
                      Text('Ships in 2–3 business days via standard courier.'),
                ),
              ),
              _entry(
                'Dropdown',
                const _DropdownDemo(),
              ),
              _entry('Progress',
                  const AmdsProgressBar(value: 0.6, label: 'Upload')),
              _entry(
                'Sparkline',
                const AmdsCard(
                  child: SizedBox(
                    height: 40,
                    child: AmdsSparkline(
                        values: [3, 5, 4, 7, 6, 9, 8, 12, 10, 14]),
                  ),
                ),
              ),
              _entry(
                'Chart container',
                const AmdsChartContainer(
                  title: 'Revenue',
                  subtitle: 'Last 30 days',
                  legend: AmdsLegend(items: [
                    AmdsLegendItem(label: 'This month', color: Colors.green),
                    AmdsLegendItem(label: 'Last month', color: Colors.grey),
                  ]),
                  child: Center(child: Text('‹ your chart widget ›')),
                ),
              ),
              _entry(
                'Timeline',
                const AmdsTimeline(tiles: [
                  AmdsTimelineTile(
                      title: 'Request submitted',
                      subtitle: 'by [USER_NAME]',
                      timestamp: 'Mon 09:12',
                      tone: AmdsStatusTone.success),
                  AmdsTimelineTile(
                      title: 'Manager approved',
                      timestamp: 'Mon 14:03',
                      tone: AmdsStatusTone.success),
                  AmdsTimelineTile(
                      title: 'Finance review',
                      subtitle: 'Waiting on [ROLE_NAME]',
                      current: true),
                  AmdsTimelineTile(title: 'Disbursed'),
                ]),
              ),
              _entry(
                'Breadcrumb',
                AmdsBreadcrumb(crumbs: [
                  AmdsCrumb('Home', onTap: () {}),
                  AmdsCrumb('Sites', onTap: () {}),
                  AmdsCrumb('Plant 4', onTap: () {}),
                  const AmdsCrumb('Compressor A-12'),
                ]),
              ),
              const _DataTableDemo(),
              const _PickersDemo(),
              const _PaginationDemo(),
              _entry(
                'Tooltip / info dot',
                Row(
                  children: [
                    Text('Annual recurring revenue',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(width: 4),
                    const AmdsInfoDot(
                      title: 'ARR',
                      body: 'Normalised yearly value of active subscriptions.',
                    ),
                  ],
                ),
              ),
              _entry(
                'Bottom sheet',
                Builder(
                  builder: (context) => AmdsButton(
                    label: 'Open actions sheet',
                    variant: AmdsButtonVariant.secondary,
                    onPressed: () => AmdsBottomSheet.actions<String>(
                      context,
                      title: 'Item actions',
                      actions: const [
                        AmdsSheetAction(
                            label: 'Share', value: 'share', icon: Icons.share),
                        AmdsSheetAction(
                            label: 'Delete',
                            value: 'delete',
                            icon: Icons.delete_outline,
                            destructive: true),
                      ],
                    ),
                  ),
                ),
              ),
              _entry(
                'Motion · route transitions',
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in AmdsTransition.values)
                      AmdsButton(
                        label: t.name,
                        variant: AmdsButtonVariant.secondary,
                        onPressed: () => Navigator.of(context).push(
                          AmdsPageRoute<void>(
                            transition: t,
                            builder: (_) => _DemoPage(t.name),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _entry(
                'Motion · staggered entrance',
                AmdsStagger(
                  spacing: 8,
                  children: [
                    for (var i = 0; i < 4; i++)
                      AmdsCard(child: Text('Row ${i + 1}')),
                  ],
                ),
              ),
              const _ShakeDemo(),
              _entry(
                'Motion · pulse',
                const Row(
                  children: [
                    AmdsPulse(
                      child:
                          AmdsStatusChip('LIVE', tone: AmdsStatusTone.danger),
                    ),
                  ],
                ),
              ),
              const _SwitcherDemo(),
            ],
          ),
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

class _DemoPage extends StatelessWidget {
  const _DemoPage(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(label)),
        body: Center(
          child: AmdsButton(
            label: 'Back',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
}

class _ShakeDemo extends StatefulWidget {
  const _ShakeDemo();
  @override
  State<_ShakeDemo> createState() => _ShakeDemoState();
}

class _ShakeDemoState extends State<_ShakeDemo> {
  int _n = 0;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AmdsSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AmdsSectionHeader('Motion · shake (invalid input)'),
            Row(
              children: [
                Expanded(
                  child: AmdsShake(
                    trigger: _n,
                    child: const AmdsTextField(label: 'Code', hint: '6 digits'),
                  ),
                ),
                const SizedBox(width: AmdsSpacing.md),
                AmdsButton(
                    label: 'Reject', onPressed: () => setState(() => _n++)),
              ],
            ),
          ],
        ),
      );
}

class _SwitcherDemo extends StatefulWidget {
  const _SwitcherDemo();
  @override
  State<_SwitcherDemo> createState() => _SwitcherDemoState();
}

class _SwitcherDemoState extends State<_SwitcherDemo> {
  bool _loading = true;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AmdsSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AmdsSectionHeader('Motion · content swap'),
            AmdsButton(
              label: _loading ? 'Show data' : 'Show loading',
              variant: AmdsButtonVariant.tertiary,
              onPressed: () => setState(() => _loading = !_loading),
            ),
            const SizedBox(height: AmdsSpacing.sm),
            AmdsSwitcher(
              child: _loading
                  ? const SizedBox(
                      key: ValueKey('l'),
                      height: 72,
                      child: AmdsSkeletonList(rows: 1),
                    )
                  : const AmdsCard(
                      key: ValueKey('d'),
                      child: Text('Loaded content'),
                    ),
            ),
          ],
        ),
      );
}

Widget _section(String title, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: AmdsSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [AmdsSectionHeader(title), child],
      ),
    );

class _SelectionDemo extends StatefulWidget {
  const _SelectionDemo();
  @override
  State<_SelectionDemo> createState() => _SelectionDemoState();
}

class _SelectionDemoState extends State<_SelectionDemo> {
  bool _check = true;
  bool _switch = false;
  String _radio = 'a';
  double _slider = 0.4;

  @override
  Widget build(BuildContext context) => _section(
        'Selection controls',
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AmdsCheckboxTile(
              label: 'Email me updates',
              value: _check,
              onChanged: (v) => setState(() => _check = v ?? false),
            ),
            AmdsSwitchTile(
              label: 'Offline mode',
              value: _switch,
              onChanged: (v) => setState(() => _switch = v),
            ),
            AmdsRadioGroup<String>(
              groupValue: _radio,
              onChanged: (v) => setState(() => _radio = v ?? 'a'),
              children: const [
                AmdsRadioTile(value: 'a', label: 'Standard'),
                AmdsRadioTile(value: 'b', label: 'Priority'),
              ],
            ),
            AmdsSlider(
              label: 'Budget',
              value: _slider,
              valueLabel: (v) => '${(v * 100).round()}%',
              onChanged: (v) => setState(() => _slider = v),
            ),
          ],
        ),
      );
}

class _ChipsDemo extends StatefulWidget {
  const _ChipsDemo();
  @override
  State<_ChipsDemo> createState() => _ChipsDemoState();
}

class _ChipsDemoState extends State<_ChipsDemo> {
  Set<String> _filters = {'Open'};
  String? _choice = 'All';

  @override
  Widget build(BuildContext context) => _section(
        'Chips',
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AmdsFilterChips<String>(
              options: const ['Open', 'In progress', 'Done'],
              selected: _filters,
              labelOf: (s) => s,
              onChanged: (next) => setState(() => _filters = next),
            ),
            const SizedBox(height: AmdsSpacing.sm),
            AmdsChoiceChips<String>(
              options: const ['All', 'Mine', 'Team'],
              value: _choice,
              labelOf: (s) => s,
              onChanged: (v) => setState(() => _choice = v),
            ),
          ],
        ),
      );
}

class _SegmentedDemo extends StatefulWidget {
  const _SegmentedDemo();
  @override
  State<_SegmentedDemo> createState() => _SegmentedDemoState();
}

class _SegmentedDemoState extends State<_SegmentedDemo> {
  String _view = 'List';
  @override
  Widget build(BuildContext context) => _section(
        'Segmented control',
        AmdsSegmentedControl<String>(
          segments: const ['List', 'Board', 'Calendar'],
          value: _view,
          onChanged: (v) => setState(() => _view = v),
        ),
      );
}

class _SearchDemo extends StatefulWidget {
  const _SearchDemo();
  @override
  State<_SearchDemo> createState() => _SearchDemoState();
}

class _SearchDemoState extends State<_SearchDemo> {
  String _q = '';
  @override
  Widget build(BuildContext context) => _section(
        'Search bar',
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AmdsSearchBar(onChanged: (q) => setState(() => _q = q)),
            const SizedBox(height: AmdsSpacing.xs),
            Text('query: "$_q"', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
}

class _DropdownDemo extends StatefulWidget {
  const _DropdownDemo();
  @override
  State<_DropdownDemo> createState() => _DropdownDemoState();
}

class _DropdownDemoState extends State<_DropdownDemo> {
  String? _role;
  @override
  Widget build(BuildContext context) => AmdsDropdown<String>(
        value: _role,
        items: const ['Admin', 'Editor', 'Viewer'],
        labelOf: (s) => s,
        onChanged: (v) => setState(() => _role = v),
      );
}

class _DataTableDemo extends StatefulWidget {
  const _DataTableDemo();
  @override
  State<_DataTableDemo> createState() => _DataTableDemoState();
}

class _AssetRow {
  const _AssetRow(this.id, this.name, this.owner, this.amount);
  final String id;
  final String name;
  final String owner;
  final int amount;
}

class _DataTableDemoState extends State<_DataTableDemo> {
  final _rows = <_AssetRow>[
    const _AssetRow('a1', 'Compressor A-12', 'P. Nair', 12400),
    const _AssetRow('a2', 'Pump Station 3', 'S. Adeyemi', 3120),
    const _AssetRow('a3', 'Conveyor Belt 7', 'M. Chen', 8730),
  ];
  int _sortCol = 3;
  bool _asc = false;
  Set<Object> _selected = {};

  @override
  Widget build(BuildContext context) {
    final sorted = [..._rows]..sort((a, b) {
        final cmp = switch (_sortCol) {
          0 => a.name.compareTo(b.name),
          3 => a.amount.compareTo(b.amount),
          _ => 0,
        };
        return _asc ? cmp : -cmp;
      });
    return _section(
      'Data table',
      SizedBox(
        height: 220,
        child: AmdsDataTable<_AssetRow>(
          rows: sorted,
          keyOf: (r) => r.id,
          rowIdentifier: (r) => r.name,
          sortColumnIndex: _sortCol,
          sortAscending: _asc,
          selected: _selected,
          onSelectionChanged: (s) => setState(() => _selected = s),
          onSort: (i, asc) => setState(() {
            _sortCol = i;
            _asc = asc;
          }),
          onRowTap: (_) {},
          columns: [
            AmdsDataColumn(
                label: 'Name', sortable: true, cell: (r) => Text(r.name)),
            AmdsDataColumn(
                label: 'Owner', minWidth: 110, cell: (r) => Text(r.owner)),
            AmdsDataColumn(
                label: 'Status',
                minWidth: 120,
                cell: (_) => const AmdsStatusChip('Active',
                    tone: AmdsStatusTone.success)),
            AmdsDataColumn(
                label: 'Amount',
                numeric: true,
                sortable: true,
                cell: (r) => Text('${r.amount}')),
          ],
        ),
      ),
    );
  }
}

class _PickersDemo extends StatefulWidget {
  const _PickersDemo();
  @override
  State<_PickersDemo> createState() => _PickersDemoState();
}

class _PickersDemoState extends State<_PickersDemo> {
  DateTime? _date;
  TimeOfDay? _time;
  @override
  Widget build(BuildContext context) => _section(
        'Date / time fields',
        Column(
          children: [
            AmdsDateField(
                value: _date, onChanged: (d) => setState(() => _date = d)),
            const SizedBox(height: AmdsSpacing.md),
            AmdsTimeField(
                value: _time, onChanged: (t) => setState(() => _time = t)),
          ],
        ),
      );
}

class _PaginationDemo extends StatefulWidget {
  const _PaginationDemo();
  @override
  State<_PaginationDemo> createState() => _PaginationDemoState();
}

class _PaginationDemoState extends State<_PaginationDemo> {
  int _page = 1;
  @override
  Widget build(BuildContext context) => _section(
        'Pagination',
        AmdsPagination(
          page: _page,
          pageCount: 9,
          totalItems: 210,
          pageSize: 25,
          onPageChanged: (p) => setState(() => _page = p),
        ),
      );
}

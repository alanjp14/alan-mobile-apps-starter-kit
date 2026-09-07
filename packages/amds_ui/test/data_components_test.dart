import 'package:amds_ui/amds_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
      theme: AmdsTheme.light(),
      home: Scaffold(body: child),
    );

class _Row {
  const _Row(this.id, this.name, this.amount);
  final String id;
  final String name;
  final int amount;
}

void main() {
  const rows = [
    _Row('a', 'Compressor A-12', 12400),
    _Row('b', 'Pump Station 3', 3120),
  ];

  List<AmdsDataColumn<_Row>> columns() => [
        AmdsDataColumn(
            label: 'Name', cell: (r) => Text(r.name), sortable: true),
        AmdsDataColumn(
            label: 'Amount', numeric: true, cell: (r) => Text('${r.amount}')),
      ];

  testWidgets('AmdsDataTable renders rows and fires sort + row tap',
      (tester) async {
    _Row? tapped;
    int? sortCol;
    await tester.pumpWidget(_host(AmdsDataTable<_Row>(
      columns: columns(),
      rows: rows,
      keyOf: (r) => r.id,
      sortColumnIndex: 0,
      onSort: (i, asc) => sortCol = i,
      onRowTap: (r) => tapped = r,
    )));
    expect(find.text('Compressor A-12'), findsOneWidget);
    expect(find.text('3120'), findsOneWidget);

    await tester.tap(find.text('NAME'));
    expect(sortCol, 0);

    await tester.tap(find.text('Pump Station 3'));
    expect(tapped?.id, 'b');
  });

  testWidgets('AmdsDataTable selection column toggles rows', (tester) async {
    var selected = <Object>{};
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => _host(AmdsDataTable<_Row>(
          columns: columns(),
          rows: rows,
          keyOf: (r) => r.id,
          rowIdentifier: (r) => r.name,
          selected: selected,
          onSelectionChanged: (s) => setState(() => selected = s),
        )),
      ),
    );
    await tester.tap(find.byType(Checkbox).at(1)); // first data row
    await tester.pumpAndSettle();
    expect(selected, {'a'});
  });

  testWidgets('AmdsSparkline paints without error for valid data',
      (tester) async {
    await tester.pumpWidget(_host(
      const SizedBox(width: 120, child: AmdsSparkline(values: [1, 3, 2, 5, 4])),
    ));
    expect(tester.takeException(), isNull);
  });

  testWidgets('AmdsChartContainer swaps in the empty state', (tester) async {
    await tester.pumpWidget(_host(const AmdsChartContainer(
      title: 'Revenue',
      status: AmdsChartStatus.empty,
      child: SizedBox(),
    )));
    expect(find.text('No data for this range'), findsOneWidget);
  });

  testWidgets('AmdsTimeline renders a node per tile', (tester) async {
    await tester.pumpWidget(_host(const SingleChildScrollView(
      child: AmdsTimeline(tiles: [
        AmdsTimelineTile(title: 'Submitted', timestamp: 'Mon'),
        AmdsTimelineTile(title: 'Approved', tone: AmdsStatusTone.success),
        AmdsTimelineTile(title: 'In review', current: true),
      ]),
    )));
    expect(find.text('Submitted'), findsOneWidget);
    expect(find.text('In review'), findsOneWidget);
  });

  testWidgets('AmdsBreadcrumb collapses the middle past maxVisible',
      (tester) async {
    await tester.pumpWidget(_host(AmdsBreadcrumb(
      maxVisible: 3,
      crumbs: [
        AmdsCrumb('Home', onTap: () {}),
        AmdsCrumb('Sites', onTap: () {}),
        AmdsCrumb('Plant 4', onTap: () {}),
        const AmdsCrumb('Compressor A-12'),
      ],
    )));
    expect(find.text('Sites'), findsNothing); // hidden behind the "…" menu
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Compressor A-12'), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz), findsOneWidget);
  });

  testWidgets('AmdsDateField opens the picker and reports a date',
      (tester) async {
    DateTime? picked;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => _host(AmdsDateField(
          value: DateTime(2026, 9, 7),
          onChanged: (d) => setState(() => picked = d),
        )),
      ),
    );
    expect(find.text('2026-09-07'), findsOneWidget);
    await tester.tap(find.text('2026-09-07'));
    await tester.pumpAndSettle();
    // Material date picker is open
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(picked, isNotNull);
  });

  testWidgets('AmdsPagination moves pages and clamps the ends', (tester) async {
    var page = 1;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => _host(Align(
          child: AmdsPagination(
            page: page,
            pageCount: 9,
            totalItems: 210,
            pageSize: 25,
            onPageChanged: (p) => setState(() => page = p),
          ),
        )),
      ),
    );
    expect(find.text('1–25 of 210'), findsOneWidget);
    await tester.tap(find.byTooltip('Next page'));
    await tester.pumpAndSettle();
    expect(page, 2);
    await tester.tap(find.text('9'));
    await tester.pumpAndSettle();
    expect(page, 9);
  });

  testWidgets('AmdsLoadMoreFooter shows the count and end state',
      (tester) async {
    await tester.pumpWidget(_host(AmdsLoadMoreFooter(
      loaded: 40,
      total: 210,
      onLoadMore: () {},
    )));
    expect(find.text('Showing 40 of 210'), findsOneWidget);
    expect(find.text('Load more'), findsOneWidget);
  });

  testWidgets('AmdsInfoDot exposes an accessible button', (tester) async {
    await tester.pumpWidget(_host(const AmdsInfoDot(
      title: 'ARR',
      body: 'Annual recurring revenue.',
    )));
    expect(find.bySemanticsLabel('About ARR'), findsOneWidget);
  });
}

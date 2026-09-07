import 'package:amds_ui/amds_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {ThemeMode mode = ThemeMode.light}) => MaterialApp(
      theme: AmdsTheme.light(),
      darkTheme: AmdsTheme.dark(),
      themeMode: mode,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  testWidgets('AmdsTextField validator drives Form.validate + errorText',
      (tester) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(_host(Form(
      key: formKey,
      child: AmdsTextField(
        label: 'Email',
        validator: (v) => v.contains('@') ? null : 'Enter a valid email.',
      ),
    )));

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Enter a valid email.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'a@b.co');
    expect(formKey.currentState!.validate(), isTrue);
    await tester.pump();
    expect(find.text('Enter a valid email.'), findsNothing);
  });

  testWidgets('AmdsListItem fires onTap and exposes a button', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_host(AmdsListItem(
      title: 'Row',
      subtitle: 'sub',
      onTap: () => taps++,
      semanticLabel: 'Open row',
    )));
    await tester.tap(find.text('Row'));
    expect(taps, 1);
    expect(find.bySemanticsLabel('Open row'), findsOneWidget);
  });

  testWidgets('AmdsCheckboxTile toggles from the row', (tester) async {
    var value = false;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => _host(AmdsCheckboxTile(
          label: 'Accept',
          value: value,
          onChanged: (v) => setState(() => value = v ?? false),
        )),
      ),
    );
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    expect(value, isTrue);
  });

  testWidgets('AmdsRadioGroup selects an option', (tester) async {
    String? picked = 'a';
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => _host(
          AmdsRadioGroup<String>(
            groupValue: picked,
            onChanged: (v) => setState(() => picked = v),
            children: const [
              AmdsRadioTile(value: 'a', label: 'Option A'),
              AmdsRadioTile(value: 'b', label: 'Option B'),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Option B'));
    await tester.pumpAndSettle();
    expect(picked, 'b');
  });

  testWidgets('AmdsFilterChips adds and removes from the set', (tester) async {
    var selected = <String>{'x'};
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => _host(AmdsFilterChips<String>(
          options: const ['x', 'y'],
          selected: selected,
          labelOf: (s) => s.toUpperCase(),
          onChanged: (next) => setState(() => selected = next),
        )),
      ),
    );
    await tester.tap(find.widgetWithText(RawChip, 'Y'));
    await tester.pumpAndSettle();
    expect(selected, {'x', 'y'});
    await tester.tap(find.widgetWithText(RawChip, 'X'));
    await tester.pumpAndSettle();
    expect(selected, {'y'});
  });

  testWidgets('AmdsSegmentedControl switches value', (tester) async {
    var value = 'list';
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => _host(AmdsSegmentedControl<String>(
          segments: const ['list', 'grid'],
          value: value,
          onChanged: (v) => setState(() => value = v),
        )),
      ),
    );
    await tester.tap(find.text('grid'));
    await tester.pumpAndSettle();
    expect(value, 'grid');
  });

  testWidgets('AmdsSearchBar debounces then emits, clear button resets',
      (tester) async {
    final emitted = <String>[];
    await tester.pumpWidget(_host(AmdsSearchBar(
      debounce: const Duration(milliseconds: 100),
      onChanged: emitted.add,
    )));
    await tester.enterText(find.byType(TextField), 'ab');
    expect(emitted, isEmpty); // still within debounce
    await tester.pump(const Duration(milliseconds: 150));
    expect(emitted, ['ab']);

    await tester.tap(find.byTooltip('Clear'));
    await tester.pump();
    expect(emitted.last, '');
  });

  testWidgets('AmdsKpiCard renders label and animated value', (tester) async {
    await tester.pumpWidget(_host(const AmdsKpiCard(
      label: 'Open items',
      value: 1284,
      delta: '12%',
      trend: AmdsTrend.up,
    )));
    await tester.pumpAndSettle();
    expect(find.text('OPEN ITEMS'), findsOneWidget);
    expect(find.text('1284'), findsOneWidget);
  });

  testWidgets('AmdsAccordion expands and collapses', (tester) async {
    var expanded = false;
    await tester.pumpWidget(_host(AmdsAccordion(
      title: 'More info',
      onExpansionChanged: (v) => expanded = v,
      child: const Text('hidden detail'),
    )));
    // collapsed: detail present in tree but sized to zero by AnimatedCrossFade
    await tester.tap(find.text('More info'));
    await tester.pumpAndSettle();
    expect(expanded, isTrue);
    expect(
      tester.getSize(find.text('hidden detail')).height,
      greaterThan(0),
    );
    await tester.tap(find.text('More info'));
    await tester.pumpAndSettle();
    expect(expanded, isFalse);
  });

  testWidgets('AmdsBottomSheet.actions returns the chosen value',
      (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(_host(Builder(builder: (c) {
      ctx = c;
      return const SizedBox(height: 10);
    })));
    final future = AmdsBottomSheet.actions<String>(
      ctx,
      title: 'Choose',
      actions: const [
        AmdsSheetAction(label: 'First', value: 'first'),
        AmdsSheetAction(label: 'Second', value: 'second'),
      ],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Second'));
    await tester.pumpAndSettle();
    expect(await future, 'second');
  });

  testWidgets('AmdsLoadingOverlay blocks input while busy', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_host(SizedBox(
      height: 200,
      child: AmdsLoadingOverlay(
        busy: true,
        child: Center(
          child: AmdsButton(label: 'Behind', onPressed: () => taps++),
        ),
      ),
    )));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text('Behind'), warnIfMissed: false);
    expect(taps, 0);
  });

  testWidgets('AmdsDropdown reports selection', (tester) async {
    String? value;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => _host(AmdsDropdown<String>(
          label: 'Role',
          value: value,
          items: const ['Admin', 'Viewer'],
          labelOf: (s) => s,
          onChanged: (v) => setState(() => value = v),
        )),
      ),
    );
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Viewer').last);
    await tester.pumpAndSettle();
    expect(value, 'Viewer');
  });
}

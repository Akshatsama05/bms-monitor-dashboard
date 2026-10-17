import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../lib/app.dart';
import '../lib/services/bms_dashboard_provider.dart';

void main() {
  testWidgets(
    'navigation opens each dashboard section and remains responsive on mobile',
    (tester) async {
      final model = BmsDashboardProvider(startClock: false, refreshDemo: false);
      addTearDown(model.dispose);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.binding.setSurfaceSize(const Size(1280, 760));
      await tester.pumpWidget(
        ChangeNotifierProvider<BmsDashboardProvider>.value(
          value: model,
          child: const BmsMonitorApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('STATE OF CHARGE'), findsOneWidget);
      expect(find.text('CONNECTED • DEMO'), findsOneWidget);
      expect(find.textContaining('Last sync '), findsOneWidget);
      expect(find.text('Discharging'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);

      await tester.tap(find.text('Faults'));
      await tester.pumpAndSettle();
      expect(find.text('Faults & alerts'), findsOneWidget);

      await tester.tap(find.text('Trends'));
      await tester.pumpAndSettle();
      expect(find.text('TELEMETRY HISTORY'), findsOneWidget);
      final sixHourChip = find.widgetWithText(ChoiceChip, '6H');
      await tester.tap(sixHourChip);
      await tester.pumpAndSettle();
      expect(model.trendRange, '6H');
      expect(tester.widget<ChoiceChip>(sixHourChip).selected, isTrue);

      await tester.tap(find.text('Cells'));
      await tester.pumpAndSettle();
      expect(find.text('CELL MONITORING'), findsOneWidget);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('PREFERENCES'), findsOneWidget);

      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pump();
      model.selectTab(0);
      await tester.pumpAndSettle();
      expect(find.text('STATE OF CHARGE'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('settings can display a simulated warning in the Faults view', (
    tester,
  ) async {
    final model = BmsDashboardProvider(startClock: false, refreshDemo: false);
    addTearDown(model.dispose);

    await tester.binding.setSurfaceSize(const Size(1280, 760));
    await tester.pumpWidget(
      ChangeNotifierProvider<BmsDashboardProvider>.value(
        value: model,
        child: const BmsMonitorApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Faults'));
    await tester.pumpAndSettle();
    expect(find.text('Temperature variance warning'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

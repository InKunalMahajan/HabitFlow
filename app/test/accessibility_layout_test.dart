import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:habitflow/main.dart';

void main() {
  Future<void> openTab(WidgetTester tester, IconData icon) async {
    await tester.tap(find.byIcon(icon).first);
    await tester.pumpAndSettle();
  }

  testWidgets('compact navigation shows all four destinations', (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const HabitFlowApp());
    expect(find.byType(NavigationBar), findsOneWidget);
    for (final label in ['Today', 'Planner', 'Goals', 'Insights']) {
      expect(find.widgetWithText(NavigationDestination, label), findsOneWidget);
    }
    await openTab(tester, Icons.flag_outlined);
    expect(find.text('Create goal'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide navigation uses a rail and not a bottom bar', (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const HabitFlowApp());
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('task controls have text tooltips and progress semantics', (tester) async {
    await tester.pumpWidget(const HabitFlowApp());
    final handle = tester.ensureSemantics();
    expect(find.byTooltip('Edit Plan tomorrow'), findsOneWidget);
    expect(find.byTooltip('Delete Plan tomorrow'), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) =>
          widget is Semantics && widget.properties.label == 'Daily progress'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('large text retains navigation and primary action', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: const HabitFlowApp(),
      ),
    );
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byTooltip('Add a task or habit'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

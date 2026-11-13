import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/main.dart';

void main() {
  testWidgets('accessibility labels include progress and task actions', (tester) async {
    await tester.pumpWidget(const HabitFlowApp());
    final semantics = tester.ensureSemantics();
    expect(find.byTooltip('Edit Plan tomorrow'), findsOneWidget);
    expect(find.byTooltip('Delete Plan tomorrow'), findsOneWidget);
    expect(find.byWidgetPredicate((widget) =>
        widget is Semantics && widget.properties.label == 'Daily progress'),
        findsOneWidget);
    semantics.dispose();
  });

  testWidgets('Insights shows saved-data progress summaries', (tester) async {
    await tester.pumpWidget(const HabitFlowApp());
    await tester.tap(find.byIcon(Icons.insights_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('Habit activity — last 7 days'), findsOneWidget);
    expect(find.text('0 of 2 completed'), findsOneWidget);
    expect(find.text('0 of 0 reached'), findsOneWidget);
  });

  testWidgets('Insights offers habit history editing', (tester) async {
    await tester.pumpWidget(const HabitFlowApp());
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Habit').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('entry-name')), 'Stretch');
    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();
    expect(find.text('Stretch'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.insights_outlined).first);
    await tester.pumpAndSettle();
    // Insights uses a lazily built ListView; the history action is below
    // the initial viewport on smaller screens.
    await tester.scrollUntilVisible(
      find.text('Edit history'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Stretch'), findsOneWidget);
    expect(find.text('Edit history'), findsOneWidget);
    await tester.tap(find.text('Edit history'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a habit history date'), findsOneWidget);
  });

  testWidgets('shows Today dashboard and progress', (tester) async {
    await tester.pumpWidget(const HabitFlowApp());
    expect(find.text('Daily progress'), findsOneWidget);
    expect(find.text('0 of 2 tasks complete'), findsOneWidget);
    expect(find.text('Review today’s priorities'), findsOneWidget);
  });

  testWidgets('task completion updates progress', (tester) async {
    await tester.pumpWidget(const HabitFlowApp());
    await tester.tap(find.byType(CheckboxListTile).first);
    await tester.pump();
    expect(find.text('1 of 2 tasks complete'), findsOneWidget);
  });

  testWidgets('navigation switches to Planner', (tester) async {
    await tester.pumpWidget(const HabitFlowApp());
    await tester.tap(find.byIcon(Icons.calendar_month_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('Schedule tasks by day. Edit a task to choose its date.'),
        findsOneWidget);
  });

  testWidgets('goals tab shows create goal action', (tester) async {
    await tester.pumpWidget(const HabitFlowApp());
    await tester.tap(find.byIcon(Icons.flag_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('Create goal'), findsOneWidget);
    await tester.tap(find.text('Create goal'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Goal name'), 'Read books');
    await tester.tap(find.text('Create goal').last);
    await tester.pumpAndSettle();
    expect(find.text('Read books'), findsOneWidget);
    expect(find.text('0 of 10 complete'), findsOneWidget);
  });

  testWidgets('quick add creates a task', (tester) async {
    await tester.pumpWidget(const HabitFlowApp());
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('entry-name')), 'Read a book');
    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();
    expect(find.text('Read a book'), findsOneWidget);
    expect(find.text('0 of 3 tasks complete'), findsOneWidget);
  });

  testWidgets('habit can be added and checked', (tester) async {
    await tester.pumpWidget(const HabitFlowApp());
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Habit').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('entry-name')), 'Drink water');
    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();
    expect(find.text('Drink water'), findsOneWidget);
    expect(find.text('Daily habit'), findsOneWidget);
  });

  testWidgets('edit and delete task with confirmation', (tester) async {
    await tester.pumpWidget(const HabitFlowApp());
    await tester.tap(find.byTooltip('Edit Plan tomorrow'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('entry-name')), 'Plan next week');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.text('Plan next week'), findsOneWidget);
    await tester.tap(find.byTooltip('Delete Plan next week'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Plan next week'), findsNothing);
    expect(find.text('0 of 1 tasks complete'), findsOneWidget);
  });
}

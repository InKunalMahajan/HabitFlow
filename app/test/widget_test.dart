import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/main.dart';

void main() {
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
    expect(find.text('Daily habit · session only'), findsOneWidget);
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

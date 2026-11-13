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
    expect(find.text('This feature is planned for a future phase.'),
        findsOneWidget);
  });

  testWidgets('quick add creates a session task', (tester) async {
    await tester.pumpWidget(const HabitFlowApp());
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Read a book');
    await tester.tap(find.text('Add task'));
    await tester.pumpAndSettle();
    expect(find.text('Read a book'), findsOneWidget);
    expect(find.text('0 of 3 tasks complete'), findsOneWidget);
  });
}

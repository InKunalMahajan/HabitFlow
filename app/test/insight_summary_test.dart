import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/entries/entry_store.dart';
import 'package:habitflow/features/insights/insight_summary.dart';

void main() {
  test('empty data returns zero rates', () {
    final summary = InsightSummary.calculate(
      entries: const [],
      goals: const [],
      now: DateTime(2026, 11, 14),
    );
    expect(summary.taskRate, 0);
    expect(summary.habitRateToday, 0);
    expect(summary.goalRate, 0);
  });

  test('counts tasks, recent habit dates and completed goals', () {
    final summary = InsightSummary.calculate(
      now: DateTime(2026, 11, 14),
      entries: [
        const FlowEntry(id: 1, title: 'Task', kind: EntryKind.task, completed: true),
        const FlowEntry(id: 2, title: 'Task 2', kind: EntryKind.task),
        const FlowEntry(
          id: 3, title: 'Habit', kind: EntryKind.habit,
          completedDates: {'2026-11-14', '2026-11-12', '2026-11-01'},
        ),
      ],
      goals: [
        {'id': 1, 'title': 'Goal', 'target': 5, 'progress': 5},
        {'id': 2, 'title': 'Goal 2', 'target': 10, 'progress': 2},
      ],
    );
    expect(summary.taskRate, 0.5);
    expect(summary.habitsDoneToday, 1);
    expect(summary.habitCompletionsLast7Days, 2);
    expect(summary.goalsCompleted, 1);
  });
}

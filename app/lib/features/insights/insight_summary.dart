import '../entries/entry_store.dart';

/// Derived on-device statistics. No network access or new database tables.
class InsightSummary {
  const InsightSummary({
    required this.taskTotal,
    required this.tasksCompleted,
    required this.habitTotal,
    required this.habitsDoneToday,
    required this.habitCompletionsLast7Days,
    required this.goalTotal,
    required this.goalsCompleted,
  });

  final int taskTotal;
  final int tasksCompleted;
  final int habitTotal;
  final int habitsDoneToday;
  final int habitCompletionsLast7Days;
  final int goalTotal;
  final int goalsCompleted;

  double get taskRate => taskTotal == 0 ? 0 : tasksCompleted / taskTotal;
  double get habitRateToday => habitTotal == 0 ? 0 : habitsDoneToday / habitTotal;
  double get goalRate => goalTotal == 0 ? 0 : goalsCompleted / goalTotal;

  factory InsightSummary.calculate({
    required Iterable<FlowEntry> entries,
    required Iterable<Map<String, Object?>> goals,
    required DateTime now,
  }) {
    final tasks = entries.where((e) => e.kind == EntryKind.task).toList();
    final habits = entries.where((e) => e.kind == EntryKind.habit).toList();
    final today = DateTime(now.year, now.month, now.day);
    final days = List.generate(7, (i) => dateKey(today.subtract(Duration(days: i)))).toSet();
    final goalList = goals.toList();
    return InsightSummary(
      taskTotal: tasks.length,
      tasksCompleted: tasks.where((e) => e.completed).length,
      habitTotal: habits.length,
      habitsDoneToday: habits.where((e) => e.completedDates.contains(dateKey(today))).length,
      habitCompletionsLast7Days: habits.fold(0, (sum, e) => sum + e.completedDates.intersection(days).length),
      goalTotal: goalList.length,
      goalsCompleted: goalList.where((g) => (g['progress'] as int) >= (g['target'] as int)).length,
    );
  }
}

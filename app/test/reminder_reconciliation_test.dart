import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/entries/entry_store.dart';
import 'package:habitflow/features/reminders/reminder_reconciliation.dart';
import 'package:habitflow/features/reminders/reminder_settings.dart';

void main() {
  test('keeps active habit reminders and identifies orphaned reminders', () {
    final store = EntryStore();
    final habit = store.add('Read', EntryKind.habit);
    final task = store.add('Send email', EntryKind.task);
    final plan = ReminderReconciliation.plan(store.items, {
      habit.id: ReminderSettings(habitId: habit.id, hour: 9, minute: 0),
      task.id: ReminderSettings(habitId: task.id, hour: 10, minute: 0),
      999: const ReminderSettings(habitId: 999, hour: 11, minute: 0),
    });
    expect(plan.active.keys, contains(habit.id));
    expect(plan.active.keys, isNot(contains(task.id)));
    expect(plan.orphanedHabitIds, containsAll([task.id, 999]));
  });

  test('disabled reminder is not scheduled but is not orphaned', () {
    final store = EntryStore();
    final habit = store.add('Stretch', EntryKind.habit);
    final plan = ReminderReconciliation.plan(store.items, {
      habit.id: ReminderSettings(
        habitId: habit.id, hour: 7, minute: 30, enabled: false,
      ),
    });
    expect(plan.active, isEmpty);
    expect(plan.orphanedHabitIds, isEmpty);
  });

  test('empty habits leave no active reminders', () {
    final plan = ReminderReconciliation.plan(const <FlowEntry>[], {
      1: const ReminderSettings(habitId: 1, hour: 8, minute: 0),
    });
    expect(plan.active, isEmpty);
    expect(plan.orphanedHabitIds, {1});
  });
}

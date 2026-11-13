import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/backup/habitflow_backup.dart';
import 'package:habitflow/features/entries/entry_store.dart';
import 'package:habitflow/features/reminders/reminder_settings.dart';

void main() {
  HabitFlowBackup sample() => HabitFlowBackup(
    entries: [
      const FlowEntry(id: 1, title: 'Read', kind: EntryKind.task,
          completed: true, scheduledDay: '2026-11-20'),
      const FlowEntry(id: 2, title: 'Walk', kind: EntryKind.habit,
          completedDates: {'2026-11-12', '2026-11-13'}),
    ],
    goals: [
      {'id': 4, 'title': 'Books', 'target': 10, 'progress': 3},
    ],
    reminders: {
      2: const ReminderSettings(habitId: 2, hour: 9, minute: 30),
    },
  );

  test('backup round trip retains entries, goals, history and reminders', () {
    final restored = HabitFlowBackup.decode(sample().encode());
    expect(restored.entries, hasLength(2));
    expect(restored.entries.first.scheduledDay, '2026-11-20');
    expect(restored.entries.last.completedDates, {'2026-11-12', '2026-11-13'});
    expect(restored.goals.single['progress'], 3);
    expect(restored.reminders[2]!.timeLabel, '09:30');
  });

  test('rejects unsupported backup versions', () {
    final source = sample().encode().replaceFirst('"version":1', '"version":999');
    expect(() => HabitFlowBackup.decode(source), throwsFormatException);
  });

  test('rejects duplicate entry IDs', () {
    final source = sample().encode().replaceFirst('"id":2', '"id":1');
    expect(() => HabitFlowBackup.decode(source), throwsFormatException);
  });

  test('rejects invalid calendar dates', () {
    final source = sample().encode().replaceFirst('2026-11-20', '2026-02-30');
    expect(() => HabitFlowBackup.decode(source), throwsFormatException);
  });

  test('rejects orphaned reminders', () {
    final source = sample().encode().replaceFirst('"habit_id":2', '"habit_id":999');
    expect(() => HabitFlowBackup.decode(source), throwsFormatException);
  });

  test('rejects malformed JSON and missing sections', () {
    expect(() => HabitFlowBackup.decode('{broken'), throwsFormatException);
    expect(
      () => HabitFlowBackup.decode('{"format":"habitflow-backup","version":1}'),
      throwsFormatException,
    );
  });

  test('rejects oversized backups', () {
    expect(
      () => HabitFlowBackup.decode(' ' * (HabitFlowBackup.maxBytes + 1)),
      throwsFormatException,
    );
  });
}

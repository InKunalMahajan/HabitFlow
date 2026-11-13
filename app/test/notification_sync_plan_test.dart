import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/entries/entry_store.dart';
import 'package:habitflow/features/reminders/notification_sync_plan.dart';
import 'package:habitflow/features/reminders/reminder_settings.dart';

void main() {
  const enabled = ReminderSettings(habitId: 1, hour: 9, minute: 0);
  const disabled = ReminderSettings(
    habitId: 2, hour: 10, minute: 0, enabled: false,
  );
  const orphan = ReminderSettings(habitId: 99, hour: 11, minute: 0);

  final entries = <FlowEntry>[
    const FlowEntry(id: 1, title: 'Read', kind: EntryKind.habit),
    const FlowEntry(id: 2, title: 'Walk', kind: EntryKind.habit),
    const FlowEntry(id: 3, title: 'Email', kind: EntryKind.task),
  ];

  test('permission granted: schedule valid habits and cancel stale IDs', () {
    final plan = NotificationSyncPlan.build(
      entries: entries,
      saved: {1: enabled, 2: disabled, 99: orphan},
      pendingIds: {1, 2, 99, 300},
      permissionGranted: true,
    );
    expect(plan.toSchedule.keys, {1});
    expect(plan.toCancel, {2, 99, 300});
  });

  test('permission denied: no schedules and cancel existing pending IDs', () {
    final plan = NotificationSyncPlan.build(
      entries: entries,
      saved: {1: enabled},
      pendingIds: {1, 4},
      permissionGranted: false,
    );
    expect(plan.toSchedule, isEmpty);
    expect(plan.toCancel, {1, 4});
  });

  test('deleted habit and task preferences are never scheduled', () {
    final plan = NotificationSyncPlan.build(
      entries: entries,
      saved: {
        3: const ReminderSettings(habitId: 3, hour: 8, minute: 0),
        99: orphan,
      },
      pendingIds: {3, 99},
      permissionGranted: true,
    );
    expect(plan.toSchedule, isEmpty);
    expect(plan.toCancel, {3, 99});
  });

  test('mismatched reminder ID is rejected', () {
    final plan = NotificationSyncPlan.build(
      entries: entries,
      saved: {1: const ReminderSettings(habitId: 7, hour: 8, minute: 0)},
      pendingIds: {1},
      permissionGranted: true,
    );
    expect(plan.toSchedule, isEmpty);
    expect(plan.toCancel, {1});
  });

  test('no pending notifications still schedules enabled reminders', () {
    final plan = NotificationSyncPlan.build(
      entries: entries,
      saved: {1: enabled},
      pendingIds: <int>{},
      permissionGranted: true,
    );
    expect(plan.toSchedule.keys, {1});
    expect(plan.toCancel, isEmpty);
  });
}

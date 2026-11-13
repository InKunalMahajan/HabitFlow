import '../entries/entry_store.dart';
import 'reminder_settings.dart';

/// Immutable commands to reconcile desired reminders with device schedules.
/// Only valid, enabled habit preferences should be scheduled.
class NotificationSyncPlan {
  const NotificationSyncPlan({
    required this.toSchedule,
    required this.toCancel,
  });

  final Map<int, ReminderSettings> toSchedule;
  final Set<int> toCancel;

  static NotificationSyncPlan build({
    required Iterable<FlowEntry> entries,
    required Map<int, ReminderSettings> saved,
    required Iterable<int> pendingIds,
    required bool permissionGranted,
  }) {
    final habits = {
      for (final entry in entries)
        if (entry.kind == EntryKind.habit) entry.id: entry,
    };
    final desired = <int, ReminderSettings>{
      if (permissionGranted)
        for (final entry in saved.entries)
          if (habits.containsKey(entry.key) &&
              entry.value.enabled &&
              entry.value.habitId == entry.key)
            entry.key: entry.value,
    };
    return NotificationSyncPlan(
      toSchedule: desired,
      toCancel: {
        for (final id in pendingIds)
          if (!desired.containsKey(id)) id,
      },
    );
  }
}

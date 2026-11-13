import '../entries/entry_store.dart';
import 'reminder_settings.dart';

/// A deterministic plan for reconciling saved habit reminders with habits.
/// Pure Dart: no OS permissions or notification plugin required.
class ReminderReconciliation {
  const ReminderReconciliation({
    required this.active,
    required this.orphanedHabitIds,
  });

  final Map<int, ReminderSettings> active;
  final Set<int> orphanedHabitIds;

  static ReminderReconciliation plan(
    Iterable<FlowEntry> entries,
    Map<int, ReminderSettings> saved,
  ) {
    final habitIds = entries
        .where((entry) => entry.kind == EntryKind.habit)
        .map((entry) => entry.id)
        .toSet();
    return ReminderReconciliation(
      active: {
        for (final item in saved.entries)
          if (habitIds.contains(item.key) && item.value.enabled)
            item.key: item.value,
      },
      orphanedHabitIds: {
        for (final id in saved.keys)
          if (!habitIds.contains(id)) id,
      },
    );
  }
}

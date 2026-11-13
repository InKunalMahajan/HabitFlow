import 'reminder_settings.dart';

/// Pure local scheduling rules for daily reminder times.
/// Does not request permissions or schedule an OS notification.
class ReminderSchedule {
  const ReminderSchedule._();

  static DateTime nextOccurrence(ReminderSettings setting, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final candidate = DateTime(
      today.year, today.month, today.day, setting.hour, setting.minute,
    );
    if (candidate.isAfter(now)) return candidate;
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    return DateTime(
      tomorrow.year, tomorrow.month, tomorrow.day, setting.hour, setting.minute,
    );
  }

  static List<ReminderOccurrence> upcoming(
    Iterable<ReminderSettings> settings,
    DateTime now,
  ) {
    final result = <ReminderOccurrence>[];
    for (final setting in settings) {
      if (!setting.enabled) continue;
      result.add(ReminderOccurrence(
        habitId: setting.habitId,
        at: nextOccurrence(setting, now),
      ));
    }
    result.sort((a, b) {
      final order = a.at.compareTo(b.at);
      return order != 0 ? order : a.habitId.compareTo(b.habitId);
    });
    return result;
  }
}

class ReminderOccurrence {
  const ReminderOccurrence({required this.habitId, required this.at});
  final int habitId;
  final DateTime at;
}

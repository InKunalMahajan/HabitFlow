import 'dart:convert';

import '../entries/entry_store.dart';
import '../reminders/reminder_settings.dart';

/// Portable, offline backup document. Parsing never modifies device storage.
class HabitFlowBackup {
  const HabitFlowBackup({
    required this.entries,
    required this.goals,
    required this.reminders,
  });

  static const format = 'habitflow-backup';
  static const version = 1;
  static const maxBytes = 5 * 1024 * 1024;
  final List<FlowEntry> entries;
  final List<Map<String, Object?>> goals;
  final Map<int, ReminderSettings> reminders;

  String encode() => jsonEncode({
    'format': format,
    'version': version,
    'entries': [
      for (final e in entries)
        {
          'id': e.id, 'title': e.title, 'kind': e.kind.name,
          'completed': e.completed, 'scheduledDay': e.scheduledDay,
          'completedDates': e.completedDates.toList()..sort(),
        },
    ],
    'goals': goals,
    'reminders': [for (final r in reminders.values) r.toRow()],
  });

  static HabitFlowBackup decode(String source) {
    if (utf8.encode(source).length > maxBytes) {
      throw const FormatException('Backup is too large.');
    }
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic> ||
        decoded['format'] != format || decoded['version'] != version) {
      throw const FormatException('Unsupported HabitFlow backup.');
    }
    final rawEntries = decoded['entries'];
    final rawGoals = decoded['goals'];
    final rawReminders = decoded['reminders'];
    if (rawEntries is! List || rawGoals is! List || rawReminders is! List) {
      throw const FormatException('Missing backup sections.');
    }
    if (rawEntries.length > 10000 || rawGoals.length > 10000 ||
        rawReminders.length > 10000) {
      throw const FormatException('Backup contains too many records.');
    }
    final entries = <FlowEntry>[];
    final ids = <int>{};
    for (final raw in rawEntries) {
      if (raw is! Map<String, dynamic>) {
        throw const FormatException('Invalid entry.');
      }
      final id = raw['id'];
      final title = raw['title'];
      final kind = raw['kind'];
      final completed = raw['completed'];
      final scheduledDay = raw['scheduledDay'];
      final dates = raw['completedDates'];
      if (id is! int || id < 1 || !ids.add(id) ||
          title is! String || title.trim().isEmpty || title.length > 120 ||
          (kind != 'task' && kind != 'habit') || completed is! bool ||
          (scheduledDay != null && (scheduledDay is! String ||
              !_validDate(scheduledDay))) ||
          dates is! List || dates.length > 36600 ||
          dates.any((d) => d is! String || !_validDate(d)) ||
          dates.toSet().length != dates.length) {
        throw const FormatException('Invalid or duplicate entry.');
      }
      if (kind == 'task' && dates.isNotEmpty) {
        throw const FormatException('Task cannot contain habit history.');
      }
      if (kind == 'habit' && scheduledDay != null) {
        throw const FormatException('Habit cannot have a task schedule.');
      }
      entries.add(FlowEntry(
        id: id, title: title, kind: kind == 'habit' ? EntryKind.habit : EntryKind.task,
        completed: completed, scheduledDay: scheduledDay,
        completedDates: dates.cast<String>().toSet(),
      ));
    }
    final goals = <Map<String, Object?>>[];
    final goalIds = <int>{};
    for (final raw in rawGoals) {
      if (raw is! Map<String, dynamic>) {
        throw const FormatException('Invalid goal.');
      }
      final id = raw['id'];
      final title = raw['title'];
      final target = raw['target'];
      final progress = raw['progress'];
      if (id is! int || id < 1 || !goalIds.add(id) ||
          title is! String || title.trim().isEmpty || title.length > 120 ||
          target is! int || target <= 0 || progress is! int || progress < 0) {
        throw const FormatException('Invalid or duplicate goal.');
      }
      goals.add({'id': id, 'title': title, 'target': target, 'progress': progress});
    }
    final reminders = <int, ReminderSettings>{};
    final habitIds = entries.where((e) => e.kind == EntryKind.habit)
        .map((e) => e.id).toSet();
    for (final raw in rawReminders) {
      if (raw is! Map<String, dynamic>) {
        throw const FormatException('Invalid reminder.');
      }
      final row = <String, Object?>{...raw};
      final reminder = ReminderSettings.fromRow(row);
      if (reminder == null || !habitIds.contains(reminder.habitId) ||
          reminders.containsKey(reminder.habitId) ||
          (row['enabled'] != 0 && row['enabled'] != 1)) {
        throw const FormatException('Invalid or orphaned reminder.');
      }
      reminders[reminder.habitId] = reminder;
    }
    return HabitFlowBackup(entries: entries, goals: goals, reminders: reminders);
  }

  static bool _validDate(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) return false;
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    if (year < 1 || month < 1 || month > 12 || day < 1 || day > 31) return false;
    final parsed = DateTime.utc(year, month, day);
    return parsed.year == year && parsed.month == month && parsed.day == day;
  }
}

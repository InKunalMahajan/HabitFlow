/// Validated, device-local daily reminder preferences.
/// This phase stores times only; notification delivery is not enabled.
class ReminderSettings {
  const ReminderSettings({required this.habitId, required this.hour, required this.minute, this.enabled = true});
  final int habitId;
  final int hour;
  final int minute;
  final bool enabled;

  String get timeLabel => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  static ReminderSettings? fromRow(Map<String, Object?> row) {
    final id = row['habit_id'];
    final hour = row['hour'];
    final minute = row['minute'];
    final enabled = row['enabled'];
    if (id is! int || hour is! int || minute is! int ||
        hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }
    return ReminderSettings(habitId: id, hour: hour, minute: minute, enabled: enabled == 1);
  }

  Map<String, Object?> toRow() => {
    'habit_id': habitId, 'hour': hour, 'minute': minute, 'enabled': enabled ? 1 : 0,
  };
}

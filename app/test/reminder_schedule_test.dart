import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/reminders/reminder_schedule.dart';
import 'package:habitflow/features/reminders/reminder_settings.dart';

void main() {
  const morning = ReminderSettings(habitId: 1, hour: 9, minute: 30);
  test('next reminder today if time has not passed', () {
    expect(
      ReminderSchedule.nextOccurrence(morning, DateTime(2026, 11, 14, 8)),
      DateTime(2026, 11, 14, 9, 30),
    );
  });

  test('next reminder tomorrow if time has passed or is now', () {
    expect(
      ReminderSchedule.nextOccurrence(morning, DateTime(2026, 11, 14, 9, 30)),
      DateTime(2026, 11, 15, 9, 30),
    );
    expect(
      ReminderSchedule.nextOccurrence(morning, DateTime(2026, 11, 14, 23, 59)),
      DateTime(2026, 11, 15, 9, 30),
    );
  });

  test('next reminder crosses month and year boundaries', () {
    expect(
      ReminderSchedule.nextOccurrence(morning, DateTime(2026, 12, 31, 23)),
      DateTime(2027, 1, 1, 9, 30),
    );
  });

  test('disabled reminders are omitted and remaining reminders sorted', () {
    final result = ReminderSchedule.upcoming([
      morning,
      const ReminderSettings(habitId: 2, hour: 7, minute: 0),
      const ReminderSettings(habitId: 3, hour: 6, minute: 0, enabled: false),
    ], DateTime(2026, 11, 14, 6));
    expect(result.map((e) => e.habitId).toList(), [2, 1]);
  });
}

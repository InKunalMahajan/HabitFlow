import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/reminders/reminder_settings.dart';

void main() {
  test('reminder preferences round-trip through SQLite row shape', () {
    const setting = ReminderSettings(habitId: 12, hour: 7, minute: 5);
    final restored = ReminderSettings.fromRow(setting.toRow());
    expect(restored?.habitId, 12);
    expect(restored?.timeLabel, '07:05');
    expect(restored?.enabled, isTrue);
  });

  test('invalid reminder time is rejected', () {
    expect(ReminderSettings.fromRow({
      'habit_id': 1, 'hour': 25, 'minute': 0, 'enabled': 1,
    }), isNull);
    expect(ReminderSettings.fromRow({
      'habit_id': 1, 'hour': 9, 'minute': -1, 'enabled': 1,
    }), isNull);
  });
}

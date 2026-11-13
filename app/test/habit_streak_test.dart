import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/insights/habit_streak.dart';

void main() {
  final now = DateTime(2026, 11, 14);

  test('empty history has zero streaks and empty week', () {
    final result = HabitStreak.fromDates({}, now);
    expect(result.current, 0);
    expect(result.longest, 0);
    expect(result.last7Days, everyElement(false));
  });

  test('today and yesterday continue the current streak', () {
    final result = HabitStreak.fromDates({
      '2026-11-14', '2026-11-13', '2026-11-12', '2026-11-08',
    }, now);
    expect(result.current, 3);
    expect(result.longest, 3);
    expect(result.last7Days, [true, false, false, false, true, true, true]);
  });

  test('yesterday streak stays active until today ends', () {
    final result = HabitStreak.fromDates({
      '2026-11-13', '2026-11-12', '2026-11-11',
    }, now);
    expect(result.current, 3);
    expect(result.longest, 3);
  });

  test('older streak is longest but not current', () {
    final result = HabitStreak.fromDates({
      '2026-11-01', '2026-11-02', '2026-11-03', '2026-11-04',
      '2026-11-14',
    }, now);
    expect(result.current, 1);
    expect(result.longest, 4);
  });

  test('future dates do not increase streaks', () {
    final result = HabitStreak.fromDates({'2026-11-15'}, now);
    expect(result.current, 0);
    expect(result.longest, 0);
  });
}

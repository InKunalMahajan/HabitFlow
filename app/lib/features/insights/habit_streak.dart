import '../entries/entry_store.dart';

/// Calendar-day streaks based on persisted habit completion dates.
class HabitStreak {
  const HabitStreak({required this.current, required this.longest, required this.last7Days});
  final int current;
  final int longest;
  /// Oldest to newest; one value per local calendar day.
  final List<bool> last7Days;

  factory HabitStreak.fromDates(Set<String> completedDates, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final todayKey = dateKey(today);
    final yesterday = today.subtract(const Duration(days: 1));
    // A streak completed yesterday remains active until the end of today.
    var cursor = completedDates.contains(todayKey) ? today : yesterday;
    var current = 0;
    while (completedDates.contains(dateKey(cursor))) {
      current++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    final validDays = <DateTime>[];
    for (final key in completedDates) {
      final day = DateTime.tryParse(key);
      if (day != null && dateKey(day) == key && !day.isAfter(today)) {
        validDays.add(DateTime.utc(day.year, day.month, day.day));
      }
    }
    validDays.sort();
    var longest = 0;
    var run = 0;
    DateTime? previous;
    for (final day in validDays) {
      if (previous != null && day.difference(previous).inDays == 1) {
        run++;
      } else {
        run = 1;
      }
      if (run > longest) longest = run;
      previous = day;
    }
    return HabitStreak(
      current: current,
      longest: longest,
      last7Days: List.generate(7, (index) {
        final day = today.subtract(Duration(days: 6 - index));
        return completedDates.contains(dateKey(day));
      }),
    );
  }
}

# Phase 03I — Habit Streaks & Weekly Activity

## Implemented
- Insights displays each habit's current streak and longest streak.
- Seven labeled daily chips show the previous six days plus today; checked and unchecked icons convey status without color alone.
- Screen-reader semantics identify the calendar date and completion status.
- Current streak ends today or yesterday. A habit completed yesterday still has an active streak today.
- Longest streak is computed from historical dates up to today; future dates are excluded.
- Unit tests cover empty data, gaps, current/longest streaks, seven-day boundaries, and future dates.
- Existing SQLite v2 completion records are reused. **No migration**.

## Verification — not yet run
The code was committed to GitHub but Flutter analysis, tests, iPhone and Android behavior have not been independently verified.

Before pulling, inspect `git status`; keep uncommitted iOS project files safe. If Git blocks the pull, do not force/reset.

```bash
cd ~/HabitFlow
git status
git pull --ff-only origin main
cd app
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run -d 00008110-000C586901E3801E
```

## Manual acceptance
1. Open Insights and confirm the Habit streaks section appears.
2. Mark a habit complete today; its current streak and today's chip update.
3. Uncheck it; today's chip and streak update.
4. Inspect seven calendar-day chips and check their date labels.
5. Close and reopen the app; verify the values persist.
6. Test larger text, VoiceOver and TalkBack. Repeat on Android.

## Limitations
- Streaks are daily only; no weekly/custom habit frequency or freeze days.
- No reminders, notifications, cloud backup or sync.
- The local date is used; changing device timezone may change the interpretation of daily streaks.

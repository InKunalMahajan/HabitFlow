# Phase 03K — Habit Reminder Preferences

## Implemented in GitHub
- Set a daily reminder time for each habit using a native time picker in Insights → Habit streaks.
- Show saved time in 24-hour HH:mm format; clear the setting.
- Save and reload settings in SQLite v3, with an upgrade path from v1/v2.
- Preserve reminder settings during existing entry snapshot saves.
- Unit tests for valid and invalid reminder settings.

## Important limitation
**This phase does not schedule or deliver device notifications.** No notification permission request, notification plugin, background task or OS-level alarm has been added. Saved times are preferences only. Real notifications need a later implementation and device permission tests.

## Verification pending
No Flutter analysis, tests or device verification has been performed by the assistant. Preserve uncommitted files, especially app/ios, before pulling.

```bash
cd ~/HabitFlow
git status
# If local changes block pulling, stop and protect them first.
git pull --ff-only origin main
cd app
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run -d 00008110-000C586901E3801E
```

## Acceptance checks
1. Existing v2 database upgrades to v3 without losing tasks, goals, habits or history.
2. Set a habit reminder time; verify the displayed time.
3. Restart the app and verify the time remains.
4. Complete/uncomplete a habit; verify reminder setting is not erased.
5. Clear the reminder; verify it stays cleared after restart.
6. Test date/time picker accessibility and large text.
7. Confirm no OS notifications are expected yet.

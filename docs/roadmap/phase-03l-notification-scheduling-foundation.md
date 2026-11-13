# Phase 03L — Notification Scheduling Foundation

## Implemented
- Pure Dart daily scheduling rules for the next occurrence of a saved reminder.
- The Insights habit card shows the next calculated local date and time.
- Enabled reminder preferences can be sorted into an upcoming schedule.
- Tests cover same-day, exact-time, next-day, year-end, disabled settings and sorting.
- Reuses SQLite v3 reminder preferences. No new database migration or dependency.

## Not implemented
**No iOS or Android notification is scheduled or delivered.** No OS permission requests, background notifications, device-specific timezone handling, or notification plugins are included. This is a preview and calculation foundation, not a notification delivery feature.

## Verification pending
Flutter analyzer, tests, and real-device behavior have not been independently run for Phase 03L. Preserve uncommitted changes including `app/ios/` before pulling.

```bash
cd ~/HabitFlow
git status
# Stop and protect local changes if they would block a pull.
git pull --ff-only origin main
cd app
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run -d 00008110-000C586901E3801E
```

## Acceptance checks
1. Set a reminder time later today and confirm next reminder preview shows today.
2. Set an earlier time and confirm the preview shows tomorrow.
3. Restart the app and confirm the time is retained.
4. Clear the reminder and confirm the preview disappears.
5. Confirm no phone notification is expected at the displayed time.
6. Verify VoiceOver/TalkBack reading and large-text layout.

## Next phase
Implement native notification permission and scheduling with an explicit supported plugin, correct timezone configuration, OS platform setup, cancellation on habit deletion, and physical iPhone/Android tests.

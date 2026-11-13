# Audit Fix 03 — Notification Reliability

## Implemented
- Added a pure Dart notification sync plan and five unit tests.
- At startup, the app compares saved enabled habit reminders with pending device notifications.
- Removes stale pending notifications for deleted or disabled habits, and clears pending notifications when permission is denied.
- Schedules only enabled reminders for existing habits with matching IDs when permission is granted.
- Scheduling is additionally guarded by a permission check inside the notification service.
- Does not change the SQLite schema or request permissions automatically at startup.

## Important limits
- The current app uses this notification plugin only for habit reminders. If other notification categories are introduced, pending IDs must be filtered by category/channel instead of cancelling all unmatched IDs.
- Native delivery is **not** verified by unit tests. iOS native project is untracked in GitHub and requires local review.
- Android delivery can be inexact; test reboot, timezone changes, app restart, denied permissions, habit deletion, habit rename, and notification settings.
- This does not add cloud sync or backups.
- GitHub CI and Mac/device results must be checked before marking complete.

## Safe Mac verification
```bash
cd ~/Downloads/HabitFlow
git status
git stash list
# If tracked changes are present, save them before pulling:
git stash push -m "Backup before Audit Fix 03"
git pull --ff-only origin main
cd app
flutter pub get
flutter analyze
flutter test test/notification_sync_plan_test.dart
flutter test
```

Do not delete `app/ios/`, use `git reset --hard`, run `git clean -fd`, or pop your existing stashes.

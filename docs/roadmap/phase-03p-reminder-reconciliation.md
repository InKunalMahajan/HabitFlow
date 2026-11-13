# Phase 03P — Reminder Reconciliation & Release Audit

## Implemented
- Pure Dart reconciliation model identifies active, disabled, and orphaned habit reminder preferences.
- On startup, the app attempts to cancel and remove orphaned reminder settings before restoring active reminders.
- Three unit tests cover valid habits, task/orphan IDs, disabled settings, and empty habit lists.
- No database schema migration or new package.

## Important limitations
- **No Flutter tests or physical-device builds were run by the assistant.** This phase is code-committed, not verified.
- Startup cleanup can only identify orphaned IDs still present in SQLite. It does not inspect every pending OS notification.
- Notification delivery, iOS AppDelegate integration, plugin API compatibility, Android reboot behavior and timezone changes remain release blockers.
- The local `app/ios/` folder may contain essential signing configuration; do not delete it.
- If native notification cancellation fails, startup reports an error; verify on device.

## Mac verification
```bash
cd ~/HabitFlow
git status
# Protect local changes, especially app/ios, before pulling.
git pull --ff-only origin main
cd app
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run -d 00008110-000C586901E3801E
```

## Acceptance checklist
1. All reminder reconciliation unit tests pass.
2. Existing habits and saved reminder times survive app restart.
3. Deleting a habit cancels its scheduled notification.
4. Changing notification permission does not crash the app.
5. Renaming a habit updates its notification text.
6. Real notifications arrive on locked iPhone and Android devices.
7. VoiceOver, TalkBack, large text and silent delivery are checked.
8. Android and iOS release builds compile successfully.

**Do not publish until all release blockers have been addressed and verified.**

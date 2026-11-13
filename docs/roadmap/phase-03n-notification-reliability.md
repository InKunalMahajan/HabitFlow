# Phase 03N — Notification Reliability & Settings

## Changes
- Before restoring notifications at app startup, inspect the current OS notification permission instead of blindly scheduling.
- When deleting a habit with a reminder, remove the in-memory reminder setting and cancel its pending device notification.
- Preserve existing reminder-time persistence and local-first behavior.

## Limitations and release blockers
- **Not verified**: Flutter compilation, notification plugin API compatibility, iPhone/Android notification delivery, timezone changes, or reboot behavior.
- iOS native project is not committed to GitHub. Review AppDelegate and plugin setup locally; never delete `app/ios/`.
- Android notification timing is inexact and subject to battery restrictions.
- Deleting a habit updates local data first; if OS cancellation fails, an error is displayed and the user should check device notifications.
- Changing habit title may leave previously scheduled notification body stale until the app reopens. Verify and fix before release.
- Notification permission can be changed in system Settings. A saved reminder is not proof that permission is enabled.

## Mac verification
```bash
cd ~/HabitFlow
git status
# Protect uncommitted files, especially app/ios, before pulling.
git pull --ff-only origin main
cd app
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run -d 00008110-000C586901E3801E
```

If Git refuses to pull, stop and protect local work; never use destructive reset or clean.

## Acceptance checks
1. Create a habit and schedule a reminder; allow notifications.
2. Restart the app and confirm the reminder is not duplicated.
3. Delete the habit and verify the pending notification is canceled.
4. Deny notification permission and restart; app remains usable.
5. Enable permission in device Settings and test a newly saved reminder.
6. Clear reminder and verify cancellation.
7. Repeat on Android; test after reboot, timezone change, and with large text/VoiceOver/TalkBack.

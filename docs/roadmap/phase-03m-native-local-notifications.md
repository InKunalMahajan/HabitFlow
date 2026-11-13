# Phase 03M — Native Local Notifications (device verification required)

## Code added
- `flutter_local_notifications` 21, `flutter_timezone` and `timezone` dependencies.
- iOS/Android notification service, permission request when setting a reminder, recurring daily notification scheduling and cancellation when clearing a reminder.
- Android POST_NOTIFICATIONS / RECEIVE_BOOT_COMPLETED permissions, receiver declarations, compileSdk 36 and desugaring.
- Silent notification content: habit title and text, no required audio.
- Re-schedule saved preferences on app startup.

## Critical verification and limitations
**This code has not been built or tested on physical devices.** Flutter package versions, native Android Gradle configuration, iOS delegate configuration, permission behavior and notification delivery must be validated before release.

The iOS project is not tracked in GitHub (your local `app/ios/` is important). On your Mac, follow the plugin's current iOS documentation to set `UNUserNotificationCenter.current().delegate = self` in `ios/Runner/AppDelegate.swift` without replacing your existing app delegate. Confirm iOS deployment target >= 13. Do not delete the iOS folder.

Android uses `inexactAllowWhileIdle`; delivery may be delayed by OS battery policy. Reminder preview shows a calculated time, not a delivery guarantee. Changing device timezone requires verification. If a habit is deleted, its pending notification may remain until explicitly canceled; this must be addressed before release.

## Local commands
```bash
cd ~/HabitFlow
git status
# Protect uncommitted changes and app/ios before pulling.
git pull --ff-only origin main
cd app
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run -d 00008110-000C586901E3801E
```

If the pull is blocked, stop and protect your changes; never use force reset or clean on the iOS folder.

## Acceptance checklist
1. Build succeeds on real iPhone and Android.
2. Create a habit and set a reminder two minutes ahead; grant permission.
3. Lock device and verify a text notification arrives (Android may be inexact).
4. Change reminder time; confirm only one notification remains scheduled.
5. Clear reminder and verify no further notification arrives.
6. Deny permission; app remains usable and shows a meaningful message.
7. Restart phone; confirm daily notifications continue.
8. Verify no sound required; VoiceOver and TalkBack read notification text.
9. Verify reminder deletion and timezone changes do not leave stale notifications.

## References
- https://pub.dev/packages/flutter_local_notifications
- https://pub.dev/packages/flutter_timezone

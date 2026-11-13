# Phase 03O — Notification Settings and Rename Synchronization

## Implemented
- Added a **Check notification permission** button on Insights. It reads OS permission status and shows a text message in a SnackBar.
- Renaming a habit with a saved reminder attempts to reschedule its daily notification using the new title, provided permission is currently granted.
- Existing SQLite v3 reminder settings remain unchanged. No new migration or package is required.
- Updated master roadmap to distinguish native scheduling code from verified notification delivery.

## Known limitations
- **No build or device verification has been performed for this phase.** iOS/Android notification delivery remains unverified.
- Android scheduled delivery may be inexact.
- iOS native project is local and must be configured on your Mac.
- Existing notification code may have platform/plugin API compatibility issues; resolve analyzer errors before running the app.
- Permission status does not guarantee a scheduled notification will be delivered.

## Verify on Mac
```bash
cd ~/HabitFlow
git status
# Protect uncommitted changes, especially app/ios, before pulling.
git pull --ff-only origin main
cd app
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run -d 00008110-000C586901E3801E
```

## Device checks
1. Open Insights and tap Check notification permission.
2. Grant or deny permission in phone settings; return and check status again.
3. Create a habit, set a reminder, then rename the habit.
4. Verify a future notification uses the updated habit title.
5. Clear and delete reminders and confirm no stale notifications.
6. Restart the app, then test notification delivery on a locked iPhone and Android phone.
7. Test text scaling, VoiceOver and TalkBack.

**Do not mark Phase 03O device verified until these checks pass.**

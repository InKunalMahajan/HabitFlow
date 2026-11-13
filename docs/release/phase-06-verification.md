# Phase 06 — Release Verification and Device Acceptance

**Status:** CI Android debug build added; physical-device and signed release checks pending.

## Automated checks
- Flutter analyzer and full widget/unit test suite.
- Android debug APK build on Ubuntu CI with JDK 17.
- No signing keys or passwords are stored in GitHub.

## Android device acceptance
1. Install the debug APK on an Android test device.
2. Create a task, habit, goal, and reminder; restart the app.
3. Confirm SQLite data and habit history persist.
4. Test notifications with permission allowed and denied.
5. Test 150% and 200% font size, light/dark mode, TalkBack, landscape, and smaller screen.
6. Test deleting habits cancels pending notifications.
7. Confirm application ID and version code before Play Console setup.

## iPhone acceptance
The iOS project is currently local/untracked; do not delete or regenerate `app/ios/`.
1. Build/run on the existing iPhone.
2. Confirm local data persists after app restart and an app update.
3. Verify VoiceOver, Dynamic Type, light/dark appearance and notifications.
4. Confirm Apple bundle ID, signing team, deployment target, AppDelegate notification setup.
5. Do not upload to TestFlight until a signed release build and privacy review are complete.

## Release gate
Do not publish until CI passes, Android signed AAB and iOS signed IPA are built, device acceptance is recorded, and privacy/store requirements are satisfied.

## Safe Mac commands
```bash
cd ~/Downloads/HabitFlow
git status
git stash list
# If tracked changes exist:
git stash push -m "Backup before Phase 06"
git pull --ff-only origin main
cd app
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
flutter devices
```

If `git pull` reports an overwrite conflict, stop and share the output. Never run `git reset --hard`, `git clean -fd`, or `git stash pop`.

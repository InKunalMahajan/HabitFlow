# Audit Fix 05 — Production Release Preparation

**Status: release blocked until verification and signing.** This phase does not publish an app.

## Android signing
Debug signing is removed from release builds. Release tasks require a private `app/android/key.properties` file and a keystore. Both are ignored by Git.

1. Create a private upload keystore locally (store it securely and back it up outside Git):
   ```bash
   cd ~/Downloads/HabitFlow/app/android
   keytool -genkeypair -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 3072 -validity 10000 -alias upload
   ```
2. Create `app/android/key.properties` **locally only** with these keys:
   ```properties
   storePassword=YOUR_PRIVATE_STORE_PASSWORD
   keyPassword=YOUR_PRIVATE_KEY_PASSWORD
   keyAlias=upload
   storeFile=../upload-keystore.jks
   ```
   **Path note:** the path is resolved relative to `app/android/app/`. If the keystore is in `app/android/`, `../upload-keystore.jks` is correct.
3. Verify that Git ignores both files:
   ```bash
   git check-ignore app/android/key.properties app/android/upload-keystore.jks
   ```
4. Run `flutter build appbundle --release` from `app/` only after configuring signing.

Never commit, paste into chat, or share passwords, private keystores or provisioning profiles. Preserve the upload key backup; losing it can affect future updates.

## Android publication blockers
- Confirm the permanent unique application ID before first publication; currently `com.habitflow.habitflow`.
- Confirm version name and increment version code for each release.
- Confirm Play Console requirements, privacy policy, Data safety, screenshots, content rating, target API, and tester eligibility.
- Check actual manifest and notification delivery on Android devices. Android scheduled notifications are inexact.
- Verify release AAB installs through a legitimate test track. No Play Store release has been performed.

## iOS publication blockers
- The user's `app/ios/` project exists **locally** and is not tracked in GitHub. Never delete, regenerate, overwrite or clean it without review and backup.
- On the Mac, verify Xcode project, bundle identifier, signing team, capabilities, deployment target, notification delegate setup, permissions, and real iPhone delivery.
- Verify `flutter build ipa --release` only after Apple signing/provisioning are configured.
- Prepare App Store Connect metadata, privacy disclosures, accessibility review, screenshots and TestFlight.
- No App Store upload or TestFlight distribution has been performed.

## Release acceptance gate
- GitHub Actions static analysis and all unit/widget tests pass.
- Database migration and rollback tests pass.
- Android signed AAB builds and passes device smoke testing.
- iPhone release build runs and notification tests pass.
- VoiceOver/TalkBack, large text, light/dark mode, and key user journeys verified on devices.
- Privacy policy, backup/recovery plan, and store compliance confirmed.
- Manual release approval after evidence is recorded.

## Safe verification
```bash
cd ~/Downloads/HabitFlow
git status
git stash list
# If tracked files are modified:
git stash push -m "Backup before Audit Fix 05"
git pull --ff-only origin main
cd app
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```
Stop if pull conflicts with the untracked `app/ios/` folder. Do not use `git clean -fd`, `git reset --hard`, or `git stash pop`.

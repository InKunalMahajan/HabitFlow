# Phase 11 — CI Failure Resolution and Production Stability Audit

## Root cause confirmed
GitHub Actions run 43509857937 had 2 analyzer lint failures (unbraced if statements), while its widget/unit tests passed. Both offending source patterns have been corrected. The earlier Phase 06 Android debug build also passed (run 43509252352).

## Current release gate
- Verify Flutter analysis, all tests and Android debug build on the **latest** commit.
- Run full device backup export/import/restore acceptance on Android and iPhone.
- Confirm signed Android AAB and iOS IPA only after private signing setup.
- Verify notification permission, time zone and reboot behavior.
- Check VoiceOver/TalkBack and large-text layout.
- Confirm privacy disclosures and backup security before publishing.

## Mac commands
```bash
cd ~/Downloads/HabitFlow
git status
git stash list
# If tracked changes exist:
git stash push -m "Backup before Phase 11"
git pull --ff-only origin main
cd app
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Do not delete `app/ios/`, reset hard, clean untracked files or pop stashes.

## Pending
Latest CI results and real-device recovery tests. Earlier successful runs do not prove the current release commit passes.

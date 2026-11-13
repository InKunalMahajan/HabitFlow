# Phase 10 — Backup Security, Recovery Testing & Release Hardening

## Security hardening
- Reject selected import paths that do not resolve to a regular file.
- Check backup size both before and after reading (5 MiB maximum).
- Decode UTF-8 strictly: malformed byte sequences are rejected.
- Reject duplicate habit-history dates and histories exceeding 36,600 dates.
- Continue using strict versioned JSON validation and explicit preview/confirmation.
- Keep all restore operations in one SQLite transaction.

## Privacy considerations
- Backups are **not encrypted**. The user must save files to a secure destination.
- The share sheet can send a copy to third-party apps. Never assume the export was saved unless the destination confirms it.
- Temporary export files can remain in OS-managed cache. A future phase should implement a controlled lifecycle.
- Clipboard backups can expose personal data to other apps. Prefer private file export.

## Recovery acceptance tests — physical devices
1. Create sample tasks, habits, dated completions, goals, and reminders.
2. Export a JSON file to a private device folder; confirm it exists.
3. Import and preview; cancel and verify the database remains unchanged.
4. Confirm replacement on test data, restart the app and verify all restored records.
5. Import invalid JSON, malformed UTF-8, oversized files and duplicate history; verify rejection.
6. Simulate a failed SQLite write in tests and confirm transaction rollback.
7. Verify notifications after restore and after device restart.
8. Test large text, VoiceOver and TalkBack.
9. Record actual iOS and Android results before any release claim.

## CI/release gate
- Flutter analyzer, widget/unit tests, and Android build must pass on the final commit.
- Android signing and iOS signing are not confirmed.
- Store privacy disclosures and backup retention guidance are required.
- No app-store publication or device recovery verification is claimed.

## Safe local verification
```bash
cd ~/Downloads/HabitFlow
git status
git stash list
# If tracked files have changes:
git stash push -m "Backup before Phase 10"
git pull --ff-only origin main
cd app
flutter pub get
flutter analyze
flutter test test/habitflow_backup_test.dart
flutter test test/entry_database_test.dart
flutter test
```
Never delete the local untracked `app/ios/` folder or use destructive Git cleanup commands.

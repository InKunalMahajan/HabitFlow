# Phase 08 — Backup Export, Import Preview & Safe Restore

## Implemented
- Backup dialog accessible from the app bar when SQLite storage is enabled.
- Copy a complete, versioned JSON backup to the device clipboard. **This is not yet a file export**; paste it into a secure file manually.
- Paste backup JSON, validate format and contents, and preview item/goal/reminder counts.
- Explicit second confirmation before replacing existing records.
- SQLite atomic restore of entries, habit history, goals and reminders in one transaction; invalid backups are rejected without changing stored data.
- Refresh in-memory state and reconcile device reminders after successful database commit.
- Integration tests for successful restore and invalid-backup protection.

## Important limitations and safeguards
- The clipboard may be accessible to other apps or synced across devices. Clear it after securely saving your backup.
- No file picker, OS share sheet, encryption, automated backup, or merge import yet.
- A completed restore replaces all existing data. Back up first.
- If SQLite commits but OS notification reconciliation fails, stored data remains restored; device reminders may require another app restart.
- Do not claim real iPhone or Android backup recovery is verified until it has been tested.
- Existing `app/ios/` and Git stashes must remain untouched.

## Safe Mac verification
```bash
cd ~/Downloads/HabitFlow
git status
git stash list
# If tracked files have changes:
git stash push -m "Backup before Phase 08"
git pull --ff-only origin main
cd app
flutter pub get
flutter analyze
flutter test test/habitflow_backup_test.dart
flutter test test/entry_database_test.dart
flutter test
```

## Device acceptance
1. Create a task, habit with history, goal and reminder.
2. Open **Backup and restore**, copy JSON and save it securely.
3. Paste the JSON, preview record counts, cancel confirmation; verify nothing changes.
4. Confirm restore with test data only; restart and verify data.
5. Paste malformed JSON; confirm rejection and no data changes.
6. Test reminder rescheduling and notification permissions.

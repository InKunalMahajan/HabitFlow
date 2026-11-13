# Phase 09 — Native JSON File Export and Import

## Implemented
- Export the current SQLite snapshot to a JSON file in the OS-managed temporary directory, then open the native share sheet so the user can choose Files, Drive or another destination.
- Import a selected `.json` file using the native file picker. Reject files over 5 MiB, malformed JSON, unsupported versions, invalid records and orphaned reminders.
- Imported data is shown in the existing preview before the user can explicitly confirm **Replace my data**.
- Existing transactional SQLite restore, cancellation and device reminder reconciliation are preserved.
- Clipboard copy/paste remains available as a fallback.

## Important limitations
- Opening the share sheet is **not** proof the user saved the backup. Verify that the JSON file exists at the chosen destination.
- Backup files contain private habit, goal and reminder data. Use a secure destination and avoid public sharing.
- Temporary export copies may remain in OS-managed cache until the OS clears them.
- No automatic backup, encryption, merge import or cloud synchronization.
- Real iPhone and Android import/export remain unverified until tested.
- Local untracked `app/ios/` must not be deleted or regenerated.

## Mac verification
```bash
cd ~/Downloads/HabitFlow
git status
git stash list
# If tracked changes exist, first:
git stash push -m "Backup before Phase 09"
git pull --ff-only origin main
cd app
flutter pub get
flutter analyze
flutter test
```

## Device acceptance
1. Create tasks, habits with completion history, goals and reminder preferences.
2. Tap **Backup and restore → Export JSON file**. Save to a private folder in the system Files app.
3. Verify the saved JSON file exists and is readable.
4. Tap **Import JSON file**, select it and verify preview counts.
5. Cancel restore and verify the database is unchanged.
6. Confirm restore using test data only, then restart and verify all records.
7. Try invalid and oversized files; verify nothing is replaced.
8. Test notification reconciliation and accessibility with VoiceOver/TalkBack.

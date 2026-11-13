# Phase 07 — Offline Backup & Recovery Foundation

## Implemented
- Versioned JSON backup document (`habitflow-backup`, format v1).
- Exports in-memory tasks, habits, completion dates, goals, and reminder preferences to a JSON string.
- Strict parser rejects invalid JSON, unsupported versions, duplicate IDs, invalid dates, orphan reminders, invalid goals, and oversized documents (5 MiB).
- Seven pure Dart tests for round-trip and invalid data.

## Safety boundary
**This phase does not yet add a user-facing Export or Import button.** No file picker, file writing, sharing, cloud backup, or destructive database restore is implemented. Decoding only creates in-memory objects. Existing SQLite data is never overwritten by this code.

Before enabling restore in a later phase, implement and test:
1. Export file to a user-selected destination and confirm readable file.
2. Preview counts and format version before importing.
3. Explicit confirmation explaining that replacement will occur.
4. Single SQLite transaction restoring entries, goals, reminders, and history together.
5. Rollback on any failure, plus restoration of notification schedules after commit.
6. Recovery testing on real Android/iOS devices and protection of private backups.

JSON backups contain personal habit and goal information; users must control where they store and share files.

## Verify on Mac
```bash
cd ~/Downloads/HabitFlow
git status
git stash list
# If tracked modifications exist:
git stash push -m "Backup before Phase 07"
git pull --ff-only origin main
cd app
flutter pub get
flutter analyze
flutter test test/habitflow_backup_test.dart
flutter test
```

Do not delete the untracked local `app/ios/` folder or use `git reset --hard`, `git clean -fd`, or `git stash pop`.

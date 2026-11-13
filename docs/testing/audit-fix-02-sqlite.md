# Audit Fix 02 — SQLite Database Reliability

## Scope
Added an optional database path to `EntryDatabase.open` so tests can use isolated temporary databases. Production continues to use the existing `habitflow.db` file and schema version **3**.

Added `sqflite_common_ffi` as a **dev dependency only** for SQLite integration tests on the GitHub Actions Linux runner.

## Integration tests
1. Fresh v3 database: tasks, scheduled dates, habit check-ins, goals and reminders survive close/reopen.
2. Snapshot update: valid reminders and history survive, removed habit reminders disappear.
3. Failed entry snapshot: duplicate primary keys trigger transaction rollback, retaining original data and reminder.
4. v1 → v3: legacy entries and check-ins survive; new goals and reminders become available.
5. v2 → v3: scheduled tasks and goals survive; reminder table is added.
6. Failed goal update: invalid target triggers rollback.

## Limitations
- Tests must pass on GitHub Actions and on the user's Mac before claiming verification.
- The app still uses full-snapshot replacement for entry saves. These tests cover atomicity but do not establish performance for large datasets.
- No cloud sync, export or backup is implemented.
- Do not delete the local iOS project, user data or Git stashes.

## Safe Mac commands
```bash
cd ~/Downloads/HabitFlow
git status
git stash list
# If tracked files are modified, save them first:
git stash push -m "Backup before SQLite Audit Fix 02"
git pull --ff-only origin main
cd app
flutter pub get
flutter analyze
flutter test test/entry_database_test.dart
flutter test
```
If pull reports a conflict with untracked `app/ios/`, stop. Never use `git clean -fd` or `git reset --hard`.

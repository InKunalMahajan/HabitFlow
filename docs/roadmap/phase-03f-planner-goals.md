# Phase 03F — Planner & Goals Management

Updated: 2026-11-14

## Implemented in GitHub
- Planner tab displays tasks sorted by scheduled date; unscheduled tasks appear last.
- Task add/edit sheet supports choosing or clearing a scheduled date.
- Goals tab supports creating goals with a positive target count, increasing/decreasing progress, and deleting with confirmation.
- SQLite schema version 2 adds `entries.scheduled_day` and a `goals` table.
- Upgrade from version 1 adds new fields without deleting existing entries and habit completion records.
- Existing SQLite database and goals are loaded before showing the app; changes use the save queue.
- Widget tests updated for Planner and goal creation.

## Verification update — 2026-11-14
The project owner reported **all eight iPhone acceptance tests passed**, including preservation of existing data during SQLite v1→v2 migration and persistence of scheduled tasks and goal progress after full app restart. Android verification remains pending. This is user-reported device testing, not independently executed by the assistant.

## Limits
- Goals are simple counters; milestones, goal editing, goal-linked tasks, reminders, calendar view, and streaks are not implemented.
- The app does not sync or back up data.
- GitHub implementation is not proof of successful build, migration or device behavior.
- Do not uninstall the iPhone app or clear app data during upgrade verification.

## Verification
```bash
cd ~/HabitFlow
git pull origin main
cd app
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run -d 00008110-000C586901E3801E
```

On the iPhone with the existing Phase 03E database: verify existing tasks and habits still exist; edit a task and schedule it; open Planner and confirm its date; create a goal with target 10; increase progress to 2; fully close and reopen the app; verify both schedule and goal progress remain. Confirm goal deletion requires approval. Repeat on Android (`flutter run -d emulator-5554`) if available.

If any command fails, report the exact output. Do not claim the phase fully verified until analyzer, tests, database migration and device restart checks pass.

# Phase 03H — Insights and Progress Dashboard

## Implemented in GitHub
- Replace the Insights placeholder with an on-device dashboard.
- Show completed tasks / total tasks.
- Show habits completed today / total habits.
- Count habit check-ins over the trailing seven calendar days.
- Show goals reached / total goals.
- Add accessible text labels and progress indicators.
- Add unit tests and an Insights widget test.

## Data definitions
- Tasks: current completion state; no completion timestamps are stored, so daily or weekly task completion trends cannot be computed accurately.
- Habits: check-ins in the current local calendar day and six preceding days, based on saved date keys.
- Goals: counted as reached when progress is greater than or equal to target.
- Empty lists show zero progress; no synthetic or sample data is inserted into the database.
- No schema migration, cloud sync or network dependency is required.

## Local verification
```bash
cd ~/HabitFlow
git status
# Protect uncommitted changes before pulling; do not delete app/ios.
git pull --ff-only origin main
cd app
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run -d 00008110-000C586901E3801E
```

If Git refuses the pull because of local changes, stop and review/stash them safely first.

## Acceptance checks
1. Insights tab opens without a placeholder.
2. Complete a task and verify the count changes.
3. Complete a habit today and verify today's count and seven-day count change.
4. Add a goal and reach its target; verify reached goals count.
5. Fully restart the app; Insights reflects persisted records.
6. Verify empty data, large text, light/dark themes and VoiceOver/TalkBack.
7. Confirm analyzer, tests and CI pass.

Status: committed to GitHub, **not yet executed or device-verified**.

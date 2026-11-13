# Phase 03G — Accessibility, UI/UX Audit & Device Testing

Updated: 2026-11-14

## Implemented
- Added semantic headings for Today, Tasks, Habits, Planner and Goals.
- Added descriptive semantics for goal progress, matching the existing Today progress label.
- Applied a SafeArea around primary content.
- On compact screens or large text, navigation shows the selected label to reduce crowding; all destinations remain available.
- Removed the global Add floating button from Goals and Insights, where it could be misleading; Goals retains its own Create goal action.
- Improved goal entry hints and keyboard action.
- Fixed the Phase 03F missing `initialGoals` parameter in the HabitFlowShell constructor, which otherwise prevents compilation.
- Updated the widget tests for the current habit subtitle and added semantic regression checks.
- Added a GitHub Actions Flutter quality workflow running dependency resolution, formatting, static analysis and tests.

## Important verification status
- Code committed to GitHub, **not yet independently built or run**.
- CI workflow execution and success are not confirmed.
- VoiceOver, TalkBack, 200% text scaling, screen orientation and narrow-screen overflow still require device testing.
- Screen reader compatibility is a goal, not a certification.
- Existing Phase 03F user-reported iPhone persistence test does not validate these new Phase 03G changes.

## Mac Terminal checks
```bash
cd ~/HabitFlow
git pull origin main
cd app
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter devices
```

## iPhone checks
```bash
flutter run -d 00008110-000C586901E3801E
```
1. Turn on Settings → Accessibility → VoiceOver and navigate all four tabs; verify headings, checkboxes, edit/delete and goal progress are spoken correctly.
2. Turn on larger text in Settings → Accessibility → Display & Text Size → Larger Text; check Today, Planner, Goals, Add sheet, and goal dialog for clipping and overflow.
3. Test light and dark appearances; keyboard entry; date picker; delete confirmation; no reliance on sound alone.
4. Create a task and goal, close and reopen the app; verify persisted data.

## Android checks
```bash
flutter run -d emulator-5554
```
Enable TalkBack and increase font size/display size in Android accessibility settings; repeat the iPhone checks. Confirm persistence after full restart.

## CI
GitHub → Actions → Flutter quality checks. Confirm a green run; do not assume CI passed just because the workflow was committed.

## Acceptance
- Analyzer passes, all widget/unit tests pass, GitHub Actions passes.
- No blocking overflow on small phones at increased text size.
- Screen readers can navigate tabs, actions, checkboxes, and progress.
- No data regression on either platform.

# HabitFlow — Master Roadmap

Updated: 2026-11-14

## Status legend
- **Implemented:** code committed to GitHub
- **Locally verified:** user ran and reported passing checks
- **Pending:** not implemented, not verified, or blocked

## Phase status

| Phase | Scope | Status |
| --- | --- | --- |
| 01 | SRS, architecture, logical data model | Drafted |
| 02B | Material 3 design proposal | Documented |
| 02C | 54-screen registry | Documented |
| 02D | Initial interactive HTML demonstration | Prototype implemented |
| 02E | UX audit and defect priorities | Documented |
| 02F | Critical design corrections | Prototype implemented; verification incomplete |
| 02G | Navigation/component design standardization | Prototype implemented |
| 02H | 54-ID design navigator | Prototype implemented; many placeholders |
| 02I-A | Prototype correction pass | Committed; manual validation pending |
| 02I-C | Screen workflow expansion | Committed; manual validation pending |
| 02I-D | Browser regression test preparation | Committed; tests not confirmed executed |
| 02J | Design acceptance and issue closure | Pending |
| 03A | Flutter Android/Web scaffold | Implemented; locally verified |
| 03B | Material 3 theme and adaptive navigation | Implemented; locally verified by analyze/tests |
| 03C | Today preview, task completion, quick add, widget tests | Implemented; locally verified by analyze/tests |
| 03D | Task/habit CRUD, daily completion, input validation, widget/unit tests | Implemented in GitHub; local analyzer/tests/device verification pending |
| 03E | SQLite v1 database, load/save entries and habit dates | iPhone task persistence after full app restart confirmed by user (2026-11-14); Android and migration verification pending |
| 03F | Planner scheduled dates, goals with progress, SQLite v2 migration | All 8 iPhone acceptance tests passed, including migration and restart persistence (user-reported 2026-11-14); Android verification pending |
| 03G | Semantic headings/progress, adaptive navigation, accessibility regression tests, CI | Local Flutter analyzer and tests passed (user-reported 2026-11-14); CI, VoiceOver, TalkBack and device audit pending |
| 03H | On-device Insights dashboard, task/habit/goal statistics and tests | Implemented in GitHub; local analyzer, tests and iPhone/Android verification pending |
| iOS enablement | Xcode simulator runtime, iOS project, iPhone testing | Runtime download in progress; iOS project and device testing pending |

## Verification evidence (reported by project owner)

After the Phase 03B–03C GitHub updates:
- `flutter pub get`: succeeded; package update notices are informational.
- `dart format lib test`: 2 files formatted, 0 changed.
- `flutter analyze`: no issues found.
- `flutter test`: all tests passed.
- `flutter run -d chrome`: **failed** to establish the debugging WebSocket connection, followed by a missing temporary `app.dill.incremental.dill` file. Browser runtime is **not verified**.
- Xcode 27.2 is installed and selected at `/Applications/Xcode.app/Contents/Developer`.
- Simulator.app is absent at the checked Xcode path; `xcrun simctl list devices available` and `xcrun simctl list runtimes` returned empty lists. iOS runtime download and simulator setup are pending.
- The project owner confirmed GitHub synchronization succeeded. The iOS simulator runtime download was started and is still taking time; installation completion is not confirmed.\n- This paragraph describes older Phase 03C evidence. Later user-reported iPhone Phase 03E/03F persistence and migration tests are documented in the phase table above. Android runtime and formal accessibility audit are still pending.

## Next development sequence

1. Finish iOS simulator runtime installation and check `flutter doctor -v`.
2. From `app/`, run `flutter create --platforms=ios .` after Xcode setup, then `flutter pub get`.
3. Run the iOS Simulator and `flutter run -d <device-id>`; resolve any code signing/build issues.
4. Diagnose Chrome debugger failure separately; test `flutter build web --release`.
5. Verify Phase 03D locally with `flutter analyze` and `flutter test`, and test task/habit flows on iPhone and Android. iPhone task persistence was confirmed by user after app restart. Still verify Android persistence and database migrations; proceed with Phase 03F Planner and Goals.
6. Complete functional screens in implementation waves: S001–S017; S018–S027; S028–S032 and S043–S045; S033–S042; S046–S054.
7. Conduct accessibility, privacy, financial correctness, sync recovery and real-device testing before any production release.

## Scope and honesty

The 54-screen registry describes planned scope, **not 54 production-ready Flutter screens**. The Flutter app uses device-local SQLite for tasks, habits, scheduled dates, and goals on iOS/Android. Insights shows local task, habit and goal statistics; historical task completion trends are not available. No reminders, secure finance ledger, cloud sync, or cloud backup are shipped.

See [Phase 03 foundation](roadmap/phase-03-flutter-foundation.md), [screen registry](design/screen-registry.md), and [test plan](testing/test-plan.md).

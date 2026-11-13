# HabitFlow

**A visual-first, Deaf-inclusive personal productivity and life-management application.**

## Current project status — 2026-11-14

Flutter Phase 03A–03C foundation is committed in `app/`.

**Locally verified by the project owner:** `flutter pub get`, `dart format lib test`, `flutter analyze` (no issues), and `flutter test` (all tests passed).

**Known blockers:** Chrome debug connection failed; iOS Simulator is not yet installed/available even though Xcode 27.2 is installed. iOS app generation and device execution remain pending.

**Not yet implemented:** durable task/habit storage, reminders, planner/calendar functionality, goals functionality, finance, wellness, cloud sync, and full 54-screen application.

The `prototype/` folder is an earlier HTML design prototype, separate from the Flutter application.

## Run the Flutter app

```bash
git pull origin main
cd app
flutter pub get
flutter analyze
flutter test
flutter build web --release
```

For an interactive run, use `flutter devices` and then `flutter run -d <device-id>` with an actual available device. Chrome debug launch is currently being troubleshot.

### iOS setup (pending)

Full Xcode 27.2 is installed. Download an iOS Simulator runtime in Xcode Settings → Components, or try `xcodebuild -downloadPlatform iOS`. Verify with `xcrun simctl list runtimes` and `xcrun simctl list devices available`.

Once a simulator is installed, from `app/`:
```bash
flutter create --platforms=ios .
flutter pub get
flutter devices
```

Then run `flutter run -d <simulator-device-id>` using the listed ID. This is a setup plan, **not a completed iOS build**.

## Phase 03 Flutter files

- `app/lib/main.dart` — Material 3 app, responsive navigation, Today preview and quick-add
- `app/lib/core/theme/app_theme.dart` — shared light/dark theme
- `app/test/widget_test.dart` — dashboard, task, navigation and quick-add widget tests

Persistent destinations: **Today, Planner, Goals, Insights**. **Add** is a quick-create action. Bottom navigation is used below 600dp, a rail from 600dp, and an extended rail from 840dp.

**Data warning:** preview tasks and completion state reset on app restart.

## Planned modules

Today; habits; tasks; reminders; planner/calendar; projects; goals and milestones; journal; focus sessions; templates; finance (accounts, double-entry ledger, budgets, savings); wellness; insights; optional account/sync/export; privacy and accessibility settings.

## Technology

Flutter/Dart and Material 3 are in use. Riverpod, go_router, Drift/SQLite, Firebase and local notifications remain proposals for later phases.

## Documentation

- [Master roadmap and phase status](docs/roadmap.md)
- [Phase 03 foundation and verification](docs/roadmap/phase-03-flutter-foundation.md)
- [Architecture](docs/architecture/overview.md)
- [54-screen registry](docs/design/screen-registry.md)
- [Design system](docs/design/design-system.md)
- [Navigation](docs/design/navigation.md)
- [Data model](docs/database/data-model.md)
- [Finance safety](docs/database/finance.md)
- [Accessibility](docs/accessibility/requirements.md)
- [Testing plan](docs/testing/test-plan.md)
- [Security and privacy](docs/security/privacy.md)

## Core principles

1. Offline-first, no mandatory account.
2. No audio-only feedback; visual, text-based status and accessible controls.
3. Separate habits, tasks, reminders, goals and projects.
4. Finance, when implemented, must use integer minor units, balanced postings, reversals and audit trails.
5. Do not claim data persistence, synchronization or platform compatibility without testing.

## License

See [LICENSE](LICENSE) and [CONTRIBUTING.md](CONTRIBUTING.md).

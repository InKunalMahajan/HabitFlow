# HabitFlow

**A visual-first, Deaf-inclusive personal productivity and life-management application.**

## Current status (Phase 03)

- **Phase 03A:** Flutter project initialized in `app/`; Android and web targets created. Project owner reported `flutter analyze` and `flutter test` passing before the Phase 03 changes.
- **Phase 03B–03C foundation:** Material 3 light/dark themes, responsive navigation, Today dashboard preview, in-memory task completion and quick-add task sheet committed to GitHub.
- **Validation required:** Run the new widget tests and analysis locally. The Phase 03 changes have **not** been verified on an Android device or in a browser by this repository update.
- **Not yet implemented:** Persistent storage, real reminders, calendar, goals, insights, financial ledger, account/sync, native accessibility audit, and full 54-screen application.

The `prototype/` directory contains an earlier HTML interaction prototype; it is separate from the Flutter app.

## Run the Flutter app

Prerequisites: Flutter SDK and a supported browser or Android device.

```bash
git pull origin main
cd app
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

To run on Android, use `flutter devices` to identify a connected Android device or emulator, then `flutter run -d <device-id>`.

## Phase 03 Flutter files

- `app/lib/main.dart` — application entry, adaptive navigation shell, Today preview, quick-add task form
- `app/lib/core/theme/app_theme.dart` — shared Material 3 light/dark themes
- `app/test/widget_test.dart` — dashboard, task, navigation, and quick-add widget tests
- `app/pubspec.yaml` — Flutter application manifest

The four persistent destinations are **Today, Planner, Goals, Insights**. **Add** is a floating quick-create action, not a fifth persistent route. At widths under 600dp the app uses bottom navigation; from 600dp it uses a navigation rail, expanding its labels at 840dp.

**Data warning:** Phase 03 tasks and completion state are session-only and reset on restart. The interface does not claim durable saving.

## Long-term planned modules

Today; habits; tasks; reminders; planner/calendar; projects; goals and milestones; journal; focus sessions; templates; finance (accounts, double-entry ledger, budgets, savings); wellness; insights; optional account/sync/export; privacy and accessibility settings.

## Planned technology

Flutter/Dart and Material 3 are in use. Riverpod, go_router, Drift/SQLite, Firebase services and local notifications are proposed for later implementation, not currently integrated.

## Documentation

- [Architecture](docs/architecture/overview.md)
- [54-screen registry](docs/design/screen-registry.md)
- [Design system](docs/design/design-system.md)
- [Navigation](docs/design/navigation.md)
- [Data model](docs/database/data-model.md)
- [Finance safety](docs/database/finance.md)
- [Accessibility](docs/accessibility/requirements.md)
- [Testing plan](docs/testing/test-plan.md)
- [Roadmap](docs/roadmap.md)
- [Security and privacy](docs/security/privacy.md)

## Core principles

1. Offline-first; no mandatory account.
2. No audio-only feedback; accessible text and visual status.
3. Separate habit, task, reminder, goal and project concepts.
4. Finance postings use integer minor units, balanced entries, reversals and audit history once implemented.
5. Do not claim data persistence, cloud synchronization or financial accuracy before verification.

## License

See [LICENSE](LICENSE) and [CONTRIBUTING.md](CONTRIBUTING.md).

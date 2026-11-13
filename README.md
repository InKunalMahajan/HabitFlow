# HabitFlow

A visual-first, Deaf-inclusive Flutter productivity app.

## Current implementation — November 2026

The Flutter application in `app/` includes Today tasks and habits, habit history and streaks, Planner, Goals, Insights, SQLite local storage (schema v3), reminder preferences, and native local notification scheduling code. Notification delivery on real devices and production signing are **not yet fully verified**.

This is an active development build, **not a published Android or iOS release**. The 54-screen design registry describes future scope; not all screens are implemented.

The local iOS project is currently untracked in GitHub. Keep `app/ios/` safe. Never run a cleanup command that deletes it.

## Run and test

```bash
cd app
flutter pub get
flutter analyze
flutter test
flutter devices
```

For an available development device, run `flutter run -d DEVICE_ID`.

## Release readiness

Android release signing requires a **private upload keystore** and local `app/android/key.properties`. Release builds are blocked without signing configuration; never commit keys or passwords. iOS release signing and native notification setup must be checked locally.

See [Audit Fix 05 release checklist](docs/release/audit-fix-05-production.md) for safe signing setup, store prerequisites and acceptance gates.

## Documentation

- [Master roadmap](docs/roadmap.md)
- [Architecture](docs/architecture/overview.md)
- [Accessibility requirements](docs/accessibility/requirements.md)
- [SQLite reliability tests](docs/testing/audit-fix-02-sqlite.md)
- [Notification reliability tests](docs/testing/audit-fix-03-notifications.md)
- [UI and accessibility audit](docs/testing/audit-fix-04-accessibility.md)
- [Release preparation](docs/release/audit-fix-05-production.md)

## Principles

Offline-first, no mandatory account, visual/text feedback without audio-only instructions, and accessible controls. Do not claim production readiness or real-device compatibility until verified.

## License

See [LICENSE](LICENSE) and [CONTRIBUTING.md](CONTRIBUTING.md).

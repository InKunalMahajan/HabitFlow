# HabitFlow

**A calm, visual-first personal productivity and life-management app for Android and iOS.**

> Status: **Design and documentation only.** Flutter has **not** been installed or initialized. No production app, Firebase project, or database is configured.

HabitFlow is designed to work **offline without an account**, with optional cloud backup and synchronization later. It prioritizes readable language, visual feedback, Deaf-inclusive accessibility, and user control.

## Planned modules
- Today dashboard; habits; tasks; reminders
- Planner/calendar; projects; goals and milestones
- Journal; focus sessions; routine templates
- Personal finance (accounts, double-entry ledger, budgets, savings)
- Wellness and mood; insights and weekly reviews
- Optional account, sync, export, privacy, and accessibility settings

## Planned technology (not installed)
Flutter/Dart, Material 3, Riverpod, go_router, Drift/SQLite, Firebase Authentication, Firestore, Cloud Functions, Firebase Cloud Messaging, and local notifications. These choices are **proposals** pending implementation review.

## Design documentation
- [Architecture](docs/architecture/overview.md)
- [54-screen registry](docs/design/screen-registry.md)
- [Design system](docs/design/design-system.md)
- [Navigation and UX](docs/design/navigation.md)
- [Data model](docs/database/data-model.md)
- [Finance safety](docs/database/finance.md)
- [Accessibility](docs/accessibility/requirements.md)
- [Testing plan](docs/testing/test-plan.md)
- [Roadmap](docs/roadmap.md)
- [Security and privacy](docs/security/privacy.md)

## Current project phases
Phase 01: SRS and architecture drafted. Phases 02B–02G: design system, screen specifications, prototype and audit. Phase 02H: 54 screen IDs represented in a design explorer, **not** 54 completed high-fidelity screens. Phase 02I: accessibility/usability validation **pending**.

## Core principles
1. Offline-first, with no mandatory account.
2. No audio-only feedback; visual messages and optional vibration.
3. Clear activity distinctions: habit, task, reminder, goal, project.
4. Finance amounts in integer minor units; balanced postings, reversals, and audit trail.
5. No false claims about sync, saved data, or financial balances.
6. Accessibility and privacy built into every workflow.

## Development
This repository currently contains planning documents only. **Do not run Flutter installation or scaffold commands** until project owner approval.

## License
See [LICENSE](LICENSE). Contributions: [CONTRIBUTING.md](CONTRIBUTING.md).

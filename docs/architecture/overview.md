# HabitFlow Technical Architecture — HF-ARCH-001B

**Status:** Proposed; not implemented.

## Architecture
Flutter presentation (Material 3) → Riverpod application/domain services → Drift/SQLite local storage → transactional outbox → optional Firebase sync via authenticated Cloud Functions and Firestore. Local functionality must not depend on a Firebase account or network.

## Planned client libraries
Flutter/Dart, Riverpod, go_router, Drift/SQLite, flutter_local_notifications, fl_chart. Dependencies and versions are not locked.

## Major domains
Profiles, categories, habits/logs, tasks/subtasks, reminders, calendar, projects, goals/milestones, journal, focus, finance, wellness, templates, analytics, settings, sync metadata.

## Data rules
UUID identifiers; profile ownership; UTC millisecond timestamps and explicit local timezone for scheduling; migrations; soft deletes where appropriate; revision and idempotency keys; atomic local writes with outbox entries. Reconcile offline edits explicitly rather than silently overwriting conflicts.

## Planned cloud functions
hfBootstrapV1, hfSyncPushV1, hfSyncPullV1, hfSyncResolveV1, hfFinancePostV1, hfFinanceReverseV1, hfBackupManifestV1, hfAccountDeleteV1, hfDeviceRegisterV1.

Firestore clients may read owner-scoped data where authorized, but trusted writes must be validated server-side. Cloud access is optional.

## Open decisions
Executable migrations, security rules, indices, financial edge cases, backup/restore conflict policy, and production notification behavior require further design and tests.

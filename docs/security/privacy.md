# Privacy, Security & Offline Trust

HabitFlow must work offline without mandatory sign-in. Account linking, cloud backup and sync are opt-in and must describe exactly what data leaves the device.

## Requirements
- Per-profile ownership and authorization at every boundary.
- Secrets never committed; use managed configuration and secure credential storage.
- Server-side validation and idempotent writes for trusted financial postings.
- Firestore owner-scoped reads; direct client writes to protected synced records denied.
- Export requires explicit scope and privacy warning; account deletion must cover local and cloud retention policies.
- Do not claim end-to-end encryption, secure backup, biometric protection or compliance without implemented evidence.
- Sensitive finance/journal data must not appear in logs, analytics or screenshots by default.
- Document threat model, backup recovery, data retention and incident response before launch.

## Current status
No production Firebase, account storage, database, or app exists in this repository.

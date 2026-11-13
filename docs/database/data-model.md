# HabitFlow Data Model — HF-DB-001A

**Status:** Logical design, not executable schema.

## Core conventions
UUID primary keys (TEXT locally), profile_id ownership, created_at/updated_at UTC ms, soft deletion as needed, revision, idempotency, sync state, transactional outbox, migration version. Use INTEGER for boolean and monetary minor units; explicit currency code; JSON only for suitable flexible metadata. Enforce foreign keys and ownership boundaries.

## Domain entity groups
- Profile: profiles, preferences, devices, auth_links.
- Activities: categories, habits, habit_logs, tasks, subtasks, reminders.
- Planning: projects, project_tasks, goals, milestones, calendar_links.
- Reflection: journal_entries, focus_sessions, wellness_logs, mood_entries.
- Finance: financial_accounts, ledger_transactions, ledger_postings, budgets, budget_allocations, savings_goals, recurring_rules.
- Templates: routine_templates, template_items.
- Sync: outbox_events, sync_cursors, conflicts, change_history, tombstones.

Entity names are illustrative until migration review. Store schedules with local time and timezone; store instants in UTC.

## Sync state machine
Clean → Pending → Syncing → Clean, or Conflict / Rejected with explicit recovery. Finance distinguishes local draft from cloud-confirmed posting. Do not silently merge ledger entries.

## Remaining work
Finalize exact fields, constraints, composite FKs, indexes, migration order, encryption approach, retention rules, and conflict resolution.

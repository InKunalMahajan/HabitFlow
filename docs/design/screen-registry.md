# HabitFlow 54-Screen Registry — HF-UX-002C

**Status:** Functional screen specification; interactive coverage incomplete. Screen IDs are stable.

| ID | Screen | ID | Screen |
|---|---|---|---|
| S001 | Welcome | S002 | Privacy Choice |
| S003 | Permissions | S004 | Sign In |
| S005 | Account Linking | S006 | Today Dashboard |
| S007 | All Activities | S008 | Activity Details |
| S009 | Habit List | S010 | Habit Editor |
| S011 | Habit Details | S012 | Habit History |
| S013 | Task List | S014 | Task Editor |
| S015 | Task Details | S016 | Reminder List |
| S017 | Reminder Editor | S018 | Calendar |
| S019 | Weekly Planner | S020 | Project List |
| S021 | Project Editor | S022 | Project Details |
| S023 | Project Board | S024 | Goal List |
| S025 | Goal Editor | S026 | Goal Details |
| S027 | Milestone Editor | S028 | Journal Timeline |
| S029 | Journal Editor | S030 | Journal Details |
| S031 | Focus Timer | S032 | Focus History |
| S033 | Finance Overview | S034 | Financial Accounts |
| S035 | Transactions | S036 | Transaction Editor |
| S037 | Budgets | S038 | Budget Editor |
| S039 | Savings Goals | S040 | Wellness Overview |
| S041 | Mood Check-In | S042 | Wellness Log |
| S043 | Template Gallery | S044 | Template Preview |
| S045 | Template Customize | S046 | Insights Overview |
| S047 | Detailed Report | S048 | Weekly Review |
| S049 | Sync Center | S050 | Conflict Resolution |
| S051 | Data Export | S052 | Profile |
| S053 | Preferences | S054 | Accessibility |

## Screen design contract
For each screen document: purpose, route and parent, fields, actions, validation, loading/empty/error/offline/conflict states, accessibility labels, responsive layout, Android/iOS behavior, acceptance tests.

## Coverage warning
Phase 02H offered a navigator for 54 IDs, but some were generic placeholders and some labels diverged from this canonical registry. In particular **S008 is Activity Details** and **S016 is Reminder List**. Correct these mismatches before implementation. The 54-screen high-fidelity approval gate is still open.

# HabitFlow Navigation & Interaction — HF-UX-002G

## Primary navigation
Today | Planner | **Add** | Goals | Insights. Add is an action opening a quick-create sheet, not a destination. Keep secondary modules (habits, tasks, reminders, journal, focus, finance, wellness, projects, templates, settings) discoverable through consistent routes and shortcuts.

## Adaptive layout
Compact <600 logical dp: bottom navigation and one-column content. Medium 600–839 dp: rail and flexible columns. Expanded ≥840 dp: rail/drawer and optional master-detail. Respect safe areas, keyboard insets, landscape and text scaling.

## Navigation rules
Maintain destination history, preserve filters on return, guard unsaved edits, use consistent back behavior, and restore focus after modal dismissal. Android system/predictive back and iOS swipe-back must not silently discard data.

## Dialog lifecycle
On open: remember opener, isolate background, focus heading or first input, trap focus. On dismiss: if dirty, show Continue Editing / Discard Changes; otherwise close. Every close path (save, cancel unchanged, discard, system back) must run **one cleanup function** restoring background interactivity and opener focus. Nested confirmation must preserve the original form state.

## Known prototype gaps
Phase 02H screen IDs and some generic actions need reconciliation with the canonical registry. Complex editor routes and full error states are not yet implemented.

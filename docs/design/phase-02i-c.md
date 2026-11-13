# Phase 02I-C — Interactive Workflow Expansion

**Status: implementation committed to standalone HTML design prototype; testing NOT RUN.**

## Scope

The [HTML prototype](../../prototype/index.html) now contains sample record detail/edit/delete interactions for habits, tasks, projects, goals, journals and templates; a keyboard-button project board that toggles task state; a milestone editor and budget editor backed by temporary in-memory collections; a sample savings contribution button; and wellness history with a mood check-in form. The existing reminders list/editor and finance income/expense/transfer flow remain available.

## Behavior and safeguards

- The 54 screen IDs remain canonical; Quick Add is a sheet action.
- Sample records exist only in page memory. Reloading resets changes.
- Editor navigation and Cancel/Back request confirmation when dirty.
- Financial transaction postings use integer paise and balanced account deltas in the demo. This is not a production ledger.
- Project board movement uses labeled buttons as a keyboard-accessible alternative to drag.
- Browser dialogs for deletion are temporary prototype controls and need accessible custom-dialog review.
- All real notifications, export, timer, authentication, sync and server posting remain unimplemented.

## Incomplete areas

This phase does **not** mean all 54 screens are production-ready or fully interactive. Reminder detail is still represented through the list/editor rather than a dedicated canonical detail screen; recurring scheduling, project task ownership, goal-milestone relationships, journal privacy controls, real mood visualization, template application, and finance reversal/ledger immutability remain incomplete. Screen reader, device, contrast and automated browser testing have not been performed.

## Exit criteria

Use [Phase 02I-C verification](../testing/phase-02i-c-verification.md) to execute and record evidence. Do not mark any test passed without running it.

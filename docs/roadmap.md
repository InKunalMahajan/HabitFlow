# HabitFlow Roadmap

## Completed planning work (not production implementation)
- Phase 01: SRS, logical database and technical architecture drafts.
- Phase 02B: Material 3 design system proposal.
- Phase 02C: Canonical 54-screen functional registry.
- Phase 02D: Initial eight-view interactive demonstration.
- Phase 02E: UX audit and prioritized defects.
- Phase 02F: Critical correction demonstration, not fully tested.
- Phase 02G: Navigation/component standardization.
- Phase 02H: 54-ID design navigator with partial/placeholder screens.

## Next
- Phase 02I: structured accessibility/usability validation with evidence.
- Phase 02J: close P0/P1 design issues, reconcile registry, final design approval.
- Only after explicit authorization: Flutter project initialization and implementation.

## Implementation waves (future)
1. Onboarding, Today, habits, tasks, reminders (S001–S017).
2. Planner, projects, goals (S018–S027).
3. Journal, focus, templates (S028–S032, S043–S045).
4. Finance and wellness (S033–S042).
5. Insights, sync, settings (S046–S054).

Private testing release only after accessibility, security, financial correctness and sync recovery gates.

## Phase 02I-A — Prototype corrections (2026-11-13)

Committed [corrected HTML design demo](../prototype/index.html), [design notes](design/phase-02i-a.md) and [verification checklist](testing/phase-02i-a-verification.md). P0 design corrections implemented in a simulated browser prototype; **not yet tested**. P1 screen-specific coverage and full accessibility remain incomplete. Flutter installation is still on hold.

## Phase 02I-C — Screen workflow expansion (2026-11-13)

Committed [expanded HTML prototype](../prototype/index.html), [implementation scope and limitations](design/phase-02i-c.md), and [26-case manual test checklist](testing/phase-02i-c-verification.md). Interactions are temporary browser demonstrations; all tests remain NOT RUN or BLOCKED. Not all 54 screens are fully interactive. Phase 02J approval is pending. Flutter remains on hold.

## Phase 02I-D — Browser regression audit preparation (2026-11-13)

Updated [HTML prototype](../prototype/index.html) to clear stale editor navigation and preserve completed state on edits. Added [Node source-contract tests](../tests/prototype-static.test.mjs) and [browser/accessibility audit plan](testing/phase-02i-d-audit.md). **Tests not executed**; this is not a device/browser pass. Phase 02J remains pending. Flutter installation remains on hold.

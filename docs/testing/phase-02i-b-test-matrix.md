# Phase 02I-B — Screen Interaction and Accessibility Test Matrix

**Status:** Test design and targeted HTML prototype fixes committed. **No automated browser, Android, iOS, TalkBack, or VoiceOver tests have been executed.**

## Critical checks (all NOT RUN)

| ID | Test | Expected |
|---|---|---|
| IB-01 | Open 54 screen IDs from directory | Correct canonical title and no broken navigation |
| IB-02 | Open S008 and S016 | Activity Details and Reminder List respectively |
| IB-03 | Press Back after navigating through three screens | Returns to previous destination without corrupting history |
| IB-04 | Type into S014 and press Back | Discard confirmation; no silent data loss |
| IB-05 | Type into S014 and choose Continue Editing | Original input remains |
| IB-06 | Type into S014 and choose Discard | Navigation proceeds and background interaction restored |
| IB-07 | Dirty editor, press Escape on confirmation | Returns to editor with values preserved |
| IB-08 | Unchanged editor, Cancel | Returns without discard confirmation |
| IB-09 | Quick Add, close with Escape | Focus returns to opener |
| IB-10 | Modal keyboard Tab and Shift+Tab | Focus remains within modal |
| IB-11 | Income ₹1,000.00 to Bank | Bank +₹1,000; combined +₹1,000 |
| IB-12 | Expense ₹200.25 from Cash | Cash −₹200.25; combined −₹200.25 |
| IB-13 | Transfer ₹500 Bank to Cash | Bank −₹500, Cash +₹500, combined unchanged |
| IB-14 | Same-account transfer | Rejected |
| IB-15 | Invalid amount 0, -1, 1.999, blank | Rejected |
| IB-16 | Invalid transaction date | Rejected |
| IB-17 | Every posting's delta sum | Exactly zero integer paise |
| IB-18 | Screen with no implemented persistence | Clearly indicates preview or simulated action |
| IB-19 | 320 CSS px viewport, 200% browser zoom | No essential clipped content |
| IB-20 | Dark mode and large text | Labels and focus indicators remain visible |
| IB-21 | Keyboard-only navigation | All essential demonstrated controls reachable |
| IB-22 | TalkBack and VoiceOver | **Blocked** pending suitable runnable app |
| IB-23 | Visual alerts without sound | Essential messages conveyed by text |
| IB-24 | Focus timer, export, sync | Explicitly labeled as simulations |

## Screen-by-screen evidence template

For **each** of S001–S054, record: route/title, primary action, keyboard navigation, focus order, error state, empty state, responsive behavior, accessibility semantics, observed result, device/browser, and issue ID.

Result values: NOT RUN, PASS, FAIL, BLOCKED. No tests should be marked PASS based only on code review.

## Unresolved gaps

The HTML navigator still uses generic previews for several detail screens. Screen-specific form models and validations are incomplete. The finance example is an in-memory balanced posting demo, not a durable immutable ledger. The project board has no fully implemented accessible rearrangement controls. Focus timer, export, notifications and cloud sync are not functional. Native assistive-technology testing is blocked until a runnable app exists.

## Exit gate

Do not mark Phase 02I-B complete until the 54-screen interaction coverage is independently reviewed, critical flows have test evidence, and unresolved P0/P1 findings are tracked or closed. Phase 02J design approval remains pending.

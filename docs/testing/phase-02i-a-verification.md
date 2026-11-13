# Phase 02I-A — Defect Corrections and Verification Checklist

**Status:** Prototype changes committed; **tests not executed** on Android, iOS, TalkBack or VoiceOver. Do not interpret an implemented behavior as a passed test.

## Defect register

| Finding | Severity | Change | Current status |
|---|---|---|---|
| HF-I-001 | P0 | Simulated integer-paise double-entry postings; account balances derived from entries; same-account transfer rejected | Implemented in HTML demo; unverified |
| HF-I-002 | P0 | Navigation, Cancel and Back prompt to discard dirty editor; focus/background cleanup shared | Implemented in HTML demo; unverified |
| HF-I-003 | P0 | Canonical S001–S054 names; S008 Activity Details, S016 Reminder List | Implemented in directory; verify each screen |
| HF-I-004 | P1 | Module-specific sample records and key controls; remaining detailed journeys explicitly identified as previews | **Partially addressed**; not closed |
| HF-I-005 | P1 | Semantic buttons, labeled inputs, focus trap, status announcements; some detail semantics still incomplete | **Partially addressed**; not closed |
| HF-I-006 | P1 | rem-based text, responsive columns, 125% text toggle and dark theme | Implemented in HTML demo; device verification pending |
| HF-I-007 | P1 | Persistent demo notice; sync/export/timer explicitly simulated | Implemented in HTML demo; unverified |

## Required manual checks (all initially NOT RUN)

- [ ] HF-01 Open all 54 screen IDs and confirm canonical titles and no broken routes.
- [ ] HF-02 S008 shows Activity Details and S016 shows Reminder List.
- [ ] HF-03 From Today, Quick Add opens; closing returns focus and restores navigation.
- [ ] HF-04 On S014 enter text, select Cancel, then Continue Editing: values remain.
- [ ] HF-05 On S014 enter text, navigate to Today, then Discard: route changes and background is interactive.
- [ ] HF-06 On S014 with unchanged form, Cancel closes without a confirmation.
- [ ] HF-07 Open dialog with keyboard, test Tab, Shift+Tab, Escape and focus restoration.
- [ ] HF-08 Add ₹1,250 expense from Bank: Bank decreases exactly ₹1,250.
- [ ] HF-09 Add ₹5,000 income to Bank: Bank increases exactly ₹5,000.
- [ ] HF-10 Transfer ₹500 Bank → Cash: combined balance unchanged, both account balances change.
- [ ] HF-11 Transfer Bank → Bank: rejected with clear error.
- [ ] HF-12 Enter ₹1.999, negative amount, empty amount and 0: all rejected.
- [ ] HF-13 Confirm each ledger posting sums to zero in integer paise.
- [ ] HF-14 At 320 CSS px, no essential content is clipped or inaccessible.
- [ ] HF-15 At 125% prototype text and browser 200% zoom, controls remain usable.
- [ ] HF-16 Test keyboard-only access to all primary routes and form fields.
- [ ] HF-17 Test dark theme, contrast and focus visibility.
- [ ] HF-18 Confirm persistent demo banner and truthful sync/export/timer messaging.
- [ ] HF-19 Test Android TalkBack on a suitable runnable implementation — **blocked** until available.
- [ ] HF-20 Test iOS VoiceOver on a suitable runnable implementation — **blocked** until available.

## Finance invariants

Each transaction must use integer minor units and at least two postings. Sum of postings per transaction and currency is zero. Bank/Cash balances derive from opening balances plus posted deltas. Transfer must not be included as income or expense. This prototype does **not** implement immutable reversal, cloud confirmation, cross-currency transfers, recurring scheduling or persistent audit logs.

## Known issues and exit criteria

The prototype is an HTML design demonstration with temporary in-memory data. The 54 screen IDs are reachable, but **not all have complete feature-specific interactions**. Generic detail previews remain, no actual sync/notifications/export occur, and no automated or device accessibility tests have run.

**Phase 02I-A must not be marked fully passed.** Complete the remaining P1 features, run manual checks, record actual results, and repeat the accessibility audit before Phase 02J design approval.

# Phase 02I-C — Interaction Verification Checklist

**All cases: NOT RUN unless independently executed and documented.**

| ID | Screen(s) | Manual test | Expected |
|---|---|---|---|
| IC-01 | S009/S011 | Select second habit | Correct selected habit details |
| IC-02 | S011/S010 | Edit habit and save | Selected record updated, not duplicated |
| IC-03 | S011 | Delete selected habit | Record removed after confirmation |
| IC-04 | S010 | Modify and Cancel | Discard confirmation |
| IC-05 | S013/S015 | Select and edit task | Correct task details and saved value |
| IC-06 | S016/S017 | Create reminder | New reminder appears in list |
| IC-07 | S020/S022 | Select and edit project | Correct project record updated |
| IC-08 | S023 | Move task to Done / To do | Button action works without drag |
| IC-09 | S024/S026 | Select and edit goal | Correct goal details |
| IC-10 | S027 | Add milestone | New milestone appears |
| IC-11 | S028/S030 | Create and edit journal | Entry updated in memory |
| IC-12 | S040/S041 | Save mood check-in | Mood history updated |
| IC-13 | S040/S042 | Save wellness log | Wellness list updated |
| IC-14 | S043/S044/S045 | Customize template | Selected template updated |
| IC-15 | S037/S038 | Create budget with 2500.00 | Budget displays ₹2,500.00 |
| IC-16 | S038 | Enter invalid amount | Clear validation, no save |
| IC-17 | S039 | Add sample ₹100 to savings | Savings current amount increases ₹100 |
| IC-18 | S033–S036 | Income, expense and transfer | Derived balances correct; transfer total unchanged |
| IC-19 | Any editor | Dirty navigation + Continue Editing | Input preserved |
| IC-20 | Any editor | Dirty navigation + Discard | Destination reached, focus and inert restored |
| IC-21 | All S001–S054 | Navigate each screen | Canonical title and usable back route |
| IC-22 | Mobile 320px | Narrow layout and 200% zoom | No essential clipping |
| IC-23 | Keyboard | Tab, Shift+Tab, Escape | Logical order and dialog containment |
| IC-24 | Android | TalkBack | BLOCKED until runnable app |
| IC-25 | iOS | VoiceOver | BLOCKED until runnable app |
| IC-26 | All | Reload prototype | Temporary sample edits reset; no persistence claims |

## Defects requiring targeted review

1. HTML delete uses native browser confirm rather than an app-designed accessible confirmation.
2. Screen-specific editor fields are generic text inputs; date/time/select/validation must be specialized.
3. Detail screen selection and edit navigation need browser regression tests.
4. Some generic previews still lack independent workflows.
5. Finance posted transactions are simulated, not durable or reversible.
6. No native assistive-technology test evidence.

## Evidence template

Record test ID, date, browser/device, viewport, steps, expected, actual, PASS/FAIL/BLOCKED, screenshot reference, and defect number. **No execution evidence is recorded by this document.**

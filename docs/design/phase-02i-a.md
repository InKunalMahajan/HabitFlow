# Phase 02I-A — Corrected Design Prototype

**Artifact:** [Open standalone HTML demo](../../prototype/index.html)

## Implemented design corrections
1. Finance: integer paise; balanced simulated postings; bank and cash derived balances; transfer must use different accounts; invalid decimal amounts rejected.
2. Forms: all editor screens use a shared dirty flag and navigation guard. Cancel, Back and route changes request confirmation. Continue Editing preserves values; Discard closes dialog, restores background/focus, and follows requested destination.
3. Canonical registry: S001–S054 use the names in the 54-screen registry. S008 is Activity Details; S016 is Reminder List. Quick Add is an action, not S008.
4. Screen actions: sample lists, creation, calendar selection, wellness, focus, finance, insights, sync and settings represented. Detailed implementation is **partial**.
5. Semantics: semantic buttons/labels, focus handling, status live region, text summaries. Full screen-reader coverage remains pending.
6. Adaptive UI: rem typography, 125% text setting, responsive sidebar/bottom navigation, dark theme, reduced-motion rule.
7. Truthful status: persistent banner identifies temporary data and absent cloud/native functionality.

## Known limitations
- The prototype is standalone browser HTML, not Flutter and not production code.
- No persistence, notifications, Firebase, actual export, running timer or cloud synchronization.
- Not every screen has its complete field schema or detailed workflow.
- No Android/iOS assistive-technology tests have been performed.
- Finance reversal and immutable server-side posting are future implementation requirements.

## Manual verification
See [Phase 02I-A verification checklist](../testing/phase-02i-a-verification.md). All tests start as NOT RUN. Do not infer pass status from code presence.

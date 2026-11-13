# Accessibility Requirements — ISL-first and Visual-first

**Status:** Requirements; real-device validation pending.

## Core principles
No audio-only alerts or instructions. Use visual notifications and optional vibration. Provide simple English, readable labels, visible status text and icons, non-color-only feedback, and clear error recovery. Optional ISL instructional content should have captions/transcripts and accessible alternatives.

## Minimum targets
WCAG AA contrast targets: 4.5:1 for ordinary text; 3:1 for large text and relevant non-text UI. Touch targets preferably ≥48×48 logical dp. Support system text scaling, reduced motion, keyboard focus order, and screen-reader labels.

## Modal and navigation
Trap focus in active dialogs; isolate background; Escape/back and discard confirmation; restore focus on exit. Provide alternatives to drag-and-drop on project boards.

## Charts
Provide meaningful summaries and accessible tables or per-point descriptions. Never rely on colors alone.

## Platform validation
Android TalkBack and iOS VoiceOver, keyboard/switch navigation, compact and tablet screens, landscape, light/dark modes, dynamic type, reduced motion, notification permissions.

## Evidence
Track device/OS, test steps, expected/actual behavior, screenshots or recordings where appropriate, severity, and retest results. No unperformed test may be marked passed.

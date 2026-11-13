# Audit Fix 04 — UI/UX and Accessibility Testing

Status: automated checks added; real-device audit still pending.

## Automated checks
- 360dp compact screen: bottom navigation, four destinations, Goals action.
- 1000dp wide screen: navigation rail instead of bottom navigation.
- Task edit/delete tooltip labels and progress semantics.
- 390dp screen with 1.5× text scale: navigation and primary Add action.
- Save failures on Today are marked as a semantic live region.

Run `flutter test test/accessibility_layout_test.dart`, `flutter analyze`, and `flutter test`.

## Real-device acceptance matrix (record pass/fail and screenshots)
| Area | iPhone VoiceOver | Android TalkBack | Visual check |
|---|---|---|---|
| Today tasks and habits | Pending | Pending | Compact, large text, dark mode |
| Quick Add and Edit | Pending | Pending | Keyboard, error text, focus |
| Planner | Pending | Pending | Dates and scroll |
| Goals | Pending | Pending | Progress announcement and controls |
| Insights | Pending | Pending | Streak history and reminder actions |
| Dialogs | Pending | Pending | Focus, cancel, close |
| Notifications | Pending | Pending | Visible text without audio |

Test 320dp, 390dp and tablet widths; portrait/landscape; 100%, 150%, and 200% text scale. Check contrast targets 4.5:1 ordinary text, 3:1 large text and controls. Check touch targets near 48dp, reduced motion and non-color-only information. Record device model, OS, actual result, screenshot, severity and retest status. Do not claim VoiceOver/TalkBack pass without testing.

## Known limitations
Widget tests do not prove real screen-reader navigation, color contrast, touch-target dimensions, or notification delivery. The iOS native folder is local/untracked. Preserve it and all Git stashes.

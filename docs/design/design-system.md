# HabitFlow Material 3 Design System — HF-DS-002B / HF-UX-002G

**Status:** Proposed tokens; contrast and device tests pending.

## Seed and semantic colors
Light: primary #6250A4, onPrimary #FFFFFF, primaryContainer #E7DEFF, onPrimaryContainer #30205F, secondary #526178, tertiary #0D8176, error #BA1A1A, background #FAF9FD, surface #FFFFFF, outline #79767F.
Dark: primary #CCBEFF, onPrimary #352565, primaryContainer #493A7B, secondary #B9C7E2, tertiary #88D8CA, error #FFB4AB, background #141318, surface #201F25, outline #938F99.

Always use semantic roles (color.primary, color.onPrimary, color.surface, etc.) rather than feature-specific hardcoded values. Never convey meaning with color alone.

## Type scale
Material 3 display 57/45/36, headline 32/28/24, title 22/16/14, body 16/14/12, label 14/12/11 (font sizes in sp). Respect OS text scaling; never fix container height around long text.

## Spacing and shapes
Spacing 4, 8, 12, 16, 24, 32, 48 dp. Compact page padding 16 dp; cards 16 dp; sections 24 dp. Buttons 48–56 dp, inputs at least 56 dp, touch targets preferably 48×48 dp. Shape radii 4/8/12/16/28/full. Define semantic elevation and focus/pressed/disabled states.

## Component inventory
HFAppScaffold, HFTopAppBar, HFNavigationBar, HFNavigationRail, HFQuickAddSheet, HFCard, HFPrimaryButton, HFSecondaryButton, HFTextField, HFMoneyField, HFCategoryChip, HFStatusIndicator, HFProgressBar, HFProgressRing, HFEmptyState, HFErrorState, HFLoadingState, HFConfirmationDialog; feature-specific HabitCard, TaskCard, GoalCard, FinanceSummary, TransactionRow, MoodSelector, CalendarDay.

## Motion
Button feedback 100–150 ms; navigation and sheets 200–300 ms; disable nonessential motion when reduced motion is requested.

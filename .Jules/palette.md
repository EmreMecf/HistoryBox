## 2024-05-23 - Accessibility in Custom Headers
**Learning:** Custom navigation headers often miss the default accessibility features of `AppBar`. Specifically, `IconButton`s used for back navigation need explicit tooltips.
**Action:** When creating custom headers, always ensure `IconButton`s have `tooltip: MaterialLocalizations.of(context).backButtonTooltip` or a specific label.

## 2024-05-23 - State-Dependent Tooltips
**Learning:** Floating Action Buttons (FABs) that toggle state (like favorites) need dynamic tooltips to accurately describe the action.
**Action:** Use ternary operators in `tooltip` properties to reflect the current state (e.g., "Add to favorites" vs "Remove from favorites").

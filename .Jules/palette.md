## 2024-05-23 - Icon-Only Button Accessibility Pattern
**Learning:** `FloatingActionButton` and other icon-only buttons in this codebase often lack explicit `tooltip` or `semanticsLabel`, relying on default behavior which may not be sufficient for state-dependent actions (e.g., toggling favorites).
**Action:** When working on screens with FABs or IconButtons, always check and explicitly define `tooltip` based on the current state (e.g., "Add to Favorites" vs "Remove from Favorites") using localized strings.

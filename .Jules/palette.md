## 2024-10-24 - Accessibility Pattern: IconButtons
**Learning:** `IconButton` widgets are frequently used without `tooltip` or `semanticsLabel`, making them inaccessible to screen readers. This is a common pattern in the shared widgets.
**Action:** Systematically check all `IconButton` usages and add `tooltip` using `AppLocalizations`.

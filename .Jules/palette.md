# Palette's Journal

## 2024-05-22 - Localized Tooltips in Shared Widgets
**Learning:** `AppLocalizations.of(context)` returns a nullable type, so access must be safe (e.g., `?.getter`). When modifying shared widgets (like `StoryCard`), ensure `AppLocalizations` is available in the context where the widget is used or tested.
**Action:** Always wrap widgets in `MaterialApp` with correct `localizationsDelegates` and `supportedLocales` during testing. Use `?.` for localization strings in widgets that might be used in contexts where localization is optional or failing.

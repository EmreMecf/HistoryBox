## 2026-01-25 - Leveraging MaterialLocalizations for Accessibility
**Learning:** Custom navigation headers often miss localized accessibility labels. Instead of creating new localization keys, `MaterialLocalizations.of(context).backButtonTooltip` provides a standard, localized "Back" string (or equivalent) for free.
**Action:** Always check `MaterialLocalizations` for standard UI strings before adding new keys to ARB files.

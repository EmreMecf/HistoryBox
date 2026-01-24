## 2024-05-22 - Missing Tooltips in Custom Headers
**Learning:** Custom `BackButtonHeader` components using `IconButton` often lack default tooltips, creating a11y gaps.
**Action:** Use `MaterialLocalizations.of(context).backButtonTooltip` for a localized, standard "Back" label without new ARB keys.

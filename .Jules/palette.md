## 2024-05-21 - Accessibility Gaps in Core Navigation
**Learning:** Core navigation elements (App Bar icons, FAB) and shared components (StoryCard) lack accessibility labels/tooltips. The app also mixes hardcoded strings with l10n, making consistent accessible labeling challenging without refactoring.
**Action:** Always check `AppLocalizations` availability but be prepared for hardcoded fallbacks or mixed patterns. Prioritize adding tooltips to icon-only buttons as they are high-impact/low-effort.

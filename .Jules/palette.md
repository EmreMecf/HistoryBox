# Palette's Journal

## 2024-05-22 - Accessibility in Flutter Custom Widgets
**Learning:** Custom interactive widgets (like `GestureDetector`) are invisible to screen readers as buttons unless wrapped in `Semantics`.
**Action:** Always wrap tappable `Container`s or `GestureDetector`s in `Semantics(button: true, label: "Action description", child: ...)` to ensure accessibility.

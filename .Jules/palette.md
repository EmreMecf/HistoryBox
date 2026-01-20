# Palette's Journal

## 2024-05-22 - [Semantics for Custom Buttons]
**Learning:** Custom interactive widgets like `GestureDetector` do not announce themselves as buttons to screen readers by default.
**Action:** Always wrap custom touchable widgets in `Semantics` with `button: true` and appropriate `label`/`onTap`. Use `excludeSemantics: true` to prevent duplicate labels from children like `Text`.

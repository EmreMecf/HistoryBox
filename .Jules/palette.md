## 2024-05-21 - [GestureDetector Accessibility Pattern]
**Learning:** `GestureDetector` provides zero accessibility by default. Wrapping it in `Semantics` is insufficient unless `button: true`, `focusable: true`, and `excludeSemantics: true` (for custom children) are used.
**Action:** Always wrap `GestureDetector` interactive elements in a configured `Semantics` widget.

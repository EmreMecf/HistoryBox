## 2025-05-20 - AnimatedButton Semantics & Test Expectations
**Learning:** `GestureDetector` requires explicit `Semantics` wrapper with `button: true`, `focusable: true` to be correctly identified as a button by screen readers. Furthermore, Flutter widget tests using `matchesSemantics` often require explicit `hasEnabledState: true` expectation when `enabled` is true, otherwise they fail with "unexpected flags: hasEnabledState".
**Action:** Always wrap custom interactive widgets in `Semantics(button: true, focusable: true, ...)` and verify `hasEnabledState` in tests.

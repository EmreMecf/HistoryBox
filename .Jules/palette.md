## 2025-01-31 - Safe Localization Fallbacks
**Learning:** When adding accessibility labels for toggle states (e.g., Favorites) where one state's key is missing from ARB files, blindly modifying ARB files can be risky without the generation tool.
**Action:** Use a hardcoded fallback with a locale check (e.g., `locale == 'tr' ? '...' : '...'`) for the missing state to ensure immediate accessibility improvement without breaking the build, while using existing keys for the available state.

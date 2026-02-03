## 2024-05-22 - Optimistic Favorites
**Learning:** Toggle buttons (like Favorites) require dynamic tooltips that reflect the current state (e.g., 'Add to Favorites' vs 'Remove from Favorites') rather than a static label. Operations modifying remote data should use optimistic local state updates to prevent UI blocking or flickering.
**Action:** Implement optimistic UI updates with revert-on-failure logic and use ternary operators for tooltips based on state.

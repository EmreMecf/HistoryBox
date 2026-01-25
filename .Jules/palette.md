## 2024-05-23 - Optimistic Favorite Toggle
**Learning:** Replacing full-page reloads with optimistic local state updates for "favorite" actions eliminates loading flickers and makes the app feel significantly faster and more responsive.
**Action:** Always implement optimistic UI updates for binary toggle actions (like favorite/like) and only revert on failure, avoiding blocking loading states.

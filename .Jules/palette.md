## 2024-10-27 - Optimistic UI for Engagement Actions
**Learning:** For high-frequency engagement actions like "Favorite" or "Like", users expect immediate feedback. Blocking the UI with a full-screen loading state (even if fast) feels jarring and slow.
**Action:** Always implement optimistic UI updates for binary toggle actions. Update local state immediately, perform the API call in background, and revert state only on failure. This creates a perceived "zero latency" experience.

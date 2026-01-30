## 2024-05-23 - Optimistic UI Updates
**Learning:** Users perceive app performance as "slow" when toggling favorites because of network latency, even if the request is fast.
**Action:** Always implement optimistic UI updates for binary state toggles (like favorites/likes). Update local state immediately, then revert if the network call fails.

## 2024-05-23 - AdService Testability
**Learning:** Singleton services like `AdService` with private constructors are hard to test if instantiated directly (`AdService()`).
**Action:** Always access singletons via the dependency injector (`injector<AdService>()`) in UI code to allow mocking in tests.

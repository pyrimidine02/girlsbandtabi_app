# ADR-20260212: Pull-to-Refresh Coverage and Immediate Logout Cache Clear

## Status
Accepted

## Context
Users requested pull-to-refresh behavior across major pages and immediate cache
disposal at logout. Existing `CacheManager.clearAll()` was a no-op, so logout
did not actually clear cached API data.

## Decision
- Add pull-to-refresh to major data-driven pages and tab lists via
  `RefreshIndicator` with force-refresh controller calls.
- Ensure refresh works even with short/empty lists by using
  `AlwaysScrollableScrollPhysics` on refreshable lists.
- Implement `CacheManager.clearAll()` to remove all keys under the cache
  namespace (`gbt_cache:*`).
- Route settings logout through `AuthController.logout()` and always perform
  local logout cleanup/cache clear even when remote logout fails.

## Alternatives Considered
- Add a single global refresh wrapper at router level (too risky with mixed
  scroll hierarchies and map/platform view pages).
- Keep logout dependent on remote API success (can leave stale local cache and
  auth state when network/API fails).

## Consequences
- Users can consistently pull to refresh on major list-style screens.
- Logout immediately clears cached API entries and resets auth state.
- Non-cache local preferences remain untouched because only namespaced cache
  keys are deleted.

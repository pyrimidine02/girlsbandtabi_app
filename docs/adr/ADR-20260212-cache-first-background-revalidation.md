# ADR-20260212: Cache-First Background Revalidation

## Status
Accepted

## Context
Some read paths used `cacheFirst` to maximize responsiveness, but that can miss
server-side updates until cache expiry or explicit refresh.

## Decision
- Keep `cacheFirst` as the foreground strategy for fast rendering.
- Add background revalidation for cache hits when cached age passes a default
  interval (10 minutes).
- De-duplicate in-flight background refresh tasks by cache key.

## Alternatives Considered
- Switch all `cacheFirst` calls to `staleWhileRevalidate` (too chatty).
- Keep pure `cacheFirst` without probing server updates (stale risk).

## Consequences
- Cached screens remain fast while still checking server changes periodically.
- Duplicate background refresh requests for the same key are avoided.

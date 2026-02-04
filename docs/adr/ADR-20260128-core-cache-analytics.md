# ADR-20260128 Core Cache + Analytics Foundations

## Status
- Accepted

## Context
- Stage 1 requires cache management and analytics foundations.
- The current codebase had LocalStorage and logging but no cache manager or analytics service.
- Firebase configuration may be absent in native projects at this moment.

## Decision
- Add a LocalStorage-backed `CacheManager` with TTL metadata and policy-based resolution.
- Add `AnalyticsService` that safely initializes Firebase Analytics and exposes common event helpers.
- Guard Crashlytics reporting in `AppLogger` and app startup to avoid crashes when Firebase is not configured.

## Alternatives Considered
- Use an in-memory-only cache (rejected: no persistence across launches).
- Introduce a third-party cache library (rejected: keep Stage 1 minimal and controllable).
- Defer analytics entirely (rejected: Stage 1 requirements include analytics/logging foundations).

## Consequences
- Apps without Firebase config files will run with analytics disabled and log a warning.
- Cache clear-all is a no-op until a key registry is added (tracked in TODO).

## References
- docs/GBT_Flutter_Implementation_Plan_v1.3.md (Stage 1)

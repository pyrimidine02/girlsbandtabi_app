# ADR-20260128 Live Stage 6 Events Integration

## Status
- Accepted

## Context
- Stage 6 requires the Live tab to use API-backed event list and detail data.
- Backend DTO shape may differ by key names, so flexible parsing is required.

## Decision
- Implement live events data pipeline (remote datasource → repository with cache → controllers).
- Apply network-first caching with 5-minute TTL for list and detail.
- Update live list/detail UI to consume data and handle loading/error/empty states.

## Alternatives Considered
- Defer integration until full event schema spec is available (rejected: Stage 6 milestone).

## Consequences
- DTO parsing may need adjustment once the backend schema is finalized.

## References
- docs/GBT_Flutter_Implementation_Plan_v1.3.md (Stage 6)
- docs/프런트엔드개발자참고문서_v1.0.0.md (Live events endpoints)

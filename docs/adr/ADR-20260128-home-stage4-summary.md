# ADR-20260128 Home Stage 4 Summary Integration

## Status
- Accepted

## Context
- Stage 4 requires the Home tab to be backed by the `/api/v1/home/summary` endpoint.
- The backend response shape is not fully detailed in the docs, so the client must tolerate field name variations.

## Decision
- Implement a home summary data pipeline (remote datasource → repository with cache → controller).
- Use `CachePolicy.staleWhileRevalidate` with a 5-minute TTL for home summary.
- Parse home summary with flexible field key matching to reduce breakage from minor backend schema differences.

## Alternatives Considered
- Rely on a strictly typed schema with code generation (rejected: missing DTO spec details).
- Skip caching until schema is finalized (rejected: Stage 4 requires caching policy).

## Consequences
- Home UI will render available sections if lists are non-empty; otherwise shows a compact empty state.
- DTO parsing should be revisited once backend confirms exact response fields.

## References
- docs/GBT_Flutter_Implementation_Plan_v1.3.md (Stage 4)
- docs/프런트엔드개발자참고문서_v1.0.0.md (Home summary endpoint)

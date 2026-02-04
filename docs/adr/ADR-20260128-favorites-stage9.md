# ADR-20260128 Favorites Stage 9 Integration

## Status
- Accepted

## Context
- Stage 9 requires saved favorites for places/events and a favorites list UI.
- Backend exposes `/users/me/favorites` with add/remove endpoints.

## Decision
- Implement favorites data pipeline (remote datasource → repository with cache → controller).
- Add favorites list screen and connect home/settings quick access.
- Wire favorite toggles in place/live detail pages.

## Alternatives Considered
- Local-only favorites cache (rejected: server source of truth).

## Consequences
- Favorite payload fields may need adjustment once backend schema is confirmed.

## References
- docs/GBT_Flutter_Implementation_Plan_v1.3.md (Stage 9)
- docs/프런트엔드개발자참고문서_v1.0.0.md (favorites endpoints)

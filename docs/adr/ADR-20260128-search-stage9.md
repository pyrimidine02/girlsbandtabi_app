# ADR-20260128 Search Stage 9 Unified Search

## Status
- Accepted

## Context
- Stage 9 requires unified search across places/events/news and recent search history.
- Backend provides `/api/v1/search` with flexible payload keys.

## Decision
- Implement search data pipeline (remote datasource → repository → controller).
- Cache search results per query for 2 minutes with network-first policy.
- Persist recent searches in LocalStorage (SharedPreferences).
- Update search UI to consume live results with loading/error/empty states.

## Alternatives Considered
- Client-only search using cached lists (rejected: server search is authoritative).

## Consequences
- Query parameter naming (`query`) may need adjustment if backend expects `q`.

## References
- docs/GBT_Flutter_Implementation_Plan_v1.3.md (Stage 9)
- docs/프런트엔드개발자참고문서_v1.0.0.md (search endpoint)

# ADR-20260128 Uploads Stage 9 Integration

## Status
- Accepted

## Context
- Stage 9 includes upload flow via presigned URLs and my uploads list.
- UI should allow viewing/deleting uploads even without file picker integration.

## Decision
- Implement uploads data pipeline (presigned URL request, confirm, list, delete).
- Add My Uploads page and link from Settings.
- Use cache for my uploads with short TTL (5 minutes).

## Alternatives Considered
- Defer uploads until file picker integration (rejected: Stage 9 milestone).

## Consequences
- Upload request payload may need adjustments when backend contract is confirmed.

## References
- docs/GBT_Flutter_Implementation_Plan_v1.3.md (Stage 9)
- docs/프런트엔드개발자참고문서_v1.0.0.md (upload endpoints)

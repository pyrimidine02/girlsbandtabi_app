# ADR-20260128 Places Stage 5 List + Detail

## Status
- Accepted

## Context
- Stage 5 requires the Places tab to show nearby places list and place details.
- Backend DTO shape is not fully specified; client must tolerate key variations.

## Decision
- Implement Places list/detail data pipeline (remote datasource → repository with cache → controllers).
- Apply cache policies: list = cache-first (30 min TTL), detail = network-first (10 min TTL).
- Update UI to render real data in the bottom sheet list and detail screen.

## Alternatives Considered
- Strict DTO mapping with code generation (rejected: schema details missing).
- Defer list/detail until map integration is complete (rejected: Stage 5 requires core place flows).

## Consequences
- Map surface remains placeholder; list/detail are production-ready.
- DTO parsing should be adjusted once backend schema is confirmed.

## References
- docs/GBT_Flutter_Implementation_Plan_v1.3.md (Stage 5)
- docs/프런트엔드개발자참고문서_v1.0.0.md (Places endpoints)

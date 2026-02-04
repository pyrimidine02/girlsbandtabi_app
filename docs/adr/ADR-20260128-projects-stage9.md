# ADR-20260128 Projects Stage 9 Selection

## Status
- Accepted

## Context
- Stage 9 requires project/band selection and unit filtering.
- App-level providers already expose selected project/unit IDs but lack persistence.

## Decision
- Implement projects data pipeline (projects/units) with caching.
- Add selection controller that syncs to LocalStorage and core providers.
- Surface a project selector and unit filter on the Home screen.

## Alternatives Considered
- Keep static project ID in AppConfig (rejected: multi-project UX requirement).

## Consequences
- Project/unit DTO mapping may need adjustment once backend schema is finalized.

## References
- docs/GBT_Flutter_Implementation_Plan_v1.3.md (Stage 9)
- docs/프런트엔드개발자참고문서_v1.0.0.md (projects/units endpoints)

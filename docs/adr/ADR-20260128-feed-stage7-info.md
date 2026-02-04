# ADR-20260128 Feed Stage 7 Info Integration

## Status
- Accepted

## Context
- Stage 7 requires the Info tab (news + community) to use API-backed data.
- Backend payloads may vary, so list/detail parsing must be tolerant.
- Community posts use `projectCode` while other features use `projectId`.

## Decision
- Implement feed data pipeline (remote datasource → repository with cache → controllers).
- Apply cache policies:
  - News list/detail: stale-while-revalidate, 15-minute TTL.
  - Post list/detail: network-first, 3-minute TTL.
- Update Feed/News/Post UI to be data-driven with loading/error/empty states.
- Resolve `projectCode` via AppConfig when present, fallback to `projectId`.

## Alternatives Considered
- Delay feed integration until API schemas are finalized (rejected: Stage 7 milestone).

## Consequences
- DTO parsing and `projectCode` resolution may need adjustment once backend contracts are finalized.

## References
- docs/GBT_Flutter_Implementation_Plan_v1.3.md (Stage 7)
- docs/girlsbandtabi_flutter_agent_guide_v1.0.0.md (Info tab requirements)

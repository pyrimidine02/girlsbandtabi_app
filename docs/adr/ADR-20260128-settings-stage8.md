# ADR-20260128 Settings Stage 8 My Page Integration

## Status
- Accepted

## Context
- Stage 8 requires settings/my page flows for profile management and notification preferences.
- The settings screen should be data-driven and respect authentication state.

## Decision
- Implement settings data pipeline (remote datasource → repository with cache → controllers).
- Add profile edit and notification settings pages under the settings route.
- Cache user profile (10m) and notification settings (5m) with stale-while-revalidate.
- Gate profile and notification screens behind authentication and show login prompts otherwise.

## Alternatives Considered
- Defer settings integration until account APIs are finalized (rejected: Stage 8 milestone).

## Consequences
- DTO parsing keys may need adjustment once backend schemas stabilize.

## References
- docs/GBT_Flutter_Implementation_Plan_v1.3.md (Stage 8)
- docs/girlsbandtabi_flutter_agent_guide_v1.0.0.md (Settings tab requirements)

# ADR-20260308: Home Summary By-Project API Integration

- Date: 2026-03-08
- Status: Accepted
- Scope: `lib/features/home/**`, `lib/core/constants/**`

## Context
- Backend added `GET /api/v1/home/summary/by-project` to return per-project
  home summaries in one response.
- Existing client only consumed `GET /api/v1/home/summary` (single project),
  so project switch flow could surface false empty states.
- Backend now includes `summary.metadata.sourceCounts` and
  `summary.metadata.fallbackApplied`, which should drive empty-state decisions
  and debugging.

## Decision
- Extend API constants and endpoint contract snapshot:
  - `ApiEndpoints.homeSummaryByProject`
  - `/api/v1/home/summary/by-project` method registration.
- Expand home DTO/domain model to include metadata:
  - `sourceCounts` (`places/liveEvents/news`)
  - `fallbackApplied` (`recommendedPlaces/trendingLiveEvents`)
  - new by-project row DTO/domain item (`projectId/projectCode/summary`).
- Update home repository/controller load strategy:
  - try by-project fetch first using active project list identifiers.
  - select selected-project summary from batch response.
  - fallback to single-project API when batch fails or selected row is absent.
- Keep existing live-poster hydration logic and apply it to by-project payloads
  per project row.
- Change home empty-state rule:
  - hard empty: cards empty + `sourceCounts` all zero.
  - soft empty: cards empty + `sourceCounts` has non-zero source rows.

## Alternatives Considered
1. Keep single-project API only.
   - Rejected: does not satisfy by-project contract and increases switch churn.
2. Remove single-project fallback.
   - Rejected: weaker resilience during staged backend rollout.
3. Ignore `sourceCounts` and keep old empty-state condition.
   - Rejected: can misclassify data-prepared states as no-content.

## Consequences
- Home project switching can reuse one batch response path while preserving
  fallback compatibility.
- Empty-state messaging is now aligned with backend diagnostic semantics.
- Home debug logs now include source/fallback metadata for quicker issue triage.

## Validation
- `flutter analyze`
- `flutter test test/features/home/data/home_summary_dto_test.dart test/features/home/domain/home_summary_test.dart test/core/constants/api_endpoints_contract_test.dart`

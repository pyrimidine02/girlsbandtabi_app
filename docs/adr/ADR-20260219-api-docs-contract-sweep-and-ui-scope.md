# ADR-20260219: API Docs Contract Sweep and Scope-aware UI Updates

## Status
- Accepted

## Context
- Backend endpoints and query contracts changed recently, causing drift between
  Flutter client behavior and the live `/v3/api-docs` contract.
- Multiple screens were still using legacy query keys (especially map/filter
  APIs) and had no automated guard to catch path/method drift.
- Search/Home UI did not fully use newly documented scoping parameters
  (`projectId`, `unitIds`), reducing relevance after backend contract changes.

## Decision
- Audit client-used endpoint path/method pairs against live
  `http://localhost:8080/v3/api-docs`.
- Sync endpoint catalog snapshot by adding missing path:
  `/api/v1/admin/users/{userId}/active`.
- Add new endpoint builder:
  `ApiEndpoints.adminUserActive(String userId)`.
- Update API compatibility in datasources:
  - `places/within-bounds`: send `north/south/east/west` + legacy keys.
  - `places/nearby`: send `lat/lon`, `latitude/longitude`, `radius` + legacy
    keys.
  - feed/news list APIs: send `pageable` while keeping `page/size`.
  - search API: support `projectId`, `unitIds`, `types`, `page`, `size`.
- Update UI behavior:
  - Search page: add “현재 프로젝트만” scope toggle and scope label.
  - Home page: reload summary when selected unit filters change.
- Add endpoint contract test to validate each client-used endpoint path/method
  against `ApiV3EndpointCatalog`.

## Alternatives Considered
- Strictly switch to v3 params only and remove all legacy params immediately:
  rejected to avoid backend rollout mismatch risk.
- Manual spot checks without test coverage: rejected due recurring endpoint
  drift and regression risk.

## Consequences
- Client is now tolerant to both legacy and latest query contracts for key map
  and feed endpoints.
- Search/Home UI reflects backend scoping features for more relevant results.
- Endpoint drift is caught earlier via automated contract tests.
- Temporary dual-query compatibility increases request verbosity until backend
  contract is stabilized.

## References
- `lib/core/constants/api_constants.dart`
- `lib/core/constants/api_v3_endpoints_catalog.dart`
- `lib/features/places/data/datasources/places_remote_data_source.dart`
- `lib/features/feed/data/datasources/feed_remote_data_source.dart`
- `lib/features/search/**`
- `lib/features/home/application/home_controller.dart`
- `test/core/constants/api_endpoints_contract_test.dart`

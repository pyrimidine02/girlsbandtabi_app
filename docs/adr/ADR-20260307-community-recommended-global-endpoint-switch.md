# ADR-20260307 Community Recommended Feed Global Endpoint Switch

## Status
Accepted (2026-03-07)

## Context
- Backend introduced a global recommended feed endpoint for mobile:
  - `GET /api/v1/community/feed/recommended`
- Product requirement: `추천` tab must not depend on selected project context.
- Existing mobile feed UI is cursor-based (`nextCursor`, `hasMore`), while the new endpoint is page-based (`page`, `size`, `sort`).

## Decision
1. Switch `추천` feed source to global endpoint:
   - `ApiEndpoints.communityRecommendedFeed`
   - query: `page`, `size`, `sort=createdAt,desc`
2. Use explicit page-based repository method for recommended mode:
   - add `FeedRepository.getCommunityRecommendedFeed(page,size,sort)`
   - `CommunityFeedController` recommended mode loads `page=0` and increments page on load-more.
3. Keep cursor-based contracts for non-recommended modes:
   - following: `GET /api/v1/community/feed/following/cursor`
   - project-specific/latest: `GET /api/v1/projects/{projectCode}/posts/cursor`
4. Remove project-switch forced reload in non-project-dependent modes:
   - `추천/팔로잉` no longer reload only because selected project changed.

## Consequences
### Positive
- Recommended tab is decoupled from `projectCode` and uses one global route.
- Recommended pagination is now explicit (`page`) and easier to reason about.

### Trade-offs
- `hasNext` is inferred by page fill (`items.length >= size`) instead of using pagination metadata because current `ApiClient` unwraps `data` only.
- One extra request can occur at boundary pages when total count is a multiple of `size`.

## Validation
- `dart analyze lib/core/constants/api_constants.dart lib/core/constants/api_v3_endpoints_catalog.dart lib/features/feed/data/datasources/feed_remote_data_source.dart lib/features/feed/data/repositories/feed_repository_impl.dart lib/features/feed/domain/repositories/feed_repository.dart lib/features/feed/application/board_controller.dart test/core/constants/api_endpoints_contract_test.dart`
- `flutter test test/core/constants/api_endpoints_contract_test.dart`

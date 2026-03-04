## ADR-20260302: Community Follow API Integration

### Status
- Accepted

### Context
- The app follow button in user profile used local storage only, so follow state
  diverged from server data and was not shared across devices/sessions.
- Live OpenAPI (`/v3/api-docs`) exposes follow APIs:
  - `GET /api/v1/users/{userId}/follow`
  - `POST /api/v1/users/{userId}/follow`
  - `DELETE /api/v1/users/{userId}/follow`
- Block APIs were already server-backed, so follow needed the same source of
  truth for consistent profile actions.

### Decision
- Replace local follow persistence with API-backed follow state in feed
  community layers:
  - Add follow endpoints to `ApiEndpoints`.
  - Add `UserFollowStatus` domain entity and DTO mapping.
  - Extend `CommunityRemoteDataSource`/`CommunityRepository` with
    `getFollowStatus`, `followUser`, `unfollowUser`.
  - Refactor `UserFollowController` into a per-user (`family`) controller that
    loads/toggles follow via repository.
  - Keep existing block-first UX behavior: follow CTA is disabled when blocked.

### Consequences
- Follow state is now server-authoritative and consistent across sessions.
- User profile follow action reflects backend validation/errors directly.
- Unfollow uses `DELETE` then status refresh to keep UI state reliable with
  204-no-content responses.

### References
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/constants/api_constants.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/application/user_follow_controller.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/data/datasources/community_remote_data_source.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/data/repositories/community_repository_impl.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/user_profile_page.dart`

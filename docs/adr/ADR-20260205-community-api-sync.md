# ADR-20260205 Community API Sync

## Status
- Accepted

## Context
- API docs added community endpoints for author profiles, by-author feeds,
  and post like status/toggles.
- Existing client used favorites for likes and N+1 aggregation for user activity.

## Decision
- Align community data parsing with `authorProfile` payloads.
- Use `/projects/{projectCode}/posts/by-author/{userId}` and
  `/projects/{projectCode}/comments/by-author/{userId}` for profile activity.
- Use `/projects/{projectCode}/posts/{postId}/like` for like state and counts.
- Add `/users/{userId}` lookups for public profiles.

## Alternatives Considered
- Keep the favorites-based like toggle (rejected: conflicts with new API).
- Continue N+1 aggregation for user activity (rejected: now unnecessary).

## Consequences
- Like state now depends on community API and no longer reuses favorites.
- Profile activity loads faster and without extra list fan-out.

## References
- lib/core/constants/api_constants.dart
- lib/features/feed/data/datasources/feed_remote_data_source.dart
- lib/features/feed/data/repositories/feed_repository_impl.dart
- lib/features/feed/application/feed_controller.dart
- lib/features/feed/application/user_activity_controller.dart
- lib/features/feed/presentation/pages/post_detail_page.dart
- lib/features/feed/presentation/pages/user_profile_page.dart
- lib/features/settings/application/settings_controller.dart
- lib/features/settings/data/repositories/settings_repository_impl.dart

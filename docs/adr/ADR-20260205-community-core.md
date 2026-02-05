# ADR-20260205 Community Core Implementation

## Status
- Accepted

## Context
- Community UI existed as mock data only, without API-backed posts/comments.
- Product requires a single project community board with post creation,
  comment submission, and user profile navigation from avatars.

## Decision
- Implement community posts/comments using the existing `/projects/{projectCode}/posts`
  and `/posts/{postId}/comments` APIs.
- Reuse favorites for post “likes” toggling while awaiting official like counts.
- Add a user activity screen that aggregates posts/comments by author using
  existing list endpoints (temporary N+1 approach).

## Alternatives Considered
- Wait for dedicated user-profile/community endpoints (rejected: would keep mock UI).
- Build a separate community module (deferred to reduce scope).

## Consequences
- Community flows are functional but user activity aggregation may be heavy.
- Additional backend endpoints are still desirable for profile data and counts.

## References
- lib/features/feed/data/datasources/feed_remote_data_source.dart
- lib/features/feed/data/repositories/feed_repository_impl.dart
- lib/features/feed/presentation/pages/post_detail_page.dart
- lib/features/feed/presentation/pages/post_create_page.dart
- lib/features/feed/presentation/pages/user_profile_page.dart

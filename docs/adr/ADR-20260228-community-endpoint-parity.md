# ADR-20260228: Community Endpoint Parity with OpenAPI v3

## Status
- Accepted

## Context
- Community APIs changed in the live contract served by
  `http://localhost:8080/v3/api-docs` (OpenAPI `info.version: v1`), and the
  Flutter client only implemented a subset of project/community paths.
- Missing integration paths included cursor/search/trending/bookmark/thread,
  subscription feed, and report/ban management read operations.
- `PostCreateRequest` contract now requires `conversationControl` and
  `mentionedUserIds`, while existing client payload sent only title/content
  (+ optional image uploads).

## Decision
- Sync endpoint constants and v3 catalog snapshot for newly required community
  paths:
  - `/api/v1/community/feed/cursor`
  - `/api/v1/community/subscriptions`
  - `/api/v1/projects/{projectCode}/posts/cursor`
  - `/api/v1/projects/{projectCode}/posts/search`
  - `/api/v1/projects/{projectCode}/posts/trending`
  - `/api/v1/projects/{projectCode}/posts/{postId}/bookmark`
  - `/api/v1/projects/{projectCode}/posts/{postId}/comments/thread`
- Extend feed/community data+domain+repository layers so each endpoint above
  has client methods and DTO/domain mapping.
- Extend moderation/reports integration with:
  - `GET /api/v1/community/reports/me`
  - `GET|DELETE /api/v1/community/reports/{reportId}`
  - `GET /api/v1/projects/{projectCode}/moderation/bans`
  - `GET|POST|DELETE /api/v1/projects/{projectCode}/moderation/bans/{userId}`
- Align post/comment write payloads with latest contract:
  - add default `conversationControl: EVERYONE`
  - add default `mentionedUserIds: []`
  - support optional `parentCommentId` on comment creation
- Wire bookmark endpoint into post detail UI via `PostBookmarkController`.
- Rework board community UX to directly consume endpoint capabilities:
  - mode tabs: latest cursor / trending / subscribed feed cursor
  - query-based search against `posts/search`
  - load-more behavior bound to cursor/page semantics per mode
- Add threaded-comment drill-down UI from post detail using
  `posts/{postId}/comments/thread`.
- Add report-history UX on board for end-users:
  - list via `community/reports/me`
  - detail via `community/reports/{reportId}`
  - cancel action for open/in-review reports.
- Add admin-only ban management UX on board:
  - list via `projects/{projectCode}/moderation/bans`
  - status lookup via `projects/{projectCode}/moderation/bans/{userId}`
  - unban via `DELETE projects/{projectCode}/moderation/bans/{userId}`.
- Add moderator delete actions in UI for posts/comments via
  `moderation/posts/{postId}` and `moderation/posts/{postId}/comments/{commentId}`.
- Expand tests for endpoint contract and new community DTO/repository mappings.

## Alternatives Considered
- Keep current UI-only scope and defer API-layer parity:
  rejected because endpoint drift would continue and block upcoming UI work.
- Implement only constants/catalog without repository/domain wiring:
  rejected because unused constants do not prevent runtime integration gaps.

## Consequences
- Community API surface is now implemented end-to-end at client API layer.
- Bookmark behavior is now live in post detail instead of placeholder UI.
- Board now provides endpoint-native interaction patterns (search/modes/load
  more), reducing client/server behavior mismatch.
- Moderator actions no longer rely on regular author-delete paths for admin
  cleanup operations.
- Report lifecycle endpoints are now reachable in user UI without requiring
  separate admin tools.
- Project-community ban lifecycle endpoints are now reachable in dedicated admin
  UI, reducing reliance on ad-hoc moderation actions.
- Contract drift for new community paths is guarded by automated tests.
- Community-ban management UX now includes in-sheet filter/sort controls for
  operator efficiency without extra API round-trips.

## References
- `http://localhost:8080/v3/api-docs` (checked on 2026-02-28, OpenAPI `v1`)
- `lib/core/constants/api_constants.dart`
- `lib/core/constants/api_v3_endpoints_catalog.dart`
- `lib/features/feed/data/datasources/feed_remote_data_source.dart`
- `lib/features/feed/data/datasources/community_remote_data_source.dart`
- `lib/features/feed/data/repositories/feed_repository_impl.dart`
- `lib/features/feed/data/repositories/community_repository_impl.dart`
- `lib/features/feed/presentation/pages/post_detail_page.dart`
- `test/core/constants/api_endpoints_contract_test.dart`

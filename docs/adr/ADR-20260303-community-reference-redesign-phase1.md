## ADR-20260303: Community Reference Redesign Phase 1 (Profile/Connections)

### Status
- Accepted

### Context
- The user requested a full community redesign inspired by X, Everytime,
  DCInside, Arca Live, Blind, and Toss Community patterns.
- Current user profile/follow UX was partially local-state based and had
  placeholder visual elements that reduced information clarity.
- Follow relationships are now server-authoritative in API v3, including:
  - `GET/POST/DELETE /api/v1/users/{userId}/follow`
  - `GET /api/v1/users/{userId}/followers`
  - `GET /api/v1/users/{userId}/following`

### Decision
- Execute redesign in phases, starting with profile/connections foundation:
  - Introduce server-backed connection list model and repository contracts.
  - Add dedicated followers/following routes and page.
  - Rebuild profile header/action information architecture:
    - identity first (name/bio),
    - direct relationship actions (follow/block/edit),
    - connection navigation tiles (followers/following),
    - content tabs (posts/comments) with pull-to-refresh.
  - Remove non-contractual decorative placeholders from profile header.

### Consequences
- Community UX now shifts toward a dense, text-first interaction model with
  reduced visual noise and faster profile-to-profile traversal.
- Connection data is consistent across sessions/devices because it is API-backed.
- Remaining "full overhaul" scope is explicitly staged:
  - phase 2: board feed hierarchy and post detail alignment,
  - phase 3: moderation/reporting and trust indicators consolidation.

### References
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/user_profile_page.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/user_connections_page.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/application/user_follow_list_controller.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/data/repositories/community_repository_impl.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/router/app_router.dart`

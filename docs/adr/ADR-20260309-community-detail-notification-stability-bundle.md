# ADR-20260309 Community Detail/Notification Stability Bundle

## Status
Accepted

## Context
- Users reported five recurring UX/reliability issues in community/settings:
  1. Post detail from profile activity sometimes failed to render data.
  2. Favorite item detail open flow intermittently failed (especially mixed payload formats).
  3. Notification settings save showed failure too often under rapid toggles.
  4. Like and bookmark semantics were visually ambiguous.
  5. Community realtime refresh latency felt too slow.
- Root causes were spread across routing context, DTO parsing robustness,
  optimistic-save race handling, and refresh cadence policies.

## Decision
- Introduce project-aware post-detail routing hints (`projectCode` query) and
  route-aware post detail/comment providers.
- Harden favorites payload parsing:
  - normalize deeplink/action style IDs,
  - support nested `entity` payload fields,
  - parse optional project reference for post navigation hinting.
- Make notification settings update resilient:
  - serialize rapid toggle writes,
  - retry once on transient network/5xx failures,
  - preserve OFF success UX even when device deactivation follow-up fails.
- Split like vs bookmark UX copy and semantics (`좋아요` vs `저장`).
- Tune realtime policy:
  - reduce SSE throttle,
  - keep short-interval polling as backup even while SSE is connected.

## Consequences
- Mixed-project navigation paths are less likely to resolve the wrong context.
- Rapid settings toggles no longer regress into stale UI state as frequently.
- Users can more clearly distinguish endorsement (`좋아요`) from save intent (`저장`).
- Realtime freshness improves at the cost of slightly increased background
  request frequency.

## Verification
- `flutter analyze`
- `flutter test test/features/favorites/data/favorite_dto_test.dart test/features/settings/application/settings_controller_test.dart test/features/places/application/places_controller_test.dart`

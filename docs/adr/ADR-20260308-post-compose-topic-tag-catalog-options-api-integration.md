# ADR-20260308: Post Compose Topic/Tag Catalog Options API Integration

- Date: 2026-03-08
- Status: Accepted
- Scope: `lib/features/feed/**` (community post compose/edit)

## Context
- Community post compose/edit was using static in-app topic/tag lists.
- Backend now provides managed catalogs via:
  - `GET /api/v1/community/posts/options`
  - `topic`, `tags` optional fields on post create/update.
- Product requirement:
  - compose/edit should prefer server catalog options.
  - if options API fails, writing flow must remain available with free-input
    fallback.

## Decision
- Add a dedicated compose taxonomy options contract in frontend:
  - `ApiEndpoints.communityPostOptions`
  - `PostComposeOptionsDto`, `PostTaxonomyOptionDto`
  - `PostComposeOptions`, `PostTaxonomyOption`
  - `FeedRepository.getPostComposeOptions(forceRefresh: false)`
- Load options on compose/edit entry once and cache for 5 minutes
  (`CachePolicy.cacheFirst`, TTL 5m).
- Use loaded catalog values for:
  - topic single-select sheet options
  - tag suggestion chips
- Keep fallback path:
  - on options API failure (or empty topic catalog), topic switches to
    free-text input sheet.
  - tags stay writable through existing free-input flow.
- Sanitize outgoing tags before submit:
  - normalize (`#`, whitespace cleanup)
  - case-insensitive de-duplicate
  - max 5 items
  - max 16 chars/item

## Alternatives Considered
1. Keep static catalogs only.
   - Rejected: cannot reflect admin taxonomy updates.
2. Block compose when options API fails.
   - Rejected: violates non-blocking fallback requirement.
3. Introduce a separate app-wide state controller for options.
   - Deferred: repository cache already satisfies current UX/perf needs with
     lower complexity.

## Consequences
- Compose/edit UX now follows backend-managed taxonomy without app redeploy.
- Network failures on options endpoint no longer block writing.
- Submit payload quality is improved by client-side tag sanitization.
- `flutter analyze` still reports pre-existing `use_build_context_synchronously`
  info in compose topic sheet invocation points.

## Validation
- `flutter test test/features/feed/data/post_dto_test.dart test/features/feed/presentation/post_compose_components_test.dart`
- `flutter test test/features/feed/application/post_compose_autosave_controller_test.dart test/features/feed/application/post_compose_draft_store_test.dart`
- `flutter analyze lib/features/feed/presentation/pages/post_create_page.dart lib/features/feed/presentation/pages/post_edit_page.dart lib/features/feed/presentation/widgets/post_compose_components.dart lib/features/feed/data/dto/post_dto.dart lib/features/feed/data/datasources/feed_remote_data_source.dart lib/features/feed/data/repositories/feed_repository_impl.dart lib/features/feed/domain/entities/feed_entities.dart lib/features/feed/domain/repositories/feed_repository.dart`

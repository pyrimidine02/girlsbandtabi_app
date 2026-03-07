# ADR-20260308: Post Compose Topic/Tag Selection and Payload Extension

## Status
- Accepted (2026-03-08)

## Context
- Community feed IA was simplified to `추천/팔로잉/프로젝트별`.
- Compose flows (`PostCreatePage`, `PostEditPage`) already support project selection and image attachments, but there was no explicit topic/tag metadata input.
- Product direction now requires users to choose topic/tag while writing posts and to propagate those values through API payloads.
- Current OpenAPI snapshot does not declare `topic`/`tags` in post create/update contracts, so client changes must remain backward-compatible.

## Decision
1. Add compose-level topic/tag controls:
   - topic: single-select bottom sheet
   - tags: add/remove with suggestion chips, duplicate guard, max-count guard
2. Persist topic/tag in local compose draft/autosave state.
3. Extend post create/update request payloads with optional:
   - `topic`
   - `tags`
4. Extend post summary/detail DTO parsing to read optional topic/tag fields if backend includes them.
5. Keep compatibility-first behavior:
   - only include `topic` when non-empty
   - only include `tags` when non-empty
   - no hard dependency on backend read support for rendering.

## Consequences
- Users can attach structured topic/tag metadata during create/edit.
- Draft restore now recovers metadata, not just title/content/images.
- Client is forward-compatible with upcoming backend topic/tag contract rollout.
- Until backend response contract is finalized, edit prefill for old posts may stay empty when topic/tag is not returned.

## Validation
- `flutter analyze lib/features/feed/presentation/pages/post_create_page.dart lib/features/feed/presentation/pages/post_edit_page.dart lib/features/feed/presentation/widgets/post_compose_components.dart lib/features/feed/application/post_compose_autosave_controller.dart lib/features/feed/application/post_compose_draft_store.dart lib/features/feed/data/dto/post_comment_dto.dart lib/features/feed/data/dto/post_dto.dart lib/features/feed/domain/entities/feed_entities.dart lib/features/feed/data/repositories/feed_repository_impl.dart lib/features/feed/domain/repositories/feed_repository.dart test/features/feed/data/post_comment_dto_test.dart test/features/feed/data/post_dto_test.dart test/features/feed/application/post_compose_draft_store_test.dart test/features/feed/application/post_compose_autosave_controller_test.dart`
- `flutter test test/features/feed/data/post_comment_dto_test.dart test/features/feed/data/post_dto_test.dart test/features/feed/application/post_compose_draft_store_test.dart test/features/feed/application/post_compose_autosave_controller_test.dart`

## Follow-up
- Align backend OpenAPI schema for `PostCreateRequest`/`PostUpdateRequest` with `topic`/`tags`.
- Add end-to-end test coverage once backend read/write contract is finalized.

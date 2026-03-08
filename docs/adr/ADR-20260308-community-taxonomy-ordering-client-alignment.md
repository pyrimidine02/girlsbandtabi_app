# ADR-20260308-community-taxonomy-ordering-client-alignment

- Date: 2026-03-08
- Status: Accepted
- Owner: Mobile Frontend

## Context

Community post compose/edit screens were still mixing API catalogs with local
hardcoded topic/tag lists and client-side normalization logic.

- Local constants (`kPostTopicOptions`, `kPostTagSuggestions`) existed in UI.
- Compose pages normalized topic/tag names before rendering.
- This could diverge from backend-managed ordering (`sortOrder ASC, name ASC`)
  and broke the single-source ordering policy from Admin taxonomy management.

## Decision

Mobile app now treats backend taxonomy catalog as the single source of truth
for ordering and runtime options.

1. Compose pages call `getPostComposeOptions(forceRefresh: true)` on entry.
2. UI uses API array order 그대로 (no client sorting/reordering logic).
3. Local hardcoded topic/tag defaults are removed from compose components.
4. On load failure, screen stays usable and exposes retry action.
5. For `401/403`, UI shows login/permission guidance consistently.
6. Empty `topics/tags` arrays are treated as valid and picker actions are
   disabled with 안내 문구.

## Alternatives Considered

- Keep local default lists as fallback:
  - Rejected. Can drift from Admin ordering and violates backend single source.
- Keep free-form fallback mode on taxonomy load failure:
  - Rejected for ordering policy consistency; retry + cache fallback preferred.

## Consequences

- Pros:
  - Admin-managed ordering is reflected consistently in mobile compose flows.
  - Less contract drift risk between backend and app.
  - Better failure UX with explicit retry and auth guidance.
- Cons:
  - Compose metadata selection depends on taxonomy catalog availability.
  - Some existing tests that assume zero network dependency for compose pages
    may need provider overrides in test harness.

## Validation

- `flutter analyze lib/features/feed/presentation/widgets/post_compose_components.dart lib/features/feed/presentation/pages/post_create_page.dart lib/features/feed/presentation/pages/post_edit_page.dart test/features/feed/data/post_dto_test.dart`
- `flutter test test/features/feed/data/post_dto_test.dart test/features/feed/presentation/post_compose_components_test.dart`

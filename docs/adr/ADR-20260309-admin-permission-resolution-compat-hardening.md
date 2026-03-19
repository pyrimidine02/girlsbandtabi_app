# ADR-20260309: Admin Permission Resolution Compatibility Hardening

- Date: 2026-03-09
- Status: Accepted
- Owners: Mobile App Team

## Context

Admin accounts intermittently appeared as non-admin in mobile UI.
Two practical failure patterns were observed:

1. `/api/v1/users/me` payload shape variance
   - mixed naming (`camelCase` vs `snake_case`)
   - legacy role-only fields (`role`, `roles`, `authorities`)
   - role/access aliases (`ROLE_ADMIN`, `super-admin`, etc.)
2. transient profile refresh failures
   - existing resolved profile state could be replaced by error/loading,
     temporarily hiding permission-gated actions.

## Decision

1. Harden access-level parsing in
   `lib/core/security/user_access_level.dart`:
   - normalize role/access tokens (separator + prefix normalization),
   - map common admin/moderator/editor/user aliases to canonical levels.
2. Harden profile DTO compatibility in
   `lib/features/settings/data/dto/user_profile_dto.dart`:
   - support snake_case profile/access keys,
   - derive `accountRole` from legacy role fields when `accountRole` is
     missing,
   - normalize access-level aliases to canonical values.
3. Preserve existing profile state during refresh errors in
   `UserProfileController.load()`:
   - keep prior `AsyncData` profile instead of downgrading to error when
     refresh fails, preventing permission flicker.

## Alternatives Considered

- Keep strict contract-only parsing (`accountRole`, `effectiveAccessLevel`)
  and fail closed on all variants.
  - Rejected: improves strictness but causes practical admin UX regressions
    while backend payloads are mixed across environments.
- Parse role claims directly from JWT for first-load fallback.
  - Deferred: adds auth-claim coupling to settings flow; current fix targets
    response-contract normalization first.

## Consequences

- Positive:
  - admin/moderation UI gates remain stable across payload shape variants.
  - transient `/users/me` refresh errors no longer immediately drop known
    admin UI state.
- Trade-off:
  - temporary compatibility mapping broadens accepted role aliases on mobile.
  - requires follow-up cleanup once backend profile contract is fully stable.

## Validation

- `flutter analyze lib/core/security/user_access_level.dart lib/features/settings/data/dto/user_profile_dto.dart lib/features/settings/application/settings_controller.dart`
- `flutter test test/core/security/user_access_level_test.dart test/features/settings/data/user_profile_dto_test.dart`

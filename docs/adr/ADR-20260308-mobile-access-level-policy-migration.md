# ADR-20260308: Mobile Access-Level Policy Migration

- Date: 2026-03-08
- Status: Accepted
- Owners: Mobile App Team

## Context

Legacy mobile permission checks were based on role-string heuristics
(`ADMIN`, `MODERATOR`, `APP_MANAGER`, etc.).  
Backend permission policy is now contract-driven with:

- `accountRole` (`ADMIN|USER`)
- `effectiveAccessLevel`
  (`USER_BASE|CONTENT_EDITOR|COMMUNITY_MODERATOR|ADMIN_NON_SENSITIVE|PLATFORM_SUPER_ADMIN`)

Continuing role-string branches causes inconsistent gating and compatibility
risk for new APIs (`/admin/users/{userId}/access-level`, `access-grants`).

## Decision

1. Introduce a single access-level resolver in mobile:
   `lib/core/security/user_access_level.dart`.
2. Expand profile DTO/domain to parse and expose:
   `accountRole`, `baselineAccessLevel`, `effectiveAccessLevel`.
3. Migrate critical UI guards to access-level checks:
   settings/admin center visibility, feed/place/post moderation actions.
4. Remove legacy user-facing “권한 요청(VIEWER/EDITOR/MODERATOR)” flow in
   Account Tools and replace with read-only access-level summary tab.
5. Add new admin permission-related endpoint constants and v3 catalog entries.

## Alternatives Considered

- Keep role-string checks and patch per-screen.
  - Rejected: grows inconsistency and fails contract migration goal.
- Hard fail when `effectiveAccessLevel` is unknown.
  - Rejected: causes runtime fragility on forward-compatible payloads.

## Consequences

- Positive:
  - Permission gating follows backend contract.
  - Unknown/new level values are handled safely (feature-restricted fallback).
  - Legacy role payloads still work through resolver fallback mapping.
- Trade-off:
  - Old project role request UI is removed from account tools.
  - Admin grant management UI is not yet implemented in mobile (constants ready).

## Implementation Notes

- Legacy project-role-request stack was fully removed from mobile runtime:
  repository interfaces, remote data source calls, cache profile, DTO/domain
  objects, and provider/controller wiring.
- Endpoint contract tests now track access-grant endpoints instead of
  `/projects/role-requests`.
- Runtime permission guards no longer use legacy role-string fallbacks;
  `effectiveAccessLevel` + `accountRole` is the sole decision input.

## Validation

- `flutter analyze` on touched files: pass
- Tests:
  - `test/core/security/user_access_level_test.dart`
  - `test/features/admin_ops/domain/admin_ops_entities_test.dart`
  - `test/features/settings/data/user_profile_dto_test.dart`

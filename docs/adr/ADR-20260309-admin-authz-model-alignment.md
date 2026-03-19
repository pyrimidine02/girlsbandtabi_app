# ADR-20260309: Admin/Authz Model Alignment (Backend 3-Axis Policy)

- Date: 2026-03-09
- Status: Accepted
- Owners: Mobile App Team
- Source request: `FE-REQ-ADMIN-AUTHZ-MODEL-20260309`

## Context

Backend authorization is based on 3 axes:

1. account role (`UserRole`)
2. effective access level (`UserAccessLevel`)
3. project role (`ProjectRole`)

Mobile had partial mismatches:

- `accountRole=ADMIN` fallback was treated as `ADMIN_NON_SENSITIVE`, while
  backend baseline rule defines admin baseline as `PLATFORM_SUPER_ADMIN`.
- several project-scope moderation/edit guards were global-level only and did
  not account for project roles.
- ops-center guard semantics differed across layers.

## Decision

1. Align account-role fallback to backend baseline:
   - `ADMIN` -> `PLATFORM_SUPER_ADMIN`
   - `USER` -> `USER_BASE`
2. Keep `effectiveAccessLevel` as first-priority source of truth.
3. Introduce project-scope authorization helpers in mobile security layer:
   - `canEditProjectContent(...)`
   - `canModerateProjectCommunity(...)`
   combining global level and project roles.
4. Extend user-profile DTO/domain with project role map support
   (`projectRolesByProject`) and tolerate map/list payload variants.
5. Standardize core ops-center gate (`hasAdminOpsAccess`) to
   `ADMIN_NON_SENSITIVE` or higher.

## Alternatives Considered

- Keep broad role-alias fallback (e.g. infer moderator/editor from accountRole).
  - Rejected: diverges from backend model where `accountRole` is secondary.
- Keep global-only project moderation checks.
  - Rejected: violates backend rule that project roles can grant scope-limited
    moderation/content permissions.

## Consequences

- Positive:
  - mobile role gating now reflects backend baseline/effective-level model.
  - project moderators/editors can be recognized via project roles.
  - settings/admin menu exposure matches actual non-sensitive admin level.
- Trade-off:
  - DTO parser complexity increased due backward-compatible project-role shapes.
  - additional follow-up needed once backend contract for `projectRoles`
    response shape is finalized.

## Validation

- `flutter analyze lib/core/security/user_access_level.dart lib/features/settings/data/dto/user_profile_dto.dart lib/features/settings/domain/entities/user_profile.dart lib/features/feed/presentation/pages/board_page.dart lib/features/feed/presentation/pages/post_detail_page.dart lib/features/places/presentation/pages/place_detail_page.dart`
- `flutter test test/core/security/user_access_level_test.dart test/features/settings/data/user_profile_dto_test.dart test/features/admin_ops/domain/admin_ops_entities_test.dart`

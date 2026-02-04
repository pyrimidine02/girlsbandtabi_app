# ADR-20260202 Auth Guard For Profile Updates

## Status
- Accepted

## Context
- Profile updates (`PATCH /api/v1/users/me`) return 403 with a CSRF-related
  message when no valid auth token is present.
- The UI could attempt updates even when auth state is stale.

## Decision
- Gate profile/notification updates behind `isAuthenticated`.
- Treat CSRF-related 403 responses as `auth_required` to surface a login prompt.
- Use token expiry data to avoid stale authenticated state on app start.
- Clear tokens and transition to unauthenticated when CSRF failures occur on
  protected endpoints.

## Alternatives Considered
- Ignore CSRF errors and rely on backend fixes (rejected: user experience).
- Implement CSRF token fetching (rejected: not documented in OpenAPI).

## Consequences
- Profile updates no longer fire when the app is unauthenticated.
- Users are prompted to log in when CSRF-related 403 errors occur.

## References
- lib/core/error/error_handler.dart
- lib/core/providers/core_providers.dart
- lib/features/settings/application/settings_controller.dart

# ADR-20260202 Auth Refresh Failure State

## Status
- Accepted

## Context
- Token refresh failures (e.g., 500 from `/auth/refresh`) left the app in an
  authenticated state, causing repeated 401s on protected endpoints.

## Decision
- Notify the auth state provider when token refresh fails so the app transitions
  to an unauthenticated state immediately.

## Alternatives Considered
- Rely on the next app restart to re-check auth (rejected: leaves noisy errors).
- Add per-endpoint guards only (rejected: auth state should be authoritative).

## Consequences
- Protected calls stop once refresh fails and UI can redirect to login.

## References
- lib/core/network/api_client.dart
- lib/core/providers/core_providers.dart

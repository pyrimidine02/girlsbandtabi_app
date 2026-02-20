# ADR-20260218: Preserve Session on Transient Refresh Failures

## Status
Accepted

## Context
Users reported being logged out when pulling to refresh on Home.

The client previously cleared tokens on any refresh failure path:
- `401` original request -> refresh attempt -> any failure => clear tokens.
- `403` with CSRF-like payload => clear tokens immediately.

This caused false logout on transient backend/network failures unrelated to
actual credential invalidation.

## Decision
- Classify refresh outcomes as:
  - `refreshed`: new access/refresh tokens issued.
  - `invalidSession`: refresh token is definitively invalid.
  - `transientFailure`: timeout/network/server/temporary parsing failure.
- Clear tokens and trigger unauthenticated state **only** for
  `invalidSession`.
- Preserve tokens/session for `transientFailure` and return the request error
  to the caller.
- Preserve tokens on CSRF-like `403` responses (log warning only).
- Deduplicate concurrent `401` refresh attempts by sharing one in-flight
  refresh future across requests.
- When refresh returns `429`, honor short `retryAfter` windows and retry the
  refresh once before failing.

## Alternatives Considered
- Keep existing behavior (fast logout on any refresh error): simple but causes
  frequent false logout and poor UX.
- Add global retry/backoff before logout: improves resilience but still risks
  forced logout without clear invalid-session evidence.

## Consequences
- Pull-to-refresh and parallel foreground requests no longer log users out on
  temporary failures.
- Explicit invalid refresh-token responses still force logout consistently.
- Some CSRF/backend misconfiguration cases now surface as request errors
  instead of forced logout, which is safer for mobile JWT flows.
- Startup bursts that trigger brief refresh rate limits can self-recover
  without user-visible forced logout.

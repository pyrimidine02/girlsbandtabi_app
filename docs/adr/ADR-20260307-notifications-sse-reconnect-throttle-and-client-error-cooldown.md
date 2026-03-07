# ADR-20260307 Notifications SSE Reconnect Throttle And Client Error Cooldown

## Status

Accepted (2026-03-07)

## Context

- Mobile logs showed sustained reconnect churn on
  `GET /api/v1/notifications/stream`.
- Failure patterns included:
  - `HTTP 401/403` (auth/session failure)
  - `HTTP 400/404` (request/route contract mismatch)
  - transport failures (`connection refused`, early connection close)
- Existing reconnect flow retried aggressively enough to create:
  - repetitive error logs
  - unnecessary network/battery usage
  - noisy debugging signal.

## Decision

`NotificationsController` reconnect behavior is changed to classify failures and
apply cooldown/backoff policies:

- Client/auth failures:
  - `401/403` -> reconnect cooldown `5m`
  - `400/404` -> reconnect cooldown `10m`
- Transport failures:
  - continue reconnect with exponential backoff + bounded jitter.
- Duplicate log suppression:
  - same failure signature logs are rate-limited (2-minute window).

Polling fallback remains active during cooldowns/failures.

## Consequences

### Positive

- Removes tight SSE retry loops under persistent client/auth failures.
- Reduces CPU/network churn and log spam without removing realtime support.
- Keeps notification data available via existing polling path.

### Tradeoffs

- Realtime recovery after `400/401/403/404` is delayed by cooldown duration.
- If backend fixes happen immediately, SSE reconnection is not instant.

## Alternatives Considered

- Disable SSE permanently after first client error.
  - Rejected: too strict, requires manual app lifecycle/auth cycle to recover.
- Retry all errors with identical backoff.
  - Rejected: still noisy and wasteful for deterministic client/auth failures.

## Verification

- `flutter analyze lib/features/notifications/application/notifications_controller.dart`
- Runtime QA checklist added in `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/TODO.md`.

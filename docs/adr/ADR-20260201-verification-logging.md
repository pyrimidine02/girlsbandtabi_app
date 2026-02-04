# ADR-20260201 Verification Debug Logging

## Status
- Accepted

## Context
- Place verification requests still return HTTP 400 without exposing server
  error payloads in the current logs.
- The existing network logger only prints method/URL/status, which is
  insufficient for diagnosing validation failures.

## Decision
- Log request query/body and response/error bodies in the Dio logging
  interceptor, with basic redaction of token-like fields.

## Alternatives Considered
- Add temporary print statements at call sites (rejected: scattered, harder to
  remove).
- Add UI-level error surface for raw server messages (deferred: UX review
  needed).

## Consequences
- Debug logs now expose request/response bodies in dev builds, enabling quick
  identification of server validation errors.
- A follow-up task is added to reduce verbose logging once verification issues
  are resolved.

## References
- lib/core/network/api_client.dart
- TODO.md

# ADR-20260201 Live Event Manual Verification

## Status
- Accepted

## Context
- `docs/place-verification-endpoints.md` specifies that verification requests
  can use `verificationMethod` and provides a live event example with
  `verificationMethod: "MANUAL"`.
- Current client sends the `/verification/challenge` nonce as `token`, which is
  not a JWE location token and can trigger `VERIFICATION_FAILED` responses.

## Decision
- Send live event verification requests with `verificationMethod: "MANUAL"`
  when no location token is available, skipping the challenge token path for
  those requests.

## Alternatives Considered
- Implement full location token (JWE) generation immediately (deferred:
  requires cryptography + location pipeline).
- Require latitude/longitude payloads for all verifications (deferred:
  location collection not wired yet).

## Consequences
- Live event verification can proceed without a JWE token.
- Place verification still relies on the challenge token path until a proper
  location token or GPS payload is added.

## References
- docs/place-verification-endpoints.md
- lib/features/verification/data/repositories/verification_repository_impl.dart
- lib/features/verification/application/verification_controller.dart
- lib/features/live_events/presentation/pages/live_event_detail_page.dart

# ADR-20260201 Place Verification Location Payload

## Status
- Accepted

## Context
- Place verification requests returned HTTP 400 because the client sent the
  challenge nonce as the `token` field.
- `docs/place-verification-endpoints.md` specifies that `VerificationRequest`
  requires either a JWE location token or a raw latitude/longitude payload.
- JWE token generation is not implemented yet, but location permissions are
  already present in the native manifests.

## Decision
- Introduce a `LocationService` that resolves the current device location with
  permission checks.
- Use latitude/longitude/accuracy payloads for place verification requests.
- Keep live-event verification using the `verificationMethod` payload.

## Alternatives Considered
- Implement JWE token generation using challenge/config immediately (deferred:
  requires crypto + key handling work).
- Continue sending the challenge nonce as `token` (rejected: violates spec and
  yields 400 responses).

## Consequences
- Place verification now depends on location permissions and enabled location
  services; failures surface as `LocationFailure` messages.
- Challenge tokens are no longer fetched as part of place verification until the
  JWE flow is implemented.

## References
- docs/place-verification-endpoints.md
- lib/core/location/location_service.dart
- lib/features/verification/data/repositories/verification_repository_impl.dart
- lib/features/verification/application/verification_controller.dart
- test/features/verification/data/verification_repository_impl_test.dart

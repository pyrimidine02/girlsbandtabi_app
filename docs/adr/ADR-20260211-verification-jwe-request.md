# ADR-20260211: Verification JWE Request Payload

## Status
Accepted

## Context
The verification endpoints now require a JWE location token in the request body
(`token`), as defined in the latest OpenAPI spec. The client previously sent
raw latitude/longitude/accuracy fields, which results in 400 errors
("JWE location token is required").

## Decision
- Generate a JWE token by combining the server challenge (nonce), verification
  config, and device location.
- Send `token`, `verificationMethod`, and `evidence` fields in verification
  requests, removing the raw location payload.
- Accept verification config public keys in JWK JSON, PEM, or base64-encoded
  PEM formats, and fall back to RSA-OAEP-256 when the config advertises `dir`
  with an asymmetric key.
- Register a per-device public key (`POST /verification/keys`) and store the
  private key securely on the client.
- Wrap location claims as a claims JWS (`RS256`, `kid` header, JSON payload)
  and then encrypt the compact JWS using JWE (`RSA-OAEP-256`) and `cty=JWT`.
- Keep the payload aligned with `LocationClaim` (lat/lon/accuracyM/timestamp/
  isMocked/mockProvider) and move nonce to a protected header when available.
- Update verification repository tests to assert the new payload shape.

## Alternatives Considered
- Keep raw location payload and request a backend fallback.
- Add a temporary feature flag to switch between raw and token payloads.

## Consequences
- Verification requests align with the OpenAPI contract and avoid 400 errors.
- Token generation becomes a required dependency for verification flows.
- Tests must cover token payload forwarding and token generation behavior.
- The client can handle current key formatting inconsistencies without blocking
  verification flows.
- JWE payload format aligns with server expectations by nesting a claims JWS.
- Claims fields now match the server `LocationClaim` DTO to avoid parse errors.
- Device key registration must succeed before verification can proceed.

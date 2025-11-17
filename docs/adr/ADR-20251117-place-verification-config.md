# ADR-20251117: Align place verification tokens with backend config

## Status
Accepted

## Context
- The verification backend now exposes `/api/v1/verification/config` containing the active public keys plus tolerance/time-skew values, and it expects every client token to be encrypted with RSA-OAEP-256 (key wrapping) + A256GCM (content).
- The existing mobile client cached a hard-coded config, defaulted to whatever `jweAlg` happened to be, and never retried when keys rotated. When the server returned an empty `publicKeys` array or rotated the key, the client surfaced only a generic error.
- The backend also rejects tokens whose timestamp deviates by more than ±60 seconds, so stale tokens (e.g., created before a retry) must be regenerated immediately.

## Decision
- Introduced `VerificationConfig` to model the config payload (public keys, algorithms, tolerances) and cache it in `VerificationService`, with explicit invalidation/refresh support.
- `buildLocationToken` now always uses the config’s primary RSA public key with RSA-OAEP-256/A256GCM, embeds `lat/lon/accuracyM/timestamp`, and nests the payload inside an unsecured JWT (`cty: JWT`, `alg: none`) before encryption so the server’s double-layer parsing succeeds.
- `PlaceVerificationController` requests tokens via `_sendVerification`, and if the server responds with retryable errors (token invalid/expired, key mismatch, clock skew), it automatically invalidates the cached config, regenerates a fresh token (new timestamp) with the updated key, and retries once before surfacing the error.
- Errors from missing keys still bubble up as user-facing messages, and the controller records the backend `resultCode` for debugging.
- While fetching the config we also read the HTTP `Date` header and compute a clock-offset so token timestamps are aligned to server time, avoiding `Invalid location token` results when the device clock drifts beyond ±60 seconds.

## Consequences
- Verification now tolerates backend key rotation or timestamp drift without manual user intervention, provided a second attempt succeeds.
- Any future config changes only require adjusting `VerificationConfig.fromJson` and the retry heuristics instead of touching the entire verification flow.
- Because the config is cached, normal verifications remain fast, but we have explicit hooks to refresh on demand.

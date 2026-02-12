# ADR-20260211: Verification Key Reset On User Change

## Status
Accepted

## Context
Verification tokens are signed with a per-device JWS key registered to the
current user. When switching accounts, the app reused a stored key and skipped
registration, causing backend failures like "Location JWS key not found".

## Decision
- Parse the access token subject (`sub`) after login.
- If the stored user ID differs from the new subject (or is missing), clear
  the verification key material so a fresh key is generated and registered.
- When the backend returns "Location JWS key not found", clear the verification
  key material and retry once with a newly registered key.

## Alternatives Considered
- Register the same key again for the new user without clearing local storage.
- Key verification storage by user ID (more extensive change).

## Consequences
- Account switches trigger a clean device-key registration flow.
- The verification experience no longer fails due to mismatched keys.
- One-time retry helps recover from missing server-side key registration.

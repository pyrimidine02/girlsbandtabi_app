# ADR-20260212: Verification Token Required Fields

## Status
Accepted

## Context
The backend requires verification tokens to include required location fields
(`lat`, `lon`, `timestamp`) and prefers optional fields to be present as well
(`accuracyM`, `isMocked`, `mockProvider`). The token should reflect the actual
capture time from the location API rather than an arbitrary current time.

## Decision
- Always include `lat`, `lon`, and `timestamp` (epoch seconds).
- Always include optional fields `accuracyM`, `isMocked`, and `mockProvider`.
- Use the location snapshot timestamp when available.

## Alternatives Considered
- Omit optional fields when not mocked (inconsistent payload schema).
- Use current time instead of the position timestamp (less accurate).

## Consequences
- Token payloads are schema-stable for backend validation.
- Mock provider defaults to a non-empty placeholder when not mocked.

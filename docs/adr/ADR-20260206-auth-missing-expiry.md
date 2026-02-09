# ADR-20260206: Auth Tokens Without Expiry

## Status
Accepted

## Context
Some auth responses do not include `expiresAt`/`expiresIn`. The client marked
those tokens as expired at startup, forcing users to log in again even though
valid refresh tokens were stored.

## Decision
- Treat missing expiry timestamps as "unknown" rather than expired.
- Keep the session authenticated and rely on refresh/401 handling to correct
  invalid tokens.

## Alternatives Considered
- Force logout when expiry is missing.
- Attempt refresh during startup (requires wiring repository into auth state).

## Consequences
- Users remain logged in across app restarts even if expiry is not provided.
- Invalid tokens will be cleared when refresh fails or a 401 occurs.

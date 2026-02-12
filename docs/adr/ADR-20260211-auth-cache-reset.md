# ADR-20260211: Auth-Scoped Cache Reset

## Status
Accepted

## Context
Profile and notification caches were stored under shared keys
(`user_profile`, `notification_settings`). When switching accounts, the app
could display stale data from the previous user until a refresh succeeded,
which is confusing and can surface the wrong account identity.

## Decision
- Clear auth-scoped caches on login/registration/OAuth completion and logout.
- Keep the change localized to the auth controller to avoid broad refactors.

## Alternatives Considered
- Key caches by user subject ID (requires token parsing + wider changes).
- Disable caching for user-scoped data entirely.

## Consequences
- Account switching no longer reuses stale profile/notification data.
- A fresh fetch is triggered after authentication, with a small extra request
  cost.

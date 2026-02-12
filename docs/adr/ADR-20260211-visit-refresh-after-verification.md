# ADR-20260211: Refresh Visits After Verification

## Status
Accepted

## Context
Visit history is cached with a stale-while-revalidate policy. After a successful
place verification, users could navigate to visit history and still see stale
data because the cache refresh happens in the background without updating UI.

## Decision
- After a successful place verification (including retry flows), trigger a
  forced reload of visit history and invalidate visit summary/ranking providers.

## Alternatives Considered
- Always force refresh when opening the visit history page.
- Remove caching for visit history.

## Consequences
- New visits appear immediately after verification.
- Adds a small extra network request after verification.

# ADR-20260211: Settings Back Navigation Guard

## Status
Accepted

## Context
The Settings page is sometimes opened as a top-level route. In that case,
calling `context.pop()` raises a `GoError: There is nothing to pop`, which
breaks the back button gesture.

## Decision
- Guard the Settings back button with `context.canPop()` before calling `pop()`.
- When no back stack is present, return to the recorded previous route (`from`)
  and fall back to `/home` if unavailable.

## Alternatives Considered
- Always `go('/')` when there is no back stack.
- Use `Navigator.maybePop()` with a fallback route.

## Consequences
- The Settings back button no longer throws when opened as a root route.
- The Settings back button returns to the previous route when possible, or
  `/home` when no history is available.

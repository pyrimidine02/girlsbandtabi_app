# ADR-20260206: Verification Codegen Cleanup

## Status
Accepted

## Context
`flutter analyze` failed due to stale/generated verification DTO files that
referenced domain types removed from the current verification model, and a
`FutureProvider` repository that was consumed synchronously in token services.

## Decision
- Remove the unused `verification_dtos.dart` artifacts that were no longer
  referenced in the verification flow.
- Convert the verification repository provider to a synchronous `Provider`,
  matching its construction and simplifying consumers.

## Alternatives Considered
- Re-introduce the removed domain entities to satisfy the stale DTOs.
- Keep the async provider and wrap token services in `FutureProvider`.

## Consequences
- Code generation and analyzer run cleanly.
- Verification repository access is now synchronous, matching its dependencies.

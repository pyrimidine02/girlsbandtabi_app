# ADR-20260128 Stage 2 Common Widgets

## Status
- Accepted

## Context
- Stage 2 requires common UI widgets for navigation and images.
- Main scaffold had an internal bottom nav implementation, and there was no shared image widget.

## Decision
- Extract bottom navigation into `GBTBottomNav` with reusable item definitions.
- Add `GBTImage` with cached network loading, shimmer placeholder, and accessibility semantics.
- Keep shimmer implementation local (existing `GBTShimmer`) to avoid extra dependencies.
- Align card widgets to use `GBTImage` for consistent image loading behavior.

## Alternatives Considered
- Keep bottom nav private inside `MainScaffold` (rejected: reduces reuse and discoverability).
- Use a third-party shimmer package (rejected: existing in-house shimmer is sufficient).

## Consequences
- `MainScaffold` now depends on `GBTBottomNav` for tab navigation UI.
- `GBTImage` provides a standard image path for upcoming screens.
- Event/place cards now share the same image loading and placeholder behavior.

## References
- docs/GBT_Flutter_Implementation_Plan_v1.3.md (Stage 2)

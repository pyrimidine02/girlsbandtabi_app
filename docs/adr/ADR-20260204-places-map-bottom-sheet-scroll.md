# ADR-20260204 Places Map Bottom Sheet Scroll

## Status
- Accepted

## Context
- The map bottom sheet used a fixed Column layout.
- On smaller sheet heights, the header content overflowed and triggered a
  RenderFlex overflow.

## Decision
- Replace the fixed Column with a `CustomScrollView` using slivers.
- Move the header, filter chips, and segmented control into slivers so they can
  scroll with the list content.

## Alternatives Considered
- Increase the bottom sheet minimum height (rejected: still fragile).
- Hide header controls on small heights (rejected: loses functionality).

## Consequences
- The bottom sheet content is fully scrollable and no longer overflows at
  minimum height.
- Header controls remain accessible by scrolling.

## References
- lib/features/places/presentation/pages/places_map_page.dart

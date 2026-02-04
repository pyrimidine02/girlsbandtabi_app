# ADR-20260204 Places List Unfiltered by Unit

## Status
- Accepted

## Context
- The app currently inherits selected unit IDs from the global project
  selector, which causes the places list to show a reduced subset.
- The product requirement is to always show the full places list unless a
  dedicated places filter is applied.

## Decision
- Stop applying the global selected unit IDs to the places list requests.
- Keep region filters and list mode toggles as explicit, user-driven filters.

## Alternatives Considered
- Add a unit filter toggle in the places UI (rejected: not requested yet).

## Consequences
- The places list always reflects the full project dataset.
- Unit selection continues to affect other features but not the places list.

## References
- lib/features/places/application/places_controller.dart

# ADR-20260204 Band Filters Per Page

## Status
- Accepted

## Context
- The global unit filter was shown on the initial screen.
- Product requirement: do not show unit filtering on the initial screen and
  instead allow band selection per tab (Places, Live).

## Decision
- Remove the unit filter button from the project selector.
- Add per-page band selection using project units on Places and Live pages.
- Apply selected band IDs to `unitIds` query parameters for those endpoints.

## Alternatives Considered
- Keep global unit filter (rejected: conflicts with UX requirement).
- Add a single global band filter (rejected: needs product confirmation).

## Consequences
- Users can filter Places/Live independently by band.
- The initial screen no longer exposes unit filtering.

## References
- lib/features/projects/presentation/widgets/project_selector.dart
- lib/features/projects/presentation/widgets/band_filter_sheet.dart
- lib/features/places/application/places_controller.dart
- lib/features/places/presentation/pages/places_map_page.dart
- lib/features/live_events/application/live_events_controller.dart
- lib/features/live_events/presentation/pages/live_events_page.dart

# ADR-20260202 Places Map Integration and Region Filter

## Status
- Accepted

## Context
- The Places map screen still showed a placeholder instead of a real map.
- Users requested a region filter to narrow down the places list and markers.

## Decision
- Render real maps in the Places tab:
  - iOS uses Apple Maps via `apple_maps_flutter`.
  - Android uses Google Maps via `google_maps_flutter`.
- Show map markers for the current places list and allow tapping to open
  the place detail screen.
- Add a region filter powered by the Places Regions API:
  - Fetch options from `/places/regions/available`.
  - Filter places via `/places/regions/filter`.
  - Recenter the map using `/places/regions/map-bounds`.
  - If slug-based calls fail, retry with the project UUID.
- Add a list mode toggle to switch between nearby places (location-based) and
  the full project list.

## Alternatives Considered
- Use only Google Maps across platforms (rejected: requested Apple Maps on iOS).
- Filter locally with `regionSummary` only (rejected: API provides dedicated
  region filter endpoints).

## Consequences
- Maps now render on device; iOS requires the embedded views plist key.
- Android still needs `MAPS_API_KEY` injected at build time for Google Maps.
- Region filter now follows the backend contract and map bounds data.

## References
- lib/features/places/presentation/pages/places_map_page.dart
- lib/features/places/domain/entities/place_entities.dart
- lib/features/places/data/datasources/places_remote_data_source.dart
- ios/Runner/Info.plist

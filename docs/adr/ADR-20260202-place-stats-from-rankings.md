# ADR-20260202 Place Stats From Rankings

## Status
- Accepted

## Context
- Place detail UI shows visit count and rating, but the place detail API does
  not provide those fields.
- The backend exposes public rankings endpoints that include `totalVisits` and
  `favoriteCount` per place.

## Decision
- Fetch place visit/like stats from the rankings endpoints and attach them to
  the place detail view model.
- Display visit counts from `most-visited` rankings and likes from
  `most-liked` rankings.

## Alternatives Considered
- Wait for backend to add stats directly to place detail (rejected: leaves UI
  empty).
- Use admin analytics endpoints (rejected: requires admin access).

## Consequences
- Place detail stats populate for places present in ranking responses.
- Places with no ranking entry display 0 for those stats.

## References
- lib/features/places/data/datasources/places_remote_data_source.dart
- lib/features/places/data/repositories/places_repository_impl.dart
- lib/features/places/presentation/pages/place_detail_page.dart

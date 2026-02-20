# ADR-20260219: Place Type Search in Map Search Sheet

## Status
- Accepted

## Context
- Users can search places from the map search sheet, but matching previously used only place/region names.
- Place list responses already include `types`, but the app discarded that field in `PlaceSummary`.
- As a result, entering place-type keywords (for example `촬영지`, `성지`, `live_house`) did not return expected places.

## Decision
- Preserve `types` in `PlaceSummary` so map/list UIs can use type metadata without an additional detail API call.
- Add a shared place-type search utility that:
  - normalizes query/type strings (`snake_case`, whitespace, case),
  - expands known synonyms (EN/KO),
  - provides a user-facing type label formatter.
- Update the map search sheet to match by:
  - place name,
  - region name,
  - place type keywords/synonyms.
- Show compact type labels in search result subtitles to make match reasons visible.

## Alternatives Considered
- Server-only type search via a dedicated endpoint: rejected for now because the map sheet already has in-memory place data and needs instant local filtering.
- Naive string replace (`_` -> space) without synonym expansion: rejected because Korean type keywords (`성지`) would still fail.

## Consequences
- Place type input now returns matching places in the map search sheet.
- The mapping logic for place-type display/search is centralized and reusable.
- Synonym coverage remains an app-managed table and needs periodic updates if backend type taxonomy changes.

## References
- `lib/features/places/domain/utils/place_type_search.dart`
- `lib/features/places/presentation/pages/places_map_page.dart`

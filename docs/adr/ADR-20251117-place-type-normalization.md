# ADR-20251117: Normalize Place Type decoding

## Status
Accepted

## Context
- Recent API responses for `GET /projects/{id}/places/{placeId}` started returning type values like `"filming_location"` and `types: ["filming_location"]` instead of the older camelCase identifiers (e.g., `"animeLocation"`).
- `Place`/`PlaceSummary` used `PlaceType` enums without any custom converter, so `json_serializable` expected the camelCase representation and threw when new snake_case values arrived. The crash bubbled up to `PlaceDetailScreen`, which showed the generic "성지 정보를 불러올 수 없습니다" message even though the backend responded with data.
- `PlaceList`, `PlaceMap`, and `Pilgrimage` screens also assumed camelCase strings when mapping icons/labels, so even if parsing succeeded, the UI would explode when iterating types.

## Decision
- Introduce `PlaceTypeCodec` to normalize API strings (snake_case, camelCase, and legacy synonyms) into the existing `PlaceType` enum and to serialize enums back to the API-friendly snake_case identifiers.
- Update `PlaceSummary`, `Place`, and `PlaceCreateRequest` models to use the codec via `@JsonKey` hooks so decoding happens centrally, including converting the `types` array into `List<PlaceType>`.
- Remove ad-hoc type parsing logic (e.g., in `UserService`) in favor of the shared codec and update all UI helpers to accept typed `PlaceType` values directly.

## Consequences
- Detail/List/Map/Pilgrimage screens no longer throw when the API returns new place type strings and continue to display consistent icons/labels by falling back to `PlaceType.other` when unknown values appear.
- `PlaceCreateRequest` now emits snake_case identifiers, aligning the payloads with the backend contract.
- Future type additions only need to update `PlaceTypeCodec` (and optionally the UI label/icon) without touching JSON parsing logic spread across the app.

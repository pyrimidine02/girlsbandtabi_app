# ADR-20260305 Place Directions JP Deeplink

- Date: 2026-03-05
- Status: Accepted

## Context

- Backend contract added `directions` to place summary/detail responses.
- `directions` is populated only for JP places (`regionCode` starts with `JPN`), and null for non-JP.
- Frontend must render a directions CTA only when server provides providers, and must use server `url` as-is.

## Decision

- Added DTO contract mapping:
  - `PlaceDirectionsDto`
  - `PlaceDirectionProviderDto`
  - wired into `PlaceSummaryDto` and `PlaceDetailDto`
- Added domain mapping:
  - `PlaceDirections`
  - `PlaceDirectionProvider`
  - wired into `PlaceSummary` and `PlaceDetail`
- Added shared launcher utility:
  - `showPlaceDirectionsSheet(...)` in `place_directions_launcher.dart`
  - provider list shown from server `label`
  - provider URL opened as server `url` without client-side URL generation
  - launch strategy: external app first, browser fallback second
  - provider order recommendation only (`iOS: apple_maps first`, `Android: google_maps first`)
- Applied UI:
  - Place detail page: `길안내` tonal CTA shown only when providers exist
  - Places map bottom-sheet list cards: compact `길안내` icon button shown only when providers exist

## Alternatives Considered

- Hardcoding per-provider URL templates in frontend:
  - Rejected due to contract drift risk and duplicate logic with backend.
- Applying CTA only in detail page:
  - Rejected because request explicitly included card/detail exposure.

## Consequences

- JP place entries can directly deep link to provider map apps.
- Non-JP places stay unchanged because `directions` null keeps CTA hidden.
- Future provider additions can be absorbed without frontend URL logic changes as long as backend returns `provider/label/url`.

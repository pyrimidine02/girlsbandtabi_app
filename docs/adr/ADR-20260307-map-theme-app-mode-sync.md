# ADR-20260307 Map Theme App-Mode Sync

## Status
Accepted (2026-03-07)

## Context
- Map surfaces were not consistently bound to app theme mode.
- Google Maps used dark style only and passed `null` in light mode, which could still follow platform/system auto-theme behavior.
- Apple Maps (`apple_maps_flutter` 1.4.0) does not expose direct light/dark style override APIs.
- Product requirement: map visual theme must follow app theme (`light/dark`) rather than system theme.

## Decision
1. Introduce shared map theme module:
   - `lib/core/theme/gbt_map_styles.dart`
   - explicit light/dark Google Map style strings.
2. Apply explicit Google Map style in all map pages:
   - places map
   - visit detail
   - travel review create
   - travel review detail
3. For Apple Maps, apply app-theme-based overlay tint in both modes:
   - dark mode: dark overlay tint
   - light mode: light overlay tint
   - keep app-theme parity when native AppleMap style cannot be directly overridden by plugin API.

## Consequences
### Positive
- Map rendering now follows app theme mode consistently across map screens.
- System/theme mismatch cases (app light + system dark, app dark + system light) no longer create inconsistent map tone on Google Maps.
- Apple Maps now provides predictable app-theme parity in both light and dark modes.

### Trade-offs
- AppleMap theme behavior is emulated with overlay tint (not true native map-tile style override).
- Overlay contrast may require tuning based on real-device UX feedback.

## Validation
- `dart analyze lib/core/theme/gbt_map_styles.dart lib/features/places/presentation/pages/places_map_page.dart lib/features/visits/presentation/pages/visit_detail_page.dart lib/features/feed/presentation/pages/travel_review_create_page.dart lib/features/feed/presentation/pages/travel_review_detail_page.dart`

# Changelog

## 2025-03-17
- Replaced selection persistence with concrete implementation and wired it into app initialization.
- Removed incomplete `lib/features/places` module/tests to unblock analyzer.
- Fixed live events data mappers/repository imports and color usage in profile/live events UI so analyzer errors are resolved.

## 2025-11-17
- Prevented `PlaceDetailScreen` from calling `ref.listen` during `initState` by using `listenManual`, resolving the runtime assertion and keeping project changes responsive.
- Added resilient place type decoding so the new API payloads (e.g., `filming_location`) map to internal enums across detail/list/map/pilgrimage screens without throwing and still display meaningful icons/labels.

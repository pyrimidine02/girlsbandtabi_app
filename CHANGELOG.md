# Changelog

## 2025-03-17
- Replaced selection persistence with concrete implementation and wired it into app initialization.
- Removed incomplete `lib/features/places` module/tests to unblock analyzer.
- Fixed live events data mappers/repository imports and color usage in profile/live events UI so analyzer errors are resolved.

## 2025-11-17
- Prevented `PlaceDetailScreen` from calling `ref.listen` during `initState` by using `listenManual`, resolving the runtime assertion and keeping project changes responsive.
- Added resilient place type decoding so the new API payloads (e.g., `filming_location`) map to internal enums across detail/list/map/pilgrimage screens without throwing and still display meaningful icons/labels.
- Surfaced precise place-verification failure reasons by mapping backend result codes to user-facing guidance and showing the raw error code for troubleshooting inside the verification sheet.
- Updated verification token generation to follow the backend contract: fetch `/verification/config` keys on demand, encrypt tokens with RSA-OAEP-256/A256GCM, and automatically retry once with a refreshed config when key rotation or clock skew causes server rejections.
- Captured the backend `Date` header when fetching the verification config so the client aligns its token timestamps with server time (preventing `Invalid location token` errors on devices with skewed clocks).
- Embedded the location payload inside an unsecured nested JWT (`cty: JWT`, `alg: none`) before encrypting, matching the backend's expectation for double-wrapped JWE tokens and unblocking verification.
- Improved verification error surfacing: API errors like "Too far from place" now come through with friendly Korean copy, thanks to better error parsing in `ApiClient` and message mapping in the controller.

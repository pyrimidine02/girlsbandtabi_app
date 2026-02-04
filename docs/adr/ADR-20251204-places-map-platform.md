# ADR-20251204: Platform-Specific Places Map Integration

## Status
**Accepted** – Implemented on 2025-12-04

## Context
- The Places screen still rendered a static FlutterMap/OpenStreetMap placeholder, so QA could not validate location flows and it ignored the KT requirement of using Apple Maps on iOS and Google Maps on Android.
- Android builds also lacked a secure way to inject a Google Maps API key, making it impossible to ship production artifacts without editing manifests manually.
- We simultaneously noticed that the documented API base URL (`docs/API문서_v2025.11.17.md`) still pointed to `http://localhost:8080`, confusing client teams since the runtime `AppConfig` already referenced the production host.

## Decision
1. Remove the `flutter_map`/`latlong2` placeholder and rebuild `PlacesMapView` on top of `google_maps_flutter` (Android) and `apple_maps_flutter` (iOS/macOS). Runtime detection chooses the appropriate widget while other platforms receive a graceful fallback message.
2. Mirror the Riverpod-driven `Place` list into native markers/annotations with bilingual info windows and calls back into the existing bottom sheet when tapped. Zoom/center controls reuse the new map controllers so UX parity is maintained.
3. Add `com.google.android.geo.API_KEY` as a manifest placeholder and plumb `MAPS_API_KEY` through Gradle so CI/local builds can inject secrets without committing them. Track the follow-up wiring in `TODO.md`.
4. Set `ApiEndpoints.baseUrl` from `AppConfig.baseUrl` and update the published API document to advertise `https://api.girlsbandtabi.com`, plus add a lightweight test to keep them in sync.

## Consequences
### Positive
- QA and product stakeholders now see real Apple/Google maps with the correct tiles, gestures, and marker density, aligning the experience with launch requirements.
- Android builds no longer require manifest edits for API keys; instead, secrets travel through Gradle placeholders and can be injected via CI.
- The documentation now matches runtime behavior, reducing confusion when debugging network traffic.
- The new unit test prevents regressions where someone might accidentally point `ApiEndpoints` back at localhost.

### Negative / Risks
- `google_maps_flutter` increases the Android/iOS binary size and requires valid API keys. Until `MAPS_API_KEY` is provided via CI/local configs, Android maps will render a blank grid (tracked in TODO).
- Apple Maps support is limited to iOS/macOS; we still show a fallback on other targets until UX requests a dedicated alternative.
- The heuristic zoom math for Apple Maps may require fine-tuning once we ingest significantly dispersed place clusters.

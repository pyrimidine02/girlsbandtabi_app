# ADR-20260308 FCM/APNs Readiness

## Status
Accepted (2026-03-08)

## Context
- The app already had Firebase Messaging service code, but runtime logs showed
  Firebase initialization failures due to missing platform config assets.
- iOS APNs entitlement was not wired in the Xcode target.
- Requirement: make push stack fully ready on app side for both FCM and APNs.

## Decision
- Add Firebase initialization fallback using runtime `--dart-define` options,
  so app can initialize when native Firebase files are absent.
- Keep bundled config path as primary (`google-services.json`,
  `GoogleService-Info.plist`), runtime options as fallback.
- Add iOS entitlements:
  - Debug: `aps-environment=development`
  - Release/Profile: `aps-environment=production`
- Wire the entitlements into Runner target build settings.
- Align frontend device registration payload to server contract:
  - include `provider` in token patch calls
  - include optional `locale` / `timezone` in register payload
  - apply iOS token/provider mapping (`FCM` preferred, `APNS` fallback)
- Add operational setup guide for Firebase/Apple console steps and verification.

## Consequences
- App side is now ready for FCM/APNs once project credentials/profiles are
  supplied.
- Missing native config files now have a documented runtime fallback path.
- Push still cannot be fully validated without external prerequisites:
  Firebase app registration, APNs key upload, provisioning refresh.

## Validation
- `flutter analyze` passes after changes.

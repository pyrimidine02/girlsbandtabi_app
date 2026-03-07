# ADR-20260307 Remote Push (FCM/APNs Path) and Runtime Hotfixes

## Status
Accepted

## Context
- Product requested real remote push delivery flow and runtime issue fixes.
- Runtime logs (2026-03-07) showed:
  - `POST /api/v1/ads/events` returns `400` with missing `decisionId`.
  - `ProjectUnitsController` occasionally throws `Bad state: Tried to use ... after dispose`.
  - App startup can throw `[core/no-app]` when `FirebaseMessaging.instance` is accessed before Firebase init in no-config environments.
- Backend live probe for push device API contract (2026-03-07, local docker):
  - `POST /api/v1/notifications/devices` requires:
    - `platform` (e.g. `IOS`)
    - `provider` (e.g. `FCM` or `APNS`)
    - `deviceId`
    - `pushToken`
  - `PATCH /api/v1/notifications/devices/{deviceId}/token` requires:
    - `pushToken`

## Decision
1. Remote push pipeline
- Add Firebase Messaging integration in Flutter app:
  - dependencies: `firebase_core`, `firebase_messaging`
  - app-scope bootstrap and background handler registration
  - foreground message -> local notification bridge
  - push-open tap -> existing in-app notification routing
- Implement `RemotePushService` to handle:
  - Firebase init/permission
  - backend device registration (`POST /notifications/devices`)
  - token refresh sync (`PATCH /notifications/devices/{deviceId}/token`)
  - logout deactivation (`DELETE /notifications/devices/{deviceId}`)
- Ensure `FirebaseMessaging.instance` is created lazily after successful Firebase init.
  - If Firebase is not configured, keep app startup alive and disable remote push path with warning logs.
- Keep `deviceId` persisted in local storage and reuse for patch/deactivate.

2. Ads 400 hotfix
- Skip ad-event tracking requests when `decisionId` is absent.
- This avoids guaranteed backend 400 for pre-decision fallback impressions/clicks.

3. Disposed notifier safety
- Add `mounted` checks around async boundaries in project controllers.
- Prevent state assignment after notifier disposal.

## Rationale
- Remote push requires explicit token lifecycle wiring, not just local notifications.
- Ad tracking without `decisionId` is invalid by server contract; client-side guard is the minimal safe fix.
- Async completion after disposal is a common notifier race and should be guarded at controller level.

## Consequences
- Push integration is now code-complete on Flutter side, but real delivery still depends on Firebase project files and platform capabilities.
- Ads tracking noise/exception logs from missing `decisionId` are eliminated.
- Project switching no longer crashes from disposed notifier state writes.

## Follow-up
- Add Firebase platform config files:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`
- Ensure iOS Push Notifications capability/APNs profile is enabled in Xcode target.
- Run physical-device push QA for foreground/background/terminated delivery.

## Verification
- `flutter pub get`
- `dart analyze lib/main.dart lib/app.dart lib/core/providers/core_providers.dart lib/core/notifications/remote_push_service.dart lib/features/ads/data/repositories/ads_repository_impl.dart lib/features/ads/presentation/widgets/hybrid_sponsored_slot.dart lib/features/auth/application/auth_controller.dart lib/features/projects/application/projects_controller.dart lib/features/settings/application/settings_controller.dart`
- `flutter test test/features/settings/application/settings_controller_test.dart`
- `flutter test test/features/home/data/home_summary_dto_test.dart`

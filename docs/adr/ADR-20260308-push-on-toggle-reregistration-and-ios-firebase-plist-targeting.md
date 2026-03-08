# ADR-20260308 Push ON Toggle Re-registration and iOS Firebase Plist Targeting

## Status
Accepted

## Context
- Push settings OFF path already deactivated backend device registration.
- ON reactivation path did not explicitly re-run permission + device registration,
  which could leave push disabled at runtime until next login/restart.
- iOS `GoogleService-Info.plist` file existed on disk but was not explicitly
  wired in `Runner.xcodeproj` resources, risking missing Firebase config in
  some build environments.

## Decision
- When notification settings update succeeds and push toggles OFF -> ON:
  - initialize remote push service
  - request notification permission
  - sync/register push device token
  - request local notification permissions
- Add `GoogleService-Info.plist` to Runner PBX group and Runner resources
  build phase in `ios/Runner.xcodeproj/project.pbxproj`.

## Consequences
- Push ON now attempts immediate end-to-end activation without requiring
  re-login.
- iOS Firebase config bundling becomes deterministic in Xcode builds.
- Failures in ON activation are logged but do not revert server-side settings,
  preserving user intent.

## Verification
- `flutter analyze lib/features/settings/application/settings_controller.dart lib/core/notifications/remote_push_service.dart lib/core/notifications/local_notifications_service.dart`
- `rg -n "GoogleService-Info.plist" ios/Runner.xcodeproj/project.pbxproj`

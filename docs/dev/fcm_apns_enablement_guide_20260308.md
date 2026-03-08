# FCM + APNs Enablement Guide (2026-03-08)

## 1) What was implemented in app code

- Remote push bootstrap is already wired at app scope.
- `RemotePushService` now supports two Firebase init paths:
  - bundled native config files (`google-services.json` / `GoogleService-Info.plist`)
  - runtime fallback via `--dart-define` Firebase options
- iOS APNs entitlements are split by build type:
  - Debug: `ios/Runner/RunnerDebug.entitlements` (`aps-environment=development`)
  - Release/Profile: `ios/Runner/RunnerRelease.entitlements` (`aps-environment=production`)
- Xcode project build settings now point to the entitlement files.
- Device contract alignment updates:
  - register payload includes optional `locale` / `timezone`
  - token patch payload includes `provider`
  - iOS provider selection:
    - use `FCM` when Firebase token exists
    - fallback to `APNS` when FCM token is unavailable and APNS token exists

## 2) Required project files (local)

Place these files locally (not committed):

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

If these are missing, remote push remains disabled and app logs:
`Firebase is not configured; remote push is disabled`.

## 3) Apple side prerequisites (APNs)

In Apple Developer:

1. App ID (`org.pyrimidines.girlsbandtabi`) must have Push Notifications enabled.
2. Provisioning profiles (Debug/Release) must be regenerated after enabling Push.
3. Install updated profiles/certificates in Xcode signing environment.

In Firebase Console:

1. Add iOS app with bundle ID `org.pyrimidines.girlsbandtabi`.
2. Upload APNs Auth Key (`.p8`) under Cloud Messaging for that iOS app.

## 4) Android side prerequisites (FCM)

In Firebase Console:

1. Add Android app with applicationId `org.pyrimidines.girlsbandtabi_app`.
2. Download `google-services.json`.
3. Put the file at `android/app/google-services.json`.

The Gradle config already applies `com.google.gms.google-services` only when this file exists.

## 5) Runtime fallback (optional, CI/local)

If native config files are not bundled, you can initialize Firebase with:

- Common:
  - `FIREBASE_API_KEY`
  - `FIREBASE_APP_ID`
  - `FIREBASE_MESSAGING_SENDER_ID`
  - `FIREBASE_PROJECT_ID`
  - `FIREBASE_STORAGE_BUCKET` (optional)
- Android overrides:
  - `FIREBASE_ANDROID_API_KEY`
  - `FIREBASE_ANDROID_APP_ID`
  - `FIREBASE_ANDROID_MESSAGING_SENDER_ID`
  - `FIREBASE_ANDROID_PROJECT_ID`
  - `FIREBASE_ANDROID_STORAGE_BUCKET` (optional)
- iOS overrides:
  - `FIREBASE_IOS_API_KEY`
  - `FIREBASE_IOS_APP_ID`
  - `FIREBASE_IOS_MESSAGING_SENDER_ID`
  - `FIREBASE_IOS_PROJECT_ID`
  - `FIREBASE_IOS_STORAGE_BUCKET` (optional)
  - `FIREBASE_IOS_BUNDLE_ID` (required)

Example:

```bash
flutter run \
  --dart-define=FIREBASE_ANDROID_API_KEY=... \
  --dart-define=FIREBASE_ANDROID_APP_ID=... \
  --dart-define=FIREBASE_ANDROID_MESSAGING_SENDER_ID=... \
  --dart-define=FIREBASE_ANDROID_PROJECT_ID=...
```

## 6) Verification checklist

1. Login with an authenticated user.
2. Confirm device registration API succeeds (`POST /api/v1/notification/devices`).
3. Confirm token update API succeeds (`PATCH /api/v1/notification/devices/{deviceId}/token`).
4. Send test push from Firebase Console.
5. Validate:
   - foreground display behavior
   - background push receipt
   - notification tap deep-link routing

## 7) Xcode Cloud note (plist injection)

`GoogleService-Info.plist` is git-ignored in this repository.  
Xcode Cloud must inject/create it during post-clone script execution
(`ci_post_clone.sh` / `ci_scripts/ci_post_clone.sh`).

Supported secret inputs (priority order):

1. `GOOGLE_SERVICE_INFO_PLIST` (raw full plist text)
2. `GOOGLE_SERVICE_INFO_PLIST_B64` (base64 full plist)
3. `FIREBASE_IOS_*` values:
   - `FIREBASE_IOS_API_KEY`
   - `FIREBASE_IOS_APP_ID`
   - `FIREBASE_IOS_MESSAGING_SENDER_ID`
   - `FIREBASE_IOS_PROJECT_ID`
   - `FIREBASE_IOS_BUNDLE_ID`
   - `FIREBASE_IOS_STORAGE_BUCKET` (optional)

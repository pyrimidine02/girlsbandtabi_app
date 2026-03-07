# ADR-20260307 Home Hub Removal and Notification Toggle/Permission Flow

## Status
Accepted

## Context
- Product request:
  - Remove center quick-access buttons (`장소/게시판/정보`) from home.
  - Fix notification settings toggle error on mobile.
  - Request OS notification permission right after login when permission is missing.
- Live backend check on local docker (2026-03-07) showed:
  - `GET /api/v1/notifications/settings` returns `200`.
  - `PUT /api/v1/notifications/settings` (push OFF) returns `200`.
  - `DELETE /api/v1/notifications/devices/{deviceId}` sample call returns `200`.
- Existing app behavior treated notification-device deactivation failure as overall settings-save failure, even when settings update itself succeeded.

## Decision
1. Home UI
- Remove `_ServiceHub` block and related widgets from `HomePage`.

2. Notification toggle failure handling
- Keep optimistic update behavior.
- When settings update succeeds and final `pushEnabled` is `false`, run device deactivation as a best-effort follow-up.
- If device deactivation fails, log warning/error but do not return settings-save failure to UI.
- Preserve server-failing device ID in storage on deactivation failure (for later retry opportunities).

3. Login permission prompt
- After successful authentication, asynchronously request notification permission.
- Do not block login success routing.
- Skip prompt when local push preference is explicitly OFF.

## Rationale
- Settings API success should be the primary success criterion for toggle UX.
- Device deactivation is a secondary cleanup step and should not cause user-facing “save failed” when the main setting is already persisted.
- Prompting right after login increases probability that local alerts can be shown without waiting for a later notification event.

## Consequences
- Users no longer see false-negative save failures for push OFF when only deactivation cleanup fails.
- Home screen becomes visually simpler by removing center shortcut row.
- Push permission prompt timing becomes deterministic at login (except when user opted push OFF).
- Full remote push background delivery (FCM/APNs) remains a separate phase; current behavior remains local notification delivery based on app-side notification sync.

## Verification
- `dart analyze lib/features/home/presentation/pages/home_page.dart lib/features/settings/application/settings_controller.dart lib/features/auth/application/auth_controller.dart test/features/settings/application/settings_controller_test.dart`
- `flutter test test/features/settings/application/settings_controller_test.dart`
- Live API probe (local docker backend, 2026-03-07): notifications settings GET/PUT and device DELETE returned `200`.

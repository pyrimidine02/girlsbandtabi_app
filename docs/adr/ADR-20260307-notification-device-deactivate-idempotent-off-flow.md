# ADR-20260307-notification-device-deactivate-idempotent-off-flow

## Status
Accepted (2026-03-07)

## Context
- 푸시 알림 OFF 처리에서 디바이스 해제 API(`DELETE /api/v1/notifications/devices/{deviceId}`) 응답의 `deactivated=false`를 클라이언트가 실패로 해석하면, 사용자 의도(알림 끄기)가 충족되어도 오류 UX가 노출될 수 있습니다.
- 백엔드가 해당 API를 멱등(idempotent) 성공 정책으로 변경하면서, 프런트도 200 응답을 성공으로 처리하도록 정렬이 필요합니다.
- 현재 앱은 알림 설정(`pushEnabled`) 저장 흐름이 존재하므로, OFF 전환 시점에 디바이스 해제를 연계하는 것이 자연스럽습니다.

## Decision
### 1) API/데이터 계층 확장
- `ApiEndpoints`에 알림 디바이스 경로를 추가:
  - `notificationDevices`
  - `notificationDevice(deviceId)`
  - `notificationDeviceToken(deviceId)`
- `NotificationDeviceDeactivationDto`를 추가해 `deviceId/deactivated` 응답을 파싱합니다.
- `SettingsRemoteDataSource.deactivateNotificationDevice(...)`를 추가합니다.
- `SettingsRepository.deactivateNotificationDevice(...)` 계약/구현을 추가합니다.

### 2) 성공 판정 정책
- `DELETE /notifications/devices/{deviceId}`가 HTTP 200이면 `deactivated` 값과 무관하게 성공 처리합니다.
- `deactivated=false`는 과도기/혼재 환경 호환 케이스로 간주하고 실패로 처리하지 않습니다.

### 3) 알림 OFF 전환 연동
- `NotificationSettingsController.updateSettings(...)`에서 `pushEnabled`가 `ON -> OFF`로 전환되고 설정 저장이 성공하면:
  - 로컬 저장소의 디바이스 ID(현행/레거시 키)를 조회
  - 존재 시 디바이스 해제 API 호출
  - 성공 시 저장된 deviceId 키를 제거
- 실제 실패(네트워크/인증/서버 오류)만 실패로 반환해 UI가 에러 UX를 노출하도록 합니다.

## Consequences
### Positive
- 알림 OFF 동작이 멱등하게 처리되어 중복 OFF 호출에서도 불필요한 오류 토스트가 줄어듭니다.
- 백엔드 계약(200 성공 통일)과 프런트 판정이 일치합니다.
- 디바이스 ID 키 정리로 불필요한 재호출 가능성을 줄입니다.

### Trade-offs
- 아직 디바이스 등록/토큰 갱신 API 연동이 완전하지 않아, 저장된 deviceId가 없으면 해제 호출은 생략됩니다.
- 설정 저장 성공 + 해제 API 실패 시 UI는 OFF 상태를 유지한 채 실패 결과를 반환합니다(의도 충족 우선).

## Validation
- `flutter analyze` (changed files only)
- `flutter test test/features/settings/data/notification_device_dto_test.dart test/features/settings/data/notification_settings_dto_test.dart test/features/settings/application/settings_controller_test.dart`

## Follow-up
- `POST /notifications/devices`, `PATCH /notifications/devices/{deviceId}/token` 연동 시 deviceId 저장/갱신 경로를 완성합니다.

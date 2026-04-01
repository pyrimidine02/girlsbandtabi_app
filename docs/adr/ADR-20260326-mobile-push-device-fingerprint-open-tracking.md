# ADR-20260326: Mobile Push Integration — Device Fingerprint & Open Tracking

- Date: 2026-03-26
- Status: Accepted
- Related:
  - `docs/dev/mobile-app-integration-request-20260326.md`
  - Backend rollout: V157 ~ V160

## Context

백엔드 알림 시스템에 다음 계약 변경이 반영되었다.

1. `POST /api/v1/notifications/devices` 에 `deviceHash`(optional) 전달
2. `POST /api/v1/notifications/{notificationId}/open` 호출로 알림 오픈 이벤트 기록
3. Quiet Hours 정확도를 위한 IANA 타임존 전달 권장

기존 앱은 디바이스 등록 시 `deviceHash`를 보내지 않았고, 푸시 탭 이벤트를 서버에
별도 기록하지 않았다. 또한 타임존은 `DateTime.now().timeZoneName` 기반이어서
IANA 형식 보장이 없었다.

## Decision

### 1) 디바이스 등록 payload 강화

- `remote_push_service`에서 등록 payload 생성 시 `deviceHash`를 포함한다.
- 해시 규칙:
  - `SHA-256(rawDeviceId + ":gbt-salt-v1")`
  - 결과는 64자 소문자 hex 문자열만 허용
- raw device id 수집:
  - Android: `android_id` 패키지 사용 (`ANDROID_ID`)
  - iOS: `device_info_plus`의 `identifierForVendor`
- 수집 실패/검증 실패 시 `deviceHash`는 생략한다(optional 계약 유지).

### 2) 알림 오픈 이벤트 전송

- `ApiEndpoints.notificationOpen(id)` 엔드포인트를 추가한다.
- `RemotePushService.trackNotificationOpen()`를 추가해 best-effort로 호출한다.
- 호출 시점:
  - `FirebaseMessaging.onMessageOpenedApp`
  - `FirebaseMessaging.getInitialMessage()`
  - 로컬 fallback 알림 탭(App 레벨 핸들러)
- 실패는 로그만 남기고 UX 흐름에는 영향 주지 않는다.

### 3) Quiet Hours용 타임존 전달 방식 변경

- `flutter_timezone`으로 로컬 타임존을 조회한다.
- IANA 패턴 검증을 통과한 경우에만 `timezone` 필드를 포함한다.
- 비정상 값(`KST`, `+09:00` 등)은 전송하지 않는다.

## Alternatives Considered

1. 기존 `DateTime.now().timeZoneName` 유지  
   - 장점: 의존성 추가 없음  
   - 단점: IANA 형식 비보장으로 Quiet Hours 정확도 저하 가능

2. `device_info_plus` 단독으로 Android 식별자 처리  
   - 장점: 추가 의존성 없음  
   - 단점: 최신 `device_info_plus`는 `androidId`를 제공하지 않음

## Consequences

- 장점:
  - 디바이스-유저 연결 레코드 생성률 향상(어뷰징 추적 근거 확보)
  - 알림 CTR 측정 데이터 수집 가능
  - Quiet Hours 계산 정확도 개선
- 비용:
  - 신규 패키지(`android_id`, `flutter_timezone`) 의존성 추가
  - 실기기 QA 항목 증가(앱 상태별 탭 시나리오)

## Verification

- `flutter analyze` 통과
- `flutter test test/core/notifications/remote_push_service_test.dart` 통과
- `flutter test` 전체 통과


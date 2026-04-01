# ADR-20260331: Client request guard hardening for 400/401 reduction

## Status
- Accepted (2026-03-31)

## 변경 전 문제
- 운영 로그에서 아래 패턴이 반복 관측되었습니다.
  - `POST /api/v1/uploads/presigned-url` → `400 INVALID_REQUEST`
  - 인증 실패 이후 `GET /api/v1/home/summary/by-project`,
    `GET /api/v1/community/feed/recommended/cursor`,
    `GET /api/v1/notifications` 반복 `401`
- 클라이언트 요청 전 입력 검증/정규화와 인증 실패 후 호출 차단이 충분하지 않아
  서버에 불필요한 요청이 계속 유입될 수 있었습니다.

## 대안
1. 서버에서만 방어하고 클라이언트는 현 상태 유지.
2. 클라이언트 입력 검증 + 인증 실패 시 호출 차단 가드 추가.
3. 모든 실패를 강제 재시도/백오프로 처리.

## 결정
- 대안 2를 채택했습니다.
- 업로드 요청 전 클라이언트 검증을 추가했습니다.
  - `filename` 필수
  - `size > 0` 필수
  - `contentType` 형식 검증
  - `contentType` trim/lowercase 정규화
- 인증 실패(401 / `auth_required`)를 감지하면
  주요 컨트롤러에서 인증 상태를 미인증으로 전환하고
  실시간/폴링 요청을 정리하도록 보강했습니다.
  - Home, Community Feed, Notifications, Mandatory Consent, User Profile
- Community Feed 구독 로드는 인증 상태에서만 호출되도록 제한했습니다.

## 근거
- 서버가 처리하기 전에 클라이언트에서 invalid payload를 차단하면
  400 소음을 구조적으로 줄일 수 있습니다.
- 인증이 무효화된 세션에서 계속 폴링/리로드를 수행하는 것은
  UX 개선 효과 없이 401 로그와 네트워크 비용만 증가시킵니다.
- 컨트롤러 레벨 가드는 기존 아키텍처를 크게 바꾸지 않고
  즉시 적용 가능한 저위험 변경입니다.

## 영향 범위
- 런타임:
  - `lib/features/uploads/application/uploads_controller.dart`
  - `lib/features/home/application/home_controller.dart`
  - `lib/features/feed/application/board_controller.dart`
  - `lib/features/notifications/application/notifications_controller.dart`
  - `lib/features/settings/application/mandatory_consent_controller.dart`
  - `lib/features/settings/application/settings_controller.dart`
- 테스트:
  - `test/features/uploads/application/uploads_controller_test.dart`

## Validation
- `flutter test test/features/uploads/application/uploads_controller_test.dart test/features/settings/application/settings_controller_test.dart test/core/notifications/remote_push_service_test.dart` passed.
- `flutter analyze lib/features/uploads/application/uploads_controller.dart test/features/uploads/application/uploads_controller_test.dart lib/features/home/application/home_controller.dart lib/features/feed/application/board_controller.dart lib/features/notifications/application/notifications_controller.dart lib/features/settings/application/mandatory_consent_controller.dart lib/features/settings/application/settings_controller.dart` passed.


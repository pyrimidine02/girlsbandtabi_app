# ADR-20260310: Notification Settings Conflict Recovery + Social Expansion

- Date: 2026-03-10
- Status: Accepted
- Scope:
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/error/error_handler.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/settings/data/dto/notification_settings_dto.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/settings/data/datasources/settings_remote_data_source.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/settings/application/settings_controller.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/settings/domain/entities/notification_settings.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/settings/presentation/pages/notification_settings_page.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/notifications/domain/entities/notification_navigation.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/notifications/domain/entities/notification_entities.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/notifications/application/notifications_controller.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/notifications/remote_push_service.dart`

## Context
- 알림 설정 저장(`PUT /api/v1/notifications/settings`)에서 간헐적으로
  `409 CONFLICT`가 발생했습니다.
- 서버 계약이 다음으로 확장되었습니다:
  - 설정 응답: `version`, `updatedAt`
  - 설정 충돌 코드: `NOTIFICATION_SETTINGS_VERSION_CONFLICT`
  - 충돌 상세: `error.details.current` 최신 스냅샷
  - 신규 카테고리: `FOLLOWING_POST`
  - 신규 소셜 이벤트:
    - `FOLLOWING_POST_CREATED`
    - `MY_POST_COMMENT_CREATED`
    - `MY_COMMENT_REPLY_CREATED`
- 기존 프런트 로직은 409를 즉시 실패 처리하거나,
  충돌 상세 스냅샷을 활용하지 못했습니다.

## Decision
- `NotificationSettingsController`에 충돌 복구 경로를 추가합니다.
  1. `ValidationFailure(code=CONFLICT|409)` 감지
  2. `ValidationFailure.details.current`가 있으면 이를 최신값으로 사용
  3. 없으면 `getNotificationSettings(forceRefresh: true)`로 최신값 재조회
  4. 최신 서버 상태에 사용자 의도값(토글 변경값)을 병합
  5. 동일 업데이트를 1회 재시도
- 충돌 판정 코드에 `NOTIFICATION_SETTINGS_VERSION_CONFLICT`를 추가합니다.
- Notification settings DTO를 계약 변경에 맞춰 조정합니다:
  - GET/캐시: `version`, `updatedAt` 유지
  - PUT: `updatedAt` 제외, `version` 포함
  - 카테고리 역호환: `FOLLOWING_POSTS` -> `FOLLOWING_POST`
- 알림 설정 UI에 `FOLLOWING_POST` 토글을 추가합니다.
- 알림 타입 정규화 공통 경로를 확장합니다:
  - `MY_POST_COMMENT_CREATED` -> `COMMENT_CREATED`
  - `MY_COMMENT_REPLY_CREATED` -> `COMMENT_REPLY_CREATED`
  - `FOLLOWING_POST_CREATED` -> `POST_CREATED`
- 복구 재시도 중 UI 상태와 로컬 `notificationsEnabled` 값을
  재시도 payload와 동기화합니다.

## Alternatives Considered
1. 409를 기존처럼 즉시 실패 처리
   - Rejected: 서버 권장 복구 절차(새로고침 후 재시도)를 따르지 못함.
2. 무조건 같은 payload 즉시 재시도
   - Rejected: 최신 상태 동기화 없이 재시도하면 동일 충돌 반복 가능성이 큼.
3. 이벤트 신규 코드를 별도 분기에서만 처리
   - Rejected: 푸시/SSE/알림함 경로별 처리 불일치로 회귀 위험이 큼.

## Consequences
- 동시 수정 충돌 상황에서 사용자 저장 성공률이 개선됩니다.
- 저장 실패 토스트 노출 빈도가 줄고 UX 일관성이 개선됩니다.
- 서버가 진짜 비호환 상태를 반환하는 경우에는 기존 실패 처리 경로를 유지합니다.
- 신규 소셜 이벤트 코드가 기존 라우팅/상세 진입 플로우와 일관되게 동작합니다.

## Validation
- `flutter analyze lib/core/error/failure.dart lib/core/error/error_handler.dart lib/features/settings/data/dto/notification_settings_dto.dart lib/features/settings/data/datasources/settings_remote_data_source.dart lib/features/settings/application/settings_controller.dart lib/features/settings/domain/entities/notification_settings.dart lib/features/settings/presentation/pages/notification_settings_page.dart lib/features/notifications/domain/entities/notification_navigation.dart lib/features/notifications/domain/entities/notification_entities.dart lib/features/notifications/application/notifications_controller.dart lib/core/notifications/remote_push_service.dart`
- `flutter test test/features/settings/data/notification_settings_dto_test.dart test/features/settings/application/settings_controller_test.dart test/features/notifications/domain/notification_navigation_test.dart`

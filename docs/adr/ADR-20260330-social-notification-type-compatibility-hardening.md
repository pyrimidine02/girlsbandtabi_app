# ADR-20260330: Social notification type compatibility hardening

## Status
- Accepted (2026-03-30)

## 변경 전 문제
- 일부 사용자 환경에서 다음 3종 알림이 누락되는 제보가 발생했습니다.
  - 팔로우 유저 신규글
  - 내 글 신규 댓글
  - 내 댓글 신규 답글
- 다른 알림은 정상 수신되어, 채널 자체(Firebase/APNs)보다는
  타입 키/별칭/이벤트명 편차에 따른 클라이언트 매핑 누락 가능성이 높았습니다.

## 대안
1. 서버 payload 포맷 고정 배포를 기다린다.
2. 클라이언트에서 타입/이벤트/카테고리 매핑의 호환성을 넓혀 즉시 완화한다.

## 결정
- 대안 2를 채택합니다.
- 클라이언트에서 아래를 보강했습니다.
  - `normalizeNotificationType` 별칭 확장
    - `FOLLOWING_POST_CREATED` 계열 → `POST_CREATED`
    - `POST_COMMENT_CREATED` / `MY_POST_COMMENT_CREATED` 계열 → `COMMENT_CREATED`
    - `POST_COMMENT_REPLY_CREATED` / `MY_COMMENT_REPLY_CREATED` 계열 → `COMMENT_REPLY_CREATED`
  - SSE 이벤트 필터 확장
    - `following_post`, `post_comment`, `comment_reply` 키워드를 알림 이벤트로 인정
  - 푸시/DTO 파싱 타입 fallback 확장
    - `notificationType`/`type` 부재 시 `eventType`도 타입 소스로 사용
  - 알림 카테고리 정규화 확장
    - 소셜 별칭 카테고리를 `FOLLOWING_POST`/`COMMENT`로 canonicalize

## 근거
- 현재 운영 중인 알림 계약 문서에는 소셜 이벤트 타입이
  `FOLLOWING_POST_CREATED`, `MY_POST_COMMENT_CREATED`,
  `MY_COMMENT_REPLY_CREATED` 등으로 명시되어 있습니다.
- 클라이언트는 이미 일부 별칭을 처리하고 있었지만,
  이벤트 소스(SSE/push/list)별 키 차이(`eventType`)와
  이벤트명 필터 범위가 좁아 누락 가능성이 존재했습니다.

## 영향 범위
- `lib/features/notifications/domain/entities/notification_navigation.dart`
- `lib/features/notifications/application/notifications_controller.dart`
- `lib/core/notifications/remote_push_service.dart`
- `lib/features/notifications/data/dto/notification_dto.dart`
- `lib/features/settings/data/dto/notification_settings_dto.dart`
- `test/features/notifications/domain/notification_navigation_test.dart`
- `test/features/notifications/data/notification_dto_test.dart`
- `test/features/settings/data/notification_settings_dto_test.dart`
- `CHANGELOG.md`
- `TODO.md`

## 검증 메모
- `flutter test test/features/notifications/domain/notification_navigation_test.dart test/features/notifications/data/notification_dto_test.dart test/features/settings/data/notification_settings_dto_test.dart` 통과.
- `flutter analyze lib/features/notifications/domain/entities/notification_navigation.dart lib/features/notifications/application/notifications_controller.dart lib/features/notifications/data/dto/notification_dto.dart lib/core/notifications/remote_push_service.dart lib/features/settings/data/dto/notification_settings_dto.dart test/features/notifications/domain/notification_navigation_test.dart test/features/notifications/data/notification_dto_test.dart test/features/settings/data/notification_settings_dto_test.dart` 통과.

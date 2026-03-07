# ADR-20260308-notification-payload-alignment-v110-client

## Status
Accepted

## Date
2026-03-08

## Context
- 프런트 요청서 `notification-payload-alignment-request-20260308.md` 기준으로
  알림함/SSE/Push payload 키 정렬이 필요했다.
- 기존 클라이언트는 대부분 alias를 지원했지만,
  딥링크 우선순위와 일부 경로 정규화(`/community/posts/*`) 및
  타입/엔티티 우선순위가 계약과 완전히 일치하지 않았다.

## Decision
1. 알림 경로 해석 우선순위를 계약 v1.1.0에 맞춘다.
   - `deeplink/deepLink` 우선, 그다음 `actionUrl`
2. 경로 정규화 보강:
   - `/community/posts/{postId}` -> `/board/posts/{postId}`
3. 타입/엔티티 alias 우선순위 정렬:
   - `notificationType` 우선, 없으면 `type`
   - `targetId` 우선, 없으면 `entityId`
4. 로컬 알림 payload 직렬화/역직렬화에 alias 쌍을 함께 유지한다.
   - `type + notificationType`
   - `deeplink + deepLink`
   - `entityId + targetId`
   - `projectCode + projectId`
5. post-scoped 타입 fallback을 확장해 링크 누락 시에도 post 라우팅 성공률을 높인다.

## Alternatives Considered
1. 기존 우선순위 유지 + 서버만 수정
   - 과거 payload와 신규 payload가 혼재될 때 라우팅 일관성이 깨질 수 있다.
2. 단일 키만 수용하고 alias 제거
   - 과도기 환경에서 역호환성이 크게 떨어진다.

## Consequences
### Positive
- 알림 payload 계약 v1.1.0과 클라이언트 동작이 일치한다.
- 동일 이벤트의 소스(Push/SSE/알림함)에 따라 라우팅이 달라지는 문제를 줄인다.

### Trade-offs
- alias 키를 병행 지원하면서 파서 코드가 다소 길어진다.
- 서버가 계약 외 경로를 보내면 여전히 generic fallback으로 남는다.

## Scope
- `lib/features/notifications/domain/entities/notification_navigation.dart`
- `lib/features/notifications/data/dto/notification_dto.dart`
- `lib/core/notifications/local_notifications_service.dart`
- `lib/core/notifications/remote_push_service.dart`
- `lib/features/notifications/application/notifications_controller.dart`
- `test/features/notifications/domain/notification_navigation_test.dart`
- `test/features/notifications/data/notification_dto_test.dart`

## Validation
- `flutter test test/features/notifications/domain/notification_navigation_test.dart test/features/notifications/data/notification_dto_test.dart`
- `flutter analyze lib/features/notifications/domain/entities/notification_navigation.dart lib/features/notifications/data/dto/notification_dto.dart lib/core/notifications/local_notifications_service.dart lib/core/notifications/remote_push_service.dart lib/features/notifications/application/notifications_controller.dart test/features/notifications/domain/notification_navigation_test.dart test/features/notifications/data/notification_dto_test.dart`

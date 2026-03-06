# ADR-20260307-notification-toggle-gating-and-push-action-routing

## Status
Accepted (2026-03-07)

## Context
- 알림 설정 화면에서 `pushEnabled=false`일 때 하위 카테고리 토글이 계속 조작 가능한 상태라 UX 계약과 불일치가 있었습니다.
- 백엔드에서 신규 푸시 타입 매핑(`FOLLOWING_POST -> POST_CREATED`, `SYSTEM_BROADCAST -> SYSTEM_NOTICE`)이 반영되었고, 알림 탭/푸시 탭 시 deeplink 또는 actionUrl 기반 이동 규칙을 프런트가 처리해야 합니다.
- 기존 모바일 알림 모델은 `id/title/body/createdAt/read`만 보관해 라우팅 힌트를 소실했습니다.

## Decision
1. 알림 설정 UX 게이트 정합화
   - `pushEnabled=false`일 때 콘텐츠 하위 토글(`COMMENT/FAVORITE/LIVE_EVENT`) 비활성화 + 회색 스타일 적용.
   - 하위 선택값은 유지하고, push 재활성화 시 기존 선택 상태를 그대로 사용.
2. 알림 모델 확장
   - `NotificationItemDto`/`NotificationItem`에 `type/actionUrl/deeplink/entityId/projectCode` 필드 추가.
   - snake_case/camelCase 키를 모두 파싱.
3. 푸시/알림 탭 라우팅 규칙 추가
   - `normalizeNotificationType`로 레거시 타입을 신형 타입으로 정규화.
   - `POST_CREATED`: deeplink/actionUrl/entityId에서 postId 해석 후 `/board/posts/{postId}` 이동.
   - `SYSTEM_NOTICE`: `actionUrl` 우선, 없으면 `/notifications` 이동.
4. 로컬 알림 탭 이벤트 처리
   - `LocalNotificationsService`에서 알림 payload를 JSON 구조화 저장.
   - 탭 이벤트 스트림을 앱 전역에서 listen하고 라우팅 + 읽음 처리 실행.
5. SSE 힌트 병합
   - 알림 목록 API에 라우팅 힌트가 없더라도, SSE payload(`notificationType/actionUrl`)를 알림 ID 기준으로 캐시해 신규 항목에 병합.

## Consequences
### Positive
- 푸시 마스터 토글 UX가 서버 동작과 직관적으로 일치합니다.
- 신규 타입(`POST_CREATED`, `SYSTEM_NOTICE`)에서 푸시 탭 이동 성공률이 올라갑니다.
- 백엔드 응답 필드가 부분적으로 확장되어도 클라이언트 복원력이 올라갑니다.

### Trade-offs
- 알림 모델/탭 처리 경로가 늘어나 코드 복잡도가 증가합니다.
- 알림 목록 API가 라우팅 필드를 아직 완전 제공하지 않으면, 일부 이동은 `/notifications` 폴백에 의존합니다.

## Validation
- `flutter analyze` (변경 파일 대상) 통과.
- `flutter test`:
  - `test/features/notifications/data/notification_dto_test.dart`
  - `test/features/notifications/domain/notification_navigation_test.dart`

## Follow-up
- 백엔드 `GET /api/v1/notifications` 응답에 `type/actionUrl/deeplink/entityId/projectCode`를 정식 포함하면 SSE 힌트 병합 로직을 단순화할 수 있습니다.
- 후속 단계에서 `POST_CREATED`, `SYSTEM_NOTICE` 전용 카테고리 토글 분리(서버 categories 확장) 예정.


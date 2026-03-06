# ADR-20260306-community-notification-sse-fallback

## Status
Accepted (2026-03-06)

## Context
- 커뮤니티 피드/알림은 현재 foreground 주기 폴링(`35s/40s`)으로 최신성을 유지한다.
- 사용자 요구사항은 더 빠른 반영과 불필요한 재조회 감소(실시간 동기화)다.
- 서버 사용자용 SSE 계약은 아직 안정화되지 않아, 클라이언트 단독 변경은 폴링 대체가 아닌 폴백 병행 전략이 필요하다.

## Decision
1. 클라이언트에 공통 SSE 인프라를 추가한다.
   - `SseClient`, `SseConnection`, `SseEvent`
   - bearer 토큰 헤더, `Last-Event-ID` 헤더, event-stream 파싱 지원
2. `CommunityFeedController`, `NotificationsController`에 SSE 연결/종료/재연결 로직을 추가한다.
   - 연결 실패/종료 시 지수 백오프(최대 60초)로 재시도
   - 이벤트 수신 시 즉시성 반영을 위해 throttled `refreshInBackground(minInterval: Duration.zero)` 실행
3. 폴링을 완전히 제거하지 않고 안전 폴백으로 유지한다.
   - SSE 연결 중에는 기존 주기 refresh 요청을 자동 스킵
   - SSE 미지원/실패 환경에서는 기존 폴링이 계속 동작

## Consequences
### Positive
- SSE 지원 환경에서 피드/알림 반영 지연이 감소한다.
- 이벤트가 없을 때 불필요한 풀 리프레시 호출을 줄일 수 있다.
- 서버 계약이 확정되면 폴링 감축/제거로 확장하기 쉬운 구조를 확보한다.

### Trade-offs
- 서버 계약 부재/불일치 시 재연결 시도가 발생하며 로그가 늘어날 수 있다.
- 현재는 이벤트 타입 스키마가 확정되지 않아, 클라이언트는 보수적으로 이벤트를 해석해 리프레시를 트리거한다.

## Validation
- `dart format lib/core/realtime/sse_client.dart lib/features/feed/application/board_controller.dart lib/features/notifications/application/notifications_controller.dart lib/features/feed/presentation/pages/board_page.dart lib/features/notifications/presentation/pages/notifications_page.dart lib/core/providers/core_providers.dart lib/core/constants/api_constants.dart`
- `flutter analyze lib/core/realtime/sse_client.dart lib/features/feed/application/board_controller.dart lib/features/notifications/application/notifications_controller.dart lib/features/feed/presentation/pages/board_page.dart lib/features/notifications/presentation/pages/notifications_page.dart lib/core/providers/core_providers.dart lib/core/constants/api_constants.dart`

## Follow-up
- 백엔드와 사용자 SSE endpoint/이벤트 스키마를 확정하고, 연결 성공률/이벤트 수신률 지표를 기준으로 폴링 주기를 단계적으로 줄인다.
- 최종적으로 SSE 안정화 후 `foreground Timer.periodic` 제거 여부를 결정한다.

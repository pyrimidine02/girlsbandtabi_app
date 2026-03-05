# ADR-20260305-community-feed-phase4-foreground-sync-fallback

## Status
Accepted (2026-03-05)

## Context
- 커뮤니티/알림은 데이터 변경 빈도가 높은 화면이라 사용자가 수동 새로고침을 하지 않으면 최신 상태와 쉽게 어긋납니다.
- 현재 앱은 pull-to-refresh와 진입 시 로드 중심이라, 화면을 오래 켜두거나 백그라운드 복귀 시 stale 상태가 남을 수 있습니다.
- 서버 소켓/푸시 디바이스 이벤트 계약은 아직 확정되지 않았기 때문에, 클라이언트 단에서 안전한 폴백 동기화가 필요합니다.

## Decision
### 1) Board 피드에 foreground 폴백 동기화 추가
- `CommunityFeedController.refreshInBackground()`를 추가.
- 포그라운드 주기 동기화는 아래 가드로 제한:
  - 이미 로딩/페이지네이션 중이면 스킵
  - 최소 간격(`35s`) 미만이면 스킵
  - 프로젝트 선택 없음이면 스킵
- 에러 시 기존 목록이 있으면 화면을 유지하고, 목록이 비어 있을 때만 실패 상태를 반영.

### 2) Notifications에 foreground 폴백 동기화 추가
- `NotificationsController.refreshInBackground()`를 추가.
- 최소 간격(`40s`)과 중복 실행 방지 플래그를 적용.
- 에러 시 기존 데이터 유지 전략을 동일하게 적용.

### 3) 화면 가시성 + 앱 라이프사이클 조건부 트리거
- `BoardPage` 커뮤니티 탭과 `NotificationsPage`에 `WidgetsBindingObserver` + 타이머 적용.
- 타이머 콜백은 **앱 resumed + 현재 route 노출 상태**일 때만 실행.
- 백그라운드에서 resumed로 돌아오면 즉시 한 번 동기화 시도.

## Consequences
### Positive
- 사용자가 손으로 당겨서 새로고침하지 않아도, 커뮤니티/알림 최신성이 개선됩니다.
- 항상 전체 로딩 스켈레톤으로 갈아엎지 않으므로 피드 읽기 흐름이 끊기지 않습니다.
- 소켓/푸시 미연동 상태에서도 “유지 가능한 최소 실시간성”을 확보합니다.

### Trade-offs
- 주기적 네트워크 요청이 추가되어 트래픽/배터리 비용이 증가할 수 있습니다.
- 완전 실시간(이벤트 단위 push) 대비 반영 지연(최대 주기 간격)이 존재합니다.

## Validation
- `flutter analyze lib/features/feed/application/board_controller.dart lib/features/feed/presentation/pages/board_page.dart lib/features/notifications/application/notifications_controller.dart lib/features/notifications/presentation/pages/notifications_page.dart` 통과
- `flutter test test/features/feed test/features/notifications` 통과

## Follow-up
- 서버에 아래 계약 확정 요청:
  - 디바이스 토큰 등록/해제 endpoint
  - 커뮤니티/알림 이벤트 스키마(WebSocket or SSE)
- 계약 확정 후 폴백 타이머 주기를 완화하거나 화면별로 비활성화 전략을 도입.

# ADR-20260326: SSE disconnect fatal-error guard for notifications/feed

## Status
- Accepted (2026-03-26)

## 변경 전 문제
- Production에서 `ClientException: Connection closed while receiving data`
  발생 시 일부 경로가 root async error로 전파되어 crash reporter에서 fatal로
  집계되는 사례가 있었다.
- 재현 상황은 알림 SSE 엔드포인트
  (`/api/v1/notifications/stream`) 연결 도중 네트워크 종료/중단 시나리오와
  일치하며, Samsung 단말에서 집중 관측되었다.

## 대안
1. 서버 keep-alive/timeout 정책만 조정하고 앱 로직은 유지한다.
2. 앱에서 스트림 단절을 expected network event로 분류하고,
   reconnect/dispose 경로의 예외 전파를 차단한다.
3. SSE를 포기하고 폴링 전용으로 전환한다.

## 결정
- 대안 2를 채택한다.
- `notifications_controller`, `board_controller`의 SSE 라이프사이클에
  safe wrapper를 추가해 unawaited 경로에서도 예외가 isolate 루트로
  전파되지 않도록 한다.
- `subscription.cancel`/`connection.close`를 개별 보호하여 종료 경쟁 상태에서
  발생하는 `ClientException`을 expected disconnect로 처리한다.
- `connection closed while receiving data` 시그니처를 명시 분류한다.

## 근거
- 모바일 네트워크 전환/절전/백그라운드 제약에서 장기 SSE 연결의 중도 종료는
  정상적으로 발생 가능한 이벤트다.
- 앱의 목표는 “연결 유지”가 아니라 “서비스 연속성”이며,
  단절 시 즉시 재연결 + 폴링 폴백이 UX/정확성에 더 유리하다.
- fatal 전파를 막아도 reconnect가 유지되므로 기능 회귀 위험이 낮다.

## 영향 범위
- 런타임:
  - 알림 실시간 동기화(`NotificationsController`)
  - 커뮤니티 피드 실시간 동기화(`CommunityFeedController`)
- 테스트:
  - SSE 단위 테스트에 stream disconnect error 시나리오 추가
- 운영/QA:
  - Samsung 실기기에서 Wi-Fi↔LTE 전환, 앱 백그라운드/복귀 반복 시
    fatal crash 재발 여부 확인 필요


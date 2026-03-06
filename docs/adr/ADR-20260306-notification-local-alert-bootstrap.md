# ADR-20260306-notification-local-alert-bootstrap

## Status
Accepted (2026-03-06)

## Context
- 사용자 요구사항은 앱 사용 중에도 실제 알림(배너/사운드)이 즉시 울리는 것이다.
- 현재 구조는 알림 목록 갱신 위주이며, 페이지 진입 상태에 따라 실시간 동기화가 중단될 수 있었다.
- 백그라운드/종료 상태 푸시는 서버의 APNs/FCM 연동이 필요하므로, 클라이언트 단독으로는 foreground 즉시 알림부터 확보해야 한다.

## Decision
1. 앱 전역에서 알림 실시간 동기화를 유지한다.
   - `GBTApp`에서 `notificationsRealtimeBootstrapProvider`를 watch
   - 알림 페이지 `dispose`에서 SSE를 중지하지 않도록 변경
2. foreground 수신 이벤트를 로컬 알림으로 변환한다.
   - `LocalNotificationsService` 추가 (`flutter_local_notifications`)
   - 신규 미읽음 알림 감지 시 로컬 배너/사운드 표시
3. 사용자 설정과 로컬 알림 표시 정책을 동기화한다.
   - 알림 설정 `pushEnabled`를 `LocalStorageKeys.notificationsEnabled`에 저장
   - 설정 비활성화 시 foreground 로컬 알림 표시 차단
4. 인증 상태 변경 시 알림 스냅샷을 초기화한다.
   - 로그아웃 시 알려진 알림 ID 집합/시드 상태를 초기화해 계정 간 오염 방지

## Consequences
### Positive
- 알림 페이지를 열지 않아도 앱 사용 중 신규 알림이 즉시 배너/사운드로 노출된다.
- 사용자의 푸시 토글과 foreground 알림 표시가 일치한다.
- SSE + polling fallback 구조를 유지해 서버 미지원/장애 시에도 동작 안정성을 확보한다.

### Trade-offs
- foreground 즉시 알림만 처리하며, 백그라운드/종료 상태 푸시는 별도 백엔드 연동이 필요하다.
- 앱 전역 부트스트랩으로 인증 후 알림 동기화 트래픽이 기본 발생한다.

## Validation
- `flutter pub get`
- `dart format lib/app.dart lib/core/notifications/local_notifications_service.dart lib/core/providers/core_providers.dart lib/features/notifications/application/notifications_controller.dart lib/features/notifications/presentation/pages/notifications_page.dart lib/features/settings/application/settings_controller.dart`
- `flutter analyze lib/app.dart lib/core/notifications/local_notifications_service.dart lib/core/providers/core_providers.dart lib/features/notifications/application/notifications_controller.dart lib/features/notifications/presentation/pages/notifications_page.dart lib/features/settings/application/settings_controller.dart`

## Follow-up
- APNs/FCM 기반 백그라운드/종료 상태 푸시를 위한 디바이스 토큰 등록 API 및 발송 파이프라인을 백엔드와 확정한다.
- 알림 탭 이탈/재진입, 로그인 전환, 권한 거부 시나리오에 대한 기기 QA를 수행한다.

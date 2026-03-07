# ADR-20260308-remote-push-notification-center-lifecycle-delivery

## Status
Accepted

## Date
2026-03-08

## Context
- 요구사항: 앱이 포그라운드/백그라운드/종료 상태 어디에 있든 푸시 수신 시
  휴대폰 알림센터에 알림이 보여야 한다.
- 기존 구현은 포그라운드에서 로컬 알림 위주였고,
  백그라운드 isolate에서는 Firebase 초기화만 수행하여 data-only 메시지의
  알림센터 노출 보장이 약했다.
- iOS 포그라운드 원격 푸시는 `setForegroundNotificationPresentationOptions`
  설정값에 따라 시스템 표시 여부가 달라진다.

## Decision
1. iOS 포그라운드 원격 푸시 시스템 표시를 활성화한다.
   - `alert: true, badge: true, sound: true`
2. Firebase background handler에서 data-only 메시지를
   로컬 알림으로 브리지한다.
   - background isolate에서 plugin 등록/초기화
   - Android 채널 생성(`gbt_notifications_high`)
   - payload 포함 로컬 알림 발행
3. iOS 포그라운드 중복 방지:
   - 원격 알림(`message.notification != null`)은 시스템 표시를 신뢰하고
     앱 로컬 재표시를 건너뛴다.
4. Android manifest에 기본 FCM 채널 ID를 명시한다.
   - `com.google.firebase.messaging.default_notification_channel_id`
5. 푸시 제목/본문 파싱 fallback 키를 확장한다.
   - title: `title` / `notificationTitle` / `subject`
   - body: `body` / `message` / `content`
   - 공급자별 data payload key 차이에도 알림센터 표시를 최대한 보장한다.

## Alternatives Considered
1. 포그라운드/백그라운드 모두 로컬 알림만 사용
   - 단순하지만 iOS 시스템 동작과 충돌 시 중복 표시 위험이 크다.
2. 서버에서 notification payload만 강제
   - data-only 이벤트형 메시지 요구를 모두 커버하지 못한다.

## Consequences
### Positive
- iOS 포그라운드에서 알림센터 노출이 명확해진다.
- Android 및 일부 iOS background/data-only 시나리오에서
  알림센터 노출 가능성이 높아진다.
- 탭 라우팅 payload 전달 경로를 유지한다.

### Trade-offs
- data-only + iOS terminated는 APNs 전달 특성상 100% 보장 불가.
- Firebase 프로젝트 설정(APNs/FCM 파일, capability, signing)이 없으면
  실제 원격 푸시 수신은 여전히 불가하다.

## Scope
- `lib/core/notifications/remote_push_service.dart`
- `android/app/src/main/AndroidManifest.xml`

## Validation
- `flutter analyze lib/core/notifications/remote_push_service.dart lib/core/providers/core_providers.dart lib/main.dart lib/app.dart`

# ADR-20260307-backend-alignment-login-rate-limit-sse-guides

## Status
Accepted (2026-03-07)

## Context
- 모바일 백엔드 변경 연동 요청서(v1.0.0) 기준으로 로그인 오류 분기, 알림 SSE 재연결 정책, 장소 가이드 호출 경로를 점검했습니다.
- 점검 결과 다음 공백이 있었습니다:
  - `429` 재시도 힌트(`Retry-After`, `X-RateLimit-Reset`)를 UI/재시도 정책에서 직접 사용하지 않음
  - 로그인 오류 UX에서 `409` 충돌 분기가 명시적이지 않음
  - 로그인 `409` 재시도 지연이 고정값이라 동시 충돌 시 재시도 집중 가능성이 있었음
  - 알림 SSE 재연결 백오프가 `2s` 시작/무지터 정책이었음
  - 앱 백그라운드/포그라운드 전환 시 SSE 연결 dispose/reconnect 규칙이 앱 전역에서 보장되지 않았음
  - `POST_CREATED` 알림에서 `postId`가 비어 있으면 커뮤니티 진입 폴백이 없어 이동 실패 가능성이 있었음
  - 장소 가이드 로딩이 `/guides`만 사용하고 `/guides/high-priority?limit=...`를 사용하지 않음

## Decision
1. 로그인 rate-limit 힌트 전파
   - `ServerFailure`에 `retryAfterMs` 필드를 추가.
   - `ErrorHandler`가 `429` 응답에서 body/header 기반 재시도 힌트를 추출:
     - body: `retryAfter`, `retryAfterMs`
     - headers: `Retry-After`, `X-RateLimit-Reset`.
2. 로그인 UX/재시도 정합화
   - 로그인 에러 메시지에 `409` 전용 분기 추가.
   - `429`는 `retryAfterMs`가 있으면 `N초 후 재시도` 문구 노출.
   - 로그인 자동 재시도 1회 대기 시간은 `retryAfterMs` 힌트를 우선 사용(안전 범위로 clamp).
   - 로그인 `409` 자동 재시도 1회는 짧은 jitter 지연을 적용.
3. 알림 SSE 재연결 정책 조정
   - 재연결 시작 지연을 `1s`로 변경하고 `1->2->4->8s` cap으로 조정.
   - 재연결 시 소량 jitter를 추가.
4. 알림 SSE 앱 라이프사이클 정합화
   - 백그라운드 전환에서 기존 SSE 연결을 정리하고, 포그라운드 복귀 시 단일 연결로 재시작.
5. 푸시 타입 라우팅 폴백 보완
   - `POST_CREATED`에서 post ID를 해석하지 못하면 커뮤니티 피드(`/board`)로 이동하도록 폴백.
6. 장소 가이드 endpoint 우선순위 변경
   - first page 로딩에서 `/places/{placeId}/guides/high-priority?limit={size}`를 우선 호출.
   - 계약 미지원 오류(`400/404/405/422`)에서는 기존 `/guides?page&size`로 폴백.

## Consequences
### Positive
- 로그인 rate-limit UX가 서버 신호와 정합적으로 동작합니다.
- `409/429`의 사용자 안내가 명확해집니다.
- SSE 동시 재연결 집중 가능성을 줄입니다.
- 백엔드 신규 가이드 endpoint를 활용하면서도 하위 호환을 유지합니다.

### Trade-offs
- `ServerFailure` 모델이 확장되어 일부 테스트/에러 경로에서 점검 포인트가 늘어납니다.
- guides 고우선 endpoint와 legacy endpoint를 모두 다루므로 fetch 경로 복잡도가 증가합니다.

## Validation
- `flutter analyze lib/core/error/failure.dart lib/core/error/error_handler.dart lib/features/auth/data/repositories/auth_repository_impl.dart lib/features/auth/presentation/pages/login_page.dart lib/features/notifications/application/notifications_controller.dart lib/features/places/data/datasources/places_remote_data_source.dart lib/features/places/data/repositories/places_repository_impl.dart`
- `flutter test test/features/auth/data/auth_repository_login_policy_test.dart test/core/error/error_handler_test.dart`
- `flutter test test/features/notifications`
- `flutter test test/features/places`

## Follow-up
- 백엔드가 `X-RateLimit-Reset` 형식을 고정(초/epoch)해주면 클라이언트 파싱 분기를 단순화할 수 있습니다.
- `/guides/high-priority` 정식 배포 완료 후 폴백 조건을 축소할 수 있습니다.

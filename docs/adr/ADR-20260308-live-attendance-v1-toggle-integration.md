# ADR-20260308-live-attendance-v1-toggle-integration

## Status
Accepted

## Date
2026-03-08

## Context
- 라이브 방문 기능은 v2(위치/티켓 검증) 도입 전까지 v1 선언형 토글로
  운영해야 한다.
- 서버 계약은 `PUT /api/v1/projects/{projectId}/live-events/{liveEventId}/attendance`
  단일 엔드포인트로 `DECLARED/VERIFIED/NONE` + `canUndo`를 내려준다.
- v1 단계에서는 방문 상태 전용 조회 API가 없어, 화면 재진입 시 로컬 상태 보존이 필요하다.

## Decision
1. 라이브 상세 페이지의 기존 `참석 인증하기` 액션을 v1 `라이브 방문` 토글로 교체한다.
2. 토글 최종 상태는 항상 서버 응답(`attended/status/canUndo`)으로 동기화한다.
3. `VERIFIED + canUndo=false` 상태는 OFF 액션을 UI에서 비활성화한다.
4. 조회 API 부재 기간에는 이벤트 단위 로컬 캐시를 사용해 재진입 상태를 복원한다.
5. `ATTENDANCE_UPDATE_FAILED`(400)는 취소 불가 안내 메시지로 명시 처리한다.

## Alternatives Considered
1. 기존 인증 시트 유지 + v1 토글 병행 노출
   - 상태 모델이 이원화되어 사용자 혼란이 커지고 정책 충돌 가능성이 높다.
2. 낙관적 업데이트만 사용하고 서버 응답 재동기화 생략
   - 멱등/검증 상태 케이스에서 클라이언트-서버 정합성이 깨질 수 있다.

## Consequences
### Positive
- v2 이전에도 사용자는 단일 토글로 방문 의사를 빠르게 기록할 수 있다.
- 검증 완료 상태의 취소 불가 규칙이 UI에서 선제적으로 반영된다.
- 조회 API가 추가되기 전까지 재진입 UX 공백을 로컬 캐시로 완화한다.

### Trade-offs
- 조회 API 부재 기간에는 다중 디바이스 동기화 지연이 발생할 수 있다.
- 인증 시트를 제거해 상세 페이지에서 즉시 검증 경로 노출은 줄어든다.

## Scope
- `lib/core/constants/api_constants.dart`
- `lib/core/constants/api_v3_endpoints_catalog.dart`
- `lib/features/live_events/application/live_events_controller.dart`
- `lib/features/live_events/data/datasources/live_events_remote_data_source.dart`
- `lib/features/live_events/data/dto/live_event_dto.dart`
- `lib/features/live_events/data/repositories/live_events_repository_impl.dart`
- `lib/features/live_events/domain/entities/live_event_entities.dart`
- `lib/features/live_events/domain/repositories/live_events_repository.dart`
- `lib/features/live_events/presentation/pages/live_event_detail_page.dart`
- `test/features/live_events/data/live_event_dto_test.dart`
- `test/core/constants/api_endpoints_contract_test.dart`

## Validation
- `flutter analyze lib/features/live_events lib/core/constants/api_constants.dart lib/core/constants/api_v3_endpoints_catalog.dart test/features/live_events/data/live_event_dto_test.dart test/core/constants/api_endpoints_contract_test.dart`
- `flutter test test/features/live_events/data/live_event_dto_test.dart test/core/constants/api_endpoints_contract_test.dart`

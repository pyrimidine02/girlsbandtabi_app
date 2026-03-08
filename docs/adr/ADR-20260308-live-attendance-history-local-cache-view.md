# ADR-20260308-live-attendance-history-local-cache-view

## Status
Accepted

## Date
2026-03-08

## Context
- 장소 방문기록(`GET /users/me/visits`)은 앱에서 별도 페이지로 조회 가능하지만,
  라이브 방문(v1)은 토글 API(`PUT /projects/{projectId}/live-events/{liveEventId}/attendance`)만 존재한다.
- v1 사양상 방문 조회 전용 API가 아직 없어도 사용자는 자신의 라이브 방문 기록을
  앱에서 확인할 수 있어야 한다.

## Decision
1. 라이브 방문기록은 로컬 캐시 키(`live_attendance_v1:{projectKey}:{eventId}`)를
   기반으로 구성한다.
2. 캐시 저장 시 `updatedAt/eventTitle/bannerUrl/showStartTime` 스냅샷을 함께 보관한다.
3. 기록 페이지 로딩 시 스냅샷이 비어있는 항목만 라이브 상세 API로 보강한다.
4. 진입점은 두 곳으로 제공한다.
   - 라이브 탭 AppBar 히스토리 버튼
   - 장소 방문기록 페이지 AppBar의 라이브 방문기록 바로가기 버튼

## Alternatives Considered
1. 조회 API가 생길 때까지 기능 미제공
   - 사용자는 방문 토글 결과를 나중에 확인할 수 없어 UX 공백이 크다.
2. 모든 기록 항목에 대해 항상 상세 API 호출
   - 네트워크 비용이 커지고 오프라인/저속 환경에서 체감이 나빠진다.

## Consequences
### Positive
- v1 조회 API 부재 상황에서도 사용자에게 라이브 방문기록 조회 기능을 제공한다.
- 캐시 스냅샷 + 선택적 보강으로 초기 표시 속도와 정보 완성도를 동시에 확보한다.
- 기존 장소 방문기록 UX와 유사한 탐색 흐름을 유지한다.

### Trade-offs
- 서버 단일 소스가 아니므로 다중 디바이스 간 최신성 차이가 생길 수 있다.
- 캐시에 남아 있는 삭제/비공개 이벤트는 보강 실패 시 최소 정보(eventId)로만 표시될 수 있다.

## Scope
- `lib/features/live_events/domain/entities/live_event_entities.dart`
- `lib/features/live_events/application/live_events_controller.dart`
- `lib/features/live_events/presentation/pages/live_event_detail_page.dart`
- `lib/features/live_events/presentation/pages/live_attendance_history_page.dart`
- `lib/features/live_events/presentation/pages/live_events_page.dart`
- `lib/features/visits/presentation/pages/visit_history_page.dart`
- `lib/core/router/app_router.dart`
- `test/features/live_events/domain/live_attendance_history_record_test.dart`

## Validation
- `flutter analyze lib/features/live_events lib/features/visits/presentation/pages/visit_history_page.dart lib/core/router/app_router.dart test/features/live_events/domain/live_attendance_history_record_test.dart`
- `flutter test test/features/live_events/data/live_event_dto_test.dart test/features/live_events/domain/live_attendance_history_record_test.dart test/core/constants/api_endpoints_contract_test.dart`

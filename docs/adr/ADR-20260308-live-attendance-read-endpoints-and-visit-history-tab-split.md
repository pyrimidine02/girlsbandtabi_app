# ADR-20260308-live-attendance-read-endpoints-and-visit-history-tab-split

## Status
Accepted

## Date
2026-03-08

## Context
- 백엔드가 라이브 방문 조회 전용 API를 정식 제공했다.
  - `GET /api/v1/projects/{projectId}/live-events/{liveEventId}/attendance`
  - `GET /api/v1/projects/{projectId}/live-events/attendances`
- 기존 모바일 구현은 조회 API 부재를 전제로 로컬 캐시 기반 보정 로직을
  포함하고 있어, 서버 상태와 분기 조건이 이중화되는 문제가 있었다.
- 설정의 방문 기록 화면에서 장소/라이브를 분리하되 UX 양식은 통일해야 한다.

## Decision
1. 라이브 방문 상태/이력 로딩의 기준을 서버 조회 API로 전환한다.
2. 로컬 캐시 키 스캔 기반 라이브 방문 이력 복원 로직은 제거한다.
3. `설정 > 방문 기록`을 단일 진입으로 유지하고, 내부에서 `장소/라이브` 탭으로 분리한다.
4. 레거시 단독 경로 `/live-attendance`는 신규 구조(`/visits?tab=live`)로 리다이렉트한다.
5. 엔드포인트 계약 테스트에 라이브 방문 단건/목록 `GET` 검증을 추가한다.

## Alternatives Considered
1. 라이브 방문 기록을 기존 단독 페이지로 유지
   - 설정 내 정보구조가 분산되고 사용자 동선이 길어져 UX 일관성이 떨어진다.
2. 조회 API 도입 후에도 로컬 캐시 병행
   - 복잡도가 높고 서버 단일 진실 원칙을 약화시킨다.

## Consequences
### Positive
- 상세/기록 화면 재진입 시 서버 상태 기준으로 일관되게 동기화된다.
- 방문 기록 화면 구조가 단순해지고 장소/라이브 전환이 빨라진다.
- 레거시 링크 유입을 깨지 않으면서 신규 정보구조로 통합 가능하다.

### Trade-offs
- `/live-attendance` 레거시 경로는 당분간 유지(redirect)해야 한다.
- 라이브 방문 기록 목록은 서버 페이지네이션 지연/오류 품질에 직접 영향받는다.

## Scope
- `lib/core/router/app_router.dart`
- `lib/features/visits/presentation/pages/visit_history_page.dart`
- `lib/features/live_events/application/live_events_controller.dart`
- `lib/features/live_events/data/datasources/live_events_remote_data_source.dart`
- `lib/features/live_events/data/repositories/live_events_repository_impl.dart`
- `lib/features/live_events/domain/entities/live_event_entities.dart`
- `lib/features/live_events/domain/repositories/live_events_repository.dart`
- `lib/features/live_events/presentation/pages/live_events_page.dart`
- `test/core/constants/api_endpoints_contract_test.dart`
- `test/features/live_events/domain/live_attendance_history_record_test.dart`

## Validation
- `flutter analyze lib/core/router/app_router.dart lib/features/visits/presentation/pages/visit_history_page.dart lib/features/live_events/presentation/pages/live_events_page.dart lib/features/live_events/application/live_events_controller.dart lib/features/live_events/data/datasources/live_events_remote_data_source.dart lib/features/live_events/data/repositories/live_events_repository_impl.dart lib/features/live_events/domain/entities/live_event_entities.dart lib/features/live_events/domain/repositories/live_events_repository.dart`
- `flutter test test/features/live_events/domain/live_attendance_history_record_test.dart`
- `flutter test test/core/constants/api_endpoints_contract_test.dart`

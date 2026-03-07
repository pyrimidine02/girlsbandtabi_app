# ADR-20260307-page-scoped-api-trigger-policy-enforcement

## Status
Accepted

## Date
2026-03-07

## Context
- 프로젝트 전환 시 오프스크린 페이지까지 연쇄적으로 API를 재호출하는 문제가 있었다.
- 특히 `units`, `community/subscriptions`, feed reload 계열 호출이
  화면 비활성 상태에서도 반복되어 서버 부하와 클라이언트 로그 노이즈를 키웠다.
- `StatefulShellRoute.indexedStack` 구조에서 방문한 branch가 유지되므로,
  단순 `selectedProject` listener는 page visibility를 보장하지 못한다.

## Decision
1. **페이지 활성 상태 기반 트리거**를 기본 정책으로 채택한다.
   - Home=0, Places=1, Live=2, Board=3, Info=4 (`currentNavIndexProvider`).
2. 각 feature controller의 project-change listener는
   **활성 탭일 때만** `load/reload`를 수행한다.
3. 탭 재진입 시 stale 데이터를 방지하기 위해
   `currentNavIndex` 진입 이벤트에서 `forceRefresh`를 1회 수행한다.
4. 프로젝트 선택 위젯에서 직접 `projectUnitsController.load(forceRefresh: true)`를 호출하지 않는다.
   - 선택 변경은 selection state update만 수행하고, 데이터 호출은 각 페이지가 책임진다.
5. 화면 단에서도 비활성 탭의 provider watch를 줄인다.
   - Places/Live의 `projectUnitsControllerProvider` watch를 active-tab 조건으로 제한.
   - Info `TabBarView`에서 News/Units 탭이 active일 때만 provider를 watch.

## Alternatives Considered
1. 모든 provider를 `autoDispose`로 변경
   - 장점: 비가시 상태 정리 강함
   - 단점: 캐시 히트/복귀 UX 저하 가능성, 영향 범위 큼.
2. 글로벌 프로젝트 이벤트 버스 + 페이지별 구독 체계 재설계
   - 장점: 아키텍처적으로 명확
   - 단점: 이번 이슈 대응 범위를 크게 초과.

## Consequences
### Positive
- 프로젝트 전환 시 불필요한 API fan-out이 크게 줄어든다.
- `units` 중복 호출 경로가 제거된다.
- Board/Info 탭의 비활성 상태 호출이 감소한다.

### Trade-offs
- 탭 재진입 시 `forceRefresh` 1회가 발생하므로 복귀 순간 네트워크 호출이 생긴다.
- 탭 비활성 시 데이터가 즉시 갱신되지 않고, 재진입 시점에 동기화된다.

## Scope
- `lib/features/home/application/home_controller.dart`
- `lib/features/places/application/places_controller.dart`
- `lib/features/live_events/application/live_events_controller.dart`
- `lib/features/feed/application/board_controller.dart`
- `lib/features/feed/application/news_controller.dart`
- `lib/features/projects/presentation/widgets/project_selector.dart`
- `lib/features/places/presentation/pages/places_map_page.dart`
- `lib/features/live_events/presentation/pages/live_events_page.dart`
- `lib/features/feed/presentation/pages/info_page.dart`

## Validation
- `flutter analyze` 대상 파일 실행
- 결과: 컴파일 에러 없음, 기존 info warning 1건(`places_map_page.dart:542`) 유지


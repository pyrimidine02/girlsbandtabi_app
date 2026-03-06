# ADR-20260306-live-events-year-filter

## Status
Accepted (2026-03-06)

## Context
- LiveEventsPage에서 이벤트 수가 누적될수록 스크롤 탐색 비용이 커졌고, 사용자 피드백으로 연도 단위 좁혀보기 필요성이 제기되었습니다.
- 기존 필터는 밴드(유닛) 기준만 제공되어 과거/미래 시즌 이벤트를 빠르게 분리하기 어려웠습니다.
- 백엔드 API에 연도 파라미터가 명시되지 않은 상태여서, 우선 클라이언트 측 필터로 즉시 대응이 필요했습니다.

## Decision
### 1) 연도 필터 상태 추가
- `lib/features/live_events/application/live_events_controller.dart`
  - `selectedLiveEventYearProvider` 추가 (`int?`, `null = 전체 연도`).

### 2) 완료 탭 전용 연도 칩 행 추가
- `lib/features/live_events/presentation/pages/live_events_page.dart`
  - `_YearChipFilterRow` 추가.
  - 완료 이벤트 데이터에서 연도 목록을 추출해 `전체 연도 + 연도별` 칩 표시.
  - 완료 탭에서만 기존 밴드 칩 아래에 배치해 필터 구조(밴드 → 연도)를 유지.

### 3) 리스트/캘린더 동일 필터 적용
- 예정 탭은 연도 필터 없이 유지하고, 완료 탭의 `_EventList`에만 `selectedYear` 필터 적용.
- 캘린더 FAB(`_showCalendar`)는 완료 탭에서 열릴 때만 연도 필터를 반영.
- 연도 선택 상태에서 데이터가 없을 때는 해당 연도 기준 메시지로 안내.

## Consequences
### Positive
- 완료 이력 탐색에서 연도 단위로 결과를 빠르게 축소할 수 있습니다.
- 예정 탭은 단순성을 유지하고, 완료 탭만 상세 탐색을 제공하는 구조가 됩니다.

### Trade-offs
- 클라이언트 필터 방식이라 원본 데이터는 여전히 전체 로드합니다(네트워크 비용 절감 효과는 제한적).
- 연도 목록은 현재 로드된 이벤트 집합 기준이므로 서버 페이지네이션 확대 시 서버 측 연도 집계 계약이 필요할 수 있습니다.

## Validation
- `flutter analyze lib/features/live_events/application/live_events_controller.dart lib/features/live_events/presentation/pages/live_events_page.dart` 통과
- `flutter test test/features/live_events` 통과

## Follow-up
- 이벤트 수가 더 증가하면 서버 쿼리 파라미터(`year`) 또는 연도 집계 엔드포인트 추가를 검토합니다.
- 연도 칩 UI에 "최근 연도 우선 + 빠른 점프" 패턴이 필요한지 QA 피드백 후 결정합니다.

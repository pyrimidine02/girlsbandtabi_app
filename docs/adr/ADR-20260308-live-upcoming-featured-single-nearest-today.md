# ADR-20260308-live-upcoming-featured-single-nearest-today

## Status
Accepted

## Date
2026-03-08

## Context
- 라이브 `예정` 탭에서 당일(`D-day`) 이벤트가 여러 개일 때 모든 항목이
  피처드 카드로 렌더링되어 리스트 가독성이 저하되었다.
- 요구사항: 당일 라이브 조건에서는 "가장 최근에 예정된" 라이브 1건만
  크게 보여주고, 나머지는 일반 카드로 유지한다.

## Decision
1. `예정` 탭 피처드 카드는 단일 항목만 허용한다.
2. 당일 이벤트가 존재하면 현재 시각 기준으로 가장 가까운 예정 이벤트를
   피처드 대상으로 선택한다.
3. 당일 이벤트가 없을 때는 `SCHEDULED` 상태 이벤트 중 가장 가까운 항목을
   대체 피처드 대상으로 선택한다.
4. 선정되지 않은 나머지 항목은 기존 `GBTEventCard`를 유지한다.

## Alternatives Considered
1. 기존처럼 `LIVE` 또는 `D-day` 전체를 피처드 처리
   - 강조 카드가 과다 노출되어 정보 우선순위가 흐려진다.
2. 단순 시간순 첫 항목만 피처드 처리
   - 당일 다건 상황에서 "현재 기준 가장 가까운 일정" 의도를 반영하지 못한다.

## Consequences
### Positive
- 당일 다건 상황에서도 상단 강조가 1건으로 수렴되어 스캔성이 개선된다.
- 사용자가 즉시 확인해야 할 가장 가까운 일정에 시각적 집중이 가능하다.

### Trade-offs
- "가장 최근" 해석을 "현재 시각 기준 가장 가까움"으로 정의했으므로,
  "가장 늦은 시간 이벤트"를 기대한 운영 의도와 다를 수 있다.

## Scope
- `lib/features/live_events/presentation/pages/live_events_page.dart`

## Validation
- `flutter analyze lib/features/live_events/presentation/pages/live_events_page.dart`

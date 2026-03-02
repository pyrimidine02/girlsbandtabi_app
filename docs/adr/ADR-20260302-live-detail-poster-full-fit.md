# ADR-20260302: Live Detail Poster Full-Fit Rendering

- Date: 2026-03-02
- Status: Accepted
- Scope: `LiveEventDetailPage`

## Context

라이브 상세 페이지 상단 포스터가 `BoxFit.cover`로 렌더링되어,
세로형 포스터의 상/하단이 잘려 보이는 문제가 있었다.

## Decision

- 라이브 상세 헤더 포스터를 `BoxFit.contain`으로 변경한다.
- `SliverAppBar.expandedHeight`를 화면 너비 기반의 반응형 값으로 확대한다.
  - 계산식: `screenWidth * 1.45`
  - 범위 제한: `300.0 ~ 620.0`
- 포스터 영역 배경은 `Colors.black`으로 고정해 letterbox가 자연스럽게 보이도록 한다.

## Alternatives Considered

1. `BoxFit.cover` 유지 + 높이만 증가
- 장점: 기존 화면 밀도 유지
- 단점: 일부 포스터는 여전히 잘림

2. 포스터 전용 상세 뷰를 별도 화면/모달로 분리
- 장점: 원본 비율 보장
- 단점: 사용자 추가 액션 필요, 이번 요구사항(기본 화면에서 전체 표시)과 불일치

## Consequences

- 장점: 포스터 전체가 항상 보이며 잘림 이슈가 해소된다.
- 단점: 가로 비율 포스터는 좌우/상하 여백(letterbox)이 생길 수 있다.

## Validation

- `dart format lib/features/live_events/presentation/pages/live_event_detail_page.dart`
- `flutter analyze lib/features/live_events/presentation/pages/live_event_detail_page.dart`

# ADR-20260302-live-detail-header-readability

- Date: 2026-03-02
- Status: Accepted

## Context

라이브 상세에서 포스터를 `contain`으로 전체 노출한 이후,
상단 컨트롤(뒤로가기/액션)이 포스터 밝기에 묻혀 보이지 않는 문제가 발생했다.
또한 레터박스 영역의 단색 검정 배경이 시각적으로 부자연스럽다는 피드백이 있었다.

## Decision

- 라이브 상세 헤더 상단 컨트롤을 오버레이 버튼으로 변경한다.
  - 반투명 배경 + 흰색 아이콘으로 포스터 명도와 무관하게 가독성 확보
- 포스터 주변 단색 검정 배경을 제거한다.
  - 뒤 레이어: 같은 포스터를 `BoxFit.cover` + 낮은 opacity로 배경 채움
  - 앞 레이어: 기존 `BoxFit.contain` 포스터 유지
- 상단에는 약한 그라데이션 스크림을 추가해 버튼 가독성을 보강한다.

## Alternatives Considered

1. AppBar 아이콘 색상만 흰색 고정
- 장점: 구현 단순
- 단점: 포스터 배경의 밝기/복잡도에 따라 여전히 식별이 어려움

2. 기존 검정 레터박스 유지 + 높이만 조정
- 장점: 구현 단순
- 단점: 디자인 이질감 지속

## Consequences

- 장점: 포스터 전체 노출 유지 + 컨트롤 접근성 개선
- 장점: 단색 검정 테두리 느낌 제거
- 단점: 헤더 렌더링 레이어가 1개 증가

## Validation

- `dart format lib/features/live_events/presentation/pages/live_event_detail_page.dart`
- `flutter analyze lib/features/live_events/presentation/pages/live_event_detail_page.dart`

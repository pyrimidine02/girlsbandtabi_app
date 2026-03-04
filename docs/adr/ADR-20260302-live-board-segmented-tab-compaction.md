# ADR-20260302-live-board-segmented-tab-compaction

- Date: 2026-03-02
- Status: Accepted

## Context

라이브 페이지(`예정/완료`)와 게시판 페이지(`커뮤니티/여행 후기`)의 상단 세그먼트 탭이
상대적으로 크게 보이면서 AppBar 내에서 과한 강조로 인식되는 UX 피드백이 있었다.

## Decision

- `GBTSegmentedTabBar`에 페이지별 미세 조정을 위한 옵션을 추가한다.
  - `height`, `borderRadius`, `indicatorBorderRadius`, `indicatorShadow`
  - `labelStyle`, `unselectedLabelStyle`, `labelPadding`
- 라이브/게시판 페이지에서만 compact 프리셋을 적용한다.
  - 높이 `44`
  - 내부 패딩 `2`
  - 인디케이터 그림자 제거
  - 라벨 스타일 `tabLabel/labelMedium`
  - 게시판 탭 텍스트를 `여행후기` → `여행 후기`로 교정

## Alternatives Considered

1. 전역 세그먼트 탭 스타일 일괄 축소
- 장점: 구현 단순
- 단점: 검색/즐겨찾기 등 기존 화면 의도까지 함께 바뀌는 회귀 위험

2. 페이지별 별도 탭 위젯 생성
- 장점: 완전한 독립 제어
- 단점: 공통 컴포넌트 중복 증가

## Consequences

- 장점: 문제 제기된 두 화면만 자연스러운 밀도로 조정 가능
- 장점: 공통 컴포넌트 재사용을 유지하면서 페이지별 튜닝 가능
- 단점: 공통 위젯 옵션이 늘어 관리 포인트가 증가

## Validation

- `dart format` 적용
- `flutter analyze`로 변경 파일 무결성 확인

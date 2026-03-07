# ADR-20260307-board-subnav-pill-restyle

## Status
Accepted (2026-03-07)

## Context
- 게시판 분기 진입 시 기존 서브 네비게이션은 상단만 둥근 바 형태였다.
- 사용자 요청은 `back + section tabs` 구성을 유지하면서, 더 진한 다크 글래스 기반의
  플로팅 pill 스타일(원형 back 버튼 강조)로 시각 톤을 변경하는 것이었다.

## Decision
- `lib/shared/main_scaffold.dart`의 `_BoardSubBottomNav`만 리스타일한다.
- 정보 구조/라우팅은 변경하지 않는다.
  - back 동작 유지
  - section 전환(`/board`, `/board/discover`, `/board/travel-reviews-tab`) 유지
- 스타일 변경 내용:
  - full-radius pill container
  - dark gradient + blur + thin border
  - stronger shadow
  - circular back action button
  - selected/unselected icon-label contrast 강화
  - light/dark 각각 기존 `GBTColors` 토큰 기반 색상 매핑 적용
  - iOS는 `ContinuousRectangleBorder` 기반 연속 곡률 + 더 큰 radius(38),
    Android는 기존 radius(34) 유지

## Consequences
- 사용자 요청 레퍼런스에 가까운 서브 내비게이션 시각을 제공한다.
- 기능 동작은 동일하므로 라우팅/상태 회귀 리스크가 낮다.
- 하단 safe-area 위에 플로팅되므로 실제 기기 QA가 필요하다.

## Verification
- `flutter analyze lib/shared/main_scaffold.dart`

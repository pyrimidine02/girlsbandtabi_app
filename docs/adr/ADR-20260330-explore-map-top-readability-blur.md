# ADR-20260330: Explore map top readability blur layer

## Status
- Accepted (2026-03-30)

## 변경 전 문제
- 탐방 지도 화면이 edge-to-edge로 확장되면서 상태바 시간/아이콘과
  최상단 컨트롤 뒤 배경이 지도 타일 색상에 직접 영향을 받았습니다.
- 밝거나 패턴이 복잡한 타일 구간에서 상단 정보 가독성이 떨어지는 경우가 있었습니다.

## 대안
1. 상태바 아이콘 스타일(라이트/다크)만 고정한다.
2. 지도 상단 영역에 약한 블러 + 스크림 레이어를 적용한다.

## 결정
- 대안 2를 채택한다.
- `PlacesMapPage` 스택에 상단 전용 `_TopMapReadabilityOverlay`를 추가한다.
- 오버레이는 `BackdropFilter.blur(sigma: 7)` + 세로 그라데이션 스크림으로 구성하고,
  범위는 플랫폼별로 다르게 제한한다.
  - iOS: `safe area top`(노치/다이나믹 아일랜드 높이)만 적용.
  - Android: 검색창 바로 위 스트립에만 적용
    (높이 = 검색창↔알약 칩 간격).

## 근거
- 아이콘 스타일 고정만으로는 지도 배경 변화(밝기/채도/패턴)에 대응하기 어렵다.
- 상단 국소 영역만 보정하면 전체 지도 가시성을 크게 해치지 않으면서
  상태바/상단 컨트롤 대비를 안정적으로 확보할 수 있다.
- 플랫폼 뷰에서 블러 효과가 제한되는 환경에서도 스크림이 대비 보정 역할을 수행한다.

## 영향 범위
- UI:
  - `lib/features/places/presentation/pages/places_map_page.dart`
- 문서:
  - `CHANGELOG.md`
  - `TODO.md`

## 검증 메모
- `flutter analyze lib/features/places/presentation/pages/places_map_page.dart lib/features/explore/presentation/pages/explore_page.dart` 통과.
- `flutter test test/features/places/application/places_controller_test.dart` 통과.

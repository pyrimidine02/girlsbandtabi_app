# ADR-20260330: Explore map edge-to-edge fill

## Status
- Accepted (2026-03-30)

## 변경 전 문제
- 탐방 탭 루트(`ExplorePage`)가 전체 `SafeArea(top)`로 감싸져 있어,
  지도 서브탭(`PlacesMapPage`)이 상태바 아래에서 시작했습니다.
- 그 결과 지도 상단에 체감상 빈 여백이 생기고,
  지도 화면이 전체를 꽉 채우지 않는 UX가 발생했습니다.

## 대안
1. `PlacesMapPage`에서만 지도 레이어를 음수 오프셋으로 끌어올린다.
2. `ExplorePage`의 루트 `SafeArea(top)`를 제거하고,
   하단 모드 pill 보정만 유지한다.

## 결정
- 대안 2를 채택한다.
- `ExplorePage`에서 상단 `SafeArea`를 제거해 `TabBarView`가 전체 뷰포트를 사용하도록 변경한다.
- `MediaQuery.padding`은 상단을 덮어쓰지 않고,
  하단에만 `_modeBarHeight`를 추가해 플로팅 모드 pill과의 충돌만 방지한다.

## 근거
- 문제의 원인이 루트 레이아웃 제약(`SafeArea(top)`)이므로,
  하위 페이지에서 음수 오프셋을 적용하는 방식보다 구조적으로 단순하다.
- 지도 탭은 edge-to-edge 렌더링을 얻고,
  다른 서브탭은 각 페이지의 `Scaffold/AppBar` 안전영역 처리로 기존 동작을 유지할 수 있다.
- 하단 pill 오버레이 보정은 유지되어 기존 스크롤/터치 영역 회귀를 줄인다.

## 영향 범위
- UI:
  - `lib/features/explore/presentation/pages/explore_page.dart`
- 문서:
  - `CHANGELOG.md`
  - `TODO.md`

## 검증 메모
- `flutter analyze lib/features/explore/presentation/pages/explore_page.dart lib/features/places/presentation/pages/places_map_page.dart` 통과.
- `flutter test test/features/places/application/places_controller_test.dart` 통과.

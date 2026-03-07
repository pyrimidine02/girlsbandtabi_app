# ADR-20260308-unified-search-global-entry-and-reference-style-discovery

## Status
Accepted

## Date
2026-03-08

## Context
- 요구사항:
  - 앱 내 어느 페이지에서든 돋보기 아이콘 탭 시 통합 검색 페이지로 진입해야 한다.
  - 통합 검색 화면은 제공된 레퍼런스의 시각 구조를 따르되, 문구/구성 요소는
    GirlsBandTabi 도메인에 맞춰야 한다.
- 기존 상태:
  - 일부 화면(Home/Feed)은 `/search`로 이동했지만,
    Board는 커뮤니티 전용 검색 시트를 열어 동작이 일관되지 않았다.
  - Places 상단 검색 카드는 지도 전용 검색만 제공했다.
  - Search 페이지는 기능은 있었지만 레퍼런스와 다른 정보 구조였다.

## Decision
1. 검색 진입점을 전역 통합 경로(`/search`)로 통일한다.
   - Home/Feed/Board 검색 아이콘 → `/search`
   - Places 상단 검색 카드 탭 → `/search`
2. Places의 지도 전용 검색은 호환성 유지를 위해 long-press로 유지한다.
3. Search 페이지 상단을 레퍼런스 톤으로 재구성한다.
   - 뒤로가기 + 대형 라운드 검색 입력창
   - 검색 범위 필 토글(현재 프로젝트/전체)
4. query empty 상태에서 도메인 맞춤 탐색 섹션을 제공한다.
   - 인기 통합 검색 (랭킹 행)
   - 인기 탐색 카테고리 (랭킹 행)
   - 검색 둘러보기 (수평 칩)
5. query non-empty 상태의 기존 통합검색 API 흐름/탭 필터는 유지한다.

## Alternatives Considered
1. 기존 화면별 검색 동작 유지
   - 화면마다 사용자 기대가 달라 학습 비용이 증가한다.
2. Places 지도 검색 완전 제거
   - 지도 맥락 탐색 UX가 손실된다.
3. Search 페이지 기능을 레퍼런스 시안 중심 정적 화면으로 단순화
   - 실제 통합검색 기능 요구를 충족하지 못한다.

## Consequences
### Positive
- 검색 진입 경험이 전 화면에서 일관된다.
- 레퍼런스 톤을 반영해 검색 허브의 정보 스캔성이 개선된다.
- 통합검색 기능(실제 API 결과)은 유지되어 기능 회귀가 없다.

### Trade-offs
- Places에서 탭 검색이 통합검색으로 바뀌어 기존 지도 전용 검색 접근성이 낮아진다
  (long-press로 보완).
- 인기/탐색 섹션 일부 지표는 UI 가독성 중심으로 구성된 클라이언트 표현이며,
  서버 집계 지표와 1:1 대응하지 않는다.

## Scope
- `lib/features/search/presentation/pages/search_page.dart`
- `lib/features/home/presentation/pages/home_page.dart`
- `lib/features/feed/presentation/pages/board_page.dart`
- `lib/features/places/presentation/pages/places_map_page.dart`

## Validation
- `flutter analyze lib/features/search/presentation/pages/search_page.dart lib/features/home/presentation/pages/home_page.dart lib/features/feed/presentation/pages/board_page.dart lib/features/places/presentation/pages/places_map_page.dart`

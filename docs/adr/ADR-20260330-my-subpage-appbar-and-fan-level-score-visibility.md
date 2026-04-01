# ADR-20260330: My sub-page appbar standardization and fan-level score visibility

## Status
- Accepted (2026-03-30)

## 변경 전 문제
- `마이` 영역 하위 페이지(`나의 덕력`, `성지순례 도감`, `응원 가이드` 등)의
  AppBar 디자인이 페이지마다 달라 `정보/유저` 탭 기준 스타일과 일관성이 깨졌다.
- `나의 덕력` 페이지는 최근 활동 중심으로만 보여주어
  점수 부여 행위를 한눈에 확인하기 어려웠다.

## 대안
1. 각 페이지 AppBar를 개별 수정한다.
2. 공통 AppBar 헬퍼를 만들고 하위 페이지에 적용한다.

## 결정
- 대안 2를 채택한다.
- `lib/core/widgets/navigation/gbt_standard_app_bar.dart`를 추가해
  `정보/유저` 탭 기준 상단바 스타일(플랫, no elevation, titleMedium w700)을 공통화한다.
- `마이` 영역 주요 하위 페이지 AppBar를 공통 헬퍼로 통일한다.
- `FanLevelPage`에 `점수 부여 행위 전체` 섹션을 추가하고,
  `점수 획득 내역`은 `xpEarned > 0` 항목만 노출한다.

## 근거
- 상단바 디자인 기준을 코드 레벨에서 일원화하면 화면 추가/수정 시 회귀를 줄일 수 있다.
- 점수 부여 행위 카탈로그 + 실제 점수 획득 내역 분리는
  규칙 인지(무엇이 점수가 되는지)와 기록 확인(내가 무엇으로 점수를 얻었는지)을 동시에 해결한다.

## 영향 범위
- UI:
  - `lib/core/widgets/navigation/gbt_standard_app_bar.dart` (신규)
  - `lib/features/fan_level/presentation/pages/fan_level_page.dart`
  - `lib/features/zukan/presentation/pages/zukan_page.dart`
  - `lib/features/zukan/presentation/pages/zukan_detail_page.dart`
  - `lib/features/cheer_guides/presentation/pages/cheer_guides_page.dart`
  - `lib/features/cheer_guides/presentation/pages/cheer_guide_detail_page.dart`
  - `lib/features/quotes/presentation/pages/quotes_page.dart`
  - `lib/features/favorites/presentation/pages/favorites_page.dart`
  - `lib/features/feed/presentation/pages/post_bookmarks_page.dart`
  - `lib/features/visits/presentation/pages/visit_history_page.dart`
  - `lib/features/visits/presentation/pages/visit_stats_page.dart`
  - `lib/features/titles/presentation/pages/title_catalog_page.dart`
  - `lib/features/calendar/presentation/pages/calendar_page.dart`
- Test:
  - `test/features/fan_level/presentation/fan_level_page_test.dart` (신규)
- 문서:
  - `CHANGELOG.md`
  - `TODO.md`

## 검증 메모
- `flutter analyze lib/core/widgets/navigation/gbt_standard_app_bar.dart lib/features/fan_level/presentation/pages/fan_level_page.dart lib/features/zukan/presentation/pages/zukan_page.dart lib/features/zukan/presentation/pages/zukan_detail_page.dart lib/features/cheer_guides/presentation/pages/cheer_guides_page.dart lib/features/cheer_guides/presentation/pages/cheer_guide_detail_page.dart lib/features/quotes/presentation/pages/quotes_page.dart lib/features/favorites/presentation/pages/favorites_page.dart lib/features/feed/presentation/pages/post_bookmarks_page.dart lib/features/visits/presentation/pages/visit_history_page.dart lib/features/visits/presentation/pages/visit_stats_page.dart lib/features/titles/presentation/pages/title_catalog_page.dart lib/features/calendar/presentation/pages/calendar_page.dart` 통과.
- `flutter analyze test/features/fan_level/presentation/fan_level_page_test.dart` 통과.
- `flutter test test/features/fan_level/presentation/fan_level_page_test.dart` 통과.

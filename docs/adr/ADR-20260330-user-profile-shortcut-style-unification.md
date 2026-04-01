# ADR-20260330: User profile shortcut style unification

## Status
- Accepted (2026-03-30)

## 변경 전 문제
- `덕력/성지 기록/라이브 기록` 숏컷이 `ActionChip` 스타일로 표시되어
  활동 통계/목록 카드와 시각 톤이 분리되어 보였다.

## 대안
1. 기존 칩 스타일 유지.
2. 숏컷을 카드형 3열 그리드로 변경해 상단 카드 디자인과 통일.

## 결정
- 대안 2를 채택한다.
- 숏컷 액션을 `ActionChip`에서 카드형 `InkWell` 컴포넌트로 교체한다.
- 3열 반응형 그리드로 균일 폭/높이를 보장한다.
- 활동 통계와 같은 팔레트 계열을 사용해 페이지 톤을 통일한다.

## 근거
- 프로필 화면 내 반복되는 카드 패턴을 통일하면 시각적 일관성과 정보 스캔성이 개선된다.
- 카드형 버튼은 칩 대비 탭 타깃이 커져 사용성이 좋아진다.

## 영향 범위
- UI:
  - `lib/features/feed/presentation/pages/user_profile_page.dart`
- 문서:
  - `CHANGELOG.md`
  - `TODO.md`

## 검증 메모
- `flutter analyze lib/features/feed/presentation/pages/user_profile_page.dart` 통과.

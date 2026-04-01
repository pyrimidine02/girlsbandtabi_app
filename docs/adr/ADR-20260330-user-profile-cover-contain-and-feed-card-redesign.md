# ADR-20260330: User profile cover contain mode and feed list card redesign

## Status
- Accepted (2026-03-30)

## 변경 전 문제
- 커버 이미지가 `BoxFit.cover`로 렌더링되어 원본 일부가 크롭됐다.
- `작성한 글`/`작성한 댓글` 목록은 기존 단색 카드 스타일로,
  상단 활동 통계 카드와 시각 톤이 분리되어 보였다.

## 대안
1. 커버 크롭 상태를 유지하고 목록 카드만 개선한다.
2. 커버를 `contain`으로 변경해 전체 이미지를 보여주고,
   하단 목록 카드도 통계 카드 톤으로 통일한다.

## 결정
- 대안 2를 채택한다.
- 커버 이미지는 `BoxFit.contain`으로 렌더링해 이미지 전체가 보이도록 한다.
- `작성한 글`/`작성한 댓글` 카드는 활동 통계와 동일한 팔레트 계열의
  그라데이션 카드 스타일로 재디자인한다.

## 근거
- 커버 원본 전체 노출 요구는 크롭 최소화보다 우선순위가 높다.
- 목록 카드 스타일 통일은 프로필 페이지의 시각 일관성과 정보 계층을 개선한다.

## 영향 범위
- UI:
  - `lib/features/feed/presentation/pages/user_profile_page.dart`
- 문서:
  - `CHANGELOG.md`
  - `TODO.md`

## 검증 메모
- `flutter analyze lib/features/feed/presentation/pages/user_profile_page.dart` 통과.

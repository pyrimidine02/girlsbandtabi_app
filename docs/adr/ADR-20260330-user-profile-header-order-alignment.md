# ADR-20260330: User profile header order and alignment refinement

## Status
- Accepted (2026-03-30)

## 변경 전 문제
- 커버 이미지 노출 높이가 부족해 사용자가 원하는 영역이 충분히 보이지 않았다.
- `프로필 수정/칭호` 액션과 닉네임/가입일/소개 시작 위치가 사용자 기대 순서와 달랐다.

## 대안
1. 기존 레이아웃 유지 후 간격만 미세 조정한다.
2. 커버 높이를 확장하고, 액션/정보 시작 위치를 명확한 규칙으로 재배치한다.

## 결정
- 대안 2를 채택한다.
- `SliverAppBar.expandedHeight`를 `280`으로 확장한다.
- `프로필 수정/칭호` 액션은 커버-본문 경계 바로 아래 우측 상단에 배치한다.
- 닉네임/가입일/소개 정보는 아바타 바로 아래에서 시작하도록 상단 간격을 줄인다.

## 근거
- 헤더 이미지 영역 확장은 커버 가시성과 사용자 만족도에 직접적으로 기여한다.
- 액션과 정보 블록의 시작 위치를 분리하면 시선 흐름이 명확해진다.

## 영향 범위
- UI:
  - `lib/features/feed/presentation/pages/user_profile_page.dart`
- 문서:
  - `CHANGELOG.md`
  - `TODO.md`

## 검증 메모
- `flutter analyze lib/features/feed/presentation/pages/user_profile_page.dart` 통과.

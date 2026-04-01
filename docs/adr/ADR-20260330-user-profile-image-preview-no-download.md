# ADR-20260330: User profile image full-screen preview without download action

## Status
- Accepted (2026-03-30)

## 변경 전 문제
- 사용자 프로필의 아바타/커버 이미지를 크게 볼 수 있는 확대 진입 경로가 없었다.
- 사용자 요구사항으로 “확대 보기 제공 + 다운로드 기능 미노출”이 명시되었다.

## 대안
1. 기존 상태 유지(확대 기능 미제공).
2. 프로필 이미지 탭 시 풀스크린 확대 뷰어를 열고, 저장/다운로드 액션은 제외한다.

## 결정
- 대안 2를 채택한다.
- 커버 이미지와 프로필 아바타에 탭 제스처를 추가해 단일 이미지 풀스크린 뷰어를 연다.
- 뷰어는 `InteractiveViewer` 기반 확대/팬만 제공하고,
  다운로드 아이콘/저장 버튼은 제공하지 않는다.

## 근거
- 이미지 상세 확인은 프로필 UI의 기본 기대 기능이다.
- 다운로드 버튼이 있을 경우 사용자 의도와 다른 저장 동작이 노출될 수 있다.
- 단일 이미지 전용 뷰어는 구현 복잡도가 낮고 회귀 범위가 작다.

## 영향 범위
- UI:
  - `lib/features/feed/presentation/pages/user_profile_page.dart`
- 문서:
  - `CHANGELOG.md`
  - `TODO.md`

## 검증 메모
- `flutter analyze lib/features/feed/presentation/pages/user_profile_page.dart` 통과.

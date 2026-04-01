# ADR-20260326: User profile activity overview and cover visibility update

## Status
- Accepted (2026-03-26)

## 변경 전 문제
- 커뮤니티 프로필 페이지가 사실상 `작성한 글/작성한 댓글` 중심으로만 구성되어,
  유저의 서비스 전반 활동(XP, 레벨, 성지/라이브 방문)을 한눈에 파악하기 어려웠다.
- 프로필 배경 이미지 크롭 비율(16:9)과 실제 표시 비율이 일치하지 않아
  편집 화면에서 본 결과보다 프로필 헤더에서 더 많이 잘려 보였다.

## 대안
1. 기존 프로필 구조를 유지하고 게시글/댓글 탭만 개선한다.
2. 프로필 헤더에 활동 요약 카드를 추가하고, 커버 크롭/표시 비율을
   동일한 16:9로 통일한다.
3. 별도 “활동 대시보드” 페이지를 신설해 프로필과 분리한다.

## 결정
- 대안 2를 채택한다.
- 프로필 헤더에 활동 요약(6개 카드)을 추가한다:
  - XP, 레벨, 방문 성지 수, 방문 라이브 수, 작성 글 수, 작성 댓글 수
- 내 프로필은 기존 앱 데이터 소스(`fanLevel`, `visits`, `live attendance`)를
  결합해 값을 보강한다.
- 타인 프로필은 공개 프로필 응답에서 통계 필드가 내려오면 사용하고,
  없으면 `-`로 폴백한다.
- 커버 크롭/표시 규칙을 공통 상수로 통일한다.
  - 크롭 비율: `16:9`
  - 편집 미리보기: `16:9 AspectRatio`
  - 프로필 헤더: `16:9 AspectRatio`
- 커버 이미지 최대 업로드 해상도를 `2560x1440`으로 상향한다.

## 근거
- 유저 요청의 핵심은 “활동 내역이 잘 드러나는 프로필”이며,
  헤더 수준의 요약 카드는 탐색 비용을 가장 낮게 만든다.
- 공개 프로필 API 스키마상 통계 필드 보장이 약하므로,
  안전 폴백(`-`)이 필수다.
- 비율 통일은 “편집 화면과 실제 화면이 다르게 보이는 문제”를 직접 해결한다.
- 해상도 상향은 커버 표시 영역 확대 시에도 화질 저하를 줄인다.

## 영향 범위
- UI:
  - `lib/core/constants/profile_media_constants.dart`
  - `lib/features/feed/presentation/pages/user_profile_page.dart`
  - `lib/features/settings/presentation/pages/profile_edit_page.dart`
- 데이터 모델:
  - `lib/features/settings/data/dto/user_profile_dto.dart`
  - `lib/features/settings/domain/entities/user_profile.dart`
- 테스트:
  - `test/features/settings/data/user_profile_dto_test.dart`

## 검증 메모
- `flutter analyze` (대상 파일) 통과.
- `flutter test test/features/settings/data/user_profile_dto_test.dart` 통과.
- 백엔드 계약 확정(2026-03-26):
  - 응답 경로: `GET /api/v1/users/me`, `GET /api/v1/users/{userId}`
  - 통계 8개 필드는 항상 제공(값 없으면 `0`, `fanLevel=1`, `fanGrade="일반인"`).
  - canonical payload(`id` + 통계 필드) 회귀 테스트를 추가해 파싱 안정성을 고정.

# ADR-20260330: User profile avatar unobstructed rendering

## Status
- Accepted (2026-03-30)

## 변경 전 문제
- `UserProfilePage` 헤더의 아바타가 장식 래퍼(배경/테두리/그림자) 안에 렌더링되어,
  실제 프로필 사진 외곽 일부가 UI 장식에 의해 가려지는 형태였다.
- 사용자 요구사항은 “프로필 사진을 아무것도 가리지 않게” 표시하는 것이었다.

## 대안
1. 기존 장식(테두리/그림자)을 유지하고 색상/두께만 조정한다.
2. 장식 래퍼를 제거하고 아바타 이미지를 직접 렌더링한다.

## 결정
- 대안 2를 채택한다.
- 아바타 래퍼 컨테이너를 제거하고 `_ProfileAvatar`를 직접 배치한다.
- 슬리버 경계에서 가려짐이 발생하지 않도록 아바타를 `SliverAppBar`의
  커버 영역 내부(`bottom` 양수 오프셋)에서 렌더링한다.
- 기존 레이아웃 높이/버튼 정렬과의 호환을 위해 아바타 반경은
  `_kAvatarRadius + _kAvatarBorder`를 사용한다.

## 근거
- 사용자 요구는 시각 장식보다 “사진 비가림(fully visible)”이 우선이다.
- 래퍼 제거가 가장 단순하고 회귀 위험이 낮은 방법이다.
- 아바타가 슬리버 경계를 넘어 오버플로우되면 커버/본문 레이어와의 페인트 순서에
  따라 일부가 가려질 수 있어, 경계 안쪽 배치가 가장 안정적이다.
- 반경 보정으로 기존 헤더 간격 계산(`_kAvatarTotal`)과의
  정렬 영향을 최소화할 수 있다.

## 영향 범위
- UI:
  - `lib/features/feed/presentation/pages/user_profile_page.dart`
- 문서:
  - `CHANGELOG.md`
  - `TODO.md`

## 검증 메모
- `flutter analyze lib/features/feed/presentation/pages/user_profile_page.dart` 통과.

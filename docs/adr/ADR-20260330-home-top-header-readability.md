# ADR-20260330 Home Top Header Readability

## Status
- Accepted (2026-03-30)

## Context
- 홈 상단 헤더는 배경 이미지/그라디언트 위에 AppBar와 인사말 텍스트를 겹쳐 렌더링합니다.
- AppBar `foregroundColor`를 설정해도, 실제 title/action은 테마 기본 스타일 영향으로
  대비가 불안정해지는 구간이 있었습니다.
- 밝은 배경 이미지에서는 인사말 subtitle과 featured live 칩의 텍스트 판독성이 떨어졌습니다.

## Decision
- `HomePage` AppBar에 스크롤 상태 기반의 명시 스타일을 적용합니다.
  - `titleTextStyle`, `iconTheme`, `actionsIconTheme`를 동적으로 지정해
    상단(투명)에서는 밝은 색, 스크롤 후에는 테마 대비에 맞는 색을 사용합니다.
  - `systemOverlayStyle`도 스크롤 상태에 맞춰 동적으로 전환합니다.
- `GBTGreetingHeader`의 텍스트/오버레이 대비를 소폭 강화합니다.
  - title/subtitle에 그림자(shadow) 추가
  - 배경 오버레이 그라디언트 상단/하단 알파 강화
  - featured live 칩 배경/테두리 대비 강화
- 재사용 위젯 확장:
  - `GBTAppBarIconButton`에 `iconColor` 옵션 추가
  - `GBTProfileAction`에 플레이스홀더 배경/아이콘 색상 오버라이드 옵션 추가

## Alternatives Considered
- 헤더 배경 자체를 더 어둡게 고정:
  - Rejected: 배경 이미지/브랜드 톤 손실이 크고 전반적인 분위기가 과도하게 무거워짐.
- AppBar에 불투명 배경을 항상 적용:
  - Rejected: 기존 immersive 헤더 경험을 훼손함.

## Consequences
- 배경 이미지 명도 변화에 덜 민감한 상단 가독성을 확보합니다.
- 공용 AppBar 액션 컴포넌트의 색상 제어 지점이 생겨 화면별 대비 튜닝이 쉬워집니다.

## Validation
- `flutter analyze lib/features/home/presentation/pages/home_page.dart lib/core/widgets/layout/gbt_greeting_header.dart lib/core/widgets/navigation/gbt_app_bar_icon_button.dart lib/core/widgets/navigation/gbt_profile_action.dart` passed.

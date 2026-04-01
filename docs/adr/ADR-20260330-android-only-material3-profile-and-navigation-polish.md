# ADR-20260330: Android-only Material 3 polish for profile and navigation

## Status
- Accepted (2026-03-30)

## 변경 전 문제
- iOS 대비 Android 화면의 촉감(press state), 계층(elevation), 선택 상태 대비가 약해
  전체 완성도가 낮게 느껴졌다.
- 하단 네비게이션/커뮤니티 서브 하단바/프로필 헤더와 탭 영역이
  Android에서 상대적으로 평면적으로 보였다.
- 버튼/탭 터치 타깃이 compact 기준이라 Android에서 조작감이 다소 답답했다.

## 대안
1. 공통 디자인만 유지하고 플랫폼 차이를 최소화한다.
2. Android에서만 Material 3 상호작용/계층/간격을 강화하고 iOS는 유지한다.

## 결정
- 대안 2를 채택한다.
- `TargetPlatform.android` 조건으로 Android 전용 스타일을 적용하고,
  iOS 경로는 기존 디자인을 유지한다.
- 적용 범위:
  - 하단 네비게이션(`GBTBottomNav`) Android 쉘 강화
  - 커뮤니티 서브 하단바 Android 톤 통일
  - 프로필 페이지(Android): 헤더 백버튼 가독성, 버튼 터치 타깃, 스티키 탭바 elevation,
    정보 간격 리듬, 팔로워/팔로잉 ripple 피드백 개선
  - 세그먼트 탭바(Android): overlay state layer, indicator 대비, 패딩/라운드 조정

## 근거
- Android Material 3 컴포넌트는 동적 색/상태 레이어/컴포넌트 계층을 전제로 설계되며,
  플랫폼 기본 감각과 일치할 때 조작성과 인지성이 좋아진다.
- FAB는 Android에서 기본적으로 우하단 메인 액션 앵커가 권장되므로,
  하단 네비게이션의 시각 계층을 정돈해 FAB와 역할 분리를 명확히 할 필요가 있다.
- Flutter Material 컴포넌트(`NavigationBar`, `TabBar overlayColor`)를 활용하면
  Android 전용 인터랙션 강화가 가능하면서도 iOS 경로를 분리 유지할 수 있다.

## 영향 범위
- UI:
  - `lib/core/widgets/navigation/gbt_bottom_nav.dart`
  - `lib/shared/main_scaffold.dart`
  - `lib/features/feed/presentation/pages/user_profile_page.dart`
  - `lib/core/widgets/navigation/gbt_segmented_tab_bar.dart`
- 문서:
  - `CHANGELOG.md`
  - `TODO.md`

## 검증 메모
- `flutter analyze lib/features/feed/presentation/pages/user_profile_page.dart lib/core/widgets/navigation/gbt_segmented_tab_bar.dart lib/core/widgets/navigation/gbt_bottom_nav.dart lib/shared/main_scaffold.dart` 통과.

## 참고 문서
- Android Developers (FAB quick guide):
  - https://developer.android.com/quick-guides/content/create-floating-action-button
- Android Developers (Compose Material 3 release notes):
  - https://developer.android.com/jetpack/androidx/releases/compose-material3
- Flutter API (`NavigationBar`):
  - https://api.flutter.dev/flutter/material/NavigationBar-class.html
- Flutter API (`FloatingActionButtonLocation.endFloat`):
  - https://api.flutter.dev/flutter/material/FloatingActionButtonLocation/endFloat-constant.html

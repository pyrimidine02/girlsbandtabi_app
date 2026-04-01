# ADR-20260331: Community Compose FAB Nav-Gap Alignment

## Status
- Accepted (2026-03-31)

## Context
- 커뮤니티 새글 작성 FAB가 iOS/Android 모두에서 하단바 대비
  지나치게 위에 배치되어 시각적 일관성이 떨어졌습니다.
- 직전 정책은 하단바 겹침/터치 안정성을 위해
  `safeArea + navReserved + platformClearance`를 사용했고,
  추가 clearance(`Android +28`, `iOS +24`)로 인해 FAB가 높아졌습니다.

## Problem (Before)
- 사용자 기대는 "하단바 바로 위" 배치였지만,
  플랫폼별 clearance로 FAB와 하단바 사이 간격이 과도했습니다.
- 플랫폼별 분기값으로 인해 위치 의도를 직관적으로 유지하기 어려웠습니다.

## Decision
- `resolveCommunityFabBottomPadding` 계산식을 다음으로 단순화합니다.
  - `subNavVisualHeight + subNavBottomInset + desiredGapAboveNav - defaultFabFloatMargin + scaledVisualLiftCompensation`
  - `subNavVisualHeight = 72dp` (`64dp + 8dp`)
  - `subNavBottomInset = 10dp` (`MainScaffold` sub-nav minimum inset)
  - `desiredGapAboveNav = 5dp` (target gap above nav top)
  - `defaultFabFloatMargin = 16dp` (`endFloat` 기본 마진 상쇄)
  - `scaledVisualLiftCompensation = clamp(38 * screenHeight / 932, 28..48)dp`
    (iPhone 17 Pro Max baseline + cross-device ratio scaling)
- 플랫폼별 clearance 분기값은 제거합니다.
- `FeedPage`와 `BoardPage` 모두 동일 유틸 계산식을 유지합니다.

## Rationale
- "하단바 바로 위"라는 UX 의도를 수식으로 직접 반영할 수 있습니다.
- iOS/Android 간 체감 배치 차이를 줄여 시각적 일관성을 높입니다.
- `endFloat`가 이미 반영하는 하단 안전영역/기본 마진을 중복 적용하지 않아
  iOS에서 과도하게 위로 뜨는 현상을 제거합니다.
- 기존 레이아웃 방식(`Padding` 기반)은 유지하므로 터치 히트 안정성은 보존됩니다.

## Scope / Impact
- Affected files:
  - `lib/features/feed/presentation/widgets/community_fab_layout.dart`
  - `lib/features/feed/presentation/pages/feed_page.dart`
  - `lib/features/feed/presentation/pages/board_page.dart`
  - `test/features/feed/presentation/widgets/community_fab_layout_test.dart`

## Verification
- `flutter analyze lib/features/feed/presentation/widgets/community_fab_layout.dart lib/features/feed/presentation/pages/feed_page.dart lib/features/feed/presentation/pages/board_page.dart test/features/feed/presentation/widgets/community_fab_layout_test.dart`
- `flutter test test/features/feed/presentation/widgets/community_fab_layout_test.dart`

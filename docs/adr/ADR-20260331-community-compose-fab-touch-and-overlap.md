# ADR-20260331: Community Compose FAB Touch and Overlap

## Status
- Accepted (2026-03-31)

## Context
- 커뮤니티 탭에서 작성 FAB 관련 플랫폼별 이슈가 발생했습니다.
  - iOS: 작성 FAB가 시각적으로 보이지만 탭 반응이 누락되는 사례 발생
  - Android: 작성 FAB가 하단 네비게이션 바에 일부 가려짐
- 기존 구현은 `Transform.translate`로 FAB를 화면 위로 강제 이동하는 방식이었고,
  외부 하단바(`MainScaffold`)와의 레이어/히트 영역 안정성이 낮았습니다.

## Problem (Before)
- FAB 위치 보정이 플랫폼별 고정값(`72`, `120`)에 의존했습니다.
- `Transform.translate`는 시각 위치 이동 중심이라
  하단바 구조 변경 시 터치/겹침 회귀 가능성이 높았습니다.

## Options Considered
- Option A: 기존 `Transform.translate` 유지 + 고정값만 증가
  - 장점: 변경량이 작음
  - 단점: 구조적 해결이 아니며 향후 하단바 디자인 변경 때 재발 가능
- Option B: FAB를 외부 `MainScaffold`로 승격
  - 장점: 하단바와 동일 레이어에서 완전 제어 가능
  - 단점: 라우트/탭 별 FAB 상태 전달 복잡도 증가
- Option C: 페이지 내부 FAB는 유지하되 `bottom padding` 계산식으로 배치 통일
  - 장점: 구현 비용 대비 안정성 높음, 기존 구조/상태 흐름 유지 가능
  - 단점: 하단바 reserved height 상수 관리 필요

## Decision
- Option C 채택.
- 공통 유틸 `resolveCommunityFabBottomPadding`을 도입해
  `safeAreaBottom + navReservedHeight + platformClearance` 계산으로
  FAB 배치를 통일했습니다.
- `BoardPage`의 FAB 배치를 `Transform.translate`에서 `Padding` 기반으로 전환했습니다.
- `FeedPage` 커뮤니티 FAB에도 동일 계산식을 적용했습니다.

## Rationale
- iOS 탭 무반응은 `Transform.translate` 기반 배치에서 발생 가능한
  히트테스트 불안정성과 연관될 가능성이 높았고,
  `Padding` 기반 배치는 레이아웃/터치 일치성이 더 높습니다.
- Android 가림 문제는 하단바 reserved 영역을 계산식으로 반영해
  단일 경로에서 해결하는 편이 유지보수에 유리합니다.

## Scope / Impact
- Affected files:
  - `lib/features/feed/presentation/widgets/community_fab_layout.dart` (new)
  - `lib/features/feed/presentation/pages/board_page.dart`
  - `lib/features/feed/presentation/pages/feed_page.dart`
  - `test/features/feed/presentation/widgets/community_fab_layout_test.dart` (new)
- 기존 라우팅/상태 관리 구조는 변경하지 않았습니다.

## Verification
- `flutter test test/features/feed/presentation/widgets/community_fab_layout_test.dart`
- `flutter analyze lib/features/feed/presentation/pages/board_page.dart lib/features/feed/presentation/pages/feed_page.dart lib/features/feed/presentation/widgets/community_fab_layout.dart test/features/feed/presentation/widgets/community_fab_layout_test.dart`


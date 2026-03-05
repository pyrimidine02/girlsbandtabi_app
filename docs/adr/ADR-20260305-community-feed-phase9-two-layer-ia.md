# ADR-20260305-community-feed-phase9-two-layer-ia

## Status
Accepted (2026-03-05)

## Context
- `deep-research-report (2).md`에서 게시판 피드 IA를 `추천/팔로잉/프로젝트` 1차 필터 + 상황별 2차 필터 구조로 정리했습니다.
- 기존 커뮤니티 탭 상단은 요소 수가 많고(헤더/검색/모드/힌트/구독 행), 사용자가 “지금 어떤 컨텍스트의 피드를 보는지”를 즉시 파악하기 어려웠습니다.
- 상단 크롬을 줄이면서도 검색·필터·발견(Discover) 맥락을 유지하는 재구성이 필요했습니다.

## Decision
### 1) 상단 커맨드바 재구성
- `lib/features/feed/presentation/pages/board_page.dart`
  - `_FeedCommandBar` 추가.
  - 섹션 라벨(`피드/발견`), 검색 진입/초기화, 결과 카운트, 상태 문구를 하나의 컴팩트 블록으로 통합.
  - 검색 상태일 때 query 중심으로 문맥 전환.

### 2) 2단계 필터 IA 적용
- 1차 필터: `_FeedModeSegmentedControl`을 재사용 가능한 형태로 확장.
  - `modes`, `labelBuilder`를 받아 `추천/팔로잉/프로젝트` 구성을 지원.
- 2차 필터: `_FeedSecondaryModeChips` 추가.
  - 1차 선택에 따라 `전체/최신/급상승` 또는 `구독 프로젝트`만 노출.

### 3) 발견/구독 컨텍스트 가시성 강화
- 발견 탭 전용 `_DiscoverInfoBanner` 추가.
- 팔로잉 모드 구독 목록 행을 `_SubscriptionProjectPill`로 통일.
- 인기 레일(`_PopularPostsCarousel`)을 피드/발견 양쪽에서 재사용할 수 있게 `headerText`를 파라미터화.

## Consequences
### Positive
- 상단 정보구조가 간결해져 첫 진입 시 컨텍스트 인지가 빨라집니다.
- 모드 전환이 “1차(관점) → 2차(정렬)” 흐름으로 정리되어 탐색 비용이 줄어듭니다.
- 검색/발견/팔로잉 상태가 각각 전용 표현을 갖게 되어 상태 혼동이 줄어듭니다.

### Trade-offs
- 모드 매핑(예: `프로젝트` -> `latest`)은 현재 백엔드 모드 모델에 맞춘 UI 해석이며, 전용 project-scope API가 추가되면 재조정이 필요합니다.
- 상단 컴포넌트 수가 늘어 유지보수 시 스타일 토큰 통합 관리가 필요합니다.

## Validation
- `flutter analyze lib/features/feed/presentation/pages/board_page.dart` 통과
- `flutter test test/features/feed --reporter compact` 통과

## Follow-up
- `/board`, `/board/discover`, `/board/travel-reviews-tab` 간 라우트 복귀 시 모드 유지 정책을 QA로 확정합니다.
- 백엔드 project-scope 전용 피드 모드가 추가되면 1차 필터의 `프로젝트` 매핑을 실제 전용 모드로 전환합니다.

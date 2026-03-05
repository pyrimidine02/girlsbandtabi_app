# ADR-20260305-community-feed-phase8-mode-reactions-comments-density

## Status
Accepted (2026-03-05)

## Context
- 커뮤니티 UI 스펙(`spec.md`, `design.md`) 기준으로 피드 모드 제어와 댓글 카드 가독성이 아직 칩 중심/간격 과다 상태였습니다.
- 기존 게시판 모드 전환은 가로 칩 나열 방식이라 선택 상태 대비가 약했고, 추천/최신/구독 같은 모드 맥락을 즉시 이해하기 어려웠습니다.
- 포스트 상세 댓글 영역에서는 닉네임 행 높이 대비 본문 시작 간격이 넓게 보이고, `...` 메뉴가 시각적으로 오른쪽 정렬이 약하게 보이는 이슈가 있었습니다.

## Decision
### 1) 커뮤니티 피드 모드 제어를 segmented control로 전환
- `lib/features/feed/presentation/pages/board_page.dart`
  - `_FeedModeSegmentedControl` 신설.
  - 모드 순서/라벨을 `추천/최신/구독/인기`로 고정 노출하고, 선택 상태를 배경+보더+폰트 굵기로 강화.
  - 뷰 폭이 좁을 때 아이콘을 자동 숨겨 텍스트 가독성 우선.

### 2) 모드 컨텍스트 힌트 확장
- 기존 추천 전용 힌트를 모드별 안내로 확장 (`_RecommendationModeHint(mode: ...)`).
- 추천/최신/구독/인기 각각에 대해 한 줄 가이드 문구와 아이콘을 제공.

### 3) 포스트 카드 반응 영역 정보성 강화
- 카드 헤더에 참여도 배지 표준화:
  - 기존 `인기` 배지 유지
  - 댓글량 기반 `토론중` 배지 추가
- 액션 바에 공유(링크 복사) 액션을 추가하고, 버튼별 semantics label/toggled 상태를 명시.

### 4) 댓글 카드 밀도/정렬 개선
- `lib/features/feed/presentation/pages/post_detail_page.dart`
  - 루트 댓글/대댓글 작성자 행을 `Stack + Positioned` 구조로 변경해 메뉴 버튼의 오른쪽 정렬 인지를 강화.
  - 닉네임 행과 본문 사이 간격을 축소하고, 본문 line-height를 소폭 낮춰 카드 밀도 개선.
  - 타임라인 반응 버튼 최소 높이를 44로 상향해 터치 타겟 일관성 확보.

## Consequences
### Positive
- 피드 모드 전환의 제어감/선택 상태 식별성이 개선됩니다.
- 댓글 카드에서 본문 시작 지점이 더 빨라져 읽기 피로가 줄어듭니다.
- 액션 버튼 의미(좋아요/북마크 토글, 공유)가 semantics에 반영되어 접근성이 향상됩니다.

### Trade-offs
- 모드 힌트가 모든 모드에 표시되므로 화면 밀도가 증가할 수 있습니다.
- 공유 동작은 현재 클립보드 복사 기반이라 OS 공유 시트 연동보다 기능 범위가 제한됩니다.

## Validation
- `flutter analyze lib/features/feed/presentation/pages/board_page.dart lib/features/feed/presentation/pages/post_detail_page.dart` 통과
- `flutter test test/features/feed` 통과

## Follow-up
- 디자인 QA에서 모드 힌트 노출 범위(모든 모드 vs 추천/구독 한정)를 확정합니다.
- 공유 액션을 OS 공유 시트(`share_plus` 등)로 확장할지 제품 결정 후 반영합니다.

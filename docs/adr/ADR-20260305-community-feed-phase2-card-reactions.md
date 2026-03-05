# ADR-20260305-community-feed-phase2-card-reactions

## Status
Accepted (2026-03-05)

## Context
- 커뮤니티 개선 2차 요구사항으로 “피드 카드에서 상세 진입 없이 즉시 좋아요/북마크 반응”이 필요함.
- 기존 `BoardPage` 카드 액션은 댓글/좋아요/공유 모두 상세 페이지 이동 중심이라 피드 소비-참여 루프가 약했음.
- 이미 상세 페이지에서는 `postLikeControllerProvider`, `postBookmarkControllerProvider` 기반 토글이 동작 중이라 재사용 가능한 상태 관리가 존재함.

## Decision
### 1) 카드 액션에 반응 토글 직접 연결
- `board_page`의 카드 액션 바에서:
  - 좋아요 버튼 → `postLikeControllerProvider(postId).notifier.toggleLike()`
  - 북마크 버튼 → `postBookmarkControllerProvider(postId).notifier.toggleBookmark()`
- 비로그인 사용자는 즉시 안내 스낵바를 노출.

### 2) 아이콘/상태 시각화 강화
- 액션 버튼에 active icon을 도입:
  - 좋아요: `favorite_border` ↔ `favorite`
  - 북마크: `bookmark_border` ↔ `bookmark`
- viewer-state 로딩 중에는 버튼 비활성 + opacity 감소 처리.

### 3) 액션 정보 접근성 보강
- 카드 action-bar `Semantics` 라벨에 북마크 상태를 포함하여
  - “좋아요/댓글 수 + 북마크 설정 여부”
  - 를 스크린리더가 함께 읽도록 확장.

## Consequences
### Positive
- 피드 카드에서 반응 완료까지 클릭 수가 줄어 참여 속도가 빨라짐.
- 상세/피드 간 반응 동작 일관성이 생김(동일 controller 경로 재사용).

### Trade-offs
- 현재 구조는 인증 사용자 기준 카드별 반응 상태 조회가 발생하므로, 목록 규모가 커질수록 reaction API 호출량이 늘어날 수 있음.
- 500 unlike 이슈는 controller 레벨 fallback(기존 적용)에 의존하며, 근본 원인은 서버 수정이 필요함.

## Validation
- `flutter analyze lib/features/feed/presentation/pages/board_page.dart` 통과

## Follow-up
- `/posts/reactions:batch` 형태의 viewer-state 배치 endpoint를 도입해 카드별 N+1 호출을 제거.
- 카드 레벨 낙관적 업데이트 캐시를 feed state에 합쳐 상세/피드 간 추가 재조회 빈도를 줄임.

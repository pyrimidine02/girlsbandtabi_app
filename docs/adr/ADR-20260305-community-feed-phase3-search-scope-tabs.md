# ADR-20260305-community-feed-phase3-search-scope-tabs

## Status
Accepted (2026-03-05)

## Context
- 커뮤니티 개선 3차로 검색 UX를 “의도 기반 필터” 형태로 확장해야 함.
- 기존 게시판 검색은 단일 query 입력만 제공하고 범위 제어(`제목/작성자/내용/미디어`)가 없어 탐색 정확도 체감이 낮았음.
- 현재 API 계약은 단일 검색 endpoint 중심이라 scope별 서버 랭킹 결과를 바로 받기 어렵다.

## Decision
### 1) 검색 스코프 상태 도입
- `CommunitySearchScope`(`all/title/author/content/media`)를 `CommunityFeedViewState`에 추가.
- 검색 시 원본 결과(`searchSourcePosts`)를 보관하고, scope 변경 시 로컬 필터링으로 즉시 재렌더링.

### 2) 검색 활성 시 전용 필터 탭 노출
- `BoardPage` 검색창 아래에 scope chip row를 노출:
  - `전체/제목/작성자/내용/미디어`
- 검색 상태 안내 라인(`query + scope + 결과 개수`)을 추가.

### 3) 검색 집중 모드 정리
- 검색 중에는 추천 힌트/팔로우 구독행/인기 캐러셀 같은 보조 블록을 숨겨
  - 검색 결과 리스트 집중도를 유지.
- 빈 상태 메시지도 scope-aware 문구로 변경.

## Consequences
### Positive
- 사용자 의도(어디서 찾을지)를 UI에서 바로 제어할 수 있어 검색 신뢰도가 개선됨.
- scope 전환 시 네트워크 왕복 없이 즉시 반응하므로 체감 속도가 빠름.

### Trade-offs
- 현재 scope 필터는 서버가 아닌 클라이언트 후처리라, 결과 랭킹 품질은 서버 검색 품질에 종속됨.
- `media` scope는 현재 계약상(썸네일/이미지 필드) 추론 기반이라 완전한 미디어 인덱스와는 차이가 있을 수 있음.

## Validation
- `flutter analyze lib/features/feed/application/board_controller.dart lib/features/feed/presentation/pages/board_page.dart` 통과
- `flutter test test/features/feed` 통과

## Follow-up
- 서버 검색 계약에 scope 파라미터(또는 scope별 endpoint)를 추가해 클라이언트 후처리를 대체.
- 검색 결과 페이지네이션이 필요해지면 scope별 cursor/state를 분리해 상태 복원 품질을 높인다.

# ADR-20260306-community-recommended-feed-scope

## Status
Accepted (2026-03-06)

## Context
- 사용자 요구사항: 추천 탭에서 프로젝트를 고정하지 않고 전체 프로젝트 글이 섞여 보여야 함.
- 기존 구현에서 `CommunityFeedMode.recommended`는 `getPostsByCursor(projectCode)`를 호출해 프로젝트 단위 피드만 조회함.
- 코드/엔드포인트 카탈로그 기준 통합 커뮤니티 커서 피드 경로(`/api/v1/community/feed/cursor`)가 이미 존재함.

## Decision
- `CommunityFeedMode.recommended` 데이터 소스를 프로젝트 커서 피드에서 통합 커서 피드로 변경한다.
  - 변경 대상: 초기 로드(`reload`), 백그라운드 새로고침(`refreshInBackground`), 추가 로드(`loadMore`).
- 프로젝트 선택 필수 조건을 모드 기반으로 변경한다.
  - `추천/팔로잉`: 프로젝트 선택 없이 로드 허용.
  - `최신/인기/검색`: 기존처럼 프로젝트 선택 필요.

## Consequences
### Positive
- 추천 탭이 프로젝트 경계를 넘는 통합 피드로 동작해 사용자 기대와 일치한다.
- 피드 진입 시 프로젝트 선택 상태에 덜 종속되어 초기 빈 화면/오류 가능성이 줄어든다.

### Trade-offs
- 현재 `추천`과 `팔로잉`이 동일 통합 피드 계약을 공유할 수 있어 체감 차이가 제한될 수 있다.
- 추천 근거(예: ranking reason, relevance signals)는 서버 계약이 추가되어야 노출 가능하다.

## Validation
- `dart format lib/features/feed/application/board_controller.dart`
- `flutter analyze lib/features/feed/application/board_controller.dart`

## Follow-up
- 백엔드에 추천 전용 컨텍스트/랭킹 계약이 추가되면 `recommended`를 전용 endpoint(또는 query contract)로 분리.
- `following` 전용 필터 계약이 분리되면 모드별 데이터 소스를 재분리하고 UX 카피를 동기화.

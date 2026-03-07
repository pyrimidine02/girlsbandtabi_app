# ADR-20260307-community-recommended-feed-endpoint-switch

## Status
Accepted (2026-03-07)

## Context
- 게시판 `추천` 모드가 커서 엔드포인트(`/api/v1/community/feed/cursor`)를 사용하면
  서버의 추천 정책이 반영되지 않거나 일반 통합 피드와 결과가 동일해질 수 있다.
- 사용자 요구사항은 `추천` 탭을 `recommended` 엔드포인트 기반으로 고정하는 것이다.

## Decision
- `CommunityFeedController`의 `CommunityFeedMode.recommended` 경로를
  `getCommunityRecommendedFeed(page, size)`로 전환한다.
- 추천 모드는 page 기반 상태를 사용한다.
  - `page`: 0부터 증가
  - `hasMore`: `items.length >= size`
  - `nextCursor`: 사용하지 않음 (`null`)

## Consequences
- 추천 탭 데이터 소스가 서버의 추천 전용 API와 일치한다.
- 추천 모드에서 cursor 상태 의존이 제거되어 페이징 로직이 단순해진다.
- `following/latest`의 cursor 기반 페이징과 추천의 page 기반 페이징이 분리된다.

## Verification
- `flutter analyze lib/features/feed/application/board_controller.dart`

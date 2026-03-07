# ADR-20260307-community-recommended-feed-cursor-fallback

## Status
Accepted (2026-03-07)

## Context
- Mobile board `추천` 탭이 `GET /api/v1/community/feed/recommended`를 호출하고 있었고,
  현재 백엔드 환경에서는 해당 경로가 `404 NOT_FOUND`를 반환했습니다.
- 기존 클라이언트는 `404`를 일반 실패로 처리해 에러 상태를 표시하고,
  백그라운드 리프레시 주기마다 동일 404 로그를 반복 발생시켰습니다.

## Decision
1. `추천` 탭의 소스를 cursor feed로 전환
   - `GET /api/v1/community/feed/recommended` 대신
     `GET /api/v1/community/feed/cursor`를 사용합니다.
2. `추천` 탭의 페이지네이션 모델을 cursor 방식으로 통일
   - `reload`/`loadMore`/`refreshInBackground` 모두
     `hasNext`, `nextCursor`를 기준으로 동작합니다.

## Consequences
### Positive
- 추천 탭에서 `404` 때문에 "문제 발생" 상태로 보이는 UX를 제거합니다.
- 동일 404 에러 로그 반복을 줄이고, following 탭과 페이징 처리 모델이 일치합니다.

### Trade-offs
- 추천 전용 서버 랭킹 경로가 향후 재도입될 경우, 클라이언트 재연동이 필요합니다.

## Validation
- `flutter analyze lib/features/feed/application/board_controller.dart`

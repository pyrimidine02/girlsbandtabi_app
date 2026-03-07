# ADR-20260307-community-mixed-project-reaction-context

## Status
Accepted (2026-03-07)

## Context
- 커뮤니티 `추천/팔로잉` 피드는 프로젝트가 섞인 게시글을 반환할 수 있다.
- 기존 클라이언트는 게시글 반응(좋아요/북마크) 조회/토글 시
  카드의 실제 소속 프로젝트와 무관하게 `selectedProjectKey`를 경로에 사용했다.
- 그 결과, 타 프로젝트 게시글 카드에서 아래 오류가 반복 발생했다.
  - `400 INVALID_REQUEST`
  - cause: `Post does not belong to project`

## Decision
- 게시글 반응 API 호출 컨텍스트를 `PostReactionTarget`으로 명시한다.
  - `postId`
  - `projectCodeOverride` (게시글 소속 프로젝트 식별자)
- `Board` 카드와 `PostDetail`에서 반응 컨트롤러를 생성할 때
  게시글의 `projectId`를 `projectCodeOverride`로 전달한다.
- `projectCodeOverride`가 없을 때만 기존처럼 `selectedProjectKey`를 사용한다.

## Consequences
- 혼합 프로젝트 피드 카드에서도 반응 API 경로가 게시글 소속 프로젝트와 일치한다.
- `Post does not belong to project` 400 노이즈를 제거한다.
- 호출 수/리빌드 범위는 기존과 동일해 성능 저하를 유발하지 않는다.

## Verification
- `flutter analyze lib/features/feed/application/reaction_controller.dart lib/features/feed/presentation/pages/board_page.dart lib/features/feed/presentation/pages/post_detail_page.dart`

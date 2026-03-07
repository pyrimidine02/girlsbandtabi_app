# ADR-20260307-post-compose-immersive-editor-mode

## Status
Accepted (2026-03-07)

## Context
- 게시글 작성/수정 화면에서 하단 네비게이션이 보이면 입력 집중도가 떨어지고,
  키보드 중심 작성 플로우와 충돌이 발생했습니다.
- 최신 요청으로 작성 화면은 단색 중심의 단순한 입력 캔버스와
  더 큰 제목 입력 강조가 필요해졌습니다.

## Decision
1. 작성/수정 라우트에서 shell 하단 네비게이션 숨김:
   - `/board/posts/new`
   - `/board/posts/:postId/edit`
2. 작성/수정 진입 시 제목 입력 autofocus 적용으로 키보드 즉시 표시.
3. 제목 입력 시각 강조:
   - `titleMedium` -> `titleLarge` + `w700`.
4. 카피/시각 정리:
   - 제목 힌트를 `제목을 입력해주세요`로 변경.
   - 제목 아래 커뮤니티 기본 준수 안내 문구 추가.
   - 프로젝트 선택의 회색 배경 박스를 제거해 단색 레이아웃 유지.

## Consequences
### Positive
- 작성 화면이 더 몰입형 편집기처럼 동작하고 입력 시작이 빨라집니다.
- 불필요한 하단 크롬이 줄어들어 키보드 영역과의 시각 충돌이 감소합니다.
- 커뮤니티 가이드 문구가 입력 시작점 근처에 배치되어 정책 인지가 쉬워집니다.

### Trade-offs
- 하단 네비게이션 즉시 접근은 작성/수정 화면에서 불가능해집니다.
- autofocus로 인해 페이지 진입 즉시 키보드가 올라와, 콘텐츠 미리보기 영역이 줄어듭니다.

## Validation
- `flutter analyze lib/features/feed/presentation/pages/post_create_page.dart lib/features/feed/presentation/pages/post_edit_page.dart lib/shared/main_scaffold.dart`

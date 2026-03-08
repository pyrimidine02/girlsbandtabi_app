# ADR-20260308-community-comment-reply-consistency-and-cache-invalidation

## Status
Accepted

## Date
2026-03-08

## Context
- 댓글/답글 생성 시 선택된 프로젝트와 실제 게시글의 프로젝트가 다르면
  프로젝트 스코프 API가 실패할 수 있다.
- 댓글/답글 생성/삭제 후 캐시 무효화가 `post_comments:p0:s20` 수준으로만
  제한되어 게시글 목록/프로필 활동 탭의 stale 데이터가 남았다.
- 프로필 탭에서 게시글 상세 진입 후 복귀 시 활동 목록이 즉시 갱신되지 않아
  "삭제했는데 그대로 보임" 체감이 발생했다.

## Decision
1. 댓글/게시글 상세 컨트롤러에 프로젝트 코드 해석/재시도 로직을 추가한다.
   - `project code`/`project id(UUID)`/현재 선택값/프로젝트 목록을 후보로 구성
   - 404 계열 실패 시 다른 후보 프로젝트 코드로 재시도
2. 댓글 생성/삭제 성공 직후 서버 강제 재조회(`forceRefresh`)를 수행한다.
   - 상세 화면의 댓글 목록/카운트가 서버 상태와 동기화되도록 보정
3. 캐시 매니저에 prefix 삭제 기능(`removeByPrefix`)을 추가한다.
4. 게시글/댓글 mutation 시 무효화 범위를 확장한다.
   - post detail/comments
   - post list + trending list
   - author posts/comments activity cache
5. 유저 프로필 탭에서 게시글 상세 진입 후 복귀하면 activity를 강제 새로고침한다.
6. 부모 댓글 삭제로 orphan이 된 답글은 post detail에서 삭제 플레이스홀더
   (`삭제된 댓글입니다`) 아래에 유지 렌더링한다.
   - 루트 승격 없이 스레드 위치를 보존하고, 답글 전체가 숨겨지는 현상을 방지한다.
   - 남은 답글이 없으면 플레이스홀더 흔적을 남기지 않는다.
7. 답글 본문 표시 시 `@부모작성자` 멘션은
   루트 댓글 직접 답글/답글의 답글 모두에서 부모 작성자 해석이 가능하면 표시한다.
8. 댓글 정책 백엔드 변경(2026-03-08)에 맞춰 프런트 렌더/행동을 정렬한다.
   - 최대 답글 깊이는 `10`으로 제한하고 UI에서도 작성 타겟을 제한한다.
   - 삭제 플레이스홀더 토큰 `"[Deleted comment]"`을 클라이언트가 인지해
     한국어 삭제 UI로 렌더링한다(legacy 토큰도 하위호환).
   - thread 조회 모달은 `maxDepth=10`으로 요청한다.

## Alternatives Considered
1. 기존 selected project만 사용 유지
   - 구현은 단순하지만 프로젝트 불일치 케이스에서 댓글/답글 실패가 반복된다.
2. mutation 직후 로컬 상태만 낙관적 반영
   - 빠르지만 스레드 삭제/카운트/정렬 불일치가 누적될 수 있다.
3. 캐시 전체 clearAll 수행
   - 일관성은 높지만 네트워크/UX 비용이 과도하다.

## Consequences
### Positive
- 프로젝트 불일치 케이스에서 댓글/답글 실패율을 낮춘다.
- 댓글 수/프로필 활동 탭 stale 현상을 줄인다.
- 캐시 무효화를 필요한 범위(prefix)로만 수행해 일관성과 비용을 균형화한다.
- 부모 댓글 삭제 후에도 남은 답글이 스레드 맥락(삭제 플레이스홀더)과 함께
  UI에서 사라지지 않는다.
- 답글이 없는 삭제 스레드는 화면에 흔적을 남기지 않는다.
- 답글 멘션 가시성이 일관되어 대화 맥락 파악이 쉬워진다.
- 백엔드 정책 변경 이후에도 depth/placeholder 동작이 UI와 일치한다.

### Trade-offs
- 프로젝트 후보 재시도로 인해 일부 요청에서 추가 왕복이 발생할 수 있다.
- mutation 이후 강제 재조회로 순간 네트워크 사용량이 증가한다.

## Scope
- `lib/features/feed/application/post_controller.dart`
- `lib/features/feed/data/repositories/feed_repository_impl.dart`
- `lib/core/cache/cache_manager.dart`
- `lib/features/feed/presentation/pages/user_profile_page.dart`
- `lib/features/feed/presentation/pages/post_detail_page.dart`
- `test/core/cache/cache_manager_test.dart`

## Validation
- `flutter analyze lib/core/cache/cache_manager.dart lib/features/feed/application/post_controller.dart lib/features/feed/data/repositories/feed_repository_impl.dart lib/features/feed/presentation/pages/user_profile_page.dart test/core/cache/cache_manager_test.dart`
- `flutter analyze lib/features/feed/presentation/pages/post_detail_page.dart`
- `flutter test test/core/cache/cache_manager_test.dart`

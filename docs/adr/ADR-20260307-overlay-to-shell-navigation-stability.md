# ADR-20260307-overlay-to-shell-navigation-stability

## Status
Accepted (2026-03-07)

## Context
- 설정의 퀵액션(`/favorites`, `/visits`, `/visit-stats`)에서 카드 상세 이동 시 일부 경로에서 빈 화면처럼 보이는 보고가 있었습니다.
- 기존 구현은 오버레이 스택(`settings/favorites/visits/stats`)에서 쉘 내부 상세(`place/live/news/post`)로 `pushNamed`를 사용해 추가 네비게이터 스택을 형성할 수 있었습니다.
- 이 구조는 상태 보존형 쉘(`StatefulShellRoute`)과 결합될 때 화면 렌더링 불안정(빈 화면/중첩 스택)을 유발할 가능성이 있습니다.

## Decision
1. 오버레이 -> 쉘 상세 이동 정책 고정
   - 현재 경로가 오버레이 컨텍스트(`/settings`, `/favorites`, `/visits`, `/visit-stats`, `/notifications`, `/search`)인 경우,
     쉘 상세 라우트 이동은 `pushNamed` 대신 `go(...)`를 사용합니다.
2. 동일 타겟 중복 push 방지 강화
   - 컨텍스트/라우터 경로가 타겟 상세와 동일한데 현재 스택에서 `pop` 가능한 경우,
     `pushNamed`를 금지하고 `go(...)` 또는 no-op으로 처리합니다.
   - 목적: 동일 상세 경로를 다시 push하면서 발생하는 duplicate page key/GlobalKey 충돌을 차단합니다.
3. 오버레이 back-stack 유지용 전용 상세 라우트 추가
   - 오버레이 컨텍스트에서 상세 진입 시 아래 라우트를 `push`로 사용합니다.
     - `/overlay/places/:placeId`
     - `/overlay/live/:eventId`
     - `/overlay/info/news/:newsId`
     - `/overlay/board/posts/:postId`
   - 목적: 크래시를 피하면서도 상세 뒤로가기 시 원래 오버레이 화면(`/favorites`, `/visits`, `/visit-stats` 등)으로 복귀하게 유지합니다.
4. 적용 범위
   - `goToPlaceDetail`, `goToLiveDetail`, `goToNewsDetail`, `goToPostDetail`에 공통 정책 반영.
   - 즐겨찾기 카드 탭은 문자열 경로 `push` 대신 위 라우터 헬퍼를 사용하도록 통일.

## Consequences
### Positive
- 오버레이에서 상세로 이동 시 빈 화면/중첩 쉘 스택 문제가 재현될 가능성을 줄입니다.
- `/settings -> /favorites -> 같은 /places/:id 재진입` 케이스에서
  `!keyReservation.contains(key)`/`GlobalKey used multiple times` 예외를 예방합니다.
- 상세 화면에서 뒤로가기 시 원래 오버레이 리스트(즐겨찾기/방문기록/통계)로 자연스럽게 복귀합니다.
- 상세 이동 방식이 공통 라우터 헬퍼로 수렴되어 유지보수가 쉬워집니다.

### Trade-offs
- 오버레이에서 쉘 상세로 이동 시 일부 케이스에서 back stack이 `push` 기반보다 짧아질 수 있습니다(`go` 전환).
- UX 기대치(back 동작)는 추가 QA가 필요합니다.

## Validation
- `flutter analyze lib/core/router/app_router.dart lib/features/favorites/presentation/pages/favorites_page.dart`
- `flutter test test/features/favorites test/features/visits`

## Follow-up
- 실제 기기(iOS/Android)에서 `/settings -> 즐겨찾기/방문기록/통계 -> 카드 상세` 플로우의 back stack UX를 확인하고 필요 시 `from` 쿼리 기반 복귀 정책을 추가합니다.

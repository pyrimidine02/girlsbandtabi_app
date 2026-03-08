# ADR-20260308-shell-bottom-nav-fullscreen-detail-policy

## Status
Accepted

## Date
2026-03-08

## Context
- 메인 쉘(StatefulNavigationShell) 하위 상세 화면에서 하단 네비게이션이
  노출되어 콘텐츠 몰입도와 화면 사용성이 떨어졌다.
- 사용자 요구사항은 “각종 상세 페이지 진입 시 하단 네비바 비노출(전체화면)”이다.

## Decision
1. 하단 네비게이션은 탭 루트 경로에서만 노출한다.
   - `/home`, `/places`, `/live`, `/board`, `/board/discover`,
     `/board/travel-reviews-tab`, `/info`
2. 위 경로 외 쉘 하위 모든 서브/상세 경로는 하단 네비게이션을 숨긴다.
3. 게시판 전용 서브 하단바(`_BoardSubBottomNav`)도 게시판 루트 경로에서만 노출한다.

## Alternatives Considered
1. 상세 페이지별 예외 목록 관리
   - 라우트 추가 시 누락 위험이 높고 유지보수 비용이 증가한다.
2. 기존처럼 대부분 경로에서 하단바 유지
   - 상세 화면 몰입도/가독성 문제를 해결하지 못한다.

## Consequences
### Positive
- 상세 화면에서 실제 콘텐츠 영역이 확대되어 UX가 개선된다.
- 신규 상세 경로가 추가되어도 기본적으로 전체화면 정책이 자동 적용된다.

### Trade-offs
- 상세 화면에서 탭 전환까지 한 단계(뒤로가기)가 추가된다.

## Scope
- `lib/shared/main_scaffold.dart`

## Validation
- `flutter analyze lib/shared/main_scaffold.dart`

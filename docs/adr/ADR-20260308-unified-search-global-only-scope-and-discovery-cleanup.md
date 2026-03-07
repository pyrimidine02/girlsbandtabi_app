# ADR-20260308-unified-search-global-only-scope-and-discovery-cleanup

## Status
Accepted

## Date
2026-03-08

## Context
- 통합검색 정책이 "프로젝트 범위 선택"에서 "항상 전체 범위 검색"으로 변경되었다.
- Search 화면의 인기 검색 섹션 우측 퍼센트 표시는 서버 집계값이 아닌
  클라이언트 생성값이라 오해 가능성이 있었다.

## Decision
1. Search 화면에서 프로젝트 범위 토글 UI를 제거한다.
2. Search 요청은 항상 전역 통합검색으로 호출한다.
   - 클라이언트에서 `projectId`, `unitIds`를 검색 요청에 주입하지 않는다.
3. 인기 검색 순위 행 우측 퍼센트 표시는 제거한다.

## Alternatives Considered
1. 범위 토글 UI를 유지하되 기본값만 전체로 변경
   - 정책 위반 가능성이 남아 동작 일관성이 떨어진다.
2. 퍼센트 값을 서버 지표 연동 전까지 유지
   - 실제 지표처럼 보이는 표현으로 사용자 오해를 유발할 수 있다.

## Consequences
### Positive
- 검색 UX가 단순해지고 정책(전역 통합검색)과 일치한다.
- 검색 결과 범위가 모든 사용자에게 동일해져 테스트/운영 해석이 쉬워진다.
- 검색 발견 섹션에서 임의 수치 노출이 사라져 신뢰성이 높아진다.

### Trade-offs
- 프로젝트 한정 검색은 검색 페이지에서 직접 선택할 수 없다.
- 인기 검색/카테고리 섹션은 서버 집계 API 연동 전까지 클라이언트 보조 데이터에 의존한다.

## Scope
- `lib/features/search/application/search_controller.dart`
- `lib/features/search/presentation/pages/search_page.dart`

## Validation
- `flutter analyze lib/features/search/presentation/pages/search_page.dart lib/features/search/application/search_controller.dart`

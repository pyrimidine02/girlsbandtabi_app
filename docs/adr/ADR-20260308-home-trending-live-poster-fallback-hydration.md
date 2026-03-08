# ADR-20260308-home-trending-live-poster-fallback-hydration

## Status
Accepted

## Date
2026-03-08

## Context
- 홈 요약 API의 트렌딩 라이브 항목에서 포스터 URL이 간헐적으로 누락되는
  케이스가 있었다.
- 동일 이벤트는 라이브 상세/목록 API에서 포스터를 정상 제공해, 홈 카드만
  이미지가 비는 시각적 불일치가 발생했다.

## Decision
1. 홈 요약 조회 후, 트렌딩 라이브 중 포스터 누락 항목만 선별한다.
2. 누락 항목에 한해 라이브 상세 API에서 포스터 URL을 보강 조회한다.
3. 보강 성공한 URL을 홈 요약 DTO에 병합한 뒤 도메인/UI로 전달한다.

## Alternatives Considered
1. 홈 DTO 파서 키만 추가
   - 완전 누락(payload 자체에 이미지 없음) 케이스는 해결하지 못한다.
2. 홈 화면에서 라이브 목록 API로 전체 대체
   - 홈 요약 API 책임을 침범하고 호출량 증가 위험이 크다.

## Consequences
### Positive
- 홈 트렌딩 라이브 카드가 라이브 페이지와 동일 포스터를 더 안정적으로 표시한다.
- 누락 항목에 대해서만 보강 호출해 불필요한 추가 호출을 최소화한다.

### Trade-offs
- 포스터 누락 항목 수만큼 보강 네트워크 호출이 추가될 수 있다.

## Scope
- `lib/features/home/data/datasources/home_remote_data_source.dart`
- `lib/features/home/data/repositories/home_repository_impl.dart`

## Validation
- `flutter analyze lib/features/home/data/datasources/home_remote_data_source.dart lib/features/home/data/repositories/home_repository_impl.dart lib/features/home/presentation/pages/home_page.dart`
- `flutter test test/features/home/data/home_summary_dto_test.dart`

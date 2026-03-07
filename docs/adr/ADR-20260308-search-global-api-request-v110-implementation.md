# ADR-20260308-search-global-api-request-v110-implementation

## Status
Accepted

## Date
2026-03-08

## Context
- 프런트 요청서 `search-global-api-request-20260308.md` 기준으로
  통합검색 전역화 계약(v1.1.0) 반영이 필요했다.
- 기존 구현은 검색 자체는 전역 방향이었지만,
  discovery API 미연동 및 검색 요청 취소(CancelToken) 미적용 상태였다.

## Decision
1. `/api/v1/search` 호출은 `q/types/page/size`만 사용한다.
   - `projectId`, `unitIds`는 클라이언트에서 전송하지 않는다.
2. 검색 홈 discovery를 서버 API와 연동한다.
   - `GET /api/v1/search/discovery/popular`
   - `GET /api/v1/search/discovery/categories`
3. 검색 입력 시 이전 in-flight 요청을 취소한다.
   - Dio `CancelToken`을 `ApiClient.get`까지 연결한다.
   - 최신 요청 ID 기준으로 stale/cancel 응답은 UI 반영에서 제외한다.
4. Discovery 실패는 검색 실패로 전파하지 않는다.
   - popular 실패: 로컬 fallback 키워드로 섹션 유지
   - categories 실패: 섹션 숨김 + retry 진입점 제공
5. `updatedAt` 표시는 로컬 시간 기준 `오늘 HH:mm 기준`으로 표시하고,
   파싱 실패 시 `방금 기준`으로 폴백한다.

## Alternatives Considered
1. 기존 정적 discovery UI 유지
   - 서버 집계 반영이 불가능하고 문서 계약과 불일치한다.
2. 요청 취소 없이 디바운스만 유지
   - 네트워크 혼잡 시 stale 응답 역전 위험이 남는다.

## Consequences
### Positive
- 검색 전역 계약과 API 요청이 일치한다.
- 검색 홈이 서버 discovery 지표를 반영할 수 있다.
- 빠른 타이핑에서 불필요 요청과 레이스 컨디션을 줄인다.

### Trade-offs
- discovery 응답 구조 변경 시 DTO/매핑 유지보수가 필요하다.
- popular fallback이 존재해 서버 장애 시에도 UI는 유지되지만,
  완전한 실시간 지표를 보장하지는 않는다.

## Scope
- `lib/core/network/api_client.dart`
- `lib/core/constants/api_constants.dart`
- `lib/core/constants/api_v3_endpoints_catalog.dart`
- `lib/features/search/application/search_controller.dart`
- `lib/features/search/data/datasources/search_remote_data_source.dart`
- `lib/features/search/data/repositories/search_repository_impl.dart`
- `lib/features/search/domain/repositories/search_repository.dart`
- `lib/features/search/domain/entities/search_entities.dart`
- `lib/features/search/presentation/pages/search_page.dart`
- `test/features/search/data/search_discovery_dto_test.dart`
- `test/core/constants/api_endpoints_contract_test.dart`

## Validation
- `flutter analyze lib/features/search lib/core/constants/api_constants.dart lib/core/constants/api_v3_endpoints_catalog.dart lib/core/network/api_client.dart test/core/constants/api_endpoints_contract_test.dart test/features/search/data/search_discovery_dto_test.dart`
- `flutter test test/features/search/data/search_item_dto_test.dart test/features/search/data/search_discovery_dto_test.dart test/core/constants/api_endpoints_contract_test.dart`

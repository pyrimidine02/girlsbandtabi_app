# ADR-20260307-home-project-gate-loading-state

## Status
Accepted (2026-03-07)

## Context
- 홈 화면은 `selectedProjectKey`가 설정된 뒤에만 `HomeController.load()`를 실행한다.
- 프로젝트 부트스트랩(`GET /api/v1/projects`)이 실패하면 `selectedProjectKey`가 비어 있고,
  홈 상태는 초기 `AsyncLoading`에서 벗어나지 못해 무한 로딩처럼 보인다.
- 실제 운영/개발 환경에서 프로젝트 API 일시 장애(5xx)가 발생할 수 있으므로,
  사용자에게 명시적 실패 상태와 재시도 경로를 제공해야 한다.

## Decision
- `HomePage`에 프로젝트-선택 게이트를 추가한다.
  - `selectedProjectKey`가 없으면 홈 데이터 렌더링 전에 프로젝트 상태를 먼저 평가한다.
  - 프로젝트 목록 로딩 중: 기존 홈 스켈레톤 유지
  - 프로젝트 목록 실패: 에러 상태 + 재시도 버튼 제공
  - 프로젝트 목록 비어 있음: 명시적 오류/빈 상태 노출
  - 프로젝트 목록은 있으나 선택 키가 없음: 첫 프로젝트 자동 선택
- 재시도 동작은 프로젝트 목록 재조회와 홈 재조회를 동시에 트리거한다.

## Consequences
- 프로젝트 API 장애 시 홈 화면이 무한 로딩으로 고정되지 않는다.
- 사용자/운영자가 상태를 즉시 인지하고 앱 내에서 재시도할 수 있다.
- 프로젝트 목록 복구 후 수동 이동 없이 홈 화면이 정상 흐름으로 복귀한다.

## Verification
- `dart analyze lib/features/home/presentation/pages/home_page.dart lib/features/home/application/home_controller.dart lib/features/projects/application/projects_controller.dart`
- `flutter test test/features/home/data/home_summary_dto_test.dart`

# ADR-20260309 Home Project Switch Instant Cache Apply

## Status
- Accepted

## Context
- 홈 화면에서 프로젝트를 변경할 때 요약 반영이 느리거나,
  사용자가 수동 새로고침을 해야 반영되는 체감 문제가 있었습니다.
- 기존 흐름은 `selectedProjectKey` 변경만 구독하고 즉시 `load()`를 호출해,
  `selectedProjectId`가 직후 갱신되는 타이밍과 엇갈릴 수 있었습니다.
- 또한 by-project 요약을 받아도 프로젝트 전환 시 메모리 즉시 반영 계층이 없어
  캐시된 요약이 있어도 네트워크 완료를 체감 대기하는 경우가 있었습니다.

## Decision
- `HomeController`에서 프로젝트 선택 변경 신호를 다음처럼 처리합니다.
  - `selectedProjectKey` + `selectedProjectId`를 모두 구독
  - microtask 단위로 신호를 coalesce하여 key/id 최신 조합으로 한 번만 load
- by-project 응답에서 프로젝트별 요약을 메모리 캐시에 저장하고,
  프로젝트 전환 시 캐시 적중 시 즉시 `AsyncData` 반영 후 백그라운드 load 수행.
- 비동기 경쟁 상태 방지를 위해 request serial을 도입하여
  최신 요청만 상태를 갱신하도록 제한.
- 프로젝트 식별자 해석 시 loaded project 목록 기반 key->id 매핑을 우선 적용.

## Consequences
- 홈 프로젝트 전환 시 즉시 전환 체감이 개선됩니다.
- key/id 갱신 레이스로 잘못된 프로젝트 요약이 유지되는 케이스를 줄입니다.
- 빠른 연속 전환 시 이전 느린 응답이 최신 상태를 덮어쓰는 문제를 방지합니다.

## Verification
- `flutter analyze lib/features/home/application/home_controller.dart`
- `flutter test test/features/home/data/home_summary_dto_test.dart test/features/home/domain/home_summary_test.dart`

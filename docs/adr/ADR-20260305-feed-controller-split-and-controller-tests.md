# ADR-20260305-feed-controller-split-and-controller-tests

## Status
Accepted (2026-03-05)

## Context
- `docs/architecture/ARCHITECTURE_REVIEW.md`에서 `lib/features/feed/application/feed_controller.dart` 비대화(단일 파일 다중 도메인 혼재)가 핵심 리스크로 식별됨.
- `docs/architecture/IMPROVEMENT_ROADMAP.md` Phase 3에서 feed controller 분리와 핵심 controller 테스트 추가를 요구함.

## Decision
### 1) Feed application 레이어 분리
- 기존 단일 파일을 목적별 파일로 분리:
  - `lib/features/feed/application/feed_repository_provider.dart`
  - `lib/features/feed/application/news_controller.dart`
  - `lib/features/feed/application/board_controller.dart`
  - `lib/features/feed/application/post_controller.dart`
  - `lib/features/feed/application/reaction_controller.dart`

### 2) 하위 호환 유지
- 기존 import 경로 안정성을 위해
  - `lib/features/feed/application/feed_controller.dart`
  - 를 **barrel export** 파일로 전환.
- 기존 화면/모듈의 `import 'feed_controller.dart'`는 즉시 깨지지 않으며 점진적 마이그레이션 가능.

### 3) Controller 테스트 추가 (Phase 3 착수)
- 신규 테스트 파일:
  - `test/features/verification/application/verification_controller_test.dart`
  - `test/features/settings/application/settings_controller_test.dart`
  - `test/features/places/application/places_controller_test.dart`
  - `test/features/visits/application/visits_controller_test.dart`
- 현재 범위: 인증/프로젝트 미선택 등 **가드 동작** + 방문 로드 성공 경로.

## Consequences
### Positive
- feed application 구조 가독성/변경 격리도 향상.
- 팀 단위 병렬 작업 시 충돌 감소.
- controller 레벨 최소 회귀 안전망 확보.

### Trade-offs
- 임시로 `feed_controller.dart`(barrel) + 세부 모듈이 공존해 파일 수가 증가.
- 테스트가 아직 주요 성공/실패 시나리오 전체를 포괄하지는 않음.

## Validation
- `flutter analyze` (변경 파일 대상): 통과
- `flutter test`: 통과

## Follow-up
- 직접 import를 세부 모듈로 점진 전환 후 `feed_controller.dart` barrel 제거.
- controller 테스트를 mutation/error/optimistic update 시나리오까지 확장.
- AsyncNotifier 전환 파일 선정 및 단계적 마이그레이션 시작.

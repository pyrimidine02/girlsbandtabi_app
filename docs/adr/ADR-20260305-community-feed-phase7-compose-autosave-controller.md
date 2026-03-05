# ADR-20260305-community-feed-phase7-compose-autosave-controller

## Status
Accepted (2026-03-05)

## Context
- Phase6에서 작성/수정 화면의 공용 UI 컴포넌트는 분리됐지만, autosave/debounce/recovery 로직은 여전히 `PostCreatePage`/`PostEditPage` state 클래스에 중복되어 있었습니다.
- 같은 임시저장 정책(디바운스, 저장 문구, 복구 배너 상태, 저장소 삭제)을 페이지마다 따로 유지하면 이후 정책 변경(저장 주기, 메시지 규칙, recovery 처리)이 쉽게 드리프트할 위험이 있었습니다.
- 커뮤니티 개선 로드맵 요구사항(“controller + view-state 계층으로 화면 책임 축소”)을 충족하려면 autosave 오케스트레이션을 application layer로 승격해야 했습니다.

## Decision
### 1) Compose autosave 전용 컨트롤러 신설
- `lib/features/feed/application/post_compose_autosave_controller.dart` 추가.
- 구성 요소:
  - `PostComposeAutosaveConfig` (storageKey 기반 세션 식별)
  - `PostComposeAutosaveState` (recoverable draft + autosave message)
  - `PostComposeAutosaveController` (`StateNotifier`)  
    - recoverable draft 로드  
    - debounce 저장 스케줄  
    - 즉시 스냅샷 저장/삭제  
    - 복구 배너 상태 소비(consume)

### 2) 작성/수정 페이지에서 autosave 중복 로직 제거
- `PostCreatePage`, `PostEditPage`에서 로컬 `Timer`, draft-store read/write/delete, autosave 메시지 상태를 제거.
- 두 페이지 모두 `postComposeAutosaveControllerProvider`를 사용해 동일한 autosave 정책을 공유.
- dispose 시점에는 `ref.read(...)`를 직접 호출하지 않도록 autosave notifier를 `initState`에서 캐시해 teardown 안정성을 보장.

### 3) 배럴 export 확장
- `lib/features/feed/application/feed_controller.dart`에 `post_compose_autosave_controller.dart` export 추가.

## Consequences
### Positive
- 작성/수정 화면의 autosave 정책이 단일 계층(application)에서 일관되게 관리됩니다.
- 페이지 state 책임이 줄어 화면 유지보수성과 가독성이 개선됩니다.
- debounce/save/delete/recover 흐름이 테스트 가능한 형태로 분리됩니다.

### Trade-offs
- provider family 설정(`storageKey`)을 페이지별로 정확히 전달해야 하며, key 정책이 바뀌면 compose 진입점 전반에서 동기화가 필요합니다.
- autosave 상태를 provider가 관리하므로, 페이지 테스트에서 provider wiring 검증이 추가로 필요합니다.

## Validation
- `dart analyze lib/features/feed/application/post_compose_autosave_controller.dart lib/features/feed/presentation/pages/post_create_page.dart lib/features/feed/presentation/pages/post_edit_page.dart test/features/feed/application/post_compose_autosave_controller_test.dart` 통과
- `flutter analyze lib/features/feed/application/post_compose_autosave_controller.dart lib/features/feed/presentation/pages/post_create_page.dart lib/features/feed/presentation/pages/post_edit_page.dart test/features/feed/application/post_compose_autosave_controller_test.dart` 통과
- `flutter test test/features/feed/application/post_compose_autosave_controller_test.dart test/features/feed/application/post_compose_draft_store_test.dart` 통과
- `flutter test test/features/feed/presentation/pages/post_compose_autosave_integration_test.dart` 통과

## Follow-up
- create/edit 페이지 수준 widget 테스트에서 autosave provider 상태(복구 배너/저장 문구/복구·삭제 버튼 동작)까지 검증합니다.
- 서버 draft API가 도입되면 controller 내부 저장 어댑터를 local-only에서 hybrid(local+remote)로 확장합니다.

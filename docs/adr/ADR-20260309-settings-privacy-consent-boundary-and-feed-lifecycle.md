# ADR-20260309: Settings Privacy/Consent Boundary + Feed Lifecycle Hardening

- Date: 2026-03-09
- Status: Accepted
- Scope:
  - `lib/features/settings/**`
  - `lib/features/feed/**`
  - `lib/features/admin_ops/**`
  - `lib/core/theme/**`

## Context
- `privacy_rights_page`와 `consent_history_page`가 presentation 레이어에서
  직접 `ApiClient`를 호출하고 있어 계층 경계가 깨져 있었습니다.
- `communityFeedControllerProvider`가 비-`autoDispose` 상태로 남아
  화면 이탈 후 리소스 정리가 약해질 가능성이 있었습니다.
- 일부 UI 경로에서 디자인 시스템 wrapper 대신 직접 sheet/dialog를 사용했고,
  사용되지 않는 deprecated gradient 상수가 누적돼 있었습니다.

## Decision
- Settings 관련 privacy/consent/account-delete API는
  `SettingsRepository` 계약으로 통합하고 페이지는 repository 경유만 사용합니다.
- `communityFeedControllerProvider`를 `autoDispose`로 전환하고 dispose 시
  realtime sync 정리를 명시적으로 수행합니다.
- Post detail의 주요 sheet 흐름은 `showGBTBottomSheet`로 통일합니다.
- 미사용 deprecated gradient 상수를 제거합니다.
- AdminOps domain에서 Flutter `Color` 의존을 제거하고 UI 팔레트 타입은
  presentation 레이어로 이동합니다.

## Alternatives Considered
1. 페이지 단에서 직접 API 호출 유지 + 개별 보강
   - Rejected: 테스트성/일관성 저하가 지속됨.
2. feed provider 생명주기 유지(비 autoDispose)
   - Rejected: 탭 전환/화면 이탈 시 정리 누락 위험이 큼.

## Consequences
- 계층 경계가 명확해져 settings 페이지 테스트/유지보수가 쉬워집니다.
- feed 화면 이탈 시 리소스 정리가 강화되어 장시간 세션에서의
  불필요한 동기화 유지 가능성을 줄입니다.
- 디자인 시스템 사용 일관성이 개선됩니다.

## Validation
- `flutter analyze` 통과.
- `flutter test test/features/settings/application/settings_controller_test.dart`
  통과.
- `flutter test test/features/feed` 실행 시 일부 기존 통합 테스트에서
  `AppConfig.baseUrl` 미초기화 환경 이슈 확인(본 변경과 독립).

# ADR-20260310: Mobile Authz Capability Request Integration

- Date: 2026-03-10
- Status: Accepted
- Scope:
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/constants/api_constants.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/constants/api_v3_endpoints_catalog.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/network/api_client.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/providers/core_providers.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/settings/**`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/**`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/test/core/constants/api_endpoints_contract_test.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/test/features/settings/**`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/test/features/feed/presentation/pages/post_compose_autosave_integration_test.dart`

## Context
- 백엔드 요청서 `FE-REQ-MOBILE-AUTHZ-CAPABILITY-20260310`에 따라,
  모바일은 `role` 단일값이 아니라
  `accountRole + access-level + project role` 조합 기반으로
  권한 가드를 일관되게 적용해야 합니다.
- 필수 요구사항에는
  `GET /users/me/access-level` 연동,
  토큰 refresh 이후 재조회,
  역할요청 입력 제한,
  번역/신고 enum/입력 정책 반영이 포함됩니다.
- 기존 구현에는 provider 생성 시 자동 비동기 로드로 인한
  dispose 이후 상태갱신/테스트 부작용 리스크가 있었습니다.

## Decision
- 권한 부트스트랩 계약을 앱 전역으로 명시화했습니다.
  - `GET /users/me/access-level` 계약을 클라이언트 상수/카탈로그/DTO에 추가.
  - `users/me` + `access-level` 결과를 프로필 모델로 병합.
  - 앱 부트스트랩에서 auth 상태/토큰 refresh 이벤트 기준으로
    프로필 강제 재조회 실행.
- 역할요청 입력을 서버 정책에 맞춰 클라이언트 선검증합니다.
  - `requestedRole`: `PLACE_EDITOR`, `COMMUNITY_MODERATOR`만 허용.
  - 요청 바디 `projectId`: UUID만 허용.
- 번역/신고 정책을 DTO/도메인/리포지토리 가드에 반영합니다.
  - 번역 언어 `ko/en/ja` 제한, `text <= 5000`.
  - 신고 `targetType`에 `PLACE/GUIDE/PHOTO` 확장.
- 설정 계층 컨트롤러에 `mounted` 가드를 추가해
  dispose 이후 상태 갱신을 차단합니다.
- provider 생성자 자동 로드를 제거하고
  app bootstrap provider에서 초기 로드를 담당하도록 분리합니다.

## Alternatives Considered
1. `users/me`만 사용하고 access-level API는 403 발생 시 재조회
   - Rejected: 권한 UI 비노출 정책(fail-closed)과 초기 일관성 요구를 만족하지 못합니다.
2. provider 생성 시 자동 `load()` 유지
   - Rejected: 테스트/화면 단위에서 의도치 않은 네트워크 bootstrap과
     dispose race를 계속 유발합니다.
3. 역할요청 제한을 서버 검증에만 위임
   - Rejected: 사용자 입력 단계에서 즉시 피드백이 불가능하고
     불필요한 실패 요청이 증가합니다.

## Consequences
- 권한 판정 데이터(`effectiveAccessLevel`, `grants`)가 앱 전역에서
  예측 가능한 시점에 동기화됩니다.
- 권한 미달 기능 비노출 정책과 토큰 refresh 이후 재평가가
  같은 파이프라인에서 동작합니다.
- dispose race 관련 크래시 리스크가 감소합니다.
- post-compose 통합 테스트는 `AppConfig` 초기화가 필요하므로,
  테스트 harness에서 이를 명시적으로 초기화합니다.

## Validation
- `flutter analyze`
- `flutter test --reporter compact`

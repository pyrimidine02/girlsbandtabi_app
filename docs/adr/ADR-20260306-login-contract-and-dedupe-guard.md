# ADR-20260306-login-contract-and-dedupe-guard

## Status
Accepted (2026-03-06)

## Context
- 2026-03-06 23:01~23:05 (KST) 구간에서 모바일 로그인 실패가 다수 발생했다.
- 주요 징후:
  - 로그인 요청에서 `400(VALIDATION_FAILED)`, `403`, `409(CONFLICT)`, `429`
  - 로그인 직후 보호 API (`/api/v1/home/summary`)에서 `401` 발생 사례
- 앱/서버 계약에서 로그인 요청 바디 표준은 `username/password`인데, 클라이언트에서 중복 요청/타이밍 레이스가 함께 발생하면 오류율이 상승할 수 있었다.

## Decision
1. 로그인 요청 계약을 고정한다.
   - DTO는 `{"username": ..., "password": ...}`만 전송한다.
   - 로그인 입력 UI는 이메일 중심 문구를 사용하되, API 키는 `username`을 유지한다.
2. 중복 로그인 요청을 이중으로 차단한다.
   - UI: 로그인 진행 중 버튼/제출 비활성화 (`_isSubmitting`)
   - Repository: 동일 계정(normalized username) in-flight 요청 dedupe
3. 제한적 재시도 정책을 적용한다.
   - `409`: 짧은 지연 후 1회 재시도 (`280ms`)
   - `429`: 즉시 재시도 금지, 지연 후 1회 재시도 (`1200ms`)
4. 토큰 저장 완료를 인증 성공의 전제조건으로 둔다.
   - 토큰 저장 이후 `hasValidTokens()` 검증에 성공해야 로그인 성공으로 처리한다.
5. 로그인 오류 UX를 상태 코드별로 분기한다.
   - `400`, `401`, `403`, `429` 각각 안내 문구 분리

## Consequences
### Positive
- 로그인 API 계약 위반 가능성(`email` 키 전송) 회귀를 테스트로 방지한다.
- 빠른 연속 탭/중복 이벤트로 인한 같은 계정 로그인 요청 폭주를 억제한다.
- 로그인 직후 토큰 미저장 상태에서 보호 API를 호출하는 레이스를 줄인다.
- 실패 사유별 안내가 명확해져 사용자 재시도 품질이 향상된다.

### Trade-offs
- `409`/`429`에서 최대 1회 지연 재시도로 로그인 완료까지 체감 지연이 늘 수 있다.
- 동일 계정으로 동시에 다른 비밀번호를 제출한 요청도 dedupe 대상이 될 수 있다(의도된 보호 동작).

## Validation
- `dart format lib/core/security/secure_storage.dart lib/features/auth/application/auth_controller.dart lib/features/auth/data/repositories/auth_repository_impl.dart lib/features/auth/presentation/pages/login_page.dart test/features/auth/data/auth_repository_login_policy_test.dart`
- `flutter analyze lib/features/auth lib/core/security/secure_storage.dart test/features/auth/data/auth_repository_login_policy_test.dart`
- `flutter test test/features/auth`

## Follow-up
- 서버가 로그인 `429`에 대해 표준 `retryAfter` 계약을 확정하면, 현재 고정 지연(`1200ms`)을 서버 지시 기반으로 전환한다.
- 로그인 화면 레벨에서 다중 탭/네트워크 지연 시나리오 위젯 테스트를 추가해 UX 회귀를 지속 감시한다.

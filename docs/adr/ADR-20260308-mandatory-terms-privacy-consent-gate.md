# ADR-20260308-mandatory-terms-privacy-consent-gate

## Status
Accepted

## Date
2026-03-08

## Context
- 요구사항: 약관/개인정보 동의 미완료 사용자는 서비스 이용을 차단해야 한다.
- 앱은 회원가입 시 동의 payload를 전송하지만, 로그인 이후 사용자 재동의를 위한
  전용 쓰기 API는 현재 클라이언트 계약에 확정되어 있지 않다.
- 사용 가능한 서버 계약은 `GET /api/v1/users/me/consents` 조회 중심이다.

## Decision
1. 인증 사용자 세션에 대해 전역 필수 동의 게이트를 도입한다.
2. 필수 동의 판정은 다음 병합 원칙으로 계산한다.
   - 서버 동의 이력(`GET /users/me/consents`)
   - 로컬 동의 스냅샷(`user_consents`)
3. 필수 타입은 `TERMS_OF_SERVICE`, `PRIVACY_POLICY` 두 가지로 제한한다.
4. 타입별 최신 레코드 기준으로 아래 조건을 모두 만족해야 통과한다.
   - `agreed == true`
   - `version == LegalPolicyConstants`의 현재 버전
5. 미충족 시 앱 전역 차단 오버레이(팝업 UI)를 띄워 모든 페이지 상호작용을 막는다.
6. 사용자가 필수 항목 체크 후 동의하면 로컬 스냅샷에 동의 레코드를 추가하고
   즉시 재판정해 차단을 해제한다.

## Alternatives Considered
1. 라우터 리다이렉트 전용 차단 페이지
   - 페이지 전환 충돌이 늘고, 요구된 팝업 UX와 어긋난다.
2. 서버 동의 이력만 신뢰
   - 서버 조회 실패 시 사용자가 무조건 차단되는 운영 리스크가 크다.
3. 로컬 동의만 신뢰
   - 멀티디바이스/감사 추적 일관성이 낮다.

## Consequences
### Positive
- 미동의 사용자에 대한 서비스 이용 차단을 클라이언트에서 즉시 강제할 수 있다.
- 정책 버전 변경 시 재동의 요구가 자동으로 동작한다.
- 서버 조회 실패 상황에서도 로컬 fallback으로 과도한 오탐 차단을 줄인다.

### Trade-offs
- 재동의 결과가 서버 이력에 즉시 반영되지 않을 수 있다(쓰기 API 부재).
- 동의 판정/차단 로직이 앱 시작 시 추가 네트워크 및 상태 계산을 수행한다.

## Scope
- `lib/features/settings/application/mandatory_consent_controller.dart`
- `lib/app.dart`
- `test/features/settings/application/mandatory_consent_controller_test.dart`

## Validation
- `flutter analyze lib/app.dart lib/features/settings/application/mandatory_consent_controller.dart`
- `flutter test test/features/settings/application/mandatory_consent_controller_test.dart`

# ADR-20260310: Mandatory Consent Gate via Server Dynamic Policy

- Date: 2026-03-10
- Status: Accepted
- Scope:
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/settings/application/mandatory_consent_controller.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/app.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/constants/api_constants.dart`

## Context
- 기존 필수 동의 게이트는 `LegalPolicyConstants` 하드코딩 버전/URL과
  로컬 동의 이력 병합 로직으로 차단 여부를 계산했습니다.
- 백엔드가 필수 동의 정책 소스를 `ENV -> DB/Admin API`로 전환하면서
  정책 버전/링크가 운영 중 실시간 변경될 수 있게 되었습니다.
- 프런트가 하드코딩 버전/링크를 계속 사용하면 운영 정책과 불일치가 발생합니다.

## Decision
- 필수 동의 게이트 판단 기준을 `GET /api/v1/users/me/consent-status`로
  단일화합니다.
  - 차단 조건: `canUseService=false` 또는
    `requiredConsents[].needsReconsent=true` 항목 존재.
- 동의 제출은 `POST /api/v1/users/me/consents`로 전환하고,
  제출 성공 직후 `consent-status`를 재조회해 차단 해제 여부를 확정합니다.
- 차단 오버레이는 API 응답 기반 동적 렌더링으로 변경합니다.
  - 문서 URL: `policyUrl`
  - 버전: `requiredVersion`
  - 타입 라벨: `TERMS_OF_SERVICE`, `PRIVACY_POLICY` 매핑
- 실패 UX를 명시합니다.
  - 상태 조회 실패: 차단 화면 내 재시도 버튼 제공
  - 제출 실패: 스낵바(토스트) 노출 후 재시도 가능
  - `error.code` 및 가능한 경우 `requestId` 노출

## Alternatives Considered
1. 하드코딩 버전/URL 유지 + 백엔드 버전과 수동 동기화
   - Rejected: 운영 반영마다 앱 릴리즈/검증이 필요하고 불일치 위험이 큼.
2. `GET /users/me/consents` 이력만으로 최신 동의 판단 유지
   - Rejected: 운영 정책(required version/url) 변경을 즉시 반영할 수 없음.

## Consequences
- 운영자가 정책 버전/링크를 변경하면 앱 업데이트 없이 즉시 반영됩니다.
- 재동의 여부 판정 책임이 서버로 일원화되어 프런트 로직이 단순해집니다.
- 상태 조회 실패 시 보수적으로 차단 유지하므로 가용성보다 정책 준수를 우선합니다.

## Validation
- `dart analyze lib/app.dart lib/features/settings/application/mandatory_consent_controller.dart lib/core/constants/api_constants.dart test/features/settings/application/mandatory_consent_controller_test.dart`
- `flutter test test/features/settings/application/mandatory_consent_controller_test.dart`


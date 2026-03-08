# ADR-20260308-privacy-rights-api-alignment-v072

## Status
Accepted

## Date
2026-03-08

## Context
- 서버에 개인정보/권리행사 API가 정식 반영되면서 계약이 구체화되었다.
  - `GET/PATCH /api/v1/users/me/privacy-settings` (`updatedAt`, `version`)
  - `GET/POST /api/v1/users/me/privacy-requests`
  - `GET /api/v1/users/me/consents` (pagination + 최신순)
- 기존 앱은 개인정보 설정 일부를 로컬 우선으로 처리하고,
  권리행사 요청은 로컬 임시 이력 의존이 남아 있었다.
- 동시 수정 충돌(`PRIVACY_SETTINGS_VERSION_CONFLICT`) 대응이 필요해졌다.

## Decision
1. 개인정보 설정 초기화는 서버 원본(`GET /privacy-settings`)을 우선 사용한다.
2. 자동번역 토글 저장 시 `version`을 함께 전송해 낙관적 동시성 제어를 적용한다.
3. `PRIVACY_SETTINGS_VERSION_CONFLICT` 발생 시 서버 최신값을 즉시 재조회해 UI를 복구한다.
4. 처리정지 요청 payload는 `requestType=RESTRICTION`으로 정렬한다.
5. 권리행사 요청 이력은 서버(`GET /privacy-requests`)에서 조회해 화면에 노출한다.
6. 동의 이력 호출은 pagination/sort 파라미터를 포함해 최신순 기준을 명시한다.
7. `409 Conflict` 에러는 `ValidationFailure`로 매핑해 서버 `error.code`를
   화면 분기에서 직접 사용할 수 있도록 한다.

## Alternatives Considered
1. 로컬 우선 정책 유지
   - 구현 단순하지만 멀티디바이스/운영자 처리 이후 상태 불일치가 누적된다.
2. version 미사용 PATCH 유지
   - 충돌 감지 불가로 마지막 저장이 덮어쓰는 경쟁 상태가 발생할 수 있다.

## Consequences
### Positive
- 개인정보 설정/권리행사 화면이 서버 단일 진실원(Source of Truth)에 맞춰 동작한다.
- 동시 수정 충돌 시 사용자에게 일관된 복구 UX를 제공한다.
- 권리행사 이력의 신뢰도가 로컬 임시 저장 대비 크게 개선된다.

### Trade-offs
- 페이지 진입 시 추가 API 왕복이 생긴다.
- 서버 미가용 시 기존 대비 로컬 fallback 경로가 줄어들어 네트워크 의존성이 높아진다.

## Scope
- `lib/features/settings/presentation/pages/privacy_rights_page.dart`
- `lib/features/settings/presentation/pages/consent_history_page.dart`
- `lib/core/error/error_handler.dart`

## Validation
- `flutter analyze lib/features/settings/presentation/pages/privacy_rights_page.dart lib/features/settings/presentation/pages/consent_history_page.dart`

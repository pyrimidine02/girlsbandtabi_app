# ADR-20260306-frontend-legal-compliance-phase2-self-service

## Status
Accepted (2026-03-06)

## Context
- Phase1에서 회원가입/위치인증 동의 게이트와 정책 노출 강화는 반영되었지만,
  사용자 관점의 권리행사 진입점(동의 이력 조회, 처리정지/탈퇴 요청, 자동번역 옵트아웃)은
  설정 화면에서 직접 접근하기 어려웠다.
- 백엔드 계약(`consents`, `privacy-settings`, `privacy-requests`)은 부분적으로만 확정되어
  모바일 클라이언트는 서버 미지원 상태에서도 UX를 끊지 않는 fallback이 필요했다.

## Decision
1. 설정 화면에 개인정보 셀프서비스 진입점을 추가한다.
   - `/settings/privacy-rights`
   - `/settings/consents`
2. `ConsentHistoryPage`는 서버 우선 + 로컬 fallback 전략을 사용한다.
   - 1순위: `GET /api/v1/users/me/consents`
   - fallback: 로컬 동의 스냅샷(`user_consents`)
3. 회원가입 성공 시 필수 동의 3종 스냅샷을 로컬에 저장한다.
   - `TERMS_OF_SERVICE`, `PRIVACY_POLICY`, `AGE_OVER_14`
4. 로그아웃 시 프라이버시/컴플라이언스 관련 로컬 키를 즉시 제거한다.
   - `user_consents`, `auto_translation_enabled`, `privacy_request_history`

## Consequences
### Positive
- 사용자 입장에서 권리행사 동선이 명확해지고, 설정 내 접근성이 개선된다.
- 서버 계약 미완료 상황에서도 기능이 완전히 막히지 않고 local fallback으로 지속 가능하다.
- 계정 전환/로그아웃 시 이전 사용자 프라이버시 데이터 잔존 가능성을 낮춘다.

### Trade-offs
- fallback 저장 구조는 감사/법적 증빙의 authoritative source가 될 수 없다.
- 서버 계약 확정 후 payload/응답 스키마 재정렬이 필요하다.

## Validation
- `dart format`:
  - `lib/core/router/app_router.dart`
  - `lib/features/auth/presentation/pages/register_page.dart`
  - `lib/features/auth/application/auth_controller.dart`
  - `lib/features/settings/presentation/pages/settings_page.dart`
  - `lib/features/settings/presentation/pages/consent_history_page.dart`
  - `lib/features/settings/presentation/pages/privacy_rights_page.dart`
- `flutter analyze` on the files above
- `flutter test`:
  - `test/features/auth/data/token_response_test.dart`
  - `test/features/settings/application/settings_controller_test.dart`
  - `test/features/settings/data/notification_settings_dto_test.dart`

## Follow-up
- 서버 계약 확정 시 `consent history`와 `privacy requests`를 서버 source-of-truth로 전환.
- 동의 스냅샷 저장 포맷을 백엔드 consent enum/version policy와 완전히 정합화.
- 권리행사 처리상태(`PENDING/APPROVED/REJECTED`) UI 및 상세 이력 페이지 추가.

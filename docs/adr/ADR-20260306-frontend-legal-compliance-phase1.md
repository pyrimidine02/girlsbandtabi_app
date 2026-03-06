# ADR-20260306-frontend-legal-compliance-phase1

## Status
Accepted (2026-03-06)

## Context
- 법률 컴플라이언스 점검 결과 중 프런트 단독으로 즉시 완화 가능한 P0 항목이 식별되었다.
- 특히 회원가입 동의 수집, 위치 인증 사전 고지, 인증 오류 메시지 최소화, 정책 문서 접근성 개선이 우선 과제로 지정되었다.
- 백엔드 계약(동의 이력 저장, 개인정보 설정 API 등)은 일부 미확정 상태다.

## Decision
1. 회원가입에 필수 동의 3종을 UI로 분리 적용한다.
   - 이용약관/개인정보처리방침/만 14세 이상 체크를 별도 수집
   - 가입 요청 직전 최종 확인 모달을 추가
2. 위치 인증 바텀시트에 사전 고지 + 동의 게이트를 추가한다.
   - 동의 전에는 인증 시작(=OS 권한 요청 및 인증 API 호출)을 차단
3. 로그인/회원가입 실패 토스트 문구를 민감정보·계정유추 방지형으로 단순화한다.
4. 정책 링크 접근 동선을 강화한다.
   - 회원가입/설정/프로필 수정 화면에 정책 링크와 버전 표기를 공통 적용
5. 설정/프로필 화면 이메일 표시는 마스킹한다.

## Consequences
### Positive
- 동의 없는 가입/위치 인증 진행 가능성을 프런트에서 즉시 차단할 수 있다.
- 운영 화면에서 민감정보 노출 리스크를 낮춘다.
- 정책 문서 접근성과 버전 인지성을 높여 사용자 고지 품질을 개선한다.

### Trade-offs
- 정책 URL/버전은 현재 상수 기반이며, 운영 시점의 최신 버전 반영은 배포 또는 정책 메타 API가 필요하다.
- 동의 이력의 서버 저장·감사 추적은 백엔드 계약 확정 전까지 제한적이다.

## Validation
- `dart format` for updated auth/settings/verification/legal files
- `flutter analyze` for updated auth/settings/verification/legal files
- `flutter test`:
  - `test/features/auth/data/token_response_test.dart`
  - `test/features/settings/application/settings_controller_test.dart`
  - `test/features/settings/data/notification_settings_dto_test.dart`

## Follow-up
- 백엔드와 다음 계약을 확정한다:
  - 가입 시 동의 항목/버전/시각 저장 필드
  - 동의 이력 조회 API
  - 개인정보 설정/권리행사 API
- 정책 문서 URL/버전을 서버 메타데이터 기반으로 동기화하도록 전환한다.

# ADR-20260309 Admin Role Request Flow Integration

## Status
Accepted

## Context
- Backend authz model request (`admin-user-and-authorization-model-request-20260309.md`) 10/11 항목 기준으로:
  - 사용자 권한 요청은 템플릿 복사 방식이 아니라 API 기반 CRUD가 필요했습니다.
  - 운영자 권한 요청 검토(승인/거절) 화면과 엔드포인트 연동이 비어 있었습니다.
- 기존 앱은 `계정 도구 > 권한 요청`에서 클립보드 템플릿만 제공했고,
  운영센터는 신고 관리만 처리했습니다.

## Decision
- 권한 요청 API 경로를 상수/계약 테스트에 추가:
  - `/api/v1/projects/role-requests`
  - `/api/v1/projects/role-requests/{requestId}`
  - `/api/v1/admin/projects/role-requests`
  - `/api/v1/admin/projects/role-requests/{requestId}`
  - `/api/v1/admin/projects/role-requests/{requestId}/review`
- Settings 계층에 사용자 권한요청 모델/리포지토리/컨트롤러를 추가:
  - 요청 생성/목록 조회/취소 지원
  - 요청 사유 길이 검증(20~2000)
- Account Tools 권한요청 탭을 API 실연동 UI로 교체:
  - `PLACE_EDITOR` / `COMMUNITY_MODERATOR` 요청 제출
  - 내 요청 내역 상태 표시 및 pending 요청 취소
- Admin Ops 계층/화면에 권한요청 검토 플로우를 추가:
  - 요청 목록/필터 조회
  - 승인/거절 + 메모 입력 후 검토 반영

## Consequences
- 문서 11.1의 사용자/운영자 요청 승인 플로우가 앱 내에서 직접 동작합니다.
- 권한요청 UX가 수동 복사 방식에서 서버 상태 기반으로 전환되어 상태 정합성이 좋아집니다.
- 11.2/11.3의 직접 부여/회수 UI는 이번 범위에서 제외했으며,
  운영자 검토 플로우를 우선 반영했습니다.

## Validation
- `flutter analyze lib/features/settings lib/features/admin_ops lib/core/constants lib/core/cache test/core/constants/api_endpoints_contract_test.dart test/features/settings/data/account_tools_dto_test.dart test/features/admin_ops/data/admin_ops_dto_test.dart`
- `flutter test test/features/settings/data/account_tools_dto_test.dart test/features/admin_ops/data/admin_ops_dto_test.dart test/core/constants/api_endpoints_contract_test.dart`

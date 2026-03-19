# ADR-20260310: Image Processing Policy Update and Admin Media Deletion Flow

- Date: 2026-03-10
- Status: Accepted
- Scope:
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/uploads/**`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/places/presentation/pages/place_detail_page.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/admin_ops/**`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/constants/api_constants.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/constants/api_v3_endpoints_catalog.dart`

## Context
- 백엔드 정책이 커뮤니티 이미지 사전 승인에서 사후 모더레이션으로 전환되었습니다.
- 프런트에는 폐기된 업로드 승인/대기 API와 승인 UI가 남아 있어 정책과 불일치 상태였습니다.
- 동시에 운영센터에서는 미디어 삭제 요청을 승인할 때
  `deleteLinkedContents` 옵션을 선택할 수 있어야 합니다.

## Decision
- 업로드 승인/대기 계약을 프런트 코드에서 제거합니다.
  - 제거:
    - `GET /api/v1/uploads/pending`
    - `PUT /api/v1/uploads/{uploadId}/approve`
  - 유지:
    - `POST /uploads/presigned-url`
    - `POST /uploads`
    - `POST /uploads/{uploadId}/confirm`
    - `GET /uploads/my`
    - `DELETE /uploads/{uploadId}`
- 장소 상세의 방문 후기 카드에서 관리자 사진 승인/반려 UI를 제거합니다.
- 운영센터에 `미디어 삭제` 탭을 추가하고 아래 액션을 지원합니다.
  - 승인(미디어만): `deleteLinkedContents=false`
  - 승인(연관 콘텐츠 포함): `deleteLinkedContents=true`
  - 반려

## Alternatives Considered
1. 기존 승인 UI를 남기고 서버 응답만 무시
   - Rejected: 정책 불일치를 UI가 계속 노출해 운영 혼선을 유발합니다.
2. 운영센터 UI 없이 백엔드 전용 처리
   - Rejected: 요청 문서의 프런트 연동 요구사항(`deleteLinkedContents` 선택 제공)을 충족하지 못합니다.

## Consequences
- 업로드 후 이미지 노출 경로가 단순해져 승인 대기 분기 회귀 위험이 감소합니다.
- place detail 후기 카드에서 불필요한 관리자 액션이 제거되어 사용자/운영자 모두 정책과 동일한 화면을 보게 됩니다.
- 운영센터에서 미디어 삭제 승인 시 연관 콘텐츠 동시 삭제 여부를 명시적으로 선택할 수 있습니다.

## Validation
- `dart analyze lib/core/constants/api_constants.dart lib/core/constants/api_v3_endpoints_catalog.dart lib/features/uploads/data/dto/upload_dto.dart lib/features/uploads/data/datasources/uploads_remote_data_source.dart lib/features/uploads/domain/repositories/uploads_repository.dart lib/features/uploads/data/repositories/uploads_repository_impl.dart lib/features/uploads/application/uploads_controller.dart lib/features/places/presentation/pages/place_detail_page.dart lib/features/admin_ops/domain/entities/admin_ops_entities.dart lib/features/admin_ops/data/dto/admin_ops_dto.dart lib/features/admin_ops/data/datasources/admin_ops_remote_data_source.dart lib/features/admin_ops/domain/repositories/admin_ops_repository.dart lib/features/admin_ops/data/repositories/admin_ops_repository_impl.dart lib/features/admin_ops/application/admin_ops_controller.dart lib/features/admin_ops/presentation/pages/admin_ops_page.dart test/core/constants/api_endpoints_contract_test.dart test/features/admin_ops/data/admin_ops_dto_test.dart test/features/admin_ops/domain/admin_ops_entities_test.dart`
- `flutter test test/core/constants/api_endpoints_contract_test.dart test/features/admin_ops/data/admin_ops_dto_test.dart test/features/admin_ops/domain/admin_ops_entities_test.dart`

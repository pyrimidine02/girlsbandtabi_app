# ADR-20260331: GIF Upload Direct Routing

## Status
- Accepted (2026-03-31)

## Context
- 모바일 GIF 업로드 요청이 `POST /api/v1/uploads/presigned-url`로 전송되며
  서버에서 `INVALID_REQUEST`를 반환했습니다.
- 서버 로그의 구체 원인:
  - `Image uploads must use direct upload endpoint.`
- 현재 클라이언트 `UploadsController`는 `image/gif`를 presigned 경로로
  우선 라우팅하도록 구현되어 있었습니다.

## Problem (Before)
- GIF 업로드가 서버 정책(이미지는 direct 업로드 사용)과 불일치했습니다.
- 결과적으로 GIF 업로드가 400으로 실패하고 게시글 작성 플로우가 중단됐습니다.

## Decision
- 업로드 라우팅 정책을 명시적으로 분리하고,
  `image/*` MIME 타입은 모두 direct multipart 업로드를 사용하도록 통일합니다.
- `UploadsController`의 GIF 전용 presigned 우선 분기를 제거합니다.
- non-image 타입만 presigned-first + direct fallback 전략을 유지합니다.

## Alternatives Considered
1. GIF만 예외적으로 presigned 유지
   - Rejected: 서버 정책과 충돌해 동일 400 오류가 재발합니다.
2. direct 실패 시 GIF를 presigned로 재시도
   - Rejected: 정책 위반 경로를 의도적으로 재시도하게 되어 불필요한 실패를 유발합니다.

## Consequences
- GIF 업로드 실패(400 INVALID_REQUEST) 재발 위험이 감소합니다.
- 이미지 업로드 경로가 `image/* => direct`로 단순화되어
  추후 MIME별 라우팅 회귀 가능성이 낮아집니다.
- non-image 업로드의 presigned 경로는 기존과 동일하게 유지됩니다.

## Scope / Impact
- Affected files:
  - `lib/features/uploads/application/uploads_controller.dart`
  - `lib/features/uploads/application/upload_routing_policy.dart` (new)
  - `test/features/uploads/application/upload_routing_policy_test.dart` (new)
  - `test/features/uploads/application/uploads_controller_test.dart` (new)

## Verification
- `flutter test test/features/uploads/application/upload_routing_policy_test.dart test/features/uploads/application/uploads_controller_test.dart`
- `flutter analyze lib/features/uploads/application/upload_routing_policy.dart lib/features/uploads/application/uploads_controller.dart test/features/uploads/application/upload_routing_policy_test.dart test/features/uploads/application/uploads_controller_test.dart`


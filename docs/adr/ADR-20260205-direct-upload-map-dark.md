# ADR-20260205: Direct Upload Fallback + Map Dark Style

## Status
Accepted

## Context
- 업로드 API가 `POST /api/v1/uploads`(multipart)로 직접 업로드를 지원하고, 기존 presigned 업로드는 fallback으로 유지가 필요했다.
- 다크모드에서 지도(구글맵)가 밝게 보여 시각적 일관성이 떨어졌다.

## Decision
- 업로드는 direct multipart를 우선 사용하고, 실패 시 presigned 업로드로 fallback 한다.
- 프로필/후기/커뮤니티 업로드 플로우는 통합된 `uploadImageBytes`를 사용한다.
- 구글맵에 다크 스타일 JSON을 적용하고, 테마 변경 시 controller에 스타일을 재적용한다.

## Alternatives Considered
- presigned 업로드만 유지: 신규 엔드포인트 활용 불가, 서버 설정 변경에 취약.
- 지도 스타일 변경 없이 유지: 다크모드 UX 불일치.

## Consequences
- 업로드 로직이 단일 API로 시작하되, 서버 기능 비활성화 시에도 presigned 경로로 안전하게 동작한다.
- 구글맵은 다크모드 대응, Apple Maps는 플랫폼 제약으로 기본 스타일 유지.

## Notes
- Apple Maps 다크 스타일은 현 시점 플러그인 제약으로 미적용.

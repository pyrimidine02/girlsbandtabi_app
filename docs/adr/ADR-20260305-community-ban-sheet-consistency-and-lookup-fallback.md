# ADR-20260305: Community Ban Sheet Consistency and Multi-key Lookup Fallback

## Status
Accepted

## Context
- `BoardPage` 내 바텀시트(`내 신고 내역`, `커뮤니티 제재 관리`)의 시각적 톤이 서로 달라 사용자가 같은 기능군으로 인지하기 어려웠다.
- 제재 조회는 `userId` 직접 입력 전제여서 운영자가 닉네임/이메일만 아는 경우 탐색 효율이 낮았다.
- 현재 API 카탈로그 기준 제재 검색 전용 엔드포인트는 없고, 아래만 존재한다.
  - `GET /api/v1/projects/{projectCode}/moderation/bans`
  - `GET /api/v1/projects/{projectCode}/moderation/bans/{userId}`

## Decision
- 두 바텀시트를 동일한 컴팩트 리스트 패턴으로 통일했다.
  - 타이틀 + 새로고침
  - 리스트 중심 밀도 높은 항목 표현
- 제재 조회 입력을 `사용자 ID/닉네임/이메일`로 확장했다.
  - UUID 입력: 기존 상세 조회 API 사용
  - 비 UUID 입력: 현재 제재 목록을 닉네임/이메일/ID 기준으로 클라이언트 필터링
  - 다건 매치: 목록 필터에 자동 반영
- DTO/Domain에 `bannedUserEmail`(optional)을 추가해 이메일 기반 필터가 가능하도록 했다.
- 서버 기능 공백은 요청서로 분리했다.
  - `docs/community-ban-user-search-api-request.md`

## Consequences
- 장점:
  - 운영 시트 UX 일관성 향상
  - UUID 미보유 상황에서도 조회 가능
- 단점:
  - 검색 정확도/성능이 현재는 클라이언트 보유 목록 크기에 의존
  - 서버 검색 API 제공 전까지 다건 결과 처리 UX 제약 존재

## Scope
- `/lib/features/feed/presentation/pages/board_page.dart`
- `/lib/features/feed/application/community_ban_view_helper.dart`
- `/lib/features/feed/data/dto/community_moderation_dto.dart`
- `/lib/features/feed/data/repositories/community_repository_impl.dart`
- `/lib/features/feed/domain/entities/community_moderation.dart`

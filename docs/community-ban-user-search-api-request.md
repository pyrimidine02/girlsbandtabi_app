# 커뮤니티 제재 사용자 검색 API 요청서

## 배경
- 현재 프로젝트 커뮤니티 제재 API는 아래 2개만 제공됩니다.
  - `GET /api/v1/projects/{projectCode}/moderation/bans`
  - `GET /api/v1/projects/{projectCode}/moderation/bans/{userId}`
- 운영 UI에서 `{userId}` 직접 입력 방식만으로는 실무 사용성이 낮습니다.
- 닉네임/이메일로 즉시 검색 가능한 서버 API가 필요합니다.

## 문제
- 운영자는 보통 사용자 UUID를 모르고, 닉네임/이메일만 알고 있는 경우가 많습니다.
- 현재는 전체 목록을 내려받아 클라이언트 필터링해야 해서 데이터가 많아질수록 비효율적입니다.
- 서버 단 검색/정렬/페이지네이션이 없어 운영 속도가 느립니다.

## 요청 사항 (권장안)
### 1) 제재 사용자 검색 엔드포인트 추가
- **GET** `/api/v1/projects/{projectCode}/moderation/bans:search`

Query Parameters:
- `q` (required): 검색어 (닉네임/이메일/사용자ID)
- `page` (optional, default `0`)
- `size` (optional, default `20`)
- `sort` (optional, default `createdAt,desc`)

응답 예시:
```json
{
  "success": true,
  "statusCode": 200,
  "data": [
    {
      "id": "ban-uuid",
      "projectId": "project-uuid",
      "bannedUser": {
        "id": "user-uuid",
        "displayName": "테스트유저",
        "email": "user@example.com",
        "avatarUrl": "https://..."
      },
      "moderatorUserId": "moderator-uuid",
      "reason": "SPAM",
      "createdAt": "2026-03-05T10:00:00Z",
      "expiresAt": null
    }
  ],
  "pagination": {
    "currentPage": 0,
    "pageSize": 20,
    "totalPages": 1,
    "totalItems": 1
  }
}
```

### 2) 기존 목록 API의 `bannedUser.email` 보장
- `GET /api/v1/projects/{projectCode}/moderation/bans` 응답의 `bannedUser.email` 필드를 포함/보장해 주세요.
- 프런트는 이메일 검색/필터 정확도를 높일 수 있습니다.

## 프런트 임시 대응 (이미 적용)
- 검색어가 UUID 형식이면 기존 상세 조회 API(`.../bans/{userId}`) 사용
- UUID가 아니면 현재 목록을 대상으로 닉네임/이메일/ID 클라이언트 필터링 수행
- 동명이인 등 다건 매치 시 목록 필터로 전환

## 기대 효과
- 운영자 검색 UX 개선 (UUID 미보유 상황 대응)
- 서버 단 검색으로 트래픽/응답 시간 절감
- 대규모 제재 데이터에서도 안정적 운영 가능

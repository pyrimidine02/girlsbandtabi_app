# 커뮤니티 실시간/알림 동기화 API 요청서

> **작성일**: 2026-03-05
> **작성자**: 클라이언트 팀
> **상태**: 구현 요청
> **우선순위**: Medium

---

## 배경

현재 앱은 커뮤니티 피드/알림 최신성을 위해 foreground 폴백 동기화(주기 리페치)를 적용했습니다.
하지만 이벤트 단위 실시간 반영(새 댓글/좋아요/팔로우/멘션/운영 알림)을 위해서는
서버 계약이 필요합니다.

---

## 요청 사항

### 1) 디바이스 토큰 등록/해제

#### `POST /api/v1/notifications/devices`

요청 예시:
```json
{
  "platform": "IOS",
  "token": "fcm-or-apns-token",
  "locale": "ko-KR",
  "timezone": "Asia/Seoul",
  "appVersion": "0.0.2",
  "buildNumber": "2026030501"
}
```

응답 예시:
```json
{
  "id": "device-registration-uuid",
  "platform": "IOS",
  "tokenHash": "...",
  "createdAt": "2026-03-05T15:00:00+09:00"
}
```

#### `DELETE /api/v1/notifications/devices/{deviceId}`
- 로그아웃/토큰 만료 시 등록 해제용.

---

### 2) 인앱 실시간 이벤트 스트림(선택)

#### WebSocket
- `GET /api/v1/realtime/community` (WebSocket upgrade)
- 인증: bearer token

이벤트 예시:
```json
{
  "eventType": "POST_COMMENT_CREATED",
  "projectId": "550e8400-e29b-41d4-a716-446655440001",
  "entityId": "comment-uuid",
  "postId": "post-uuid",
  "createdAt": "2026-03-05T15:10:00+09:00"
}
```

권장 `eventType`:
- `POST_CREATED`
- `POST_UPDATED`
- `POST_DELETED`
- `POST_LIKED`
- `POST_UNLIKED`
- `POST_COMMENT_CREATED`
- `POST_COMMENT_UPDATED`
- `POST_COMMENT_DELETED`
- `NOTIFICATION_CREATED`

---

### 3) 최소 폴백용 증분 조회 endpoint (소켓 미적용 시)

#### `GET /api/v1/community/changes?since={ISO-8601}`
- 클라이언트가 마지막 동기화 시각 이후 변경사항만 조회 가능하도록 요청.

응답 예시:
```json
{
  "serverTime": "2026-03-05T15:20:00+09:00",
  "changes": [
    {
      "eventType": "POST_COMMENT_CREATED",
      "entityId": "comment-uuid",
      "postId": "post-uuid",
      "createdAt": "2026-03-05T15:19:57+09:00"
    }
  ]
}
```

---

## 기대 효과

- 피드/알림 stale 시간 단축
- 불필요한 full-refresh 요청 감소
- 실시간 UX와 배터리/트래픽 효율 간 균형 확보

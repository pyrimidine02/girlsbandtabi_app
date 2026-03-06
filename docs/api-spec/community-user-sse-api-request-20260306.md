# 커뮤니티/알림 사용자 SSE API 요청서 (v1)

> 작성일: 2026-03-06  
> 작성자: Flutter Client Team  
> 상태: Backend 요청 필요  
> 우선순위: High

## 1) 배경

현재 앱은 커뮤니티/알림 최신성 유지를 위해 foreground polling을 사용합니다.
클라이언트는 SSE 연결 로직을 이미 반영했지만, 사용자용 SSE endpoint 계약이 확정되지 않아
실질적으로는 폴링 폴백이 계속 필요합니다.

## 2) 요청 Endpoint

### A. Community realtime stream
- `GET /api/v1/community/events/stream`
- Auth: `Authorization: Bearer <accessToken>`
- Response: `text/event-stream`

### B. Notifications realtime stream
- `GET /api/v1/notifications/stream`
- Auth: `Authorization: Bearer <accessToken>`
- Response: `text/event-stream`

## 3) 이벤트 포맷(권장)

SSE frame 예시:

```text
event: COMMUNITY_POST_CREATED
id: 8f6a2f8b-7e6f-4f0f-9c33-8cc4da8f118d
data: {"eventType":"COMMUNITY_POST_CREATED","projectCode":"girls-band-cry","entityId":"38f55757-6953-44d4-abb8-8ab0ec35003e","occurredAt":"2026-03-06T10:20:30Z"}

```

필수 필드:
- `eventType` (string)
- `entityId` (string)
- `occurredAt` (ISO-8601 UTC)

선택 필드:
- `projectCode` (string)
- `postId` (string)
- `commentId` (string)
- `notificationId` (string)
- `actorUserId` (string)

권장 이벤트 타입:
- Community: `COMMUNITY_POST_CREATED`, `COMMUNITY_POST_UPDATED`, `COMMUNITY_POST_DELETED`, `COMMUNITY_COMMENT_CREATED`, `COMMUNITY_COMMENT_UPDATED`, `COMMUNITY_COMMENT_DELETED`, `COMMUNITY_REACTION_CHANGED`
- Notifications: `NOTIFICATION_CREATED`, `NOTIFICATION_UPDATED`, `NOTIFICATION_READ`

## 4) 재연결/복구 계약

- `Last-Event-ID` 헤더 지원 요청
- 서버는 heartbeat comment(`: ping`) 주기적으로 전송
- 일시적 장애 시 `retry: <ms>` 힌트 제공
- 401/403 시 연결 종료 + 명확한 에러 응답

## 5) 운영/성능 요구

- 권장 idle timeout 명시 (예: 60~120s heartbeat 유지 시 연결 지속)
- 사용자당 동시 연결 제한 정책 문서화
- 이벤트 전송 보장 수준(At-most-once / At-least-once) 명시

## 6) 클라이언트 동작 기준

- SSE 연결 성공 시 주기 polling은 soft-skip
- SSE 실패/미지원 시 기존 polling 자동 fallback 유지
- 이벤트 수신 시 throttle refresh 수행 (과도한 burst 방지)

## 7) 확인 요청

1. 위 2개 endpoint 제공 가능 여부
2. 이벤트 타입 enum 확정안
3. `Last-Event-ID` 및 replay window(보관 시간) 지원 여부
4. 인증 만료/권한 오류 시 표준 응답 포맷

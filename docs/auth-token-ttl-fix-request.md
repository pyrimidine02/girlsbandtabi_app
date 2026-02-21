# 인증 토큰 TTL 개선 요청 (프런트 → 백엔드)

**작성일**: 2026-02-21
**우선순위**: High
**관련 증상**: 게시글 삭제 / 모든 인증 필요 액션이 5~6시간 비활성 후 무조건 실패

---

## 1. 문제 요약

앱을 백그라운드에 5시간 이상 두면 **refresh token이 만료**되어, 다음 액션 시도 시:

1. Access token 만료 → 서버 401
2. 인터셉터가 `/auth/refresh` 시도 → **서버 401** ("Refresh token expired or revoked")
3. 클라이언트가 강제 로그아웃 처리 → 사용자가 수행하려던 액션(삭제, 좋아요 등) 취소됨
4. 재로그인 후 수동으로 다시 시도해야 함

---

## 2. 로그 근거 (서버 로그 실측)

```
# 1차 발생 (컨테이너 12)
02:38:05  POST /api/v1/auth/refresh → 401  "Refresh token expired or revoked"

# 2차 발생 (컨테이너 10, 재기동 후)
03:17:22  POST /api/v1/auth/refresh → 200  ← 마지막 갱신 성공
03:32:22  Access token 만료 (JWT exp 클레임 기준, TTL = 15분 확인됨)
  ── 약 5시간 31분 비활성 ──
08:48:50  DELETE /api/v1/projects/.../posts/{id} → 401  (access token 만료)
08:48:54  POST /api/v1/auth/refresh → 401  "Refresh token expired or revoked"
08:49:05  POST /api/v1/auth/login  → 200  (재로그인)
08:49:12  POST /api/v1/auth/refresh → 401  (재로그인 직후 동시 요청 race condition)
08:49:20  POST /api/v1/auth/login  → 200  (재로그인 2차)
08:49:30  DELETE /api/v1/projects/.../posts/{id} → 204  ← 최종 성공
```

**JWT 만료 메시지 원문 (서버 DEBUG 로그)**:
```
JWT expired 18989187 milliseconds ago at 2026-02-20T18:32:22.000Z.
Current time: 2026-02-20T23:48:51.187Z. Allowed clock skew: 0 milliseconds.
```

→ Access token TTL **15분**, Refresh token TTL **실측 약 5시간 31분** (03:17 발급 → 08:48 만료 기준)

> **확인 요청**: `redis-cli -a <password> ttl refresh:*` 명령으로 설정된 실제 TTL 수치를 공유해주시면 정확한 근거로 교체하겠습니다.

---

## 3. 요청 사항

### 3-1. [필수] Refresh Token TTL 연장

| 항목 | 현재 | 요청값 |
|---|---|---|
| Access token TTL | 15분 | **변경 없음** (보안상 적절) |
| Refresh token TTL | ~5~6시간 | **7일** |

**근거**: 모바일 앱은 하루 이상 백그라운드 상태가 일반적입니다. 업계 표준 (Google, Kakao, Apple 등)은 refresh token을 7~30일로 운용합니다.

**환경변수 또는 Spring 설정 (단위 통일 필요 — 아래 중 택1)**:

```bash
# 옵션 A: 밀리초(ms) Long 타입
JWT_ACCESS_TOKEN_EXPIRATION_MS=900000       # 15분
JWT_REFRESH_TOKEN_EXPIRATION_MS=604800000   # 7일
```

```yaml
# 옵션 B: ISO-8601 Duration
jwt:
  access-token-expiration: PT15M   # 15분
  refresh-token-expiration: P7D    # 7일
```

> 백엔드 내부 바인딩 방식(Long ms vs Duration)에 맞는 옵션으로 적용해주세요. 키 이름에 단위(`-ms`)를 명시하거나 ISO-8601 표기를 사용하면 혼동을 방지할 수 있습니다.

**Refresh Token 응답 스키마 확인 요청**:

클라이언트는 `POST /api/v1/auth/refresh` 응답에서 다음 필드를 파싱합니다. 현재 응답이 아래 형식과 일치하는지 확인 부탁드립니다.

```json
// POST /api/v1/auth/refresh → 200 OK
{
  "success": true,
  "data": {
    "accessToken": "eyJ...",
    "refreshToken": "eyJ...",
    "expiresIn": 900,
    "tokenType": "Bearer"
  }
}
```

> `data` 래퍼 없이 flat 구조로 반환할 경우 클라이언트 파싱 오류가 발생하므로 현재 응답 구조를 공유해주시면 클라이언트 쪽에서 맞추겠습니다. 또한 **`expiresIn` 또는 `expiresAt` 필드를 항상 포함**해주시면 이후 선제적 토큰 갱신(silent refresh) 구현 시 활용할 수 있습니다.

**보안 고려사항**:
- TTL 연장으로 탈취 시 유효 창이 넓어지므로 아래 사항 확인을 요청합니다.
  - 로그아웃 시 해당 refresh token을 Redis에서 즉시 revoke하는지 여부
  - 멀티 디바이스 지원 여부: Redis key가 `refresh:{userId}` 단일 키라면 기기 2에서 로그인 시 기기 1의 토큰이 덮어씌워짐. `refresh:{jti}` 또는 `refresh:{userId}:{deviceId}` 기반 키를 권장합니다.

---

### 3-2. [필수] Refresh Token 오류 응답 코드 표준화

현재 refresh 실패 시 응답 body의 `error.code`가 일관되지 않아, 클라이언트 인터셉터가 **갱신 실패와 일반 인증 오류를 구분하지 못합니다**.

**요청**: `POST /api/v1/auth/refresh` 실패 시 아래 형식 준수

```http
HTTP/1.1 401 Unauthorized
Content-Type: application/json

{
  "success": false,
  "statusCode": 401,
  "error": {
    "code": "REFRESH_TOKEN_EXPIRED",
    "message": "Refresh token has expired. Please login again."
  }
}
```

**에러 코드 및 HTTP 상태 코드 매핑표** (클라이언트 분기 기준):

| HTTP 상태 | error.code | 의미 | 클라이언트 처리 |
|---|---|---|---|
| `401` | `REFRESH_TOKEN_EXPIRED` | 만료 | 세션 파기 → 로그아웃 |
| `401` | `REFRESH_TOKEN_REVOKED` | 서버 측 강제 폐기 | 세션 파기 → 로그아웃 |
| `400` | `INVALID_REFRESH_TOKEN` | 위변조 / 형식 오류 | 세션 파기 → 로그아웃 |
| `400` | `REFRESH_TOKEN_ALREADY_USED` | Rotation 중복 감지 (3-3절 참조) | 세션 파기 또는 재시도 |
| `401` | `TOKEN_EXPIRED` | 일반 만료 폴백 | 세션 파기 → 로그아웃 |
| `401` | `AUTHENTICATION_FAILED` | 인증 실패 | 세션 파기 → 로그아웃 |

> **중요**: `REFRESH_TOKEN_REVOKED`는 반드시 `401`로 반환해주세요. `400`으로 반환될 경우 클라이언트가 일시적 오류로 오분류해 세션을 파기하지 않을 수 있습니다.

> RFC 6750 참고: `401` 응답에 `WWW-Authenticate: Bearer error="invalid_token"` 헤더를 포함하면 표준 준수가 됩니다. 필수 요건은 아니지만 향후 확장성을 위해 권장합니다.

---

### 3-3. [필수] Refresh Token Rotation 동시 요청 처리

**현상 재현**: 재로그인(08:49:05) 직후 **7초 만에** 다시 `POST /auth/refresh → 401` (08:49:12).

**원인**: 여러 화면이 동시에 401을 받아 각각 refresh를 시도하는 race condition입니다. 클라이언트 인터셉터가 `_refreshFuture` 단일 Future로 중복 요청을 deduplication하고 있으나, 컨테이너 재기동 직후 빈 토큰 상태에서 여러 화면이 동시에 API를 호출하는 경우를 완전히 차단하지 못합니다. 이 상황에서 첫 번째 refresh 성공 후 rotate된 이전 토큰으로 두 번째 요청이 들어오면 서버가 401을 반환합니다.

**서버 측 요청** (아래 두 옵션 중 하나):

**[옵션 A — 권장] Idempotency Window**

같은 refresh token으로 30초 이내 중복 요청이 들어오면 **새로 발급한 토큰 쌍을 동일하게 반환**합니다. 즉, 이미 rotate한 응답을 캐싱하여 재전송합니다.

```
Redis 예시:
SET refresh:idempotency:{old_refresh_token_jti} {new_token_pair_json} EX 30
```

단, 이 방식은 30초 window 동안 두 클라이언트가 동시에 새 토큰을 받을 수 있으므로, **이를 허용하는 정책**임을 팀 내에서 확인 후 적용해주세요.

**[옵션 B — 보안 우선]** 이미 rotate된 이전 refresh token으로 요청이 오면 해당 사용자의 모든 refresh token을 즉시 revoke하고 `REFRESH_TOKEN_ALREADY_USED (400)` 반환. (RFC 6819 section 5.2.2 준수)

> 이 항목이 `[선택]`으로 보일 수 있으나, 재로그인 직후 즉시 재현되는 문제이므로 **[필수]**로 처리를 요청합니다.

---

## 4. 영향 범위

| 영향 | 내용 |
|---|---|
| **Redis** | Refresh token TTL 변경 — 기존 세션에는 소급 적용되지 않으며, 재로그인 후 새 TTL 적용 |
| **멀티 디바이스** | Redis key 구조가 `refresh:{userId}` 단일 키라면 기기별 독립 세션 불가 → key 구조 검토 필요 |
| **보안** | TTL 연장에 따른 탈취 위험 창 증가 → 로그아웃 시 즉시 revoke, Secure Storage 전송 유지로 완화 |
| **관리자 강제 로그아웃** | 관리자가 특정 사용자 토큰을 revoke해도 access token 만료(최대 15분)까지 요청이 통과됨. 현재 수용 가능한 범위로 판단 |
| **클라이언트** | 에러 코드 표준화(3-2절) 외 추가 코드 변경 없음 |

---

## 5. 권장 배포 순서

에러 코드를 먼저 표준화하지 않고 TTL만 늘리면, 클라이언트가 refresh 실패 원인을 구분하지 못해 불필요한 강제 로그아웃이 발생할 수 있습니다.

```
1단계: 에러 응답 코드 표준화 (3-2절) — 클라이언트 호환성 확인 후
2단계: Refresh Token TTL 연장 (3-1절)
3단계: Idempotency window 또는 ALREADY_USED 감지 (3-3절)
```

---

## 6. 검증 방법

| # | 검증 내용 | 기대 결과 |
|---|---|---|
| 1 | 로그인 후 6시간 경과 후 게시글 삭제 시도 | 재로그인 없이 `204` 반환 |
| 2 | `POST /api/v1/auth/refresh` 의도적 만료 후 호출 | `error.code: "REFRESH_TOKEN_EXPIRED"` 포함 |
| 3 | `redis-cli ttl refresh:*` | 약 `604800`초 |
| 4 | Rotate된 이전 refresh token으로 재요청 | Idempotency 적용 시: 동일한 새 토큰 반환 / B안 적용 시: `REFRESH_TOKEN_ALREADY_USED 400` |
| 5 | 동일 계정 두 기기 동시 로그인 | 각 기기 독립 세션 유지 여부 확인 |
| 6 | 로그아웃 후 저장된 refresh token으로 `/auth/refresh` 호출 | `REFRESH_TOKEN_REVOKED 401` 반환 |

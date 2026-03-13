# 모바일 앱 프런트엔드 연동 요청서

## 문서 기본 정보

| 항목 | 값 |
|---|---|
| 문서명 | 칭호(Title) 시스템 모바일 연동 요청서 |
| 문서 ID | FE-REQ-TITLE-SYSTEM-20260313 |
| 문서 버전 | v1.0.0 |
| 작성일 | 2026-03-13 |
| 작성/요청 | Backend API Team |
| 수신 대상 | Mobile App Team |
| 우선순위 | Medium |
| 적용 릴리즈 | Title System v1 |
| API Base Path | `/api/v1` |

## 개정 이력

| 버전 | 날짜 | 변경 내용 | 작성자 |
|---|---|---|---|
| v1.0.0 | 2026-03-13 | 칭호 카탈로그/활성 칭호 관리/타인 프로필 칭호 조회 API 신규 추가 | Backend API Team |

---

## 1. 요청 배경

유저 활동(장소 방문, 라이브 참석)에 따라 자동으로 칭호가 부여되는 시스템이 추가되었습니다.
유저는 획득한 칭호 중 하나를 **프로젝트별로 독립적으로** 활성 칭호로 지정할 수 있으며,
타인의 프로필에서도 그 유저의 활성 칭호를 볼 수 있습니다.

---

## 2. 목표

1. 칭호 카탈로그 화면 — 획득 가능한 칭호 전체 목록과 내 획득 상태, 활성 여부 표시
2. 내 프로필 — 현재 활성 칭호 배지 표시 및 칭호 선택/해제 UI
3. 타인 프로필 — 상대방의 활성 칭호 배지 표시
4. Push 알림 — 칭호 자동 부여 시 표시 이름으로 알림

---

## 3. 핵심 개념

### 3.1 칭호 카테고리 (TitleCategory)

| 값 | 설명 |
|---|---|
| `ACTIVITY` | 장소 방문/라이브 참석 등 활동 기반 |
| `COMMEMORATIVE` | 기념 칭호 (프로젝트 1주년 등) |
| `EVENT` | 이벤트 한정 칭호 |
| `ADMIN` | 운영자 수동 부여 칭호 |

### 3.2 프로젝트 스코프

- 칭호 자체가 **전체 공통** 또는 **프로젝트 전용**으로 구분됩니다.
- 유저는 **프로젝트 컨텍스트별로 독립적인** 활성 칭호를 지정합니다.
  - 예: GBP 프로젝트에서는 "성지 개척자", 앱 홈에서는 "첫 라이브 참전" 설정 가능
- `projectKey` 파라미터를 생략하면 **앱 홈(전체 컨텍스트)** 기준입니다.

### 3.3 칭호 자동 부여 흐름

```
유저가 장소 방문 / 라이브 참석
    → 서버가 업적 조건 평가
    → 조건 달성 시 해당 칭호 자동 부여
    → Push 알림 발송: "칭호 {칭호표시명}을(를) 획득했습니다!"
    → 이후 유저가 원하면 활성 칭호로 지정
```

유저가 직접 특정 행동을 해서 칭호를 획득하는 것이 아니라, **서버가 자동으로 판단해 부여**합니다.
앱에서 별도로 칭호 획득 요청 API를 호출할 필요가 없습니다.

---

## 4. API 계약 요약

| 구분 | Method | Path | Auth | 목적 |
|---|---|---|---|---|
| 칭호 카탈로그 | `GET` | `/titles` | 선택 | 전체 칭호 목록 조회 (인증 시 획득/활성 여부 포함) |
| 내 활성 칭호 조회 | `GET` | `/users/me/title` | 필수 | 내 현재 활성 칭호 조회 |
| 내 활성 칭호 설정 | `PUT` | `/users/me/title` | 필수 | 활성 칭호 변경 |
| 내 활성 칭호 해제 | `DELETE` | `/users/me/title` | 필수 | 활성 칭호 초기화 |
| 타인 활성 칭호 조회 | `GET` | `/users/{userId}/title` | 불필요 | 타인의 현재 활성 칭호 조회 |

---

## 5. 상세 API 명세

### 5.1 칭호 카탈로그 조회

```
GET /api/v1/titles?projectKey={projectKey}
```

| 파라미터 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `projectKey` | `string` | N | 프로젝트 slug 또는 UUID. 생략 시 전체(공통) 칭호만 반환 |

**응답 예시 (HTTP 200, 인증 상태)**

```json
{
  "success": true,
  "statusCode": 200,
  "data": [
    {
      "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "code": "FIRST_VISIT",
      "name": "성지에 첫 발을 디디다",
      "description": "첫 번째 성지 방문을 인증했습니다.",
      "category": "ACTIVITY",
      "projectId": null,
      "sortOrder": 10,
      "isEarned": true,
      "isActive": false
    },
    {
      "id": "b2c3d4e5-f6a7-8901-bcde-f01234567891",
      "code": "PIONEER",
      "name": "성지 개척자",
      "description": "100개 이상의 성지를 방문했습니다.",
      "category": "ACTIVITY",
      "projectId": null,
      "sortOrder": 40,
      "isEarned": false,
      "isActive": false
    }
  ],
  "error": null,
  "metadata": {
    "requestId": "req_1741830000000_0001",
    "timestamp": "2026-03-13T10:00:00Z",
    "version": "v1"
  },
  "pagination": null
}
```

**비인증 상태일 때** `isEarned`와 `isActive`는 `null`로 내려옵니다.

`data[]` 필드 정의:

| 필드 | 타입 | nullable | 설명 |
|---|---|---|---|
| `id` | `string(uuid)` | N | 칭호 고유 ID |
| `code` | `string` | N | 시스템 식별 코드 (예: `FIRST_VISIT`, `PIONEER`) |
| `name` | `string` | N | 표시 이름 (예: 성지 개척자) |
| `description` | `string` | Y | 획득 조건 설명 |
| `category` | `string` | N | `ACTIVITY` \| `COMMEMORATIVE` \| `EVENT` \| `ADMIN` |
| `projectId` | `string(uuid)` | Y | `null` = 전체 공통, non-null = 해당 프로젝트 전용 |
| `sortOrder` | `int` | N | 목록 정렬 순서 (오름차순) |
| `isEarned` | `boolean` | Y | 현재 유저가 보유 중이면 `true` (비인증 시 `null`) |
| `isActive` | `boolean` | Y | 현재 프로젝트 컨텍스트에서 활성 칭호이면 `true` (비인증 시 `null`) |

---

### 5.2 내 활성 칭호 조회

```
GET /api/v1/users/me/title?projectKey={projectKey}
Authorization: Bearer {accessToken}
```

| 파라미터 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `projectKey` | `string` | N | 생략 시 전체(앱 홈) 컨텍스트 기준 |

**응답 예시 (HTTP 200, 활성 칭호 있음)**

```json
{
  "success": true,
  "statusCode": 200,
  "data": {
    "titleId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "code": "FIRST_VISIT",
    "name": "성지에 첫 발을 디디다",
    "description": "첫 번째 성지 방문을 인증했습니다.",
    "category": "ACTIVITY"
  },
  "error": null,
  "metadata": { "requestId": "...", "timestamp": "...", "version": "v1" },
  "pagination": null
}
```

**활성 칭호 미설정 시: HTTP 204 No Content** (body 없음)

`data` 필드 정의:

| 필드 | 타입 | nullable | 설명 |
|---|---|---|---|
| `titleId` | `string(uuid)` | N | 칭호 ID |
| `code` | `string` | N | 시스템 코드 |
| `name` | `string` | N | 표시 이름 |
| `description` | `string` | Y | 설명 |
| `category` | `string` | N | 카테고리 |

---

### 5.3 내 활성 칭호 설정

```
PUT /api/v1/users/me/title?projectKey={projectKey}
Authorization: Bearer {accessToken}
Content-Type: application/json
```

**요청 본문**

```json
{
  "titleId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `titleId` | `string(uuid)` | Y | 활성화할 칭호 ID (획득한 칭호여야 함) |

**성공 응답: HTTP 200** — `GET /users/me/title`과 동일한 `ActiveTitleItem` 반환

**오류 응답:**

| HTTP | 케이스 |
|---|---|
| 400 | `titleId` 포맷이 UUID가 아닌 경우 |
| 403 | 해당 칭호를 아직 획득하지 않은 경우 |
| 404 | 존재하지 않거나 비활성화된 칭호 |

---

### 5.4 내 활성 칭호 해제

```
DELETE /api/v1/users/me/title?projectKey={projectKey}
Authorization: Bearer {accessToken}
```

**성공 응답: HTTP 204 No Content**

멱등적입니다. 이미 활성 칭호가 없어도 204를 반환합니다.

---

### 5.5 타인 활성 칭호 조회

```
GET /api/v1/users/{userId}/title?projectKey={projectKey}
```

인증 불필요, 공개 엔드포인트입니다.

| 파라미터 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `userId` | `string(uuid)` | Y | 조회할 유저 ID |
| `projectKey` | `string` | N | 생략 시 전체(앱 홈) 컨텍스트 기준 |

**응답: HTTP 200** — `GET /users/me/title`과 동일한 `ActiveTitleItem` 반환

| HTTP | 케이스 |
|---|---|
| 204 | 해당 유저가 활성 칭호를 설정하지 않은 경우 |
| 404 | `userId`가 UUID 형식이 아닌 경우 |

---

## 6. 오류 응답 공통 형식

```json
{
  "success": false,
  "statusCode": 403,
  "data": null,
  "error": {
    "code": "FORBIDDEN",
    "message": "Title has not been earned by this user"
  },
  "metadata": { "requestId": "...", "timestamp": "...", "version": "v1" },
  "pagination": null
}
```

---

## 7. Push 알림 — 칭호 자동 부여

칭호가 자동으로 부여되면 서버가 Push 알림을 발송합니다.

| 항목 | 값 |
|---|---|
| 알림 제목 | `칭호 획득!` (또는 기존 알림 헤더 정책 따름) |
| 알림 본문 | `"성지에 첫 발을 디디다" 칭호를 획득했습니다!` |
| 딥링크 | 칭호 목록 화면 (`/titles`) 또는 프로필 화면 |

앱에서는 알림 수신 시 칭호 목록 또는 프로필 화면으로 이동하는 딥링크를 처리해 주세요.

---

## 8. 화면별 연동 가이드

### 8.1 칭호 목록 화면

```
진입 시 → GET /api/v1/titles?projectKey={현재 프로젝트}
    인증 상태라면 isEarned / isActive 포함

표시 구분:
  - isEarned=true  → 획득 완료 (활성 선택 가능)
  - isEarned=false → 미획득 (잠김 상태)
  - isActive=true  → 현재 활성 칭호 (강조 표시)

칭호 선택 → PUT /api/v1/users/me/title?projectKey={현재 프로젝트}
    성공 시 해당 칭호 isActive=true로 로컬 상태 업데이트

칭호 해제 → DELETE /api/v1/users/me/title?projectKey={현재 프로젝트}
```

### 8.2 내 프로필 화면

```
진입 시 → GET /api/v1/users/me/title?projectKey={현재 프로젝트}
    200: 칭호 배지 표시 (name 기준)
    204: "칭호 미설정" 또는 배지 숨김
```

### 8.3 타인 프로필 화면

```
진입 시 → GET /api/v1/users/{targetUserId}/title?projectKey={현재 프로젝트}
    200: 칭호 배지 표시
    204: 배지 숨김 (칭호 미설정)
```

### 8.4 프로젝트 컨텍스트 처리

| 화면 위치 | projectKey 값 |
|---|---|
| 특정 프로젝트(GBP 등) 내부 | 해당 프로젝트 slug (예: `gbp`) |
| 앱 홈, 전체 피드 등 | 파라미터 생략 (전체 컨텍스트) |

---

## 9. 수용 기준 (Acceptance Criteria)

- [ ] 비인증 상태에서 `GET /titles`를 호출하면 `isEarned=null`, `isActive=null`로 정상 응답한다.
- [ ] 인증 상태에서 `GET /titles`를 호출하면 획득한 칭호는 `isEarned=true`로 표시된다.
- [ ] 활성 칭호가 없을 때 `GET /users/me/title`은 204를 반환하고 앱이 빈 상태를 처리한다.
- [ ] 획득하지 않은 칭호를 `PUT /users/me/title`로 지정 시도하면 403을 받고 UI에서 처리한다.
- [ ] `DELETE /users/me/title` 호출 후 프로필에서 칭호 배지가 사라진다.
- [ ] 타인 프로필에서 `GET /users/{userId}/title`이 정상 호출되고 배지가 표시된다.
- [ ] 칭호 자동 부여 Push 알림 수신 시 딥링크가 올바른 화면으로 이동한다.
- [ ] 프로젝트 컨텍스트(`projectKey`)가 다른 경우 각각 독립적인 활성 칭호를 보여준다.

---

## 10. QA 테스트 케이스

| ID | 시나리오 | 절차 | 기대 결과 |
|---|---|---|---|
| TC-01 | 비인증 카탈로그 조회 | 로그인 없이 `GET /titles` | 200, `isEarned/isActive=null` |
| TC-02 | 인증 카탈로그 조회 | 로그인 후 `GET /titles` | 200, 획득 칭호 `isEarned=true` |
| TC-03 | 활성 칭호 미설정 조회 | 칭호 미설정 계정으로 `GET /users/me/title` | 204 No Content |
| TC-04 | 활성 칭호 설정 | 획득한 칭호 ID로 `PUT /users/me/title` | 200, ActiveTitleItem 반환 |
| TC-05 | 미획득 칭호 설정 시도 | 미획득 칭호 ID로 `PUT /users/me/title` | 403 반환, 오류 UI 표시 |
| TC-06 | 활성 칭호 해제 | `DELETE /users/me/title` | 204, 이후 조회 시 204 |
| TC-07 | 타인 프로필 칭호 | 타인 userId로 `GET /users/{userId}/title` | 200 또는 204 |
| TC-08 | 프로젝트별 독립 설정 | GBP 컨텍스트와 전체 컨텍스트에서 각각 다른 칭호 설정 | 각 컨텍스트 독립 반환 확인 |
| TC-09 | Push 알림 수신 | 장소 방문 조건 달성 시 Push 수신 | 칭호 표시 이름이 알림 본문에 포함 |
| TC-10 | 비활성 칭호 설정 시도 | 관리자가 비활성화한 칭호 ID로 `PUT /users/me/title` | 404 반환 |

---

## 11. 구현 참고 경로 (백엔드)

| 파일 | 설명 |
|---|---|
| `server/.../identity/user/gateway/TitleController.kt` | `GET /api/v1/titles` |
| `server/.../identity/user/gateway/UserTitleController.kt` | `/api/v1/users/me/title`, `/api/v1/users/{userId}/title` |
| `server/.../identity/user/service/TitleService.kt` | `TitleCatalogItem`, `ActiveTitleItem` DTO 정의 |
| `server/.../db/migration/V107__create_title_tables.sql` | 스키마 정의 |

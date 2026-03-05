# 인증 이의제기 API 엔드포인트 요청서

> **작성일**: 2026-03-05
> **작성자**: 클라이언트 팀
> **상태**: 구현 요청 대기 중
> **우선순위**: Medium

---

## 배경 및 목적

현재 앱은 NFC/GPS 기반 현장 인증(장소 방문 인증, 라이브 이벤트 출석 인증)을 지원합니다.
인증은 기기에서 서명된 JWS 토큰을 서버로 전송하는 방식으로 이루어지며, 다음 이유로 인해 실패할 수 있습니다:

- GPS 오차 (실제로 현장에 있었으나 위치 정확도가 불충분)
- 시간 창 만료 (이동 중 네트워크 지연)
- 토큰 서명 오류 (기기 키 불일치)

사용자가 정당하게 현장에 있었음에도 인증이 실패한 경우, **이의제기(Appeal)** 를 통해 수동 검토를 요청할 수 있어야 합니다.

클라이언트는 실패한 인증 시도를 **기기 로컬에 30일간** 보관하고, 그 기록을 바탕으로 이의제기를 제출합니다.

---

## 데이터 모델

### VerificationAppeal (이의제기)

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `id` | UUID | 서버 생성 | 이의제기 고유 ID |
| `userId` | UUID | 서버 추출 | 요청자 (JWT에서 추출) |
| `projectId` | UUID | 필수 | 소속 프로젝트 |
| `targetType` | enum | 필수 | `PLACE_VISIT` \| `LIVE_EVENT` |
| `targetId` | string | 필수 | 대상 ID — `PLACE_VISIT`이면 `placeId`, `LIVE_EVENT`이면 `liveEventId` |
| `reason` | enum | 필수 | 아래 Reason 목록 참조 |
| `description` | string | 선택 | 사용자 상세 설명 (max 1000자) |
| `evidenceUrls` | string[] | 선택 | 첨부 이미지 URL 목록 (업로드 API 활용) |
| `attemptedAt` | ISO 8601 | 필수 | 클라이언트가 기록한 실패 시각 |
| `status` | enum | 서버 생성 | `PENDING` \| `UNDER_REVIEW` \| `APPROVED` \| `REJECTED` |
| `reviewerMemo` | string | 선택 | 검토자 메모 (검토 후 채워짐) |
| `reviewedBy` | UUID | 선택 | 검토한 관리자 ID |
| `createdAt` | ISO 8601 | 서버 생성 | 이의제기 생성 시각 |
| `resolvedAt` | ISO 8601 | 선택 | 처리 완료 시각 |

#### Reason 열거형

| 값 | 설명 |
|----|------|
| `FALSE_REJECTION` | 오탐 거절 (현장에 있었으나 거절됨) |
| `GPS_INACCURACY` | GPS 오차로 인한 실패 |
| `NETWORK_ISSUE` | 네트워크 문제로 인한 실패 |
| `DEVICE_ISSUE` | 기기 문제 (시계 오차, 키 불일치 등) |
| `LOCATION_ERROR` | 위치 정보 오류 |
| `OTHER` | 기타 |

---

## 엔드포인트 목록

### 8.X 인증 이의제기 (Verification Appeals)

기본 경로: `/api/v1/projects/{projectId}/verification-appeals`

> **참고**: 이미 `api_constants.dart`에 경로 상수가 선언되어 있습니다.
> - `verificationAppeals(projectId)` → `/api/v1/projects/{projectId}/verification-appeals`
> - `verificationAppeal(projectId, appealId)` → `/api/v1/projects/{projectId}/verification-appeals/{appealId}`

---

### 8.X.1 이의제기 제출

```
POST /api/v1/projects/{projectId}/verification-appeals
```

**권한**: 인증된 사용자 (프로젝트 멤버)

**Request Body** (application/json):
```json
{
  "targetType": "PLACE_VISIT",
  "targetId": "place-uuid-here",
  "reason": "GPS_INACCURACY",
  "description": "당시 건물 내부라 GPS 신호가 불안정했습니다.",
  "evidenceUrls": ["https://cdn.example.com/evidence/img1.jpg"],
  "attemptedAt": "2026-03-04T14:23:00+09:00"
}
```

**Response 201 Created**:
```json
{
  "id": "appeal-uuid",
  "projectId": "project-uuid",
  "targetType": "PLACE_VISIT",
  "targetId": "place-uuid-here",
  "reason": "GPS_INACCURACY",
  "description": "당시 건물 내부라 GPS 신호가 불안정했습니다.",
  "evidenceUrls": ["https://cdn.example.com/evidence/img1.jpg"],
  "attemptedAt": "2026-03-04T14:23:00+09:00",
  "status": "PENDING",
  "reviewerMemo": null,
  "createdAt": "2026-03-05T10:00:00+09:00",
  "resolvedAt": null
}
```

**에러**:
| 코드 | 사유 |
|------|------|
| 400 | 필수 필드 누락 또는 유효하지 않은 targetType/reason |
| 403 | 프로젝트 멤버가 아닌 경우 |
| 404 | projectId 또는 targetId 미존재 |
| 409 | 동일 targetId에 대해 PENDING/UNDER_REVIEW 상태의 이의제기 이미 존재 |

---

### 8.X.2 내 이의제기 목록 조회

```
GET /api/v1/projects/{projectId}/verification-appeals
```

**권한**: 인증된 사용자 (본인 이의제기만 반환)

**Query Parameters**:
| 파라미터 | 타입 | 기본값 | 설명 |
|---------|------|--------|------|
| `page` | int | 0 | 페이지 번호 |
| `size` | int | 20 | 페이지 크기 |
| `status` | string | (전체) | 상태 필터 (`PENDING`, `UNDER_REVIEW`, `APPROVED`, `REJECTED`) |
| `targetType` | string | (전체) | 유형 필터 (`PLACE_VISIT`, `LIVE_EVENT`) |

**Response 200 OK**:
```json
{
  "content": [
    {
      "id": "appeal-uuid",
      "projectId": "project-uuid",
      "targetType": "PLACE_VISIT",
      "targetId": "place-uuid",
      "reason": "GPS_INACCURACY",
      "status": "PENDING",
      "createdAt": "2026-03-05T10:00:00+09:00",
      "resolvedAt": null
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 1,
  "totalPages": 1
}
```

---

### 8.X.3 이의제기 상세 조회

```
GET /api/v1/projects/{projectId}/verification-appeals/{appealId}
```

**권한**: 인증된 사용자 (본인 것만) 또는 MODERATOR 이상

**Response 200 OK**: `8.X.1` 응답과 동일한 전체 DTO

**에러**:
| 코드 | 사유 |
|------|------|
| 403 | 본인 이의제기가 아닌 경우 (MODERATOR 제외) |
| 404 | 이의제기 미존재 |

---

### 8.X.4 이의제기 취소 (PENDING 상태만 가능)

```
DELETE /api/v1/projects/{projectId}/verification-appeals/{appealId}
```

**권한**: 인증된 사용자 (본인 것만)

**Response 204 No Content**

**에러**:
| 코드 | 사유 |
|------|------|
| 400 | PENDING이 아닌 상태 (이미 검토 중이거나 처리 완료) |
| 403 | 본인 이의제기가 아닌 경우 |
| 404 | 이의제기 미존재 |

---

### 8.X.5 이의제기 검토 (관리자/모더레이터 전용)

```
PATCH /api/v1/projects/{projectId}/verification-appeals/{appealId}/review
```

**권한**: MODERATOR 이상

**Request Body**:
```json
{
  "decision": "APPROVED",
  "reviewerMemo": "현장 CCTV 기록 확인 후 승인 처리합니다."
}
```

`decision` 값: `APPROVED` | `REJECTED`

**동작**:
- `APPROVED` 시: 서버가 해당 장소/이벤트에 대해 수동으로 인증 기록을 생성합니다.
- `REJECTED` 시: 이의제기 상태만 REJECTED로 변경합니다.

**Response 200 OK**: 업데이트된 전체 DTO

---

### 8.X.6 이의제기 목록 조회 (관리자 전용)

```
GET /api/v1/projects/{projectId}/admin/verification-appeals
```

**권한**: MODERATOR 이상

**Query Parameters**: `8.X.2`와 동일, 추가로 `userId` 필터 지원

**Response 200 OK**: `8.X.2`와 동일한 페이지네이션 응답

---

## 추가 고려 사항

### 1. 중복 이의제기 방지
동일 `targetId`에 대해 `PENDING` 또는 `UNDER_REVIEW` 상태인 이의제기가 이미 존재하면 `409 Conflict`를 반환합니다.
클라이언트는 이의제기 목록 조회 시 `targetId` 기반으로 중복 여부를 사전 확인할 수 있습니다.

### 2. APPROVED 처리 시 인증 기록 자동 생성
`APPROVED` 처리 시 서버는 해당 사용자의 `PLACE_VISIT` 또는 `LIVE_EVENT` 인증 기록을 생성해야 합니다.
`attemptedAt` 값을 인증 시각으로 사용하는 것을 권장합니다.

### 3. 알림 연동
이의제기 상태 변경 시 (`APPROVED`, `REJECTED`) 푸시 알림을 전송하는 것을 권장합니다.
기존 알림 시스템 (`/api/v1/notifications`)을 활용합니다.

### 4. 이의제기 횟수 제한 (Rate Limiting)
악용 방지를 위해 사용자당 동시 `PENDING` 이의제기 수를 제한하는 것을 권장합니다.
제안: 프로젝트당 최대 5건 동시 PENDING.

### 5. `attemptedAt` 신뢰성
`attemptedAt`은 클라이언트가 제공하는 값입니다.
서버는 이 값이 현재 시각으로부터 30일 이내인지 검증하고, 미래 시각은 거부합니다.

---

## 클라이언트 구현 현황

| 항목 | 상태 | 위치 |
|------|------|------|
| 실패 기록 로컬 저장 (`FailedVerificationAttempt`) | ✅ 완료 | `lib/features/verification/domain/entities/` |
| 로컬 저장 서비스 (`FailedAttemptService`) | ✅ 완료 | `lib/features/verification/application/` |
| 인증 실패 시 자동 기록 (`VerificationController`) | ✅ 완료 | `lib/features/verification/application/` |
| 이의제기 제출 UI (`AccountToolsPage`) | ✅ 완료 | `lib/features/settings/presentation/pages/` |
| 이의제기 대상 선택 (실패 기록 피커) | ✅ 완료 | 위 동일 |
| API 연동 (`SettingsController` → 서버 전송) | ⏳ 백엔드 구현 후 | - |
| 이의제기 목록 서버 조회 | ⏳ 백엔드 구현 후 | - |
| APPROVED 시 방문 기록 자동 갱신 | ⏳ 백엔드 구현 후 | - |

---

## 요청 사항 요약

1. **`POST /api/v1/projects/{projectId}/verification-appeals`** — 이의제기 제출 (최우선)
2. **`GET /api/v1/projects/{projectId}/verification-appeals`** — 내 이의제기 목록 (최우선)
3. **`GET /api/v1/projects/{projectId}/verification-appeals/{appealId}`** — 상세 조회
4. **`DELETE /api/v1/projects/{projectId}/verification-appeals/{appealId}`** — 취소
5. **`PATCH /api/v1/projects/{projectId}/verification-appeals/{appealId}/review`** — 검토 (관리자)
6. **`GET /api/v1/projects/{projectId}/admin/verification-appeals`** — 관리자 목록

1~2번이 클라이언트 릴리스 필수 사항입니다.

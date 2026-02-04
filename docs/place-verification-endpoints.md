# 장소 인증 엔드포인트 스키마 (Frontend)

## 범위
- 위치 기반 장소 방문 인증 + 관련 메타 엔드포인트.
- Base Path: `/api/v1`
- 응답 래퍼: `ApiResponse<T>` (모든 엔드포인트 공통)

## 공통 응답 래퍼

### ApiResponse<T>
| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `success` | boolean | Y | 성공 여부 |
| `statusCode` | number | Y | HTTP 상태 코드 |
| `data` | T or null | Y | 성공 시 데이터 |
| `error` | ErrorDetail or null | Y | 실패 시 오류 상세 |
| `metadata` | ResponseMetadata | Y | 요청 추적 메타데이터 |
| `pagination` | PaginationInfo or null | Y | 페이지네이션(해당 시) |

### ErrorDetail
| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `code` | string | Y | 오류 코드 (예: `VERIFICATION_FAILED`) |
| `message` | string | Y | 사용자 메시지 |
| `details` | object | Y | 추가 상세 정보 |
| `fieldErrors` | FieldError[] | Y | 필드 단위 오류 목록 |
| `type` | string or null | N | 문제 유형 URI |
| `instance` | string or null | N | 문제 인스턴스 URI |
| `recoveryActions` | string[] | Y | 복구 힌트 |
| `retryInfo` | RetryInfo or null | N | 재시도 정보 |

### ResponseMetadata
| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `requestId` | string | Y | 요청 식별자 |
| `timestamp` | string (ISO-8601) | Y | 응답 시각 |
| `version` | string | Y | API 버전 (`v1`) |
| `processingTimeMs` | number or null | N | 처리 시간(ms) |
| `correlationId` | string or null | N | 분산 추적 ID |
| `serverId` | string or null | N | 서버 인스턴스 ID |

## 스키마

### VerificationRequest
> **요구사항**: `token` 또는 `latitude` + `longitude` 중 하나는 반드시 필요합니다.

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `token` | string or null | N | 위치 토큰(JWE). 제공 시 우선 사용됨 |
| `latitude` | number or null | N | 위도 (token 없이 테스트 시 사용) |
| `longitude` | number or null | N | 경도 (token 없이 테스트 시 사용) |
| `accuracy` | number or null | N | 정확도(m). 낮을수록 정확 |
| `verificationMethod` | string or null | N | 검증 방식 힌트 (예: `MANUAL`) |
| `evidence` | string or null | N | 증빙 데이터(예약 필드) |

### VerificationConfigDto
| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `jweAlg` | string | Y | JWE 알고리즘 (`RSA-OAEP-256` 또는 `dir`) |
| `jwsAlg` | string | Y | JWS 알고리즘 (`RS256` 또는 `none`) |
| `publicKeys` | string[] | Y | JWS 검증 공개키(PEM) 목록 |
| `toleranceMeters` | number | Y | 허용 거리(m) |
| `timeSkewSec` | number | Y | 허용 시간 오차(초) |

### ChallengeDto
| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `nonce` | string | Y | 챌린지 nonce |
| `expiresAt` | string (ISO-8601) | Y | 만료 시각 |

### VisitSuccessResponse
| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `placeId` | string | Y | 장소 UUID |
| `result` | string | Y | 결과 (`VERIFIED`) |

### AttendanceSuccessResponse
| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `liveEventId` | string | Y | 라이브 이벤트 UUID |
| `result` | string | Y | 결과 (`RECORDED`) |

## 엔드포인트

### 1) GET `/api/v1/verification/config`
- **Auth**: Public
- **Response**: `ApiResponse<VerificationConfigDto>`

예시 응답:
```json
{
  "success": true,
  "statusCode": 200,
  "data": {
    "jweAlg": "RSA-OAEP-256",
    "jwsAlg": "RS256",
    "publicKeys": ["-----BEGIN PUBLIC KEY-----\n..."] ,
    "toleranceMeters": 10,
    "timeSkewSec": 60
  },
  "error": null,
  "metadata": {
    "requestId": "req_1738387200000_1234",
    "timestamp": "2026-02-01T00:00:00Z",
    "version": "v1",
    "processingTimeMs": 3,
    "correlationId": null,
    "serverId": null
  },
  "pagination": null
}
```

### 2) GET `/api/v1/verification/challenge`
- **Auth**: Public
- **Response**: `ApiResponse<ChallengeDto>`

예시 응답:
```json
{
  "success": true,
  "statusCode": 200,
  "data": {
    "nonce": "3a2bd7b1-2e20-4b1f-9808-8c1a1d68b5e0",
    "expiresAt": "2026-02-01T00:05:00+09:00"
  },
  "error": null,
  "metadata": {
    "requestId": "req_1738387200000_5678",
    "timestamp": "2026-02-01T00:00:00Z",
    "version": "v1",
    "processingTimeMs": 2,
    "correlationId": null,
    "serverId": null
  },
  "pagination": null
}
```

### 3) POST `/api/v1/projects/{projectId}/places/{placeId}/verification`
- **Auth**: 로그인 필요
- **Path Params**:
  - `projectId`: 프로젝트 식별자(슬러그/코드)
  - `placeId`: 장소 UUID
- **Request**: `VerificationRequest`
- **Response**: `ApiResponse<VisitSuccessResponse>`
- **Errors**: `400`(VERIFICATION_FAILED), `401`, `404`

예시 요청:
```json
{
  "token": "<JWE_TOKEN>",
  "accuracy": 12.5
}
```

예시 응답:
```json
{
  "success": true,
  "statusCode": 200,
  "data": {
    "placeId": "0c5a3f0d-6ec0-4d6c-88c0-118cb81831e2",
    "result": "VERIFIED"
  },
  "error": null,
  "metadata": {
    "requestId": "req_1738387200000_9012",
    "timestamp": "2026-02-01T00:00:00Z",
    "version": "v1",
    "processingTimeMs": 18,
    "correlationId": null,
    "serverId": null
  },
  "pagination": null
}
```

### 4) POST `/api/v1/projects/{projectId}/live-events/{liveEventId}/verification`
- **Auth**: 로그인 필요
- **Path Params**:
  - `projectId`: 프로젝트 식별자(슬러그/코드)
  - `liveEventId`: 라이브 이벤트 UUID
- **Request**: `VerificationRequest`
- **Response**: `ApiResponse<AttendanceSuccessResponse>`
- **Errors**: `400`(VERIFICATION_FAILED), `401`, `404`

예시 요청 (수동 인증):
```json
{
  "verificationMethod": "MANUAL"
}
```

예시 응답:
```json
{
  "success": true,
  "statusCode": 200,
  "data": {
    "liveEventId": "2b4f5d47-8a15-4c0f-8a31-1d7fd7c1f9aa",
    "result": "RECORDED"
  },
  "error": null,
  "metadata": {
    "requestId": "req_1738387200000_3456",
    "timestamp": "2026-02-01T00:00:00Z",
    "version": "v1",
    "processingTimeMs": 22,
    "correlationId": null,
    "serverId": null
  },
  "pagination": null
}
```

## 참고
- 위치 토큰은 짧은 시간 내(수십 초) 사용해야 하며, 정확도(`accuracy`)가 너무 큰 경우 실패할 수 있습니다.
- `verificationMethod`, `evidence`는 향후 확장을 위한 필드로, 현재는 대부분 서버에서 무시됩니다.

# 방문 상세 위치 노출 API 변경 요청 (프런트 전달)

## 요구사항 요약
- **리스트는 위치 미노출 유지**
- 방문 상세 전용 API를 신설해 위치 정보를 제공
- 프런트는 기존 UI/로직을 그대로 사용 가능

## 변경 내용
### 1) 방문 리스트 API (변경 없음)
**GET** `/api/v1/users/me/visits`

응답 필드:
```json
{
  "id": "visit-uuid",
  "placeId": "place-uuid",
  "visitedAt": "2026-01-01T15:30:00.000+09:00"
}
```

### 2) 방문 상세 API (신설)
**GET** `/api/v1/users/me/visits/{visitId}`

응답 필드:
```json
{
  "id": "visit-uuid",
  "placeId": "place-uuid",
  "visitedAt": "2026-01-01T15:30:00.000+09:00",
  "latitude": 37.785834,
  "longitude": -122.406417,
  "accuracy": 5.0
}
```

## DTO 적용
- **리스트 DTO**: `VisitEventDto { id, placeId, visitedAt }`
- **상세 DTO**: `VisitEventDetailDto { id, placeId, visitedAt, latitude, longitude, accuracy }`

## 프런트 적용 범위
- UI 변경 없음
- 방문 상세 화면에서 기존 `latitude/longitude/accuracy` 표시 로직 그대로 사용 가능

## 오류 케이스
- `400`: `visitId` UUID 형식 아님
- `404`: 해당 방문 없음
- `401`: 인증 필요

# 백엔드 API 요청서: 홈 화면 배너 커스터마이징 시스템

작성일: 2026-03-13
작성자: 앱 개발팀
관련 ADR: `docs/adr/ADR-20260313-profile-banner-customization.md`

---

## 개요

홈 화면 상단 헤더(GBTGreetingHeader) 영역을 유저별 커스텀 배너 이미지로 표시하는 기능입니다.
배너는 **칭호·티어 달성 시 해금**되는 구조로, 앱 내 성취 시스템의 기반이 됩니다.

---

## 데이터 모델

### Banner (배너 카탈로그 항목)

| 필드 | 타입 | 설명 |
|------|------|------|
| `id` | String (UUID) | 배너 고유 ID |
| `name` | String | 배너 표시 이름 (예: "벚꽃 성지") |
| `imageUrl` | String | 헤더 전체 배경용 원본 이미지 URL |
| `thumbnailUrl` | String | 피커 그리드용 썸네일 URL (200×130px 권장) |
| `rarity` | String (Enum) | `COMMON` / `RARE` / `EPIC` / `LEGENDARY` |
| `unlockType` | String (Enum) | `DEFAULT` / `TIER` / `TITLE` / `EVENT` / `ADMIN_GRANT` |
| `unlockDescription` | String? | 해금 조건 텍스트 (예: "티어 실버 이상 달성 시 해금") |
| `sortOrder` | Int | 피커 내 정렬 순서 |
| `isActive` | Boolean? | 현재 요청 유저의 활성 여부 (인증 요청 시에만 포함) |

**rarity 값 정의:**
- `COMMON`: 기본 제공 (회색 테두리)
- `RARE`: 파란색 테두리
- `EPIC`: 보라색 테두리
- `LEGENDARY`: 금색 테두리

**unlockType 값 정의:**
- `DEFAULT`: 항상 사용 가능 (비회원 포함)
- `TIER`: 특정 티어 이상 달성 필요
- `TITLE`: 특정 칭호 보유 필요
- `EVENT`: 한정 이벤트 획득
- `ADMIN_GRANT`: 관리자 수동 부여

---

### UserBanner (유저 활성 배너)

| 필드 | 타입 | 설명 |
|------|------|------|
| `bannerId` | String? | 현재 활성 배너 ID (`null`이면 기본 배너) |
| `imageUrl` | String? | 활성 배너 이미지 URL |
| `thumbnailUrl` | String? | 활성 배너 썸네일 URL |
| `name` | String? | 활성 배너 이름 |

---

## 필요 엔드포인트 (4개)

---

### 1. 배너 카탈로그 조회

```
GET /api/v1/banners
```

**인증:** 선택 (인증 시 `isUnlocked`, `isActive` 포함)
**설명:** 앱에 등록된 전체 배너 목록 반환. 인증 유저는 본인의 해금 상태가 포함됨.

**Query Parameters:**

| 파라미터 | 타입 | 기본값 | 설명 |
|----------|------|--------|------|
| `rarity` | String? | — | 희귀도 필터 (COMMON/RARE/EPIC/LEGENDARY) |

**Response 200:**
```json
[
  {
    "id": "banner-sakura-001",
    "name": "벚꽃 성지",
    "imageUrl": "https://cdn.example.com/banners/sakura_full.jpg",
    "thumbnailUrl": "https://cdn.example.com/banners/sakura_thumb.jpg",
    "rarity": "RARE",
    "unlockType": "TIER",
    "unlockDescription": "티어 실버 이상 달성 시 해금",
    "sortOrder": 10,
    "isUnlocked": true,
    "isActive": false
  },
  {
    "id": "banner-default-001",
    "name": "기본 배너",
    "imageUrl": "https://cdn.example.com/banners/default_full.jpg",
    "thumbnailUrl": "https://cdn.example.com/banners/default_thumb.jpg",
    "rarity": "COMMON",
    "unlockType": "DEFAULT",
    "unlockDescription": null,
    "sortOrder": 0,
    "isUnlocked": true,
    "isActive": true
  }
]
```

**캐시 제안:** CDN/응답 캐시 1시간 (인증 유저는 유저별 캐시)

---

### 2. 내 활성 배너 조회

```
GET /api/v1/users/me/banner
```

**인증:** 필수 (Bearer Token)
**설명:** 현재 로그인 유저의 활성 배너 조회. 설정된 배너가 없으면 `204 No Content`.

**Response 200:**
```json
{
  "bannerId": "banner-sakura-001",
  "imageUrl": "https://cdn.example.com/banners/sakura_full.jpg",
  "thumbnailUrl": "https://cdn.example.com/banners/sakura_thumb.jpg",
  "name": "벚꽃 성지"
}
```

**Response 204:** 활성 배너 없음 (기본 배너 표시)

---

### 3. 배너 설정 (교체)

```
PUT /api/v1/users/me/banner
```

**인증:** 필수 (Bearer Token)
**설명:** 유저의 활성 배너를 지정된 배너로 교체. 해당 배너를 해금하지 않은 경우 `403` 반환.

**Request Body:**
```json
{
  "bannerId": "banner-sakura-001"
}
```

**Response 200:**
```json
{
  "bannerId": "banner-sakura-001",
  "imageUrl": "https://cdn.example.com/banners/sakura_full.jpg",
  "thumbnailUrl": "https://cdn.example.com/banners/sakura_thumb.jpg",
  "name": "벚꽃 성지"
}
```

**Error Cases:**

| HTTP | 코드 | 설명 |
|------|------|------|
| 400 | `banner_not_found` | 존재하지 않는 bannerId |
| 403 | `banner_locked` | 해금되지 않은 배너 |

---

### 4. 배너 초기화 (기본으로 되돌리기)

```
DELETE /api/v1/users/me/banner
```

**인증:** 필수 (Bearer Token)
**설명:** 유저의 활성 배너를 제거 (기본 배너로 복원). 이미 기본 상태여도 `204` 반환.

**Response 204:** 성공 (내용 없음)

---

## 해금 시스템 연동 (별도 기획 필요)

배너 해금 조건(`unlockType`)에 따라 백엔드에서 유저별 `isUnlocked` 값을 계산해야 합니다.
현재 앱에는 티어/칭호 시스템이 구현되어 있지 않으므로, 추후 아래 엔드포인트 또는 내부 로직과 연동이 필요합니다:

| unlockType | 연동 포인트 |
|------------|-------------|
| `DEFAULT` | 항상 `isUnlocked: true` |
| `TIER` | 유저 프로필에 `tier` 필드 추가 후 비교 (별도 기획 필요) |
| `TITLE` | 유저가 보유한 칭호 목록 조회 후 비교 (별도 기획 필요) |
| `EVENT` | 이벤트 참여 기록 조회 (별도 기획 필요) |
| `ADMIN_GRANT` | `user_banner_grants` 테이블 조회 |

**단기 우선 구현 제안:**
1단계: `DEFAULT` + `ADMIN_GRANT` 타입만 구현 → 관리자가 수동으로 유저에게 배너 부여
2단계: 티어/칭호 시스템 구축 후 `TIER`, `TITLE` 해금 자동화

---

## 관리자 전용 엔드포인트 (선택 사항)

### 유저에게 배너 수동 부여
```
POST /api/v1/admin/users/{userId}/banners
```
**Request Body:** `{ "bannerId": "banner-sakura-001" }`

### 배너 카탈로그 CRUD
```
POST   /api/v1/admin/banners          # 배너 생성
PUT    /api/v1/admin/banners/{id}     # 배너 수정 (이미지 URL, 이름, 조건 등)
DELETE /api/v1/admin/banners/{id}     # 배너 삭제
```

---

## 이미지 스펙 (CDN 업로드 시 참고)

| 용도 | 권장 크기 | 포맷 | 설명 |
|------|-----------|------|------|
| 헤더 전체 배경(`imageUrl`) | 1080×400px | JPEG/WebP | 상단 헤더 꽉 채움 (`BoxFit.cover`) |
| 피커 썸네일(`thumbnailUrl`) | 360×130px | JPEG/WebP | 그리드 셀 3열, 가로 압축 비율 적용 |

---

## 프런트엔드 구현 현황

| 항목 | 상태 |
|------|------|
| 배너 엔티티 / DTO | ✅ 완료 |
| 원격 데이터 소스 | ✅ 완료 |
| 리포지토리 (캐시 포함) | ✅ 완료 |
| Riverpod 컨트롤러 | ✅ 완료 |
| 배너 피커 페이지 (`/banner-picker`) | ✅ 완료 |
| 홈 화면 헤더 연동 | ✅ 완료 |
| 편집 아이콘 (헤더 우하단) | ✅ 완료 |
| 백엔드 API 연동 | ⏳ 백엔드 구현 대기 중 |
| 실제 배너 이미지 CDN 등록 | ⏳ 디자인팀 협의 필요 |


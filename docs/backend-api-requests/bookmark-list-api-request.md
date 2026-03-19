# 백엔드 API 추가 요청서

## 요청 제목
게시글 북마크 목록 조회 API 신규 추가

---

## 배경 및 문제

현재 게시글 북마크 관련 API는 **단건 처리(토글/상태 조회)만** 지원합니다.

| 현재 지원 엔드포인트 | 용도 |
|---|---|
| `GET /api/v1/projects/{projectCode}/posts/{postId}/bookmark` | 특정 게시글의 내 북마크 상태 조회 |
| `POST /api/v1/projects/{projectCode}/posts/{postId}/bookmark` | 북마크 등록 |
| `DELETE /api/v1/projects/{projectCode}/posts/{postId}/bookmark` | 북마크 해제 |

그러나 **"내가 북마크한 게시글 전체 목록"을 조회하는 API가 없습니다.**

클라이언트(앱)에는 커뮤니티 설정 > "북마크한 글" 화면이 존재하며, 사용자가 북마크한 게시글 목록을 모아서 볼 수 있어야 합니다. 현재 해당 API 부재로 인해:

1. 앱 내 "북마크한 글" 페이지가 항상 비어 보이는 버그가 있습니다.
2. 임시 방편으로 클라이언트 로컬 스토리지(SharedPreferences)에 북마크 데이터를 저장하는 방식으로 우회하고 있으나, **앱 재설치 시 데이터 소실**, **다중 기기 간 동기화 불가** 문제가 있습니다.

---

## 요청 사항

### 신규 API: 내 북마크 게시글 목록 조회

```
GET /api/v1/users/me/post-bookmarks
```

또는 기존 즐겨찾기 엔드포인트 패턴과 통일하려면:

```
GET /api/v1/users/me/favorites?type=POST
```

---

## 상세 스펙

### 요청

**Method:** `GET`
**Endpoint:** `/api/v1/users/me/post-bookmarks`
**인증:** Bearer 토큰 필수 (로그인한 사용자만 조회 가능)

**Query Parameters:**

| 파라미터 | 타입 | 필수 여부 | 기본값 | 설명 |
|---|---|---|---|---|
| `page` | integer | 선택 | `0` | 페이지 번호 (0-based) |
| `size` | integer | 선택 | `20` | 페이지당 항목 수 |
| `projectCode` | string | 선택 | - | 특정 프로젝트 게시글만 필터링 |

---

### 응답

**Status:** `200 OK`

```json
{
  "items": [
    {
      "postId": "abc123",
      "projectCode": "girlsband",
      "title": "첫 번째 단독 콘서트 후기",
      "thumbnailUrl": "https://cdn.example.com/images/post-thumb.jpg",
      "authorName": "홍길동",
      "authorAvatarUrl": "https://cdn.example.com/avatars/user.jpg",
      "commentCount": 12,
      "likeCount": 45,
      "bookmarkedAt": "2025-03-10T14:22:00Z",
      "createdAt": "2025-03-09T10:00:00Z"
    }
  ],
  "pagination": {
    "currentPage": 0,
    "pageSize": 20,
    "totalElements": 3,
    "totalPages": 1,
    "hasNext": false
  }
}
```

**응답 필드 설명:**

| 필드 | 타입 | 설명 |
|---|---|---|
| `postId` | string | 게시글 ID |
| `projectCode` | string | 게시글이 속한 프로젝트 코드 |
| `title` | string | 게시글 제목 |
| `thumbnailUrl` | string? | 대표 이미지 URL (없을 수 있음) |
| `authorName` | string? | 작성자 닉네임 |
| `authorAvatarUrl` | string? | 작성자 프로필 이미지 URL |
| `commentCount` | integer | 댓글 수 |
| `likeCount` | integer | 좋아요 수 |
| `bookmarkedAt` | string (ISO 8601) | 북마크 등록 시각 |
| `createdAt` | string (ISO 8601) | 게시글 작성 시각 |

---

### 에러 응답

| HTTP Status | 설명 |
|---|---|
| `401 Unauthorized` | 인증 토큰 없음 또는 만료 |
| `403 Forbidden` | 권한 없음 |

---

## 추가 고려 사항

### 삭제된 게시글 처리
북마크한 게시글이 이후 삭제된 경우:
- 목록에서 **자동 제외** (삭제된 게시글은 응답에 포함하지 않음)
- 또는 `isDeleted: true` 필드를 포함해 클라이언트가 처리 가능하도록

둘 중 하나의 방식으로 처리 부탁드립니다. (자동 제외 방식 선호)

### 정렬
- 기본 정렬: `bookmarkedAt` 내림차순 (최신 북마크 순)

### 기존 `/users/me/favorites` 통합 여부
기존 즐겨찾기 API(`/users/me/favorites`)에서 게시글 타입(`entityType: POST`)을 지원하는 방식으로 통합도 가능합니다. 백엔드 구조에 맞는 방향을 선택해 주세요.

---

## 클라이언트 현재 상태

- 앱 파일: `lib/features/feed/presentation/pages/post_bookmarks_page.dart`
- API 상수 위치: `lib/core/constants/api_constants.dart`
- 해당 엔드포인트 추가 시 클라이언트는 `ApiEndpoints.userPostBookmarks` 상수 추가 후 즉시 연동 가능

---

## 우선순위

**높음** — 현재 "북마크한 글" 기능이 사실상 동작하지 않아 사용자 경험에 직접 영향

---

*작성일: 2026-03-17*

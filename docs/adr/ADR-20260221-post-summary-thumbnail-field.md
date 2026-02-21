# ADR-20260221: Post Summary Thumbnail & imageUrls Field

**Date**: 2026-02-21
**Status**: Proposed

---

## Context

게시글 작성 시 이미지를 업로드하면 `upload.url`을 수집하고 content 마크다운 끝에 `![](url)` 형태로 삽입합니다. 서버 list 응답의 `PostSummary` DTO에는 `imageUrls` / `thumbnailUrl` 필드가 없어 목록 화면에서 썸네일을 표시하려면 content를 파싱해야 합니다. content가 잘리면 이미지 URL 추출이 불가능합니다.

**목표**: 게시글 카드 썸네일 = `post.imageUrls[0]` = 업로더가 올린 첫 번째 이미지 URL

---

## Decision

### 1. POST /api/v1/projects/{code}/posts — Request Body

`imageUrls` 필드를 추가로 수락합니다.

```json
{
  "title": "string",
  "content": "string (markdown with embedded images)",
  "imageUrls": ["https://...", "https://..."]
}
```

- `imageUrls`는 선택 필드 (`optional`, default `[]`)
- 클라이언트는 이미지 업로드 완료 후 반환된 URL 목록을 그대로 전달
- 서버는 이 배열을 별도 컬럼/관계 테이블에 저장 (content 파싱 불필요)

### 2. GET /api/v1/projects/{code}/posts — Response Body (PostSummary)

`imageUrls` 배열 또는 `thumbnailUrl` 단일 필드를 응답에 포함합니다.

**Option A** (권장): `imageUrls` 배열 — 첫 번째 요소가 썸네일
```json
{
  "id": "...",
  "title": "...",
  "imageUrls": ["https://cdn.example.com/first.webp", "..."]
}
```

**Option B**: `thumbnailUrl` 단일 필드
```json
{
  "id": "...",
  "title": "...",
  "thumbnailUrl": "https://cdn.example.com/first.webp"
}
```

클라이언트 `PostSummaryDto.fromJson`은 이미 두 가지 방식 모두 처리합니다.

---

## Flutter Client Changes (구현 완료)

| 파일 | 변경 내용 |
|---|---|
| `data/dto/post_comment_dto.dart` | `PostCreateRequestDto.imageUrls` 필드 추가 |
| `domain/repositories/feed_repository.dart` | `createPost` 시그니처에 `imageUrls` 추가 |
| `data/repositories/feed_repository_impl.dart` | DTO 생성 시 `imageUrls` 전달 |
| `presentation/pages/post_create_page.dart` | `createPost` 호출 시 `imageUrls` 전달 |
| `presentation/pages/board_page.dart` | 썸네일 64→88px, content 스니펫 추가 |

---

## Consequences

- **긍정**: content 파싱 없이 신뢰할 수 있는 썸네일 URL 제공
- **긍정**: 서버와 클라이언트 간 명확한 계약 (contract)
- **부정**: 서버 스키마 변경 필요 (기존 게시글은 `imageUrls` 없음 → content 파싱 폴백 유지)
- **호환성**: 클라이언트는 `imageUrls` → content 추출 → `thumbnailUrl` 순 폴백 처리 유지

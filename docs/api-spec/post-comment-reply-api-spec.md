# 게시글 댓글 대댓글(답글) API 엔드포인트 요청서

> **작성일**: 2026-03-05
> **작성자**: 클라이언트 팀
> **상태**: 구현 요청
> **우선순위**: High

---

## 배경 및 목적

현재 게시글 댓글 시스템(`POST /comments`)은 `parentCommentId` 필드를 요청 바디에 포함하도록
클라이언트가 구현되어 있으나, 아래 두 가지 사항이 불명확합니다.

1. **백엔드에서 `parentCommentId`를 실제로 처리하는지 여부** 확인 필요
2. **댓글별 답글 목록 조회 엔드포인트** 미구현 — 현재 `GET /comments` 는 페이지 전체 댓글을 반환하므로,
   특정 댓글의 답글만 페이지네이션하여 조회할 수 없음

클라이언트는 v2 리뉴얼에서 인라인 대댓글 UI를 도입했으며, 이를 위해 아래 API가 필요합니다.

---

## 현재 클라이언트 상태

| 항목 | 상태 | 비고 |
|------|------|------|
| 대댓글 UI (인라인 확장) | ✅ 완료 | `post_detail_page.dart` |
| 답글 작성 바 (reply context banner) | ✅ 완료 | `_CommentComposerBar` |
| `parentCommentId` 전송 | ✅ 완료 | `PostCommentsController.addComment` |
| 답글 목록 로컬 그루핑 | ✅ 완료 | flat list에서 client-side 그루핑 |
| 답글 전용 페이지네이션 조회 | ⏳ 백엔드 대기 | `GET /comments/{commentId}/replies` |

---

## 데이터 모델

### PostComment (게시글 댓글)

| 필드 | 타입 | 설명 |
|------|------|------|
| `id` | UUID | 댓글 고유 ID |
| `postId` | UUID | 소속 게시글 ID |
| `authorId` | UUID | 작성자 (JWT 추출) |
| `authorName` | string | 작성자 표시명 |
| `authorAvatarUrl` | string? | 작성자 아바타 URL |
| `content` | string | 댓글 내용 (max 1000자) |
| `parentCommentId` | UUID? | 대댓글이면 부모 댓글 ID |
| `depth` | int | 중첩 깊이 (root=0, 1단계 답글=1) |
| `replyCount` | int | 직접 답글 수 (최상위 댓글에만 의미 있음) |
| `createdAt` | ISO 8601 | 생성 시각 |
| `updatedAt` | ISO 8601? | 수정 시각 |

---

## 엔드포인트 목록

기본 경로: `/api/v1/projects/{projectCode}/posts/{postId}/comments`

---

### 9.X.1 댓글 생성 (대댓글 지원 확인 요청)

```
POST /api/v1/projects/{projectCode}/posts/{postId}/comments
```

**권한**: 인증된 사용자 (프로젝트 멤버)

**Request Body**:
```json
{
  "content": "댓글 내용입니다.",
  "parentCommentId": "parent-comment-uuid"  ← 대댓글 시 필수, 일반 댓글 시 생략
}
```

**Response 201 Created**:
```json
{
  "id": "comment-uuid",
  "postId": "post-uuid",
  "authorId": "user-uuid",
  "authorName": "사용자명",
  "authorAvatarUrl": "https://cdn.example.com/avatar.jpg",
  "content": "댓글 내용입니다.",
  "parentCommentId": "parent-comment-uuid",
  "depth": 1,
  "replyCount": 0,
  "createdAt": "2026-03-05T10:00:00+09:00",
  "updatedAt": null
}
```

**확인 필요 사항**:
- [ ] `parentCommentId` 를 받아 DB에 저장하는지 확인
- [ ] 부모 댓글의 `replyCount` 가 1 증가하는지 확인
- [ ] 존재하지 않는 `parentCommentId` 전달 시 `404` 반환하는지 확인
- [ ] 최대 중첩 깊이 제한이 있는지 확인 (권고: depth ≤ 2)

**에러**:
| 코드 | 사유 |
|------|------|
| 400 | content 누락 또는 길이 초과 |
| 403 | 프로젝트 멤버가 아닌 경우 |
| 404 | postId 또는 parentCommentId 미존재 |

---

### 9.X.2 댓글 목록 조회 (기존 — flat list)

```
GET /api/v1/projects/{projectCode}/posts/{postId}/comments
```

**현재 동작**: 게시글의 모든 댓글(최상위 + 답글)을 flat list로 반환.

**클라이언트 동작**: 수신한 flat list를 `parentCommentId == null` 기준으로 분리하여
최상위 댓글과 대댓글을 구분합니다.

**확인 필요 사항**:
- [ ] `parentCommentId`가 null인 댓글(최상위)과 non-null인 댓글(대댓글) 모두 포함되는지 확인
- [ ] 응답에 `depth`, `replyCount` 필드가 포함되는지 확인

---

### 9.X.3 특정 댓글의 답글 목록 조회 (신규 요청 — 최우선)

```
GET /api/v1/projects/{projectCode}/posts/{postId}/comments/{commentId}/replies
```

**권한**: 모든 사용자 (공개 게시글) / 인증 사용자 (멤버 전용 게시글)

**Query Parameters**:
| 파라미터 | 타입 | 기본값 | 설명 |
|---------|------|--------|------|
| `page` | int | 0 | 페이지 번호 |
| `size` | int | 20 | 페이지 크기 |

**Response 200 OK**:
```json
{
  "content": [
    {
      "id": "reply-uuid",
      "postId": "post-uuid",
      "authorId": "user-uuid",
      "authorName": "답글 작성자",
      "authorAvatarUrl": "https://cdn.example.com/avatar.jpg",
      "content": "답글 내용입니다.",
      "parentCommentId": "parent-comment-uuid",
      "depth": 1,
      "replyCount": 0,
      "createdAt": "2026-03-05T10:00:00+09:00",
      "updatedAt": null
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 5,
  "totalPages": 1
}
```

**에러**:
| 코드 | 사유 |
|------|------|
| 404 | commentId 미존재 |

---

### 9.X.4 댓글 스레드 조회 (기존 — 트리 구조)

```
GET /api/v1/projects/{projectCode}/posts/{postId}/comments/thread
```

**현재 동작**: `parentCommentId` + `maxDepth` + `size` 파라미터를 받아
중첩 트리 구조(`CommentThreadNode`)를 반환합니다. 바텀시트 스레드 뷰에 사용됩니다.

**확인 필요 사항**:
- [ ] `parentCommentId` 없이 호출 시 전체 스레드를 반환하는지 확인
- [ ] 특정 `parentCommentId` 지정 시 해당 댓글의 하위 트리만 반환하는지 확인

---

## 우선순위 요약

| 순위 | 엔드포인트 | 현재 상태 | 비고 |
|------|-----------|---------|------|
| 1 | `POST /comments` — `parentCommentId` 처리 | 미확인 | 필수 (대댓글 쓰기) |
| 2 | `GET /comments/{commentId}/replies` | 미구현 | 필수 (페이지네이션) |
| 3 | `GET /comments` — depth/replyCount 포함 | 미확인 | 클라이언트 그루핑에 필요 |
| 4 | `GET /comments/thread` — 동작 확인 | 미확인 | 바텀시트용 |

---

## 추가 고려 사항

### 1. 최대 중첩 깊이 제한
악용 방지 및 UI 일관성을 위해 `depth ≤ 2` (최상위 댓글 + 1단계 답글)를 권고합니다.
depth 2 이상의 답글 시도 시 `400` 에러 또는 depth 1로 자동 clamp 처리를 권고합니다.

### 2. replyCount 실시간 갱신
답글 생성/삭제 시 부모 댓글의 `replyCount`를 자동으로 증감시켜야 합니다.
클라이언트는 `replyCount`를 "답글 N개 보기" 버튼 표시에 활용합니다.

### 3. 답글 삭제 시 처리
부모 댓글 삭제 시 자식 답글 처리 정책:
- **Cascade 삭제**: 부모 삭제 시 모든 답글도 삭제 (권고)
- **Soft delete + tombstone**: `[삭제된 댓글입니다]` 로 대체

### 4. 알림 연동
답글 등록 시 원 댓글 작성자에게 푸시 알림 전송을 권고합니다.
기존 알림 시스템(`/api/v1/notifications`) 활용.

---

## 클라이언트 구현 현황 요약

```
lib/features/feed/
├── application/post_controller.dart
│   └── PostCommentsController.addComment(content, {parentCommentId}) ✅
├── presentation/pages/post_detail_page.dart
│   ├── _PostDetailPageState._replyTarget               ✅
│   ├── _PostDetailPageState._setReplyTarget()          ✅
│   ├── _PostDetailPageState._clearReplyTarget()        ✅
│   ├── _PostCommentsSection (root/reply grouping)      ✅
│   ├── _CommentItem (inline expandable replies)        ✅
│   ├── _ReplyItem (대댓글 아이템 with accent bar)     ✅
│   └── _CommentComposerBar (reply context banner)      ✅
└── data/
    ├── dto/post_comment_dto.dart (parentCommentId)     ✅
    └── datasources/feed_remote_data_source.dart        ✅
```

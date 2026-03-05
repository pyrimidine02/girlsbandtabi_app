# 게시글 드래프트 API 엔드포인트 요청서

> **작성일**: 2026-03-05
> **작성자**: 클라이언트 팀
> **상태**: 구현 요청
> **우선순위**: Low (P2)

---

## 배경

클라이언트는 우선 로컬 임시저장을 적용했지만, 다중 디바이스/재설치 복구를 위해
서버 드래프트 API가 필요합니다.

---

## 요청 엔드포인트

### 1) 드래프트 생성
`POST /api/v1/projects/{projectCode}/posts/drafts`

Request:
```json
{
  "title": "임시 제목",
  "content": "임시 내용",
  "imageUploadIds": ["upload-uuid-1"]
}
```

Response 201:
```json
{
  "id": "draft-uuid",
  "projectId": "project-uuid",
  "authorId": "user-uuid",
  "title": "임시 제목",
  "content": "임시 내용",
  "imageUploadIds": ["upload-uuid-1"],
  "updatedAt": "2026-03-05T16:00:00+09:00"
}
```

### 2) 드래프트 수정
`PATCH /api/v1/projects/{projectCode}/posts/drafts/{draftId}`

### 3) 내 드래프트 목록 조회
`GET /api/v1/projects/{projectCode}/posts/drafts?page=0&size=20`

### 4) 드래프트 삭제
`DELETE /api/v1/projects/{projectCode}/posts/drafts/{draftId}`

### 5) 드래프트 게시
`POST /api/v1/projects/{projectCode}/posts/drafts/{draftId}/publish`

---

## 클라이언트 기대 동작

- 앱 시작 시 프로젝트별 최신 드래프트 1건 복구 제안
- 동일 사용자의 동시 편집 충돌 시 `updatedAt` 기반 충돌 안내
- 게시 성공 시 해당 드래프트 자동 삭제

---

## 비고

- 서버 구현 전까지는 로컬 임시저장(`SharedPreferences`)로 운영.

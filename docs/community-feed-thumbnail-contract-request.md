# [긴급] 커뮤니티 피드 썸네일 계약 정합성 개선 요청서

**작성일**: 2026-03-07  
**요청 대상**: Backend API Team  
**우선순위**: High

---

## 1) 배경

- 모바일 앱에서 프로젝트를 전환한 뒤, 커뮤니티 피드 카드의 이미지 미리보기가 비어 보이는 사례가 반복 발생했습니다.
- 확인된 관련 엔드포인트:
  - `GET /api/v1/projects/{projectCode}/posts/cursor`
  - `GET /api/v1/community/feed/cursor`
- 현재 프런트는 다수의 키 변형(`imageUrls`, `image_urls`, `thumbnailUrl`, `thumbnail_image_url`, `coverImage.image_url` 등)을 폴백으로 처리하고 있으나, 프로젝트/응답 형태별 편차가 커서 안정성이 낮습니다.

---

## 2) 문제 요약

- 같은 기능의 피드 응답인데도 이미지 필드 네이밍/구조가 일관되지 않습니다.
- 일부 항목은 상세 조회에서는 이미지가 존재하지만, 목록 요약 응답에서는 썸네일 판단 필드가 비어 있습니다.
- 결과적으로 프로젝트 변경 직후 카드 썸네일이 누락되어 UX 일관성이 깨집니다.

---

## 3) 요청 사항 (필수)

### 3-1. 목록 응답 스키마 고정

대상:  
- `GET /api/v1/projects/{projectCode}/posts/cursor`
- `GET /api/v1/community/feed/cursor`

각 `items[]`에 아래 필드를 **고정**해 주세요.

- `imageUrls`: `string[]` (항상 포함, 값 없으면 `[]`)
- `thumbnailUrl`: `string | null` (항상 포함)

### 3-2. 값 정합성 규칙

- 게시글에 이미지가 1개 이상이면:
  - `imageUrls.length >= 1`
  - `thumbnailUrl == imageUrls[0]`
- 게시글에 이미지가 없으면:
  - `imageUrls: []`
  - `thumbnailUrl: null`

### 3-3. URL 포맷 고정

- 클라이언트가 바로 렌더링 가능한 절대 URL만 반환해 주세요.
- 권장 예: `https://r2.pyrimidines.org/...`
- 상대 경로/내부 스토리지 경로는 응답 금지 부탁드립니다.

### 3-4. 하위 호환 정책 명시

- 레거시 키(`image_urls`, `thumbnail_image_url`, `coverImage` 등)는 단계적으로 제거하되,
  - 제거 일정 공지
  - 공지 기간 동안은 정식 키(`imageUrls`, `thumbnailUrl`)를 반드시 동시 제공

---

## 4) 권장 응답 예시

```json
{
  "success": true,
  "statusCode": 200,
  "data": {
    "items": [
      {
        "id": "38f55757-6953-44d4-abb8-8ab0ec35003e",
        "projectId": "550e8400-e29b-41d4-a716-446655440001",
        "authorId": "243701ba-86d8-4356-9c17-630944e2ed8f",
        "authorName": "System Admin",
        "title": "썸네일",
        "content": "....",
        "imageUrls": [
          "https://r2.pyrimidines.org/uploads/.../image-1.webp",
          "https://r2.pyrimidines.org/uploads/.../image-2.webp"
        ],
        "thumbnailUrl": "https://r2.pyrimidines.org/uploads/.../image-1.webp",
        "commentCount": 1,
        "likeCount": 1,
        "createdAt": "2026-03-05T06:22:55.253859504Z"
      }
    ],
    "nextCursor": null,
    "hasNext": false
  }
}
```

---

## 5) 검증 기준 (완료 조건)

- 프로젝트 전환 후 피드 첫 로드에서 썸네일 누락 재현되지 않음
- 위 2개 엔드포인트 응답의 `items[]`에 `imageUrls`, `thumbnailUrl` 항상 포함
- 이미지가 있는 게시글의 `thumbnailUrl`이 `imageUrls[0]`와 일치
- QA 샘플 50건 기준(이미지 있음/없음 혼합) 미리보기 누락 0건

---

## 6) 프런트 참고 사항

- 프런트는 현재 레거시 키 폴백 파서를 유지 중입니다.
- 서버 계약 고정 이후, 프런트는 폴백 분기를 제거해 파서를 단순화할 예정입니다.


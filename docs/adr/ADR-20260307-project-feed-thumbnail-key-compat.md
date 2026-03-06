# ADR-20260307-project-feed-thumbnail-key-compat

## Status
Accepted (2026-03-07)

## Context
- 프로젝트를 변경한 뒤 게시글 카드에서 이미지 미리보기가 사라지는 케이스가 보고되었다.
- 카드 미리보기는 `PostSummaryDto`에서 파싱한 `imageUrls`/`thumbnailUrl`에 의존한다.
- 프로젝트별 피드 응답은 운영 환경/엔드포인트에 따라 이미지 필드 네이밍이 달라질 수 있다(`thumbnailUrl` 외 snake_case, nested object 키 등).

## Decision
- `PostSummaryDto.fromJson` 이미지 파싱을 호환성 중심으로 확장한다.
  - thumbnail 후보 키 확장:
    - `thumbnailUrl`, `thumbnail_url`
    - `coverImageUrl`, `cover_image_url`
    - `firstImageUrl`, `first_image_url`
    - `thumbnailImageUrl`, `thumbnail_image_url`
    - object 형태(`thumbnail`, `coverImage`, `thumbnailImage`) 내부 URL 키 탐색
  - 이미지 배열 후보 키 확장:
    - `imageUrls`, `image_urls`, `images`, `attachments`, `files`, `photoUrls`, `photo_urls`, `media`
  - 배열 항목 URL 키 확장:
    - `url`, `imageUrl`, `image_url`, `src`, `thumbnailUrl`, `thumbnail_url`, `fileUrl`, `file_url`, `path`
- summary 이미지 배열이 비었고 thumbnail만 존재할 때 기존 fallback 동작을 유지한다.

## Consequences
### Positive
- 프로젝트 전환 시 카드 미리보기 누락 확률이 줄어든다.
- 백엔드 응답 키 변형에 대한 프런트 회복력이 올라간다.

### Trade-offs
- 허용 키가 많아져 DTO 파싱 로직이 다소 복잡해진다.
- 장기적으로는 서버 계약 키를 단일화해 파싱 분기를 줄여야 한다.

## Validation
- `dart format lib/features/feed/data/dto/post_dto.dart test/features/feed/data/post_dto_test.dart`
- `flutter analyze lib/features/feed/data/dto/post_dto.dart test/features/feed/data/post_dto_test.dart`
- `flutter test test/features/feed/data/post_dto_test.dart`

## Follow-up
- 서버 PostSummary 계약을 `thumbnailUrl` + `imageUrls`로 고정하고 다른 키는 점진 제거한다.
- 운영 로그에서 미리보기 누락 케이스 샘플 payload를 수집해 파싱 케이스를 최소화/정규화한다.

# ADR-20260309 Android Feed Thumbnail URL Normalization and Upload DTO Compatibility

## Status
- Accepted

## Context
- Android에서 게시글 작성 직후 피드 카드 썸네일이 간헐적으로 비는 현상이
  지속되었습니다.
- 코드 경로 분석 결과, 피드/게시판 카드 썸네일 후보는
  `thumbnailUrl -> imageUrls -> content image` 순서지만,
  URL 정규화가 `http/https + host`만 허용해 상대경로/스킴 누락 URL이
  후보에서 제거될 수 있었습니다.
- 업로드 응답 DTO는 `uploadId/url/isApproved` 단일 키에 의존하고 있어,
  백엔드 응답 키가 `id/publicUrl/approved` 등으로 변형되면
  썸네일 파생 입력(`imageUploadIds`) 또는 콘텐츠 이미지 URL 수집이
  누락될 수 있었습니다.

## Decision
- `resolveMediaUrl` 정규화 규칙을 확장했습니다.
  - 스킴 없는 public host URL(`r2.pyrimidines.org/...`) 허용
  - 업로드 객체 키 형태(`uploads/...`, `uploads%2F...`)를
    `https://r2.pyrimidines.org/...`로 정규화
  - 기타 상대경로(`/media/...`)는 API origin 기준 절대 URL로 해석
- 본문 이미지 추출기(`image_url_extractor`)를 확장했습니다.
  - markdown/html 이미지 URL 파싱 시 상대경로/스킴 누락 URL도 수용
  - 이미지 URL 판별을 URL 정규화(`resolveMediaUrl`) 이후 수행
- 업로드 DTO 파싱을 다중 키 폴백으로 확장했습니다.
  - upload id: `uploadId | upload_id | id | fileId | file_id`
  - URL: `url | fileUrl | publicUrl | cdnUrl | path`
  - 승인 상태: `isApproved | approved`
- 게시글 작성/수정 업로드 경로에 URL 보강(retry) 로직을 추가했습니다.
  - direct upload 응답의 `url`이 비어 있으면 `/uploads/my` 재조회로
    동일 `uploadId`의 URL을 최대 3회 보강 시도
  - 보강 성공 시 markdown 본문/미리보기 후보 URL이 즉시 채워지도록 적용
  - 보강 실패 시 warning 로그로 디바이스별 이슈를 추적 가능하게 구성

## Consequences
- Android에서 상대/변형 URL 때문에 썸네일 후보가 제거되는 케이스를
  클라이언트 레벨에서 완화합니다.
- 업로드 응답 키 편차가 있어도 `imageUploadIds`/image URL 수집의
  안정성이 올라가 게시글 요약 썸네일 생성 성공률이 개선됩니다.
- API origin 미초기화 환경(격리 테스트)에서는 기존 동작을 유지하도록
  예외 안전 처리했습니다.

## Verification
- `flutter test test/core/utils/media_url_test.dart test/features/uploads/data/upload_dto_test.dart`
- `flutter test test/core/utils/image_url_extractor_test.dart`
- `flutter analyze lib/features/feed/presentation/pages/post_create_page.dart lib/features/feed/presentation/pages/post_edit_page.dart`
- `flutter analyze lib/core/utils/media_url.dart lib/core/utils/image_url_extractor.dart lib/features/uploads/data/dto/upload_dto.dart`

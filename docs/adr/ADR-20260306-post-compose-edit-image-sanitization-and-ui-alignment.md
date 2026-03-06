# ADR-20260306-post-compose-edit-image-sanitization-and-ui-alignment

## Status
Accepted (2026-03-06)

## Context
- 게시글 수정 화면에서 본문(`content`)에 저장된 이미지 마크다운(`![](url)`) 또는 인라인 이미지 URL이 그대로 노출되어, 사용자가 R2 주소를 직접 보게 되는 문제가 있었습니다.
- 현재 백엔드 업데이트 API는 `title/content` 중심이라, 이미지를 유지하려면 본문에 다시 이미지 URL 블록을 병합해 전달해야 합니다.
- 작성/수정 화면의 상단 정보 구조가 다른 주요 페이지 대비 다소 분절되어 보인다는 피드백이 있었습니다.

## Decision
### 1) 수정 에디터 본문 정제
- `PostEditPage` 초기화 시 본문을 `stripImageMarkdown(...)`로 정제해 텍스트 입력 영역에는 순수 본문만 표시합니다.

### 2) 기존 첨부 이미지를 별도 상태로 분리
- 기존 이미지는 `post.imageUrls + extractImageUrls(content)`를 합쳐 정규화/중복 제거 후 `_existingImageUrls`로 관리합니다.
- 수정 화면 이미지 섹션에서 기존 원격 이미지와 신규 로컬 이미지를 동일 그리드로 표시하고, 각각 제거/전체 삭제를 지원합니다.

### 3) 수정 저장 시 이미지 보존
- 저장 시 `기존 이미지 + 신규 업로드 이미지`를 병합/정규화한 뒤 `appendImageMarkdownContent(...)`로 본문에 재병합하여 전송합니다.
- 이로써 본문 편집 중 URL 노출은 사라지고, 첨부 이미지 보존/삭제 의도도 반영됩니다.

### 4) 작성/수정 UI 리듬 통일
- 공용 컴포넌트로 `PostComposeIntroCard`와 `PostComposeRemoteImageTile`를 추가하고,
  `PostCreatePage`/`PostEditPage` 모두 동일한 상단 안내 카드를 사용하도록 통일했습니다.

## Consequences
### Positive
- 수정 화면에서 R2 URL 텍스트 노출 문제가 제거됩니다.
- 기존 이미지가 입력 텍스트가 아니라 첨부 영역에서 관리되어 UX가 직관적으로 개선됩니다.
- 작성/수정 페이지의 시각적 시작점이 통일되어 페이지 일관성이 높아집니다.

### Trade-offs
- 현재 autosave draft 스냅샷은 로컬 이미지 경로만 저장하므로, “기존 원격 이미지 제거 상태”는 드래프트에 완전 반영되지 않습니다(세션 내 상태는 정상 반영).

## Validation
- `dart format lib/features/feed/presentation/pages/post_edit_page.dart lib/features/feed/presentation/pages/post_create_page.dart lib/features/feed/presentation/widgets/post_compose_components.dart`
- `flutter analyze lib/features/feed/presentation/pages/post_edit_page.dart lib/features/feed/presentation/pages/post_create_page.dart lib/features/feed/presentation/widgets/post_compose_components.dart`

## Follow-up
- autosave 모델에 `existingImageUrls` 스냅샷 포함 여부를 검토해 수정 중 이미지 제거 상태까지 복구 가능하도록 확장합니다.

# ADR-20260305-community-feed-phase5-compose-local-draft

## Status
Accepted (2026-03-05)

## Context
- 커뮤니티 개선 5차 요구사항으로 작성/편집 UX에서 임시저장과 복구 경험이 필요합니다.
- 현재 `PostCreatePage`/`PostEditPage`는 화면 이탈 시 경고만 있고, 앱 재실행 후 작성 복구 흐름이 없습니다.
- 서버 드래프트 API는 아직 확정되지 않아 로컬 선구현이 필요합니다.

## Decision
### 1) 로컬 임시저장 스토어 도입
- `PostComposeDraftStore`를 추가하고 `SharedPreferences(LocalStorage)`에 JSON으로 저장.
- 저장 항목:
  - `title`, `content`, `imagePaths`, `savedAt`, `projectCode`

### 2) 작성/수정 화면 자동 임시저장
- `PostCreatePage`와 `PostEditPage` 모두 입력 변경 시 `1.2s` 디바운스로 자동 저장.
- 저장 조건:
  - 작성: 제목/내용/이미지 중 하나라도 있으면 저장
  - 수정: 초기값 대비 변경이 있을 때만 저장

### 3) 재진입 복구 배너 추가
- 저장된 draft가 있으면 상단 배너(`복구`, `삭제`) 노출.
- 복구 시 title/content/image(존재 파일만) 반영.
- 게시 성공 시 draft 즉시 삭제.

### 4) 수정 페이지 dirty 판정 정교화
- 기존 수정 페이지는 초기값이 비어있지 않아 항상 `_hasDraft=true`로 동작할 여지가 있었음.
- 초기값(`_initialTitle`, `_initialContent`)과 현재값을 비교하는 `_isDirty` 기반으로 정리.

## Consequences
### Positive
- 앱 종료/재시작/탭 이동 이후에도 작성 연속성이 유지됩니다.
- 이미지 첨부/텍스트 입력 손실 가능성이 크게 줄어듭니다.
- 수정 화면의 이탈 경고/버튼 활성화가 실제 변경 여부에 맞게 동작합니다.

### Trade-offs
- 로컬 임시저장은 단말 단위라 다중 기기 동기화는 불가능합니다.
- 이미지 경로는 로컬 파일 상태에 의존하므로 파일이 삭제된 경우 복구에서 제외됩니다.

## Validation
- `flutter analyze lib/features/feed/application/post_compose_draft_store.dart lib/features/feed/presentation/pages/post_create_page.dart lib/features/feed/presentation/pages/post_edit_page.dart`
- `flutter test test/features/feed/application/post_compose_draft_store_test.dart`

## Follow-up
- 서버 드래프트 계약(`POST/PATCH/GET /posts/drafts`) 확정 시 로컬 임시저장을 서버 동기화 draft로 확장.
- 드래프트가 여러 프로젝트/여러 글쓰기 인스턴스를 지원해야 하는지 정책 확정.

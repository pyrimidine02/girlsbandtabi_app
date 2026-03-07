# ADR-20260307-post-compose-camera-gallery-toolbar-only

## Status
Accepted (2026-03-07)

## Context
- 작성/수정 하단 툴바에 다수 액션이 노출되어 핵심 미디어 입력 흐름이 분산되었습니다.
- 사용자 요청은 하단 툴바를 `갤러리 + 카메라` 2개 액션으로 단순화하고,
  카메라 액션의 실제 캡처 동작을 명확히 보장하는 것이었습니다.

## Decision
1. 하단 툴바 액션을 두 개로 제한:
   - gallery (`pickMultiImage`)
   - camera (`pickImage(source: camera)`).
2. 작성/수정 페이지 모두 동일한 picker 동작으로 통일.
3. 첨부 제한/중복 제거는 기존 정책을 유지하고 공용 append 처리로 재사용.
4. 갤러리/카메라 오픈 실패 시 사용자 메시지 제공.

## Consequences
### Positive
- 작성 화면 하단 액션이 단순해져 사용 의도가 명확해집니다.
- 카메라와 갤러리 모두 실제 동작 경로가 분리되어 유지보수가 쉬워집니다.

### Trade-offs
- 기존 하단 툴바의 부가 액션(GIF/리스트/일괄삭제/카운트)은 제거되었습니다.

## Validation
- `flutter analyze lib/features/feed/presentation/pages/post_create_page.dart lib/features/feed/presentation/pages/post_edit_page.dart`

# ADR-20260307-post-compose-single-tone-editor-and-project-dropdown

## Status
Accepted (2026-03-07)

## Context
- 작성/수정 화면에서 회색 구간 분리와 가로 pill 기반 프로젝트 선택이
  입력 집중 흐름을 끊는다는 피드백이 있었습니다.
- 최신 요청은 단색 캔버스 기반의 미니멀 편집기와
  제목/본문 구분선 중심 구조를 요구했습니다.

## Decision
1. 작성/수정 화면을 단색(white) 에디터 캔버스로 통일.
2. 제목 입력과 본문 입력 사이에 연한 1px 구분선을 추가.
3. 커뮤니티 준수 문구를 고정 안내 텍스트 대신
   본문 입력 플레이스홀더로 이동.
4. 프로젝트 선택 UX를 변경:
   - 기존 `ProjectSelectorCompact`(가로 pill row) 대신
   - `ProjectDropdownSelectorCompact`(단일 드롭다운 + 바텀시트 목록)
     방식으로 교체.

## Consequences
### Positive
- 시각적 노이즈가 줄어 입력 시작/집중 속도가 개선됩니다.
- 작은 화면에서도 프로젝트 선택 조작이 명확해지고 스크롤 충돌이 줄어듭니다.
- 가이드 문구를 placeholder로 배치해 본문 입력 의도와 자연스럽게 연결됩니다.

### Trade-offs
- 다크 모드에서도 작성/수정 화면은 밝은 편집기 톤을 사용하므로
  앱 전체 테마 일관성보다 작성 집중을 우선합니다.
- 프로젝트 목록이 많은 경우 바텀시트 스크롤 탐색이 필요합니다.

## Validation
- `flutter analyze lib/features/projects/presentation/widgets/project_selector.dart lib/features/feed/presentation/pages/post_create_page.dart lib/features/feed/presentation/pages/post_edit_page.dart lib/shared/main_scaffold.dart`

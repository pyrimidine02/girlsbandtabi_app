# ADR-20260307-post-compose-audience-like-project-chip

## Status
Accepted (2026-03-07)

## Context
- 작성/수정 화면에서 프로젝트 선택 위치와 방식이 레퍼런스의
  오디언스 칩 상호작용과 다르다는 피드백이 있었습니다.
- 사용자는 제목/본문 입력 영역을 단일 표면으로 유지하고,
  프로젝트 선택은 `모든 사람` 칩 위치처럼 즉시 접근 가능한
  상단 칩 형태를 요구했습니다.

## Decision
1. 프로젝트 선택 방식을 상단 칩으로 변경:
   - 아바타 우측 상단에 `ProjectAudienceSelectorCompact` 배치.
   - 탭 시 바텀시트(`프로젝트 선택`)에서 즉시 선택 가능.
2. 작성/수정 본문 영역의 별도 프로젝트 선택 행 제거.
3. 작성/수정 편집 표면은 theme surface를 사용:
   - light: 흰색
   - dark: 다크 서피스.

## Consequences
### Positive
- 프로젝트 선택 접근성이 높아지고 입력 흐름 중단이 줄어듭니다.
- 사용자가 제공한 레퍼런스와 상호작용 패턴이 더 유사해집니다.
- 라이트/다크 모드에서 작성 표면 일관성이 개선됩니다.

### Trade-offs
- 상단 칩 영역이 좁은 화면에서 긴 프로젝트명을 잘라 표시합니다.
- 바텀시트 프로젝트 리스트 탐색 비용은 프로젝트 수 증가에 따라 커질 수 있습니다.

## Validation
- `flutter analyze lib/features/projects/presentation/widgets/project_selector.dart lib/features/feed/presentation/pages/post_create_page.dart lib/features/feed/presentation/pages/post_edit_page.dart lib/shared/main_scaffold.dart`

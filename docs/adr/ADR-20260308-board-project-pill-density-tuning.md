# ADR-20260308-board-project-pill-density-tuning

## Status
Accepted (2026-03-08)

## Context
- 피드 상단 `프로젝트별` 옆 프로젝트 선택 알약이 상대적으로 크게 보여
  탭 행 가독성과 균형이 떨어졌습니다.
- 동일 컴포넌트는 작성 화면에서도 사용 중이어서, 전역 축소는 작성 UX에
  영향을 줄 수 있습니다.

## Decision
1. `ProjectAudienceSelectorCompact`에 `dense` 옵션을 추가한다.
2. 보드 상단(`프로젝트별` 옆)에서는 `dense: true`를 사용한다.
3. 작성/수정 화면은 기존 기본 크기(`dense: false`)를 유지한다.

## Consequences
### Positive
- 상단 탭 행에서 알약의 시각적 무게가 줄어 균형이 좋아집니다.
- 같은 컴포넌트를 컨텍스트별 밀도로 재사용할 수 있습니다.

### Trade-offs
- 컴포넌트 옵션이 1개 증가해 스타일 분기 관리가 필요합니다.

## Validation
- `flutter analyze lib/features/projects/presentation/widgets/project_selector.dart lib/features/feed/presentation/pages/board_page.dart`

# ADR-20260307-post-compose-audience-chip-size-and-transparent-inputs

## Status
Accepted (2026-03-07)

## Context
- 상단 프로젝트 선택 칩이 작성 화면에서 시각적으로 크다는 피드백이 있었습니다.
- 입력 영역은 박스/배경색 느낌 없이 더 가벼운 편집 캔버스가 필요했습니다.

## Decision
1. `ProjectAudienceSelectorCompact` 크기 축소:
   - 높이 `38 -> 32`
   - 내부 아이콘/텍스트/화살표 및 패딩을 함께 축소.
2. 제목/본문 TextField를 명시적으로 투명 fill로 설정:
   - `filled: true`
   - `fillColor: Colors.transparent`

## Consequences
### Positive
- 상단 칩 시각 비중이 줄어 제목/본문 입력 집중도가 올라갑니다.
- 입력 필드 배경색 인상이 제거되어 단일 캔버스 느낌이 강화됩니다.

### Trade-offs
- 칩 터치 타겟이 작아졌으므로 실제 기기 터치 정확도 QA가 필요합니다.

## Validation
- `flutter analyze lib/features/feed/presentation/pages/post_create_page.dart lib/features/feed/presentation/pages/post_edit_page.dart lib/features/projects/presentation/widgets/project_selector.dart`

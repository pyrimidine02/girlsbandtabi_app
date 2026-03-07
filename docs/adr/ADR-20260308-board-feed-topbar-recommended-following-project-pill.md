# ADR-20260308-board-feed-topbar-recommended-following-project-pill

## Status
Accepted (2026-03-08)

## Context
- 피드 상단 구성이 복잡했습니다:
  - 1차 탭(`추천/팔로잉/뉴스/콘텐츠`)
  - 2차 주제 칩(`전체` + 구독 프로젝트)
- 최신 요구사항은 상단을 단순화해
  `추천`, `팔로잉`, `프로젝트 선택 알약`만 남기고 `전체` 행을 제거하는 것입니다.

## Decision
1. 피드 상단 컨트롤을 `추천/팔로잉` 2개 모드 + 프로젝트 알약으로 재구성한다.
2. 작성 화면에서 사용 중인 `ProjectAudienceSelectorCompact`를 피드 상단에 재사용한다.
3. 기존 2차 주제 칩 행(`전체` 포함)을 제거한다.
4. 프로젝트 알약 선택 이벤트 시 프로젝트 피드 리스트(`_ProjectPostList`)로 전환한다.
5. `ProjectAudienceSelectorCompact`에 선택 이벤트 콜백(`onProjectSelected`)을 추가해
   상위 화면에서 전환 동작을 연결할 수 있게 한다.

## Consequences
### Positive
- 상단 정보 구조가 단순해져 피드 진입 인지 부하가 줄어듭니다.
- 작성 화면과 피드 화면의 프로젝트 선택 UI가 통일됩니다.
- 피드 상단 높이를 줄여 본문 가시 영역을 확보합니다.

### Trade-offs
- 기존 `뉴스/콘텐츠` 탭 직접 진입 경로는 제거되고, 프로젝트 선택 알약 중심 흐름으로 변경됩니다.

## Validation
- `flutter analyze lib/features/feed/presentation/pages/board_page.dart lib/features/projects/presentation/widgets/project_selector.dart`

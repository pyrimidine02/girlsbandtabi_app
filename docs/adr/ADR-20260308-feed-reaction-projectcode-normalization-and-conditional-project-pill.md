# ADR-20260308-feed-reaction-projectcode-normalization-and-conditional-project-pill

## Status
Accepted (2026-03-08)

## Context
- 커뮤니티 추천/팔로잉 피드는 여러 프로젝트 게시글이 섞여 내려옵니다.
- 반응(좋아요/북마크) 조회 시 `projectCodeOverride`에 UUID `projectId`가 전달되면서
  `/projects/{uuid}/posts/{id}/like|bookmark` 요청이 발생했고 404가 반복되었습니다.
- 상단 피드 컨트롤 UX 요구사항도 변경되어,
  `추천/팔로잉` 옆에 `프로젝트별` 버튼을 두고, 프로젝트 선택 알약은
  `프로젝트별` 탭에서만 노출해야 했습니다.

## Decision
1. 반응 컨트롤러에서 프로젝트 참조 정규화 로직을 추가한다.
   - 입력이 `projectCode`면 그대로 사용
   - 입력이 UUID `projectId`면 로드된 프로젝트 목록에서 `projectCode`로 변환
   - UUID인데 매핑 불가하면 유효하지 않은 UUID 경로 호출을 하지 않음
2. 피드 상단 탭을 `추천/팔로잉/프로젝트별`로 구성한다.
3. 프로젝트 선택 알약(`ProjectAudienceSelectorCompact`)은
   `프로젝트별` 탭일 때만 노출한다.

## Consequences
### Positive
- mixed-project 피드에서 반응 상태 조회 404 스팸이 줄어듭니다.
- 상단 컨트롤이 사용 의도(일반 피드 vs 프로젝트별 피드)에 맞게 명확해집니다.
- 작성 화면과 동일한 프로젝트 선택 알약 컴포넌트를 재사용해 UI 일관성을 유지합니다.

### Trade-offs
- 프로젝트 목록이 아직 로드되지 않은 타이밍에는 UUID 매핑이 제한될 수 있습니다.
- 이 경우 반응 조회는 선택 프로젝트 fallback 또는 no-call 경로에 의존합니다.

## Validation
- `flutter analyze lib/features/feed/application/reaction_controller.dart lib/features/feed/presentation/pages/board_page.dart lib/features/projects/presentation/widgets/project_selector.dart`

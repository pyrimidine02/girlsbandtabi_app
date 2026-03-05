# ADR-20260305-community-feed-phase6-compose-component-modularization

## Status
Accepted (2026-03-05)

## Context
- `PostCreatePage`와 `PostEditPage`는 공용 UI 블록(가이드 카드, 프로젝트 배지, 이미지 섹션, 이미지 타일, 로그인 안내, draft 복구 배너)을 거의 동일하게 중복 구현하고 있었습니다.
- 커뮤니티 개선 로드맵의 “대형 화면 파일 분해/모듈화” 항목을 진행하려면 중복 UI를 분리해 재사용 가능한 컴포넌트 계층을 먼저 만드는 것이 필요합니다.

## Decision
### 1) 작성/수정 공용 컴포넌트 파일 신설
- `lib/features/feed/presentation/widgets/post_compose_components.dart`를 추가.
- 아래 요소를 공용 컴포넌트로 이동:
  - `PostComposeStatusCard`
  - `PostComposeProjectBadge`
  - `PostComposeImageSection`
  - `PostComposePickedImageTile`
  - `PostComposeDraftRecoveryBanner`
  - `PostComposeLoginRequiredMessage`

### 2) 공용 본문 유틸 분리
- 이미지 마크다운 병합 로직을 `appendImageMarkdownContent`로 공용화.

### 3) 페이지 파일 경량화
- `PostCreatePage`/`PostEditPage`에서 중복 위젯/함수 정의를 제거하고 공용 컴포넌트 import로 교체.

## Consequences
### Positive
- 작성/수정 화면의 시각/동작 일관성이 강제됩니다.
- 추후 디자인/문구 변경 시 1곳 수정으로 양쪽 화면 반영이 가능합니다.
- 페이지 파일 길이와 책임이 줄어 유지보수성이 개선됩니다.

### Trade-offs
- 공용 컴포넌트 의존이 늘어나 개별 페이지에서 로컬 커스터마이징이 필요할 경우 props 확장이 필요합니다.

## Validation
- `flutter analyze lib/features/feed/presentation/widgets/post_compose_components.dart lib/features/feed/presentation/pages/post_create_page.dart lib/features/feed/presentation/pages/post_edit_page.dart` 통과
- `flutter test test/features/feed/application/post_compose_draft_store_test.dart test/features/feed` 통과

## Follow-up
- 작성/수정 공용 상태 로직(autosave/debounce/recovery)을 `controller + view state`로 승격해 화면 상태 책임을 더 줄입니다.
- compose 위젯 테스트(복구 배너, autosave 상태 텍스트, 이미지 섹션 버튼 상태)를 추가합니다.

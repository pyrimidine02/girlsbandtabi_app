# ADR-20260307-post-create-profile-edit-visual-alignment

## Status
Accepted (2026-03-07)

## Context
- `PostCreatePage`의 시각 구조가 `ProfileEditPage`와 달라 동일 앱 내 설정/작성 흐름에서 톤이 분리되어 보였습니다.
- 특히 작성 페이지는 상단 안내 카드/진행률 카드 중심이고, 프로필 수정은 섹션 헤더 + 카드 그룹 중심이라 정보 밀도와 시선 흐름이 달랐습니다.

## Decision
1. `PostCreatePage`를 `ProfileEditPage`와 동일한 섹션 카드 언어로 정렬:
   - `프로젝트`, `기본 정보`, `사진` 섹션 헤더 + 라운드 카드.
2. 주요 액션 위치를 일치:
   - 하단 고정 CTA 대신 AppBar 텍스트 액션(`등록`)으로 통일.
3. 이미지 섹션 컴포넌트 확장:
   - `PostComposeImageSection.useCardChrome` 옵션 추가.
   - 카드 내부 재사용 시 borderless 임베드 가능하게 조정.
4. 작성 화면 메타 노이즈/임시저장 생명주기 보정:
   - 프로젝트 카드 내 `현재 프로젝트: <slug>` 보조 문구 제거.
   - 업로드 성공 시 임시저장 draft를 삭제하고 dispose 단계에서 재저장되지 않도록 차단.
   - 임시저장 상태 메시지를 상단 섹션 근처로 이동해 가시성 확보.

## Consequences
### Positive
- 작성/설정 플로우의 시각 일관성이 개선됩니다.
- 작성 화면 상단 크롬이 단순화되어 입력 영역 집중도가 올라갑니다.
- 이미지 섹션 컴포넌트 재사용성이 증가합니다.

### Trade-offs
- 기존 하단 고정 버튼에 익숙한 사용자에게는 액션 위치 변화가 있을 수 있습니다.
- 작성/수정 페이지 간 UI 패턴 차이가 일부 남아(수정 페이지는 기존 레이아웃 유지) 추가 정렬 여지가 있습니다.

## Validation
- `flutter analyze lib/features/feed/presentation/pages/post_create_page.dart lib/features/feed/presentation/widgets/post_compose_components.dart`
- `flutter test test/features/feed/application/post_compose_autosave_controller_test.dart`
- `flutter test test/features/feed/presentation/pages/post_compose_autosave_integration_test.dart`

# ADR-20251129: KT UXD v1.1 Redesign for Community, Favorites, and Notifications

## Status
**Accepted** – Implemented on 2025-11-29

## Context
- 홈/라이브/순례 등 주요 화면은 이미 KT UXD v1.1 레이아웃과 컴포넌트로 마이그레이션을 완료했으나, 커뮤니티/즐겨찾기/알림 화면은 기존 iOS 스타일 위젯과 기본 Scaffold를 유지하고 있어 비주얼 일관성과 접근성이 깨져 있었다.
- 프로젝트 레벨에서 KT UXD v1.1 전체 구현(디자인 토큰, KTButton, Flow 컴포넌트 등)을 완료한 상태이므로, 구현한 토큰과 컴포넌트를 삭제하거나 퇴행시키지 않고 화면만 교체해야 했다.
- 커뮤니티 모듈은 향후 AI 요약, 라이브 피드 등 확장을 계획하고 있어, 헤더/탭/포스트 카드가 KT UXD의 모듈식 패턴을 따라야 했다.
- 즐겨찾기/알림 화면은 데이터 소스 및 Riverpod 상태 관리가 이미 존재하므로, UI 레이어만 교체하면서 무한 스크롤·읽음 처리 등 기존 로직을 유지해야 했다.

## Decision
리스트/폼/디테일 화면을 모두 KT UXD v1.1 패턴으로 재구성하되, 기존 서비스/Provider/도메인 로직은 유지한다.

### Community
- `CommunityScreen`을 FlowGradientBackground + FlowCard hero + KT 탭 구조로 재작성하고, `_CommunityPostCard` 등 세부 카드도 KT Typography/Spacing을 따른다.
- `PostCreateScreen`은 KTTextField/KTTextArea/KTCheckbox/KTButton을 사용해 Seamless Flow 글쓰기 경험과 임시 저장/옵션 토글을 제공한다.
- `PostDetailScreen`은 FlowCard 기반의 헤더/본문/댓글 콜투액션으로 리디자인하여 시맨틱 강조와 후속 액션 버튼을 통합했다.

### Favorites
- Riverpod 기반 데이터 흐름을 유지하면서 `FlowCard` 요약 타일과 `FlowEmptyState`를 도입하여 에러/빈 상태를 통일했다.
- 즐겨찾기 필터는 KT 스타일 칩으로 교체하여 rebuild scope를 줄이고 터치 타겟을 WCAG 수준으로 확장했다.

### Notifications
- 기존 Scaffold + ListTile 구성을 KTAppLayout, FlowCard 헤더, KTButtons로 교체하고, NotificationService를 그대로 재사용하는 mark-read UX를 구성했다.

### Shared Component
- 다양한 화면에서 동일한 UX를 확보하기 위해 `FlowEmptyState` 위젯을 `lib/widgets/flow_components.dart`에 추가했다.

## Consequences
### Positive
1. 커뮤니티/즐겨찾기/알림이 모두 KT UXD 시각 언어와 상호작용 패턴을 따르면서 앱 전반의 일관성이 확보되었다.
2. 기존 Service/Provider 레이어를 수정하지 않아 회귀 위험 없이 UI 레이어만 교체할 수 있었다.
3. 새로 도입한 `FlowEmptyState`와 KTButton 기반 CTA 덕분에 빈 상태/오류 상태 처리 코드가 재사용 가능해졌다.
4. KTTextField/KTTextArea/KTButton/KTIconButton 등 이미 구현된 컴포넌트를 소모하여 “구현된 것은 삭제하지 않는다”라는 요구사항을 충족했다.

### Negative / Risks
1. 커뮤니티/즐겨찾기 화면이 FlowCard와 대형 그래디언트를 사용하기 때문에 저사양 기기에서 약간의 렌더링 비용이 증가할 수 있다. 필요 시 RepaintBoundary 추가나 이미지 캐싱을 고려해야 한다.
2. 알림 화면은 여전히 NotificationService의 polling 기반 FutureBuilder에 의존하므로, 향후 스트리밍 방식으로 전환할 때 UI 업데이트가 한 번 더 필요하다.
3. 일부 버튼은 현재 SnackBar 모의동작을 사용하고 있어, 백엔드 API 연결 시엔 실제 내비게이션/서비스 호출로 교체해야 한다.

## Follow-up
- 커뮤니티 탭 데이터를 실제 API와 연결하고, 포스트 작성/상세 화면과 라우팅을 정식으로 고도화한다.
- 즐겨찾기/알림 화면에서의 성능을 모니터링하고 필요 시 `ListView` → `SliverList` 전환 등 최적화를 고려한다.
- `FlowEmptyState`를 다른 레거시 화면에도 단계적으로 적용하여 빈 상태 표준을 통일한다.

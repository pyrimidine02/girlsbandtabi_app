# ADR-20260307-post-detail-profile-entry-and-user-profile-refresh

## Status
Accepted (2026-03-07)

## Context
- 게시글 상세에서 작성자 영역에 `팔로우`와 `프로필 보기` 버튼이 동시에 존재해 시선 분산이 발생했다.
- 작성자 프로필 진입 동선이 화면마다 다르게 느껴져 학습 비용이 올라갔다.
- 사용자 프로필 헤더가 상대적으로 무겁고 액션 버튼 밀도가 높아, 핵심 정보(이름/소개/팔로우 상태) 스캔 속도가 떨어졌다.

## Decision
1. 게시글 상세 작성자 영역의 프로필 진입 동선을 단일화한다.
   - 별도 `프로필 보기` 텍스트 버튼을 제거하고, 아바타 탭만 프로필 진입 CTA로 사용.
2. 게시글 상세 `팔로우` CTA를 컴팩트 스타일로 축소한다.
   - 높이/패딩을 줄인 작은 tonal pill(`27px`)로 조정.
3. 사용자 프로필 헤더를 카드형 구조로 재설계한다.
   - compact cover + avatar + name/summary + bio + action row + stats 순서로 정보 위계를 단순화.
   - 타 사용자 프로필 액션은 `팔로우/차단` compact pill row로 통일.
4. 프로필 페이지 상단 타이틀을 컨텍스트 기반으로 변경한다.
   - 내 프로필: `내 프로필`
   - 타 사용자 프로필: 대상 display name

## Reference Notes
- X Help Center: 프로필 사진/이름 탭을 통한 프로필 진입이 기본 패턴임을 참고.
- Apple Human Interface Guidelines (Accessibility): 터치 대상 크기와 스캔 가능한 계층 구조 원칙을 반영.
- Material Design button hierarchy(tonal/outlined): primary/secondary 액션 대비를 단순화하는 원칙을 반영.

## Consequences
### Positive
- 작성자 영역의 CTA가 단순해져 의사결정 비용이 낮아진다.
- 팔로우 버튼의 시각적 존재감이 줄어, 본문/메타 정보와의 균형이 좋아진다.
- 프로필 화면에서 핵심 정보와 액션의 우선순위가 명확해진다.

### Trade-offs
- 아바타 탭 기반 내비게이션을 처음 사용하는 사용자에게는 명시적 텍스트 CTA가 줄어들었다.
- 프로필 헤더 구조 변경으로 기존 스크린샷/디자인 QA 기준을 업데이트해야 한다.

## Validation
- `dart format lib/features/feed/presentation/pages/post_detail_page.dart lib/features/feed/presentation/pages/user_profile_page.dart`
- `flutter analyze lib/features/feed/presentation/pages/post_detail_page.dart lib/features/feed/presentation/pages/user_profile_page.dart`

## Follow-up
- 실제 디바이스에서 작은 화면(iPhone mini급/Android compact width) 기준 follow/block 버튼 탭 정확도 QA를 수행한다.
- 필요 시 아바타 진입 affordance 강화를 위해 작성자명/서브텍스트에도 동일 내비게이션을 확장 검토한다.

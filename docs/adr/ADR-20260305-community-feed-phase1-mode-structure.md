# ADR-20260305-community-feed-phase1-mode-structure

## Status
Accepted (2026-03-05)

## Context
- 사용자 요청(`/Users/sonhoyoung/Downloads/community.md`)에서 커뮤니티 상단 정보구조를 `추천/팔로우/최신/인기` 기준으로 재정렬하는 1차 개선이 요구됨.
- 기존 구현은 `최신/트렌딩/구독 피드` 3모드이며, 칩 순서가 선택 상태에 따라 동적으로 섞여 탐색 예측성이 낮음.
- 현재 백엔드에는 추천 전용 endpoint가 확정되지 않아 프런트에서 단계적 도입이 필요함.

## Decision
### 1) 모드 체계 4분할
- `CommunityFeedMode`를 `recommended/following/latest/trending`으로 확장.
- 기본 진입 모드를 `recommended`로 변경.
- 라벨을 `추천/팔로우/최신/인기`로 통일.

### 2) 상단 모드 칩 고정 순서
- `_CommunityTab` 필터 칩을 “활성칩 우선 정렬”에서 고정 순서 렌더링으로 변경:
  - `추천 → 팔로우 → 최신 → 인기`
- 선택 상태는 스타일만 변경하고 위치는 바꾸지 않음.

### 3) 추천 모드 단계적 매핑
- 추천 전용 API 부재로 1차에서는 `recommended`를 기존 cursor 최신 피드(`getPostsByCursor`)에 매핑.
- 추천 모드 진입 시 안내 문구(`_RecommendationModeHint`)를 노출해 의도를 명시.
- 인기 캐러셀은 `추천/최신`에서 모두 노출.

## Consequences
### Positive
- 커뮤니티 피드의 상단 정보 구조가 X/피드형 앱 패턴에 맞게 명확해짐.
- 모드 칩 위치 고정으로 사용자가 탭 위치를 학습하기 쉬워짐.
- 추천 전용 서버 계약 전에도 UI 전환을 선제적으로 진행 가능.

### Trade-offs
- `recommended`와 `latest` 데이터 소스가 현재 동일하여 초기에 체감 차이가 제한적임.
- 추천 근거(reason/context) 노출은 백엔드 확장 전까지 미완료 상태.

## Validation
- `flutter analyze lib/features/feed/application/board_controller.dart lib/features/feed/presentation/pages/board_page.dart` 통과

## Follow-up
- 추천 전용 endpoint(또는 recommendation context 필드) 확정 시 `recommended` 분기 데이터 소스를 교체.
- 2차 단계에서 카드 레벨 반응(좋아요/북마크) 즉시 토글 및 batch viewer-state 계약을 연결.

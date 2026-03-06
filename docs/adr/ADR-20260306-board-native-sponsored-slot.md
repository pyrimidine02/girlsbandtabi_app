# ADR-20260306-board-native-sponsored-slot

## Status
Accepted (2026-03-06)

## Context
- 사용자 요청으로 커뮤니티 피드에 "토스처럼 자연스럽게 보이는 광고 자리"가 필요했습니다.
- 동시에 강제 전환형(시간 경과 후 자동 노출/전면 전환) 광고는 금지 조건이었습니다.
- 현재 게시판 리스트는 게시글만 렌더링하고 있어 광고 슬롯 삽입 시 인덱스 매핑 안정성 보장이 필요했습니다.

## Decision
### 1) 인라인 스폰서 슬롯 방식 채택
- 전면 인터스티셜/타이머 광고 없이, 기존 게시글 카드와 동일한 밀도의 리스트 카드로만 노출합니다.
- `GBTSponsoredSlotCard`를 추가해 피드 카드 톤과 동일한 표면/보더/패딩 시스템을 사용합니다.

### 2) 결정적(deterministic) 배치 계산기 추가
- `FeedNativeAdPlacement`를 도입해 게시글 인덱스와 광고 슬롯 인덱스를 안정적으로 매핑합니다.
- 규칙:
  - 상단 4개 게시글은 광고 없이 유지
  - 이후 6개 게시글마다 슬롯 1개 삽입
  - 슬롯 순번(`adOrdinal`)으로 캠페인 회전

### 3) 게시판 리스트 2곳에 동일 적용
- 프로젝트 게시글 리스트 (`_ProjectPostList`)
- 커뮤니티 통합 피드 리스트 (`_CommunityList`)
- 슬롯 탭 시 앱 내부 주요 섹션(`장소`, `라이브`, `여행후기`)으로 이동하도록 연결

### 4) 광고 밀도 완화 + 홈 1개 슬롯 추가
- 피드 심리적 거부감을 줄이기 위해 스폰서 슬롯 밀도를 대폭 완화:
  - 상단 10개 게시글 이후 노출
  - 이후 간격 18개 게시글
  - 하드캡 1개(리스트당 최대 1개)
- 홈 화면에는 자연 노출용 슬롯을 1개만 추가하고, 전면/타이머 광고는 계속 금지 유지.

## Consequences
### Positive
- 사용자 스크롤 흐름을 끊지 않는 "네이티브 광고 자리"를 확보했습니다.
- 전면/타이머 광고가 없어 UX 침습도가 낮습니다.
- 피드 광고 밀도를 낮춰 과다 노출로 인한 피로도를 줄였습니다.
- 배치 계산기를 분리해 리스트 로직 변경 시 회귀를 줄일 수 있습니다.

### Trade-offs
- 현재는 정적 캠페인 문구/라우팅만 제공하며 외부 광고 네트워크, 노출/클릭 측정은 미연동 상태입니다.
- 슬롯이 리스트 중간에 삽입되므로 게시글 절대 인덱스 기반 UI 로직이 있다면 `postIndex` 매핑을 사용해야 합니다.

## Validation
- `flutter analyze lib/features/feed/presentation/pages/board_page.dart lib/features/feed/presentation/models/feed_native_ad_placement.dart lib/core/widgets/cards/gbt_sponsored_slot_card.dart`
- `flutter test test/features/feed/presentation/models/feed_native_ad_placement_test.dart`

## Follow-up
- 백엔드 광고/프로모션 계약이 확정되면 슬롯 콘텐츠를 서버 주도형으로 전환하고 노출/클릭 이벤트 트래킹을 추가합니다.

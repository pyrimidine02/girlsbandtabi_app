# ADR-20260306-hybrid-sponsored-slot-admob-house

## Status
Accepted (2026-03-06)

## Context
- 사용자 요구사항: 강제 전환형 광고 없이 자연스러운 인라인 광고를 유지하면서, 외부 광고(수익화)와 개인 프로모션(하우스 캠페인)을 함께 운영.
- 기존 구현은 정적 스폰서 카드만 존재하여 네트워크 광고/서버 의사결정/이벤트 추적이 불가능했습니다.

## Decision
### 1) 하이브리드 슬롯 아키텍처 도입
- `features/ads` 모듈 추가:
  - domain: `AdSlotRequest`, `AdSlotDecision`, `AdDeliveryType`, `AdEventType`
  - data: `AdsRemoteDataSource`, `AdsRepositoryImpl`, decision/event DTO
  - application: `adSlotDecisionProvider`, `adEventTrackerProvider`
  - presentation: `HybridSponsoredSlot` (House + AdMob Native fallback/전환)

### 2) 슬롯별 전략 분리
- 홈 슬롯: 기본 `house` 전략(개인 프로모션 우선).
- 게시판 피드 슬롯: 기본 `networkThenHouse` 전략(외부 광고 우선, 실패 시 하우스 카드).
- 피드 노출 밀도는 기존 완화 정책 유지(최대 1개/리스트).

### 3) 외부 광고 SDK 기본선
- `google_mobile_ads` 추가.
- 앱 시작 시 `MobileAds.instance.initialize()` 호출.
- Android/iOS에 테스트 App ID 기본 설정:
  - Android: `ca-app-pub-3940256099942544~3347511713`
  - iOS: `ca-app-pub-3940256099942544~1458002511`
- 실서비스는 `--dart-define`으로 실제 유닛 ID 주입:
  - `ADMOB_ANDROID_NATIVE_HOME_UNIT_ID`
  - `ADMOB_IOS_NATIVE_HOME_UNIT_ID`
  - `ADMOB_ANDROID_NATIVE_BOARD_UNIT_ID`
  - `ADMOB_IOS_NATIVE_BOARD_UNIT_ID`

## Consequences
### Positive
- 개인 프로모션과 외부 광고를 하나의 슬롯 체계로 함께 운영 가능.
- 백엔드 결정(`house/network/none`)으로 노출 전략을 서버 주도 제어 가능.
- 네트워크 광고 실패 시 하우스 카드로 UX 공백 최소화.

### Trade-offs
- Native ad 렌더링은 플랫폼 의존성이 있어 OS/SDK 버전에 따른 QA가 필요.
- 백엔드 결정 API가 미구현이면 클라이언트 폴백 전략에 의존.

## Validation
- `flutter analyze` (ads/home/board 관련 파일)
- `flutter test test/features/feed/presentation/models/feed_native_ad_placement_test.dart`

## Follow-up
- 백엔드 결정/이벤트 API가 확정되면 decision payload 필드(타겟 URL/빈도제한/세그먼트)를 서버 계약과 1:1로 정렬.
- 운영 환경 App ID/Ad Unit ID를 테스트 값에서 실값으로 교체.

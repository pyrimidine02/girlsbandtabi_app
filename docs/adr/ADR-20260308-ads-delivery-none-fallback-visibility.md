# ADR-20260308-ads-delivery-none-fallback-visibility

## Status
Accepted

## Date
2026-03-08

## Context
- 광고 슬롯 API는 `deliveryType=none`을 반환할 수 있고, 기존 앱은 해당 경우
  슬롯을 `SizedBox.shrink()`로 완전히 숨겼다.
- 실사용에서 `none` 응답이 내려올 때 광고 영역이 빈 공백처럼 사라져
  "광고가 안 나온다"는 체감 이슈가 반복되었다.
- 동시에 서버 계약상 `none=숨김` 정책 자체는 유지해야 하므로
  전역 동작을 강제 변경하면 다른 슬롯 정책을 깨뜨릴 수 있다.

## Decision
1. `HybridSponsoredSlot`에 `DeliveryNoneStrategy`를 추가한다.
   - `hide`(기본): 기존 계약대로 슬롯 숨김
   - `fallback`: 로컬 폴백 카드 렌더
2. 홈/피드 광고 슬롯은 `deliveryNoneStrategy: fallback`을 적용한다.
   - Home: `_HomeSponsoredSlot`
   - Feed: `_FeedSponsoredCard`
3. `fallback` 경로에서는 `decision`을 `null`로 전달해
   `deliveryType=none` 결정에 대해 이벤트 트래킹(`ads/events`)을 보내지 않는다.

## Alternatives Considered
1. `none`일 때 항상 숨김 유지
   - 서버 계약과는 일치하지만 사용자 체감 이슈(광고 미노출 인지)를 해결하지 못한다.
2. 앱 전역에서 `none`을 모두 폴백으로 강제
   - 빠르지만 슬롯별 정책 유연성을 잃고, 향후 숨김이 필요한 슬롯에 불리하다.

## Consequences
### Positive
- 홈/피드에서 광고 영역이 사라지는 UI 공백을 줄인다.
- 슬롯별로 `none` 처리 정책을 선택할 수 있어 운영/실험 대응이 쉬워진다.

### Trade-offs
- 서버가 `none`으로 숨김을 의도한 경우에도 해당 슬롯에서는 로컬 프로모션이 노출된다.
- 정책 일관성을 위해 슬롯별 전략값 관리가 필요하다.

## Scope
- `lib/features/ads/presentation/widgets/hybrid_sponsored_slot.dart`
- `lib/features/home/presentation/pages/home_page.dart`
- `lib/features/feed/presentation/pages/board_page.dart`

## Validation
- `flutter analyze lib/features/ads/presentation/widgets/hybrid_sponsored_slot.dart lib/features/home/presentation/pages/home_page.dart lib/features/feed/presentation/pages/board_page.dart`
- `flutter test test/features/ads/data/ad_slot_decision_dto_test.dart test/features/ads/data/ads_repository_impl_test.dart`

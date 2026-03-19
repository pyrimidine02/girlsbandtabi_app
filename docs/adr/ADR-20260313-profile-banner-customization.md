# ADR-20260313: Profile Banner Customization Feature

## 상태 (Status)
Implemented

## 배경 (Background)

홈 페이지의 `GBTGreetingHeader`는 기본 인디고 그라디언트 배경을 표시하거나,
콘텐츠에서 파생된 배경 이미지(트렌딩 라이브 포스터 등)를 표시합니다.
사용자가 자신만의 배경(배너)을 선택·적용할 수 있는 개인화 기능이 요구되었습니다.
배너는 티어 달성이나 칭호 획득으로 해금되는 잠금 시스템을 가집니다.

## 문제 (Problem)

1. 홈 헤더 배경이 시스템 선택(콘텐츠 파생)에만 의존하여 개인화 불가.
2. 배너 카탈로그·해금 상태를 서버에서 관리하므로 Clean Architecture에 맞는 계층 분리 필요.
3. 배너는 자주 변경되지 않으나 네트워크 비용을 줄이기 위한 캐싱 전략이 필요.

## 결정 (Decision)

### 아키텍처

```
features/profile_banner/
  domain/
    entities/banner_entities.dart       — BannerRarity, BannerUnlockType, BannerItem, ActiveBanner
    repositories/banner_repository.dart — 추상 리포지토리 계약
  data/
    dto/banner_dto.dart                 — BannerItemDto, ActiveBannerDto (fromJson/toJson)
    datasources/banner_remote_data_source.dart
    repositories/banner_repository_impl.dart
  application/
    banner_controller.dart              — ActiveBannerNotifier, BannerCatalogNotifier, providers
  presentation/
    pages/banner_picker_page.dart       — ConsumerStatefulWidget 전체 페이지 피커
```

### 상태 관리

- `activeBannerProvider`: `StateNotifierProvider` (long-lived, 탭 전환 시 유지)
  - `setActive(bannerId)`: 낙관적 업데이트 + 롤백
  - `clearActive()`: 배너 제거
- `bannerCatalogProvider`: `StateNotifierProvider.autoDispose` (피커 페이지 전용)
  - `applyBanner(bannerId)`: active 설정 + catalog 갱신
- `bannerRepositoryProvider`: `FutureProvider` — CacheManager 비동기 의존성 처리

### 캐싱

| 리소스 | 캐시 키 | 정책 | TTL |
|---|---|---|---|
| 활성 배너 | `banner:active` | staleWhileRevalidate | 10분 |
| 배너 카탈로그 | `banner:catalog` | staleWhileRevalidate | 1시간 |

set/clear 변이 시 `banner:active` 캐시를 즉시 갱신/제거하여 일관성 유지.

### GBTGreetingHeader 변경

- 신규 파라미터:
  - `userBannerUrl`: 사용자 배너 URL. 지정 시 콘텐츠 파생 배경보다 우선 적용.
  - `onCustomizeTap`: 팔레트 아이콘 버튼 콜백. null이면 버튼 미표시.
- 기존 파라미터 및 동작 완전 하위 호환 유지.

### 라우팅

- `/banner-picker` 경로: shell 외부 overlay 라우트 (`_buildAdaptiveOverlayPage` 사용)
- `AppRoutes.bannerPicker = 'banner-picker'` 상수 추가

## 대안 (Alternatives Considered)

1. **BottomSheet로 피커 표시**: 배너 그리드 크기를 고려하면 전체 페이지 라우트가 UX상 더 적합.
2. **InheritedWidget 패턴**: 기존 프로젝트가 Riverpod 패턴을 일관되게 사용 중이므로 채택하지 않음.
3. **카탈로그 캐시 없이 매번 fetch**: 배너는 자주 변경되지 않고 1시간 TTL이 합리적.

## 영향 범위 (Impact)

- `lib/core/constants/api_constants.dart`: 엔드포인트 상수 추가
- `lib/core/widgets/layout/gbt_greeting_header.dart`: 파라미터 추가 (하위 호환)
- `lib/features/home/presentation/pages/home_page.dart`: activeBannerProvider watch 추가
- `lib/core/router/app_router.dart`: 라우트 추가

## 남은 과제 (Follow-up)

- 서버 배너 API 엔드포인트 구현 확인
- `BannerPickerPage` 위젯 테스트 추가
- 배너 해금 조건 알림/표시 방식 디자인 확정

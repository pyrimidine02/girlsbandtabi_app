# ADR-20260330: Cache tiering and sensitive local storage hardening

## Status
- Accepted (2026-03-30)

## 변경 전 문제
- 앱 응답 속도 최적화를 위해 LocalStorage 캐시를 폭넓게 사용하고 있었지만,
  메모리 hit 최적화(L1)가 없어 반복 조회 시 디스크 접근 비용이 남아 있었습니다.
- 작성 draft는 보관 기간 정책이 없어 장기 잔존할 수 있었고,
  로그아웃 시 draft key 정리가 보장되지 않았습니다.
- 푸시 등록 식별자(`notificationDeviceId`, `notificationPushToken`)가
  LocalStorage 경로에 남을 수 있어 민감 식별자 저장 강도가 부족했습니다.

## 대안
1. 현 상태 유지(LocalStorage 중심 캐시, 추가 분류 없음).
2. 모든 캐시를 SecureStorage로 이동.
3. 데이터 민감도에 따라 저장소를 분리하고, 캐시는 L1 메모리 + LocalStorage를 조합.

## 결정
- 대안 3을 채택했습니다.
- 비민감 캐시는 `CacheManager`에서 `L1 in-memory (bounded)` + `LocalStorage`를
  함께 사용하는 tiered cache로 구성했습니다.
  - `getJsonEntry`: memory-first
  - `setJson/remove/removeByPrefix/clearAll`: memory + local 동기 정리
  - 기본 메모리 용량: 300 entries (`memoryCacheCapacity` 주입 가능)
- 작성 draft는 보관 기간을 기본 30일로 제한하고,
  만료 draft는 조회 시 즉시 삭제합니다.
- 로그아웃 시 draft key prefix(`feed_post_create_draft_*`,
  `feed_post_edit_draft_*`)를 스캔해 사용자 잔존 데이터를 정리합니다.
- 푸시 등록 식별자(`deviceId`, `pushToken`)는 SecureStorage 우선 저장으로 전환하고,
  legacy LocalStorage 값은 fallback/migration 후 정리합니다.
  - 등록 해제 성공/404 시 secure + legacy 키를 함께 제거합니다.

## 근거
- 메모리 cache hit는 빈번한 동일 key 재조회에서 디스크 I/O를 줄여
  체감 응답 시간을 개선합니다.
- draft TTL + 로그아웃 정리는 사용자 작성 흔적의 과도한 잔존을 줄입니다.
- 디바이스 등록 식별자는 토큰과 함께 취급해야 하는 민감 식별자이므로
  SecureStorage가 LocalStorage보다 적절합니다.

## 영향 범위
- 런타임:
  - `lib/core/cache/cache_manager.dart`
  - `lib/features/feed/application/post_compose_draft_store.dart`
  - `lib/features/auth/application/auth_controller.dart`
  - `lib/core/security/secure_storage.dart`
  - `lib/core/notifications/remote_push_service.dart`
  - `lib/core/providers/core_providers.dart`
  - `lib/features/settings/application/settings_controller.dart`
- 테스트:
  - `test/core/cache/cache_manager_test.dart`
  - `test/features/feed/application/post_compose_draft_store_test.dart`
  - `test/core/notifications/remote_push_service_test.dart` (신규)
  - `test/features/settings/application/settings_controller_test.dart`

## Validation
- `flutter test test/core/cache/cache_manager_test.dart test/features/feed/application/post_compose_draft_store_test.dart test/core/notifications/remote_push_service_test.dart test/features/settings/application/settings_controller_test.dart test/features/feed/application/post_compose_autosave_controller_test.dart test/features/feed/presentation/pages/post_compose_autosave_integration_test.dart` passed.
- `flutter analyze lib/core/cache/cache_manager.dart test/core/cache/cache_manager_test.dart lib/features/feed/application/post_compose_draft_store.dart test/features/feed/application/post_compose_draft_store_test.dart lib/features/auth/application/auth_controller.dart lib/core/security/secure_storage.dart lib/core/notifications/remote_push_service.dart lib/core/providers/core_providers.dart lib/features/settings/application/settings_controller.dart test/core/notifications/remote_push_service_test.dart test/features/settings/application/settings_controller_test.dart` passed.


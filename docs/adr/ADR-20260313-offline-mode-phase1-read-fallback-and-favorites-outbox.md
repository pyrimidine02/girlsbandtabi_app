# ADR-20260313: Offline Mode Phase 1 (Read Fallback + Favorites/Post-Reaction/Live-Attendance Outbox)

- Date: 2026-03-13
- Status: Accepted
- Scope:
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/cache/cache_manager.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/providers/core_providers.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/error/failure.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/storage/local_storage.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/favorites/application/favorites_controller.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/favorites/application/pending_favorite_mutation.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/application/reaction_controller.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/application/pending_post_reaction_mutation.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/live_events/application/live_events_controller.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/live_events/application/pending_live_attendance_mutation.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/app.dart`

## Context
- 앱은 오프라인 배너는 있었지만, 데이터 계층이 오프라인을 적극 인지하지 않아
  일부 경로에서 네트워크 호출/재시도와 불필요한 에러 로그가 발생했습니다.
- 쓰기 작업은 온라인 전제가 강해 오프라인 토글 액션(예: 즐겨찾기)이
  사용자 의도 대비 실패 UX로 보일 가능성이 있었습니다.

## Decision
- 캐시 매니저에 네트워크 가용성 프로브를 주입하고,
  오프라인 시 읽기 정책을 `cacheOnly`로 일괄 폴백합니다.
  - 캐시 미스는 `CacheFailure(code=offline_cache_miss)`로 구분합니다.
- `CacheFailure` 메시지에서 `offline_cache_miss`를 별도 문구로 노출합니다.
- 즐겨찾기 토글에 오프라인 대기 큐(Outbox)를 도입합니다.
  - 오프라인 토글은 낙관적 UI 반영 후 로컬 대기열에 저장
  - 동일 entity/type 작업은 최신 의도 상태로 dedupe
  - 온라인 복귀(연결 이벤트/로그인 복귀) 시 자동 동기화
- 게시글 좋아요/북마크 토글에도 오프라인 대기 큐를 적용합니다.
  - 오프라인 토글 즉시 낙관적 반영
  - 앱 전역 bootstrap(`postReactionOutboxBootstrapProvider`)으로 자동 동기화
  - unlike 500(UUID 재시도) 우회 로직을 outbox 동기화 경로에도 반영
- 라이브 출석 토글에도 오프라인 대기 큐를 적용합니다.
  - 오프라인 토글 즉시 낙관적 반영 후 로컬 대기열에 저장
  - 앱 전역 bootstrap(`liveAttendanceOutboxBootstrapProvider`)으로 자동 동기화
  - 대기열 동기화 실패 시 네트워크/인증 오류만 재시도 대상으로 유지

## Alternatives Considered
1. 기존 repository별 `networkFirst` 예외 처리만 확장
   - Rejected: feature별 중복 코드와 정책 불일치가 커집니다.
2. 전면 Outbox(모든 쓰기 액션 동시 도입)
   - Rejected: 이미지 업로드/충돌 처리까지 포함 시 위험도가 높아
     단계적 적용이 더 안전합니다.

## Consequences
- 읽기 경로에서 오프라인 체감 안정성이 즉시 개선됩니다.
- 즐겨찾기 토글은 연결 상태와 무관하게 사용자 의도 중심 UX를 제공할 수 있습니다.
- 좋아요/북마크/출석 토글 모두 동일한 Outbox 패턴으로 운영되어 유지보수 일관성이 높아집니다.

## Validation
- `flutter analyze`
- `flutter test test/core/cache/cache_manager_test.dart`
- `flutter test test/features/feed/application/pending_post_reaction_mutation_test.dart`
- `flutter test test/features/live_events/application/pending_live_attendance_mutation_test.dart`

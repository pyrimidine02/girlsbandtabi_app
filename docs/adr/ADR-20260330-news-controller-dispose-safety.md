# ADR-20260330: News controller dispose-safety for async load

## Status
- Accepted (2026-03-30)

## 변경 전 문제
- Crashlytics에서 아래 시그니처가 집계되었습니다.
  - `Bad state: Tried to use NewsListController after dispose was called`
  - stack: `NewsListController.load` (`state = ...` 지점)
- `newsListControllerProvider`/`newsDetailControllerProvider`는 `autoDispose`이며,
  탭 전환/뒤로가기 후 비동기 요청이 완료되면 dispose된 notifier에 `state`를
  다시 쓰는 경쟁 상태가 발생할 수 있었습니다.

## 대안
1. `load()` 호출을 화면 생명주기에 더 강하게 묶어 dispose 시점 이전에만 실행한다.
2. 요청 취소 토큰/CancelableOperation을 도입해 dispose 시 네트워크 요청 자체를 취소한다.
3. 컨트롤러 내부에서 비동기 경계마다 `mounted`를 확인하고,
   dispose 이후 `state` 갱신을 무시한다.

## 결정
- 대안 3을 우선 적용합니다.
- `NewsListController.load`와 `NewsDetailController.load`에
  `mounted` 가드를 추가했습니다.
  - 진입 직후
  - `state = AsyncLoading()` 직전
  - `feedRepositoryProvider.future` await 직후
  - API 응답 await 직후
- 재현 회귀를 막기 위해 테스트를 추가했습니다.
  - 요청 시작 후 컨테이너를 dispose한 뒤 응답을 완료해도
    `load()`가 예외 없이 종료되는지 검증.

## 근거
- 원인 시그니처가 `StateNotifier`의 dispose 후 state 쓰기와 정확히 일치합니다.
- `mounted` 가드는 Riverpod `StateNotifier` 수명주기와 직접 호환되며
  최소 변경으로 크래시를 차단합니다.
- 취소 토큰 도입(대안 2)은 효과가 크지만 리포지토리/데이터소스 계층까지
  범위가 확장되므로 이번 hot-fix 범위를 초과합니다.

## 영향 범위
- 런타임:
  - `lib/features/feed/application/news_controller.dart`
- 테스트:
  - `test/features/feed/application/news_controller_test.dart` (신규)
- QA:
  - 빠른 탭 전환/뒤로가기 상황에서 동일 Crashlytics 시그니처 재발 여부 모니터링 필요

## Validation
- `flutter test test/features/feed/application/news_controller_test.dart` passed.
- `flutter analyze lib/features/feed/application/news_controller.dart test/features/feed/application/news_controller_test.dart` passed.

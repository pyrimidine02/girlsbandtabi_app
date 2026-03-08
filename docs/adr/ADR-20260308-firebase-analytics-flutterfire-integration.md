# ADR-20260308-firebase-analytics-flutterfire-integration

## Status
Accepted

## Date
2026-03-08

## Context
- iOS 네이티브 가이드는 Xcode `Add Packages`로 FirebaseAnalytics를 추가하지만,
  본 프로젝트는 Flutter 앱이며 의존성 관리는 `pubspec.yaml` + CocoaPods
  (FlutterFire plugin) 체계를 사용한다.
- 기존 `AnalyticsService`는 no-op으로 콘솔 로그만 남겨 실제 분석 전송이 없었다.

## Decision
1. Firebase Analytics는 Flutter dependency(`firebase_analytics`)로 추가한다.
2. `AnalyticsService`를 Firebase Analytics 기반 구현으로 전환한다.
3. Firebase 초기화는 lazy 방식으로 처리하고,
   - bundled config 우선
   - 필요 시 runtime options(`firebase_runtime_options.dart`) 폴백
   으로 안정성을 확보한다.
4. Firebase 옵션이 없는 환경에서는 debug log-only로 안전하게 degrade한다.

## Alternatives Considered
1. Xcode `Add Packages` 직접 사용
   - Flutter 의존성/플러그인 관리 경로와 분리되어 유지보수 리스크가 높다.
2. 기존 no-op 유지
   - 제품 분석 지표 수집 요구를 충족하지 못한다.

## Consequences
### Positive
- 기존 이벤트 API(`logEvent`, `logScreenView`)를 유지하면서 실제 Firebase 전송이 가능해진다.
- 구성 파일 부재 환경에서도 앱 동작은 유지된다.

### Trade-offs
- Firebase 초기화 실패 시 이벤트가 전송되지 않고 로컬 로그로 대체된다.

## Scope
- `pubspec.yaml`
- `lib/core/analytics/analytics_service.dart`

## Validation
- `flutter pub get`
- `flutter analyze lib/core/analytics/analytics_service.dart lib/core/providers/core_providers.dart`

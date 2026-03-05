# ADR-20260305-architecture-roadmap-phase1-2

## Status
Accepted (2026-03-05)

## Context
- 기준 문서:
  - `docs/architecture/ARCHITECTURE_REVIEW.md`
  - `docs/architecture/IMPROVEMENT_ROADMAP.md`
- 주요 이슈:
  - 인증 가드 미완성으로 비로그인 보호 경로 접근 가능
  - `state.extra` 강제 캐스팅으로 런타임 크래시 위험
  - 프로덕션 로그 노출
  - `.family` provider의 생명주기 관리 부재
  - core -> feature(settings) 역방향 의존
  - 팔레트/생일 계산 유틸 중복
  - 미사용 의존성 유지

## Decision
### 1) P1 보안/안정성 적용
- `lib/core/router/app_router.dart`
  - `debugLogDiagnostics: kDebugMode`로 제한
  - 인증 redirect에 보호 경로 차단 추가
  - `state.extra` 캐스팅 구간을 타입 가드 + fallback 페이지로 보호
- `lib/core/logging/app_logger.dart`
  - `info/warning/error/network`를 디버그 빌드에서만 출력

### 2) P2 상태관리/의존성 정리
- `.family` provider 전체를 `autoDispose.family`로 전환
- async provider body의 `await ref.watch(...future)`를 `await ref.read(...future)`로 통일
- `lib/core/widgets/navigation/gbt_profile_action.dart`
  - feature provider 직접 참조 제거
  - `avatarUrl`, `onTap` 주입 방식으로 역의존 제거

### 3) P2 중복/의존성 정리
- 공통 유틸 추출:
  - `lib/core/utils/palette_utils.dart`
  - `lib/core/utils/date_utils.dart`
- 중복 제거 대상 반영:
  - `lib/features/feed/presentation/pages/info_page.dart`
  - `lib/features/feed/presentation/pages/member_detail_page.dart`
  - `lib/features/feed/presentation/pages/unit_detail_page.dart`
- `pubspec.yaml` 미사용 패키지 제거:
  - `graphql_flutter`, `equatable`, `table_calendar`, `flutter_sfsymbols`
  - `crypto` (direct)
  - `patrol`, `faker`, `json_serializable`, `freezed`
  - `freezed_annotation` (direct)

## Consequences
### Positive
- 보호 경로 접근 제어 강화
- 라우팅 인자 타입 오류로 인한 크래시 방지
- release 로그 노출 위험 감소
- family provider 누수 리스크 완화
- core 계층의 feature 결합도 감소
- 중복 유틸 제거로 유지보수성 향상
- 의존성 경량화

### Trade-offs
- `GBTProfileAction`에서 아바타 표시를 원하면 호출부에서 명시적으로 주입해야 함
- `autoDispose` 전환으로 일부 화면 재진입 시 재로딩 빈도가 증가할 수 있음 (의도된 생명주기 정리)

## Validation
- `flutter analyze` (변경 대상 파일): 통과
- `flutter test`: 통과
- 참고: 프로젝트 전체 `flutter analyze`에는 기존 비차단 warning/info가 남아있음 (이번 ADR 범위 외)

## Follow-up
- Roadmap Phase 3 진행:
  - `feed_controller.dart` 분리
  - 우선순위 controller 테스트 추가
  - AsyncNotifier 점진 전환
  - Domain↔Data 정책 명문화

## References
- Flutter SDK: 3.32.6
- flutter_riverpod: 2.6.1
- go_router: 14.8.1

# ADR-20260306-locale-switch-japanese-support

## Status
Accepted (2026-03-06)

## Context
- 앱이 `MaterialApp.locale`를 `ko_KR`로 고정하고 있어, `supportedLocales`에 `ja_JP`가 있어도 일본어로 전환되지 않았습니다.
- 설정 화면의 언어 항목은 "준비 중" 상태로 실제 로케일 변경 기능이 없었습니다.
- 디자인 변경 없이 일본어 대응을 활성화해야 했습니다.

## Decision
- `core/providers/core_providers.dart`에 `localeProvider`(`LocaleNotifier`)를 추가했습니다.
  - `LocalStorageKeys.locale`에서 저장된 언어를 로드합니다.
  - `setLocale()` 호출 시 선택값을 저장합니다.
- `app.dart`에서 `MaterialApp.router.locale`을 `localeProvider`와 연결했습니다.
  - 기존 `const Locale('ko', 'KR')` 고정을 제거했습니다.
  - `Intl.defaultLocale`을 현재 로케일로 동기화합니다.
- `settings_page.dart`에서 언어 행을 실제 동작으로 변경했습니다.
  - 바텀시트에서 `System / 한국어 / English / 日本語` 선택 가능
  - 선택 즉시 앱 로케일 반영
- 최소 범위 공통 문구를 로케일 분기 처리하기 위해 경량 헬퍼를 도입했습니다.
  - `core/localization/locale_text.dart` (`context.l10n(ko/en/ja)`)
  - 적용 범위: 오프라인 배너, Android 뒤로가기 종료 안내, 하단 탭/게시판 서브탭 라벨

## Consequences
### Positive
- 일본어/영어/한국어 전환이 앱 런타임에서 즉시 가능해졌습니다.
- 선택 언어가 저장되어 재시작 후에도 유지됩니다.
- 기존 UI 구조/디자인을 바꾸지 않고 대응했습니다.
- 게시판/라이브/프로젝트 선택기의 주요 사용자 노출 문구를 `ko/en/ja`로 확장해 실제 사용 구간의 체감 번역 범위를 넓혔습니다.
- 피드 도메인 시간 경과 라벨과 카운트 축약 표기를 로케일에 맞게 출력해 언어 전환 시 표현 일관성을 확보했습니다.
- 게시판 검색 바텀시트 입력 상태를 컨트롤러 의존에서 분리해 dispose 이후 접근 크래시 가능성을 줄였습니다.
- 장소/방문 상세 플로우(`places_map`, `place_detail`, `place_review`, `visit_history`, `visit_detail`, `visit_stats`)의 사용자 노출 문구를 `ko/en/ja`로 확장해 일본어 사용 시 주요 동선의 언어 일관성을 확보했습니다.

### Trade-offs
- 아직 관리자 도구/설정 일부/목업 페이지는 하드코딩된 한국어 문자열을 사용합니다.
- 이번 변경은 실제 사용자 핵심 동선을 우선 커버했으며, 잔여 화면 번역은 후속 작업이 필요합니다.

## Validation
- `flutter analyze lib/core/providers/core_providers.dart lib/app.dart lib/shared/main_scaffold.dart lib/features/settings/presentation/pages/settings_page.dart lib/core/localization/locale_text.dart` 통과
- `flutter analyze` 통과(기존 경고/정보성 항목 제외, 신규 오류 없음)

## Follow-up
- 남은 하드코딩 문자열(관리자/계정 도구/알림 설정/목업 화면)을 `context.l10n` 또는 ARB 기반 정식 로컬라이징으로 단계적 전환합니다.

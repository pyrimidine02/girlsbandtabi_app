# 코드 감사 보고서 (Code Audit Report)

> 생성일: 2026-03-09  
> 기준 브랜치: `HEAD` (local working tree)  
> 분석 범위: `lib/**` (Dart 265개), `test/**` (Dart 53개)  
> 분석 방식: 정적 검색(`rg`) + 수동 코드 검토

---

## 0. 요약 (Executive Summary)

### 현재 상태 한 줄 요약
- 전반적인 코드 품질은 양호하나, **설정(privacy/consent) 계층 위반**, **피드 컨트롤러 비대화**, **일부 성능/디자인 일관성 이슈**가 누적되어 있습니다.

### 심각도 분포
- P1(즉시): 4건
- P2(단기): 7건
- P3(중기): 6건

### 이번 리비전에서 바로잡은 점
- 이전 감사 문서의 일부 오래된 정보(예: 테스트 파일 2개, darkGreetingGradient 중복)는 현재 코드와 불일치하여 정정했습니다.

---

## 1. P1 — 즉시 조치 필요 (아키텍처/운영 리스크)

### 1.1 Presentation 레이어에서 ApiClient 직접 호출
- 파일:
  - `lib/features/settings/presentation/pages/privacy_rights_page.dart`
  - `lib/features/settings/presentation/pages/consent_history_page.dart`
- 근거:
  - `apiClient.get/post/patch/delete` 직접 호출 확인
- 위험:
  - Clean Architecture 경계 붕괴
  - 테스트 어려움 증가, 에러 처리 패턴 분산
- 개선:
  - `SettingsRepository` + `SettingsController` 경유 구조로 통일
  - 페이지는 `AsyncValue` 소비만 담당

### 1.2 Domain 레이어 Flutter 의존
- 파일:
  - `lib/features/admin_ops/domain/entities/admin_ops_entities.dart:5`
- 근거:
  - `import 'package:flutter/material.dart';`
- 위험:
  - Domain 순수성 훼손, 재사용성/테스트성 저하
- 개선:
  - Domain 모델에서 Flutter 타입 제거
  - UI 전용 타입 변환은 presentation mapper로 이동

### 1.3 `board_controller.dart` 단일 거대 컨트롤러 (963줄)
- 파일:
  - `lib/features/feed/application/board_controller.dart`
- 근거:
  - SSE, polling, pagination, 검색/필터, 인증 반응이 한 클래스에 집중
- 위험:
  - 변경 충돌/회귀 발생 확률 상승
  - 부분 테스트 어려움
- 개선:
  - `CommunityFeedQueryController`, `CommunityFeedRealtimeController`, `CommunityFeedSyncCoordinator`로 책임 분리

### 1.4 실시간 피드 Provider 생명주기 관리 미흡
- 파일:
  - `lib/features/feed/application/board_controller.dart:958`
- 근거:
  - `communityFeedControllerProvider`가 `autoDispose` 아님
- 위험:
  - 탭 이탈 후 SSE/폴링 유지 가능성
  - 배터리/네트워크 비용 증가
- 개선:
  - `StateNotifierProvider.autoDispose` 전환
  - 화면 진입/이탈 기준 명시적 `start/stop` 계약 추가

---

## 2. P2 — 단기 개선 권장 (성능/UX)

### 2.1 HomePage rebuild 범위 과대
- 파일:
  - `lib/features/home/presentation/pages/home_page.dart:47-62`
- 근거:
  - `build()`에서 provider 다수 동시 `watch`
- 영향:
  - 작은 상태 변화에도 홈 전체 리빌드
- 개선:
  - AppBar/프로젝트게이트/콘텐츠 영역을 별도 `ConsumerWidget`으로 분리

### 2.2 SearchPage 키 입력 시 전체 리빌드
- 파일:
  - `lib/features/search/presentation/pages/search_page.dart:68`
- 근거:
  - `setState(() => _query = value)`
- 개선:
  - `ValueNotifier<String>` + `ValueListenableBuilder`
  - 검색 결과 섹션만 부분 갱신

### 2.3 FeedPage 탭 전환 시 전체 리빌드
- 파일:
  - `lib/features/feed/presentation/pages/feed_page.dart:69`
- 근거:
  - FAB 표시 상태를 `setState`로 관리
- 개선:
  - `ValueNotifier<bool>`로 FAB 영역만 재빌드

### 2.4 이미지 fallback 재시도 시 setState 반복
- 파일:
  - `lib/features/feed/presentation/pages/feed_page.dart:808`
- 개선:
  - 재시도 횟수 제한 + 백오프 + 최종 fallback 고정

### 2.5 실시간 fallback polling 기본 12초
- 파일:
  - `lib/features/feed/application/board_controller.dart:430`
- 영향:
  - 장시간 세션에서 네트워크/배터리 소모 증가
- 개선:
  - foreground 20~30초, background 60초 이상 정책 분리

### 2.6 대형 파일 집중 (유지보수성 저하)
- 파일 길이:
  - `search_page.dart`: 1260줄
  - `feed_page.dart`: 925줄
  - `board_controller.dart`: 963줄
  - `main_scaffold.dart`: 525줄
- 개선:
  - 위젯/컨트롤러 책임 단위로 단계적 분할

### 2.7 Post detail에서 디자인 시스템 우회 바텀시트/다이얼로그
- 파일:
  - `lib/features/feed/presentation/pages/post_detail_page.dart:514,704,749,793`
- 근거:
  - `showModalBottomSheet`, `showDialog` 직접 호출
- 개선:
  - `GBTBottomSheet`, `showGBTAdaptiveConfirmDialog` 우선 사용

---

## 3. P3 — 중기 개선 (일관성/기술부채)

### 3.1 Deprecated gradient dead code 정리
- 파일:
  - `lib/core/theme/gbt_colors.dart`
- 확인:
  - `accentGradient`, `secondaryGradient`, `darkAccentGradient`, `darkSurfaceGradient`는 정의만 존재
- 개선:
  - 사용되지 않는 deprecated 상수 제거

### 3.2 하드코딩 색상 분산
- 파일:
  - `lib/features/settings/presentation/pages/settings_page.dart`
  - `lib/features/places/presentation/pages/place_detail_page.dart`
- 개선:
  - `GBTColors` 시맨틱 토큰(`settingsIcon*`, `overlay*`)으로 승격

### 3.3 하드코딩 Duration 분산
- 파일:
  - `lib/core/widgets/navigation/gbt_bottom_nav.dart`
  - `lib/features/feed/presentation/pages/post_detail_page.dart`
- 개선:
  - `GBTAnimations.fast|normal`로 통일

### 3.4 Provider 배치 규칙 불균일
- 현상:
  - feature별 provider 선언 위치가 파일마다 다름
- 개선:
  - `{feature}_providers.dart` 표준 규칙 수립

### 3.5 에러 처리 스타일 혼재
- 현상:
  - `Result<T>`, `throw`, `setState + try/catch` 공존
- 개선:
  - Controller에서 `Result<T>` 표준 해석 후 `AsyncValue`로 통일

### 3.6 TODO 항목 추적 체계 부족
- 확인된 TODO 주요 항목:
  - 이벤트/장소/뉴스 공유
  - 뉴스 북마크
  - 크래시 리포팅 연동
- 개선:
  - TODO를 `TODO.md` 항목/우선순위와 연결

---

## 4. 테스트 관점 (현실 기준 업데이트)

### 4.1 정정
- 테스트 파일 수는 **2개가 아니라 53개**입니다.
- DTO/Repository/Controller 테스트는 상당수 존재합니다.

### 4.2 여전히 공백이 큰 영역
- `board_controller.dart` (실시간 + 폴링 핵심)
- `post_controller.dart` (댓글/낙관적 업데이트)
- `auth_controller.dart` (인증 흐름 핵심)
- `api_client.dart` (인터셉터/에러 매핑)

### 4.3 권장 테스트 우선순위
1. `board_controller` 상태 전이 테스트 (SSE 연결/해제, fallback polling)
2. `api_client` 4xx/5xx 매핑 + refresh interceptor 테스트
3. `auth_controller` 토큰 만료/재로그인 시나리오
4. `post_controller` 댓글 작성/삭제/롤백 시나리오

---

## 5. 수정 완료/정정된 항목 (Previous Draft 대비)

- `darkGreetingGradient`는 `greetingGradient`와 동일값이 아님 (이미 분리됨).
- 테스트 커버리지 기술은 최신 코드 상태에 맞춰 정정함.
- TODO 개수 표기 방식(EN/KO 중복 라인)을 정리해 실제 작업 단위 중심으로 기술함.

---

## 6. 실행 계획 (2주 스프린트 기준)

### Sprint A (즉시)
1. Settings API 직접 호출 제거 (Repository/Controller 경유)
2. AdminOps domain의 Flutter import 제거
3. community feed provider lifecycle 정리(`autoDispose` + cleanup)

### Sprint B (단기)
1. Home/Search/Feed 리빌드 범위 축소
2. PostDetail 바텀시트/다이얼로그 디자인 시스템 통합
3. Polling interval 정책 분리(foreground/background)

### Sprint C (중기)
1. 색상/애니메이션 토큰 정리
2. board/search/feed 파일 분할
3. 핵심 미테스트 모듈 단위 테스트 보강

---

## 7. 검증 명령

```bash
flutter analyze
flutter test
```

추가 권장(변경 파일 한정):

```bash
flutter test test/features/feed
flutter test test/features/settings
```

---

이 문서는 “문제 목록”보다 “수정 우선순위와 실행 가능성”을 중심으로 유지합니다.
새 PR 반영 시 P1/P2 상태를 먼저 업데이트하세요.

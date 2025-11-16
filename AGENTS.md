# Project Agent Playbook (AGENTS.md)

> 이 문서는 AI 에이전트(Claude/Codex/Gemini)가  
> **Flutter (Dart + Flutter 3.x+ + Clean Architecture + Riverpod/BLoC + REST/GraphQL API Client + Local Persistence)**  
> 프로젝트를 자동으로 작업할 때 따라야 할 **간결한 플레이북**입니다.  
> **핵심만 짧게** 유지하세요. 상세 설명은 `docs/`에 ADR로 남깁니다.

## Goals

- 기능/화면 단위로 **동작하는 Flutter UI**를 빠르게 만들고, 회귀 없이 확장하기.
- 변경 시 항상:
  - **테스트 우선** (unit/widget/integration)
  - **성능(빌드 빈도, Rebuild scope, 렌더링 비용)**과
  - **접근성·반응형 레이아웃**을 기본 가드레일로 삼기.
- **캡슐화(Encapsulation) · 관심사 분리(Separation of Concerns) · 확장 가능성(Extensibility)**을 모든 변경의 기본 원칙으로 삼기.

---

## Multi-CLI Collaboration Protocol (Codex · Claude · Gemini)

- **토론(의논) · 결정 · 적용**을 CLI 3종과 함께 수행한다.
- 공통 절차:

  1) **Plan 수립** — 각 CLI가 Flutter 기준 계획 제시:
    - `codex "Read AGENTS.md; propose a step-by-step plan for <feature/screen> with navigation & state-management risks"`
    - `claude Plan: <feature> — constraints: rebuild minimization, state hoisting, scroll/jank prevention`
    - `gemini Read AGENTS.md and repository; summarize feature boundaries & propose UI/UX validation checklist`

  2) **합의(Arbitrate)** — 상충 시 원칙:  
     **사용자 경험(UX)·정확성 > 성능 > 구현 속도**. 최종 결정은 사용자가 승인.

  3) **실행(Apply)** — 구현은 **Claude** 또는 **Codex**가 주도,  
     **Gemini**는 전역 위젯 트리/라우팅/상태 의존성을 점검.

  4) **검증(Verify)** —
    - `@test-reviewer`: unit/widget/integration 테스트 추가/수정
    - `@judge`: UX 플로우·성능(jank, frame drop)·접근성 기준 충족 여부 평가

- 회의용 원라인 예시:
  - `codex "Scan lib/** for large build methods; propose refactor plan by splitting widgets"`
  - `claude "@system-architect Draft ADR for feature module boundaries & state-management strategy"`
  - `gemini "Scan lib/** and test/**. Output architecture map (presentation/domain/data) & hotspot risks"`

---

## Coding & Commenting Standard — **Google Code Style + Effective Dart & Flutter**

- **코드 스타일**

  - 언어: **Dart**
    - **Google Dart Style Guide / Google Code Style**을 기본으로 따른다.
    - Flutter 공식 샘플/코드 스타일, **Effective Dart**의 규칙을 함께 따른다.
  - 기본 규칙(요약):
    - 들여쓰기: 스페이스 2칸
    - 한 줄 최대 길이: 80~100 컬럼 내(분기점은 팀 설정에 따르되 자동 포맷 결과를 그대로 사용)
    - 중괄호/괄호 배치, 공백, 줄바꿈은 `dart format` 결과를 신뢰한다.

  - 네이밍:
    - 클래스/위젯: `PascalCase` (`UserProfileScreen`, `UserAvatar`)
    - 변수/함수: `lowerCamelCase`
    - 상수: `lowerCamelCase` 또는 프로젝트 내 합의된 방식 사용  
      (예: `defaultTimeout`, `primaryButtonRadius` 등 — 불필요한 `k` prefix 지양)

  - 파일:
    - snake_case 파일명 (`user_profile_screen.dart`, `user_repository.dart`)
    - feature 단위 디렉터리 구조 유지 (`lib/features/<feature>/...`)

- **주석은 영어·한글 병기 (Google Style + 프로젝트 규칙)**
  - 순서: **영어(EN) → 한글(KO)**
  - 의미 등가를 유지하고, 중복/장황한 주석은 피한다.
  - Dartdoc 스타일은 Google 스타일 가이드를 따르되, 설명 문장 안에서 EN/KO를 같이 적는다.

  - 함수/클래스 헤더(Dartdoc) 예시:
    ```dart
    /// EN: Displays the public profile screen for a given user ID.
    /// KO: 주어진 사용자 ID에 대한 공개 프로필 화면을 표시합니다.
    class UserProfileScreen extends StatelessWidget {
      const UserProfileScreen({super.key, required this.userId});

      final String userId;

      @override
      Widget build(BuildContext context) { ... }
    }
    ```

  - 인라인 주석 예시:
    ```dart
    // EN: Avoid triggering unnecessary rebuilds by keeping this widget lightweight.
    // KO: 이 위젯을 가볍게 유지해 불필요한 재빌드를 피합니다.
    final theme = Theme.of(context);
    ```

- **도구 연계**
  - 포맷터: `dart format` (또는 `flutter format`) — **Google 스타일**을 자동 적용.
  - Lint:
    - `flutter_lints` 또는 `very_good_analysis` 기반 `analysis_options.yaml`
    - Google 스타일과 충돌하는 규칙이 있으면, **Google 스타일 + 팀 규칙**을 우선으로 조정.
  - CI:
    - 포맷 미적용 / 린트 위반 시 파이프라인 실패.

---

## API Client & Networking Principles

- **계약 우선(Contract-first)**:
  - 서버의 OpenAPI/GraphQL 스키마를 기준으로 **API 클라이언트 모델**을 생성하거나 수동 정의.
  - 네트워크 DTO와 Domain 모델을 분리해 매핑 계층을 둔다.

- **HTTP 클라이언트**
  - `dio` 또는 `http` 사용 시 공통 설정:
    - 타임아웃, 로깅(개발용), 에러 매핑(4xx/5xx → 도메인 예외)
    - 공통 헤더(Authorization, Locale 등) 인터셉터로 처리
  - 재시도/백오프 전략은 별도 유스케이스 또는 리포지토리 레벨에서 관리.

- **오프라인·캐싱**
  - 필요 시 Local DB(예: `drift`, `sqflite`, `isar`) + 메모리 캐시 조합.
  - Remote → Local → UI 순으로 데이터 흐름을 설계하고, stale 데이터 표시 정책을 정의.
  - 이미지/리스트는 pagination + 캐시 전략을 일관되게 적용.

- **에러 처리 & UX**
  - 도메인 계층에서 에러 타입(예: `NetworkFailure`, `AuthFailure`)을 정의.
  - UI에서는 스낵바·다이얼로그·에러 상태 위젯 등으로 일관되게 표현.
  - 로딩/에러/빈(empty) 상태를 구분하는 **표준 상태 모델**(sealed class 등)을 사용.

---

## Architecture & Encapsulation

- **모듈 경계 (Flutter Clean Architecture)**

  - Feature-first 구조를 기본으로 하고, 각 feature 내부에 계층을 둔다:
    - `presentation` — Widgets, pages, routes, state notifiers/Bloc
    - `application` or `state` — use cases, controllers, view models
    - `domain` — entities, value objects, repositories(interface), domain services
    - `data` — DTO, remote/local data sources, repository 구현체

  - 예시 디렉터리:
    ```
    lib/
      features/
        profile/
          presentation/
          application/
          domain/
          data/
      core/
        widgets/
        routing/
        theme/
        error/
        utils/
    ```

- **상태 관리**
  - 프로젝트에서 채택한 방식(Riverpod, BLoC, Provider 등)을 일관되게 사용.
  - 상태는 가능한 **불변(immutable)**으로 유지하고, side-effect는 분리된 레이어에서 처리.
  - 전역 상태는 최소화하고, feature-scoped provider/bloc을 선호.

- **확장성**
  - Open-Closed 원칙: 기존 위젯/로직을 깨지 않고 새로운 모드를 확장 가능한 구조로 설계.
  - 전략/정책 객체(예: 정렬 방식, 필터링 전략)를 DI로 전달해 UI에서 쉽게 교체 가능하도록 한다.

- **성능·렌더링**
  - 큰 build 메서드는 작은 위젯으로 분리해 **rebuild scope**를 최소화.
  - `ListView.builder`, `AnimatedBuilder`, `ValueListenableBuilder` 등 효율적인 위젯을 적절히 사용.
  - 필요 시 `RepaintBoundary`로 리렌더링 범위를 제어하되 남용하지 않는다.

---

## Repo Layout (assumed)

- `lib/` : 앱 소스 코드
  - `lib/main.dart` : 진입점
  - `lib/app.dart` : MaterialApp / Router 설정
  - `lib/core/` : 공통 인프라 (theme, routing, error, utils, localization)
  - `lib/features/` : 도메인/기능 모듈 (예: user, pilgrimage, live_schedule, stats 등)
- `test/` : unit/widget 테스트
- `integration_test/` : 통합 테스트 (플로우/네비게이션)
- `assets/` : 이미지, 폰트, lottie, json 등
- `docs/` : ADR, 설계 다이어그램, UX 플로우
- `scripts/` : 코드 생성, 릴리즈 자동화 등

---

## Commands

- Build:
  - `flutter pub get`
  - `flutter build apk` / `flutter build ios` / `flutter build web`
- Run (local):
  - `flutter run` (디바이스/에뮬레이터 지정)
- Test:
  - `flutter test`
  - `flutter test integration_test` (필요 시)
- Lint/Format:
  - `dart format .`
  - `flutter analyze`

---

## Tools / Boundaries

- 허용 툴:
  - 코드 읽기/검색: Read, Grep, Glob
  - 코드 수정: Edit, MultiEdit, Write
  - 스크립트/명령: Bash (Flutter/Dart 관련 명령만)
  - WebFetch: Flutter/Dart 공식 문서, 패키지 메타데이터(pub.dev) 조회

- **금지:**
  - iOS/Android 네이티브 설정(`android/`, `ios/`)의 위험한 변경 (서명/프로비저닝 등)
  - 프로덕션 API 키/시크릿 노출
  - 배포 파이프라인(스토어 업로드) 직접 변경

- 외부 네트워크 접근은 **문서/공식 레지스트리/패키지 메타데이터** 범위로 제한.

---

## Memory / Artifacts

- 의미 있는 작업 후 반드시:
  - `CHANGELOG.md`에 요약 기록
  - `docs/adr/ADR-YYYYMMDD-<topic>.md` 작성
    - 변경 전 문제 / 대안 / 결정 / 근거 / 영향 범위
  - `TODO.md`에 남긴 임시 조치/부채와 제거 기준을 명시

---

## Security & Secrets

- 모든 시크릿(API 키, 클라이언트 시크릿 등)은:
  - 런타임 환경(.env, .json config, native secure storage)에서 주입
  - **코드/깃에 절대 커밋 금지**
- TLS/HTTPS만 사용하고, self-signed / insecure HTTP는 개발용에서만 사용.
- 민감한 로깅(토큰, 패스워드, 주민번호 등)은 금지.

---

## Approval Rules (에이전트)

- 대규모 리팩토링/디렉터리 구조 변경/라우팅 전략 변경은  
  **Plan 문서(텍스트) → 사용자 승인** 후 진행.
- 테스트 커버리지:
  - 기존 대비 **하락 금지** (widget/unit/integration 조합 기준).
- 성능:
  - 스크롤 시 잦은 jank(프레임 드랍) 유발 변경 금지.
  - 리스트/애니메이션 추가 시 성능 영향 분석 메모를 남긴다.

---

## Escalation

- 요구사항이 불명확하거나 UX/설계 충돌 발견 시:
  1. 작업 중단
  2. 질문/모호점 목록 작성
  3. 사용자의 승인/답변을 받은 뒤 진행

- 외부 문서 인용 시:
  - **출처 링크/버전**(Flutter SDK 버전, 패키지 버전)을 ADR에 남긴다.

---

## Review Checklist (AI가 스스로 점검)

- [ ] `flutter analyze` / 테스트 모두 통과했는가?
- [ ] **Google Code Style + Effective Dart / Flutter 스타일 + bilingual comments(EN/KO)** 준수했는가?
- [ ] 라우팅/네비게이션 변경 시 기존 딥링크/플로우와 호환성을 고려했는가?
- [ ] 큰 위젯/빌드 메서드를 적절히 분리해 **rebuild scope**를 최소화했는가?
- [ ] API 호출/에러 처리/캐싱 전략을 일관되게 적용했는가?
- [ ] 접근성(semantic label, tap target size, contrast)과 반응형 레이아웃을 고려했는가?
- [ ] ADR/CHANGELOG/TODO를 업데이트했는가?
- [ ] 성능(스크롤, 애니메이션, 메모리 사용) 예산을 초과하지 않았는가?

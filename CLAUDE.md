# CLAUDE.md

이 프로젝트의 에이전트 지침은 `AGENTS.md`를 단일 소스로 사용합니다.  
**Claude**는 먼저 루트의 `AGENTS.md`를 읽고 따르세요.

## Flutter 전용 추가 지침

- 이 리포지토리는 **Flutter (Dart) 애플리케이션**을 위한 것입니다.
- 새로운 화면, 위젯, 상태 관리 로직을 작성하기 전에 반드시 아래를 먼저 수행합니다.
    1. `AGENTS.md`를 읽고 전체 아키텍처·코딩 규칙을 파악한다.
    2. 변경 범위(어떤 feature / layer / 파일)에 대한 **간단한 Plan**을 텍스트로 작성한다.
    3. 위젯 트리 영향 범위(부모/자식 위젯, Router 경로, Provider/Bloc 의존성)를 정리한다.
- 코드를 수정할 때는:
    - **구조(architecture)**: presentation / application(state) / domain / data 계층을 유지한다.
    - **상태 관리**: 기존 프로젝트에서 채택한 패턴(Riverpod, BLoC, Provider 등)을 그대로 따른다.
    - **테스트**: 새로운 기능에는 최소한의 widget/unit 테스트를 추가한다.
- 항상 `AGENTS.md`에 정의된 **Effective Dart 스타일, 이중 언어(EN/KO) 주석 규칙, 테스트·성능·접근성 체크리스트**를 우선적으로 따른다.

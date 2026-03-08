# ADR-20260308: Feed Post Card Project Badge Emphasis

- Date: 2026-03-08
- Status: Accepted
- Scope: `lib/features/feed/presentation/pages/board_page.dart`

## Context

- 커뮤니티 피드 카드의 프로젝트명이 메타 텍스트(`프로젝트명 · 시간`)에 묻혀
  가독성이 낮다는 피드백이 있었다.
- 추천/팔로잉 혼합 피드에서 프로젝트 식별성은 탐색 품질에 직접 영향을 준다.

## Decision

- 카드 작성자 메타 영역에서 프로젝트명을 알약 배지로 분리한다.
  - 강조 색상: theme primary 계열(light/dark 분기)
  - 배경: low-alpha tint
  - 테두리: mid-alpha border
- 시간 정보는 기존 tertiary 메타 텍스트로 유지한다.
- 줄바꿈/협소 폭 대응을 위해 `Wrap` 레이아웃을 사용한다.

## Consequences

- 프로젝트명이 즉시 식별되어 카드 스캔 속도가 개선된다.
- 기존 카드 정보량은 유지하면서 시각적 우선순위만 조정된다.
- 색상 강조는 라이트/다크 모드 모두에서 일관되게 동작한다.

## Validation

- `flutter analyze lib/features/feed/presentation/pages/board_page.dart`

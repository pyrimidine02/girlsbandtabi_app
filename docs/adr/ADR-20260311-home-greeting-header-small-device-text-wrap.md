# ADR-20260311 Home Greeting Header Small-Device Text Wrap

## Status
- Accepted (2026-03-11)

## Context
- 홈 상단 인사말 헤더의 title/subtitle가 `maxLines: 1`로 고정되어
  작은 화면(좁은 폭 기기)에서 문장 뒤가 잘리는 문제가 발생했습니다.
- 사용자명이 길거나 로컬라이즈 문장이 긴 경우 잘림이 더 자주 발생했습니다.

## Decision
- 인사말 title/subtitle를 최대 2줄까지 허용합니다.
- 텍스트 줄바꿈에 필요한 실제 높이를 `TextPainter`로 측정하고,
  그 추가 높이를 헤더 높이에 동적으로 반영합니다.
- 기존 featured live 칩/배경/그라디언트 구조는 유지합니다.

## Alternatives Considered
- 폰트 크기 일괄 축소:
  - Rejected: 가독성이 저하되고 큰 화면 UX에도 영향을 줌.
- 짧은 문구로 강제 치환:
  - Rejected: 로컬라이즈 문장 의미 손실이 발생.

## Consequences
- 작은 기기에서 인사말 텍스트 가시성이 개선됩니다.
- 레이아웃 계산 비용이 소폭 증가하지만 홈 헤더 1회 렌더 수준이라 영향은 제한적입니다.

## Validation
- `flutter analyze lib/core/widgets/layout/gbt_greeting_header.dart` passed.


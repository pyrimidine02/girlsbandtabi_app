# ADR-20260302-live-detail-poster-offset-and-bg

- Date: 2026-03-02
- Status: Accepted

## Context

라이브 상세 헤더에서 포스터 전체 노출 이후,
상태바 영역(시간/알림)과 포스터가 겹쳐 보이는 문제가 있었다.
또한 포스터 하단의 반사처럼 보이는 배경 처리에 대한 거부감 피드백이 있었다.

## Decision

- 포스터 표시를 상단에서 약간 아래로 이동한다.
  - `posterTopOffset = statusBarInset + 20px`
- 포스터 주변 배경은 동일 포스터 반사형 배경을 제거하고,
  중립 그라데이션 배경으로 교체한다.

## Alternatives Considered

1. 포스터를 그대로 두고 상단 스크림만 강화
- 장점: 구현 단순
- 단점: 상태바 영역 겹침 인상은 그대로 남음

2. AppBar 전체 높이 축소
- 장점: 상단 점유율 감소
- 단점: 세로 포스터 전체 표시 목표와 충돌

## Consequences

- 장점: 상태바 영역과 포스터 시각 충돌 감소
- 장점: 하단 반사 느낌 제거로 더 중립적인 화면 톤 확보
- 단점: 매우 작은 화면에서 포스터 실표시 높이가 소폭 줄어듦

## Validation

- `flutter analyze lib/features/live_events/presentation/pages/live_event_detail_page.dart`

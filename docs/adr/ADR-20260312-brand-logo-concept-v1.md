# ADR-20260312-brand-logo-concept-v1

- Date: 2026-03-12
- Status: Accepted

## Context

앱 브랜딩 일관성을 위해 현재 서비스 성격을 담은 기본 로고 시안이 필요했습니다.
요구사항은 빠르게 사용할 수 있는 1안(단일 시안)입니다.

## Decision

아래 요소를 결합한 로고 시안 1개를 SVG로 제작했습니다.

1. 밴드/음악 상징: 기타 픽 + 음표
2. 성지/이동 상징: 위치 핀
3. 앱 톤앤매너: 블루 계열 기반 + 핑크 포인트 그라데이션

산출물:
- `docs/design/logo/girlsbandtabi_logo_v1.svg`
- `docs/design/logo/girlsbandtabi_logo_v1.png`

## Rationale

- 앱 핵심 도메인(음악 + 이동 정보)을 한 심볼에 압축해 전달 가능합니다.
- SVG 포맷으로 추후 iOS/Android/Web별 리사이즈 대응이 쉽습니다.
- 디자인 시안 단계에서 가장 빠르게 피드백 루프를 돌릴 수 있습니다.

## Consequences

- 장점:
  - 즉시 README, 문서, 디자인 리뷰에 활용 가능합니다.
  - 벡터 기반이라 품질 저하 없이 크기 변경 가능합니다.
- 단점:
  - 아직 다크/라이트 배경별 별도 변형안, 워드마크 조합안은 없습니다.

## Follow-up

1. 앱 아이콘용 안전영역/마스킹(iOS squircle, Android adaptive icon) 최적화 버전 생성
2. 모노톤(단색) 버전 및 작은 크기(24/32/48px) 가독성 버전 생성
3. 필요 시 워드마크 조합형(심볼 + `GirlsBandTabi`) 추가

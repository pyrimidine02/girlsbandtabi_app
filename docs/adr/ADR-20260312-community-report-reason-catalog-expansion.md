# ADR-20260312-community-report-reason-catalog-expansion

- Date: 2026-03-12
- Status: Accepted

## Context

커뮤니티 이용규칙 강화에 맞춰 신고 UI에서도
`거래 유도`, `허위 신고/신고 악용`, `조작/어뷰징` 사유를 직접 선택할 수 있어야
운영 분류 정확도와 신고 접수 일관성이 높아집니다.

다만 현재 서버가 확장 enum을 즉시 지원하지 않을 수 있어,
프런트에서 사유를 추가해도 기존 API 계약과 충돌 없이 동작해야 합니다.

## Decision

1. 신고 사유 enum에 아래 3개를 추가합니다.
   - `TRADE_INDUCEMENT`
   - `FALSE_REPORT_ABUSE`
   - `MANIPULATION_ABUSE`
2. 신고 시트는 enum 기반 렌더링을 유지하므로 신규 사유를 즉시 표시합니다.
3. 신고 생성 요청은 하위호환 정책을 적용합니다.
   - 확장 사유 선택 시 `reason=OTHER`로 전송
   - 실제 확장 사유는 `description`에
     `[TRADE_INDUCEMENT]` 같은 마커로 인코딩

## Rationale

- UX 측면: 이용자가 정책에 맞는 사유를 직접 선택할 수 있어 신고 품질이 개선됩니다.
- 운영 측면: 세부 사유가 description에 남아 모더레이션 분류에 활용 가능합니다.
- 호환성 측면: 서버 enum 미지원 환경에서도 4xx 없이 접수를 유지할 수 있습니다.

## Consequences

- 장점:
  - UI와 정책 문구가 정합성을 갖게 됩니다.
  - 서버 릴리즈 순서와 무관하게 프런트 반영이 가능합니다.
- 단점:
  - 서버가 확장 enum을 정식 지원하기 전까지는 reason 필드 집계에서
    `OTHER` 비중이 높게 보일 수 있습니다.

## Follow-up

1. 백엔드에서 확장 reason enum 정식 지원 시
   `requestApiValue=OTHER` fallback을 제거하고 직접 코드 전송으로 전환
2. 운영 대시보드/통계에서 description 마커 파싱 여부 검토


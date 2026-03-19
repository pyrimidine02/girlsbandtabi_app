# ADR-20260312-community-rules-hardening-with-major-platform-patterns

- Date: 2026-03-12
- Status: Accepted

## Context

기존 커뮤니티 이용규칙에는 기본 금지행위와 제재 단계가 정의되어 있었지만,
대형 커뮤니티 플랫폼에서 공통적으로 운영하는 세부 기준(신고 악용,
무결성 조작, 제재 회피, 민감 주제 처리, 청소년 보호 무관용 등)의 명시성이
상대적으로 약했습니다.

운영 일관성과 분쟁 대응력을 높이기 위해, 이미 검증된 대형 플랫폼 운영 패턴을
GirlsBandTabi 정책에 맞게 반영할 필요가 있었습니다.

## Decision

`docs/legal/커뮤니티이용규칙_v2026.03.12.md`에 다음을 추가/강화합니다.

1. 내부 거래 및 외부 거래 유도 링크 금지 고도화
2. 무결성(Integrity) 보호 정책 신설
   - 자동화 어뷰징, 반응 수치 조작, 조직적 여론 조작 금지
3. 신고 시스템 악용 금지
   - 허위/보복/대량 반복 신고 제재
4. 제재 회피 금지
   - 다중 계정/계정 공유 기반 우회 시 통합 제재 가능
5. 청소년 보호 및 민감 콘텐츠 기준 강화
   - 아동·청소년 성착취성 콘텐츠 무관용
   - 고위험 허위정보 및 민감 주제 사전 고지 기준 추가
6. 운영 임시조치 유형 명시
   - 게시글/댓글 잠금, 쿨다운, 노출 제한

## Rationale

- 주요 플랫폼은 공통적으로 `안전 + 무결성 + 제재 집행력`을 핵심 축으로 둡니다.
- 단순 금지목록만으로는 신고 악용, 조작, 우회 계정 같은 실무 이슈 대응이
  어렵기 때문에 정책 문구를 명시적으로 강화해야 합니다.
- 앱 특성상 거래 사기·오프플랫폼 유도 리스크가 높아 거래 관련 규정의
  독립 섹션화가 필요했습니다.

## Consequences

- 장점:
  - 운영자 판단 기준이 구체화되어 제재 일관성이 높아집니다.
  - 분쟁/이의제기 시 기준 문구를 명확히 제시할 수 있습니다.
  - 청소년 보호 및 위험 콘텐츠 대응에서 보수적 집행 근거가 강화됩니다.
- 단점:
  - 정책 문구가 길어져 초기 온보딩 시 가독성이 낮아질 수 있습니다.
  - 오탐 제재 가능성을 줄이기 위한 운영자 가이드/교육이 추가로 필요합니다.

## Follow-up

1. 신고 UI 사유에 `거래 유도`, `허위/보복 신고`, `조작/어뷰징` 항목 추가 검토
2. 운영툴에서 임시조치(잠금/쿨다운) 액션 버튼 제공 여부 검토
3. 월간 제재 통계(신고 악용, 거래 유도, 다중 계정 우회)를 별도 모니터링

## References

- Reddit Rules
  - https://redditinc.com/policies/reddit-rules
- Discord Community Guidelines
  - https://discord.com/guidelines
- YouTube Community Guidelines
  - https://support.google.com/youtube/answer/9288567
- KakaoTalk Operation Policy (Overview)
  - https://talksafety.kakao.com/en/policy
- KakaoTalk User Safety (Sexual offenses against children and juveniles)
  - https://talksafety.kakao.com/en/policy/usersafety

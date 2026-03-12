# ADR-20260312-music-lyrics-member-part-colorization

- Date: 2026-03-12
- Status: Accepted

## Context

악곡 상세 페이지에서 가사/파트 데이터는 존재하지만,
사용자가 특정 멤버 파트를 빠르게 식별하기 어려웠습니다.

요구사항:
- 멤버 파트 탭 시 가사 강조 색상 전환
- 매핑 누락 시 시간 겹침 기반 fallback
- `DUET/UNISON/HARMONY` 혼합색 표현

## Decision

`music_song_detail_page.dart`의 통합 가사 패널을 다음 규칙으로 확장했습니다.

1. 멤버 파트 선택 UI 추가
- 파트 멤버 칩(`전체 + 멤버`) 제공
- 라인 파트 배지 탭으로도 멤버 선택 토글 가능

2. 색상 규칙
- 멤버 기본색: `memberId` 해시 기반 고정 컬러맵
- 단일 파트 라인: 멤버 단색 강조
- `DUET/UNISON/HARMONY`: 다중 멤버 색상 그라데이션
- 매핑/멤버 없는 라인: 기본 텍스트 색 유지

3. 파트-가사 매핑 규칙
- 1순위: `parts.segments[].lyricLineId` ↔ `lyrics.lines[].lineId`
- 2순위 fallback: `startMs/endMs` 최대 겹침 라인 매핑

4. 데이터 소스 우선순위
- `eventId` 존재 시 `live-context`의 `lyrics/parts/callGuide` 우선 사용
- 값 누락 시 기존 개별 상태를 fallback으로 사용

## Rationale

- 백엔드 스키마 변경 없이 프런트에서 즉시 UX 개선 가능
- 매핑 누락 데이터에도 사용자 경험이 끊기지 않음
- 멤버 중심 소비 패턴(누가 부르는 파트인지 확인)에 직접 대응

## Consequences

- 장점:
  - 멤버 파트 탐색성이 크게 향상됨
  - 누락 데이터에 대한 복원력 증가
- 제약:
  - 시간 겹침 fallback은 데이터 품질에 따라 근사 매핑일 수 있음
  - 그라데이션 표현은 line-level 시각화이므로 음절 단위 정밀 매핑은 아님

## Follow-up

1. 위젯 테스트 추가
- 멤버 칩 선택 시 라인 스타일 변경 검증
- `lyricLineId` 누락 시 시간 겹침 fallback 검증
- 혼합 파트 타입(`DUET/UNISON/HARMONY`) 그라데이션 검증

2. API 계약 정리
- 가능하면 `live-context` 단일 경로 중심으로 호출 단순화
- `lyricLineId` 누락률 모니터링 지표 확보

## References

- 구현 파일:
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/music/presentation/pages/music_song_detail_page.dart`
- 관련 요청 맥락:
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/docs/api-spec/악곡정보_백엔드요청서_통합반영_프런트연동_v1.1.0.md`

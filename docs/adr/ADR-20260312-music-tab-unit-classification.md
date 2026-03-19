# ADR-20260312-music-tab-unit-classification

- Date: 2026-03-12
- Status: Accepted

## Context

정보 탭의 악곡 페이지는 앨범/트랙을 단일 리스트로만 보여주고 있어,
프로젝트 내 복수 유닛이 존재할 때 원하는 유닛 기준 탐색이 어려웠습니다.

요구사항은 "악곡 페이지에서 유닛으로 앨범과 트랙 분류 가능"입니다.

## Decision

악곡 탭에 유닛 분류 칩(전체 + 유닛별)을 추가하고,
선택된 유닛 기준으로 앨범/트랙을 동시에 필터링합니다.

- 유닛 키 생성 규칙:
  - 1순위: `song.primaryUnitId`
  - 2순위: `song.primaryUnitName`
- 트랙: 선택 유닛 키와 일치하는 항목만 노출
- 앨범: 필터링된 트랙의 `albumId` 집합을 기준으로 노출
- 선택 유닛 옵션이 데이터 변경으로 사라지면 자동으로 `전체`로 복귀

## Rationale

- 사용자는 유닛 관점으로 악곡을 빠르게 좁혀 보길 원합니다.
- 서버 API를 추가 변경하지 않고 현재 응답(`songs`의 unit 정보)만으로 구현 가능해
  릴리즈 리스크를 낮출 수 있습니다.
- 앨범/트랙에 동일한 필터를 적용해 탐색 모델을 일관되게 유지할 수 있습니다.

## Consequences

- 장점:
  - 유닛 중심 탐색성이 즉시 개선됩니다.
  - 기존 악곡 상세 이동 플로우를 유지한 채 UI 레벨에서 확장됩니다.
- 제약:
  - 앨범 필터는 현재 클라이언트에 로드된 트랙(`songs` 페이지) 기준으로 계산됩니다.
  - 아주 큰 데이터셋에서 곡 페이지네이션이 완료되기 전에는 일부 앨범이
    지연 노출될 수 있습니다.

## Follow-up

1. 백엔드에 `music/albums` 유닛 필터(`unitId`)가 공식 지원되면
   앨범 필터를 서버 사이드로 전환
2. 필요 시 트랙 섹션을 유닛 그룹 헤더형 레이아웃으로 확장 검토
3. 악곡 탭 위젯 테스트 추가(유닛 칩 선택/필터/복귀 상태)

## References

- 구현 파일: `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/info_page.dart`
- 관련 요청 문서:
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/docs/api-spec/악곡정보_백엔드요청서_통합반영_프런트연동_v1.1.0.md`

# ADR-20260312: Music Info Backend Request Draft

- Date: 2026-03-12
- Status: Accepted
- Scope:
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/docs/api-spec/악곡정보_백엔드요청서_v1.0.0.md`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/CHANGELOG.md`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/TODO.md`

## Context
- 사용자 요청으로 악곡 정보 기능을 확대해야 합니다.
  - 앨범 정보
  - 노래별 가사
  - 가사별 멤버 파트
  - 노래별 콜 타이밍(콜표)
- 현재 클라이언트 저장소에는 해당 범위의 명시적 API 계약 문서가 없어서
  백엔드/프런트 병렬 개발 시 스펙 불일치 리스크가 큽니다.

## Decision
- `docs/api-spec/악곡정보_백엔드요청서_v1.0.0.md`를 신규 작성했습니다.
- 문서에 아래 내용을 포함해 계약 초안을 고정했습니다.
  - 앨범/곡/가사/파트/콜표 조회 엔드포인트 제안
  - 버전/세트리스트/크레딧/난이도/미디어/가용성 6개 항목 상세 API 제안
  - `version/lang` 파라미터 표준화
  - 타임라인 단위(`ms`) 규칙
  - 추가 제한사항(파라미터 범위, 타임라인 무결성, 필드 길이/개수,
    `ETag/revision`, 레이트 리밋, 상태코드 매핑)
  - `MUSIC_*` 에러코드 제안
  - 더미데이터(JSON) 샘플
  - QA 체크리스트/백엔드 확인 요청

## Alternatives Considered
1. 기능별 개별 문서로 분산 작성
   - Rejected: 데이터 계약이 분산되어 가사/파트/콜표 타임라인 정합성 검토가 어려움.
2. 화면 요구사항만 텍스트로 전달
   - Rejected: 백엔드 구현 가능한 계약(필드/타입/에러코드/샘플)이 부족함.

## Consequences
- 백엔드가 구현 단위를 API별로 바로 나눌 수 있습니다.
- 프런트는 더미데이터로 화면/상태/UI 예외 케이스를 선개발할 수 있습니다.
- 이후 실제 서버 응답과 차이가 생기면 본 문서를 단일 기준으로 diff 관리할 수 있습니다.

## Validation
- 문서 파일 생성 및 저장소 반영 확인
  - `docs/api-spec/악곡정보_백엔드요청서_v1.0.0.md`

# ADR-20260302-android-internal-distribution-workflow

- Date: 2026-03-02
- Status: Accepted

## Context

요청사항은 Git push 기반으로 Android 테스트 단계부터 자동 검증하고,
조건 충족 시 내부 테스터로 자동 배포하는 것이다.
현재 저장소에는 GitHub Actions 워크플로가 없어 수동 빌드/배포에 의존하고 있었다.

## Decision

- GitHub Actions 워크플로를 신규 추가한다:
  - 파일: `.github/workflows/android-internal-distribution.yml`
- 동작 정책:
  - `pull_request(main)`: `flutter analyze` + `flutter test --no-pub`
  - `push(main)`/`workflow_dispatch`: 품질 단계 통과 후
    `flutter build appbundle --release` + Google Play Internal track 업로드
- 배포 방식:
  - `r0adkll/upload-google-play@v1` 사용
  - 패키지명: `org.pyrimidines.girlsbandtabi_app`
- 민감정보는 GitHub Secrets로 주입한다.

## Alternatives Considered

1. Firebase App Distribution 사용
- 장점: 초기 설정 단순
- 단점: Play Internal 테스트 트랙과 별도 운영 필요

2. 수동 배포 유지
- 장점: 구현 불필요
- 단점: 반복 비용/실수 위험 높음, 자동 회귀 방지 불가

## Consequences

- 장점: main 브랜치에서 품질 검증 + 내부 배포 자동화
- 장점: 수동 배포 시간/누락 감소
- 단점: Secrets 미설정 시 배포 단계 실패

## Validation

- 워크플로 YAML 파싱 검증(`ruby yaml load`) 통과

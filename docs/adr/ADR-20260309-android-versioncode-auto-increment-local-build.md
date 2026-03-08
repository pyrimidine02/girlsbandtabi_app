# ADR-20260309-android-versioncode-auto-increment-local-build

## Status
Accepted

## Date
2026-03-09

## Context
- 로컬에서 내부테스트 AAB를 반복 빌드할 때 `versionCode` 충돌이 발생했다.
- 기존 `scripts/bump_version.sh`는 어떤 레벨(major/minor/patch)이든
  build number를 항상 `+1`로 리셋하는 구조였다.
- CI는 자동 build-number를 주입하지만, 로컬 수동 빌드 경로는
  충돌 방지가 약했다.

## Decision
1. `scripts/bump_version.sh`를 개선한다.
   - 모드: `major|minor|patch|build`
   - build number 자동증가:
     - `max(current_build + 1, current_epoch_second)`
   - 수동 지정 옵션: `--build-number N`
   - 검증 옵션: `--dry-run`
   - 상한 방어: `N <= 2,100,000,000`
2. 로컬 내부테스트 빌드 전용 스크립트를 추가한다.
   - `scripts/build_android_internal.sh [mode]`
   - 동작: 버전 갱신 -> `flutter build appbundle --release` -> 산출물 출력
3. 운영 문서에 자동 빌드 절차를 반영한다.
   - `BUILD_GUIDE.md`
   - `docs/모바일버전배포가이드_v1.0.0.md`

## Alternatives Considered
1. pubspec 수동 편집 유지
   - 단순하지만 사람 실수로 충돌이 반복된다.
2. 로컬에서는 `--build-number` 수동 플래그만 강제
   - 매번 번호 계산이 필요해 운영 비용이 높다.

## Consequences
### Positive
- 로컬 빌드에서도 `versionCode`가 단조 증가해 충돌 가능성이 크게 줄어든다.
- 내부테스트 빌드 명령이 단순해져 운영 실수를 줄일 수 있다.

### Trade-offs
- 빌드 시 `pubspec.yaml`이 자동 변경되므로 커밋 관리가 필요하다.

## Scope
- `scripts/bump_version.sh`
- `scripts/build_android_internal.sh`
- `BUILD_GUIDE.md`
- `docs/모바일버전배포가이드_v1.0.0.md`

## Validation
- `bash -n scripts/bump_version.sh`
- `bash -n scripts/build_android_internal.sh`
- `./scripts/bump_version.sh build --dry-run`
- `flutter build appbundle --release`

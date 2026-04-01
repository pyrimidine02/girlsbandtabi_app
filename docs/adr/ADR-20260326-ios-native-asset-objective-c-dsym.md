# ADR-20260326: iOS Archive dSYM Inclusion for objective_c Native Asset

- Date: 2026-03-26
- Status: Accepted

## Context

Xcode Archive 업로드 시 다음 오류가 발생했다.

- `The archive did not include a dSYM for the objective_c.framework ...`
- UUID: `B8D20861-8B1E-3A14-A9FF-E9D5E228953B`

프로젝트는 Flutter native asset 경로를 통해 `objective_c.framework`를 앱에 포함한다.
이 프레임워크는 Pods 산출물이 아니며, 기존 Podfile의 dSYM 설정으로는 아카이브
dSYMs 폴더에 자동 포함되지 않았다.

## Decision

Runner 타깃의 `Thin Binary` 단계 직후에 native asset dSYM 생성 스크립트를 실행한다.

- 새 스크립트: `ios/scripts/generate_native_asset_dsym.sh`
- 동작:
  1. `${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}/objective_c.framework/objective_c` 탐색
  2. `dsymutil`로 `objective_c.framework.dSYM` 생성
  3. `${ARCHIVE_DSYMS_PATH}`가 존재하면 archive dSYMs 폴더로 복사

이를 위해 `ios/Runner.xcodeproj/project.pbxproj`의 `Thin Binary` script를 아래처럼
확장한다.

- `xcode_backend.sh embed_and_thin`
- `generate_native_asset_dsym.sh`

## Alternatives Considered

1. Podfile `post_install`에서 dSYM 강제  
   - native asset은 Pods 대상이 아니므로 문제를 해결하지 못함.

2. 수동으로 아카이브 후 dSYM 복사  
   - 사람 의존적이며 CI/Xcode Cloud 재현성이 낮음.

## Consequences

- 장점:
  - 아카이브 산출물에 `objective_c.framework.dSYM`가 일관되게 포함됨
  - App Store Connect 업로드의 missing dSYM 오류 제거
- 비용:
  - iOS 빌드 스크립트 1개 유지보수 필요

## Verification

- `plutil -lint ios/Runner.xcodeproj/project.pbxproj` 통과
- `dsymutil` 생성 후 `dwarfdump --uuid` 비교:
  - framework binary UUID == dSYM UUID 확인


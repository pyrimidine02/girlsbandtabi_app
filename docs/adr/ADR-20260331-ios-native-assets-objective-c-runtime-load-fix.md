# ADR-20260331: iOS Native Assets objective_c Runtime Load Fix

## Status
- Accepted (2026-03-31)

## Context
- iOS 앱 실행 중 `package:objective_c/objective_c.dylib` 로딩 실패가
  반복적으로 보고되었습니다.
- 에러 시그니처:
  - `Couldn't resolve native function 'DOBJC_initializeApi'`
  - `Failed to load dynamic library 'objective_c.framework/objective_c'`
- 영향 범위:
  - `path_provider_foundation` 및 `cached_network_image` 초기화 경로에서
    예외가 연쇄적으로 발생하며 이미지/캐시 계층 동작 안정성 저하.

## Problem (Before)
- 빌드 산출물 `NativeAssetsManifest.json`의 objective_c 경로가
  iOS 런타임에서 직접 로딩하기 어려운 형태로 남아 있었습니다.
- 결과적으로 앱 번들의 `Frameworks/objective_c.framework`가 존재해도
  런타임 dlopen 단계에서 경로 해석 실패가 발생했습니다.

## Decision
- iOS `Thin Binary` 단계 직후 native-assets 매니페스트를 보정하는
  후처리 스크립트를 추가합니다.
- objective_c 경로를 다음으로 통일합니다.
  - `@executable_path/Frameworks/objective_c.framework/objective_c`
- 보정 스크립트 실행 순서:
  1. `xcode_backend.sh embed_and_thin`
  2. `fix_native_assets_manifest.sh`
  3. `generate_native_asset_dsym.sh`

## Rationale
- 런타임 로더가 해석 가능한 명시 경로를 사용하면
  시뮬레이터/디바이스 모두에서 동일하게 동작합니다.
- Flutter/Dart toolchain 버전 차이에 따른 native-assets 경로 산출 편차를
  빌드 후처리 한 곳에서 흡수할 수 있습니다.
- 기존 dSYM 보강 흐름은 유지해 App Store 업로드 안정성도 보존합니다.

## Scope / Impact
- Added:
  - `ios/scripts/fix_native_assets_manifest.sh`
- Updated:
  - `ios/Runner.xcodeproj/project.pbxproj`
- Non-goals:
  - Android/native assets 경로 처리 변경 없음
  - objective_c 패키지 코드 자체 변경 없음

## Verification
- `sh -n ios/scripts/fix_native_assets_manifest.sh`
- `plutil -lint ios/Runner.xcodeproj/project.pbxproj`
- `flutter build ios --simulator --debug`
- 출력 산출물 확인:
  - `build/ios/iphonesimulator/Runner.app/Frameworks/App.framework/flutter_assets/NativeAssetsManifest.json`
  - objective_c 항목이 `@executable_path/Frameworks/objective_c.framework/objective_c`로 반영됨.

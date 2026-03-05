# ADR-20260306-android-version-bump-003-manual-build

## Status
Accepted (2026-03-06)

## Context
- 내부 테스트 배포 준비를 위해 앱 버전을 `0.0.3`으로 상향하고 수동 Android 빌드 산출물을 확보해야 했습니다.
- 현재 CI는 `main` push 시 내부트랙 업로드를 수행하지만, 요청은 즉시 수동 산출물 생성이었습니다.

## Decision
- `pubspec.yaml` 버전을 `0.0.3+2026030601`로 변경했습니다.
- 수동 릴리즈 빌드를 수행했습니다.
  - `flutter build appbundle --release`
  - `flutter build apk --release --build-name=0.0.3 --build-number=2026030601`
- APK 메타데이터를 `aapt`로 확인해 실제 버전값을 검증했습니다.

## Consequences
### Positive
- 내부 테스트/수동 배포에 사용할 최신 버전 산출물을 즉시 확보했습니다.
- APK 기준 `versionName/versionCode` 검증이 완료되어 배포 버전 혼동을 줄였습니다.

### Trade-offs
- 수동 빌드 결과와 CI 자동 빌드 결과가 동시에 존재하므로, 업로드 시 파일 선택 기준을 명확히 해야 합니다.

## Validation
- `aapt dump badging build/app/outputs/flutter-apk/app-release.apk`
  - `versionName='0.0.3'`
  - `versionCode='2026030601'`

## Follow-up
- Play Console internal track 업로드 후 테스터 업데이트 경로를 검증합니다.

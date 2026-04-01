# ADR-20260326: Android image_cropper ActivityNotFound crash fix

## Status
- Accepted (2026-03-26)

## 변경 전 문제
- Crashlytics에서 이미지 크롭 진입 시 아래 크래시가 집계되었다.
  - `PlatformException(activity_not_found, Unable to find explicit activity class {org.pyrimidines.girlsbandtabi_app/M4.b} ...)`
- 스택상 `MethodChannelImageCropper.cropImage` 단계에서 Android Activity
  실행에 실패했다.

## 대안
1. `image_cropper` 패키지 버전 업그레이드만 수행하고 매니페스트는 유지한다.
2. 플러그인 문서대로 `UCropActivity`를 앱 매니페스트에 명시 선언하고,
   Android 15 테마 권장사항(`Ucrop.CropTheme`)까지 함께 반영한다.
3. 앱 내 이미지 크롭 기능을 비활성화하거나 대체 라이브러리로 교체한다.

## 결정
- 대안 2를 채택한다.
- `android/app/src/main/AndroidManifest.xml`에
  `com.yalantis.ucrop.UCropActivity`를 명시 선언한다.
- `android/app/src/main/res/values/styles.xml`에 `Ucrop.CropTheme`를 추가한다.
- Android 15+ 대응을 위해
  `android/app/src/main/res/values-v35/styles.xml`를 추가하고
  `windowOptOutEdgeToEdgeEnforcement=true`를 설정한다.

## 근거
- `image_cropper` 9.1.0 공식 README 및 예제 매니페스트는
  Android에서 `UCropActivity` 수동 선언을 요구한다.
- 현재 앱 매니페스트에는 해당 Activity가 없어 런타임에서
  `ActivityNotFoundException`이 발생할 수 있다.
- 변경 범위가 작고 기능 회귀 위험이 낮으며, 크래시 원인을 직접 해소한다.

## 영향 범위
- Android 이미지 크롭 진입 경로 전반(`image_cropper` 호출 기능)
- Android 리소스 테마(`Ucrop.CropTheme`)
- QA:
  - Samsung 포함 실기기에서 크롭 진입/완료/취소 플로우 재검증 필요

## 검증 메모
- `flutter analyze` 통과.
- `flutter build appbundle`은 환경 이슈(Gradle cache metadata/AGP DSL 경고)로
  실패하여, 매니페스트 병합 결과는 다음 빌드 환경 정상화 후 재확인 필요.

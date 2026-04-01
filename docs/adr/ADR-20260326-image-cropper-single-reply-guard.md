# ADR-20260326: Android image_cropper Reply already submitted crash guard

## Status
- Accepted (2026-03-26)

## 변경 전 문제
- Samsung 단말 중심으로 아래 크래시가 집계되었다.
  - `IllegalStateException: Reply already submitted`
  - `io.flutter.embedding.engine.dart.DartMessenger$Reply.reply`
  - `vn.hunghd.flutter.plugins.imagecropper.ImageCropperDelegate.onActivityResult`
- 문제 발생 시 Android 메인 스레드 예외로 앱 프로세스가 종료되었다.

## 대안
1. `image_cropper` 버전 업그레이드만 수행한다.
2. 앱에서 크롭 호출 재진입만 제한하고 플러그인은 그대로 둔다.
3. `image_cropper` Android delegate를 로컬 오버라이드 패치해 단일 reply 보장을 강제하고,
   앱 레벨 재진입 가드를 함께 적용한다.

## 결정
- 대안 3을 채택한다.
- `dependency_overrides`로 `third_party/image_cropper`를 사용한다.
- Android `ImageCropperDelegate`를 다음 원칙으로 패치한다.
  - 동시 크롭 요청 차단(`crop_in_progress`)
  - `startActivityForResult` 예외를 안전하게 `error`로 응답 후 종료
  - 응답 직전에 `pendingResult`를 소모(consume)하고, reply는 `try/catch`로 보호
  - 이미 응답 완료된 결과에 대한 중복 reply 예외(`IllegalStateException`)는 로깅 후 무시
- 앱(`profile_edit_page.dart`)에서 아바타/커버 변경 플로우에 재진입 방지 상태를 추가해
  중복 호출 가능성을 줄인다.
- 추가 완화책(임시):
  - Samsung Android 단말에서는 네이티브 크롭 액티비티 호출을 우회하고,
    선택한 원본 이미지를 바로 업로드한다.

## 근거
- `image_cropper` 9.1.0/12.1.0 Android delegate 코드를 비교했을 때,
  `pendingResult.success/error` 호출 경로에 단일 reply 강제 가드가 없다.
- 유사 이슈(중복 reply로 크래시)는 공개 이슈에서도 반복 보고되었다.
- 플러그인 교체 없이 현재 UX를 유지하면서 크래시 빈도를 낮추는 가장 작은 변경이다.
- Samsung 단말에서는 vendor-specific activity/result 타이밍 이슈가 남을 수 있어
  네이티브 크롭 자체를 건너뛰는 우회가 단기적으로 가장 안정적이다.

## 영향 범위
- Android 이미지 크롭 런타임 경로(`image_cropper` plugin)
- 설정 > 프로필 편집 화면의 이미지 변경 플로우
- 의존성 해석: `image_cropper`는 pub 원격 대신 로컬 패치 경로를 사용
- Samsung Android: 프로필 이미지 변경 시 크롭 UI가 표시되지 않고 바로 업로드됨(임시)

## 검증 메모
- `flutter pub get` (로컬 오버라이드 적용 확인)
- `flutter analyze` 통과
- `flutter test` 통과

## 출처 / 버전
- image_cropper package: v9.1.0 (현재 앱 사용 버전), v12.1.0 (최신 비교)
  - https://pub.dev/packages/image_cropper
  - https://pub.dev/packages/image_cropper/changelog
- image_cropper GitHub issue (유사 `Reply already submitted` 사례)
  - https://github.com/hnvn/flutter_image_cropper/issues/164

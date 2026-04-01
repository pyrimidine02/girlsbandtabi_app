# ADR-20260330: Android 프로필 이미지 크롭 인앱 전환 (크래시 안정화)

## Status
- Accepted (2026-03-30)

## 변경 전 문제
- Android에서 프로필 사진/커버 크롭 진입 시 `image_cropper`(uCrop Activity) 경로에서
  디바이스별 런타임 크래시가 재발했다.
- 기존 완화책은 Samsung 우회 중심이어서, 비Samsung Android 단말에서
  네이티브 크롭 경로가 계속 실행되는 리스크가 남아 있었다.

## 대안
1. 기존 `image_cropper` 네이티브 Activity 경로를 유지하고 벤더별 예외를 추가한다.
2. Android에서만 인앱 Flutter 크롭 UI로 전환하고, iOS는 기존 네이티브 크롭을 유지한다.
3. Android에서 크롭 기능 자체를 비활성화하고 원본 이미지만 업로드한다.

## 결정
- 대안 2 채택.
- Android 프로필 이미지 크롭을 `crop_your_image` 기반 인앱 다이얼로그로 전환한다.
- iOS/기타 플랫폼은 기존 `image_cropper` 흐름을 유지한다.
- 크롭 결과는 임시 파일로 저장 후 기존 업로드 파이프라인(WebP 변환/업로드)을 재사용한다.

## 근거
- 앱 프로세스 종료를 유발할 수 있는 네이티브 Activity 전환 구간을 Android에서 제거하면
  크래시 표면적을 직접 줄일 수 있다.
- 인앱 크롭은 동일한 비율 제약(아바타 1:1, 커버 16:9)을 유지할 수 있어 UX 손실이 작다.
- 업로드/서버 계약을 변경하지 않아 영향 범위를 UI 레이어로 한정할 수 있다.

## 영향 범위
- `lib/features/settings/presentation/pages/profile_edit_page.dart`
- `pubspec.yaml`, `pubspec.lock` (`crop_your_image` 추가)
- Android 프로필 편집 이미지 선택/크롭 플로우

## 검증 메모
- `flutter analyze lib/features/settings/presentation/pages/profile_edit_page.dart` 통과.
- 실기기 QA 필요:
  - Android 13/14/15에서 아바타/커버 크롭 적용/취소/복귀
  - 크롭 결과 반영 및 크래시 미발생 확인

## 출처 / 버전
- crop_your_image: ^2.0.0
- image_cropper: 9.1.0 (로컬 오버라이드 유지)

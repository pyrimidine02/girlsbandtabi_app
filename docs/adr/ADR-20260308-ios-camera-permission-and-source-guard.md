# ADR-20260308-ios-camera-permission-and-source-guard

## Status
Accepted (2026-03-08)

## Context
- 게시글 작성/수정 화면에서 카메라 아이콘 탭 시 iOS에서 앱이 종료되는 문제가 발생했습니다.
- iOS는 카메라 접근 시 `Info.plist`의 `NSCameraUsageDescription`가 없으면 앱을 강제 종료합니다.
- 일부 환경(시뮬레이터/미지원 기기)에서는 카메라 source 자체가 지원되지 않습니다.

## Decision
1. `ios/Runner/Info.plist`에 `NSCameraUsageDescription`를 추가한다.
2. 작성/수정 화면의 카메라 액션 호출 전 `supportsImageSource(ImageSource.camera)`를 확인한다.
3. 카메라 미지원 환경에서는 카메라 실행을 시도하지 않고 안내 메시지를 보여준다.

## Consequences
### Positive
- iOS 카메라 접근 시 권한 설명 누락으로 인한 강제 종료를 방지합니다.
- 미지원 디바이스에서 예외/크래시 대신 일관된 사용자 피드백을 제공합니다.

### Trade-offs
- 미지원 환경에서는 카메라 기능이 비활성 체감되며, 사용자는 갤러리 경로를 사용해야 합니다.

## Validation
- `flutter analyze lib/features/feed/presentation/pages/post_create_page.dart lib/features/feed/presentation/pages/post_edit_page.dart`

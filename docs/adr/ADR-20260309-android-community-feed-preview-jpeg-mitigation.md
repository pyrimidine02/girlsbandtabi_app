# ADR-20260309 Android Community Feed Preview JPEG Mitigation

## Status
- Accepted

## Context
- Community posts authored on Android intermittently showed no preview image in
  feed cards, while the same posts rendered images correctly on post detail.
- Current upload encoder behavior differs by platform:
  - Android: `image/webp`
  - iOS/macOS: `image/jpeg` fallback
- Feed preview depends primarily on summary-level `thumbnailUrl` /
  `imageUrls`; if backend summary-side thumbnail derivation is stricter for
  WebP, Android-authored posts can lose preview even when detail has images.

## Decision
- Add a targeted mitigation for community post compose/edit:
  - Force Android upload encoding to JPEG for those flows.
- Implemented by adding `forceJpeg` option to upload conversion utility and
  enabling it in:
  - `PostCreatePage._uploadImages`
  - `PostEditPage._uploadImages`

## Consequences
- Android community post image uploads become format-aligned with iOS fallback,
  reducing backend thumbnail-pipeline format variance.
- File size may increase compared with WebP uploads on Android.
- This is a mitigation, not a final contract fix; backend summary payload
  consistency (`thumbnailUrl`, `imageUrls`) remains the long-term requirement.

## Verification
- `flutter analyze lib/features/uploads/utils/webp_image_converter.dart lib/features/feed/presentation/pages/post_create_page.dart lib/features/feed/presentation/pages/post_edit_page.dart`

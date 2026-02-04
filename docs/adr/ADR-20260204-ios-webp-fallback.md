# ADR-20260204 iOS WebP Fallback

## Status
- Accepted

## Context
- iOS simulator crashes when attempting WebP encoding via
  `flutter_image_compress` (unsupported ImageIO output format).
- The app needs to remain stable during photo uploads on iOS.

## Decision
- Use WebP encoding on platforms that support it.
- Fallback to JPEG encoding on iOS/macOS while keeping EXIF when possible.
- Preserve the correct content type (`image/jpeg`) for fallback uploads.

## Alternatives Considered
- Keep WebP on iOS (rejected: native crash).
- Skip compression and upload originals (rejected: inconsistent size/format).
- Add a custom WebP encoder (deferred: would drop EXIF and add complexity).

## Consequences
- iOS/macOS uploads may be JPEG while other platforms stay on WebP.
- Backend must accept `image/jpeg` alongside `image/webp` for uploads.

## References
- lib/features/uploads/utils/webp_image_converter.dart
- lib/features/places/presentation/widgets/place_review_sheet.dart
- lib/features/settings/presentation/pages/profile_edit_page.dart

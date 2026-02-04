# ADR-20260204 WebP Upload Conversion

## Status
- Accepted

## Context
- Upload API accepts `image/webp`, and iOS images are often HEIC.
- Backend validation requires a consistent content type for uploads.

## Decision
- Convert all selected images to WebP before upload.
- Use `flutter_image_compress` with `keepExif: true` for best-effort metadata
  preservation and a max size/quality appropriate for mobile uploads.

## Alternatives Considered
- Upload original formats (rejected: inconsistent server support).
- Convert only HEIC (rejected: requirement wants all images normalized).

## Consequences
- Uploads are normalized to WebP with predictable content types.
- Some metadata may still be lost depending on platform codec support.

## References
- lib/features/uploads/utils/webp_image_converter.dart
- lib/features/places/presentation/widgets/place_review_sheet.dart
- lib/features/settings/presentation/pages/profile_edit_page.dart

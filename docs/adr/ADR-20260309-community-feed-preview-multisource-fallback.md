# ADR-20260309 Community Feed Preview Multi-Source Fallback

## Status
- Accepted

## Context
- On Android, some community posts intermittently rendered without preview
  image in feed cards while post detail still had image context.
- Existing card logic selected a single preview URL with strict priority and
  did not recover when that chosen URL failed to load.

## Decision
- Introduce multi-source preview candidates for feed/board cards:
  1. `thumbnailUrl`
  2. `imageUrls`
  3. image URLs extracted from post content
- Add runtime fallback on image-load failure:
  - if current preview URL fails, automatically retry next candidate.
- Keep `imageUploadIds` from create-upload results even when a temporary empty
  upload URL is returned, so backend thumbnail derivation is not blocked.

## Consequences
- Feed preview is more resilient to partial/unstable summary image fields.
- Broken `thumbnailUrl` no longer forces an empty preview when alternative
  image sources are available.
- Minor extra image-request attempts can occur when initial URLs fail.

## Verification
- `flutter analyze lib/core/widgets/common/gbt_image.dart lib/features/feed/presentation/pages/feed_page.dart lib/features/feed/presentation/pages/board_page.dart lib/features/feed/presentation/pages/post_create_page.dart`

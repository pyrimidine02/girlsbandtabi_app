# ADR-20260308 Feed Preview Thumbnail Priority and URL Sanitization

## Status
Accepted

## Context
- On Android feed cards, newly uploaded post images were intermittently missing
  from list preview while post detail rendered images normally.
- Feed card preview logic prioritized `imageUrls.first`, which can diverge from
  backend-selected thumbnail semantics.
- Backend contract already defines thumbnail derivation from the first uploaded
  image (`imageUploadIds[0]`).

## Decision
- Update feed/board post-card preview image resolution priority:
  1. `thumbnailUrl` (server-selected first upload thumbnail)
  2. first valid item in `imageUrls`
  3. first image extracted from post content
- Harden post summary DTO image URL parsing:
  - trim URL values,
  - ignore invalid placeholder values like `"null"`,
  - accept additional URL object keys (`publicUrl`, `cdnUrl`),
  - normalize map key parsing for dynamic JSON objects.

## Consequences
- Feed list preview is consistent with backend first-upload thumbnail behavior.
- UI is more resilient to mixed/dirty image URL payload shapes.
- Existing older posts without `thumbnailUrl` remain backward-compatible via
  fallback order.

## Verification
- `flutter analyze lib/features/feed/data/dto/post_dto.dart lib/features/feed/presentation/pages/board_page.dart lib/features/feed/presentation/pages/feed_page.dart`
- `flutter test test/features/feed/data/post_dto_test.dart`

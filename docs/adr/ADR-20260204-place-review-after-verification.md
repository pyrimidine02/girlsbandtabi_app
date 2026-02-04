# ADR-20260204 Place Review After Verification

## Status
- Accepted

## Context
- After a successful place verification, users need to submit a visit review
  and optional photos.
- The app already supports presigned uploads but lacked UI and comment creation.

## Decision
- Add a post-verification review sheet for places.
- Upload selected images via presigned URLs and confirm uploads.
- Create a place comment using `photoUploadIds`.
- Show “아직 준비중입니다.” when a 403 occurs.

## Alternatives Considered
- Defer review flow (rejected: requirement asks for immediate availability).

## Consequences
- Users can submit reviews with photo attachments right after verification.
- Requires photo library permission on iOS.

## References
- lib/features/places/presentation/widgets/place_review_sheet.dart
- lib/features/verification/presentation/widgets/verification_sheet.dart
- lib/features/uploads/utils/presigned_upload_helper.dart

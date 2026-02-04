# ADR-20260204 Profile Avatar Upload

## Status
- Accepted

## Context
- Users need to update profile photos from the profile edit page.
- The backend already exposes presigned upload + confirm APIs for media.

## Decision
- Use `image_picker` to select a photo from the gallery.
- Upload the file via presigned URL, confirm it, then store the returned URL as
  `avatarUrl` when saving the profile.
- Display upload progress state on the avatar and surface failures via snackbars.

## Alternatives Considered
- Defer avatar upload until a separate settings screen (rejected: slower UX).

## Consequences
- Profile photos can be updated without leaving the edit page.
- Uploads are performed before saving, so a new avatar URL is available at save.

## References
- lib/features/settings/presentation/pages/profile_edit_page.dart
- lib/features/uploads/application/uploads_controller.dart
- lib/features/uploads/utils/presigned_upload_helper.dart

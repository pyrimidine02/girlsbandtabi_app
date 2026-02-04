# ADR-20260204 Reject Upload Deletes

## Status
- Accepted

## Context
- Admin can approve or reject review photo uploads.
- Rejected uploads should be removed from R2 to avoid orphaned storage.

## Decision
- After rejecting an upload, call the delete upload endpoint to remove the
  file from storage.

## Consequences
- Rejected photos are removed from R2 and will no longer resolve in UI.
- Admins cannot re-approve deleted uploads without re-uploading.

## References
- lib/features/places/presentation/pages/place_detail_page.dart
- lib/features/uploads/application/uploads_controller.dart

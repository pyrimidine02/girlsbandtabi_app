# ADR-20260204 Admin Review Photo Approval

## Status
- Accepted

## Context
- Visit reviews can include photo uploads.
- Admins need to approve or reject those photos via the new uploads API.

## Decision
- Surface review photo thumbnails in the place detail comments section.
- For admin users, provide approve/deny actions that call
  `/api/v1/uploads/{uploadId}/approve`.

## Alternatives Considered
- Build a separate moderation screen (rejected: adds extra navigation).

## Consequences
- Admins can moderate review photos directly from place details.
- Approval actions operate on all photo uploads attached to a comment.

## References
- lib/features/places/presentation/pages/place_detail_page.dart
- lib/features/uploads/application/uploads_controller.dart

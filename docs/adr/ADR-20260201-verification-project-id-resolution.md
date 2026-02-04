# ADR-20260201 Verification Project ID Resolution

## Status
- Accepted

## Context
- Place verification requests kept returning HTTP 400 while sending valid
  latitude/longitude payloads.
- The backend may validate `projectId` as a UUID for verification endpoints,
  but the app was always passing the selected project key (slug/code).
- The project selection UI already has the UUID available, but it was not
  persisted for reuse.

## Decision
- Persist the selected project UUID alongside the project key.
- Prefer the stored project UUID for verification requests; fall back to the
  project key when the UUID is unavailable.

## Alternatives Considered
- Keep using only the project key for verification (rejected: potential UUID
  validation errors).
- Always fetch the projects list to resolve UUIDs on demand (deferred: extra
  latency and network coupling).

## Consequences
- Verification requests can use the UUID without altering the existing project
  selection API or UI state shape.
- If the backend accepts slugs, the fallback preserves current behavior.

## References
- lib/features/projects/application/projects_controller.dart
- lib/features/projects/presentation/widgets/project_selector.dart
- lib/features/verification/application/verification_controller.dart

# ADR-20260202 Project Slug API Usage

## Status
- Accepted

## Context
- The backend accepts project slugs for at least some project-scoped paths
  (verified for `GET /api/v1/projects/{projectId}/units` using the slug).
- The app already stores a project key (slug/code) alongside legacy project IDs.
- We want consistent, human-readable identifiers in project-scoped requests
  whenever the API supports them.

## Decision
- Use the stored project key (slug/code) for project-scoped API paths.
- Fall back to legacy project IDs only when the slug is missing.

## Alternatives Considered
- Continue preferring IDs (rejected: contradicts slug-first request and reduces
  readability in logs/debugging).
- Make per-endpoint switches (deferred: revisit if any endpoint rejects slugs).

## Consequences
- Units + verification requests now use project slugs when available.
- Remaining project-scoped endpoints still need verification to ensure slug
  compatibility.

## References
- lib/features/projects/presentation/widgets/project_selector.dart
- lib/features/projects/application/projects_controller.dart
- lib/features/verification/application/verification_controller.dart

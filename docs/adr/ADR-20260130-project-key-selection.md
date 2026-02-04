# ADR-20260130 Project Selection by Slug/Code

## Status
- Accepted

## Context
- Project-scoped endpoints were called with a hardcoded project ID, causing 404s in local/dev environments.
- The backend provides a projects list that includes a human-readable slug/code (e.g., `girls-band-cry`).

## Decision
- Fetch and cache the projects list, then select a project key from the API response.
- Use the project slug/code as the project key for project-scoped requests (places, live events, news, units, verification).
- Keep a legacy migration path for stored project IDs and map them to slugs when possible.

## Alternatives Considered
- Keep hardcoded project IDs in AppConfig (rejected: brittle and blocks local testing).
- Add a manual project ID override (deferred: prefer API-driven selection first).

## Consequences
- Project-dependent requests wait for project selection instead of falling back to AppConfig defaults.
- Android emulators or devices may still need a host alias to reach the local API.

## References
- lib/features/projects/application/projects_controller.dart
- lib/core/storage/local_storage.dart
- lib/features/*/application/*_controller.dart

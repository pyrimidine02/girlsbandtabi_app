# ADR-20260131 Projects Fetch Dedupe and Units Project ID

## Status
- Accepted

## Context
- App startup triggered multiple concurrent calls to `/api/v1/projects` from
  both project selection initialization and the projects list controller.
- Home summary requests were occasionally duplicated when project key and unit
  filters updated in quick succession.
- Unit list requests were returning 500 errors when called with the project
  slug/code; API docs describe the parameter as `{projectId}`.
- The local Swagger UI at `http://localhost:8080/swagger-ui/index.html` was not
  reachable from this environment, so the internal API guide was used as the
  fallback reference.

## Decision
- Deduplicate in-flight project list fetches in `ProjectsRepositoryImpl` and
  avoid redundant selection updates when the unit list is unchanged.
- Guard the home summary loader from duplicate requests while the same
  selection is already in-flight.
- Use the project ID when requesting units, with a fallback to slug/code if the
  ID is unavailable.

## Alternatives Considered
- Merge projects selection and projects list into a single provider (deferred:
  larger refactor).
- Add a new selection state model for home summary that coalesces project + unit
  changes (deferred: broader state changes).
- Keep using slug/code for units and accept server errors (rejected).

## Consequences
- Startup produces fewer duplicate network calls for projects and home summary.
- Unit fetches use project IDs, aligning with the `{projectId}` contract.
- If Swagger differs from the internal docs, the endpoints may need revalidation
  once Swagger is accessible.

## References
- docs/프런트엔드개발자참고문서_v1.0.0.md
- lib/features/projects/application/projects_controller.dart
- lib/features/projects/data/repositories/projects_repository_impl.dart
- lib/features/projects/presentation/widgets/project_selector.dart
- lib/features/home/application/home_controller.dart

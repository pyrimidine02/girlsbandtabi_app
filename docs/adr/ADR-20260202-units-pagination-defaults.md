# ADR-20260202 Units Pagination Defaults

## Status
- Accepted

## Context
- Swagger/OpenAPI served at `/api-docs/api` defines
  `GET /api/v1/projects/{projectId}/units` with optional `page`, `size`,
  and `sort` query parameters and a paginated list response.
- The app previously called the endpoint without query parameters, while the
  backend currently returns HTTP 500 even with explicit pagination.
- We want the client to align with the documented contract to remove one
  possible variable during backend debugging.

## Decision
- Always include default pagination parameters (`page=0`, `size=20`) when
  requesting project units, with optional `sort` support for future use.

## Alternatives Considered
- Leave the request unparameterized (rejected: diverges from documented
  contract and complicates debugging).
- Change the repository/controller to pass pagination options (deferred: the
  UI currently consumes full lists without paging UX).

## Consequences
- The units request now matches the Swagger contract even when the UI does not
  expose pagination controls.
- Backend 500s remain a server-side issue and require backend fixes/log review.

## References
- lib/features/projects/data/datasources/projects_remote_data_source.dart
- docs/프런트엔드개발자참고문서_v1.0.0.md
- /api-docs/api (Swagger/OpenAPI)

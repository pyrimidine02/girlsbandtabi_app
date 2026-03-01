## ADR-20260301: Endpoint-Driven User Feature Coverage

### Status
- Accepted

### Context
- The user requested endpoint-driven product coverage against the current
  OpenAPI snapshot and asked for missing user-facing features to be implemented.
- The v3 snapshot (`api_docs.json`, OpenAPI 3.0.1) contains 197 paths, mixing:
  - end-user mobile features,
  - moderator/admin operational APIs,
  - health/actuator and internal streams.
- Implementing every endpoint as a standalone mobile page is not an appropriate
  product strategy because many paths are backoffice-only or infrastructure-only.

### Decision
- Treat endpoint coverage as **user-journey coverage** instead of raw path count.
- Group endpoints into user-facing capability domains:
  - Auth / profile / notifications
  - Home / search
  - Places / regions / comments / verification
  - Live events
  - Community posts/comments/reports
  - Account tools (blocks / role requests / verification appeals)
- Implement newly missing user-facing capabilities in this pass:
  - `GET /api/v1/users/me/blocks`, `DELETE /api/v1/users/me/blocks/{targetUserId}`
  - `GET|POST /api/v1/projects/role-requests`,
    `DELETE /api/v1/projects/role-requests/{requestId}`
  - `GET|POST /api/v1/projects/{projectId}/verification-appeals`
- Expose these in one cohesive UX surface: `Settings > Account Tools`.

### Consequences
- User-facing endpoint coverage improves without adding fragmented standalone
  pages for each API path.
- Previously backend-only wired APIs now have direct in-app workflows:
  - block list management,
  - role request creation/cancellation,
  - verification appeal submission/history.
- Some endpoints remain intentionally out of app scope (admin dashboards,
  media-deletion review, circuit breakers, stream endpoints, actuator paths)
  and should continue to live in operator tooling.

### References
- OpenAPI snapshot: `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/api_docs.json`
- Endpoint catalog: `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/constants/api_v3_endpoints_catalog.dart`

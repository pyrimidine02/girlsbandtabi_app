# ADR-20260218: OpenAPI v3 Endpoint Sync

## Status
Accepted

## Context
Backend endpoints changed and the client needed alignment with the current
`/v3/api-docs` contract. Two client paths in active moderation flows no longer
existed in the latest spec.

## Decision
- Fetch and use `http://localhost:8080/v3/api-docs` as the source of truth.
- Add a generated endpoint catalog snapshot for the full v3 path/method set.
- Remove non-existent endpoint constants:
  - `/api/v1/users/me/actionable-status`
  - `/api/v1/community/appeals`
- Add currently documented moderation-related endpoint builders:
  - `/api/v1/projects/{projectCode}/moderation/bans`
  - `/api/v1/projects/{projectCode}/moderation/posts/{postId}`
  - `/api/v1/projects/{projectId}/verification-appeals`
- Change sanction lookup to `/api/v1/users/me` with optional sanction field
  parsing to avoid hard dependency on removed paths.

## Alternatives Considered
- Keep removed endpoints and rely on 404 fallback behavior.
- Delay sync until BE reintroduces dedicated sanction/appeal endpoints.

## Consequences
- Runtime avoids unnecessary 404 calls for removed endpoints.
- Endpoint coverage is auditable against a concrete v3 snapshot.
- Community post-appeal feature remains backend-limited until a matching
  endpoint is exposed in OpenAPI.

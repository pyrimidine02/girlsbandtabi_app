# ADR-20260219: Admin Ops UI and Endpoint Wiring

- Date: 2026-02-19
- Status: Accepted

## Context

The OpenAPI v3 snapshot includes admin/operations endpoints that were present in constants but not wired to runtime data sources or screens (for example: dashboard and admin community report moderation endpoints).

Users requested full endpoint alignment and visible UI entry points for changed contracts, including role-based access behavior in the app.

## Decision

1. Add a new feature module: `lib/features/admin_ops/` with Clean Architecture layers.
2. Wire these admin endpoints to concrete data flows:
   - `GET /api/v1/admin/dashboard`
   - `GET /api/v1/admin/moderation/dashboard` (fallback)
   - `GET /api/v1/admin/community/reports`
   - `GET/PATCH /api/v1/admin/community/reports/{reportId}`
   - `PATCH /api/v1/admin/community/reports/{reportId}/assign`
3. Add a new admin screen route:
   - `/settings/admin` (`AppRoutes.adminOps`)
4. Expose “운영 센터” menu in settings only for admin-capable roles.
5. Add endpoint contract tests and DTO parsing tests for new admin endpoint usage.

## Alternatives Considered

- Keep endpoints constants-only without UI/data wiring.
  - Rejected: does not satisfy endpoint sync + UX request.
- Add an entirely separate app section outside settings.
  - Rejected: higher navigation impact and rollout risk.

## Consequences

- Positive:
  - Admin endpoints are now used end-to-end from screen to repository.
  - Settings has a discoverable, role-gated admin entry point.
  - Endpoint contract coverage catches future path/method drift.
- Trade-off:
  - Request body fields for report assign/status are intentionally tolerant (multi-key payload) until backend payload schema is frozen.

## Follow-up

- Confirm canonical request field names for assign/review PATCH payloads and remove compatibility keys.
- Expand admin pages to cover other operational endpoints (role requests, verification appeals, media deletion requests) after product prioritization.

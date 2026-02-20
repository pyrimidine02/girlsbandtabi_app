# ADR-20260218: Community Moderation Enhancement (P0-P1)

## Status
Accepted

## Context
Community moderation UX was limited to simple report/block actions and had no
client-side report cooldown, no visible content moderation state, no sanction
precheck in posting flow, and no appeal submission path.

## Decision
- Add client-side report cooldown (`5 minutes`) per target ID.
- Require a confirmation dialog before report submission.
- Extend post DTO/domain with `moderationStatus` and render quarantine banner.
- Add sanction model (`none/warning/muted/banned`) and fetch my sanction status.
- Block post creation for restricted users (`muted`/`banned`).
- Add moderation appeal submission flow and API wiring.
- Apply graceful fallback for sanction status endpoint non-availability
  (`404`/network => `none`) to preserve existing UX.

## Alternatives Considered
- Server-only throttling without client cooldown: poor immediate UX feedback.
- Hard-fail sanction endpoint errors: risky regression when backend is rolling
  out the endpoint.
- Appeal support in a separate screen only: heavier navigation overhead.

## Consequences
- Users receive immediate, clear moderation feedback at submission points.
- Author-facing appeal path is available directly from quarantined content.
- Posting restrictions are enforced earlier in the client flow.
- Client remains backward compatible while backend endpoints roll out.

# ADR-20260128 Verification Stage 9 Check-in Flow

## Status
- Accepted

## Context
- Stage 9 requires place/live verification flows using `/verification/challenge` and verification endpoints.
- Detailed payload schema is not fully specified in the frontend docs.

## Decision
- Implement verification data pipeline (remote datasource → repository → controller).
- Use challenge token from `/verification/challenge` and send as `challengeToken` in verification request.
- Surface verification via bottom sheet from place/live detail pages with loading/error/success states.

## Alternatives Considered
- Defer verification integration until full schema is provided (rejected: Stage 9 milestone).

## Consequences
- Verification request payload may need expansion once backend schema is confirmed.

## References
- docs/GBT_Flutter_Implementation_Plan_v1.3.md (Stage 9)
- docs/프런트엔드개발자참고문서_v1.0.0.md (verification endpoints)

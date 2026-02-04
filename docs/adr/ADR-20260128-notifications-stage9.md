# ADR-20260128 Notifications Stage 9 Integration

## Status
- Accepted

## Context
- Stage 9 requires notification list, read handling, and navigation to notification settings.

## Decision
- Implement notifications data pipeline (remote datasource → repository with cache → controller).
- Update notifications page with grouped sections and read indicators.
- Wire "알림 설정" menu to settings notification page.

## Alternatives Considered
- Local-only notifications (rejected: server source of truth).

## Consequences
- Notification DTO field mapping may require updates when backend schema is finalized.

## References
- docs/GBT_Flutter_Implementation_Plan_v1.3.md (Stage 9)
- docs/프런트엔드개발자참고문서_v1.0.0.md (notification endpoints)

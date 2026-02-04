# ADR-20260202 Live Events Order and D-day

## Status
- Accepted

## Context
- The live events list relied on server order, which could surface older
  entries ahead of closer dates.
- The UI only displayed dates without a D-day indicator for quick context.

## Decision
- Sort upcoming events by `showStartTime` ascending (closest upcoming first).
- Sort completed events by `showStartTime` descending (most recent first).
- Add a D-day label (D-day, D-#, D+#) based on local date and surface it in the
  list date badge and event detail date row.

## Alternatives Considered
- Keep server order (rejected: inconsistent recency ordering).
- Show D-day only in the detail page (rejected: list lacks quick context).

## Consequences
- The live list now aligns with "recent first" expectations per status tab.
- Users see both date and D-day at a glance.

## References
- lib/features/live_events/domain/entities/live_event_entities.dart
- lib/features/live_events/presentation/pages/live_events_page.dart
- lib/core/widgets/cards/gbt_event_card.dart
- lib/features/live_events/presentation/pages/live_event_detail_page.dart

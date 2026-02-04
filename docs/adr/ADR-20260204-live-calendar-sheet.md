# ADR-20260204 Live Calendar Sheet

## Status
- Accepted

## Context
- The Live page had a calendar icon but no implementation.
- Users need a quick way to browse events by date.

## Decision
- Implement a modal bottom sheet with a custom month grid.
- Mark dates that have events with a dot indicator.
- Show events for the selected date under the calendar.

## Alternatives Considered
- Full-screen calendar view (deferred: higher effort).
- Separate calendar tab (deferred: UX decision pending).

## Consequences
- Calendar icon now opens a working calendar view.
- Users can jump directly to events on a specific date.

## References
- lib/features/live_events/presentation/pages/live_events_page.dart

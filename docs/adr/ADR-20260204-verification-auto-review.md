# ADR-20260204 Verification Auto Review Open

## Status
- Accepted

## Context
- Place verification already supports a post-checkin review sheet.
- Users requested that the review sheet opens automatically after a successful
  verification instead of requiring an extra tap.

## Decision
- Auto-close the verification sheet and open the review sheet once verification
  succeeds (only when a review callback is provided).

## Alternatives Considered
- Keep the manual “후기 작성” button (rejected: adds an extra step).

## Consequences
- Verification success immediately transitions into review authoring.
- Live-event verification remains unchanged because no review callback is set.

## References
- lib/features/verification/presentation/widgets/verification_sheet.dart
- lib/features/places/presentation/pages/place_detail_page.dart

# ADR-20260219: Place Marker Type Styling and List Type/Tag Labels

- Date: 2026-02-19
- Status: Accepted

## Context

Users requested two map/list UX changes:

1. Change map marker style based on each place's first type.
2. Show both place types and tags in the places list.

The existing UI used a single default marker style and did not surface tags in the list card.

## Decision

1. Add `placeMarkerHueFromFirstType()` utility to map the first type into stable marker hue buckets.
2. Apply this hue mapping to both map providers:
   - Google Maps marker hue (`defaultMarkerWithHue`)
   - Apple Maps annotation hue (`defaultAnnotationWithHue`)
3. Keep cluster markers in a dedicated cluster color (orange).
4. Extend summary DTO/domain with `tags` so list screens can render tags without additional detail API calls.
5. Extend horizontal place cards to render small chips for:
   - types (category chip)
   - tags (tag chip)

## Consequences

- Positive:
  - Users can distinguish marker categories at a glance.
  - Places list now exposes type+tag context together.
- Trade-off:
  - Summary endpoints without `tags` will render type chips only.
  - Marker hues are heuristic buckets and may need tuning after UX feedback.

## Follow-up

- Verify backend summary endpoints consistently include `tags`.
- Tune hue mapping table as place-type taxonomy expands.

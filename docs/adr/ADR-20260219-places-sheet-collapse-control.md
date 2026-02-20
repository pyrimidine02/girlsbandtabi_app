# ADR-20260219: Places Sheet Collapse Control from Mid-List Scroll

- Date: 2026-02-19
- Status: Accepted

## Context

In `PlacesMapPage`, users could not easily collapse the bottom sheet while the list was scrolled to the middle because drag gestures were consumed by inner list scrolling.

## Decision

Add a persistent floating toggle button bound to `DraggableScrollableController`:

- When expanded: button collapses sheet to min size.
- When collapsed: button expands sheet back to initial size.
- Keep existing drag behavior unchanged.

## Consequences

- Positive: Users can reveal the map instantly without scrolling list back to top.
- Trade-off: Adds one more floating action control on the map screen.

## Follow-up

- Validate button placement on smaller devices and adjust offsets if it overlaps other controls.

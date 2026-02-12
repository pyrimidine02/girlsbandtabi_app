# ADR-20260212: Defer Connectivity Overlay Updates

## Status
Accepted

## Context
On iOS, a `semantics.parentDataDirty` assertion can occur when the connectivity
overlay updates during a semantics flush. The overlay uses `Positioned` in a
`Stack`, and updates triggered by the connectivity stream can land in the
middle of a frame.

## Decision
- Keep the overlay layout stable.
- Defer connectivity-driven state updates with a post-frame callback so the
  UI updates occur in the next frame.

## Alternatives Considered
- Leave direct `ref.watch` updates in build (risking mid-frame semantics churn).
- Remove the offline banner (loses important UX feedback).

## Consequences
- Offline banner updates are delayed by at most one frame.
- Reduced risk of iOS semantics assertions during frame processing.

# ADR-20260211: Offline Banner Overlay

## Status
Accepted

## Context
The offline banner was rendered in a column above the app content, which pushed
the UI down whenever connectivity changed. This caused a visible layout shift.

## Decision
- Render the offline banner as an overlay (Stack + Positioned) so it does not
  affect layout flow.
- Use `IgnorePointer` to avoid blocking UI interactions beneath the banner.

## Alternatives Considered
- Keep layout shift and add animation.
- Use `ScaffoldMessenger` banners/snackbars per page.

## Consequences
- No vertical layout shift when entering/exiting offline mode.
- The banner overlays the top edge but does not block interactions.

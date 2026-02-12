# ADR-20260212: iOS Map Offstage Guard by Active Tab

## Status
Accepted

## Context
`StatefulShellRoute.indexedStack` keeps every tab branch mounted, which means
the iOS map platform view can be built even when the Places tab is not active.
This has produced iOS rendering/semantics assertions (including parentData
dirty during semantics flush) and startup instability.

## Decision
- Track the active bottom navigation index in a shared provider.
- Gate the map view build so the platform view is only created when the Places
  tab is active.

## Alternatives Considered
- Rely on `ModalRoute.isCurrent` checks inside the map view (insufficient for
  indexed-stack tabs).
- Keep the map mounted offstage (continues to trigger iOS platform view issues).

## Consequences
- The map platform view no longer builds when the tab is inactive.
- Switching to the Places tab recreates the map view, which is acceptable for
  stability on iOS.

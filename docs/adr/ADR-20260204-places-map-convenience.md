# ADR-20260204 Places Map Convenience Features

## Status
- Accepted

## Context
- The map view needed quick actions for refreshing data, fitting all markers,
  and searching by place/region.
- Large datasets benefit from clustering and filter summaries.

## Decision
- Add map convenience actions:
  - Fit all markers into view.
  - Refresh list + region options.
  - Filter summary chips with quick reset.
  - Lightweight clustering based on zoom-level grid.
  - Local search for regions/places to recenter the map.

## Alternatives Considered
- Rely on external clustering packages (rejected: keep platform parity and
  avoid extra dependencies for Apple Maps).

## Consequences
- Cluster markers are approximate and update on camera idle.
- Search uses local data + region options; no geocoding yet.

## References
- lib/features/places/presentation/pages/places_map_page.dart

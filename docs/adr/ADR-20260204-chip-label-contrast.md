# ADR-20260204 Chip Label Contrast

## Status
- Accepted

## Context
- Related band tags in the place detail screen were rendered with a white
  label color on a light chip background, making the text unreadable.

## Decision
- Set the light theme chip label style to `GBTColors.textSecondary` so tag
  labels maintain readable contrast.

## Alternatives Considered
- Override label color per screen (rejected: inconsistent styling).

## Consequences
- Chip labels remain readable across light surfaces.

## References
- lib/core/theme/gbt_theme.dart

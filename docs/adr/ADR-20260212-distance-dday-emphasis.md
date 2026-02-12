# ADR-20260212: Distance and D-Day Visual Emphasis

## Status
Accepted

## Context
Place lists and live event lists were visually neutral, making key metadata
(distance and D-day) easy to miss. The request is to emphasize these values
with color while preserving the existing neutral-first layout.

## Decision
- Render distance on horizontal place cards as a teal semantic badge.
- Render upcoming event D-day labels as a pink accent pill.
- Keep past events in neutral styling to avoid overstating stale data.

## Alternatives Considered
- Apply accent colors to all metadata (too noisy).
- Use larger typography without color (less scannable).

## Consequences
- Distance and D-day are easier to scan.
- Accent usage remains limited to key status signals.

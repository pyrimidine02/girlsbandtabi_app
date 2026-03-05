# ADR-20260305 Board Top Chrome Compact + Search Icon Entry

- Date: 2026-03-05
- Status: Accepted

## Context

- Board page top area occupied too much vertical space.
- User requested:
  - reduce visual footprint of `커뮤니티/여행 후기` selector
  - replace always-visible search bar with a simple magnifier icon.

## Decision

- Reduced AppBar segmented-tab chrome:
  - preferred height `44 -> 36`
  - segmented control height `44 -> 36`
  - tighter paddings/radius/label spacing
- Replaced persistent community search bar with icon-trigger flow:
  - top compact row with `검색` icon
  - tapping icon opens search bottom sheet (`TextField + 검색/초기화`)
  - existing controller search behavior preserved (`applySearch`, `clearSearch`)
  - while searching, quick clear icon remains visible in top row.

## Alternatives Considered

- Keep full search bar and only reduce tab height:
  - Rejected, because user explicitly requested icon-only search entry.
- Move search icon to parent AppBar actions:
  - Rejected for now to avoid cross-tab state coupling complexity between parent `BoardPage` and child `CommunityTab`.

## Consequences

- More vertical space available for feed content at top.
- Search remains discoverable while reducing constant chrome usage.
- Search interaction becomes one extra tap (icon -> sheet), which is acceptable for current density goal.

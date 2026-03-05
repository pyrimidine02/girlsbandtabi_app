# ADR-20260305 Option B Board Sub Bottom Navigation

- Date: 2026-03-05
- Status: Accepted

## Context

- User explicitly requested Option B-like behavior with one additional condition:
  - keep the original main 5-tab bottom navigation
  - when entering `게시판`, replace the bottom bar with a board-specific one
    (`← + 피드/발견/여행후기`)
- Existing board redesign still relied on an internal board section nav, which did
  not satisfy this requirement.

## Decision

- Restored shell-level primary tabs to the original 5-tab layout:
  - `/home`, `/places`, `/live`, `/board`, `/info`
- `BoardPage` now supports route-driven section rendering:
  - `initialSection`
  - `showInternalSectionNav`
- Main scaffold now renders a board-specific sub bottom bar when branch index is
  `게시판`:
  - left back arrow: `go(lastNonBoardLocation)` with fallback `/home`
  - section tabs route switches:
    - `/board`
    - `/board/discover`
    - `/board/travel-reviews-tab`
- Board sub bottom bar visual style follows the same liquid-glass language as the
  primary bottom navigation for UI consistency.
- Board branch keeps post/review detail/create routes under `/board/...`.
- Added compatibility redirects for previously introduced paths:
  - `/feed`, `/discover`, `/travel-reviews-tab`, `/posts/...`,
    `/travel-reviews/...` -> corresponding `/board/...` paths

## Alternatives Considered

- Keep only board-internal top nav:
  - Rejected because user explicitly required section switching in the bottom bar.
- Full removal of compatibility paths without redirects:
  - Rejected to avoid breaking existing links and shared deep links.

## Consequences

- User-requested IA is satisfied: main tabs stay intact, and board uses a dedicated
  sub bottom navigation with back arrow.
- Existing and transitional links remain valid via redirects.

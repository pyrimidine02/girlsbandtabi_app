# ADR-20260305 Board Toss-Style Nav and Feed Redesign

- Date: 2026-03-05
- Status: Accepted

## Context

- User requested replacing the board top selector (`커뮤니티/여행 후기`) with a Toss-like dedicated navigation bar.
- Required elements:
  - back arrow
  - sections: `피드`, `여행후기`
  - one additional section chosen by frontend
- Additional request: redesign feed surface closer to Toss Securities feed scanning experience.

## Decision

- Removed AppBar bottom segmented selector and introduced a board-specific nav bar in body top:
  - back arrow (`canPop -> pop`, fallback -> `/home`)
  - section chips: `피드`, `발견`, `여행후기`
- Switched board content rendering from `TabBarView` to section-state conditional rendering.
- Added `발견` section mapped to community `trending` mode (forced sync on section entry, restore to `추천` when returning to `피드`).
- Added Toss-like feed hero header (`오늘의 피드` / `지금 발견되는 글`) with compact count badge.
- Reworked feed list container style from divider timeline to rounded panel cards for high-density scanning.
- Added project-context copy rule in post meta: `프로젝트명에 남긴 글`.
- Added section-level motion rule with `fade-through` style switch animation and selection haptic feedback.
- Added reduced-motion fallback (`MediaQuery.disableAnimations`) to keep section switch accessible.

## Alternatives Considered

- Keeping `TabController` with extended 3-tab structure:
  - Rejected due unnecessary controller complexity and lifecycle side effects for section-specific mode forcing.
- Putting board nav into global bottom nav:
  - Rejected to avoid cross-feature navigation model changes in `MainScaffold`.

## Consequences

- Board now has a distinct IA and interaction model aligned with requested style.
- `발견` section provides discovery utility without adding new backend contract.
- Existing role-based FAB actions remain preserved and section-aware.

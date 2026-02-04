# ADR-20251204: QuickAccessGrid Overflow Fix

## Status
**Accepted** – Implemented on 2025-12-04

## Context
- QA spotted a `RenderFlex overflowed by 16 pixels` error on iPhone 17 Pro Max whenever the Home screen rendered the QuickAccessGrid.
- Each tile used a hard-coded `childAspectRatio: 1.5`, so the cards were forced into ~110px heights on narrow widths while the icon/badge/text stack needed ~180px.
- Because the grid sat inside a `SingleChildScrollView`, the overflow manifested as runtime red stripes instead of clipping, blocking dogfooding and raising accessibility concerns.

## Decision
1. Wrap QuickAccessGrid with `LayoutBuilder` so we can dynamically compute the usable width, pick an appropriate column count (2/3/4), and derive the tile width just like `SliverGrid` does internally.
2. Clamp each tile's height toward a 184px target by calculating `childAspectRatio = tileWidth / targetHeight` and bounding it between 0.9 and 1.35 to cover phones/tablets without producing squat desktop tiles.
3. Leave the existing card contents untouched but let the responsive delegate provide the required space, preventing Column overflows without adding extra rebuilds.
4. Add `test/features/home/presentation/widgets/quick_access_grid_test.dart` to pump the widget at a 320px width and assert that no overflow exceptions are thrown, guarding against future regressions when copy lengths change.
5. Document the change here, reference it in `CHANGELOG.md`, and open a `TODO.md` reminder for broader golden coverage (tablet/desktop, localized copy) once UX finalizes the strings.

## Consequences
### Positive
- Home dashboard loads without layout exceptions across the tested device matrix, so debug banners no longer mask other regressions.
- The grid now adapts to tablets/desktops automatically, unlocking denser layouts without manual rewrites.
- Regression test provides fast feedback if future content/spacing changes make the cards too tall again.

### Negative / Risks
- The responsive breakpoints (720/1024) were chosen heuristically; once designers hand off concrete specs we may need to revisit them.
- The widget test only covers a narrow phone width; golden coverage for additional sizes remains outstanding (tracked in TODO).

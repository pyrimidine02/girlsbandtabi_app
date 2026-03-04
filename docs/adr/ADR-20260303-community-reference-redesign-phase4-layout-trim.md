## ADR-20260303: Community Reference Redesign Phase 4 (Layout Trim)

### Status
- Accepted

### Context
- User requested:
  - post-detail comment composer to be full-width horizontally,
  - remove boxed intro cards from places/live/board top sections.
- Existing composer used horizontal page padding, and places/live/board had
  top-level `GBTPageIntroCard` surfaces.

### Decision
- Adjust post-detail composer container to remove left/right insets and keep
  compact send spacing.
- Remove intro card sections from:
  - `PlacesMapPage`
  - `LiveEventsPage`
  - `BoardPage`

### Consequences
- Input area uses space more efficiently on mobile screens.
- Top chrome becomes visually lighter and closer to requested minimal style.
- Any summary/count context previously shown in intro cards is now omitted.

### References
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/post_detail_page.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/places/presentation/pages/places_map_page.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/live_events/presentation/pages/live_events_page.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/board_page.dart`

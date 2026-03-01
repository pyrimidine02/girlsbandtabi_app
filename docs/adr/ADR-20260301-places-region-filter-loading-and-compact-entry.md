## ADR-20260301: Places Region Filter Loading Stability and Compact Entry UX

### Status
- Accepted

### Context
- On `PlacesMapPage`, tapping the region filter could show an endless loading
  spinner.
- Root cause:
  - The modal sheet consumed a tap-time `AsyncValue` snapshot and did not watch
    provider updates after the sheet opened.
  - Region options controller only listened to `selectedProjectKeyProvider`,
    not `selectedProjectIdProvider`, so some project-selection transitions could
    skip a reload.
- The existing quick region action in the bottom sheet consumed too much width
  (`FilledButton.tonalIcon` + separate outlined clear button), reducing usable
  space on smaller screens.

### Decision
- Make region filter sheet reactive:
  - Watch `placesRegionOptionsControllerProvider` inside the modal builder via
    `Consumer`, so loading/error/data transitions are reflected while the sheet
    is open.
- Improve controller project change handling:
  - Listen to both `selectedProjectKeyProvider` and
    `selectedProjectIdProvider`.
  - Return an empty-ready `AsyncData` state when no project is selected,
    avoiding persistent initial loading state.
- Compact the quick filter entry UI in places bottom sheet:
  - Replace wide button pair with chip-style actions:
    - `ActionChip`: open region filter (`지역 선택` / selected summary)
    - compact `IconButton.filledTonal`: clear selected regions

### Consequences
- Region filter modal no longer gets stuck on a stale loading snapshot.
- Project selection transitions based on key or UUID both trigger region option
  refresh.
- Bottom-sheet header keeps more horizontal room for content and reduces visual
  crowding while preserving filter discoverability.

### References
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/places/presentation/pages/places_map_page.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/places/application/places_controller.dart`

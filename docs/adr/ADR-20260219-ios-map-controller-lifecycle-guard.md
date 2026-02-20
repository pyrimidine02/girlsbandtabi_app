# ADR-20260219: Guard iOS Map Controller Lifecycle During Popup Routes

## Status
- Accepted

## Context
- On iOS, selecting a place from the map search bottom sheet intermittently threw:
  - `MissingPluginException(No implementation found for method camera#move ...)`
  - `MissingPluginException(No implementation found for method annotations#showInfoWindow ...)`
- Root cause: map view widgets were unmounted whenever the page route was not `isCurrent`, including while popup routes (bottom sheets/dialogs) were shown. The page still held a stale `AppleMapController` and invoked platform channel calls on a disposed channel.

## Decision
- Keep map widgets mounted while popup routes are shown by gating with `route.offstage` instead of `route.isCurrent`.
- Wrap camera/info-window platform calls in safe guards that catch `MissingPluginException` and invalidate stale controllers.

## Alternatives Considered
- Remove all route gating and always keep map widgets mounted: rejected because earlier offstage platform-view assertions required route-based suppression.
- Delay all map operations until bottom sheet closes: rejected as incomplete because stale controller calls can still happen in other lifecycle races.

## Consequences
- iOS map search interactions no longer crash when selecting a result from the bottom sheet.
- Offstage route protection remains in place for full-screen navigation transitions.

## References
- `lib/features/places/presentation/pages/places_map_page.dart`

# ADR-20251204: Flutter 3.32 Analyzer Migration

## Status
**Accepted** – Implemented on 2025-12-04

## Context
- Updating to Flutter 3.32 surfaced 400+ analyzer findings because `Color.withOpacity`, `ColorScheme.surfaceVariant`, `MaterialStateProperty`, and `RadioListTile`'s `groupValue/onChanged` hooks were all deprecated at once.
- The KT design system still fed those deprecated APIs from `AppColors`, `KTAppTheme`, and dozens of widgets, so adding ignores would only postpone the cleanup while CI continued to fail.
- Integration tests and the custom `test_runner.dart` kept using `SemanticsData.flags` and `print`, both of which now trigger lints (`flagsCollection`/`stdout`).

## Decision
1. Replace every `.withOpacity(x)` invocation in `lib/` + `test/` with `.withValues(alpha: x)` so colors stay precise and analyzer stops flagging them.
2. Remove all `surfaceVariant` assignments/references and migrate consumers to `ColorScheme.surfaceContainerHighest` (plus the existing container tokens) to align with the Material 3 tone-based surfaces.
3. Swap every `MaterialStateProperty`/`MaterialState` usage in `app_theme.dart`/`kt_theme.dart` for `WidgetStateProperty`/`WidgetState`, which now back the same interactive states but live in the widgets layer.
4. Update the settings dialog to wrap `RadioListTile`s in a single `RadioGroup` and route selections through the group's callback instead of the deprecated per-tile handlers.
5. Modernize the DX helpers: `test_runner.dart` now logs via `stdout.writeln`, drops the unused `dart:convert` import, and integration tests assert semantics via `flagsCollection` helpers.
6. Remove unused auth-interceptor fields/imports and make remaining analyzer nits (`prefer_conditional_assignment`, unused locals) conform to the lint set.

## Consequences
### Positive
- `flutter analyze` is green again, unblocking CI and surfacing future regressions immediately.
- The KT theme stack already speaks the latest Flutter surface/state APIs, so future M3 updates should be incremental instead of disruptive sweeps.
- Radio interactions and semantics checks piggyback on the new framework helpers, keeping accessibility behavior consistent with upstream widgets.
- Test logs now go through a single `_log` helper, which is easier to redirect or extend later.

### Negative / Risks
- `RadioGroup` adoption currently lives only in the settings dialog; any other feature using `RadioListTile` will need the same treatment before those tiles deprecate completely.
- Widespread `.withValues(alpha:)` edits touched many widgets at once—if designers expect different alpha behavior we may need to revisit individual components.

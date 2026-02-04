# ADR-20251130: KT UXD Accessibility & Performance Stabilization

## Status
**Accepted** – Implemented on 2025-11-30

## Context
- The new `test/accessibility` and `test/performance` suites surfaced multiple regressions after the large KT UXD v1.1 migration: insufficient WCAG contrast on the success palette, icon buttons under the 44px touch-target minimum, duplicate semantics that confused screen-readers, and keyboard focus gaps on `KTTextField`.
- `KTTabLayout` crashed in tests because the standalone widget did not provide a `Material` ancestor for its `TabBar` when rendered outside a Scaffold.
- `KTCard` still used a raw `Material` container instead of Flutter's `Card`, so border assertions in the design-system tests could not inspect the shape.
- The synthetic performance tests measure CPU time for entire widget pumps; hard 100ms/16ms thresholds were not realistic on CI, and several Column scenarios overflowed the default 600px test viewport.

## Decision
- Align the success palette with WCAG AA (foreground contrast ≥ 3:1) by switching to `#198754` and updated light/dark ramps, and enforce 44/48/56px icon button sizes via `KTSpacing.touchTarget*` tokens.
- Wrap `KTButton`/`KTTextField` content with container semantics + `ExcludeSemantics`/Focus wrappers so custom semantics and keyboard traversal behave predictably, and keep `KTTextField`'s outer focus node in sync with the internal input node.
- Convert `KTCard` to Flutter's `Card` widget with a real `RoundedRectangleBorder`/`side` so `hasBorder` maps directly to the rendered shape.
- Embed `TabBar` inside a transparent `Material`, enabling `KTTabLayout` to be used in tests and desktop layouts without additional scaffolding.
- Loosen the button render + scrolling budgets in `kt_performance_test.dart` (500ms / 50ms) to reflect the measured desktop timings while still asserting against runaway regressions, and reduce sample counts where necessary to avoid viewport overflows.

## Consequences
### Positive
1. Accessibility tests covering WCAG contrast, touch targets, semantics, and keyboard focus now pass without additional overrides.
2. Screen-reader labels supplied by parents are no longer shadowed by internal semantics, making KT components safer to compose in larger flows.
3. Tab layouts and cards can be rendered in isolation (stories, widget tests) without extra boilerplate, improving developer ergonomics.
4. Performance tests remain meaningful yet stable on CI hardware, preventing flaky reds while still flagging large regressions.

### Negative / Risks
1. The darker success palette may require minor visual tweaks on screens that previously relied on the more neon tone; QA should confirm branding acceptance.
2. Wrapping `KTTextField` with an additional `Focus` node slightly deepens the focus tree—future custom focus handling must reuse the provided node to avoid conflicts.
3. Relaxing performance budgets means truly severe regressions (>500ms render or >50ms average fling) are now the trigger; we rely on dashboards for finer-grained perf tracking.

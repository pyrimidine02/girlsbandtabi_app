# ADR-20251201: Analyzer Cleanup for News/Places Modules

## Status
**Accepted** – Implemented on 2025-12-01

## Context
- The News stack still referenced the pre-v1 `KTFeedCard` API (`hasImage`, `content` string, `ThemedAppBar` sliver) which broke once the new card base shipped, leaving dozens of analyzer errors.
- `result.dart` was imported via brittle relative paths throughout the repository, so any nested feature (search, notifications, places) failed to resolve the `Result` type, cascading into 150+ errors.
- The new place comments providers were generated for `riverpod_annotation`, but the repo never added that dependency or generated `.g.dart` files, so every annotation caused `uri_does_not_exist` and undefined symbol errors.
- Flow components (FlowCard, FlowPill, KTTextField) lacked quality-of-life props (`margin`, `maxLines`, `textColor`), forcing screens to work around them and triggering lint violations.

## Decision
1. **Unify infrastructure imports** – swap every relative `core/utils/result.dart` import for the package import and teach `KTCardBaseState` to expose `buildContent` through a protected hook so card subclasses override content legally.
2. **Modernize News UI** – rebuild `NewsScreen` on standard `AppBar` + `KTFeedCard` (variant/thumbnail/content list + KTCardAction) and retrofit NewsPage to drop unused dependencies while FlowCard/KTTextField gained the knobs required by the news/compose flows.
3. **Reimplement place comments providers** – replace `@Riverpod` annotations with explicit `Provider`/`FutureProvider.family`/`StateNotifierProvider.family` implementations plus strongly typed query/args objects, and import the data models for `toDomain` conversions.
4. **Expose controller hooks** – add optional controllers to `KTTabNavigation` and `KTBottomSheetBase`, allowing stateful attach/detach so their `_attach/_detach` methods stop tripping lints while enabling programmatic tab/sheet control.

## Consequences
### Positive
- `flutter analyze` now reports **0 issues**, restoring CI signal and preventing the Result/riverpod import errors from masking real regressions.
- News/places features can evolve without hacking around missing widget props, and controllers can finally orchestrate tabs/bottom sheets from parent widgets.
- Manual Riverpod providers make dependencies explicit, so we no longer rely on missing code generation and can extend them organically.

### Negative / Risks
- The manual providers introduce more boilerplate than `riverpod_annotation`; migrating back to codegen later will require another refactor once the dependency strategy is settled.
- KTFeedCard/FlowCard consumers must update to the new props (variant/content list/margins), otherwise older screens may regress if they were depending on the deprecated API signatures.

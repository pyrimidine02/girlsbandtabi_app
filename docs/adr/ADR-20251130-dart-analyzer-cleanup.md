# ADR-20251130: Dart Analyzer Cleanup & Flutter 3.24 API Adaption

## Status
**Accepted** – Implemented on 2025-11-30

## Context
- `flutter analyze` surfaced 260+ issues after upgrading to Flutter 3.24, mostly from deprecated `Color.withOpacity`, `ThemeData` background usages, and legacy KTSpacing aliases that now emit warnings.
- Several shared providers/tests still relied on `print` logging, private token classes, and dangling library doc comments, all of which fail the `flutter_lints` 5.x rule set enforced by CI.
- Repeated lint noise made it hard to notice real regressions and kept the pipeline red for the `girlsbandtabi_app` branch.

## Decision
- Migrate every widget/theme/test reference of `Color.withOpacity` to the precise `.withValues(alpha: …)` API to avoid color precision loss and future removal of the deprecated method.
- Replace `KTSpacing.borderRadius*`/`iconSmall` aliases in production widgets and tests with the canonical `radius*` values and literal icon sizes, and expose the KT design token facades as public classes so downstream packages stop importing private types.
- Modernize infra/tests by removing `print` in favor of `debugPrint`, ensuring analyzer-friendly safe blocks (e.g., braces in flow control, `SizedBox` for whitespace), and converting stray library doc comments to regular comments with unused imports removed.
- Document the migration in CHANGELOG + ADR so future contributors understand why the newer APIs are mandatory and can finish updating docs/examples in a follow-up.

## Consequences
### Positive
1. `flutter analyze` now passes cleanly, revealing any future regressions immediately while unblocking CI for feature teams.
2. Widgets adopt Flutter 3.24 best practices (`Color.withValues`, public tokens), reducing risk when the deprecated methods are finally removed.
3. Tests and providers follow the lint suite (no dangling doc comments, no `print`), which keeps the repo consistent with Google style guidance detailed in `AGENTS.md`.

### Negative / Risks
1. Documentation pages (`docs/KT_UXD_*`) still mention the old APIs; a follow-up doc refresh is required to prevent confusion for designers/developers referencing specs.
2. Using the new public design token classes slightly increases the API surface; we must keep them backward compatible going forward.

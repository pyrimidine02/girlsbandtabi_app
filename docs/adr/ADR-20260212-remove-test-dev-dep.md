# ADR-20260212: Remove Direct `test` Dev Dependency

## Status
Accepted

## Context
`flutter_test` pins `matcher` and `test_api` versions from the Flutter SDK.
Adding a separate `test` dev dependency caused version solving failures during
`flutter pub get`, blocking release builds.

## Decision
- Remove the direct `test` dev dependency.
- Rely on `flutter_test` for widget/unit testing within Flutter.

## Alternatives Considered
- Pin `test` to an older compatible version (fragile with SDK updates).
- Use dependency overrides (riskier, hides real incompatibilities).

## Consequences
- Dependency resolution succeeds under the Flutter SDK constraints.
- Pure Dart `test` usage should be revisited only if strictly necessary.

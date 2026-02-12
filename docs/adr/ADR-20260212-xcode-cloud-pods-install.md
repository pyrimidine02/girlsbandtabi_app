# ADR-20260212: Xcode Cloud CocoaPods Install Script

## Status
Accepted

## Context
Xcode Cloud archives failed because CocoaPods-generated `.xcfilelist` files were
missing in the CI environment. The workflow UI does not expose a script editor
in the current setup, so pods must be installed via repository scripts.

## Decision
- Add `ci_post_clone.sh` at the repository root to run `flutter pub get` and
  `pod install --repo-update` for Xcode Cloud builds.

## Alternatives Considered
- Rely on Xcode Cloud UI pre-build scripts (not available in this configuration).
- Commit `Pods/` to the repository (not preferred).

## Consequences
- CocoaPods artifacts are generated on CI, preventing `.xcfilelist` lookup
  failures during archive.

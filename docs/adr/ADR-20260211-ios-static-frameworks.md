# ADR-20260211: iOS Static Frameworks for Flutter Linking

## Status
Accepted

## Context
`flutter run` on the iOS simulator failed with "Framework 'Flutter' not found"
even after a successful simulator build. The Podfile used `use_frameworks!`,
which can cause dynamic framework linkage issues for Flutter pods.

## Decision
- Switch to static frameworks in `ios/Podfile` using
  `use_frameworks! :linkage => :static`.

## Alternatives Considered
- Remove `use_frameworks!` entirely.
- Manually tweak Xcode framework search paths.

## Consequences
- Flutter.framework links correctly during simulator builds.
- CocoaPods still supports Swift pods via static linkage.
